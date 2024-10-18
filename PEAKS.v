module PEAKS(
	input clk,
	input en,
	input rst,
	input [7:0]	 pix,
	input [7:0]	 corner,
	input	[12:0] col,
	input [12:0] row,
	output reg [7:0] pixout
);	
////TODO: test with csct input instead of grayscale input
//parameter		KEYPOINT_THRESHOLD=64;//maybe 32?
//parameter		PEAK=3'd0,FINISH_BUFFER=3'd1,MATCH=3'd2,PROCESS_POINT=3'd2,NEXT=3'd3,HOLD=3'd4;
//reg	[2:0]		state;
//reg	[:]		microstate;
//reg	[:0]		count;
////look for peak in tile,when finished (on subcoord 63,63) look for next peak 
////																				or finish buffer (4+64+4),	then compute match for next frame (centered on same block), process point, 
////																				THEN:	increment tile and start matching the next time those points come in
////																				THEN: hold
//reg [3:0]		tileX,tileY; //(increment tileY then tileX makes it more efficient
////break into 64x64 points
////initially just display peak
////10 64 blocks wide, need to store the blocks
////BEWARE:	beware delay/kernel shift in CORNER input vs grayscale inputs
//
//always @(posedge clk) begin
//	
////	if	(rst) begin
////		argmaxX [col[12:6]][row[12:6]] <=	0;
////		argmaxY [col[12:6]][row[12:6]] <=	0;
////		maxpoint[col[12:6]][row[12:6]] <=	0;	
////	end else if	(en && corner>maxpoint[col[12:6]][row[12:6]]) begin
////		argmaxX [col[12:6]][row[12:6]] <=	col[5:0];
////		argmaxY [col[12:6]][row[12:6]] <=	row[5:0];
////		maxpoint[col[12:6]][row[12:6]] <=	corner;
////	end
//	
////	pixout = (col[5:0]==argmaxX[col[12:6]][row[12:6]])&&(row[5:0]==argmaxY[col[12:6]][row[12:6]])&&(maxpoint[col[12:6]][row[12:6]]>32) ? 8'hFF : 8'h00;
//	if				(state==PEAK			) begin
//		
//		if(/*WITHIN buffer window*/) begin
//			buffc_data	<=	pix;
//			buffc_addr	<=	//TODO //BEWARE: underflowing
//		end
//		
//		if(col[12:6]==tileX && row[12:6]==tileY) begin	//BEWARE: different bitsize
//			max		<=	corner>max ? pix 		 : max;
//			
//		end
//		
//		if (col[5:0]==63 && row[5:0]==63)
//			state	<=	max>KEYPOINT_THRESHOLD ? FINISH_BUFFER : NEXT ; //TODO: DOUBLE CHECK IF ITS ACTUALLY IN ACTIVE REGION
//	end else if (state==FINISH_BUFFER) begin //BEWARE: what happens it transitstoin to this state but theres no border left?
//		if(/*WITHIN buffer window*/) begin
//			buffc_data	<=	pix;
//			buffc_addr	<=	//TODO
//		end
//		if(/*TERMINAL CONDITION*/) begin
//			state 		<= MATCH;
//			microstate	<= 0;//TODO
//		end;
//	end else if (state==MATCH			) begin	
//		//buffer window in both, match both
//		//buffer both marcowindows into memory, search both in parallel
//		//calc start index for matching
//		if				(microstate==	)	begin
//			//buffer both windows
//			buffa_data	<=	//convert
//			buffa_addr	<=
//			buffb_data	<=
//			buffb_addr	<=
//			if(/*terminal value*/) begin
//				microstate<=//TODO
//				count	<=	0;
//			end
//		end else if (microstate==	)	begin
//			//1st 3 bits are window x, 2nd 3 are window y, next n are offset x, final n are offset y
//			//start matching to accum points, go until max
//			count	<=	count+1;
//			buffa_rd_addr	<=	//TODO xoffset+x
//			buffb_rd_addr	<=	//TODO yoffset+y
//			//BEWARE: data 2 clk cycles delayed
//			if			(/*start of new block (?two clock cycles ago?)*/) begin
//				a_minsad			<=	a_sad<a_minsad	? a_sad	:a_minsad;
//				a_argminXsad	<=	a_sad<a_minsad	? /*offset x*/ : a_argminXsad;
//				a_argminYsad	<=	a_sad<a_minsad	? /*offset y*/ : a_argminYsad;
//				a_sad				<=	/*abs diff*/;
//				b_minsad			<=	b_sad<minsad	? b_sad	:b_minsad;
//				b_argminXsad	<=	b_sad<minsad	? /*offset x*/ : b_argminXsad;
//				b_argminYsad	<=	b_sad<minsad	? /*offset y*/ : b_argminYsad;
//				b_sad				<=	/*abs diff*/;
//			end else begin
//				a_sad			<=	a_sad+/*abs diff*/;
//				b_sad			<=	b_sad+/*abs diff*/;
//			end
//			if(/*terminal value*/)
//				microstate<=//TODO;
//		end else if	(microstate==	)	begin
//			//now we have two matched points
//			if(/*terminal value*/)
//				
//		end
//	end else if (state==NEXT			) begin
//		tileY	<=	tileY==YMAX ? 0 : tileY+1;
//		tileX	<=	tileY==YMAX ? (tileX==XMAX?0:tileX+1) : tileX;
//		state	<=	(tileX==XMAX)&&(tileY==YMAX) ? HOLD : PEAK ;
//	end else if (state==HOLD			) begin
//			//send finish signal and wait for start signal
//			
//	end
//end
////step1:	display valid max peak points on screen, overlayed on raw image 
////step2:	display matched pairs overlayed on raw image
////step3: get function with homography calculation block
//
////step2:	state machine for frame on each point, buffer large as it comes in, then match incoming pixels on next frame
////		output to ram, once ran thru image, calculate homography
////rectify:

endmodule
