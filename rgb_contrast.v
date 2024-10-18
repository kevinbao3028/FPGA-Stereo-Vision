module rgb_contrast(
    input  [7:0] raw_VGA_R,
    input  [7:0] raw_VGA_G,
    input  [7:0] raw_VGA_B,
    input  [3:0] contrast_level,  // 4-bit contrast level input
    output [7:0] contrast_VGA_R,
    output [7:0] contrast_VGA_G,
    output [7:0] contrast_VGA_B
);

    // Contrast adjustment
    wire [7:0] mid_value = 128;  // Midpoint value for 8-bit colors
    wire [8:0] contrast_scale = 256 + ((contrast_level - 8) << 5);  // Contrast scaling factor

    // Function to adjust contrast based on the contrast level
    function [7:0] adjust_contrast(input [7:0] color, input [8:0] scale);
        integer temp;
        begin
            temp = (color - mid_value) * scale;
            temp = temp >>> 8;  // Divide by 256 (arithmetic right shift)
            temp = temp + mid_value;
            adjust_contrast = (temp < 0) ? 0 : (temp > 255 ? 255 : temp);
        end
    endfunction

    // Apply contrast adjustment to each channel
    assign contrast_VGA_R = adjust_contrast(raw_VGA_R, contrast_scale);
    assign contrast_VGA_G = adjust_contrast(raw_VGA_G, contrast_scale);
    assign contrast_VGA_B = adjust_contrast(raw_VGA_B, contrast_scale);

endmodule
