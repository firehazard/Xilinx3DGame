`define IDLE     3'b000
`define CLEAR	  3'b001
`define SQUARE_1 3'b010
`define SQUARE_2 3'b011
`define SQUARE_3 3'b100
`define SQUARE_4 3'b101

module SquareWriter(clock,reset,enable,xc1,xc2,xc3,xc4,yc1,yc2,yc3,yc4,d1,d2,d3,d4,topready,donesquare,doneclear,xcenter,ycenter,depth,enedge,clear);

    	input clock,reset,enable,topready,donesquare,doneclear;
	input [8:0] xc1,xc2,xc3,xc4,yc1,yc2,yc3,yc4; 
	input [5:0] d1,d2,d3,d4;
//	input [6:0] cruiserx,cruisery;
	
	output [8:0] xcenter,ycenter;
	output [5:0] depth;
	output clear,enedge;

//new stuff
	wire [8:0] next_xcenter, next_ycenter;
	wire [5:0] next_depth;
	wire next_enedge;

	
	DFF #(9) x_reg(.clk(clock),.en(1'b1),.in(next_xcenter),.out(xcenter));
	DFF #(9) y_reg(.clk(clock),.en(1'b1),.in(next_ycenter),.out(ycenter));
	DFF #(6) depth_reg(.clk(clock),.en(1'b1),.in(next_depth),.out(depth));
	DFF #(1) enedge_reg(.clk(clock),.en(1'b1),.in(next_enedge),.out(enedge));

/*	
	wire[8:0] tempsx1,tempsy1,tempsx2,tempsy2,tempsx3,tempsy3,tempsx4,tempsy4;
	CoordTrans trans1(.cruiserx(cruiserx),.cruisery(cruisery),.absquarex(xc1),.absquarey(yc1),
				   .squarex(tempsx1),.squarey(tempsy1));
	CoordTrans trans2(.cruiserx(cruiserx),.cruisery(cruisery),.absquarex(xc2),.absquarey(yc2),
				   .squarex(tempsx2),.squarey(tempsy2));
	CoordTrans trans3(.cruiserx(cruiserx),.cruisery(cruisery),.absquarex(xc3),.absquarey(yc3),
				   .squarex(tempsx3),.squarey(tempsy3));
	CoordTrans trans4(.cruiserx(cruiserx),.cruisery(cruisery),.absquarex(xc4),.absquarey(yc4),
				   .squarex(tempsx4),.squarey(tempsy4));
*/

	wire[2:0] state, next_state;
	reg [2:0] next_state1;
	
	assign next_state = reset? 3'b000: next_state1; 
	
	
	always@(state or donesquare or doneclear or topready)
	begin
		case(state)
			`IDLE: next_state1 = topready? `CLEAR:`IDLE;
			`CLEAR: next_state1 = doneclear? `SQUARE_1:`CLEAR;
			`SQUARE_1: next_state1 = donesquare? `SQUARE_2:`SQUARE_1;
			`SQUARE_2: next_state1 = donesquare? `SQUARE_3:`SQUARE_2;
			`SQUARE_3: next_state1 = donesquare? `SQUARE_4:`SQUARE_3;
			`SQUARE_4: next_state1 = donesquare? `IDLE:`SQUARE_4;
			default: next_state1=`IDLE;
		endcase
	end


	DFF #(3) state_reg(.clk(clock),.en(enable),.in(next_state),.out(state));

//assign DFF to xcenter, ycenter, depth, and enedge, before sending out
	

	
	assign clear= (state==`CLEAR);//might have to change
	assign next_enedge = ( (state==`SQUARE_1) | (state==`SQUARE_2) |	(state==`SQUARE_3) | (state==`SQUARE_4));
	//use enedge and and this with the slowclk

	assign {next_xcenter,next_ycenter,next_depth}=(state==`SQUARE_1)?{xc1,yc1,d1}:
				  					      (state==`SQUARE_2)?{xc2,yc2,d2}:
				      		 			 (state==`SQUARE_3)?{xc3,yc3,d3}:
				  	 		 			 (state==`SQUARE_4)?{xc4,yc4,d4}:{9'd0,9'd0,6'd0};

endmodule