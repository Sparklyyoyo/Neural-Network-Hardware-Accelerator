module dot(input logic clk, input logic rst_n,
           // slave (CPU-facing)
           output logic slave_waitrequest,
           input logic [3:0] slave_address,
           input logic slave_read, output logic [31:0] slave_readdata,
           input logic slave_write, input logic [31:0] slave_writedata,
           // master (memory-facing)
           input logic master_waitrequest,
           output logic [31:0] master_address,
           output logic master_read, input logic [31:0] master_readdata, input logic master_readdatavalid,
           output logic master_write, output logic [31:0] master_writedata);

    enum {IDLE, READ_W, READ_A, STORE, CALCULATE} state;

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

    always_ff @(posedge clk or negedge rst_n)

        if (!rst_n) begin

            state <= IDLE;

            w_address <= 32'b0;
            a_address <= 32'b0;
            v_length <= 32'b0;
            num_multiplications <= 32'b0;
            latest_weight <= 32'b0;
            latest_activation <= 32'b0;
            dot_product_sum <= 32'b0;
            read_a_flag <= 1'b0;
            latest_result <= 32'b0;
        end 
        
        else begin

            case (state)
                IDLE: begin
                    
                    if ((slave_write === 1'b1) && (slave_address === 4'b0)) begin
                        state <= READ_W;
                    end
                    
                    else
                        state <= IDLE;

                    if(slave_write) begin

                        case(slave_address)

                            4'd2: w_address <= slave_writedata;
                            4'd3: a_address <= slave_writedata;
                            4'd5: v_length <= slave_writedata;
                        endcase
                    end

                    dot_product_sum <= 32'b0;
                    num_multiplications <= 32'b0;
                    latest_weight <= 32'b0;
                    latest_activation <= 32'b0;
                end

                READ_W: begin

                    if (!master_waitrequest)
                        state <= STORE;
                    
                    else
                        state <= READ_W;
                end

                STORE: begin

                    if (master_readdatavalid) begin

                        if(!read_a_flag) begin
                            state <= READ_A;
                            latest_weight <= master_readdata;
                        end
                        
                        else begin
                            state <= CALCULATE;
                            latest_activation <= master_readdata;
                        end
                    end 
                    
                    else
                        state <= STORE;
                end

                READ_A: begin

                    if (!master_waitrequest)
                        state <= STORE;
                    
                    else
                        state <= READ_A;
                    
                    read_a_flag <= 1'b1;
                end

                CALCULATE: begin

                    dot_product_sum <= dot_product_sum + truncucated_result;

                    if((num_multiplications + 32'd1) < v_length) begin
                        state <= READ_W;
                    end

                    else begin
                        state <= IDLE;
                        latest_result <= dot_product_sum + truncucated_result;
                    end

                    num_multiplications <= num_multiplications + 32'd1;

                    read_a_flag <= 1'b0;
                end
            endcase
        end

    /* Outputs
    
    output logic slave_waitrequest
    output logic [31:0] slave_readdata
    output logic [31:0] master_address
    output logic master_read
    output logic master_write
    output logic [31:0] master_writedata
    */

    always_comb begin
        
        multiplication_result = 32'b0;
        truncucated_result = 32'b0;

        case(state)

            IDLE: begin

                slave_readdata = latest_result;
                slave_waitrequest = 1'b0;
                master_address = 32'b0;
                master_read = 1'b0;
                master_write = 1'b0;
                master_writedata = 32'b0;
            end

            READ_W: begin

                slave_readdata = 32'b0;
                slave_waitrequest = 1'b1;
                master_address = w_address + (num_multiplications * 32'd4);
                master_read = 1'b1;
                master_write = 1'b0;
                master_writedata = 32'b0;
            end

            READ_A: begin

                slave_readdata = 32'b0;
                slave_waitrequest = 1'b1;
                master_address = a_address + (num_multiplications * 32'd4);
                master_read = 1'b1;
                master_write = 1'b0;
                master_writedata = 32'b0;
            end

            STORE: begin

                slave_readdata = 32'b0;
                slave_waitrequest = 1'b1;
                master_address = 32'b0;
                master_read = 1'b0;
                master_write = 1'b0;
                master_writedata = 32'b0;
            end

            CALCULATE: begin

                slave_readdata = 32'b0;
                slave_waitrequest = 1'b1;
                master_address = 32'b0;
                master_read = 1'b0;
                master_write = 1'b0;
                master_writedata = 32'b0;

                multiplication_result = latest_weight * latest_activation;
                truncucated_result = multiplication_result [47:16];
            end

            default: begin

                slave_readdata = 32'bx;
                slave_waitrequest = 1'bx;
                master_address = 32'bx;
                master_read = 1'bx;
                master_write = 1'bx;
                master_writedata = 32'bx;
            end
        endcase
    end

endmodule: dot
