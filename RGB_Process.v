module RGB_Process(
   input [7:0]	a_R,
   input [7:0] a_G,
   input [7:0] a_B,
	input [7:0] b_R,
   input [7:0] b_G,
   input [7:0] b_B,
	input [7:0] a_Gray,
	input [7:0] b_Gray,
	input [23:0] a_csct,
	input [23:0] b_csct,
	input [7:0] disp,
	input [7:0] min,
//	input  [7:0] raw_VGA_R,
//	input  [7:0] raw_VGA_G,
//	input  [7:0] raw_VGA_B,
	input	 [12:0] y,
	input  [12:0] x,

	output reg [7:0] o_VGA_R,
	output reg [7:0] o_VGA_G,
	output reg [7:0] o_VGA_B,
	output [9:0] LEDR,
	output [7:0] HEX0,
	output [7:0] HEX1,
	output [7:0] HEX2,
	output [7:0] HEX3,
	output [7:0] HEX4,
	output [7:0] HEX5,
	
	inout			ps_clk,
	inout			ps_data,
	
	input [8:0] switch,
	input [3:0] KEY,
	input CLOCK_50,
	input CLOCK_25
);
wire [12:0] row;
wire [12:0] col;
assign row = 13'd0+y-13'd45;
assign col = 13'd0+x;
reg [31:0] clk = 0;
//clock divider
always @ (posedge CLOCK_25)
begin
	clk <= clk + 1;
end

reg [12:0] cursor_row = 13'd240;
reg [12:0] cursor_col = 13'd240;

//define the mouse state to not be moving in the beginning
reg [1:0] mouse_state_left_right = 2'b01; 
reg [1:0] mouse_state_up_down = 2'b01;

//state machine for mouse ui
reg [1:0] ui_state_machine = 2'b00;
reg latch = 1'b0;

reg [9:0] ledr_out;
//assign LEDR = ledr_out;

assign LEDR = {ui_1_latch,ui_2_latch,ui_3_latch,ui_4_latch,ui_5_latch,ui_6_latch,ui_7_latch,ui_8_latch,ui_9_latch,ui_10_latch};


always @ (*)
begin
	case({hex3[6:0], hex2[6:0]})
		//left
		14'b1000111_0001110:
		begin
			ledr_out[2] = 1'b1;
			ledr_out[1] = 1'b0;
			ledr_out[0] = 1'b0;
			mouse_state_left_right = 2'b00;
		end
		//center
		14'b0101011_0100111:
		begin
			ledr_out[2] = 1'b0;
			ledr_out[1] = 1'b1;
			ledr_out[0] = 1'b0;
			mouse_state_left_right = 2'b01;
		end
		//right
		14'b0101111_1111000:
		begin
			ledr_out[2] = 1'b0;
			ledr_out[1] = 1'b0;
			ledr_out[0] = 1'b1;
			mouse_state_left_right = 2'b10;
		end
	endcase

	case({hex1[6:0], hex0[6:0]})
		//up
		14'b1000001_0001100:
		begin
			ledr_out[9] = 1'b1;
			ledr_out[8] = 1'b0;
			ledr_out[7] = 1'b0;
			mouse_state_up_down = 2'b00;
		end
		//center
		14'b0101011_0100111:
		begin
			ledr_out[9] = 1'b0;
			ledr_out[8] = 1'b1;
			ledr_out[7] = 1'b0;
			mouse_state_up_down = 2'b01;
		end
		//down
		14'b0100001_0101011:
		begin
			ledr_out[9] = 1'b0;
			ledr_out[8] = 1'b0;
			ledr_out[7] = 1'b1;
			mouse_state_up_down = 2'b10;
		end
	endcase
end



