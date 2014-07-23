module MaskGen(xmap,dist,mask);
	input[5:0] xmap;
	input [1:0] dist;
	output [63:0] mask;
	reg [63:0] mask1;
	assign mask = mask1;
	always@(xmap or dist) begin
		case(xmap)
		6'd0: mask1 = {62'd0, dist[1], dist[0]};
		6'd2: mask1 = {60'd0, dist[1], dist[0], 2'd0};
		6'd4: mask1 = {58'd0, dist[1], dist[0], 4'd0};
		6'd6: mask1 = {56'd0, dist[1], dist[0], 6'd0};
		6'd8: mask1 = {54'd0, dist[1], dist[0], 8'd0};
		6'd10: mask1 = {52'd0, dist[1], dist[0], 10'd0};
		6'd12: mask1 = {50'd0, dist[1], dist[0], 12'd0};
		6'd14: mask1 = {48'd0, dist[1], dist[0], 14'd0};
		6'd16: mask1 = {46'd0, dist[1], dist[0], 16'd0};
		6'd18: mask1 = {44'd0, dist[1], dist[0], 18'd0};
		6'd20: mask1 = {42'd0, dist[1], dist[0], 20'd0};
		6'd22: mask1 = {40'd0, dist[1], dist[0], 22'd0};
		6'd24: mask1 = {38'd0, dist[1], dist[0], 24'd0};
		6'd26: mask1 = {36'd0, dist[1], dist[0], 26'd0};
		6'd28: mask1 = {34'd0, dist[1], dist[0], 28'd0};
		6'd30: mask1 = {32'd0, dist[1], dist[0], 30'd0};
		6'd32: mask1 = {30'd0, dist[1], dist[0], 32'd0};
		6'd34: mask1 = {28'd0, dist[1], dist[0], 34'd0};
		6'd36: mask1 = {26'd0, dist[1], dist[0], 36'd0};
		6'd38: mask1 = {24'd0, dist[1], dist[0], 38'd0};
		6'd40: mask1 = {22'd0, dist[1], dist[0], 40'd0};
		6'd42: mask1 = {20'd0, dist[1], dist[0], 42'd0};
		6'd44: mask1 = {18'd0, dist[1], dist[0], 44'd0};
		6'd46: mask1 = {16'd0, dist[1], dist[0], 46'd0};
		6'd48: mask1 = {14'd0, dist[1], dist[0], 48'd0};
		6'd50: mask1 = {12'd0, dist[1], dist[0], 50'd0};
		6'd52: mask1 = {10'd0, dist[1], dist[0], 52'd0};
		6'd54: mask1 = {8'd0, dist[1], dist[0], 54'd0};
		6'd56: mask1 = {6'd0, dist[1], dist[0], 56'd0};
		6'd58: mask1 = {4'd0, dist[1], dist[0], 58'd0};
		6'd60: mask1 = {2'd0, dist[1], dist[0], 60'd0};
		6'd62: mask1 = {dist[1], dist[0], 62'd0};
		default: mask1 = 64'd0;	
		endcase
	end
endmodule	  