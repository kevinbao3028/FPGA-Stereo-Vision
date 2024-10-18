module grayscale(
    input  [7:0] raw_VGA_R,
    input  [7:0] raw_VGA_G,
    input  [7:0] raw_VGA_B,
    output [7:0] grayscale_VGA_R,
    output [7:0] grayscale_VGA_G,
    output [7:0] grayscale_VGA_B
);

    // Luminance =  0.2126 red + 0.7152 green + 0.0722 blue

    wire [15:0] luminance;
	 
    // Since decimal value, multiplied the number by 256 then divided the whole thing by 256 (shifting by 8 bits)
    assign luminance = (raw_VGA_R * 55) + (raw_VGA_G * 182) + (raw_VGA_B * 18) >> 8;

    // Assign new Grayscale_RGB value
    assign grayscale_VGA_R = luminance[7:0];
    assign grayscale_VGA_G = luminance[7:0];
    assign grayscale_VGA_B = luminance[7:0];

endmodule
