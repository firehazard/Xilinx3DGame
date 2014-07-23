module square_unit(clock,cruiserx,cruisery, reset,rvalue,enable,up,down,left,right,xcenter,ycenter,depth,random);
	input clock, reset, enable,up,down,left,right;
	input [6:0] cruiserx, cruisery;
	input [12:0] rvalue;
	input [7:0] random;
	output [8:0] xcenter,ycenter;
	output[5:0] depth;
		

	wire [12:0] depth1;
	
	
	wire[12:0] next_depth;
	wire[12:0] grate,ngrate;  	
	
	wire [13:0] xcenter1,ycenter1;
	wire [6:0] xctemp, yctemp;

	wire[13:0] next_cx,next_cy;
	reg [13:0] next_cx1, next_cy1;
	
	wire restart=(depth==6'd63);
		
	assign next_depth = reset? rvalue:(depth1>13'b1111110000000)? 13'b1111110000000:(depth1-grate);
	assign depth = depth1[12:7];
	
	assign xctemp = xcenter1[13:7];
	assign yctemp = ycenter1[13:7];
	
	Growth_LUT g1(.depth(depth1),.grate(grate));
	Growth_LUT g2(.depth((13'd63)-depth1),.grate(ngrate));
	
	assign next_cx = reset? {7'd63,{7{1'b0}}}:restart? xcenter1+{random[3:0],{7{1'b0}}}:next_cx1;
	assign next_cy = reset? {7'd63,{7{1'b0}}}:restart? ycenter1+{random[7:4],{7{1'b0}}}:next_cy1; 

//	assign next_cx = (reset|restart)? {7'd63/*random[6:0]*/,{7{1'b0}}}:next_cx1;
//	assign next_cy = (reset|restart)? {7'd63/*random[13:7]*/,{7{1'b0}}}:next_cy1;
	
	DFF #(13) depthr(.in(next_depth),.en(enable|reset),.clk(clock),.out(depth1)); //change to DFF
	DFF #(14) xcenter_reg(.in(next_cx),.en(enable|reset),.clk(clock),.out(xcenter1));
	DFF #(14) ycenter_reg(.in(next_cy),.en(enable|reset),.clk(clock),.out(ycenter1));
	
	CoordTrans trans1(.cruiserx(cruiserx),.cruisery(cruisery),.absquarex(xctemp),.absquarey(yctemp),
				   .squarex(xcenter),.squarey(ycenter));
				   
	always@(left or right or xcenter1 or ngrate)
	   begin
		if (right==1'b1 & xcenter1[13:7]>7'd0)
		next_cx1 = xcenter1-{1'b0,ngrate};
		else if(left==1'b1 & xcenter1[13:7]<7'd127)
		next_cx1 = xcenter1+{1'b0,ngrate};
		else next_cx1 = xcenter1;
	   end
	
	always@(up or down or ycenter1 or ngrate)
	   begin
		if (down==1'b1 & ycenter1[13:7]>7'd0)
		next_cy1 = ycenter1-{1'b0,ngrate};
		else if(up==1'b1 & ycenter1[13:7]<7'd127)
		next_cy1 = ycenter1+{1'b0,ngrate};
		else next_cy1 = ycenter1;
	   end
endmodule