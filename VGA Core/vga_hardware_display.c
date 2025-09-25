/*
--- File:    vga_convolution.c
--- Module:  vga_convolution
--- Brief:   Host-side program that plots pixels to a VGA Avalon peripheral and renders a 5x5 weighted blur.

--- Description:
---   - Writes packed {Y[6:0], X[7:0], Brightness[7:0]} words to the VGA adapter at base 0x00004000.
---   - Loads sparse pixel coordinates from "pixels.txt" into a 160x120 map (1 byte per pixel).
---   - Applies a 5x5 integer-weighted convolution, normalizes by 100, and streams results row-by-row.

--- Interfaces:
---   vga (MMIO) : 32-bit write-only register at 0x00004000. Write format: {y<<24 | x<<16 | colour}.

--- Author: Joey Negm
*/

// --- VGA base address ---
volatile unsigned *vga = (volatile unsigned *) 0x00004000;

// --- Input pixels ---
unsigned char pixel_list[] = {
#include "pixels.txt"
};
unsigned num_pixels = sizeof(pixel_list)/2;

// --- Function prototype ---
void vga_plot(unsigned x, unsigned y, unsigned colour);

int main()
{

	unsigned int i;
	unsigned int j;
	unsigned int x;
	unsigned int y;
	int         dx;
	int         dy;

    // 5x5 convolution weights
	int weight[5][5] = {
        {1, 2, 4, 2, 1},
        {2, 4, 8, 4, 2},
        {4, 8, 16, 8, 4},
        {2, 4, 8, 4, 2},
        {1, 2, 4, 2, 1}
    };

    // Populate pixel map and row buffer
    unsigned char pixel_map[160][120] = {0};
    unsigned char brightness_row[160];      
    for (i = 0; i < num_pixels; i++) {
        pixel_map[pixel_list[i * 2]][pixel_list[i * 2 + 1]] = 255;
    }

    // --- Convolution + plot, row by row ---
    for (j = 0; j <= 119; j++) { 
        for (i = 0; i <= 159; i++) { 
            unsigned brightness = 0;
            for (dx = -2; dx <= 2; dx++) {
                for (dy = -2; dy <= 2; dy++) {
                    if ((i + dx) >= 0 && (i + dx) <= 159 && (j + dy) >= 0 && (j + dy) <= 119) {
                        brightness += pixel_map[i + dx][j + dy] * weight[dx + 2][dy + 2];
                    }
                }
            }
            // Normalize and store in row buffer
            brightness /= 100;
            brightness_row[i] = brightness;
        }
        // Plot the entire row from the row buffer
        for (i = 0; i <= 159; i++) {
            vga_plot(i, j, brightness_row[i]);
        }
    }

}

// --- Plot a pixel at (x,y) with given colour ---
void vga_plot(unsigned x, unsigned y, unsigned colour){
    unsigned writedata;
    writedata = (y << 24) | (x << 16) | colour;
    *(vga) = writedata;
}
