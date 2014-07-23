`define READ 		2'b00
`define GET 		2'b01
`define UPDATE 	2'b10
`define REWRITE	2'b11

`define NORMAL 1'b0
`define FAST 1'b1

module Tunnel(clk,rst,enable,speed,oldata,up1,down1,left1,right1,ymap,topready,bramdata,ewrite,score1,score2,score3,crashed,arrow,apilot,mult);
	input clk,rst,enable,up1,down1,left1,right1,topready,speed,apilot;
	input [1:0] oldata;
	output [3:0] arrow;
	output ewrite;
	output [14:0] bramdata;
	output [12:0] ymap;	
	output [3:0] score1,score2,score3;
	output crashed, mult;

	wire [1:0] new_data; //tempdata;
	wire [1:0] dist;
	wire [10:0] random;
	
	wire up,down,left,right;
	wire [8:0] xc1,xc2,xc3,xc4,yc1,yc2,yc3,yc4; 
	wire [5:0] d1,d2,d3,d4;
	wire donesquare,doneclear;
		
	wire [14:0] cleardata,sdata;
    	
	wire enedge,clear,pvalid;
    	wire [6:0] cruiserx,cruisery;
    	wire [8:0] xcenter,ycenter;
	wire [5:0] depth;					   
    	wire [6:0] xstart, xend; //edge limits
	wire [5:0] ystart, yend; //edge limits
	wire [2:0] etype;       // edge type
    	wire [7:0] xval;
	wire [5:0] yval;  
	wire donedge,done_point;

	wire [1:0] state,next_state;	
	reg [1:0] next_state1;
	
	
	//SLOW CLOCK
   	wire slowclk,normalclk,fastclk;
	wire clkstate;
	wire nextclkstate;
	reg nextclk1;
	reg slowclk1;

		
	assign mult = (clkstate==`FAST);

	assign slowclk = slowclk1;
		
	assign nextclkstate = rst? `NORMAL:nextclk1; 

	DFF #(1) clkstate_reg (.clk(clk),.en(1'b1),.in(nextclkstate),.out(clkstate));
	
	always @ (clkstate or speed or normalclk or fastclk) begin
		case (clkstate)
		`NORMAL: begin
			  slowclk1=normalclk;
			  nextclk1=speed? `FAST: `NORMAL;
			  end
		`FAST: begin
			  slowclk1=fastclk;
			  nextclk1=speed? `NORMAL: `FAST;
			  end
		default: begin
			  slowclk1=normalclk;
			  nextclk1=`NORMAL;
			  end
	     endcase
	end
			  	
	
	slow_clk #(19) slowmedown(.clk(clk),.reset(rst),.slow_clk(normalclk));
	slow_clk #(16) alilfaster(.clk(clk),.reset(rst),.slow_clk(fastclk));	


	wire flipenable = (state==`GET);  	

	assign next_state = rst? `READ: next_state1;
	
	assign ewrite = ((state==`UPDATE) | (state==`REWRITE)) | clear;
		
	DFF #(2) buffer(.clk(clk),.en(flipenable|rst),.in(oldata),.out(new_data));

	DFF #(2) state_reg(.clk(clk),.en(enable|rst),.in(next_state),.out(state));

//score 
	wire next_scored, scored,next_crashed;
	reg scored1,crashed1;

	wire go = ~crashed;
 	
 	assign next_scored = rst? 1'b0:scored1;
	assign next_crashed = rst? 1'b0:crashed1;
	 
	
	DFF #(1) score_reg (.clk(clk),.en(1'b1),.in(next_scored),.out(scored));
	DFF #(1) crashed_reg (.clk(clk),.en(1'b1),.in(next_crashed),.out(crashed));   
   	
	counter #(4) score1count(.clk(clk),.rst(rst|(score1==4'd10)),.en(enscore),.count(score1));
	counter #(4) score2count(.clk(clk),.rst(rst|(score2==4'd10)),.en(score1==4'd10),.count(score2));
	counter #(4) score3count(.clk(clk),.rst(rst|(score3==4'd10)),.en(score2==4'd10),.count(score3));
	
	wire next_atscreen,atscreen;
	wire sq1,sq2,sq3,sq4;
	wire next_sq1, next_sq2,next_sq3,next_sq4;


	assign next_sq1 = ( (xc1[8:7]==2'b00)& (d1==6'd0)&(yc1[8:5]==4'b1111 | (yc1>=9'd0 & yc1<9'd94)) ); 
	assign next_sq2 = ( (xc2[8:7]==2'b00)&(d2==6'd0)&(yc2[8:5]==4'b1111 | (yc2>=9'd0 & yc2<9'd94)) ); 
	assign next_sq3 = ( (xc3[8:7]==2'b00)&(d3==6'd0)&(yc3[8:5]==4'b1111 | (yc3>=9'd0 & yc3<9'd94)) ); 
	assign next_sq4 = ( (xc4[8:7]==2'b00)&(d4==6'd0)&(yc4[8:5]==4'b1111 | (yc4>=9'd0 & yc4<9'd94)) );

	assign next_atscreen = (d1==6'd0) | (d2==6'd0) | (d3==6'd0) | (d4==6'd0);

	DFF #(1) sq1_reg(.clk(clk),.en(1'b1),.in(next_sq1),.out(sq1));
	DFF #(1) sq2_reg(.clk(clk),.en(1'b1),.in(next_sq2),.out(sq2));
	DFF #(1) sq3_reg(.clk(clk),.en(1'b1),.in(next_sq3),.out(sq3));
	DFF #(1) sq4_reg(.clk(clk),.en(1'b1),.in(next_sq4),.out(sq4));
	DFF #(1) scre_reg(.clk(clk),.en(1'b1),.in(next_atscreen),.out(atscreen));

	edge_detect edgemebaby(.clk(clk),.in(scored),.out(enscore));

     always@(atscreen or sq1 or sq2 or sq3 or sq4) begin
		if (sq1 | sq2 |sq3 | sq4) begin
					scored1 = 1'b1;
					crashed1 = 1'b0;
					end
		else if (atscreen) begin
				scored1=1'b0;
				crashed1=1'b1;
				end
	     else begin
			scored1=1'b0;
			crashed1=1'b0;
		end
	end

	 wire [8:0] xout, yout;
	 

	 depthcomp pantudepth(.d1(d1),.d2(d2),.d3(d3),.xc1(xc1),.xc2(xc2),.xc3(xc3),.xc4(xc4),
	 				  .yc1(yc1),.yc2(yc2),.yc3(yc3),.yc4(yc4),.xout(xout),.yout(yout));


	assign arrow[0] = (yout[8] | (yout[8:4]==5'b00000));
	assign arrow[1] = (~yout[8] & (yout[7:4]>4'b0010));
	assign arrow[2] = (xout[8] | (xout<9'd48));
	assign arrow[3] = (~xout[8] & (xout>9'd80));
	
	assign {up,down,left,right} = apilot? {arrow[0],arrow[1],arrow[2],arrow[3]}:{up1,down1,left1,right1};
		
	always @(state or pvalid) begin
		case(state)
		 `READ: next_state1    =   pvalid? `GET:`READ; 
		 `GET:  next_state1    =  `UPDATE;
		 `UPDATE: next_state1  =	 `REWRITE;
		 `REWRITE: next_state1 =  `READ;
		 default: next_state1 = `READ;
	   	endcase
	end


	
    assign done_point = (state==`REWRITE);

	
