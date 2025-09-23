module tb_rtl_wordcopy();

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

    wordcopy dut(.*);

    always #5 clk = ~clk;

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

    initial begin

        clk = 1'b0;
        
        #10

        //Initalizing

        rst_n = 1'b0;
        master_readdatavalid = 1'b0;
        master_waitrequest = 1'b0;

        #10

        rst_n = 1'b1;

        slave_address = 4'd1;
        slave_write = 1'b1;
        slave_writedata = 32'd0;

        #10

        assert(dut.destination_address === 32'd0)
        slave_address = 4'd2;
        slave_write = 1'b1;
        slave_writedata = 32'd256;

        #10

        assert(dut.source_address === 32'd256)
        //assert(dut.state === IDLE)
        slave_address = 4'd3;
        slave_write = 1'b1;
        slave_writedata = 32'd3;

        #10

        assert(dut.num_words === 32'd3)
        slave_address = 4'd0;
        slave_write = 1'b1;
        slave_writedata = 32'd0;

        assert(master_read === 1'b0)
        assert(master_write === 1'b0)
        //assert(master_writedata === 32'd1)
        //assert(master_address === dut.destination_address)
        assert(slave_waitrequest === 1'b0)

        //IDLE to READ
        #10


        assert(master_read === 1'b1)
        assert(master_write === 1'b0)
       // assert(master_writedata === 32'd1)
        //assert(master_address === dut.source_address)
        assert(slave_waitrequest === 1'b1)

        master_waitrequest = 1'b1;

        //READ to READ
        #10

        assert(master_read === 1'b1)
        assert(master_write === 1'b0)
       // assert(master_writedata === 32'd1)
        assert(master_address === dut.source_address)
        assert(slave_waitrequest === 1'b1)

        master_waitrequest = 1'b0;

        //READ to WAIT
        #10

        assert(master_read === 1'b0)
        assert(master_write === 1'b0)
        //assert(master_writedata === 32'd1)
        //assert(master_address === 	dut.destination_address)
        assert(slave_waitrequest === 1'b1)

        master_waitrequest = 1'b1;

        master_readdatavalid = 1'b1;
        master_readdata = 32'd1;

        //WAIT to WAIT
        #10

        assert(master_read === 1'b0)
        assert(master_write === 1'b0)
        //assert(master_writedata === 32'd1)
        //assert(master_address === 	dut.destination_address)
        assert(slave_waitrequest === 1'b1)

        master_readdatavalid = 1'b0;

        //WAIT to WRITE
        #10

        assert(master_read === 1'b0)
        assert(master_write === 1'b1)
        assert(master_writedata === 32'd1)
        //assert(master_address === dut.destination_address)
        assert(slave_waitrequest === 1'b1)


        //WRITE to WRITE
        #10

        assert(master_read === 1'b0)
        assert(master_write === 1'b1)
        assert(master_writedata === 32'd1)
        assert(master_address === dut.destination_address)
        assert(slave_waitrequest === 1'b1)

        master_waitrequest = 1'b0;

        //WRITE to READ
        #10

        assert(master_read === 1'b1)
        assert(master_write === 1'b0)
       // assert(master_writedata === 32'd1)
        //assert(master_address === dut.source_address + 32'd4)
        assert(slave_waitrequest === 1'b1)

        master_waitrequest = 1'b1;

        //READ to READ
        #10

        assert(master_read === 1'b1)
        assert(master_write === 1'b0)
       // assert(master_writedata === 32'd1)
        assert(master_address === dut.source_address + 32'd4)
        assert(slave_waitrequest === 1'b1)

        master_waitrequest = 1'b0;

        //READ to WAIT
        #10

        assert(master_read === 1'b0)
        assert(master_write === 1'b0)
        //assert(master_writedata === 32'd1)
        //assert(master_address === 	dut.destination_address)
        assert(slave_waitrequest === 1'b1)

        master_waitrequest = 1'b1;

        //WAIT to WAIT
        #10

        assert(master_read === 1'b0)
        assert(master_write === 1'b0)
        //assert(master_writedata === 32'd1)
        //assert(master_address === 	dut.destination_address)
        assert(slave_waitrequest === 1'b1)

        
        master_readdatavalid = 1'b1;
        master_readdata = 32'd2;

        //WAIT to WAIT
        #10

        assert(master_read === 1'b0)
        assert(master_write === 1'b0)
        //assert(master_writedata === 32'd1)
        //assert(master_address === 	dut.destination_address)
        assert(slave_waitrequest === 1'b1)

        master_readdatavalid = 1'b0;

        //WAIT to WRITE
        #10

        assert(master_read === 1'b0)
        assert(master_write === 1'b1)
        assert(master_writedata === 32'd2)
       // assert(master_address === dut.destination_address + 32'd4)
        assert(slave_waitrequest === 1'b1)

        //WRITE to WRITE
        #10

        assert(master_read === 1'b0)
        assert(master_write === 1'b1)
        assert(master_writedata === 32'd2)
        assert(master_address === dut.destination_address + 32'd4)
        assert(slave_waitrequest === 1'b1)

        master_waitrequest = 1'b0;

        //WRITE to READ
        #10

        assert(master_read === 1'b1)
        assert(master_write === 1'b0)
       //assert(master_writedata === 32'd1)
        //assert(master_address === dut.source_address +32'd8)
        assert(slave_waitrequest === 1'b1)

        master_waitrequest = 1'b1;

        //READ to READ
        #10

        assert(master_read === 1'b1)
        assert(master_write === 1'b0)
       // assert(master_writedata === 32'd1)
        assert(master_address === dut.source_address + 32'd8)
        assert(slave_waitrequest === 1'b1)

        master_waitrequest = 1'b0;

        //READ to WAIT
        #10

        assert(master_read === 1'b0)
        assert(master_write === 1'b0)
        //assert(master_writedata === 32'd1)
        //assert(master_address === 	dut.destination_address)
        assert(slave_waitrequest === 1'b1)

        master_readdatavalid = 1'b1;
        master_readdata = 32'd3;

        master_waitrequest = 1'b1;

        //WAIT to WAIT
        #10

        assert(master_read === 1'b0)
        assert(master_write === 1'b0)
        //assert(master_writedata === 32'd1)
        //assert(master_address === 	dut.destination_address)
        assert(slave_waitrequest === 1'b1)

        master_readdatavalid = 1'b0;

        //WAIT to WRITE
        #10

        assert(master_read === 1'b0)
        assert(master_write === 1'b1)
        assert(master_writedata === 32'd3)
        //assert(master_address === dut.destination_address + 32'd8)
        assert(slave_waitrequest === 1'b1)

        //WRITE to WRITE
        #10

        assert(master_read === 1'b0)
        assert(master_write === 1'b1)
        assert(master_writedata === 32'd3)
        assert(master_address === dut.destination_address + 32'd8)
        assert(slave_waitrequest === 1'b1)

        master_waitrequest = 1'b0;

        //WRITE to IDLE
        #10

	    assert(master_read === 1'b0)
        assert(master_write === 1'b0)
        //assert(master_writedata === 32'd1)
        //assert(master_address === dut.destination_address)
        assert(slave_waitrequest === 1'b0)

        master_waitrequest = 1'b1;
        slave_write = 1'b1;
        slave_address = 4'd0;

        //IDLE to READ
        #10


        assert(master_read === 1'b1)
        assert(master_write === 1'b0)
       // assert(master_writedata === 32'd1)
        //assert(master_address === dut.source_address)
        assert(slave_waitrequest === 1'b1)

        master_waitrequest = 1'b1;

        //READ to READ
        #10

        assert(master_read === 1'b1)
        assert(master_write === 1'b0)
       // assert(master_writedata === 32'd1)
        assert(master_address === dut.source_address)
        assert(slave_waitrequest === 1'b1)

        master_waitrequest = 1'b0;

        //READ to WAIT
        #10

        assert(master_read === 1'b0)
        assert(master_write === 1'b0)
        //assert(master_writedata === 32'd1)
        //assert(master_address === 	dut.destination_address)
        assert(slave_waitrequest === 1'b1)

        master_waitrequest = 1'b1;

        master_readdatavalid = 1'b1;
        master_readdata = 32'd1;

        //WAIT to WAIT
        #10

        assert(master_read === 1'b0)
        assert(master_write === 1'b0)
        //assert(master_writedata === 32'd1)
        //assert(master_address === 	dut.destination_address)
        assert(slave_waitrequest === 1'b1)

        master_readdatavalid = 1'b0;

        //WAIT to WRITE
        #10

        assert(master_read === 1'b0)
        assert(master_write === 1'b1)
        assert(master_writedata === 32'd1)
        //assert(master_address === dut.destination_address)
        assert(slave_waitrequest === 1'b1)


        //WRITE to WRITE
        #10

        assert(master_read === 1'b0)
        assert(master_write === 1'b1)
        assert(master_writedata === 32'd1)
        assert(master_address === dut.destination_address)
        assert(slave_waitrequest === 1'b1)

        master_waitrequest = 1'b0;

        //WRITE to READ
        #10

        assert(master_read === 1'b1)
        assert(master_write === 1'b0)
       // assert(master_writedata === 32'd1)
        //assert(master_address === dut.source_address + 32'd4)
        assert(slave_waitrequest === 1'b1)

        master_waitrequest = 1'b1;

        //READ to READ
        #10

        assert(master_read === 1'b1)
        assert(master_write === 1'b0)
       // assert(master_writedata === 32'd1)
        assert(master_address === dut.source_address + 32'd4)
        assert(slave_waitrequest === 1'b1)

        master_waitrequest = 1'b0;

        //READ to WAIT
        #10

        assert(master_read === 1'b0)
        assert(master_write === 1'b0)
        //assert(master_writedata === 32'd1)
        //assert(master_address === 	dut.destination_address)
        assert(slave_waitrequest === 1'b1)

        master_waitrequest = 1'b1;

        //WAIT to WAIT
        #10

        assert(master_read === 1'b0)
        assert(master_write === 1'b0)
        //assert(master_writedata === 32'd1)
        //assert(master_address === 	dut.destination_address)
        assert(slave_waitrequest === 1'b1)

        
        master_readdatavalid = 1'b1;
        master_readdata = 32'd2;

        //WAIT to WAIT
        #10

        assert(master_read === 1'b0)
        assert(master_write === 1'b0)
        //assert(master_writedata === 32'd1)
        //assert(master_address === 	dut.destination_address)
        assert(slave_waitrequest === 1'b1)

        master_readdatavalid = 1'b0;

        //WAIT to WRITE
        #10

        assert(master_read === 1'b0)
        assert(master_write === 1'b1)
        assert(master_writedata === 32'd2)
       // assert(master_address === dut.destination_address + 32'd4)
        assert(slave_waitrequest === 1'b1)

        //WRITE to WRITE
        #10

        assert(master_read === 1'b0)
        assert(master_write === 1'b1)
        assert(master_writedata === 32'd2)
        assert(master_address === dut.destination_address + 32'd4)
        assert(slave_waitrequest === 1'b1)

        master_waitrequest = 1'b0;

        //WRITE to READ
        #10

        assert(master_read === 1'b1)
        assert(master_write === 1'b0)
       //assert(master_writedata === 32'd1)
        //assert(master_address === dut.source_address +32'd8)
        assert(slave_waitrequest === 1'b1)

        master_waitrequest = 1'b1;

        //READ to READ
        #10

        assert(master_read === 1'b1)
        assert(master_write === 1'b0)
       // assert(master_writedata === 32'd1)
        assert(master_address === dut.source_address + 32'd8)
        assert(slave_waitrequest === 1'b1)

        master_waitrequest = 1'b0;

        //READ to WAIT
        #10

        assert(master_read === 1'b0)
        assert(master_write === 1'b0)
        //assert(master_writedata === 32'd1)
        //assert(master_address === 	dut.destination_address)
        assert(slave_waitrequest === 1'b1)

        master_readdatavalid = 1'b1;
        master_readdata = 32'd3;

        master_waitrequest = 1'b1;

        //WAIT to WAIT
        #10

        assert(master_read === 1'b0)
        assert(master_write === 1'b0)
        //assert(master_writedata === 32'd1)
        //assert(master_address === 	dut.destination_address)
        assert(slave_waitrequest === 1'b1)

        master_readdatavalid = 1'b0;

        //WAIT to WRITE
        #10

        assert(master_read === 1'b0)
        assert(master_write === 1'b1)
        assert(master_writedata === 32'd3)
        //assert(master_address === dut.destination_address + 32'd8)
        assert(slave_waitrequest === 1'b1)

        //WRITE to WRITE
        #10

        assert(master_read === 1'b0)
        assert(master_write === 1'b1)
        assert(master_writedata === 32'd3)
        assert(master_address === dut.destination_address + 32'd8)
        assert(slave_waitrequest === 1'b1)

        master_waitrequest = 1'b0;

        //WRITE to IDLE
        #10

	    assert(master_read === 1'b0)
        assert(master_write === 1'b0)
        //assert(master_writedata === 32'd1)
        //assert(master_address === dut.destination_address)
        assert(slave_waitrequest === 1'b0)

        master_waitrequest = 1'b1;
        slave_write = 1'b0;
        slave_address = 4'd0;

        #500
      
        $stop;
    end
endmodule: tb_rtl_wordcopy
