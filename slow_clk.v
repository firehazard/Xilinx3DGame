module slow_clk(clk,reset,slow_clk);
   parameter n = 1;
   input clk, reset;
   output slow_clk;
   wire temp_clk;
   wire[n-1:0] count;
   counter #(n) ck1(.clk(clk),.rst(reset),.en(1'b1),.count(count));
   assign temp_clk = (count[n-1]==1);
   edge_detect ed1 (.clk(clk),.in(temp_clk),.out(slow_clk));
endmodule