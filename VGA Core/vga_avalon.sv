module vga_avalon(input logic clk, input logic reset_n,
                  input logic [3:0] address,
                  input logic read, output logic [31:0] readdata,
                  input logic write, input logic [31:0] writedata,
                  output logic [7:0] vga_red, output logic [7:0] vga_grn, output logic [7:0] vga_blu,
                  output logic vga_hsync, output logic vga_vsync, output logic vga_clk);
    
    /*

        Ports:

        Input Ports:

        input logic resetn
        input logic clock
        input logic [7:0] colour
        input logic [7:0] x
        input logic [6:0] y
        input logic plot


        Output Ports:

        output logic [9:0] VGA_R
        output logic [9:0] VGA_G
        output logic [9:0] VGA_B
        output logic VGA_HS
        output logic VGA_VS
        output logic VGA_BLANK
        output logic VGA_SYNC
        output logic VGA_CLK

        */
    
    // your Avalon slave implementation goes here

    logic [6:0] y_in;
    logic [7:0] x_in;
    logic [7:0] brightness;
    logic plot;
    logic [9:0] NINE_BIT_VGA_R;
    logic [9:0] NINE_BIT_VGA_G;
    logic [9:0] NINE_BIT_VGA_B;

    logic VGA_BLANK;
    logic VGA_SYNC;

    assign vga_red = NINE_BIT_VGA_R [9:2];
    assign vga_grn = NINE_BIT_VGA_G [9:2];
    assign vga_blu = NINE_BIT_VGA_B [9:2];
    
    assign readdata = 32'd0;

    assign y_in = writedata[30:24];
    assign x_in = writedata[23:16];
    assign brightness = writedata[7:0];

    vga_adapter #( .RESOLUTION("160x120"), .MONOCHROME("TRUE"), .BITS_PER_COLOUR_CHANNEL(8) )
	vga(.resetn(reset_n), .clock(clk), .colour(brightness), .x(x_in), .y(y_in), .plot(plot), .VGA_R(NINE_BIT_VGA_R), .VGA_G(NINE_BIT_VGA_G),
        .VGA_B(NINE_BIT_VGA_B), .VGA_HS(vga_hsync), .VGA_VS(vga_vsync), .VGA_BLANK(VGA_BLANK), .VGA_SYNC(VGA_SYNC), .VGA_CLK(vga_clk));

    // NOTE: We will ignore the VGA_SYNC and VGA_BLANK signals.
    //       Either don't connect them or connect them to dangling wires.
    //       In addition, the VGA_{R,G,B} should be the upper 8 bits of the VGA module outputs.

    /*
    enum {IDLE, DRAW, ERROR} state;

    always_ff @(posedge clk) begin

        if (!reset_n) begin

            state <= IDLE;
        end 
        
        else begin

            case (state)

                IDLE: begin

                    if ((address === 4'd0) && (x_in <= 8'd159) && (y_in <= 8'd119) && (write === 1'b1)) begin

                        state <= DRAW;
                    end

                    else begin

                        state <= IDLE;
                    end
                end

                DRAW: begin
                    if ((address === 4'd0) && (x_in <= 8'd159) && (y_in <= 8'd119)) begin

                        state <= DRAW;
                    end

                    else begin

                        state <= IDLE;
                    end
                end

                default: begin

                    state <= ERROR;
                end
            endcase
        end
    end

    always_comb begin

        case(state)

            IDLE: begin
                
                if ((address === 4'd0) && (x_in <= 8'd159) && (y_in <= 8'd119) && (write === 1'b1))
                    plot = 1'b1;

                else
                    plot = 1'b0;
            end

            DRAW: begin

                plot = 1'b1;
            end

            default: begin

                plot = 1'bx;
            end
        endcase
    end
    */

    always_comb begin

        if ((address === 4'd0) && (x_in <= 8'd159) && (y_in <= 8'd119) && (write === 1'b1))
            plot = 1'b1;

        else
            plot = 1'b0;
    end

endmodule: vga_avalon


