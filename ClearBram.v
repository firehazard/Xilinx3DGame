module ClearBram(clock,reset,enable,doneclear,bramdata);
	input clock,reset,enable;
	output doneclear;
	output [14:0] bramdata;
	wire [12:0] address;
	assign bramdata = {address,2'd0};
	counter #(13) clear_counter(.clk(clock),.rst(reset),.en(enable|reset),.count(address));
	assign doneclear=&address;
endmodule