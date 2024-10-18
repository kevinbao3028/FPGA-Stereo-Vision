module EDGETHIN(
	input clk,	//pixel speed clock (25MHz)
	input [7:0] pix,
	input [12:0] row,
	input [12:0] col,
	output  [7:0] pixout,
	output reg [12:0] rowout,
	output reg [12:0] colout
);
	reg	[23:0]	xout1,yout1;
	wire	[23:0]	temp;
	assign temp = (24'h0+xout1*xout1+yout1*yout1)>>10;
	assign pixout = {8{temp>128}};//temp>255?255:temp;
	//BEWARE: may have to zero pad image for avoid weird wrap arounds
	//5 linebuffers, QUESTION: does "leave it blank" initialize RAM to zero?
		//read col+1, so at clock t+1 it has the current value in that col
		//write col
	wire [7:0] out1,out2,out3;	
	//BEWARE: only using 9 lowest bit of column //TODO: double check ordering 0n col, col+2
	linebuffer l1(.clock(clk),.data(pix ),.rdaddress(col[9:0]+10'd2),.wraddress(col[9:0]),.wren(1'b1),.q(out1));	//2-port RAM 1024x8
	linebuffer l2(.clock(clk),.data(out1),.rdaddress(col[9:0]+10'd2),.wraddress(col[9:0]),.wren(1'b1),.q(out2));
	linebuffer l3(.clock(clk),.data(out2),.rdaddress(col[9:0]+10'd2),.wraddress(col[9:0]),.wren(1'b1),.q(out3));
	//registers store the last 5 8-bit values from each of the pixels
	reg [23:0] r1=40'b0,r1_c,r2=40'b0,r2_c,r3=40'b0,r3_c;
	reg [9:0]	a,b,c,d;
	always @(*) begin
		r1_c 	<= {r1[15:0],out1};
		r2_c 	<= {r2[15:0],out2};
		r3_c 	<= {r3[15:0],out3};
		//compare each pixel in window
		a=r1[7:0]	+2*r2[7:0]	+r3[7:0]		;
		b=r1[23:16]	+2*r2[23:16]+r3[23:16]	;
		c=r1[7:0]	+2*r1[15:8]	+r1[23:16]	;
		d=r3[23:16]	+2*r3[15:8]	+r3[7:0]		;
		xout1	<=	4*(a>b?a-b:b-a);		//adjust output coords (input pixel is bottom right of window, output is center; -2,-2)
		yout1	<=	4*(c>d?c-d:d-c);
		colout <= col-12'd1;
		rowout <= row-12'd1;
	end
	
	always @(posedge clk) begin
		r1 <= r1_c;
		r2 <= r2_c;
		r3 <= r3_c;
	end
	
endmodule

