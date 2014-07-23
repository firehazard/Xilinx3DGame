`define EIDLE 3'b000
`define EIDLE_2 3'b111
`define EDGE_1 3'b001 //LEFT EDGE
`define EDGE_2 3'b010 //RIGHT EDGE
`define EDGE_3 3'b011 //TOP EDGE
`define EDGE_4 3'b100 //BOTTOM EDGE


module EdgeCalculator(clock,reset,enable,donedge,xcenter,ycenter,depth,donesquare,xstart,xend,
			   ystart,yend,etype);

	input clock,reset, enable,donedge;
	input [8:0] xcenter,ycenter;
	input [5:0] depth;
	output donesquare;
	
	output [2:0] etype; //001 - vertical            010-horizontal            1xx - invalid 
	output[6:0] xstart,xend;
	output[5:0] ystart,yend;
//new stuff
	
//	wire [2:0] next_etype;
	wire [6:0] next_xstart, next_xend;
	wire [5:0] next_ystart, next_yend;


	
	wire[8:0] xs,xe,xstemp,xetemp;
	wire[8:0] ys,ye,ystemp,yetemp;//we need 9 bits... 8 bits for all possible values, 1 for sign
	
	wire[5:0] D=6'd63-depth;
	
	wire [2:0] state,next_state;
	reg [2:0] next_state1;

//pipeline
 //	DFF #(3) etype_reg(.clk(clock),.en(1'b1),.in(next_etype),.out(etype));
	DFF #(7) xstart_reg(.clk(clock),.en(1'b1),.in(next_xstart),.out(xstart));
	DFF #(7) xend_reg(.clk(clock),.en(1'b1),.in(next_xend),.out(xend));
	DFF #(6) ystart_reg(.clk(clock),.en(1'b1),.in(next_ystart),.out(ystart));
	DFF #(6) yend_reg(.clk(clock),.en(1'b1),.in(next_yend),.out(yend));

	assign etype[0] = ( (state==`EDGE_1) | (state==`EDGE_2) );
	assign etype[1] = ( (state==`EDGE_3) | (state==`EDGE_4) );
	assign etype[2]  =((xs[8]&xe[8])| //start and end are negative (1=invalid)
				    (ys[8]&ye[8])| //start and end are negative
					(xs[7]& ~xs[8])| //start is greater than max value
					((ys[6]|ys[7])&~ys[8])); //start is greater than max value



	assign next_state = reset? `EIDLE:next_state1;

	DFF #(3) state_reg(.clk(clock),.en(enable|reset),.in(next_state),.out(state));

	always@(state or donedge or enable) //we had edgevalid in here once upon a time
	begin
		case(state)
		`EIDLE: next_state1 = enable? `EIDLE_2:`EIDLE;
		`EIDLE_2: next_state1 = enable? `EDGE_1: `EIDLE;
		`EDGE_1: next_state1 = donedge? `EDGE_2:`EDGE_1;
		`EDGE_2: next_state1 = donedge? `EDGE_3:`EDGE_2;
		`EDGE_3: next_state1 = donedge? `EDGE_4:`EDGE_3;
		`EDGE_4: next_state1 = donedge? `EIDLE:`EDGE_4;
		default: next_state1 =  `EIDLE;
		endcase
	end	 

    // assign xstart,xend,ystart,yend,etype go to flip flop.

	assign donesquare = (state==`EDGE_4) & donedge; 
		
	assign xstemp = xcenter-D;
	assign xetemp = (D==6'd0)? xcenter+D:xcenter+(D-1);
	assign ystemp = ycenter-D;
	assign yetemp = (D==6'd0)? ycenter+D:ycenter+(D-1);

	assign {xs,xe,ys,ye}=(state==`EDGE_1)?{xstemp,xstemp,ystemp,yetemp}:
				  	 (state==`EDGE_2)?{xetemp,xetemp,ystemp,yetemp}:
				      (state==`EDGE_3)?{xstemp,xetemp,ystemp,ystemp}:
				  	 (state==`EDGE_4)?{xstemp,xetemp,yetemp,yetemp}:{9'd0,9'd0,9'd0,9'd0};
 	
	assign next_xstart =  xs[8]? 7'd0:xs[6:0];
	assign next_xend   = (xe[7]&~xe[8])? 7'd127:xe[6:0];
	assign next_ystart =  ys[8]? 6'd0:ys[5:0];
	assign next_yend   =  ((ye[6]|ye[7])&~ye[8])? 6'd63:ye[5:0];
	 

endmodule