// Four Squares UPDATERS     
    	square_unit square1(.clock(clk),.reset(rst),.enable(enable&slowclk&(~enedge)&go),.rvalue(13'b1111110000000),
				.left(left),.right(right),.up(up),.down(down),.xcenter(xc1),.ycenter(yc1),.depth(d1),
				.random(random[7:0]),.cruiserx(cruiserx),.cruisery(cruisery));
	square_unit square2(.clock(clk),.reset(rst),.enable(enable&slowclk&(~enedge)&go),.rvalue(13'b1111010010101),
				.left(left),.right(right),.up(up),.down(down),.xcenter(xc2),.ycenter(yc2),.depth(d2),
				.random(random[10:3]),.cruiserx(cruiserx),.cruisery(cruisery));
	square_unit square3(.clock(clk),.reset(rst),.enable(enable&slowclk&(~enedge)&go),.rvalue(13'b1110000000000),
				.left(left),.right(right),.up(up),.down(down),.xcenter(xc3),.ycenter(yc3),.depth(d3),
				.random(random[9:2]),.cruiserx(cruiserx),.cruisery(cruisery));
	square_unit square4(.clock(clk),.reset(rst),.enable(enable&slowclk&(~enedge)&go),.rvalue(13'b1010010101111),
				.left(left),.right(right),.up(up),.down(down),.xcenter(xc4),.ycenter(yc4),.depth(d4),
				.random(random[8:1]),.cruiserx(cruiserx),.cruisery(cruisery));
  
    ClearBram cleaning(.clock(clk),.reset(rst),.enable(clear),.doneclear(doneclear),.bramdata(cleardata));
       
    CruiserView cview(.clock(clk),.reset(rst),.enable(enable&slowclk&(~enedge)&go),.up(up),.down(down),.left(left),
    			 .right(right),.cruiserx(cruiserx),.cruisery(cruisery));

  
    SquareWriter swriter(.clock(clk),.reset(rst),.enable(enable),.xc1(xc1),.xc2(xc2),.xc3(xc3),.xc4(xc4),
    			  .yc1(yc1),.yc2(yc2),.yc3(yc3),.yc4(yc4),.d1(d1),.d2(d2),.d3(d3),.d4(d4),.topready(topready),.donesquare(donesquare),
			  .doneclear(doneclear),.xcenter(xcenter),.ycenter(ycenter),.depth(depth),
			  .enedge(enedge),.clear(clear));
	
	EdgeCalculator edgecalc(.clock(clk),.reset(rst),.enable(enedge),.donedge(donedge),
				.xcenter(xcenter),.ycenter(ycenter),.depth(depth),.donesquare(donesquare),
				.xstart(xstart),.xend(xend),.ystart(ystart),.yend(yend),.etype(etype));

	PointWriter pointwriter(.clock(clk),.reset(rst),.xstart(xstart),.xend(xend),
					    .ystart(ystart),.yend(yend),.etype(etype),.done_point(done_point),
					    .xval(xval),.yval(yval),.donedge(donedge),.pvalid(pvalid));
	


	LFSR PantuRandom (.clk(clk),.rst(1'b0),.shift_enable(1'b1),.count(random));
	
	wire [1:0] sqdepth;
	reg [1:0] sqdepth1;
	assign sqdepth=sqdepth1;
	
	always @ (depth) begin
	      if (depth > 6'd60) sqdepth1=2'b01;
      	 else if (depth > 6'd49) sqdepth1=2'b10;
	 	 else sqdepth1=2'b11;
	end
	
	assign dist = (pvalid&(new_data>sqdepth))? new_data:sqdepth;
		
	assign ymap = {xval[7:1],yval};

    	assign bramdata = clear? cleardata:sdata;

	assign sdata = {ymap,dist};

endmodule