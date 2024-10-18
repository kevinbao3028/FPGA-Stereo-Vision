module RAWDATA_TO_RGB (
	input RST_N,
//CAMERA B
	input		[9:0]		aData,
	input					aHS,
	input					aVS,
	input					aClk,	//25MHz from Camera A
	
	output		[7:0] 	aR,
	output		[7:0] 	aG,
	output		[7:0] 	aB,
	output reg	[15:0]	aX,
	output reg	[15:0]	aY,
//CAMERA A
	input 	[9:0] 	bData,
	input					bHS,
	input					bVS,
	input					bClk,	//25MHz from Camera B
	
	output		[7:0] 	bR,
	output		[7:0] 	bG,
	output		[7:0] 	bB,
	output reg	[15:0]	bX,
	output reg	[15:0]	bY,
//RGB READ IO
	input 					rdClk,	//25MHz clock to read at
	output 	   [15:0]	oX,
	output      [15:0]	oY,
//TEST IO
	input					swtest,
	output		[9:0]	otest
);
//COPIED AND MODIFIED FROM D8M_SET.v
parameter D8M_LINE_CNT  =  792 ; //792from signaltape 
parameter FREE_RUN      =  44; 
//Camera input logic
reg [15:0] aX_c,aY_c,bX_c,bY_c,oT,oT_c,aXcnt,aXcnt_c,bXcnt,bXcnt_c;
reg [2:0] aT=3'b1,aT_c,bT=3'b1,bT_c;
reg aHSold,aVSold,bHSold,bVSold;

