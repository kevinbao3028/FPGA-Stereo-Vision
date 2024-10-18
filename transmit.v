//////////////////////////////////
/// mouse interface to DE1-SoC ///
/// Feb 2016                   ///
/// ps2 transfer               ///
/// part 2 transmit module     ///
/// updated Feb 2017				 ///
/// add more sesitive to 		 ///
/// movement check             ///
//////////////////////////////////

module transmit (
 hex_out0, 		// 7 bit binary Output
 hex_out1, 		// 7 bit binary Output
 hex_out2, 		// 7 bit binary Output
 hex_out3, 		// 7 bit binary Output
 hex_out4, 		// 7 bit binary Output
 hex_out5, 		// 7 bit binary Output
 x_value,		// 9 bit x direction value
 y_value,		// 9 bit y direction value
 b_value,		// 8 bit button and x/y sign value
 xy_counter,	// counter for serial shift register
 cont_up,
 state_value_y,
 counter_xy,
 resetx,			// initial state x direction
 resety,			// initial state y direction
 centre,
 boff,
 top,
 last,
 leftm,
 rghtm,
 upp,
 down,
 xyb_stop,		// indicates end of 3 bit transfer
 enable_send,  // stream load enabled
 clk,				// 50 KHz clock
 reset,			// master reset
 ps2_clk, 		// ps2 clock
 ps2_data	 	// ps2 data
);

 
 // input signals
 
 input ps2_clk;
 input ps2_data;
 input reset;
 input clk;
 input enable_send;
 
 //output registers ;
 
 output reg [6:0] hex_out0 ;
 output reg [6:0] hex_out1 ;
 output reg [6:0] hex_out2 ;
 output reg [6:0] hex_out3 ;
 output reg [6:0] hex_out4 ;
 output reg [6:0] hex_out5;
 output reg [6:0] xy_counter; 
 output reg [8:0] x_value;
 output reg [8:0] y_value;
 output reg [7:0] b_value;
 
 output reg xyb_stop;
 output reg centre;
 output reg top;
 output reg last;
 output reg leftm;
 output reg rghtm;
 output reg down;
 output reg upp;
 output reg resetx;
 output reg resety;
 output reg boff;
 
 
 // internal registers
 
 output reg [3:0] counter_xy;	// counter for first and second value
 output reg [3:0] state_value_y;// y state machine
 reg [3:0] state_value_x;// x state machine
 reg [8:0] x_first;		// store first x value
 reg [8:0] x_second;		// store second x value
 reg [8:0] y_first;		// store first y value
 reg [8:0] y_second;		// store second y value
 reg [32:0] xyb_value;	// serial shift register
 reg PSCLK;					// for ps2 clk
 reg [8:0] PS; 			//for ps2 data
 reg PSO;   				// stores serial data value
 
 
 // setting to create HEX value on display
 parameter HEX_0 = 7'b1000000;		// zero
 parameter HEX_1 = 7'b1111001;		// one
 parameter HEX_2 = 7'b0100100;		// two
 parameter HEX_3 = 7'b0110000;		// three
 parameter HEX_4 = 7'b0011001;		// four
 parameter HEX_5 = 7'b0010010;		// five
 parameter HEX_6 = 7'b0000010;		// six
 parameter HEX_7 = 7'b1111000;		// seven
 parameter HEX_8 = 7'b0000000;		// eight
 parameter HEX_9 = 7'b0011000;		// nine
 parameter HEX_10 = 7'b0001000;		// ten
 parameter HEX_11 = 7'b0000011;		// eleven
 parameter HEX_12 = 7'b1000110;		// twelve
 parameter HEX_13 = 7'b0100001;		// thirteen
 parameter HEX_14 = 7'b0000110;		// fourteen
 parameter HEX_15 = 7'b0001110;		// fifteen
 parameter zero   = 7'b1111111;		// all off
 
 //change the definition for right, left, and middle
 parameter right = 7'b0101111;      // right
 parameter left = 7'b1000111;			// left
 parameter middle = 7'b0101011;		// middle and letter n, (change to letter C later)
 parameter dash = 7'b0111111; 		// dash (no button push)
 
 parameter tee =  7'b1111000;			// letter T
 parameter you = 7'b1000001;        // letter U
 parameter pee = 7'b0001100;        // letter P
 parameter see = 7'b0100111;			// lower case c
 
 /////////////////////////////////////////////
 // state machine values for mouse movement //
 ///////////////////////////////////////////// 
 
 parameter load_value_y1 = 4'b0000;
 parameter load_value_y2 = 4'b0001;
 parameter test_sign_y =   4'b0010;
 parameter compare_up =    4'b0011;
 parameter compare_down =  4'b0100;
 parameter test_cont_y	=  4'b0101;
 parameter no_change_y =   4'b0110;
 parameter check_move_y =  4'b0111;
 parameter check_down =    4'b1000;
 parameter check_up =      4'b1001;
 parameter stay_y = 			4'b1010;
 
 parameter load_value_x1 = 4'b0000;
 parameter load_value_x2 = 4'b0001;
 parameter test_sign_x = 	4'b0010;
 parameter compare_left =  4'b0011;
 parameter compare_right = 4'b0100;
 parameter test_cont_x =   4'b0101;
 parameter no_change_x =   4'b0110;
 parameter check_move_x = 	4'b0111;
 parameter check_left = 	4'b1000;
 parameter check_right = 	4'b1001;
 parameter stay_x =			4'b1010;
 
 
 
  ////////////////////////////////////////
 // PS2 mouse value retrieve register  // 
 ////////////////////////////////////////
 
 always @(negedge enable_send or posedge ps2_clk) begin
 
 	if  (!enable_send)
	
	begin
	xy_counter = 7'b0; // reset counter
	end
	
	else begin
	
	if ( sync_time) 
	xy_counter = 7'b0;
	
	else
	xy_counter = xy_counter + 1;
	end
	
	end

 
 wire sync_time = (xy_counter < 7'd32)? 1'b0 : 1'b1; // end of each load cycle
 
 
 always @ (negedge enable_send or negedge ps2_clk) begin
 
 if (!enable_send) begin xyb_stop = 0 ; end
 else
 case (xy_counter)
 
		// begin load byte 0
		7'd0	: begin xyb_value[0] = ps2_data ; xyb_stop = 0; end // bit 0 - start
 
		7'd1	: begin xyb_value[1] = ps2_data ; xyb_stop = 0; end // bit 1 - valid bit 0 (left button)
		
		7'd2	: begin xyb_value[2] = ps2_data ; xyb_stop = 0; end // bit 2 - valid bit 1 (right button)
		
		7'd3	: begin xyb_value[3] = ps2_data ; xyb_stop = 0; end // bit 3 - valid bit 2 (middle button)
		
		7'd4	: begin xyb_value[4] = ps2_data ; xyb_stop = 0; end // bit 4 - valid bit 3 (always high)
		
		7'd5	: begin xyb_value[5] = ps2_data ; xyb_stop = 0; end // bit 5 - valid bit 4 (x sign)
		
		7'd6	: begin xyb_value[6] = ps2_data ; xyb_stop = 0; end // bit 6 - valid bit 5 (y sign)
		
		7'd7	: begin xyb_value[7] = ps2_data ; xyb_stop = 0; end // bit 7 - valid bit 6 (x over)
		
		7'd8	: begin xyb_value[8] = ps2_data ; xyb_stop = 0; end // bit 8 - valid bit 7 (y over)
		
		7'd9	: begin xyb_value[9] = ps2_data ; xyb_stop = 0; end // bit 9 - end 1
		
		7'd10	: begin xyb_value[10] = ps2_data ; xyb_stop = 0; end // bit 10 - end 2
		
		// begin load byte 1
		
		7'd11	: begin xyb_value[11] = ps2_data ; xyb_stop = 0; end // bit 0 - valid bit 0

		7'd12	: begin xyb_value[12] = ps2_data ; xyb_stop = 0; end // bit 1 - valid bit 1
		
		7'd13	: begin xyb_value[13] = ps2_data ; xyb_stop = 0; end // bit 2 - valid bit 2
		
		7'd14	: begin xyb_value[14] = ps2_data ; xyb_stop = 0; end // bit 3 - valid bit 3
		
		7'd15	: begin xyb_value[15] = ps2_data ; xyb_stop = 0; end // bit 4 - valid bit 4
		
		7'd16	: begin xyb_value[16] = ps2_data ; xyb_stop = 0; end // bit 5 - valid bit 5
		
		7'd17	: begin xyb_value[17] = ps2_data ; xyb_stop = 0; end // bit 6 - valid bit 6
		
		7'd18	: begin xyb_value[18] = ps2_data ; xyb_stop = 0; end // bit 7 - valid bit 7
		
		7'd19	: begin xyb_value[19] = ps2_data ; xyb_stop = 0; end // bit 8 - valid bit 8
		
		7'd20	: begin xyb_value[20] = ps2_data ; xyb_stop = 0; end // bit 9 -  end 1
		
		7'd21	: begin xyb_value[21] = ps2_data ; xyb_stop = 0; end // bit 10 - end 2
		
		// begin load byte 2
		
		7'd22	: begin xyb_value[22] = ps2_data ; xyb_stop = 0; end // bit 0 - valid bit 0

		7'd23	: begin xyb_value[23] = ps2_data ; xyb_stop = 0; end // bit 1 - valid bit 1
		
		7'd24	: begin xyb_value[24] = ps2_data ; xyb_stop = 0; end // bit 2 - valid bit 2
		
		7'd25	: begin xyb_value[25] = ps2_data ; xyb_stop = 0; end // bit 3 - valid bit 3
		
		7'd26	: begin xyb_value[26] = ps2_data ; xyb_stop = 0; end // bit 4 - valid bit 4
		
		7'd27 : begin xyb_value[27] = ps2_data ; xyb_stop = 0; end // bit 5 - valid bit 5
		
		7'd28	: begin xyb_value[28] = ps2_data ; xyb_stop = 0; end // bit 6 - valid bit 6
		
		7'd29	: begin xyb_value[29] = ps2_data ; xyb_stop = 0; end // bit 7 - valid bit 7
		
		7'd30	: begin xyb_value[30] = ps2_data ; xyb_stop = 0; end // bit 8 - valid bit 8
		
		7'd31	: begin xyb_value[31] = ps2_data ; xyb_stop = 0; end // bit 9 -  end 1
		
		7'd32	: begin xyb_value[32] = ps2_data ; xyb_stop = 1; end // bit 10 - end 2
		
			
		endcase
		
		end
////////////////////////////////////////////
/// store values in 8 bit register for  ////
/// button pushes middle left right     ////
/// x and y value                       ////
////////////////////////////////////////////		
		
		
	always @ ( posedge clk ) begin
	
		if (xyb_stop) begin
		
		 b_value [7:0] <= xyb_value [8:1];
		 x_value [8:0] <= xyb_value [19:11];
		 y_value [8:0] <= xyb_value [30:22];
		 
		 end	
	 end
	 
	
////////////////////////////////////////////////
/// Testing to see which button was pushed   ///
////////////////////////////////////////////////	
	 always @  ( posedge clk or negedge enable_send ) begin
	 
	 if (!enable_send) begin
// default setting		 
	 hex_out5 = dash;
	 hex_out4 = dash;
	 end
	 
	 else
	 
	 case (b_value [3:0])  
	 
	 4'b1100: begin  hex_out5 = HEX_11; hex_out4 = middle; centre = 1;top = 0; last = 0; boff = 0; end // middle button
	 4'b1010: begin  hex_out5 = HEX_11; hex_out4 = right; last = 1; centre = 0; top = 0; boff = 0; end  // right button
	 4'b1001: begin  hex_out5 = HEX_11; hex_out4 = left; top = 1; centre = 0; last = 0; boff = 0; end // left button
	 4'b1000: begin  hex_out5 = dash; hex_out4 = dash; centre = 0; top = 0; last = 0; boff = 1; end // no button push
	 
	 endcase
	 
	 end
	 
/////////////////////////////////////
////   counter  for ps2 clock    //// 	
/////////////////////////////////////

 always @ ( posedge xyb_stop ) begin
	
	if (!reset) begin counter_xy = 4'b0; end	
	
		else 
		
		counter_xy = counter_xy +1;
	 end


/////////////////////////////////
////   testing y movement    //// 	
/////////////////////////////////
 output reg[2:0] cont_up;
 reg[2:0] cont_down;
 reg[2:0] cont_left;
 reg[2:0] cont_right;
 reg[2:0] cont_track_y;
 reg[2:0] cont_track_x;

 always @	( posedge clk or negedge enable_send ) begin
	
	if  (!enable_send)
// default setting	
	begin
	state_value_y = load_value_y1;
	y_first = 8'b1;
	y_second = 8'b1;
	hex_out1 = dash;
	hex_out0 = dash;
	cont_up = 0;
	cont_down = 0;
	cont_track_y = 0;
	resety = 0;
	end
	
	else
	
	case (state_value_y)
	load_value_y1: //000
// load first y value	

	begin
	
	 if (!counter_xy[0])
	 y_first = y_value;
	 else 	 
	 state_value_y = load_value_y2;
	 end
///////////////////////////////////////////////////////	 
	 load_value_y2://001
// load second y value	 
	 begin
	 
	 if (counter_xy[0] & xyb_stop)
	 y_second = y_value;
	 else
	 state_value_y = test_sign_y;
	 end
///////////////////////////////////////////////////////	 
	 test_sign_y: //010
// compare to find direction	 
	 begin
	 
	 if (y_first[8] & y_second[8]) // both high values 
	  state_value_y = compare_down;
	  else if
	   (!y_first[8] & y_second[8] ) // first low and second high
		state_value_y = compare_down;
		else if
		(y_first[8] & !y_second[8]) // first high and second low
		state_value_y = compare_up;
		else if
		(!y_first[8] & !y_second[8]) // both low values
	   state_value_y = compare_up;
		
		else 
		
		state_value_y = test_sign_y; // once condition must be met
		
		end

///////////////////////////////////////////////////////		
		compare_up: //011
// display HEX value			
		begin				
	   resety = 1;
		cont_up = cont_up + 1;
		cont_track_y = cont_track_y + 1;
	   state_value_y = test_cont_y;
		end

///////////////////////////////////////////////////////		
		compare_down: // 100
// display HEX value		
		begin
	   resety = 1;
		cont_down = cont_down + 1;
		cont_track_y = cont_track_y + 1;
		state_value_y = test_cont_y;
		end
////////////////////////////////////////////////////////		

		test_cont_y: // 0101 (5)
		begin
		
		if (cont_track_y == 4) // keep track of # of movements
		
		state_value_y = check_move_y;
		
		else 
		state_value_y = no_change_y;
		end
		
		check_move_y: //0111 (7)
		
		begin
//		checking for down movement		
		if (cont_down >= 4)
		state_value_y = check_down;
		
		else 
// 	checking for up movement
		if (cont_up >= 4)
		state_value_y = check_up;
		
		else 
//		no vertical movement detected this cycle		
	
		state_value_y = stay_y;
		end
		
		stay_y:
//		There was no movement change
		begin
		hex_out1 = middle;
		hex_out0 = see;
		cont_track_y = 0;
		cont_down = 0;
		cont_up= 0;
		state_value_y = no_change_y;
		end		
		
		
		check_up	:	
//		There was up movement
		begin
		hex_out1 = you;
		hex_out0 = pee;
		upp = 1;
		down = 0;
		cont_track_y = 0;
		cont_down = 0;
		cont_up= 0;
		state_value_y = no_change_y;
		end
		
		check_down	:	
// 	There was down movement		
		begin
		hex_out1 = HEX_13;
		hex_out0 = middle;
		down  = 1;
		upp = 0;
		cont_track_y = 0;
		cont_down = 0;
		cont_up= 0;
		state_value_y = no_change_y;
		end
		
		no_change_y: //101
// wait for next movement check		
		begin
		
		if (!counter_xy[0])
		state_value_y = load_value_y1;
		else
		state_value_y = no_change_y;

		end
		endcase
		
		end
		
		
/////////////////////////////////
////   testing x movement    //// 	
/////////////////////////////////		

 always @	( posedge clk or negedge enable_send ) begin
	
	if  (!enable_send)
// default setting		
	begin
	state_value_x = load_value_x1;
	x_first = 8'b1;
	x_second = 8'b1;
	hex_out3 = dash;
	hex_out2 = dash;
	cont_left = 0;
	cont_right = 0;
	cont_track_x = 0;
	resetx = 0;

	end
	
	else
	
	case (state_value_x)
	load_value_x1: //000
	
	
	begin
	
	 if (!counter_xy[0])
	 x_first = x_value;	// load first x value 
	 
	 else 	 
	 state_value_x = load_value_x2;
	 end
///////////////////////////////////////////////////////	 
	 load_value_x2://001
	 
	 begin
	 
	 if (counter_xy[0] & xyb_stop )
	 x_second = x_value; // load second x value
	 else
	 state_value_x = test_sign_x;
	 end
///////////////////////////////////////////////////////	 
	 test_sign_x://010
// compare to find direction	 
	 begin
	 
	 if (x_first[8] & x_second[8]) // both high values 
	  state_value_x = compare_left;
	  else if
	   (!x_first[8] & x_second[8] ) // first low and second high
		state_value_x = compare_left;
		else if
		(x_first[8] & !x_second[8]) // first high and second low
		state_value_x = compare_right ;
		else if
		(!x_first[8] & !x_second[8]) // both low values
	   state_value_x = compare_right;
		
		else 
		
		state_value_x = test_sign_x; // once condition must be met
		
		end


///////////////////////////////////////////////////////		
		compare_right: //011
// display HEX value			
		begin				
		resetx = 1;
		cont_right = cont_right + 1;
		cont_track_x = cont_track_x + 1;
	   state_value_x = test_cont_x;
		end

///////////////////////////////////////////////////////		
		compare_left: // 100
// display HEX value		
		begin
	   resetx = 1;
		cont_left = cont_left + 1;
		cont_track_x = cont_track_x + 1;
		state_value_x = test_cont_x;
		end
////////////////////////////////////////////////////////		

		test_cont_x:
		begin
		
		if (cont_track_x == 4) // keep track of # of movements
		
		state_value_x = check_move_x;
		
		else 
		state_value_x = no_change_x;
		end
		
		check_move_x:
		
		begin
//		checking for right movement		
		if (cont_right >= 4)
		state_value_x = check_right;
		
		else 
// 	checking for left movement
		if (cont_left >= 4)
		state_value_x = check_left;
		
		else 
//		no horizontal movement detected this cycle	
		state_value_x = stay_x;
		end
		
		stay_x:
		
		begin
		
		hex_out3 = middle;
		hex_out2 = see;
		cont_track_x = 0;
		cont_left = 0;
		cont_right = 0;
		state_value_x = no_change_x;
		end
		
		
		check_right	:	
//		There was right movement
		begin
		hex_out3 = right;
		hex_out2 = tee;
		leftm = 0;
		rghtm = 1;
		cont_track_x = 0;
		cont_left = 0;
		cont_right = 0;
		state_value_x = no_change_x;
		end
		
		check_left :		
// 	There was left movement		
		begin
		hex_out3 = left;
		hex_out2 = HEX_15;
		rghtm = 0;
		leftm = 1;
		cont_track_x = 0;
		cont_left = 0;
		cont_right = 0;
		state_value_x = no_change_x;
		end	
		
		
		no_change_x:
// wait for next movement check  		
		begin
		
		if (!counter_xy[0])
		state_value_x = load_value_x1;
		
		else
		
		state_value_x = no_change_x;

		end
		
		endcase
		
		end
		
 endmodule		