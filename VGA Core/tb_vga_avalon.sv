module tb_vga_avalon();

    logic clk;
    logic reset_n;
    logic [3:0] address;
    logic read;
    logic [31:0] readdata;
    logic write;
    logic [31:0] writedata;
    logic [7:0] vga_red;
    logic [7:0] vga_grn;
    logic [7:0] vga_blu;
    logic vga_hsync;
    logic vga_vsync;
    logic vga_clk;
    
    logic [6:0] y_in;
    logic [7:0] x_in;
    logic [7:0] brightness;

    vga_avalon dut(.*);

    always #1 clk = ~clk;

    assign writedata[30:24] = y_in;
    assign writedata[23:16] = x_in;
    assign writedata[7:0] = brightness;

    initial begin
        
        clk = 1'b0;
        reset_n = 1'b0;
        
        #2 
        
        reset_n = 1'b1;
        address = 4'b0000;
        brightness = 8'd200;
        write = 1'b1;
        y_in = 0;
        x_in = 0;

        #2

        y_in = 2;
        x_in = 2;

        #2

        address = 4'b0001;
        y_in = 4;
        x_in = 4;

        #2

        address = 4'b0000;
        y_in = 6;
        x_in = 6;

        #2

        y_in = 122;
        x_in = 120;

        #2

        address = 4'b0000;
        y_in = 8;
        x_in = 8;

        #2

        y_in = 100;
        x_in = 200;

        #2

        address = 4'b0000;
        y_in = 10;
        x_in = 10;

        #4

        $stop;
    end
endmodule: tb_vga_avalon
