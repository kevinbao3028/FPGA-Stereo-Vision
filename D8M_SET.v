module D8M_SET (
   input       CLOCK_50,	
	input       RESET_SYS_N ,	
	//output	   SCLK ,
	//inout 	   SDATA,
	
	input [9:0]CCD_DATA  ,
	input       CCD_FVAL  ,//frame valide
	input	      CCD_LVAL	 ,
	input	      CCD_PIXCLK,
	
   input       VGA_HS  ,
   input       VGA_VS  ,
	input  READ_EN , 

	output [7:0]sCCD_R,
	output [7:0]sCCD_G,
	output [7:0]sCCD_B,
	output		sCCD_DVAL,
	output  [12:0] READ_Cont,
   output  reg [12:0] X_Cont,	
   output  reg [12:0] Y_Cont,
   output  reg [12:0] X_WR_CNT	
 );
//=============================================================================
// REG/WIRE declarations
//=============================================================================
wire[9:0]  mCCD_DATA;
//-------CCD CA--- 
//D8M_WRITE_COUNTER 	u3	(	
//	.iCLK       ( CCD_PIXCLK ),
//	.iRST       ( RESET_SYS_N ),
//	.iFVAL      ( CCD_FVAL ),
//	.iLVAL      ( CCD_LVAL ),
//	.X_Cont     ( X_Cont ),
//	.Y_Cont     ( Y_Cont ),
//	.X_WR_CNT   (X_WR_CNT)
//			
//);
parameter D8M_LINE_CNT  =  792 ; //792from signaltape 
parameter FREE_RUN      =  44; 
	
reg				Pre_FVAL;
reg				Pre_LVAL;
reg 	[15:0]	X_TOTAL;
reg 	[15:0]	Y_TOTAL;  

always@(posedge CCD_PIXCLK or negedge RESET_SYS_N) begin
	if(!RESET_SYS_N) begin
		Pre_FVAL	<=CCD_FVAL;
		Pre_LVAL	<=CCD_LVAL;
		X_Cont	<=	0;
		Y_Cont	<=	0;
		X_WR_CNT <= 0; 
	end else begin
		Pre_FVAL	<=	CCD_FVAL;
		Pre_LVAL	<=	CCD_LVAL;
		if  ( Pre_LVAL & !CCD_LVAL)		
			X_WR_CNT <=   0; 
		else 	if ( CCD_LVAL ) 				
			X_WR_CNT <=  X_WR_CNT +1; 
      		
		//------------------------------		
		if   ( Pre_FVAL & !CCD_FVAL) 
			{ Y_TOTAL , Y_Cont }  	<=	{ Y_Cont ,16'h0  } ;
		else if   ( Pre_LVAL & !CCD_LVAL) begin 
			Y_Cont	  <=	 Y_Cont +1; 
		   { X_TOTAL , X_Cont }  	<=	{ X_Cont ,16'h0  } ;
		end else  if ( ( Y_Cont <=  FREE_RUN  ) && ( X_Cont	== D8M_LINE_CNT )) begin  
			Y_Cont	<=	 Y_Cont +1; 
		   X_Cont	<=	 0; 			
		end else 	
			X_Cont	<=	 X_Cont +1; 		
	end
end						
//--READ Counter --- 	
//VGA_READ_COUNTER   cnt(
//	.CLK   (CCD_PIXCLK  ),
//	.CLR_n (VGA_HS ),
//	.EN    (READ_EN),
//	.CNT   (READ_Cont)
//);
reg [15:0] CNT_ ;

assign READ_Cont = CNT_ ; 

always @ ( posedge CCD_PIXCLK ) begin
 if ( !VGA_HS) CNT_ <=0; 
 else if ( READ_EN ) CNT_ <=CNT_ +1 ; 
end

//
//--RAW TO RGB --- 							

parameter D8M_VAL_LINE_MAX  = 620; 
parameter D8M_VAL_LINE_MIN  = 2; 
//----- WIRE /REG 
wire	   [9:0]	mDAT0_0;
wire	   [9:0]	mDAT0_1;
wire 		[9:0]	mCCD_R;
wire 		[9:0]	mCCD_G; 
wire 		[9:0]	mCCD_B;
//-------- RGB OUT ---- 
assign   sCCD_R	 = mCCD_R[9:2];
assign  sCCD_G  = mCCD_G[9:2] ;
assign	sCCD_B	 =	mCCD_B[9:2];
//----3 2-PORT-LINE-BUFFER----  
Line_Buffer_J 	u0	(	
						.CCD_PIXCLK  ( CCD_PIXCLK ),
                  .mCCD_LVAL   ( CCD_LVAL) , 	
						.X_Cont      ( X_WR_CNT) , //ISSUE?
						.mCCD_DATA   ( CCD_DATA),
						.VGA_CLK     ( CCD_PIXCLK ), 
                  .READ_Request( READ_EN ),
                  .READ_Cont   ( READ_Cont),					
						.taps0x      ( mDAT0_0),
						.taps1x      ( mDAT0_1)
						);					
wire    RD_EN ; 
assign RD_EN = (( READ_Cont > D8M_VAL_LINE_MIN ) && ( READ_Cont < D8M_VAL_LINE_MAX ))?1:0 ; 								
RAW_RGB_BIN  bin(
      .CLK  ( CCD_PIXCLK ), 
      .RST_N( RD_EN  ) , 
      .D0   ( mDAT0_0),
      .D1   ( mDAT0_1),
      .X    ( READ_Cont[0]) ,
      .Y    ( Y_Cont[0]),
      .R    ( mCCD_B),
      .G    ( mCCD_G), 
      .B    ( mCCD_R)
); 
endmodule
