// This implementation supports a 50MHz clock
// 
// 
// CounterX[10:0] - current pixel's Xposition. [0...1287]
// CounterY[9:0]  - current pixel's Yposition. [0...479 ]
// Valid 		- asserted when visible rectangle is being drawn.
module sync_gen50 (clk,CounterX, CounterY, Valid, vga_h_sync, vga_v_sync);
	input clk;
	output Valid, vga_h_sync, vga_v_sync;
	output [9:0] CounterY;
	output [10:0] CounterX;
        
	reg [9:0] CounterY;
	reg [10:0] CounterX;
    	reg ResetCntX, EnableCntY, ResetCntY;
	reg Valid, vga_h_sync, vga_v_sync;    

//Counters
always @ (posedge clk) begin
	if (ResetCntX) CounterX[10:0] <= 11'b0;
	else CounterX[10:0] <= CounterX[10:0] + 1;

	if (ResetCntY) CounterY[9:0] <= 10'b0;
	else if (EnableCntY) CounterY[9:0] <= CounterY + 1;
	else CounterY[9:0] <= CounterY[9:0];	
end

//Synchronizer controller    
always @(posedge clk )
        	begin	
                	ResetCntX 	<= (CounterX[10:0] ==1586); // was 381 was 798
                	EnableCntY 	<= (CounterX[10:0] == 1300); // was 39 was 25
               	ResetCntY 	<= (CounterY[9:0] ==527);
		end

//signal synchronizer
always @(posedge clk)
	begin
		vga_h_sync 	<= ~((CounterX[10:0] >= 1304) && (CounterX[10:0] <= 1493));
		vga_v_sync 	<= ~((CounterY[9:0] == 493)  	|| (CounterY[9:0]  == 494 ));
		Valid 	<=  (((CounterX == 1587) 	|| (CounterX < 1288)) &&
                		     ((CounterY ==  527) 	|| (CounterY < 480 )) );
	end
endmodule 