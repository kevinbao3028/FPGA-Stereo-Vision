module CORNER(
	input clk,
	input signed [7:0] xgrad,
	input signed [7:0] ygrad,
	input	[12:0] col,
	input [12:0] row,
	output signed [7:0] pixout,
	output reg [12:0] ocol,
	output reg [12:0] orow
);

reg	signed	[15:0]	x2[2:0],xy[2:0],y2[2:0],txy;
reg	signed	[23:0]	temp1;//,temp2;
wire	signed	[23:0]	temp2;

//assign temp2 = temp1>0 ? temp1 : 0-temp1;//TODO: divide corner operator
//assign temp2 = temp1>=0 ? temp1>>12 : 8'h0;
assign pixout=	temp1>255 ? 8'hFF : temp1;
//preprocess bits coming in, then out
//TODO: change word width on linebuffers or add new ones for all 3 vals
wire	signed	[7:0]		x2out1,x2out2,	
								y2out1,y2out2,
								xyout1,xyout2;
								
reg	signed	[7:0]		x2data,
								y2data,
								xydata;
reg	signed	[15:0]	bx2,by2,bxy;
//TODO: figure out write address
linebuffer x2l1(.clock(clk),.data(x2data),.rdaddress(col[9:0]+10'd2),.wraddress(col[9:0]),.wren(1'b1),.q(x2out1));
linebuffer x2l2(.clock(clk),.data(x2out1),.rdaddress(col[9:0]+10'd2),.wraddress(col[9:0]),.wren(1'b1),.q(x2out2));
//linebuffer and blur all 3 values
reg sign;
reg	[7:0]	tempxy;
always @(posedge clk) begin

	txy	=	xgrad*ygrad;
	sign	=	txy<0;
	tempxy=	sign?(0-txy)>>8:txy>>8;
	x2[0] <=	(16'd0+xgrad*xgrad) >>8	;	x2[1]	<=	x2[0];	x2[2]	<=	x2[1];	x2data <=	(x2[0]+2*x2[1]+x2[2]);	//BEWARE: signed division
	xy[0] <=	sign?8'd0-tempxy:tempxy	;	xy[1]	<=	xy[0];	xy[2]	<=	xy[1];	y2data <=	(y2[0]+2*y2[1]+y2[2]);	//TODO: signed division
	y2[0]	<=	(16'h0+ygrad*ygrad) >>8	;	y2[1]	<=	y2[0];	y2[2]	<=	y2[1];	xydata <=	(xy[0]+2*xy[1]+xy[2]);
	//txy division not working properly
	//TODO: make these divide properly
	bx2	<=	(x2data+2*x2out1+x2out2);	//BEWARE: signed division
	by2	<=	(y2data+2*y2out1+y2out2);
	bxy	<=	(xydata+2*xyout1+xyout2);
	//calc blurred structure tensor
	temp1	= (16*(bx2*by2-bxy*bxy)-(bx2+by2)*(bx2+by2) );//TODO: saturate
	if			(temp1>262144)	temp1	=	(temp1+1048576	)>>13;
	else	if	(temp1>131072)	temp1	=	(temp1+65536	)>>11;
	else	if	(temp1>0		 )	temp1	=	temp1				 >>10;
	else							temp1	=	0;
//	if			(temp1>262144)	temp1	=	temp1>>12;
//	else if	(temp1>16384 )	temp1 =	
//	else if  (temp1>1024  ) temp1 =
//	else if  (temp1>16	 ) temp1 =
//	else		(temp1>0		 ) temp1 = 	
//	else							temp1	=	0;
	//temp1	= temp1>=0 ? temp1>>10 : 8'h0;
																		 //BEWARE signed division
	ocol <= col-1;
	orow <= row-1;
	//BEWARE: division not syntehsizable
end
//find peak point in every 64x64 square, determine if confident
//
endmodule
