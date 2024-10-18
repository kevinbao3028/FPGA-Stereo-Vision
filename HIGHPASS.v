module HIGHPASS(
	input clk,	//pixel speed clock (25MHz)
	input [7:0] pix,
	input [12:0] row,
	input [12:0] col,
	output reg [7:0] pixout,
	output reg [12:0] rowout,
	output reg [12:0] colout
);
	//BEWARE: may have to zero pad image for avoid weird wrap arounds
	//5 linebuffers, QUESTION: does "leave it blank" initialize RAM to zero?
		//read col+1, so at clock t+1 it has the current value in that col
		//write col
	wire [7:0] out1,out2,out3,out4,out5;	
	//BEWARE: only using 9 lowest bit of column //TODO: double check ordering 0n col, col+2
	linebuffer l1(.clock(clk),.data(pix ),.rdaddress(col[9:0]+10'd2),.wraddress(col[9:0]),.wren(1'b1),.q(out1));	//2-port RAM 1024x8
	linebuffer l2(.clock(clk),.data(out1),.rdaddress(col[9:0]+10'd2),.wraddress(col[9:0]),.wren(1'b1),.q(out2));
	linebuffer l3(.clock(clk),.data(out2),.rdaddress(col[9:0]+10'd2),.wraddress(col[9:0]),.wren(1'b1),.q(out3));
	linebuffer l4(.clock(clk),.data(out3),.rdaddress(col[9:0]+10'd2),.wraddress(col[9:0]),.wren(1'b1),.q(out4));
	linebuffer l5(.clock(clk),.data(out4),.rdaddress(col[9:0]+10'd2),.wraddress(col[9:0]),.wren(1'b1),.q(out5));
	//registers store the last 5 8-bit values from each of the pixels
	reg [39:0] r1=40'b0,r1_c,r2=40'b0,r2_c,r3=40'b0,r3_c,r4=40'b0,r4_c,r5=40'b0,r5_c;
	always @(*) begin
		r1_c 	<= {r1[31:0],out1};
		r2_c 	<= {r2[31:0],out2};
		r3_c 	<= {r3[31:0],out3};
		r4_c	<= {r4[31:0],out4};
		r5_c 	<= {r5[31:0],out5};
		//compare each pixel in window
		pixout	<=(16'h0	+(  r1_c[7:0]+2*r1_c[15:8]+2*r1_c[23:16]+2*r1_c[31:24]+  r1_c[39:32])
								+(2*r2_c[7:0]+4*r2_c[15:8]+4*r2_c[23:16]+4*r2_c[31:24]+2*r2_c[39:32])
								+(2*r3_c[7:0]+4*r3_c[15:8]+4*r3_c[23:16]+4*r3_c[31:24]+2*r3_c[39:32])
								+(2*r4_c[7:0]+4*r4_c[15:8]+4*r4_c[23:16]+4*r4_c[31:24]+2*r4_c[39:32])
								+(  r5_c[7:0]+2*r5_c[15:8]+2*r5_c[23:16]+2*r5_c[31:24]+  r5_c[39:32]))>>6;
		//adjust output coords (input pixel is bottom right of window, output is center; -2,-2)
		colout <= col-12'd2;
		rowout <= row-12'd3;
	end
	
	always @(posedge clk) begin
		r1 <= r1_c;
		r2 <= r2_c;
		r3 <= r3_c;
		r4 <= r4_c;
		r5 <= r5_c;
	end
	
endmodule

