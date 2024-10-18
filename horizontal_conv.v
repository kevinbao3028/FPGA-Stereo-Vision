module horizontal_conv(
input [7:0] pixel,
input clk,
input toggle,
output [17:0] pixel_out_horiz
);

reg [7:0] prev_pixel1 = 0;
reg [7:0] prev_pixel2 = 0;
reg [7:0] prev_pixel3 = 0;
reg [7:0] prev_pixel4 = 0;

reg [7:0] prev_pixel5 = 0;
reg [7:0] prev_pixel6 = 0;
reg [7:0] prev_pixel7 = 0;
reg [7:0] prev_pixel8 = 0;
reg [7:0] prev_pixel9 = 0;
reg [7:0] prev_pixel10 = 0;

reg [17:0] temp_pixel;

assign pixel_out_horiz[17:0] = temp_pixel[17:0];

//perform the blur and pipeline pixels
// Correcting the pixel shift operation
always @(posedge clk) 
begin
	//5x5 gaussian blur
	if(toggle == 1'b0)
	begin
		prev_pixel1 <= prev_pixel2;
		prev_pixel2 <= prev_pixel3;
		prev_pixel3 <= prev_pixel4;
		prev_pixel4 <= pixel;
		
		temp_pixel <= (prev_pixel1 * 1) + (prev_pixel2 * 4) + (prev_pixel3 * 6) + (prev_pixel4 * 4) + (pixel * 1);
	end
	
	//11x11 gaussian blur
	else
	begin
		prev_pixel1 <= prev_pixel2;
		prev_pixel2 <= prev_pixel3;
		prev_pixel3 <= prev_pixel4;
		prev_pixel4 <= prev_pixel5;
		prev_pixel5 <= prev_pixel6;
		prev_pixel6 <= prev_pixel7;
		prev_pixel7 <= prev_pixel8;
		prev_pixel8 <= prev_pixel9;
		prev_pixel9 <= prev_pixel10;
		prev_pixel10 <= pixel;

		temp_pixel <= 
		(prev_pixel1 * 1) + 
		(prev_pixel2 * 10) + 
		(prev_pixel3 * 45) + 
		(prev_pixel4 * 120) + 
		(prev_pixel5 * 210) + 
		(prev_pixel6 * 252) + 
		(prev_pixel7 * 210) + 
		(prev_pixel8 * 120) + 
		(prev_pixel9 * 45) + 
		(prev_pixel10 * 10) + 
		(pixel * 1);
	end
end


endmodule