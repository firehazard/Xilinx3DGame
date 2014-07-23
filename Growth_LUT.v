module Growth_LUT(depth,grate);
	input[12:0] depth;
	output[12:0] grate;
	reg[6:0] grate1;
	assign grate = {{6{1'b0}},grate1};
	always @ (depth)
 	  begin
        	if (depth<=13'b1111110000000 & depth>13'b1111101011010)
	 	   grate1 = 7'b0000010; 
	  else if (depth<=13'b1111101011010 & depth>13'b1111100101000)
		   grate1 = 7'b0000011;
          else if (depth<=13'b1111100101000 & depth>13'b1111011101000)
		   grate1 = 7'b0000100;
          else if (depth<=13'b1111011101000 & depth>13'b1111010010101)
		   grate1 = 7'b0000101;
          else if (depth<=13'b1111010010101 & depth>13'b1111000101010)
		   grate1 = 7'b0000111;
          else if (depth<=13'b1111000101010 & depth>13'b1110110011111)
		   grate1 = 7'b0001001;
          else if (depth<=13'b1110110011111 & depth>13'b1110011101010)
		   grate1 = 7'b0001100;
          else if (depth<=13'b1110011101010 & depth>13'b1110000000000)
		   grate1 = 7'b0010000;
          else if (depth<=13'b1110000000000 & depth>13'b1101011001000)
		   grate1 = 7'b0010100;
          else if (depth<=13'b1101011001000 & depth>13'b1100101000010)
		   grate1 = 7'b0011010;
	  else if (depth<=13'b1100101000010 & depth>13'b1011101000110)
		   grate1 = 7'b0100010;
	  else if (depth<=13'b1011101000110 & depth>13'b1010010101111)
		   grate1 = 7'b0101101;
	  else if (depth<=13'b1010010101111 & depth>13'b1000101010011)
		   grate1 = 7'b0111010;
  	  else if (depth<=13'b1000101010011 & depth>13'b0110011111001)
		   grate1 = 7'b1001100;
	  else if (depth<=13'b0110011111001 & depth>13'b0011101010011)
		   grate1 = 7'b1100010;
	  else if (depth<=13'b0011101010011 & depth>13'b0000000000000)
		   grate1 = 7'b1111111;
	  else grate1 = 7'b0000010;
	end	 
endmodule