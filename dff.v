module DFF(clk, en, in, out);
  parameter n = 1 ;  // width
  input clk, en ;
  input [n-1:0] in ;
  output [n-1:0] out ;
  reg [n-1:0] out ;
  
  always @(posedge clk)
    if (en==1)
      out = in ;
endmodule