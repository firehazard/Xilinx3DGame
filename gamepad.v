//------------------------------------------------------
// Debouncing module for inputs
//------------------------------------------------------

module Debounce(clk, rst, switch, deb_signal) ;

  input clk, rst, switch ;
  output deb_signal ;

  wire [9:0] count ;
  wire enable, enable_next, enable_next1, deb_signal_next, clear ;

  gCounter #(10) delay(clk, clear, clear|enable, count) ;
  
  assign deb_signal_next = rst ? 1'b0 : (count[9] & switch) ;
  
  assign clear = rst | (~switch & count[2]) ;
  assign enable_next1 = (~switch & ~deb_signal) ? enable : (switch & ~deb_signal) ;
  assign enable_next = rst ? 1'b0 : enable_next1 ;
  
  DFF #(1) deb_reg(clk, 1'b1, deb_signal_next, deb_signal);
  DFF #(1) enable_reg(clk, 1'b1, enable_next, enable);

endmodule

//------------------------------------------------------
// Gamepad interface
//------------------------------------------------------

module Gamepad(clk, rst, right_in, left_in, c_start, a_b, down_in, up_in, right_out, left_out, c_out, a_out, down_out, up_out) ;
  input clk, rst, right_in, left_in, c_start, a_b, down_in, up_in ;
  output right_out, left_out, c_out, a_out, down_out, up_out ;
  
  Debounce switch1(clk, rst, ~right_in, right_out) ;
  Debounce switch2(clk, rst, ~left_in, left_out) ;
  Debounce switch3(clk, rst, ~down_in, down_out) ;
  Debounce switch4(clk, rst, ~up_in, up_out) ;
  Debounce switch5(clk, rst, ~c_start, c_out) ;
  Debounce switch6(clk, rst, ~a_b, a_out) ;
endmodule  

//--------------------------------------
module gCounter (clk, rst, en, count);
  parameter n=3;
  input clk, rst, en;
  output [n-1:0] count;

  wire [n-1:0] next_count, count;

  DFF #(n) count_reg(clk, en, next_count, count);

  assign next_count = rst ? {n{1'b0}} : (count+1);

endmodule