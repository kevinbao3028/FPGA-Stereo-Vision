module HYBRIDMEDIANBLUR(
	input clk,	//pixel speed clock (25MHz)
	input [7:0] pix,
	input [12:0] row,
	input [12:0] col,
	output reg [7:0] pixout,
	output reg [12:0] rowout,
	output reg [12:0] colout
);
	//TODO: make it remove on line buffer and use incoming values
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
	reg [23:0] r1=40'b0,r1_c,r2=40'b0,r2_c,r3=40'b0,r3_c,r4=40'b0,r4_c,r5=40'b0,r5_c;
	reg [7:0]  min45,max45,min90,max90;
	reg [7:0] s45[2:0],s90[2:0],m45,m90;
	always @(*) begin
		r1_c 	<= {r1[15:0],out1};
		r2_c 	<= {r2[15:0],out2};
		r3_c 	<= {r3[15:0],out3};		//compare each pixel in window
		//pixout<=
		//exclude min/max
		//min45	=	r1[23:16];
		min45	=	r1[7:0]<r1[23:16] ?	r1[7:0]	:	r1[23:16];
		min45	=	r3[7:0]<min45		?	r3[7:0]	:	min45;
		min45	=	r3[23:16]<min45	?	r3[23:16]:	min45;
		min45	=	r2[15:8]<min45		?	r2[15:8]:	min45;
		max45	=	r1[7:0]>r1[23:16] ?	r1[7:0]	:	r1[23:16];
		max45	=	r3[7:0]>max45		?	r3[7:0]	:	max45;
		max45	=	r3[23:16]>max45	?	r3[23:16]:	max45;
		max45	=	r2[15:8]>max45		?	r3[23:16]:	max45;
		s45[0]=	r1[23:16]==min45	?	r1[7:0] 	:	r1[23:16]==max45 ? r2[15:8] : r1[23:16];
		s45[1]=	r3[7:0]==min45  	?	r1[7:0] 	:	r3[7:0]==max45   ? r2[15:8] : r3[7:0];
		s45[2]=	r3[23:16]==min45	?	r1[7:0] 	:	r3[23:16]==max45 ? r2[15:8] : r3[23:16];
		if			( (s45[0]<=s45[1] && s45[0]>=s45[2])||(s45[0]>=s45[1] && s45[0]<=s45[2])	)	m45=s45[0];
		else if	( (s45[1]<=s45[0] && s45[1]>=s45[2])||(s45[1]>=s45[0] && s45[1]<=s45[2])	)	m45=s45[1];
		else																												m45=s45[2];
		
		min90	=	r1[15:8]<r2[7:0]	?	r1[15:8]	:	r2[7:0];
		min90	=	r2[23:16]<min90	?	r2[23:16]:	min90;
		min90	=	r3[15:8]<min90		?	r3[15:8] :	min90;
		min90	=	r2[15:8]<min90		?	r2[15:8] :	min90;
		max90	=	r1[15:8]<r2[7:0]	?	r1[15:8]	:	r2[7:0];
		max90	=	r2[23:16]<max90	?	r2[23:16]:	max90;
		max90	=	r3[15:8]<max90		?	r3[15:8] :	max90;
		max90	=	r2[15:8]<max90		?	r2[15:8] :	max90;
		s90[0]=	r2[7:0]==min90		?	r1[15:8] :	r1[7:0]==max90   ? r2[15:8] : r1[7:0];
		s90[1]=	r3[15:8]==min90  	?	r1[15:8] 	:	r3[15:8]==max90  ? r2[15:8] : r3[15:8];
		s90[2]=	r2[23:16]==min90	?	r1[15:8] 	:	r2[23:16]==max90 ? r2[15:8] : r2[23:16];
		if			( (s90[0]<=s90[1] && s90[0]>=s90[2])||(s90[0]>=s90[1] && s90[0]<=s90[2])	)	m90=s90[0];
		else if	( (s90[1]<=s90[0] && s90[1]>=s90[2])||(s90[1]>=s90[0] && s90[1]<=s90[2])	)	m90=s90[1];
		else																												m90=s90[2];
		
		if			( (m45<=r2[15:8] && m45>=m90)||(m45>=r2[15:8] && m45<=m90)	)	pixout=m45;
		else if	( (m90<=r2[15:8] && m90>=m45)||(m90>=r2[15:8] && m90<=m45)	)	pixout=m90;
		else																							pixout=r2[15:8];
		//adjust output coords (input pixel is bottom right of window, output is center; -2,-2)
		colout <= col-12'd1;
		rowout <= row-12'd1;
	end
	
	always @(posedge clk) begin
		r1 <= r1_c;
		r2 <= r2_c;
		r3 <= r3_c;
	end
	
endmodule

