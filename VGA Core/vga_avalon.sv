/*
--- File:    vga_avalon.sv
--- Module:  vga_avalon
--- Brief:   Simple Avalon-style VGA write interface that plots monochrome pixels via vga_adapter.

--- Description:
---   Accepts writes with packed {y[6:0], x[7:0], brightness[7:0]} and asserts 'plot' when address 0 is written
---   with in-range coordinates. Read path returns zeros.

--- Interfaces:
---   clk, reset_n        : Clock and active-low reset.
---   address, read/write : Simple register interface.
---   readdata/writedata  : 32-bit bus (see packing above).
---   vga_*               : RGB/HS/VS/CLK outputs, 8-bit per color.

--- Author: Joey Negm
*/

module vga_avalon(
    input  logic        clk, 
    input  logic        reset_n,

    // --- Register interface ---
    input  logic [3:0]  address,
    input  logic        read, 
    output logic [31:0] readdata,
    input  logic        write, 
    input  logic [31:0] writedata,

    // --- VGA outputs ---
    output logic [7:0]  vga_red,
    output logic [7:0]  vga_grn, 
    output logic [7:0]  vga_blu,
    output logic        vga_hsync, 
    output logic        vga_vsync, 
    output logic        vga_clk
    );

    // --- Internal Signals ---
    logic [6:0] y_in;
    logic [7:0] x_in;
    logic [7:0] brightness;
    logic       plot;

    logic [9:0] NINE_BIT_VGA_R;
    logic [9:0] NINE_BIT_VGA_G;
    logic [9:0] NINE_BIT_VGA_B;

    logic       VGA_BLANK;
    logic       VGA_SYNC;

    // --- VGA adapter: 10-bit DAC downshift to 8-bit outputs ---
    assign vga_red = NINE_BIT_VGA_R [9:2];
    assign vga_grn = NINE_BIT_VGA_G [9:2];
    assign vga_blu = NINE_BIT_VGA_B [9:2];
    
    assign readdata = 32'd0;

    // --- Unpack inputs ---
    assign y_in = writedata[30:24];
    assign x_in = writedata[23:16];
    assign brightness = writedata[7:0];

    vga_adapter #(.RESOLUTION("160x120"), .MONOCHROME("TRUE"), .BITS_PER_COLOUR_CHANNEL(8)) 
        vga (
            .resetn(reset_n), 
            .clock(clk), 
            .colour(brightness), 
            .x(x_in), 
            .y(y_in), 
            .plot(plot), 
            .VGA_R(NINE_BIT_VGA_R), 
            .VGA_G(NINE_BIT_VGA_G),
            .VGA_B(NINE_BIT_VGA_B), 
            .VGA_HS(vga_hsync), 
            .VGA_VS(vga_vsync), 
            .VGA_BLANK(VGA_BLANK), 
            .VGA_SYNC(VGA_SYNC), 
            .VGA_CLK(vga_clk)
        );

    // --- Plot enable on valid write ---
    always_comb begin
        if ((address === 4'd0) && (x_in <= 8'd159) && (y_in <= 8'd119) && (write === 1'b1))
            plot = 1'b1;
        else
            plot = 1'b0;
    end
endmodule: vga_avalon


