module DISPARITY(
	input 			clk,
	input [23:0]	a,
	input	[23:0]	b,
	input [7:0]		aGrad,
	input	[9:0]		x,
	input	[9:0]		y,
	input 			oreq,
	output[7:0]		omin,
	output[7:0]		oargmin,
	output[9:0]		ox,
	output[9:0]		oy
);
parameter	DELAY= 0;
parameter	P1	=	2;//2	4
parameter	P2	=	12;//9;//9	8
parameter	TV	=	4'd12;

integer i,j,k,m,n;

reg [23:0] bHist [63:0];
reg [23:0] d [63:0];
reg [7:0] disparity_curve 		[63:0];

//reg [7:0] disparity_curve_2	[63:0];	//store last 2 disparity curves
//d,disparity_curve
assign ox = x+64;
assign oy = y;

reg	[7:0]	min;
reg	[7:0]	argmin;

assign omin 	= min;
assign oargmin = argmin;

reg [3:0] disp	[63:0];
reg [3:0] w		[65:0];
reg [3:0] w_c	[65:0];
reg [3:0] w_min;

reg [3:0] e		[65:0];
reg [3:0] e_c  [65:0];
reg [3:0] e_min;

reg  [7:0]	p2;
wire [7:0]	p2_2;

reg [7:0]	w_outtemp ,w_arg1 ,w_arg2 ,w_arg3 ,w_arg4 ;
reg [7:0]	nw_outtemp,nw_arg1,nw_arg2,nw_arg3,nw_arg4;
reg [7:0]	n_outtemp ,n_arg1 ,n_arg2 ,n_arg3 ,n_arg4 ;
reg [7:0]	ne_outtemp,ne_arg1,ne_arg2,ne_arg3,ne_arg4;

reg [7:0]	e_outtemp ,e_arg1 ,e_arg2 ,e_arg3 ,e_arg4 ;

wire	[10:0]	d_wr_add,d_rd_add;
wire  [9:0]		pixadd;

//sum, compress curve into 4 bits
reg	[255:0]	nw_data,		n_data,		ne_data;
wire	[255:0]	nw_q,			n_q,			ne_q;
reg	[3:0]		nw_min_data,n_min_data,	ne_min_data;
wire	[3:0]		nw_min_q,	n_min_q,		ne_min_q;

reg 	[255:0]	l_data,		d_data;
wire	[255:0]	l_q,			d_q;


always @(posedge clk) begin
	min=255;
	argmin=0;
	//TODO: reset w_min, choose better than 48
	w_min 	  = 255;
	nw_min_data= 255;
	 n_min_data= 255;
	ne_min_data= 255;
	e_min		  = 255;
	w[0]	<=	TV;
	w[65]	<=	TV;
	e[0]	<=	TV;
	e[65]	<= TV;
	//PART 0
	if 		(aGrad<16)	p2<=8'd14;
	else if	(aGrad<32)	p2<=8'd12;
	else if	(aGrad<64)	p2<=8'd10;
	else if	(aGrad<96)	p2<=8'd08;
	else if	(aGrad<128)	p2<=8'd06;
	else if	(aGrad<192)	p2<=8'd04;
	else						p2<=8'd03;
	
	for(i=0;i<64;i=i+1) begin	//BEWARE: trying to index Hist[64] at the end
