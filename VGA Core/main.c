volatile unsigned *vga = (volatile unsigned *) 0x00004000; /* VGA adapter base address */

unsigned char pixel_list[] = {
#include "pixels.txt"
};

unsigned num_pixels = sizeof(pixel_list)/2;
void vga_plot(unsigned x, unsigned y, unsigned colour);

int main()
{

	unsigned int i;
	unsigned int j;
	unsigned int x;
	unsigned int y;
	int dx;
	int dy;

	//unsigned char pixel_map[160][120] = {0};
	//unsigned char brightness_map[160][120] = {0};

	int weight[5][5] = {
        {1, 2, 4, 2, 1},
        {2, 4, 8, 4, 2},
        {4, 8, 16, 8, 4},
        {2, 4, 8, 4, 2},
        {1, 2, 4, 2, 1}
    };

unsigned char pixel_map[160][120] = {0}; // Original pixel data
unsigned char brightness_row[160];      // Stores one row of brightness

// Populate pixel_map with input data
for (i = 0; i < num_pixels; i++) {
    pixel_map[pixel_list[i * 2]][pixel_list[i * 2 + 1]] = 255; // Set pixel brightness to white
}

// Perform convolution and plot brightness row by row
for (j = 0; j <= 119; j++) { // For each row in the output
    for (i = 0; i <= 159; i++) { // For each pixel in the row
        unsigned brightness = 0;

        // Convolve over the 5x5 neighborhood
        for (dx = -2; dx <= 2; dx++) {
            for (dy = -2; dy <= 2; dy++) {
                if ((i + dx) >= 0 && (i + dx) <= 159 && (j + dy) >= 0 && (j + dy) <= 119) {
                    brightness += pixel_map[i + dx][j + dy] * weight[dx + 2][dy + 2];
                }
            }
        }

        brightness /= 100; // Normalize brightness
        brightness_row[i] = brightness; // Store in the current row buffer
    }

    // Plot the current row
    for (i = 0; i <= 159; i++) {
        vga_plot(i, j, brightness_row[i]);
    }
}

}

void vga_plot(unsigned x, unsigned y, unsigned colour){

    unsigned writedata;

    writedata = (y << 24) | (x << 16) | colour;

    *(vga) = writedata;
}