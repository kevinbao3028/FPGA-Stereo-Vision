module gaussian_blur(
input [7:0] pixel_in,
input clk,
input [12:0] row,
input [12:0] col,
input toggle,
output [7:0] pixel_out
);


wire [17:0] temp_output;

horizontal_conv horiz_conv (.pixel(pixel_in), .clk(clk), .pixel_out_horiz(temp_output));

reg wr_enable = 1'b0;
M10K_BLOCK row1(.address(row), .clock(clk), .data(temp_row1), .wren(wr_enable), .q(row_1));
M10K_BLOCK row2(.address(row), .clock(clk), .data(temp_row2), .wren(wr_enable), .q(row_2));
M10K_BLOCK row3(.address(row), .clock(clk), .data(temp_row3), .wren(wr_enable), .q(row_3));
M10K_BLOCK row4(.address(row), .clock(clk), .data(temp_row4), .wren(wr_enable), .q(row_4));

M10K_BLOCK row5(.address(row), .clock(clk), .data(temp_row5), .wren(wr_enable), .q(row_5));
M10K_BLOCK row6(.address(row), .clock(clk), .data(temp_row6), .wren(wr_enable), .q(row_6));
M10K_BLOCK row7(.address(row), .clock(clk), .data(temp_row7), .wren(wr_enable), .q(row_7));
M10K_BLOCK row8(.address(row), .clock(clk), .data(temp_row8), .wren(wr_enable), .q(row_8));
M10K_BLOCK row9(.address(row), .clock(clk), .data(temp_row9), .wren(wr_enable), .q(row_9));
M10K_BLOCK row10(.address(row), .clock(clk), .data(temp_row10), .wren(wr_enable), .q(row_10));


reg [17:0] temp_row1 = 0;
reg [17:0] temp_row2 = 0;
reg [17:0] temp_row3 = 0;
reg [17:0] temp_row4 = 0;

reg [17:0] temp_row5 = 0;
reg [17:0] temp_row6 = 0;
reg [17:0] temp_row7 = 0;
reg [17:0] temp_row8 = 0;
reg [17:0] temp_row9 = 0;
reg [17:0] temp_row10 = 0;


wire [17:0] row_1;
wire [17:0] row_2;
wire [17:0] row_3;
wire [17:0] row_4;

wire [17:0] row_5;
wire [17:0] row_6;
wire [17:0] row_7;
wire [17:0] row_8;
wire [17:0] row_9;
wire [17:0] row_10;

reg [21:0] temp_pixel = 0;

reg [7:0] pixel_output = 8'b0;
assign pixel_out[7:0] = pixel_output;

always @ (*)
begin
	//5x5 gaussian blur
	if(toggle == 1'b0)
	begin
		pixel_output[7:0] = temp_pixel[15:8];
	end
	
	//11x11 gaussian blur
	else
	begin
		pixel_output[7:0] = temp_pixel[21:14];
	end
end

reg state = 1'b0;
localparam s0 = 1'b0; // perform convolution
localparam s1 = 1'b1; // save to M10k block


always @ (posedge clk)
begin
	case (state)
	s0:
	begin
		//5x5 filter
		if(toggle == 1'b0)
		begin
			//perform convolution
			wr_enable <= 1'b0;
			temp_pixel <= (row_1 * 1) + (row_2 * 4) + (row_3 * 6) + (row_4 * 4) + (temp_output * 1);
			state <= s1;
		end
		//11x11 filter
		else
		begin
			wr_enable <= 1'b0;
			
			temp_pixel <= 
			(row_1 * 1) + 
			(row_2 * 10) + 
			(row_3 * 45) + 
			(row_4 * 120) + 
			(row_5 * 210) + 
			(row_6 * 252) + 
			(row_7 * 210) + 
			(row_8 * 120) + 
			(row_9 * 45) + 
			(row_10 * 10) + 
			(temp_output * 1);
			
			state <= s1;
		end
	end
	s1:
	begin
		//5x5 filter
		if(toggle == 1'b0)
		begin
			wr_enable <= 1'b1;
			temp_row1 <= row_2;
			temp_row2 <= row_3;
			temp_row3 <= row_4;
			temp_row4 <= temp_output;
			state <= s0;
		end
		
		//11x11 filter
		else
		begin
			wr_enable <= 1'b1;
			temp_row1 <= row_2;
			temp_row2 <= row_3;
			temp_row3 <= row_4;
			temp_row4 <= row_5;
			temp_row5 <= row_6;
			temp_row6 <= row_7;
			temp_row7 <= row_8;
			temp_row8 <= row_9;
			temp_row9 <= row_10;
			temp_row10 <= temp_output;
			state <= s0;
		end
	end
	endcase
end

endmodule