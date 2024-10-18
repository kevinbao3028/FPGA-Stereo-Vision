//////////////////////////////////
/// mouse interface to DE1-SoC ///
/// Feb 2016                   ///
/// ps2 interface              ///
/// part 1 introducing signals ///
/// module	for transmit  		 ///
//////////////////////////////////

module mouse (
 hex0_out, 		// 7 bit binary Output
 hex1_out, 		// 7 bit binary Output
 hex2_out, 		// 7 bit binary Output
 hex3_out, 		// 7 bit binary Output
 hex4_out, 		// 7 bit binary Output
 hex5_out, 		// 7 bit binary Output

 clk_50		, 	// input 50 MHz clk
 ps2_clk 	, 	// ps2 clock
 ps2_data	, 	// ps2 data
 send_enable,	// switch 1
 reset			// switch 0
);     


 output [6:0] hex0_out ;
 output [6:0] hex1_out ;
 output [6:0] hex2_out ;
 output [6:0] hex3_out ;
 output [6:0] hex4_out ;
 output [6:0] hex5_out ;
 
 inout ps2_clk;
 inout ps2_data;
 input clk_50;
 input reset; 				// swt 0 
 input send_enable; 		// swt 1
 
 ///////////////////////////////
 //// internal register ////////
 ///////////////////////////////
 
 reg [6:0] PS2_COUNTER; 
 reg [15:0] clk_div;
 reg [3:0] clk_counter; 
 reg send_recieved; 		
 reg send_start; 			
 reg send_stop;
 reg clk_stop;
 reg send_data;
 reg trigger_data; 	// tri state control for PS2 clock
 reg PSO;   			// stores serial data value
 reg PSCLK; 			// for ps2 clk
 reg clk;
 reg [8:0] PS; 		//for ps2 data
 
 //////////////////////////////////////
 // variables from transmit
 //////////////////////////////////////
 
 wire xyb_stop;
 wire [2:0] counter_xy;
 wire [2:0] cont_down;
 wire [2:0] cont_up;
 wire [6:0] xy_counter;
 wire [8:0] x_value;
 wire [8:0] y_value;
 wire [7:0] b_value;
 wire [8:0] x_first;
 wire [8:0] x_second;
 wire [8:0] y_first;
 wire [8:0] y_second;
 wire [3:0] state_value_y;
 wire [3:0] state_value_x;
 wire [8:0] hex_out0;
 wire [8:0] hex_out1;
 wire [8:0] hex_out2;
 wire [8:0] hex_out3;
 wire [8:0] hex_out4;
 wire [8:0] hex_out5;
 wire top;
 wire centre;
 wire last;
 wire upp;
 wire down;
 wire leftm;
 wire rghtm;
 wire resetx;
 wire resety;
 wire boff;
 

 wire enable_send = (PS2_COUNTER < 7'd23)? 1'b0 : 1'b1;
 
 
 //////////////////////////////////////////////////
 // module transmit     
 //////////////////////////////////////////////////
 
   transmit  u0(
	 .hex_out0(hex_out0), 		
	 .hex_out1(hex_out1), 		
	 .hex_out2(hex_out2), 		
	 .hex_out3(hex_out3), 		
	 .hex_out4(hex_out4), 		
	 .hex_out5(hex_out5),
	 
	 .x_value(x_value),
	 .y_value(y_value),
	 .b_value(b_value),
	 .top(top),
	 .centre(centre),
	 .last(last),
	 .leftm(leftm),
	 .rghtm(rghtm),
	 .boff(boff),
	 .upp(upp),
	 .down(down),
	 .counter_xy(counter_xy),
	 .xy_counter(xy_counter),
	 .cont_up(cont_up),
	 .state_value_y(state_value_y),
    .xyb_stop(xyb_stop),
	 
	 .clk(clk),
	 .enable_send(enable_send),
	 .reset(reset),
	 .resetx(resetx),
	 .resety(resety),
	 .ps2_clk (ps2_clk), 		
	 .ps2_data(ps2_data) 		
	);
 
 //////////////////////////////////////////////////////
 
 parameter clk_freq = 50000000;  // 50 Mhz
 parameter ps2_freq = 50000;     // 50 Khz
 parameter mouse_stream = 9 'b011110100; // streaming mouse with parity F4
 
//////////////////////////////////////////////
////// clock divider from 50 MHz to 50 KHz ///
//////////////////////////////////////////////
	
  always @ (posedge clk_50 or negedge reset)
  begin
		if (!reset)
		begin
			clk_div <= 0;  // counter
			clk <= 0;		// frequency

		end
		
		else
		
		begin
		
			if (clk_div <  (clk_freq/ps2_freq) )  // keeps dividing until reaches desired frequency
			clk_div <= clk_div + 1;
			
			
			else
			begin 
					clk_div <= 0;
					clk <= ~clk; // 50 KHz clock used for ps2 clock circuit
			end
		end
	end


 ///////////////////////////////////
 /// serial clock state machine  ///
 ///////////////////////////////////	
 
always @(negedge reset or posedge clk ) begin
	if (!reset) clk_counter =  4 'b1111;
	else begin
	if (send_enable==0)
		clk_counter=0;
		else
		if ((clk_counter < 7'd9) & (clk_stop ==0)) clk_counter = clk_counter + 1;
	end
	end
	
 /////////////////////////////
 // counter for PS2 clock  ///
 /////////////////////////////
 
 always @ (negedge reset or posedge clk ) begin
 
 if (!reset) begin clk_stop = 0;  send_start = 1 ; PSCLK = 1;  end
 else
 case (clk_counter)
 
		// begin clock load command pulse ~ 100 120 us
		
		4'd0	: begin clk_stop = 0; send_start = 1; PSCLK = 1; send_data = 0; trigger_data = 0; end // send command
		
		4'd1	: begin clk_stop = 0; send_start = 1; PSCLK = 0; send_data = 0; trigger_data = 0;end // active clock low
		
		4'd2	: begin clk_stop = 0; send_start = 1; PSCLK = 0; send_data = 0; trigger_data = 0; end // active clock low 
		
		4'd3	: begin clk_stop = 0; send_start = 1; PSCLK = 0; send_data = 0; trigger_data = 0;end // active clock low
		
		4'd4	: begin clk_stop = 0; send_start = 1; PSCLK = 1; send_data = 1; trigger_data = 1;end // await data transmission
		
		4'd5	: begin clk_stop = 0; send_start = 0; PSCLK = 1; send_data = 1; trigger_data = 1; end // keep data enabled
		
		4'd6	: begin clk_stop = 0; send_start = 0; PSCLK = 1; send_data = 1; trigger_data = 1; end // keep data enabled
		
		4'd7	: begin clk_stop = 0; send_start = 0; PSCLK = 1; send_data = 1; trigger_data = 1; end // keep data enabled
		
		4'd8	: begin clk_stop = 0; send_start = 0; PSCLK = 1; send_data = 1; trigger_data = 0; end // tri state data
		
		4'd9	: begin clk_stop = 1; send_start = 0; PSCLK = 1; send_data = 1; trigger_data = 0; end // stop counter
		
			endcase
	end
		
///////////////////////////////////////////
// counter to serially shift data bits  ///
//  into mouse register                 ///
///////////////////////////////////////////

always @(negedge reset or posedge ps2_clk) begin
	if (!reset) PS2_COUNTER =  7 'b0;
	else begin
	if (send_data ==0 )
		PS2_COUNTER=7'b0;
		else
		if ((PS2_COUNTER < 7'd23) & (send_stop ==0)) 
		
		PS2_COUNTER = PS2_COUNTER + 1;
	end
	end

	
 
 always @ (negedge reset or negedge ps2_clk) begin
 
 if (!reset) begin send_recieved = 0; PSO = 1; send_stop = 0; PS= mouse_stream ; end
 else
 case (PS2_COUNTER)
 
		// begin load
		7'd0	: begin PSO = 0; send_recieved = 0; send_stop = 0; end //  wait for clock	

		7'd1	: begin PSO = PS[0]; send_recieved = 1; send_stop = 0; end // bit 0
		
		7'd2	: begin PSO = PS[1]; send_recieved = 1; send_stop = 0; end // bit 1
		
		7'd3	: begin PSO = PS[2]; send_recieved = 1; send_stop = 0; end // bit 2
		
		7'd4	: begin PSO = PS[3]; send_recieved = 1; send_stop = 0; end // bit 3
		
		7'd5	: begin PSO = PS[4]; send_recieved = 1; send_stop = 0; end // bit 4
		
		7'd6	: begin PSO = PS[5]; send_recieved = 1; send_stop = 0; end // bit 5
		
		7'd7	: begin PSO = PS[6]; send_recieved = 1; send_stop = 0; end // bit 6 
		
		7'd8	: begin PSO = PS[7]; send_recieved = 1; send_stop = 0; end // bit 7	
		
		7'd9  : begin PSO = PS[8]; send_recieved = 1; send_stop = 0; end // bit 8
		
		7'd10	: begin PSO = 1; send_recieved = 1; send_stop = 0; end // parity
		
		7'd11	: begin PSO = 1; send_recieved = 1; send_stop = 0; end // stop
		
		7'd12	: begin PSO = 1; send_recieved = 0; send_stop = 0; end // ack (return ownership to mouse)
		
		7'd13 : begin PSO = 1; send_recieved = 0; send_stop = 0; end // PS2 clock and data tri stated
		
		7'd14	: begin PSO = 1; send_recieved = 0; send_stop = 0; end  // stop counter 1
		
		7'd15	: begin PSO = 1; send_recieved = 0; send_stop = 0; end  // stop counter 2
		
		7'd16	: begin PSO = 1; send_recieved = 0; send_stop = 0; end  // stop counter 3
		
		7'd17	: begin PSO = 1; send_recieved = 0; send_stop = 0; end  // stop counter 4
		
		7'd18	: begin PSO = 1; send_recieved = 0; send_stop = 0; end  // stop counter 5
		
		7'd19	: begin PSO = 1; send_recieved = 0; send_stop = 0; end  // stop counter 6
		
		7'd20	: begin PSO = 1; send_recieved = 0; send_stop = 0; end  // stop counter 7
		
		7'd21	: begin PSO = 1; send_recieved = 0; send_stop = 0; end  // stop counter 8
		
		7'd22	: begin PSO = 1; send_recieved = 0; send_stop = 0; end  // stop counter 9
		
		7'd23	: begin PSO = 1; send_recieved = 0; send_stop = 1; end  // stop counter 10
		
		7'd24	: begin PSO = 1; send_recieved = 0; send_stop = 1; end  // stop counter 11
			
		endcase
		end

 ///////////////////////////////////////////
 // assign signals                    //////
 ///////////////////////////////////////////
 
 assign ps2_clk = send_start ? PSCLK : 1'bz;  //bi-directional
 assign ps2_data = (send_recieved | trigger_data) ? PSO : 1'bz; //bi-directional
 
 assign hex0_out = hex_out0;
 assign hex1_out = hex_out1;
 assign hex2_out = hex_out2;
 assign hex3_out = hex_out3;
 assign hex4_out = hex_out4;
 assign hex5_out = hex_out5;
 


endmodule
