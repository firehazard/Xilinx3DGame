module vgamask(clock,reset,enable,X,vga_data,two_bit);
	input clock,reset,enable;
	input [10:0] X;
	input [63:0] vga_data;
	output [1:0] two_bit;
 	wire next_two;
	reg [1:0] two_bit1;
	assign next_two=reset? 2'b00:two_bit1;
	DFF #(1) tworeg(.clk(clock),.en(enable),.in(next_two),.out(two_bit));
  
   always@(X or vga_data) 
 	begin
	case (X[6:2])
	5'd0: two_bit1=vga_data[63:62];
	5'd1: two_bit1=vga_data[61:60];
	5'd2: two_bit1=vga_data[59:58];
	5'd3: two_bit1=vga_data[57:56];
	5'd4: two_bit1=vga_data[55:54];
	5'd5: two_bit1=vga_data[53:52];
	5'd6: two_bit1=vga_data[51:50];
	5'd7: two_bit1=vga_data[49:48];
	5'd8: two_bit1=vga_data[47:46];
	5'd9: two_bit1=vga_data[45:44];
	5'd10: two_bit1=vga_data[43:42];
	5'd11: two_bit1=vga_data[41:40];
	5'd12: two_bit1=vga_data[39:38];
	5'd13: two_bit1=vga_data[37:36];
	5'd14: two_bit1=vga_data[35:34];
	5'd15: two_bit1=vga_data[33:32];
	5'd16: two_bit1=vga_data[31:30];
	5'd17: two_bit1=vga_data[29:28];
	5'd18: two_bit1=vga_data[27:26];
	5'd19: two_bit1=vga_data[25:24];
	5'd20: two_bit1=vga_data[23:22];
	5'd21: two_bit1=vga_data[21:20];
	5'd22: two_bit1=vga_data[19:18];
	5'd23: two_bit1=vga_data[17:16];
	5'd24: two_bit1=vga_data[15:14];
	5'd25: two_bit1=vga_data[13:12];
	5'd26: two_bit1=vga_data[11:10];
	5'd27: two_bit1=vga_data[9:8];
	5'd28: two_bit1=vga_data[7:6];
	5'd29: two_bit1=vga_data[5:4];
	5'd30: two_bit1=vga_data[3:2];
	5'd31: two_bit1=vga_data[1:0]; 
     default: two_bit1=2'b00;
    endcase
  end

endmodule