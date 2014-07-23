`define X_SHIFT 11'd132
`define Y_SHIFT 10'd112


module vga_cruiser_top(clock,resetn, right_in, down_in, left_in,up_in, vga_hsync , vga_vsync, vga_red0, vga_green0, vga_blue0, vga_red1, vga_green1, vga_blue1);
  
  input clock, resetn;
  input right_in,down_in,left_in,up_in;
   
  wire reset = ~resetn;
  // *** VGA OUTPUTS *** //
  output vga_hsync, vga_vsync; // sync signals for monitor
  output vga_red0, vga_green0, vga_blue0, vga_red1, vga_green1, vga_blue1; // Output color signals to the VGA

  // *** VGA SIGNALS *** //
  wire [9:0] YPos;	// [0..479] 
  wire [10:0] XPos;	// [0...1287]
  wire [7:0] tcgrom_d, tcgrom_q; // output of the character generation ROM
  wire [5:0] char_selection_d, char_selection_q; // input to the character generation ROM
  wire vga_hsync_d, vga_hsync_q, vga_vsync_d, vga_vsync_q; // VGA Flops
  wire [1:0] vga_red_d, vga_green_d, vga_blue_d; // Color Flops
  wire [1:0] vga_red_q, vga_green_q, vga_blue_q;
  wire Valid; // VGA Valid signal -- never turn on colors unless you are valid!
  reg [5:0] char_selection;
  
  reg color;
  
  sync_gen50 syncVGA( .clk(clock), .CounterX(XPos), .CounterY(YPos), .Valid(Valid),
                      .vga_h_sync(vga_hsync_d), .vga_v_sync(vga_vsync_d));

 
  tcgrom tcgrom(.addr({char_selection_q, YPos[4:2]}), .data(tcgrom_d));
  
  
//  wire [5:0] addr;
//  wire we, cen;
  
//  wire [255:0] dout;
  
//  assign we = reset? 1'b1: (YPos==527 && XPos==1586)? ~we:we; 

//  assign cen = ( (YPos<(`Y_SHIFT+63)) && YPos>`Y_SHIFT && ((XPos-`X_SHIFT)==0) );
   
//  counter #(6) count1(.clk(clock),.rst(reset),.en(cen|reset),.count(addr));


 
  
  // Register the output of the character generator. This allows us to break up the critical
  //  path through the character generator to the VGA and makes it easier to meet 50MHz, but 
  //  it will delay the output by one cycle, but we don't really care since no one will be able
  //  to see the difference.
  assign char_selection_d = char_selection;

  //--------------------------------------------------
  // Display the correct character in the locations
  // chosen for the title and the scores
  //--------------------------------------------------
  always @(YPos or XPos)
    begin
	 if (YPos[9:5] == 5'b00001)
	   begin
        if (XPos[10:6] == 5'b00011)
          char_selection = 6'b010100;//T
        else if (XPos[10:6] == 5'b00100)
          char_selection = 6'b010101;//U
        else if (XPos[10:6] == 5'b00101)
        	 char_selection = 6'b001110;//N
        else if (XPos[10:6] == 5'b00110)
        	 char_selection = 6'b001110;//N
        else if (XPos[10:6] == 5'b00111)
         	char_selection = 6'b000101;//E
        else if (XPos[10:6] == 5'b01000)
         	char_selection = 6'b001100;//L
        else if (XPos[10:6] == 5'b01001)
      	  char_selection = 6'b100000;//_
        else if (XPos[10:6] == 5'b01010)
      	  char_selection = 6'b000011;//C
        else if (XPos[10:6] == 5'b01011)
          char_selection = 6'd18;//R
	  else if (XPos[10:6] == 5'b01100)
          char_selection = 6'd21;//U
	 else if (XPos[10:6] == 5'b01101)
          char_selection = 6'd9;//I
	 else if (XPos[10:6] == 5'b01110)
          char_selection = 6'd19;//S
	 else if (XPos[10:6] == 5'b01111)
          char_selection = 6'd5;//E
	 else if (XPos[10:6] == 5'b10000)
          char_selection = 6'd18;//R
	 else
          char_selection = 6'b100000;
	end
end     
  
  


	assign game_area = ( YPos>(10'd112) & YPos<(10'd176) & XPos>(11'd389) & XPos<(11'd645));

   
   //assign colors//
   always @(XPos or tcgrom_q)
    begin  	
      case (XPos[5:3])
        3'h0 : color = tcgrom_q[7];
        3'h1 : color = tcgrom_q[6];
        3'h2 : color = tcgrom_q[5];
        3'h3 : color = tcgrom_q[4];
        3'h4 : color = tcgrom_q[3];
        3'h5 : color = tcgrom_q[2];
        3'h6 : color = tcgrom_q[1];
        3'h7 : color = tcgrom_q[0];	 	      	 	      
      endcase 
    end  
  
  //--------------------------------------------------
  // Assign colors depending on the parts of the screen
  //-------------------------------------------------- 
  assign vga_red_d = {2{1'b0}};
  assign vga_blue_d = {2{color}};
  assign vga_green_d = {2{game_area}};


	  // Hook up the VGA through some flip flops to break up our critical path
  assign vga_vsync = vga_vsync_q;
  assign vga_hsync = vga_hsync_q;
  assign vga_red1 = vga_red_q[1];
  assign vga_red0 = vga_red_q[0];
  assign vga_green1 = vga_green_q[1];
  assign vga_green0 = vga_green_q[0];
  assign vga_blue1 = vga_blue_q[1];
  assign vga_blue0 = vga_blue_q[0];

   // Output flops
   DFF #(8) tcgrom_reg (.clk(clock), .en(1'b1), .in(tcgrom_d), .out(tcgrom_q));
   DFF #(6) char_selection_reg (.clk(clock), .en(1'b1), .in(char_selection_d), 
   	.out(char_selection_q));
   DFF vga_vsync_reg (.clk(clock), .en(1'b1), .in(vga_vsync_d), .out(vga_vsync_q));
   DFF vga_hsync_reg (.clk(clock), .en(1'b1), .in(vga_hsync_d), .out(vga_hsync_q));
   DFF #(2) vga_red_reg (.clk(clock), .en(1'b1), .in(vga_red_d), .out(vga_red_q));
   DFF #(2) vga_green_reg (.clk(clock), .en(1'b1), .in(vga_green_d), .out(vga_green_q));
   DFF #(2) vga_blue_reg (.clk(clock), .en(1'b1), .in(vga_blue_d), .out(vga_blue_q));  

   wire [63:0] oldata;
   wire [71:0] bramdata;
	
   wire right,left,up,down;
   wire topready,ewrite;
   
   wire [7:0] read_address;
	
   Tunnel TunnelCruiser(.clk(clock),.rst(reset),.enable(1'b1),.oldata(oldata),.up(up),
   				    .down(down),.left(left),.right(right),.topready(topready),.bramdata(bramdata),
				    .ewrite(ewrite),.ymap(read_address));



endmodule