module CSCT(
	input clk,	//pixel speed clock (25MHz)
	input [7:0] pix,
	input [12:0] row,
	input [12:0] col,
	output reg [23:0] pixout,
	output reg [12:0] rowout,
	output reg [12:0] colout
);
	parameter T = 8'd8;//8'd2;
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
	reg [7:0]  min,max;
	always @(*) begin
		r1_c 	<= {r1[31:0],out1};
		r2_c 	<= {r2[31:0],out2};
		r3_c 	<= {r3[31:0],out3};
		r4_c	<= {r4[31:0],out4};
		r5_c 	<= {r5[31:0],out5};
		//compare each pixel in window
		min=r3[23:16]>T?r3[23:16]-T:8'h0;
		max=r3[23:16]<256-T?r3[23:16]+T:8'hFF;
		pixout[4:0]		<=	{r1[39:32]>max,r1[31:24]>max,r1[23:16]>max,r1[15:8]>max,r1[7:0]>max};
		pixout[9:5]		<=	{r2[39:32]>max,r2[31:24]>max,r2[23:16]>max,r2[15:8]>max,r2[7:0]>max};
		pixout[13:10]	<=	{r3[39:32]>max,r3[31:24]>max,					 r3[15:8]>max,r3[7:0]>max};
		pixout[18:14]	<=	{r4[39:32]>max,r4[31:24]>max,r4[23:16]>max,r4[15:8]>max,r4[7:0]>max};
		pixout[23:19]	<=	{r5[39:32]>max,r5[31:24]>max,r5[23:16]>max,r5[15:8]>max,r5[7:0]>max};

//		pixout[4:0]		<=	{(r1[39:32]>min)&(r1[39:32]<max),(r1[31:24]>min)&(r1[31:24]<max),(r1[23:16]>min)&(r1[23:16]<max),(r1[15:8]>min)&(r1[15:8]<max),(r1[7:0]>min)&(r1[7:0]<max)};
//		pixout[9:5]		<=	{(r2[39:32]>min)&(r2[39:32]<max),(r2[31:24]>min)&(r2[31:24]<max),(r2[23:16]>min)&(r2[23:16]<max),(r2[15:8]>min)&(r2[15:8]<max),(r2[7:0]>min)&(r2[7:0]<max)};
//		pixout[13:10]	<=	{(r3[39:32]>min)&(r3[39:32]<max),(r3[31:24]>min)&(r3[31:24]<max),											,(r3[15:8]>min)&(r3[15:8]<max),(r3[7:0]>min)&(r3[7:0]<max)};
//		pixout[18:14]	<=	{(r4[39:32]>min)&(r4[39:32]<max),(r4[31:24]>min)&(r4[31:24]<max),(r4[23:16]>min)&(r4[23:16]<max),(r4[15:8]>min)&(r4[15:8]<max),(r4[7:0]>min)&(r4[7:0]<max)};
//		pixout[23:19]	<=	{(r5[39:32]>min)&(r5[39:32]<max),(r5[31:24]>min)&(r5[31:24]<max),(r5[23:16]>min)&(r5[23:16]<max),(r5[15:8]>min)&(r5[15:8]<max),(r5[7:0]>min)&(r5[7:0]<max)};
		
//		pixout[4:0]		<=	{r1[39:32]>r3[23:16],r1[31:24]>r3[23:16],r1[23:16]>r3[23:16],r1[15:8]>r3[23:16],r1[7:0]>r3[23:16]};
//		pixout[9:5]		<=	{r2[39:32]>r3[23:16],r2[31:24]>r3[23:16],r2[23:16]>r3[23:16],r2[15:8]>r3[23:16],r2[7:0]>r3[23:16]};
//		pixout[13:10]	<=	{r3[39:32]>r3[23:16],r3[31:24]>r3[23:16],						   ,r3[15:8]>r3[23:16],r3[7:0]>r3[23:16]};
//		pixout[18:14]	<=	{r4[39:32]>r3[23:16],r4[31:24]>r3[23:16],r4[23:16]>r3[23:16],r4[15:8]>r3[23:16],r4[7:0]>r3[23:16]};
//		pixout[23:19]	<=	{r5[39:32]>r3[23:16],r5[31:24]>r3[23:16],r5[23:16]>r3[23:16],r5[15:8]>r3[23:16],r5[7:0]>r3[23:16]};

		//adjust output coords (input pixel is bottom right of window, output is center; -2,-2)
		colout <= col-12'd2;
		rowout <= row-12'd2;
	end
	
	always @(posedge clk) begin
		r1 <= r1_c;
		r2 <= r2_c;
		r3 <= r3_c;
		r4 <= r4_c;
		r5 <= r5_c;
	end
	
endmodule

