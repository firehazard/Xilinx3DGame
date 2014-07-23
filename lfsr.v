// Linear Feedback Shift Register
// Generates one new "random" bit (the MSB)
// in each cycle that shift is enabled.
//
/*
module LFSR (clk, rst, shift_enable, count);

  input clk, rst, shift_enable ;
  output [31:0] count ;
  wire feedback ;
  wire [31:0] next_count, count ;

  assign feedback = ((count[22] ^ count[2]) ^ (count[1] ^ count[0])) ^              
                    ~(|count[31:1]) ;
  assign next_count = rst ? 32'b10110110100010110010101001011101 : 
                           {feedback, count[31:1]} ;

  DFF #(32) rand_reg(clk, shift_enable, next_count, count) ;
endmodule
*/



module LFSR (clk, rst, shift_enable, count); 
 input clk, rst, shift_enable ; 
 output [10:0] count ; 
 wire feedback ; 
 wire [10:0] next_count, count ; 

 assign feedback = ((count[7] ^ count[2]) ^ (count[1] ^ count[0])) ^               
                   ~(|count[10:1]) ; 
 assign next_count = rst ? 11'b01001011101: 
                          {feedback, count[10:1]} ; 
 DFF #(11) rand_reg(clk, shift_enable, next_count, count) ; 

endmodule