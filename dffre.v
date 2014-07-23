// dffre: D flip-flop with active high enable and reset
// Parametrized width; default of 1
module dffre(d,en,r,clk,q);
	parameter WIDTH = 1;
	input en,r,clk;
	input [WIDTH-1:0] d;
	output [WIDTH-1:0] q;
	reg [WIDTH-1:0] q;
	always @ (posedge clk)
		if ( r )
			q <= {WIDTH{1'b0}};
		else if (en)
			q <= d;
		else q <= q;
endmodule