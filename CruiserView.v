module CruiserView(clock,reset,enable,up,down,left,right,cruiserx,cruisery);
	input clock,reset,enable,up,down,left,right;
	output[6:0] cruiserx,cruisery;
	
	reg[6:0] next_x1,next_y1;

	wire [6:0] next_x = reset? 7'd64: next_x1;
 	wire [6:0] next_y = reset? 7'd64: next_y1; 
 
 	DFF #(7) x_reg(.clk(clock),.en(enable|reset),.in(next_x),.out(cruiserx)); 
	DFF #(7) y_reg(.clk(clock),.en(enable|reset),.in(next_y),.out(cruisery));

	always@(left or right or cruiserx)
	   begin
		if (right==1'b1 & cruiserx<7'd127)
		next_x1 = cruiserx+1;
		else if(left==1'b1 & cruiserx>7'd0)
		next_x1 = cruiserx-1;
		else next_x1 = cruiserx;
	   end

	always@(up or down or cruisery)
	   begin
		if (down==1'b1 & cruisery<7'd127)
		next_y1 = cruisery+1;
		else if(up==1'b1 & cruisery>7'd0)
		next_y1 = cruisery-1;
		else next_y1 = cruisery;
	   end	

endmodule