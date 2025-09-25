/*
--- File:    tb_rtl_dot.sv
--- Module:  tb_rtl_dot
--- Brief:   Testbench driving the 'dot' accelerator via simple stimulus and immediate assertions.

--- Description:
---   Instantiates 'dot' with wildcard port connections and steps through IDLE→READ_W→STORE→READ_A→CALCULATE
---   sequences while checking visible DUT behavior with immediate assertions.
---   Notes: master2_* signals and some assertions appear in comments or as undeclared references here;
---   they were left intact intentionally (formatting-only pass).

--- Interfaces:
---   Drives: clk, rst_n, slave_*, master_* (matching 'dot' ports).
---   Observes: slave_readdata, slave_waitrequest, master_*.

--- Author: Joey Negm
*/

module tb_rtl_dot();

    // --- Signals ---
    logic        clk;
    logic        rst_n;

    // Slave (CPU-facing)
    logic        slave_waitrequest;
    logic [3:0]  slave_address;
    logic        slave_read;
    logic [31:0] slave_readdata;
    logic        slave_write;
    logic [31:0] slave_writedata;

    // Master (memory-facing)
    logic        master_waitrequest;
    logic [31:0] master_address;
    logic        master_read;
    logic [31:0] master_readdata;
    logic        master_readdatavalid;
    logic        master_write;
    logic [31:0] master_writedata;

    // --- DUT ---
    dot dut(.*);

    // --- Clock ---
    always #5 clk = ~clk;

    initial begin
    
        clk = 1'b0;
            
        #10

        rst_n = 1'b0;

        #10

        rst_n = 1'b1;

        //IDLE Initializing

        master_waitrequest   = 1'b1;
        master_readdatavalid = 1'b0;

        master2_waitrequest   = 1'b1;
        master2_readdatavalid = 1'b0;

        slave_write     = 4'd1;
        slave_address   = 4'd2;
        slave_writedata = 32'd1;

        #10

        assert(dut.w_address === 32'd1);

        slave_address   = 4'd3;
        slave_writedata = 32'd256;
        
        #10

        assert(dut.a_address === 32'd256);

        slave_address   = 4'd5;
        slave_writedata = 32'd3;

        #10

        assert(dut.v_length === 32'd3);

        slave_address   = 4'd0;
        slave_write     = 4'd0;

        //IDLE to IDLE
        #10

        slave_write     = 4'd1;

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 0);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        //IDLE to READ_W
        #10
        
        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.w_address);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);

        slave_write = 4'd0;

        //READ_W to READ_W
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.w_address);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);
        
        master_waitrequest = 1'b0;
        

        //READ_W to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_waitrequest = 1'b1;

        //STORE to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b1;
        master_readdata      = 32'b0000000000000001_0000000000000000;

        //STORE to READ_A
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.a_address);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b0;

        //READ_A to READ_A
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.a_address);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_waitrequest = 1'b0;

        //READ_A to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_waitrequest = 1'b1;

        //STORE to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b1;
        master_readdata      = 32'b0000000000000011_0000000000000000;

        //STORE to CALCULATE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);        

        master_readdatavalid = 1'b0;

        //CALCULATE to READ_W (CYCLE 1 COMPLETE)
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.w_address + 4);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);

        //READ_W to READ_W
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.w_address + 4);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);
        
        master_waitrequest = 1'b0;
        

        //READ_W to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_waitrequest = 1'b1;

        //STORE to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b1;
        master_readdata      = 32'b0000000000000010_0000000000000000;

        //STORE to READ_A
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.a_address + 4);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b0;

        //READ_A to READ_A
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.a_address + 4);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_waitrequest = 1'b0;

        //READ_A to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_waitrequest = 1'b1;

        //STORE to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b1;
        master_readdata      = 32'b0000000000000010_0000000000000000;

        //STORE to CALCULATE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);        

        master_readdatavalid = 1'b0;

        //CALCULATE to READ_W (CYCLE 2 COMPLETE)
        #10


        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.w_address + 8);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);

        //READ_W to READ_W
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.w_address + 8);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);
        
        master_waitrequest = 1'b0;
        

        //READ_W to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_waitrequest = 1'b1;

        //STORE to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b1;
        master_readdata      = 32'b0000000000000011_0000000000000000;

        //STORE to READ_A
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.a_address + 8);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b0;

        //READ_A to READ_A
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.a_address + 8);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_waitrequest = 1'b0;

        //READ_A to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_waitrequest = 1'b1;

        //STORE to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b1;
        master_readdata      = 32'b0000000000000001_0000000000000000;

        //STORE to CALCULATE (CYCLE 3 COMPLETE)
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);        

        master_readdatavalid = 1'b0;

        //CALCULATE to IDLE //(CALCULATION 1 COMPLETE)
        #10

        assert(slave_readdata === 32'b0000000000001010_0000000000000000);
        assert(slave_waitrequest === 0);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        slave_write = 4'd1;

        //IDLE to READ_W
        #10
        
        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.w_address);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);

        slave_write = 4'd0;

        //READ_W to READ_W
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.w_address);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);
        
        master_waitrequest = 1'b0;
        

        //READ_W to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_waitrequest = 1'b1;

        //STORE to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b1;
        master_readdata      = 32'b0000000000000001_1000000000000000;

        //STORE to READ_A
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.a_address);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b0;

        //READ_A to READ_A
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.a_address);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_waitrequest = 1'b0;

        //READ_A to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_waitrequest = 1'b1;

        //STORE to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b1;
        master_readdata      = 32'b0000000000000011_1000000000000000;

        //STORE to CALCULATE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);        

        master_readdatavalid = 1'b0;

        //CALCULATE to READ_W (CYCLE 1 COMPLETE)
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.w_address + 4);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);

        //READ_W to READ_W
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.w_address + 4);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);
        
        master_waitrequest = 1'b0;
        

        //READ_W to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_waitrequest = 1'b1;

        //STORE to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b1;
        master_readdata      = 32'b0000000000000010_1000000000000000;

        //STORE to READ_A
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.a_address + 4);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b0;

        //READ_A to READ_A
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.a_address + 4);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_waitrequest = 1'b0;

        //READ_A to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_waitrequest = 1'b1;

        //STORE to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b1;
        master_readdata      = 32'b0000000000000010_1000000000000000;

        //STORE to CALCULATE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);        

        master_readdatavalid = 1'b0;

        //CALCULATE to READ_W (CYCLE 2 COMPLETE)
        #10


        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.w_address + 8);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);

        //READ_W to READ_W
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.w_address + 8);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);
        
        master_waitrequest = 1'b0;
        

        //READ_W to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_waitrequest = 1'b1;

        //STORE to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b1;
        master_readdata      = 32'b0000000000000011_1000000000000000;

        //STORE to READ_A
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.a_address + 8);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b0;

        //READ_A to READ_A
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.a_address + 8);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_waitrequest = 1'b0;

        //READ_A to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_waitrequest = 1'b1;

        //STORE to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b1;
        master_readdata      = 32'b0000000000000001_1000000000000000;

        //STORE to CALCULATE (CYCLE 3 COMPLETE)
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);        

        master_readdatavalid = 1'b0;

        //CALCULATE to IDLE (CALCULATION 2 COMPLETE)
        #10

        assert(slave_readdata === 32'b0000000000010000_1100000000000000);
        assert(slave_waitrequest === 0);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        slave_write = 4'd1;

        //IDLE to READ_W
        #10
        
        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.w_address);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);

        slave_write = 4'd0;

        //READ_W to READ_W
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.w_address);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);
        
        master_waitrequest = 1'b0;
        

        //READ_W to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_waitrequest = 1'b1;

        //STORE to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b1;
        master_readdata      = 32'b1111111111111110_1000000000000000;

        //STORE to READ_A
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.a_address);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b0;

        //READ_A to READ_A
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.a_address);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_waitrequest = 1'b0;

        //READ_A to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_waitrequest = 1'b1;

        //STORE to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b1;
        master_readdata      = 32'b0000000000000011_1000000000000000;

        //STORE to CALCULATE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);        

        master_readdatavalid = 1'b0;

        assert(dut.latest_weight === 32'b1111111111111110_1000000000000000);
        assert(dut.latest_activation === 32'b0000000000000011_1000000000000000);

        assert(dut.multiplication_result === 64'b11111111111111111111111111111010_11000000000000000000000000000000)
                                    //Result:64'b11111111111111111111111111111110_01000000000000000000000000000000
        else
            $display("Result is wrong. Got %b", dut.multiplication_result);

        assert(dut.truncucated_result === 32'b1111111111111010_1100000000000000)

        //CALCULATE to READ_W (CYCLE 1 COMPLETE)
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.w_address + 4);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);

        //READ_W to READ_W
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.w_address + 4);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);
        
        master_waitrequest = 1'b0;
        

        //READ_W to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_waitrequest = 1'b1;

        //STORE to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b1;
        master_readdata      = 32'b1111111111111101_1000000000000000;

        //STORE to READ_A
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.a_address + 4);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b0;

        //READ_A to READ_A
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.a_address + 4);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_waitrequest = 1'b0;

        //READ_A to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_waitrequest = 1'b1;

        //STORE to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b1;
        master_readdata      = 32'b0000000000000010_1000000000000000;

        //STORE to CALCULATE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);        

        master_readdatavalid = 1'b0;

        //CALCULATE to READ_W (CYCLE 2 COMPLETE)
        #10


        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.w_address + 8);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);

        //READ_W to READ_W
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.w_address + 8);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);
        
        master_waitrequest = 1'b0;
        

        //READ_W to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_waitrequest = 1'b1;

        //STORE to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b1;
        master_readdata      = 32'b0000000000000011_1000000000000000;

        //STORE to READ_A
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.a_address + 8);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b0;

        //READ_A to READ_A
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.a_address + 8);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_waitrequest = 1'b0;

        //READ_A to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_waitrequest = 1'b1;

        //STORE to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b1;
        master_readdata      = 32'b0000000000000001_1000000000000000;

        //STORE to CALCULATE (CYCLE 3 COMPLETE)
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);        

        master_readdatavalid = 1'b0;

        //CALCULATE to IDLE
        #10

        assert(slave_readdata === 32'b1111111111111001_1100000000000000);
        assert(slave_waitrequest === 0);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);
        $stop;
    end
endmodule: tb_rtl_dot