//define mouse movement
always @ (posedge clk[18])
begin
	case(mouse_state_left_right)
		2'b00:
		begin
			if(hex4[6:0] == 7'b0101011)
			begin
				if(cursor_col <= 13'd1)
				begin
					cursor_col <= cursor_col;
				end
				else
				begin
					cursor_col <= cursor_col - 1;
				end
			end
		end
		2'b01:
		begin
			if(hex4[6:0] == 7'b0101011)
			begin
				cursor_col <= cursor_col;
			end
		end
		2'b10:
		begin
			if(hex4[6:0] == 7'b0101011)
			begin
				if(cursor_col >= 13'd639)
				begin
					cursor_col <= cursor_col;
				end
				else
				begin
					cursor_col <= cursor_col + 1;
				end
			end
		end
	endcase

	case(mouse_state_up_down)
		2'b00:
		begin
			if(hex4[6:0] == 7'b0101011)
			begin
				if(cursor_row <= 13'd1)
				begin
					cursor_row <= cursor_row;
				end
				else
				begin
					cursor_row <= cursor_row - 1;
				end
			end
		end
		2'b01:
		begin
			if(hex4[6:0] == 7'b0101011)
			begin
				cursor_row <= cursor_row;
			end
		end
		2'b10:
		begin
			if(hex4[6:0] == 7'b0101011)
			begin
				if(cursor_row >= 13'd479)
				begin
					cursor_row <= cursor_row;
				end
				else
				begin
					cursor_row <= cursor_row + 1;
				end
			end
		end
	endcase
	
	//mouse ui state machine
	if(KEY[3] == 1'b0 && latch == 1'b0)
	begin
		ui_state_machine <= ui_state_machine + 2'b01;
		latch <= 1'b1;
	end
	else if(KEY[3] == 1'b1)
	begin
		latch <= 1'b0;
	end
	
	//rmb toggle latch
	if(hex4[6:0] == 7'b0101111 && rmb_toggle_latch == 1'b0)
	begin
		rmb_latch <= rmb_latch + 1'b1;
		rmb_toggle_latch <= 1'b1;
	end
	else if(hex4[6:0] != 7'b0101111)
	begin
		rmb_toggle_latch <= 1'b0;
	end
	
	//transparent rectangle
	if(KEY[1] == 1'b0)
	begin
		KEY1_row <= cursor_row;
		KEY1_col <= cursor_col;
	end
	else if(KEY[0] == 1'b0)
	begin
		KEY0_row <= cursor_row;
		KEY0_col <= cursor_col;
	end
	
	//clickbox ui
	if(cursor_row >= ui_1_up && cursor_row <= ui_1_down && cursor_col >= ui_1_left && cursor_col <= ui_1_right)
	begin
		 if(hex4[6:0] == 7'b1000111 && ui_1_toggle_latch == 1'b0)
		 begin
			  ui_1_latch <= ui_1_latch + 1'b1;
			  ui_1_toggle_latch <= 1'b1;
		 end
		 else if (hex4[6:0] != 7'b1000111)
		 begin
			  ui_1_toggle_latch <= 1'b0;
		 end
	end

	if(cursor_row >= ui_2_up && cursor_row <= ui_2_down && cursor_col >= ui_2_left && cursor_col <= ui_2_right)
	begin
		 if(hex4[6:0] == 7'b1000111 && ui_2_toggle_latch == 1'b0)
		 begin
			  ui_2_latch <= ui_2_latch + 1'b1;
			  ui_2_toggle_latch <= 1'b1;
		 end
		 else if (hex4[6:0] != 7'b1000111)
		 begin
			  ui_2_toggle_latch <= 1'b0;
		 end
	end

	if(cursor_row >= ui_3_up && cursor_row <= ui_3_down && cursor_col >= ui_3_left && cursor_col <= ui_3_right)
	begin
		 if(hex4[6:0] == 7'b1000111 && ui_3_toggle_latch == 1'b0)
		 begin
			  ui_3_latch <= ui_3_latch + 1'b1;
			  ui_3_toggle_latch <= 1'b1;
		 end
		 else if (hex4[6:0] != 7'b1000111)
		 begin
			  ui_3_toggle_latch <= 1'b0;
		 end
	end

	if(cursor_row >= ui_4_up && cursor_row <= ui_4_down && cursor_col >= ui_4_left && cursor_col <= ui_4_right)
	begin
		 if(hex4[6:0] == 7'b1000111 && ui_4_toggle_latch == 1'b0)
		 begin
			  ui_4_latch <= ui_4_latch + 1'b1;
			  ui_4_toggle_latch <= 1'b1;
		 end
		 else if (hex4[6:0] != 7'b1000111)
		 begin
			  ui_4_toggle_latch <= 1'b0;
		 end
	end

	if(cursor_row >= ui_5_up && cursor_row <= ui_5_down && cursor_col >= ui_5_left && cursor_col <= ui_5_right)
	begin
		 if(hex4[6:0] == 7'b1000111 && ui_5_toggle_latch == 1'b0)
		 begin
			  ui_5_latch <= ui_5_latch + 1'b1;
			  ui_5_toggle_latch <= 1'b1;
		 end
		 else if (hex4[6:0] != 7'b1000111)
		 begin
			  ui_5_toggle_latch <= 1'b0;
		 end
	end

	if(cursor_row >= ui_6_up && cursor_row <= ui_6_down && cursor_col >= ui_6_left && cursor_col <= ui_6_right)
	begin
		 if(hex4[6:0] == 7'b1000111 && ui_6_toggle_latch == 1'b0)
		 begin
			  ui_6_latch <= ui_6_latch + 1'b1;
			  ui_6_toggle_latch <= 1'b1;
		 end
		 else if (hex4[6:0] != 7'b1000111)
		 begin
			  ui_6_toggle_latch <= 1'b0;
		 end
	end

	if(cursor_row >= ui_7_up && cursor_row <= ui_7_down && cursor_col >= ui_7_left && cursor_col <= ui_7_right)
	begin
		 if(hex4[6:0] == 7'b1000111 && ui_7_toggle_latch == 1'b0)
		 begin
			  ui_7_latch <= ui_7_latch + 1'b1;
			  ui_7_toggle_latch <= 1'b1;
		 end
		 else if (hex4[6:0] != 7'b1000111)
		 begin
			  ui_7_toggle_latch <= 1'b0;
		 end
	end

	if(cursor_row >= ui_8_up && cursor_row <= ui_8_down && cursor_col >= ui_8_left && cursor_col <= ui_8_right)
	begin
		 if(hex4[6:0] == 7'b1000111 && ui_8_toggle_latch == 1'b0)
		 begin
			  ui_8_latch <= ui_8_latch + 1'b1;
			  ui_8_toggle_latch <= 1'b1;
		 end
		 else if (hex4[6:0] != 7'b1000111)
		 begin
			  ui_8_toggle_latch <= 1'b0;
		 end
	end

	if(cursor_row >= ui_9_up && cursor_row <= ui_9_down && cursor_col >= ui_9_left && cursor_col <= ui_9_right)
	begin
		 if(hex4[6:0] == 7'b1000111 && ui_9_toggle_latch == 1'b0)
		 begin
			  ui_9_latch <= ui_9_latch + 1'b1;
			  ui_9_toggle_latch <= 1'b1;
		 end
		 else if (hex4[6:0] != 7'b1000111)
		 begin
			  ui_9_toggle_latch <= 1'b0;
		 end
	end

	if(cursor_row >= ui_10_up && cursor_row <= ui_10_down && cursor_col >= ui_10_left && cursor_col <= ui_10_right)
	begin
		 if(hex4[6:0] == 7'b1000111 && ui_10_toggle_latch == 1'b0)
		 begin
			  ui_10_latch <= ui_10_latch + 1'b1;
			  ui_10_toggle_latch <= 1'b1;
		 end
		 else if (hex4[6:0] != 7'b1000111)
		 begin
			  ui_10_toggle_latch <= 1'b0;
		 end
	end

	if(cursor_row >= ui_11_up && cursor_row <= ui_11_down && cursor_col >= ui_11_left && cursor_col <= ui_11_right)
	begin
		 if(hex4[6:0] == 7'b1000111 && ui_11_toggle_latch == 1'b0)
		 begin
			  ui_11_latch <= ui_11_latch + 1'b1;
			  ui_11_toggle_latch <= 1'b1;
		 end
		 else if (hex4[6:0] != 7'b1000111)
		 begin
			  ui_11_toggle_latch <= 1'b0;
		 end
	end

	if(cursor_row >= ui_12_up && cursor_row <= ui_12_down && cursor_col >= ui_12_left && cursor_col <= ui_12_right)
	begin
		 if(hex4[6:0] == 7'b1000111 && ui_12_toggle_latch == 1'b0)
		 begin
			  ui_12_latch <= ui_12_latch + 1'b1;
			  ui_12_toggle_latch <= 1'b1;
		 end
		 else if (hex4[6:0] != 7'b1000111)
		 begin
			  ui_12_toggle_latch <= 1'b0;
		 end
	end

end

wire [7:0] vga_out_aR,	vga_out_bR;
wire [7:0] vga_out_aG,	vga_out_bG;
wire [7:0] vga_out_aB,	vga_out_bB;

wire [7:0] contrast_aR,	contrast_bR;
wire [7:0] contrast_aG,	contrast_bG;
wire [7:0] contrast_aB, contrast_bB;

wire [7:0] grayscale_aR, grayscale_bR;
wire [7:0] grayscale_aG, grayscale_bG;
wire [7:0] grayscale_aB, grayscale_bB;

//ps2 mouse button user interface
localparam lmb_up 		= 13'd0004;
localparam lmb_down 		= 13'd0012;
localparam lmb_left 		= 13'd0004;
localparam lmb_right 	= 13'd0012;

localparam mmb_up 		= 13'd0004;
localparam mmb_down 		= 13'd0012;
localparam mmb_left 		= 13'd0016;
localparam mmb_right 	= 13'd0024;

localparam rmb_up 		= 13'd0004;
localparam rmb_down 		= 13'd0012;
localparam rmb_left 		= 13'd0028;
localparam rmb_right 	= 13'd0036;

//ps2 mouse movement user interface
localparam top_left_up			= 13'd16;
localparam top_left_down		= 13'd24;
localparam top_left_left		= 13'd4;
localparam top_left_right		= 13'd12;

localparam top_middle_up		= 13'd16;
localparam top_middle_down		= 13'd24;
localparam top_middle_left		= 13'd16;
localparam top_middle_right	= 13'd24;

localparam top_right_up			= 13'd16;
localparam top_right_down		= 13'd24;
localparam top_right_left		= 13'd28;
localparam top_right_right		= 13'd36;



localparam middle_left_up		= 13'd28;
localparam middle_left_down	= 13'd36;
localparam middle_left_left	= 13'd4;
localparam middle_left_right	= 13'd12;

localparam middle_middle_up	= 13'd28;
localparam middle_middle_down	= 13'd36;
localparam middle_middle_left	= 13'd16;
localparam middle_middle_right= 13'd24;

localparam middle_right_up		= 13'd28;
localparam middle_right_down	= 13'd36;
localparam middle_right_left	= 13'd28;
localparam middle_right_right	= 13'd36;



localparam bottom_left_up		= 13'd40;
localparam bottom_left_down	= 13'd48;
localparam bottom_left_left	= 13'd4;
localparam bottom_left_right	= 13'd12;

localparam bottom_middle_up	= 13'd40;
localparam bottom_middle_down	= 13'd48;
localparam bottom_middle_left	= 13'd16;
localparam bottom_middle_right= 13'd24;

localparam bottom_right_up		= 13'd40;
localparam bottom_right_down	= 13'd48;
localparam bottom_right_left	= 13'd28;
localparam bottom_right_right	= 13'd36;

//click button UI
localparam ui_1_up 		= 13'd00468;
localparam ui_1_down 	= 13'd00476;
localparam ui_1_left 	= 13'd0004;
localparam ui_1_right 	= 13'd0012;

localparam ui_2_up 		= 13'd00468;
localparam ui_2_down 	= 13'd00476;
localparam ui_2_left 	= 13'd0016;
localparam ui_2_right 	= 13'd0024;

localparam ui_3_up 		= 13'd00468;
localparam ui_3_down 	= 13'd00476;
localparam ui_3_left 	= 13'd0028;
localparam ui_3_right 	= 13'd0036;

localparam ui_4_up 		= 13'd00468;
localparam ui_4_down 	= 13'd00476;
localparam ui_4_left 	= 13'd0040;
localparam ui_4_right 	= 13'd0048;

localparam ui_5_up 		= 13'd00468;
localparam ui_5_down 	= 13'd00476;
localparam ui_5_left 	= 13'd0052;
localparam ui_5_right 	= 13'd0060;

localparam ui_6_up 		= 13'd00468;
localparam ui_6_down 	= 13'd00476;
localparam ui_6_left 	= 13'd0064;
localparam ui_6_right 	= 13'd0072;

localparam ui_7_up 		= 13'd00468;
localparam ui_7_down 	= 13'd00476;
localparam ui_7_left 	= 13'd0076;
localparam ui_7_right 	= 13'd0084;

localparam ui_8_up 		= 13'd00468;
localparam ui_8_down 	= 13'd00476;
localparam ui_8_left 	= 13'd0088;
localparam ui_8_right 	= 13'd0096;

localparam ui_9_up 		= 13'd00468;
localparam ui_9_down 	= 13'd00476;
localparam ui_9_left 	= 13'd00100;
localparam ui_9_right 	= 13'd00108;

localparam ui_10_up 		= 13'd00468;
localparam ui_10_down 	= 13'd00476;
localparam ui_10_left 	= 13'd00112;
localparam ui_10_right 	= 13'd00120;

localparam ui_11_up 		= 13'd00468;
localparam ui_11_down 	= 13'd00476;
localparam ui_11_left 	= 13'd00124;
localparam ui_11_right 	= 13'd00132;

localparam ui_12_up 		= 13'd00468;
localparam ui_12_down 	= 13'd00476;
localparam ui_12_left 	= 13'd00136;
localparam ui_12_right 	= 13'd00144;


//define default position for + cursor
reg signed	[12:0] center_row = 13'd240;
reg signed	[12:0] center_col = 13'd240;

//ui latches
reg ui_1_latch = 1'b0;
reg ui_2_latch = 1'b0;
reg ui_3_latch = 1'b0;
reg ui_4_latch = 1'b0;
reg ui_5_latch = 1'b0;
reg ui_6_latch = 1'b0;
reg ui_7_latch = 1'b0;
reg ui_8_latch = 1'b0;
reg ui_9_latch = 1'b0;
reg ui_10_latch = 1'b0;
reg ui_11_latch = 1'b0;
reg ui_12_latch = 1'b0;

reg ui_1_toggle_latch = 1'b0;
reg ui_2_toggle_latch = 1'b0;
reg ui_3_toggle_latch = 1'b0;
reg ui_4_toggle_latch = 1'b0;
reg ui_5_toggle_latch = 1'b0;
reg ui_6_toggle_latch = 1'b0;
reg ui_7_toggle_latch = 1'b0;
reg ui_8_toggle_latch = 1'b0;
reg ui_9_toggle_latch = 1'b0;
reg ui_10_toggle_latch = 1'b0;
reg ui_11_toggle_latch = 1'b0;
reg ui_12_toggle_latch = 1'b0;

//rmb latch
reg [3:0] rmb_latch = 4'b0;
reg rmb_toggle_latch = 1'b0;

//define default position for transparent rectangle
reg [12:0] KEY1_row = 13'd0;
reg [12:0] KEY1_col = 13'd0;
reg [12:0] KEY0_row = 13'd479;
reg [12:0] KEY0_col = 13'd639;

gaussian_blur gaussian_blur_aR (.pixel_in(a_R), .clk(CLOCK_25), .row(row), .col(col), .pixel_out(vga_out_aR), .toggle(rmb_latch[0]));
gaussian_blur gaussian_blur_aG (.pixel_in(a_G), .clk(CLOCK_25), .row(row), .col(col), .pixel_out(vga_out_aG), .toggle(rmb_latch[0]));
gaussian_blur gaussian_blur_aB (.pixel_in(a_B), .clk(CLOCK_25), .row(row), .col(col), .pixel_out(vga_out_aB), .toggle(rmb_latch[0]));

gaussian_blur gaussian_blur_bR (.pixel_in(b_R), .clk(CLOCK_25), .row(row), .col(col), .pixel_out(vga_out_bR), .toggle(rmb_latch[0]));
gaussian_blur gaussian_blur_bG (.pixel_in(b_G), .clk(CLOCK_25), .row(row), .col(col), .pixel_out(vga_out_bG), .toggle(rmb_latch[0]));
gaussian_blur gaussian_blur_bB (.pixel_in(b_B), .clk(CLOCK_25), .row(row), .col(col), .pixel_out(vga_out_bB), .toggle(rmb_latch[0]));


rgb_contrast contrasta(.raw_VGA_R(a_R), .raw_VGA_G(a_G), .raw_VGA_B(a_B), .contrast_level(rmb_latch[3:0]), .contrast_VGA_R(contrast_aR), .contrast_VGA_G(contrast_aG), .contrast_VGA_B(contrast_aB));
rgb_contrast contrastb(.raw_VGA_R(b_R), .raw_VGA_G(b_G), .raw_VGA_B(b_B), .contrast_level(rmb_latch[3:0]), .contrast_VGA_R(contrast_bR), .contrast_VGA_G(contrast_bG), .contrast_VGA_B(contrast_bB));

grayscale graya(.raw_VGA_R(a_R), .raw_VGA_G(a_G), .raw_VGA_B(a_B), .grayscale_VGA_R(grayscale_aR), .grayscale_VGA_G(grayscale_aG), .grayscale_VGA_B(grayscale_aB));
grayscale grayb(.raw_VGA_R(b_R), .raw_VGA_G(b_G), .raw_VGA_B(b_B), .grayscale_VGA_R(grayscale_bR), .grayscale_VGA_G(grayscale_bG), .grayscale_VGA_B(grayscale_bB));


wire [7:0] hex0;
wire [7:0] hex1;
wire [7:0] hex2;
wire [7:0] hex3;
wire [7:0] hex4;
wire [7:0] hex5;

assign HEX0 = hex0;
assign HEX1 = hex1;
assign HEX2 = hex2;
assign HEX3 = hex3;
assign HEX4 = hex4;
assign HEX5 = hex5;

mouse u2(
	.hex0_out(hex0), 		// 7 bit binary Output
	.hex1_out(hex1), 		// 7 bit binary Output
	.hex2_out(hex2), 		// 7 bit binary Output
	.hex3_out(hex3), 		// 7 bit binary Output
	.hex4_out(hex4), 		// 7 bit binary Output
	.hex5_out(hex5), 		// 7 bit binary Output
	.clk_50(CLOCK_50), 			// input 50 MHz clk
	.ps2_clk(ps_clk), 	// ps2 clock
	.ps2_data(ps_data), 	// ps2 data
	.send_enable(switch[1]),	// switch 1
	.reset(switch[0])				// switch 0
);



always @ (*)
begin
	o_VGA_R = a_R;
	o_VGA_G = a_G;
	o_VGA_B = a_B;
	
//finite state machine for ui clickboxes
	//gaussian blur a
	if(ui_1_latch == 1'b1)
	begin
		o_VGA_R = vga_out_aR;
		o_VGA_G = vga_out_aG;
		o_VGA_B = vga_out_aB;
	end
	//gaussian blur b
	if(ui_2_latch == 1'b1)
	begin
		o_VGA_R = vga_out_bR;
		o_VGA_G = vga_out_bR;
		o_VGA_B = vga_out_bR;
	end
	//contrast a
	if(ui_3_latch == 1'b1)
	begin
		o_VGA_R = contrast_aR;
		o_VGA_G = contrast_aG;
		o_VGA_B = contrast_aB;
	end
	//contrast b
	if(ui_4_latch == 1'b1)
	begin
		o_VGA_R = contrast_bR;
		o_VGA_G = contrast_bG;
		o_VGA_B = contrast_bB;
	end
	//grayscale a
	if(ui_5_latch == 1'b1)
	begin
		o_VGA_R = grayscale_aR;
		o_VGA_G = grayscale_aG;
		o_VGA_B = grayscale_aB;
	end
	//grayscale b
	if(ui_6_latch == 1'b1)
	begin
		o_VGA_R = grayscale_bR;
		o_VGA_G = grayscale_bG;
		o_VGA_B = grayscale_bB;
	end
	//csct a
	if(ui_7_latch == 1'b1)
	begin
		o_VGA_R = a_csct[23:16];
		o_VGA_G = a_csct[15:8];
		o_VGA_B = a_csct[7:0];
	end
	//csct b
	if(ui_8_latch == 1'b1)
	begin
		o_VGA_R = b_csct[23:16];
		o_VGA_G = b_csct[15:8];
		o_VGA_B = b_csct[7:0];
	end
	//a & b (r & b)
	if(ui_9_latch == 1'b1)
	begin
		o_VGA_R = a_Gray;
		o_VGA_G = 8'h00;
		o_VGA_B = b_Gray;
	end
	//ui_10 min
	if(ui_10_latch == 1'b1)
	begin
		o_VGA_R = min;
		o_VGA_G = min;
		o_VGA_B = min;
	end
	//ui_11 disp
	if(ui_11_latch == 1'b1)
	begin
		o_VGA_R = disp;
		o_VGA_G = disp; 
		o_VGA_B = disp;
	end
	//ui_12 rgb
	if(ui_12_latch == 1'b1)
	begin
		o_VGA_R = rmb_latch[0]?a_R:b_R;
		o_VGA_G = rmb_latch[0]?a_G:b_G;
		o_VGA_B = rmb_latch[0]?a_B:b_B;
	end

//ps/2 mouse button user interface
	if(ui_state_machine[1:0] == 2'b01 || ui_state_machine[1:0] == 2'b11)
	begin 
		if(row >= lmb_up && row <= lmb_down && col >= lmb_left && col <= lmb_right)
		begin
			if(hex4[6:0] == 7'b1000111)
			begin
				o_VGA_R = 8'b11111111;
				o_VGA_G = 8'b00000000;
				o_VGA_B = 8'b00000000;
			end
			else
			begin
				o_VGA_R = 8'b00000000;
				o_VGA_G = 8'b11111111;
				o_VGA_B = 8'b00000000;
			end
		end

		if(row >= mmb_up && row <= mmb_down && col >= mmb_left && col <= mmb_right)
		begin
			if(hex4[6:0] == 7'b0101011)
			begin
				o_VGA_R = 8'b11111111;
				o_VGA_G = 8'b00000000;
				o_VGA_B = 8'b00000000;
			end
			else
			begin
				o_VGA_R = 8'b00000000;
				o_VGA_G = 8'b11111111;
				o_VGA_B = 8'b00000000;
			end
		end

		if(row >= rmb_up && row <= rmb_down && col >= rmb_left && col <= rmb_right)
		begin
			if(hex4[6:0] == 7'b0101111)
			begin
				o_VGA_R = 8'b11111111;
				o_VGA_G = 8'b00000000;
				o_VGA_B = 8'b00000000;
			end
			else
			begin
				o_VGA_R = 8'b00000000;
				o_VGA_G = 8'b11111111;
				o_VGA_B = 8'b00000000;
			end
		end	
	end

//ps/2 mouse movement user interface
	if(ui_state_machine[1:0] == 2'b10 || ui_state_machine[1:0] == 2'b11)
	begin
		if(row >= top_left_up && row <= top_left_down && col >= top_left_left && col <= top_left_right)
		begin
			if({hex3[6:0], hex2[6:0], hex1[6:0], hex0[6:0]} == 28'b1000111_0001110_1000001_0001100)
			begin
				o_VGA_R = 8'b11111111;
				o_VGA_G = 8'b00000000;
				o_VGA_B = 8'b00000000;
			end
			else
			begin
				o_VGA_R = 8'b00000000;
				o_VGA_G = 8'b11111111;
				o_VGA_B = 8'b00000000;
			end
		end

		if(row >= top_middle_up && row <= top_middle_down && col >= top_middle_left && col <= top_middle_right)
		begin
			if({hex3[6:0], hex2[6:0], hex1[6:0], hex0[6:0]} == 28'b0101011_0100111_1000001_0001100)
			begin
				o_VGA_R = 8'b11111111;
				o_VGA_G = 8'b00000000;
				o_VGA_B = 8'b00000000;
			end
			else
			begin
				o_VGA_R = 8'b00000000;
				o_VGA_G = 8'b11111111;
				o_VGA_B = 8'b00000000;
			end
		end
		
		if(row >= top_right_up && row <= top_right_down && col >= top_right_left && col <= top_right_right)
		begin
			if({hex3[6:0], hex2[6:0], hex1[6:0], hex0[6:0]} == 28'b0101111_1111000_1000001_0001100)
			begin
				o_VGA_R = 8'b11111111;
				o_VGA_G = 8'b00000000;
				o_VGA_B = 8'b00000000;
			end
			else
			begin
				o_VGA_R = 8'b00000000;
				o_VGA_G = 8'b11111111;
				o_VGA_B = 8'b00000000;
			end
		end
		
		if(row >= middle_left_up && row <= middle_left_down && col >= middle_left_left && col <= middle_left_right)
		begin
			if({hex3[6:0], hex2[6:0], hex1[6:0], hex0[6:0]} == 28'b1000111_0001110_0101011_0100111)
			begin
				o_VGA_R = 8'b11111111;
				o_VGA_G = 8'b00000000;
				o_VGA_B = 8'b00000000;
			end
			else
			begin
				o_VGA_R = 8'b00000000;
				o_VGA_G = 8'b11111111;
				o_VGA_B = 8'b00000000;
			end
		end

		if(row >= middle_middle_up && row <= middle_middle_down && col >= middle_middle_left && col <= middle_middle_right)
		begin
			if({hex3[6:0], hex2[6:0], hex1[6:0], hex0[6:0]} == 28'b0101011_0100111_0101011_0100111)
			begin
				o_VGA_R = 8'b11111111;
				o_VGA_G = 8'b00000000;
				o_VGA_B = 8'b00000000;
			end
			else
			begin
				o_VGA_R = 8'b00000000;
				o_VGA_G = 8'b11111111;
				o_VGA_B = 8'b00000000;
			end
		end
		
		if(row >= middle_right_up && row <= middle_right_down && col >= middle_right_left && col <= middle_right_right)
		begin
			if({hex3[6:0], hex2[6:0], hex1[6:0], hex0[6:0]} == 28'b0101111_1111000_0101011_0100111)
			begin
				o_VGA_R = 8'b11111111;
				o_VGA_G = 8'b00000000;
				o_VGA_B = 8'b00000000;
			end
			else
			begin
				o_VGA_R = 8'b00000000;
				o_VGA_G = 8'b11111111;
				o_VGA_B = 8'b00000000;
			end
		end


		if(row >= bottom_left_up && row <= bottom_left_down && col >= bottom_left_left && col <= bottom_left_right)
		begin
			if({hex3[6:0], hex2[6:0], hex1[6:0], hex0[6:0]} == 28'b1000111_0001110_0100001_0101011)
			begin
				o_VGA_R = 8'b11111111;
				o_VGA_G = 8'b00000000;
				o_VGA_B = 8'b00000000;
			end
			else
			begin
				o_VGA_R = 8'b00000000;
				o_VGA_G = 8'b11111111;
				o_VGA_B = 8'b00000000;
			end
		end

		if(row >= bottom_middle_up && row <= bottom_middle_down && col >= bottom_middle_left && col <= bottom_middle_right)
		begin
			if({hex3[6:0], hex2[6:0], hex1[6:0], hex0[6:0]} == 28'b0101011_0100111_0100001_0101011)
			begin
				o_VGA_R = 8'b11111111;
				o_VGA_G = 8'b00000000;
				o_VGA_B = 8'b00000000;
			end
			else
			begin
				o_VGA_R = 8'b00000000;
				o_VGA_G = 8'b11111111;
				o_VGA_B = 8'b00000000;
			end
		end
		
		if(row >= bottom_right_up && row <= bottom_right_down && col >= bottom_right_left && col <= bottom_right_right)
		begin
			if({hex3[6:0], hex2[6:0], hex1[6:0], hex0[6:0]} == 28'b0101111_1111000_0100001_0101011)
			begin
				o_VGA_R = 8'b11111111;
				o_VGA_G = 8'b00000000;
				o_VGA_B = 8'b00000000;
			end
			else
			begin
				o_VGA_R = 8'b00000000;
				o_VGA_G = 8'b11111111;
				o_VGA_B = 8'b00000000;
			end
		end
	end
	
//click button ui
	if(row >= ui_1_up && row <= ui_1_down && col >= ui_1_left && col <= ui_1_right)
	begin
		 //red if selected
		 if(ui_1_latch == 1'b1)
		 begin
			  o_VGA_R = 8'b11111111;
			  o_VGA_G = 8'b00000000;
			  o_VGA_B = 8'b00000000;
		 end
		 //yellow if cursor is hovering
		 else if(cursor_row >= ui_1_up && cursor_row <= ui_1_down && cursor_col >= ui_1_left && cursor_col <= ui_1_right)
		 begin
			  o_VGA_R = 8'b11111111;
			  o_VGA_G = 8'b11111111;
			  o_VGA_B = 8'b00000000;
		 end
		 //green if not hovering
		 else
		 begin
			  o_VGA_R = 8'b00000000;
			  o_VGA_G = 8'b11111111;
			  o_VGA_B = 8'b00000000;
		 end
	end

	if(row >= ui_2_up && row <= ui_2_down && col >= ui_2_left && col <= ui_2_right)
	begin
		 //red if selected
		 if(ui_2_latch == 1'b1)
		 begin
			  o_VGA_R = 8'b11111111;
			  o_VGA_G = 8'b00000000;
			  o_VGA_B = 8'b00000000;
		 end
		 //yellow if cursor is hovering
		 else if(cursor_row >= ui_2_up && cursor_row <= ui_2_down && cursor_col >= ui_2_left && cursor_col <= ui_2_right)
		 begin
			  o_VGA_R = 8'b11111111;
			  o_VGA_G = 8'b11111111;
			  o_VGA_B = 8'b00000000;
		 end
		 //green if not hovering
		 else
		 begin
			  o_VGA_R = 8'b00000000;
			  o_VGA_G = 8'b11111111;
			  o_VGA_B = 8'b00000000;
		 end
	end

	if(row >= ui_3_up && row <= ui_3_down && col >= ui_3_left && col <= ui_3_right)
	begin
		 //red if selected
		 if(ui_3_latch == 1'b1)
		 begin
			  o_VGA_R = 8'b11111111;
			  o_VGA_G = 8'b00000000;
			  o_VGA_B = 8'b00000000;
		 end
		 //yellow if cursor is hovering
		 else if(cursor_row >= ui_3_up && cursor_row <= ui_3_down && cursor_col >= ui_3_left && cursor_col <= ui_3_right)
		 begin
			  o_VGA_R = 8'b11111111;
			  o_VGA_G = 8'b11111111;
			  o_VGA_B = 8'b00000000;
		 end
		 //green if not hovering
		 else
		 begin
			  o_VGA_R = 8'b00000000;
			  o_VGA_G = 8'b11111111;
			  o_VGA_B = 8'b00000000;
		 end
	end

	if(row >= ui_4_up && row <= ui_4_down && col >= ui_4_left && col <= ui_4_right)
	begin
		 //red if selected
		 if(ui_4_latch == 1'b1)
		 begin
			  o_VGA_R = 8'b11111111;
			  o_VGA_G = 8'b00000000;
			  o_VGA_B = 8'b00000000;
		 end
		 //yellow if cursor is hovering
		 else if(cursor_row >= ui_4_up && cursor_row <= ui_4_down && cursor_col >= ui_4_left && cursor_col <= ui_4_right)
		 begin
			  o_VGA_R = 8'b11111111;
			  o_VGA_G = 8'b11111111;
			  o_VGA_B = 8'b00000000;
		 end
		 //green if not hovering
		 else
		 begin
			  o_VGA_R = 8'b00000000;
			  o_VGA_G = 8'b11111111;
			  o_VGA_B = 8'b00000000;
		 end
	end

	if(row >= ui_5_up && row <= ui_5_down && col >= ui_5_left && col <= ui_5_right)
	begin
		 //red if selected
		 if(ui_5_latch == 1'b1)
		 begin
			  o_VGA_R = 8'b11111111;
			  o_VGA_G = 8'b00000000;
			  o_VGA_B = 8'b00000000;
		 end
		 //yellow if cursor is hovering
		 else if(cursor_row >= ui_5_up && cursor_row <= ui_5_down && cursor_col >= ui_5_left && cursor_col <= ui_5_right)
		 begin
			  o_VGA_R = 8'b11111111;
			  o_VGA_G = 8'b11111111;
			  o_VGA_B = 8'b00000000;
		 end
		 //green if not hovering
		 else
		 begin
			  o_VGA_R = 8'b00000000;
			  o_VGA_G = 8'b11111111;
			  o_VGA_B = 8'b00000000;
		 end
	end

	if(row >= ui_6_up && row <= ui_6_down && col >= ui_6_left && col <= ui_6_right)
	begin
		 //red if selected
		 if(ui_6_latch == 1'b1)
		 begin
			  o_VGA_R = 8'b11111111;
			  o_VGA_G = 8'b00000000;
			  o_VGA_B = 8'b00000000;
		 end
		 //yellow if cursor is hovering
		 else if(cursor_row >= ui_6_up && cursor_row <= ui_6_down && cursor_col >= ui_6_left && cursor_col <= ui_6_right)
		 begin
			  o_VGA_R = 8'b11111111;
			  o_VGA_G = 8'b11111111;
			  o_VGA_B = 8'b00000000;
		 end
		 //green if not hovering
		 else
		 begin
			  o_VGA_R = 8'b00000000;
			  o_VGA_G = 8'b11111111;
			  o_VGA_B = 8'b00000000;
		 end
	end

	if(row >= ui_7_up && row <= ui_7_down && col >= ui_7_left && col <= ui_7_right)
	begin
		 //red if selected
		 if(ui_7_latch == 1'b1)
		 begin
			  o_VGA_R = 8'b11111111;
			  o_VGA_G = 8'b00000000;
			  o_VGA_B = 8'b00000000;
		 end
		 //yellow if cursor is hovering
		 else if(cursor_row >= ui_7_up && cursor_row <= ui_7_down && cursor_col >= ui_7_left && cursor_col <= ui_7_right)
		 begin
			  o_VGA_R = 8'b11111111;
			  o_VGA_G = 8'b11111111;
			  o_VGA_B = 8'b00000000;
		 end
		 //green if not hovering
		 else
		 begin
			  o_VGA_R = 8'b00000000;
			  o_VGA_G = 8'b11111111;
			  o_VGA_B = 8'b00000000;
		 end
	end

	if(row >= ui_8_up && row <= ui_8_down && col >= ui_8_left && col <= ui_8_right)
	begin
		 //red if selected
		 if(ui_8_latch == 1'b1)
		 begin
			  o_VGA_R = 8'b11111111;
			  o_VGA_G = 8'b00000000;
			  o_VGA_B = 8'b00000000;
		 end
		 //yellow if cursor is hovering
		 else if(cursor_row >= ui_8_up && cursor_row <= ui_8_down && cursor_col >= ui_8_left && cursor_col <= ui_8_right)
		 begin
			  o_VGA_R = 8'b11111111;
			  o_VGA_G = 8'b11111111;
			  o_VGA_B = 8'b00000000;
		 end
		 //green if not hovering
		 else
		 begin
			  o_VGA_R = 8'b00000000;
			  o_VGA_G = 8'b11111111;
			  o_VGA_B = 8'b00000000;
		 end
	end

	if(row >= ui_9_up && row <= ui_9_down && col >= ui_9_left && col <= ui_9_right)
	begin
		 //red if selected
		 if(ui_9_latch == 1'b1)
		 begin
			  o_VGA_R = 8'b11111111;
			  o_VGA_G = 8'b00000000;
			  o_VGA_B = 8'b00000000;
		 end
		 //yellow if cursor is hovering
		 else if(cursor_row >= ui_9_up && cursor_row <= ui_9_down && cursor_col >= ui_9_left && cursor_col <= ui_9_right)
		 begin
			  o_VGA_R = 8'b11111111;
			  o_VGA_G = 8'b11111111;
			  o_VGA_B = 8'b00000000;
		 end
		 //green if not hovering
		 else
		 begin
			  o_VGA_R = 8'b00000000;
			  o_VGA_G = 8'b11111111;
			  o_VGA_B = 8'b00000000;
		 end
	end

	if(row >= ui_10_up && row <= ui_10_down && col >= ui_10_left && col <= ui_10_right)
	begin
		 //red if selected
		 if(ui_10_latch == 1'b1)
		 begin
			  o_VGA_R = 8'b11111111;
			  o_VGA_G = 8'b00000000;
			  o_VGA_B = 8'b00000000;
		 end
		 //yellow if cursor is hovering
		 else if(cursor_row >= ui_10_up && cursor_row <= ui_10_down && cursor_col >= ui_10_left && cursor_col <= ui_10_right)
		 begin
			  o_VGA_R = 8'b11111111;
			  o_VGA_G = 8'b11111111;
			  o_VGA_B = 8'b00000000;
		 end
		 //green if not hovering
		 else
		 begin
			  o_VGA_R = 8'b00000000;
			  o_VGA_G = 8'b11111111;
			  o_VGA_B = 8'b00000000;
		 end
	end

	if(row >= ui_11_up && row <= ui_11_down && col >= ui_11_left && col <= ui_11_right)
	begin
		 //red if selected
		 if(ui_11_latch == 1'b1)
		 begin
			  o_VGA_R = 8'b11111111;
			  o_VGA_G = 8'b00000000;
			  o_VGA_B = 8'b00000000;
		 end
		 //yellow if cursor is hovering
		 else if(cursor_row >= ui_11_up && cursor_row <= ui_11_down && cursor_col >= ui_11_left && cursor_col <= ui_11_right)
		 begin
			  o_VGA_R = 8'b11111111;
			  o_VGA_G = 8'b11111111;
			  o_VGA_B = 8'b00000000;
		 end
		 //green if not hovering
		 else
		 begin
			  o_VGA_R = 8'b00000000;
			  o_VGA_G = 8'b11111111;
			  o_VGA_B = 8'b00000000;
		 end
	end

	if(row >= ui_12_up && row <= ui_12_down && col >= ui_12_left && col <= ui_12_right)
	begin
		 //red if selected
		 if(ui_12_latch == 1'b1)
		 begin
			  o_VGA_R = 8'b11111111;
			  o_VGA_G = 8'b00000000;
			  o_VGA_B = 8'b00000000;
		 end
		 //yellow if cursor is hovering
		 else if(cursor_row >= ui_12_up && cursor_row <= ui_12_down && cursor_col >= ui_12_left && cursor_col <= ui_12_right)
		 begin
			  o_VGA_R = 8'b11111111;
			  o_VGA_G = 8'b11111111;
			  o_VGA_B = 8'b00000000;
		 end
		 //green if not hovering
		 else
		 begin
			  o_VGA_R = 8'b00000000;
			  o_VGA_G = 8'b11111111;
			  o_VGA_B = 8'b00000000;
		 end
	end

	//create toggle for transparent rectangle
	
	//12 states ui state machine
	
	//RGB
	
	//blur
	//contrast
	//grayscale
	
	//census
	//disparity
	
	//check HEX0 HEX1, and HEX3 HEX2 to define the mouse movement
	//display + cursor
	if(row >= KEY1_row && row <= KEY0_row && col >= KEY1_col && col <= KEY0_col) begin
		o_VGA_R = {1'b1,o_VGA_R[7:1]};
		o_VGA_G = {1'b1,o_VGA_G[7:1]};
		o_VGA_B = {1'b1,o_VGA_B[7:1]};
	end
	
	if(
	((row == cursor_row - 1 || row == cursor_row || row == cursor_row + 1) && col == cursor_col)
	|| 
	((col == cursor_col - 1 || col == cursor_col || col == cursor_col + 1) && row == cursor_row)
	)
	begin
		o_VGA_R = 8'b00000000;
		o_VGA_G = 8'b11111111;
		o_VGA_B = 8'b11111111;
	end
	

end

endmodule
