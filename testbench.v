`timescale 1ps / 1ps
module testbench;

integer i;
reg	clk = 0;
reg	[12:0]	 x=0,y=0;


initial begin
	for(i=0;i<64000;i=i+1) begin
		clk=~clk;
		if(clk) begin
			x = x<792 ? x+1 : 0;
			y = x<792 ? y	 : y<525?y+1:0;
		end
		#1;
	end
	$finish;
end
 
RECTIFY rectifier(
	.clk(clk),
	.a(ix^iy),
	.b(~ix^iy),
	.ix({19'd0,x}),
	.iy({19'd0,y})
);

endmodule
