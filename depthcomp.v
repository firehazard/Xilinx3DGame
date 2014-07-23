module depthcomp(d1,d2,d3,xc1,xc2,xc3,xc4,yc1,yc2,yc3,yc4,xout,yout);
	input [5:0] d1,d2,d3; 
	input [8:0] xc1,xc2,xc3,xc4,yc1,yc2,yc3,yc4; 
	output [8:0] xout, yout; 
	
	reg [8:0] xreg, yreg; 

	always@(d1 or d2 or d3 or xc1 or xc2 or xc3 or xc4 or yc1 or yc2 or yc3 or yc4) begin 
		if(d1<6'd40) begin 
  			xreg = xc1; 
  			yreg = yc1; 
 		end 
    		else if(d2<6'd40) begin 
  			xreg = xc2; 
  			yreg = yc2; 
 		end 
    		else if(d3<6'd40) begin 
  			xreg = xc3; 
  			yreg = yc3; 
 		end 
    		else begin 
  			xreg = xc4; 
  			yreg = yc4; 
		end 
	end 

	assign xout = xreg; 
	assign yout = yreg; 

endmodule