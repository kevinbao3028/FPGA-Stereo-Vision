module RECTIFY(
	input clk,
	input		[7:0]		a,
	input		[7:0]		b,
	input		[31:0]	ix,
	input		[31:0]	iy,
	output	[31:0]	ox,
	output	[31:0]	oy,
	output	[7:0]		oa,
	output	[7:0]		ob
	
);
parameter LINEDELAY=8;
parameter aH11=1	,aH12=0	,aH13=0,
			 aH21=0	,aH22=1	,aH23=0,
			 aH31=0	,aH32=0	,aH33=1;
parameter bH11=1	,bH12=0	,bH13=0,
			 bH21=0	,bH22=1	,bH23=0,
			 bH31=0	,bH32=0	,bH33=1;
//TODO: delay data by an addition 2 block cycles
//TODO: interp mulitple values

wire	signed [31:0]	y_want_a,y_want_b,x_want_a,x_want_b;

reg	[7:0]	data,datb;
reg	[12:0]	rd_ptr=0,wr_ptr_a,wr_ptr_b;//BITWIDTH DEPENDENT ON RAM SIZE
reg	[31:0]	delay_a,delay_b;

assign ox=ix;
assign oy=iy<LINEDELAY ? 525+iy-LINEDELAY: iy-LINEDELAY; //BEWARE: 525 vs 524 or something

RECTBUFFER buffer_a(.clock(clk),.data(data),.rdaddress(rd_ptr+2),.wraddress(wr_ptr_a),.wren(1'b1),.q(oa));
RECTBUFFER buffer_b(.clock(clk),.data(datb),.rdaddress(rd_ptr+2),.wraddress(wr_ptr_b),.wren(1'b1),.q(ob));

//BEWARE: signed properties of divider
//BEWARE: clk delay fo divider
//y_want goes negative over the top/bottom half border
//x_want_a-ox goes to lower value in those regions
INTDIV div_ax(//two clock cycle delay
	.clock(clk),
	.clken(1'b1),
	.numer	(32'h0+aH11*ix+aH12*iy+aH13),
	.denom	(32'h0+aH31*ix+aH32*iy+aH33),
	.quotient(x_want_a),
	.remain	());
INTDIV div_ay(
	.clock(clk),
	.clken(1'b1),
	.numer	(32'h0+aH21*ix+aH22*iy+aH23),
	.denom	(32'h0+aH31*ix+aH32*iy+aH33),
	.quotient(y_want_a),
	.remain	());
INTDIV div_bx(
	.clock(clk),
	.clken(1'b1),
	.numer	(32'h0+bH11*ix+bH12*iy+bH13),
	.denom	(32'h0+bH31*ix+bH32*iy+bH33),
	.quotient(x_want_b),
	.remain	());
INTDIV div_by(
	.clock(clk),
	.clken(1'b1),
	.numer	(32'h0+bH21*ix+bH22*iy+bH23),
	.denom	(32'h0+bH31*ix+bH32*iy+bH33),
	.quotient(y_want_b),
	.remain	());
//assign y_want_a=iy;
//assign y_want_b=iy;
//assign x_want_a=ix;
//assign x_want_b=ix;
always @(posedge clk) begin
	//calc desired coord
	//TODO: divider
	//x_want_a	=	(aH11*ix+aH12*iy+aH13)/(aH31*ix+aH32*iy+aH33);
	//y_want_a	=	(aH21*ix+aH22*iy+aH23)/(aH31*ix+aH32*iy+aH33);
	//x_want_b	=	(bH11*ix+bH12*iy+bH13)/(bH31*ix+bH32*iy+bH33);
	//y_want_b	=	(bH21*ix+bH22*iy+bH23)/(bH31*ix+bH32*iy+bH33);
	delay_a	=	(y_want_a-oy)*32'd640+(x_want_a-ox)-2;//is it an issue of fractional y lines?
	delay_b	=	(y_want_b-oy)*32'd640+(x_want_b-ox)-2;//for 2 clock cycle divider delay
	//TODO: fix skipping value in the middle
	//BEWARE: 32 bit delay -> 13 bit
	rd_ptr	<=	ix<640 ? rd_ptr+1 : rd_ptr;//only inc in frame
	wr_ptr_a	<=	rd_ptr+delay_a;
	wr_ptr_b	<=	rd_ptr+delay_b;
	data		<=	a;
	datb		<=	b;
//calcul
end

//BEWARE: writing to overflowed values outside active region---

endmodule
