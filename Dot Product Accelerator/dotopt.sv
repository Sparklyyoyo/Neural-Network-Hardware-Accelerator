/*
--- File:    dotopt.sv
--- Module:  dotopt
--- Brief:   Optimized dot-product accelerator with CPU slave, SDRAM master (weights), and SRAM master2 (activations).

--- Description:
---   Computes a dot product using two memory channels: SDRAM for weights, SRAM for activations.
---   CPU programs base addresses and vector length, then writes to control register 0 to start.
---   Final result is readable via the slave interface when the FSM returns to IDLE.

--- Interfaces:
---   clk, rst_n          : Clock and active-low reset.
---   slave_* (CPU)       : Configuration and result readback.
---   master_* (SDRAM)    : Read interface for weights.
---   master2_* (SRAM)    : Read interface for activations.

--- Author: Joey Negm
*/

module dotopt(
    input logic clk, 
    input logic rst_n,

    // --- CPU-facing (slave) ---
    output logic        slave_waitrequest,
    input  logic [3:0]  slave_address,
    input  logic        slave_read,
    output logic [31:0] slave_readdata,
    input  logic        slave_write,
    input  logic [31:0] slave_writedata,

    // --- SDRAM-facing (weights/biases) ---
    input  logic        master_waitrequest,
    output logic [31:0] master_address,
    output logic        master_read, 
    input  logic [31:0] master_readdata, 
    input  logic        master_readdatavalid,
    output logic        master_write, 
    output logic [31:0] master_writedata,

    // --- SRAM-facing (activations) ---
    input  logic        master2_waitrequest,
    output logic [31:0] master2_address,
    output logic        master2_read, 
    input  logic [31:0] master2_readdata, 
    input  logic        master2_readdatavalid,
    output logic        master2_write, 
    output logic [31:0] master2_writedata);

    // --- State Machine ---
    enum {IDLE, READ_W, READ_A, STORE, CALCULATE} state_W; // state_A;

    logic [31:0] w_address;
    logic [31:0] a_address;
    logic [31:0] v_length;
    logic [31:0] num_multiplications;

    logic signed [31:0] latest_weight;
    logic signed [31:0] latest_activation;
    logic signed [63:0] multiplication_result;
    logic signed [31:0] truncucated_result;
    logic signed [31:0] latest_result;
    logic signed [31:0] dot_product_sum;

    logic read_a_flag;
    logic calculation_done;

    always_ff @(posedge clk or negedge rst_n)
        if (!rst_n) begin
            state_W             <= IDLE;

            w_address           <= 32'b0;
            a_address           <= 32'b0;
            v_length            <= 32'b0;
            num_multiplications <= 32'b0;

            latest_weight       <= 32'b0;
            dot_product_sum     <= 32'b0;
            read_a_flag         <= 1'b0;
            latest_result       <= 32'b0;
            calculation_done    <= 1'b0;
            latest_activation   <= 32'b0;
        end
        else begin
            case (state_W)
                IDLE: begin
                    // --- Trigger when CPU writes to reg 0 ---
                    if ((slave_write === 1'b1) && (slave_address === 4'b0)) begin
                        state_W <= READ_W;
                    end
                    else begin
                        state_W <= IDLE;
                    end

                    // --- Configuration registers ---
                    if (slave_write) begin
                        case (slave_address)
                            4'd2: w_address <= slave_writedata;
                            4'd3: a_address <= slave_writedata;
                            4'd5: v_length  <= slave_writedata;
                        endcase
                    end

                    // --- Reset accumulators ---
                    dot_product_sum <= 32'b0;
                    num_multiplications <= 32'b0;
                    latest_weight <= 32'b0;
                    calculation_done <= 1'b0;
                end

                READ_W: begin
                    // --- Issue weight read when SDRAM is free ---
                    if (!master_waitrequest)
                        state_W <= STORE;
                    else
                        state_W <= READ_W;

                    if (!master2_waitrequest) begin
                        read_a_flag <= 1'b1;
                    end

                    if(master2_readdatavalid && read_a_flag) begin
                        latest_activation <= master2_readdata;
                    end
                end

                STORE: begin
                    // --- Capture weight ---
                    if (master_readdatavalid) begin
                        latest_weight <= master_readdata;
                        state_W       <= CALCULATE;
                    end
                    else
                        state_W <= STORE; 
                    
                    if (master2_readdatavalid && read_a_flag)
                        latest_activation <= master2_readdata;   
                end

                CALCULATE: begin
                    dot_product_sum <= dot_product_sum + truncucated_result;

                    if ((num_multiplications + 32'd1) < v_length) begin
                        state_W <= READ_W;
                    end
                    else begin
                        state_W       <= IDLE;
                        latest_result <= dot_product_sum + truncucated_result;
                    end

                    num_multiplications <= num_multiplications + 32'd1;
                    read_a_flag         <= 1'b0;
                end
            endcase
        end
    
    
    // --- COMB: Outputs ---
    always_comb begin
        
        multiplication_result = 32'b0;
        truncucated_result = 32'b0;

        case(state_W)

            IDLE: begin

                slave_readdata = latest_result;
                slave_waitrequest = 1'b0;
                master_address = 32'b0;
                master_read = 1'b0;
                master_write = 1'b0;
                master_writedata = 32'b0;

                master2_address = 32'b0;
                master2_read = 1'b0;
                master2_write = 1'b0;
                master2_writedata = 32'b0;                
            end

            READ_W: begin
                slave_readdata    = 32'b0;
                slave_waitrequest = 1'b1;

                // --- SDRAM: weight read ---
                master_address    = w_address + (num_multiplications * 32'd4);
                master_read       = 1'b1;
                master_write      = 1'b0;
                master_writedata  = 32'b0;

                // --- SRAM: activation read ---
                master2_address    = a_address + (num_multiplications * 32'd4);
                master2_read       = 1'b1;
                master2_write      = 1'b0;
                master2_writedata  = 32'b0; 

                if (!read_a_flag)
                    master2_read = 1'b1;
                else
                    master2_read = 1'b0;

            end

            STORE: begin
                slave_readdata    = 32'b0;
                slave_waitrequest = 1'b1;

                master_address    = 32'b0;
                master_read       = 1'b0;
                master_write      = 1'b0;
                master_writedata  = 32'b0;

                master2_address   = 32'b0;
                master2_read      = 1'b0;
                master2_write     = 1'b0;
                master2_writedata = 32'b0;                
            end

            CALCULATE: begin

                slave_readdata    = 32'b0;
                slave_waitrequest = 1'b1;

                master_address    = 32'b0;
                master_read       = 1'b0;
                master_write      = 1'b0;
                master_writedata  = 32'b0;

                master2_address   = 32'b0;
                master2_read      = 1'b0;
                master2_write     = 1'b0;
                master2_writedata = 32'b0;                

                multiplication_result = latest_weight * latest_activation;
                truncucated_result    = multiplication_result [47:16];
            end

            default: begin

                slave_readdata    = 32'bx;
                slave_waitrequest = 1'bx;
                master_address    = 32'bx;
                master_read       = 1'bx;
                master_write      = 1'bx;
                master_writedata  = 32'bx;

                master2_address   = 32'bx;
                master2_read      = 1'bx;
                master2_write     = 1'bx;
                master2_writedata = 32'bx;                
            end
        endcase
    end
endmodule: dotopt