//STAGE 1
//		aHist[i+1] <= aHist[i];
		d[i]=a^bHist[i];//if we make these parallel it'll only delay it by a clk cycle
		//adds up all 24 bits of d
		//disparity_curve_2	[i] 	= 	disparity_curve[i];
		disparity_curve[i]	=	8'd0+d[i][0] +d[i][1] +d[i][2] +d[i][3] +d[i][4] +d[i][5] +d[i][6] +d[i][7]
											 +d[i][8] +d[i][9] +d[i][10]+d[i][11]+d[i][12]+d[i][13]+d[i][14]+d[i][15]
											 +d[i][16]+d[i][17]+d[i][18]+d[i][19]+d[i][20]+d[i][21]+d[i][22]+d[i][23];
		//{min,argmin} = disparity_curve[i] < min ? {disparity_curve[i],i+8'd0} : {min,argmin};
		case(disparity_curve[i]) //qunatized log //BEWARE: before or after pixel merge?
		0:	disp[i]	= 	4'd0;
		1:	disp[i]	=	4'd2;
		2:	disp[i]	=	4'd3;
		3:	disp[i]	=	4'd4;
		4:	disp[i]	=	4'd5;
		5:	disp[i]	=	4'd5;
		6:	disp[i]	=	4'd6;
		7:	disp[i]	=	4'd6;
		8:	disp[i]	=	4'd6;
		default:	disp[i]	=	4'd7;
		endcase
		argmin		= (8'h0+e_c[i+1]+4*l_q[4*i +:4])<min	  ? i			 : argmin;
		min			= (8'h0+e_c[i+1]+4*l_q[4*i +:4])<min	  ? (8'h0+e_c[i+1]+4*l_q[4*i +:4]) : min;
//STAGE 2
		w_min			= w_c[i+1]<w_min ? w_c[i+1] : w_min;
		nw_min_data	= nw_data[4*i +:4]<nw_min_data ? nw_data[4*i +:4] : nw_min_data;
		 n_min_data	=  n_data[4*i +:4]< n_min_data ?  n_data[4*i +:4] :  n_min_data;
		ne_min_data	= ne_data[4*i +:4]<ne_min_data ? ne_data[4*i +:4] : ne_min_data;
		e_min			= e_c[i+1]<e_min ? e_c[i+1] : e_min;

		
		w[i+1]	<= oreq ? w_c[i+1] : 4'h0;
		e[i+1]	<= oreq ? e_c[i+1] : 4'h0;//this refill value bad prolly
//STAGE 3
		l_data[4*i +:4]	<=	(6'h0+nw_data[4*i +:4]+n_data[4*i +:4]+ne_data[4*i +:4]+w_c[i+1])>>2;
		d_data[4*i +:4]	<=	disp[i];
	end
	for(n=62;n>=0;n=n-1)
		bHist[n+1] <= bHist[n];
	bHist[0] <= b;
end

DISPBUFFER	nw_buffer		(	.clock(clk),.data(y>1 ? nw_data : 256'h0),.rdaddress(x+10'd1),.wraddress(x),.wren(1'b1),.q(nw_q)	);
DISPBUFFER  n_buffer			(	.clock(clk),.data(y>1 ?  n_data : 256'h0),.rdaddress(x+10'd2),.wraddress(x),.wren(1'b1),.q( n_q)	);
DISPBUFFER 	ne_buffer		(	.clock(clk),.data(y>1 ? ne_data : 256'h0),.rdaddress(x+10'd3),.wraddress(x),.wren(1'b1),.q(ne_q)	);
////one clock cycle delayed
MINBUFFER	nw_min_buffer	(	.clock(clk),.data(nw_min_data),.rdaddress(x+10'd1),.wraddress(x-1),.wren(1'b1),.q(nw_min_q)	);
MINBUFFER	n_min_buffer	(	.clock(clk),.data( n_min_data),.rdaddress(x+10'd1),.wraddress(x-1),.wren(1'b1),.q( n_min_q)	);
MINBUFFER	ne_min_buffer	(	.clock(clk),.data(ne_min_data),.rdaddress(x+10'd1),.wraddress(x-1),.wren(1'b1),.q(ne_min_q)	);
//TODO: zero pad other dims
//aggregate costs

//TODO: ensure proper underflow for addresses
//data lines are from one clock cycle ago

assign pixadd	 = 10'd639-x;
assign d_rd_add = 11'd0+{1'b0,{10{~y[0]}}}+pixadd;
assign d_wr_add = 11'd0+{1'b0,{10{ y[0]}}}+x;

DOUBLEDISPBUFFER		l_buffer		(	.clock(clk),.data(l_data),.rdaddress(d_rd_add),.wraddress(d_wr_add),.wren(1'b1),.q(l_q)	);
DOUBLEDISPBUFFER		d_buffer		(	.clock(clk),.data(d_data),.rdaddress(d_rd_add),.wraddress(d_wr_add),.wren(1'b1),.q(d_q) );
DOUBLEWEIGHTBUFFER	p_buffer		(	.clock(clk),.data(p2)	 ,.rdaddress(d_rd_add),.wraddress(d_wr_add),.wren(1'b1),.q(p2_2) );



always @(*) begin
	for(j=0;j<64;j=j+1) begin
		//W
		w_arg1	=	w[j+1];
		w_arg2	=	w[j+2]+P1;
		w_arg3	=	w[j+0]+P1;
		w_arg4	=	w_min+p2;
		if			(w_arg1<=w_arg2 && w_arg1<=w_arg3 && w_arg1<=w_arg4)			w_outtemp	=	disp[j]+w_arg1-w_min;
		else if	(w_arg2<=w_arg1 && w_arg2<=w_arg3 && w_arg2<=w_arg4)			w_outtemp	=	disp[j]+w_arg2-w_min;
		else if	(w_arg3<=w_arg1 && w_arg3<=w_arg2 && w_arg3<=w_arg4)			w_outtemp	=	disp[j]+w_arg3-w_min;
		else																						w_outtemp	=	disp[j]+w_arg4-w_min;
		w_c[j+1]	<=	w_outtemp>15 ? 4'hF : w_outtemp;
		//NW
		nw_arg1	=	nw_q[4*j +:4];
		if (j<63)	nw_arg2	=	4'd0+nw_q[4*j+4 +:4]+P1;
		else			nw_arg2	=	TV+P1;
		if (j>1)		nw_arg3	=	4'd0+nw_q[4*j-4 +:4]+P1;
		else 			nw_arg3	= 	TV+P1;	//PROBLEM: SETTING EDGES TO ZERO
		nw_arg4	=	nw_min_q+p2;
		if			(nw_arg1<=nw_arg2 && nw_arg1<=nw_arg3 && nw_arg1<=nw_arg4)	nw_outtemp	=	disp[j]+nw_arg1-nw_min_q;
		else if	(nw_arg2<=nw_arg1 && nw_arg2<=nw_arg3 && nw_arg2<=nw_arg4)	nw_outtemp	=	disp[j]+nw_arg2-nw_min_q;
		else if	(nw_arg3<=nw_arg1 && nw_arg3<=nw_arg2 && nw_arg3<=nw_arg4)	nw_outtemp	=	disp[j]+nw_arg3-nw_min_q;
		else																						nw_outtemp	=	disp[j]+nw_arg4-nw_min_q;
		nw_data[4*j +:4]	<=	nw_outtemp>15?4'hF:nw_outtemp;
//		//N
		n_arg1	=	n_q[4*j +:4];
		if (j<63)	n_arg2	=	4'd0+n_q[4*j+4 +:4]+P1;
		else			n_arg2	=	TV+P1;
		if (j>1)		n_arg3	=	4'd0+n_q[4*j-4 +:4]+P1;
		else 			n_arg3	= 	TV+P1;
		n_arg4	=	n_min_q+p2;
		if			(n_arg1<=n_arg2 && n_arg1<=n_arg3 && n_arg1<=n_arg4)			n_outtemp	=	disp[j]+n_arg1-n_min_q;
		else if	(n_arg2<=n_arg1 && n_arg2<=n_arg3 && n_arg2<=n_arg4)			n_outtemp	=	disp[j]+n_arg2-n_min_q;
		else if	(n_arg3<=n_arg1 && n_arg3<=n_arg2 && n_arg3<=n_arg4)			n_outtemp	=	disp[j]+n_arg3-n_min_q;
		else																						n_outtemp	=	disp[j]+n_arg4-n_min_q;
		n_data[4*j +:4]	<=	n_outtemp>15?4'hF:n_outtemp;
//		//NE
		ne_arg1	=	ne_q[4*j +:4];
		if (j<63)	ne_arg2	=	4'd0+ne_q[4*j+4 +:4]+P1;
		else			ne_arg2	=	TV+P1;
		if (j>1)		ne_arg3	=	4'd0+ne_q[4*j-4 +:4]+P1;
		else 			ne_arg3	= 	TV+P1;
		ne_arg4	=	ne_min_q+p2;
		if			(ne_arg1<=ne_arg2 && ne_arg1<=ne_arg3 && ne_arg1<=ne_arg4)	ne_outtemp	=	disp[j]+ne_arg1-ne_min_q;
		else if	(ne_arg2<=ne_arg1 && ne_arg2<=ne_arg3 && ne_arg2<=ne_arg4)	ne_outtemp	=	disp[j]+ne_arg2-ne_min_q;
		else if	(ne_arg3<=ne_arg1 && ne_arg3<=ne_arg2 && ne_arg3<=ne_arg4)	ne_outtemp	=	disp[j]+ne_arg3-ne_min_q;
		else																						ne_outtemp	=	disp[j]+ne_arg4-ne_min_q;
		ne_data[4*j +:4]	<=	ne_outtemp>15? 4'hF : ne_outtemp;
//		//E		
		e_arg1	=	e[j+1];
		e_arg2	=	e[j+2]+P1;
		e_arg3	=	e[j+0]+P1;
		e_arg4	=	e_min+p2_2;
		if			(e_arg1<=e_arg2 && e_arg1<=e_arg3 && e_arg1<=e_arg4)			e_outtemp	=	d_q[j]+e_arg1-e_min;
		else if	(e_arg2<=e_arg1 && e_arg2<=e_arg3 && e_arg2<=e_arg4)			e_outtemp	=	d_q[j]+e_arg2-e_min;
		else if	(e_arg3<=e_arg1 && e_arg3<=e_arg2 && e_arg3<=e_arg4)			e_outtemp	=	d_q[j]+e_arg3-e_min;
		else																						e_outtemp	=	d_q[j]+e_arg4-e_min;
		e_c[j+1]	<=	e_outtemp>15 ? 4'hF : e_outtemp;
	end
end

endmodule
