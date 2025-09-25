/*
--- File:    sys_top.sv
--- Module:  sys_top
--- Brief:   Top-level SoC wrapper connecting FPGA I/O (keys, switches, VGA, SDRAM, HEX, LEDs) to dnn_accel_system.

--- Description:
---   Wires board-level signals into the Platform Designer/Qsys system 'dnn_accel_system'.
---   Drives HEX1–HEX5 off, clears LEDR[8:0], and exposes PLL lock on LEDR[9].

--- Interfaces:
---   CLOCK_50        : 50 MHz input clock.
---   KEY[3]          : Async active-low reset into system (KEY[3] = reset_n).
---   SW, LEDR        : Board switches/LEDs (LEDR[9] shows pll_locked).
---   VGA_*           : RGB + HS/VS + pixel clock to display.
---   SDRAM_*         : External SDRAM interface.
---   HEX[0..5]       : Seven-seg displays (only HEX0 is driven by system).

--- Author: Joey Negm
*/

module sys_top(
    input  logic        CLOCK_50,
    input  logic [3:0]  KEY,
    input  logic [9:0]  SW, 

    // --- VGA ---
    output logic [9:0]  LEDR,
    output logic [7:0]  VGA_R, 
    output logic [7:0]  VGA_G, 
    output logic [7:0]  VGA_B,
    output logic        VGA_HS, 
    output logic        VGA_VS, 
    output logic        VGA_CLK,

    // --- SDRAM ---
    output logic        DRAM_CLK, 
    output logic        DRAM_CKE,
    output logic        DRAM_CAS_N, 
    output logic        DRAM_RAS_N, 
    output logic        DRAM_WE_N,
    output logic [12:0] DRAM_ADDR, 
    output logic [1:0]  DRAM_BA, 
    output logic        DRAM_CS_N,
    inout  logic [15:0] DRAM_DQ, 
    output logic        DRAM_UDQM, 
    output logic        DRAM_LDQM,

    // --- Seven-seg displays ---
    output logic [6:0]  HEX0, 
    output logic [6:0]  HEX1, 
    output logic [6:0]  HEX2,
    output logic [6:0]  HEX3, 
    output logic [6:0]  HEX4, 
    output logic [6:0]  HEX5
    );

    //--- Unused outputs ---
    assign HEX1 = 7'b1111111;
    assign HEX2 = 7'b1111111;
    assign HEX3 = 7'b1111111;
    assign HEX4 = 7'b1111111;
    assign HEX5 = 7'b1111111;
    assign LEDR[8:0] = 9'b000000000;

    // --- System integration ---
    dnn_accel_system sys(.clk_clk(CLOCK_50), .reset_reset_n(KEY[3]),
                         .pll_locked_export(LEDR[9]),
                        
                        // --- VGA ---
                         .vga_vga_red(VGA_R),
                         .vga_vga_grn(VGA_G),
                         .vga_vga_blu(VGA_B),
                         .vga_vga_hsync(VGA_HS),
                         .vga_vga_vsync(VGA_VS),
                         .vga_vga_clk(VGA_CLK),

                        // --- SDRAM ---
                         .sdram_clk_clk(DRAM_CLK),
                         .sdram_addr(DRAM_ADDR),
                         .sdram_ba(DRAM_BA),
                         .sdram_cas_n(DRAM_CAS_N),
                         .sdram_cke(DRAM_CKE),
                         .sdram_cs_n(DRAM_CS_N),
                         .sdram_dq(DRAM_DQ),
                         .sdram_dqm({DRAM_UDQM, DRAM_LDQM}),
                         .sdram_ras_n(DRAM_RAS_N),
                         .sdram_we_n(DRAM_WE_N),

                        // --- Seven-seg displays ---
                         .hex_export(HEX0)
    );
endmodule: sys_top

