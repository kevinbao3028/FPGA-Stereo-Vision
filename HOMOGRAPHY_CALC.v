module HOMOGRAPHY_CALC(
	input clk
	
	//possibly feed ram into this? and state?
);
//reg	[:0]	state=0;
//wait for points list -> eight point algo -> fit rectifying homography -> output to rectification module -> wait for..
//8point
//calc smallest eigenvalue of Y
//repack e
//find smallest singular vectors/values
//subtract from e to get rank 2 matrix

//fit rectifying homography
//always @(posedge clk) begin
//
//end
//
//given a list of points, 
//start with 9XN memory
//run instruction every 14 clock cycles
//run instrction, wait 13 cycles, 

reg [3:0]	count=0;
reg [15:0]	ip=0;
reg [15:0]	gp0,gp1,gp2,gp3,gp4;//TODO: add mroe gp as neccesary
reg [31:0]	fp0,fp1,fp2,fp3,fp4;
reg [31:0]	arg1,arg2;
reg [31:0]	y[8:0][17:0];	//TODO: init as valid matrix
//BEWARE: addressing order of 2d array in verilog
reg [31:0]	fp_div,fp_mult,fp_add,fp_sub,fp_lt;


FPADD fpadd(
	.clock(clk),
	.dataa(arg1),
	.datab(arg2),
	.result(fp_add)
);
FPSUB fpsub(
	.clock(clk),
	.dataa(arg1),
	.datab(arg2),
	.result(fp_sub)
);
FPDIV fpdiv(
	.clock(clk),
	.dataa(arg1),
	.datab(arg2),
	.result(fp_div)
);
FPMUL fpmul(
		.clk(clk),    //    clk.clk
		.areset(1'b0), // areset.reset
		.a(arg1),      //      a.a
		.b(arg2),      //      b.b
		.q(fp_mult)       //      q.q
);

always @(posedge clk) begin
	count<= count+1;

	if(count==0) begin
		case(ip)
		0:	gp0	<=	0;
		1:	gp1	<=	gp0+1;			
		2:	begin								arg1	<=	y[gp1][gp0];	arg2	<=	y[gp0][gp0];	end
		3:	fp2	<=	fp_div;
		4:	gp3	<=	0;					
		5:	begin								arg1	<=	fp2;				arg2	<=	y[gp0][gp3]; 	end
		6:	begin								arg1	<=	y[gp1][gp3];	arg2	<=	fp_mult;			end
		7:	y[gp1][gp3]	<=	fp_sub;
		8:	gp3	<=	gp3+1;	
		9:	ip		<=	gp3<18?ip-5:ip;
		10:gp1	<=	gp1+1;
		11:ip		<=	gp1<9?ip-10:ip;
		12:fp2	<= y[gp0][gp0];
		13:gp3	<=	0;
		14:begin								arg1	<=	y[gp0][gp3];	arg2	<=	fp2;				end
		15:y[gp0][gp3]	<=	fp_div;
		16:gp3	<=	gp3+1;
		17:ip		<=	gp3<18?ip-4:ip;
		18:gp0	<=	gp0+1;
		19:ip		<=	gp0<8?ip-16:ip;
		20:fp2	<= y[gp0][gp0];
		21:gp3	<=	0;
		22:begin								arg1	<=	y[gp0][gp3];	arg2	<=	fp2;				end
		22:y[gp0][gp3]	<=	fp_div;
		23:gp3	<=	gp3+1;
		24:ip		<=	gp3<18?ip-4:ip;
		25:gp0	<=	1;
		26:gp1	<=	0;
		27:fp2	<=	y[gp1][gp0];
		28:gp3	<=	gp1;
		29:begin								arg1	<=	fp2;				arg2	<=	y[gp0][gp3];	end
		30:begin								arg1	<=	y[gp1][gp3];	arg2	<=	fp_mult;			end
		31:y[gp1][gp3]	<=	fp_sub;
		32:gp3	<=	gp3+1;
		33:ip		<=	gp3<18?ip-5:ip;
		34:gp1	<=	gp1+1;
		35:ip		<=	gp1<0?ip-9:ip;
		36:gp0	<=	gp0+1;
		37:ip		<=	gp0<9?ip-12:ip;
		endcase
	end else if (count==1)
		ip	<= ip+1;
end

endmodule
	