always@(posedge aClk or negedge RST_N) begin
	if(!RST_N) begin
		aHSold	<=aHS;
		aVSold	<=aVS;
		aX	<=	0;
		aY	<=	0;
		aXcnt <= 0; 
	end else begin
		aHSold	<=aHS;
		aVSold	<=aVS;
		if  		( aHSold & !aHS)			aXcnt 	<=  16'h0; 
		else 	if ( aHS ) 						aXcnt 	<=  aXcnt +1; 
	
		if   		(aVSold & !aVS) 			 aY  		<=	16'h0;
		else if  (aHSold & !aHS) 			{aY,aX}	<= {aY+1,16'h0};
		else if 	((aY<=44)&&(aX==792)) 	{aY,aX}	<= {aY+1,16'h0}; 		
	   else 										 aX		<=	aX +1; 		
	end
end

always@(posedge bClk or negedge RST_N) begin
	if(!RST_N) begin
		bHSold	<=bHS;
		bVSold	<=bVS;
		bX	<=	0;
		bY	<=	0;
		bXcnt <= 0; 
	end else begin
		bHSold	<=bHS;
		bVSold	<=bVS;
		if  		( bHSold & !bHS)			bXcnt 	<=  16'h0; 
		else 	if ( bHS ) 						bXcnt 	<=  bXcnt +1; 
	
		if   		(bVSold & !bVS) 			 bY  		<=	16'h0;
		else if  (bHSold & !bHS) 			{bY,bX}	<= {bY+1,16'h0};
		else if 	((bY<=44)&&(bX==792)) 	{bY,bX}	<= {bY+1,16'h0}; 		
	   else 										 bX		<=	bX +1; 			
	end
end
always @(posedge aClk)
		if (aHS && !aHSold)	aT <= {aT[1:0],aT[2]} ;	//on aHS rising edge
always @(posedge bClk)
		if (bHS && !bHSold)	bT <= {bT[1:0],bT[2]} ;
//rgb output logic
reg	[9:0]		oRa,oRb,oGa,oGb,oBa,oBb,	aD0last,aD1last,bD0last,bD1last,aD0,aD1,bD0,bD1,	oGa_c,oGb_c;
wire	[9:0]		rda1,rda2,rda3,rdb1,rdb2,rdb3;
reg	[15:0]	rdX=16'h0,rdX_c,rdY=16'h0,rdY_c,rdAddr,rdAddr_c;

reg	VGA_VS_c;

assign	aR	= oRa[9:2];//rdY==0 ? 8'hFF : oRb[9:2];//oRa[9:2];
assign	aG	= oGa[9:2];//oGa[9:2];
assign	aB	= oBa[9:2];//oBb[9:2];//oBa[9:2];
assign	bR	= oRb[9:2];//oRb[9:2];
assign	bG	= oGb[9:2];//oGb[9:2];
assign	bB	= oBb[9:2];//oBb[9:2];

assign	oX	= rdX;
assign	oY	= rdY;

reg	stupida,stupidb; //TODO: DELETE/RENAME

always @(*) begin
	oT_c		<= ( rdX==16'h0 ? ( (oT<2)&RST_N ? oT+1 : 2'h0) : oT )&{2{RST_N}};
	rdX_c		<= (~aHS&aHSold)|(rdY<=44 & rdX==792)|~RST_N ? 16'h0 : rdX+1; 
	rdY_c		<= (~aVS&aVSold)|~RST_N ? 16'h0 : ( (~aHS&aHSold)|(rdY<=44 & rdX==792) ? rdY+1 : rdY); 
	rdAddr_c	<= aHS ? rdAddr+1 : 16'h0;
	{oGa_c,stupida}	<= rdX[0]^rdY[0] ? (11'b0+aD0+aD1last) : (11'b0+aD0last+aD1); //BEWARE: DONT TRUST SYNTHESIS
	{oGb_c,stupidb} 	<= rdX[0]^rdY[0] ? (11'b0+bD0+bD1last) : (11'b0+bD0last+bD1);
	case (oT)
	2'd0:	{aD0,bD0,aD1,bD1}	<=	{rda2,rdb2,rda3,rdb3};
	2'd1:	{aD0,bD0,aD1,bD1}	<=	{rda3,rdb3,rda1,rdb1};
	2'd2:	{aD0,bD0,aD1,bD1}	<=	{rda1,rdb1,rda2,rdb2};
	endcase
end
always @(posedge rdClk) begin
	oT				<= oT_c;
	rdX			<=	rdX_c;
	rdY			<=	rdY_c;
	rdAddr		<= rdAddr_c;
	aD0last		<= aD0;
	aD1last		<= aD1;
	bD0last		<= bD0;
	bD1last		<= bD1;
	case ({rdY[0],rdX[0]})	//Set R/B channels
	2'b01:	{oRa,oRb,oBa,oBb}	<=	{aD1,bD1,aD0last,bD0last};
	2'b00:	{oRa,oRb,oBa,oBb}	<=	{aD1last,bD1last,aD0,bD0};
	2'b11:	{oRa,oRb,oBa,oBb}	<=	{aD0,bD0,aD1last,bD1last};
	2'b10:	{oRa,oRb,oBa,oBb}	<=	{aD0last,bD0last,aD1,bD1};
	endcase

	oGa	<= oGa_c;
	oGb	<= oGb_c;
end
//Store the last 3 lines so the lines being read aren't the one being written
LINEBUFFER_RD line1a(
	.data( aData ),
	.wraddress( aXcnt ),
	.wrclock( aClk ),
	.wren( aT[0] && aHS),
	.rdaddress( rdX ),
	.rdclock( rdClk ),
	.q( rda1 )
);
LINEBUFFER_RD line2a(
	.data( aData ),
	.wraddress( aXcnt ),
	.wrclock( aClk ),
	.wren( aT[1] && aHS),
	.rdaddress( rdX ),
	.rdclock( rdClk ),
	.q( rda2 )
);
LINEBUFFER_RD line3a(
	.data( aData ),
	.wraddress( aXcnt ),
	.wrclock( aClk ),
	.wren( aT[2] && aHS ),
	.rdaddress( rdX ),
	.rdclock( rdClk ),
	.q( rda3 )
);

LINEBUFFER_RD line1b(
	.data( bData ),
	.wraddress( bXcnt ),
	.wrclock( bClk ),
	.wren( bT[0] && bHS),
	.rdaddress( rdX ),
	.rdclock( rdClk ),
	.q( rdb1 )
);
LINEBUFFER_RD line2b(
	.data( bData ),
	.wraddress( bXcnt ),
	.wrclock( bClk ),
	.wren( bT[1] && bHS),
	.rdaddress( rdX ),
	.rdclock( rdClk ),
	.q( rdb2 )
);
LINEBUFFER_RD line3b(
	.data( bData ),
	.wraddress( bXcnt ),
	.wrclock( bClk ),
	.wren( bT[2] && bHS),
	.rdaddress( rdX ),
	.rdclock( rdClk ),
	.q( rdb3 )
);

endmodule
