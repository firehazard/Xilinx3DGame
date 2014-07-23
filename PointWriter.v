module PointWriter(clock,reset,xstart,xend,ystart,yend,etype,done_point,xval,yval,donedge,pvalid);
   	input clock,reset,done_point;
	input [6:0] xstart,xend;
	input [5:0] ystart,yend;
	input [2:0] etype;

	output donedge,pvalid;
	output[7:0] xval; //8 bits because we are multiplying by 2
	output[5:0] yval;
 
 	reg[7:0] xval1;
 	reg[5:0] yval1; 

    	wire[6:0] countx; 
	wire[5:0] county;
	//take out donedge // and etype[1] with everything else //take donedge out //take reset out  //take out etype 2 too
	wire enablex = ((etype[1])&(~etype[2])&(~pvalid)&(~donedge))|reset|(done_point&(etype[1])&(~etype[2]));      	
	wire enabley = ((etype[0])&(~etype[2])&(~pvalid)&(~donedge))|reset|(done_point&(etype[0])&(~etype[2]));
	
	
	//load the counters with xstart or ystart
	//change reset to reset | edgedectect (etype[2]);	  //xval and yval are simply the values of the counter

	counter #(7) x_counter(.clk(clock),.rst(reset|donedge),.en(enablex),.count(countx));
	counter #(6) y_counter(.clk(clock),.rst(reset|donedge),.en(enabley),.count(county));

	//what value do we send out to the mapper in case we don't want to write anything?

	always @ (countx or county or etype or xstart or xend or ystart or yend)
	 begin
      case(etype) // only check last two bits of etype
      3'b010: begin 
	 		xval1 = ((countx>=xstart) & (countx<=xend))? {countx,1'b0}:8'd0;
       		yval1 = ystart;
			end
      3'b001: begin
	 		xval1 = {xstart,1'b0}; 
       		yval1 = ((county>=ystart) & (county<=yend))? county:6'd0;
			end
      default: begin
	 		xval1 = 8'd0;
        		yval1 = 6'd0;		 
			end          
      endcase
     end	
											 
	assign xval= xval1;
	assign yval= yval1;
											  //take etype[2] out
	assign donedge = (countx==7'd127) | (county==6'd63) | etype[2]; //done when we reach the last value of x and y   & donedge
	assign pvalid = ((((countx>=xstart) & (countx<=xend)) | ((county>=ystart) & (county<=yend))))&
	 			  ((etype[1]|etype[0])&(~etype[2]));
	//assign pvalid = check valid ranges (AND) and take out etype[1:0] //change or to and
endmodule