module tb_rtl_dotopt();


    logic clk;
    logic rst_n;
    logic slave_waitrequest;
    logic [3:0] slave_address;
    logic slave_read;
    logic [31:0] slave_readdata;
    logic slave_write;
    logic [31:0] slave_writedata;
    logic master_waitrequest;
    logic [31:0] master_address;
    logic master_read;
    logic [31:0] master_readdata;
    logic master_readdatavalid;
    logic master_write;
    logic [31:0] master_writedata;

    logic master2_waitrequest;
    logic [31:0] master2_address;
    logic master2_read;
    logic [31:0] master2_readdata;
    logic master2_readdatavalid;
    logic master2_write;
    logic [31:0] master2_writedata;


    dotopt dut(.*);


    /* Inputs
    input logic clk
    input logic rst_n
    input logic [3:0] slave_address
    input logic slave_read
    input logic slave_write
    input logic [31:0] slave_writedata
    input logic master_waitrequest
    input logic [31:0] master_readdata
    input logic master_readdatavalid
    */

    /* Outputs
    
    output logic slave_waitrequest
    output logic [31:0] slave_readdata
    output logic [31:0] master_address
    output logic master_read
    output logic master_write
    output logic [31:0] master_writedata
    */

    always #5 clk = ~clk;

    initial begin
    
        clk = 1'b0;
            
        #10

        rst_n = 1'b0;

        #10

        rst_n = 1'b1;

        //IDLE Initalizing

        master_waitrequest = 1'b1;
        master_readdatavalid = 1'b0;

        master2_readdatavalid = 1'b0;
        master2_readdata = 32'b0000000000000001_0000000000000000;
        master2_waitrequest = 1'b1;

        slave_write = 4'd1;
        slave_address = 4'd2;
        slave_writedata = 32'd1;

        #10

        assert(dut.w_address === 32'd1)

        slave_address = 4'd3;
        slave_writedata = 32'd256;
        
        #10

        assert(dut.a_address === 32'd256)

        slave_address = 4'd5;
        slave_writedata = 32'd3;

        #10

        assert(dut.v_length === 32'd3)

        slave_address = 4'd0;
        slave_write = 4'd0;

        //IDLE to IDLE
        #10

        slave_write = 4'd1;

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
        master2_waitrequest = 1'b0;

        //READ_W to READ_W
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.w_address);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master2_waitrequest = 1'b1;
        
        master2_readdatavalid = 1'b1;
        master2_readdata = 32'b0000000000000011_0000000000000000;

        //READ_W to READ_W
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.w_address);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);
        
        master_waitrequest = 1'b0;
        
        master2_readdatavalid = 1'b0;

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

        //STORE to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b1;
        master_readdata = 32'b000000000000001_0000000000000000;

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

        master2_waitrequest = 1'b0;

        //READ_W to READ_W
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.w_address + 4);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);
        
        master_waitrequest = 1'b0;
        
        master2_waitrequest = 1'b1;
        master2_readdatavalid = 1'b1;
        master2_readdata = 32'b0000000000000010_0000000000000000;

        //READ_W to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_waitrequest = 1'b1;

        master2_readdatavalid = 1'b0;

        //STORE to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        //STORE to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b1;
        master_readdata = 32'b0000000000000010_0000000000000000;

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

        master2_waitrequest = 1'b0;

        //READ_W to READ_W
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.w_address + 8);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master2_readdatavalid = 1'b1;
        master2_readdata = 32'b0000000000000001_0000000000000000;

        master2_waitrequest = 1'b1;
        
        //READ_W to READ_W
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === dut.w_address + 8);
        assert(master_read === 1);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_waitrequest = 1'b0;
        master2_readdatavalid = 1'b0;
        
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

        //STORE to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b1;
        master_readdata = 32'b0000000000000011_0000000000000000;

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

        //STORE to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b1;
        master_readdata = 32'b0000000000000001_1000000000000000;

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

        //STORE to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b1;
        master_readdata = 32'b0000000000000010_1000000000000000;

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
        master_readdata = 32'b0000000000000011_1000000000000000;

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

        assert(slave_readdata === 32'b0000000000000111_1000000000000000);
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

        //STORE to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b1;
        master_readdata = 32'b1111111111111110_1000000000000000;

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

        //STORE to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b1;
        master_readdata = 32'b1111111111111101_1000000000000000;

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

        //STORE to STORE
        #10

        assert(slave_readdata === 0);
        assert(slave_waitrequest === 1);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        master_readdatavalid = 1'b1;
        master_readdata = 32'b0000000000000011_1000000000000000;

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

        assert(slave_readdata === 32'b1111111111111111_1000000000000000);
        assert(slave_waitrequest === 0);
        assert(master_address === 0);
        assert(master_read === 0);
        assert(master_write === 0);
        assert(master_writedata === 0);

        slave_write = 4'd0;

        #100;

        $stop;
    end

endmodule: tb_rtl_dotopt
