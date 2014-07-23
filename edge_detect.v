// This module receives an input "in" and
// turns it into a single cycle pulse. 
// This means that "out" goes high in the same
// cycle as "in" and falls one cycle later. 
// One pulse is generated per rise of "in".
module edge_detect(clk, in, out);

	input clk;
	input in;
	output out;

	wire in_reg;

	DFF dff1(.clk(clk), .en(1'b1), .in(in), .out(in_reg));

	// "out" is high only if "in" wasn't
	// high in the previous cycle.
	assign out = in & (~in_reg);

endmodule