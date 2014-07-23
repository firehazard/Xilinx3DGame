`define X_SHIFT 11'd388 //132 before
`define Y_SHIFT 10'd176 //112 before


module top_dog(clock,resetn,c_start,a_b,right_in, down_in, left_in,up_in, vga_hsync , vga_vsync, vga_red0, vga_green0, vga_blue0, vga_red1, vga_green1, vga_blue1);
  
  input clock, resetn,c_start;
  input right_in,down_in,left_in,up_in,a_b;
   
  wire reset = (~resetn);
  wire abutton, pbutton;
  // *** VGA OUTPUTS ** //
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

  //new stuff
   
  wire [10:0] Xt = XPos-`X_SHIFT;
  wire [9:0] Yt = YPos-`Y_SHIFT;
  wire [8:0] X = Xt[8:0];
  wire [6:0] Y = Yt[6:0];   
  wire [3:0] score1,score2,score3;
  wire crash;
  wire [3:0] arrow;

  reg reds1,greens1,blacks1;
  wire reds,greens,blacks;
  assign reds=reds1;
  assign greens=greens1;
  assign blacks=blacks1;   

  //Going to Tunnel Cruiser
  wire [1:0] oldata;
  wire [14:0] bramdata;
  wire right,left,up,down;
  wire topready,ewrite;
  wire [12:0] read_address;
   
   wire [12:0] vga_addr, yao_ming_addr, childress_addr;
   wire [1:0] yao_ming_out,childress_out,vga_data;   
  //bselect code															    	
  
  wire bselect,next_bselect;
  reg bselect1;
  assign next_bselect = reset? 1'b1:bselect1;
  DFF #(1) bselect_reg (.clk(clock),.en(1'b1),.in(next_bselect),.out(bselect));
  always@(XPos or YPos or bselect)
  begin
	if ((XPos==11'd1585)&(YPos==10'd526)) bselect1=~bselect;
	else bselect1=bselect;
  end
  

  wire speed,next_speed;
  reg speed1;
  assign next_speed = reset? 1'b0:speed1;
  DFF #(1) speed_reg (.clk(clock),.en(1'b1),.in(next_speed),.out(speed));
  always@(abutton or speed)
  begin
	if (abutton) speed1=~speed;
	else speed1=speed;
  end
  
  wire apilot,next_apilot;
  reg pilot1;
  assign next_apilot = reset? 1'b0:pilot1;
  DFF #(1) pilot_reg (.clk(clock),.en(1'b1),.in(next_apilot),.out(apilot));
  always@(pbutton or apilot)
  begin
	if (pbutton) pilot1=~apilot;
	else pilot1=apilot;
  end

  
  wire score_frame;
 
       // Gamepad
  Gamepad in(.clk(clock),.rst(reset),.right_in(right_in),.left_in(left_in),.a_b(a_b),.c_start(c_start),
  				.down_in(down_in),.up_in(up_in),.right_out(right),.left_out(left),.down_out(down),
				.up_out(up),.a_out(abutton),.c_out(pbutton));

  
    
  
  sync_gen50 syncVGA( .clk(clock),.CounterX(XPos), .CounterY(YPos), .Valid(Valid),
                      .vga_h_sync(vga_hsync_d), .vga_v_sync(vga_vsync_d));

 
  tcgrom tcgrom(.addr({char_selection_q, YPos[4:2]}), .data(tcgrom_d));

  
  // Register the output of the character generator. This allows us to break up the critical
  //  path through the character generator to the VGA and makes it easier to meet 50MHz, but 
  //  it will delay the output by one cycle, but we don't really care since no one will be able
  //  to see the difference.

  assign char_selection_d = char_selection;

  assign topready= ((XPos==11'd1586) & (YPos==10'd526));


  //--------------------------------------------------
  // Display the correct character in the locations
  // chosen for the title and the scores
  //--------------------------------------------------

  always @(YPos or XPos or score1 or score2 or score3 or crash or arrow or apilot)
    begin
	 if (YPos[9:5] == 5'b00010)
        if (XPos[10:6] == 5'b00011)
          char_selection = 6'd16;//P
        else if (XPos[10:6] == 5'b00100)
          char_selection = 6'd9;//I
        else if (XPos[10:6] == 5'b00101)
        	 char_selection = 6'd18;//R
        else if (XPos[10:6] == 5'b00110)
        	 char_selection = 6'd1;//A
        else if (XPos[10:6] == 5'b00111)
         	char_selection = 6'd20;//T
	   else if (XPos[10:6] == 5'b01000)
         	char_selection = 6'd5;//E

        else if (XPos[10:6] == 5'b01010)
      	  char_selection = 6'd3;//C
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

	
	else
	if (YPos[9:5]==5'b01100)
	   if (XPos[10:6] == 5'b00101)
          char_selection = 6'd19;//S
        else if (XPos[10:6] == 5'b00110)
          char_selection = 6'd3;//C
        else if (XPos[10:6] == 5'b00111)
        	 char_selection = 6'd15;//O
        else if (XPos[10:6] == 5'b01000)
        	 char_selection = 6'd18;//R
        else if (XPos[10:6] == 5'b01001)
         	char_selection = 6'd5;//E
	   else if (XPos[10:6] == 5'b01100)
	   		char_selection = {2'b11, score3}; //hundreds's digit
	   else if (XPos[10:6] == 5'b01101)
	   		char_selection = {2'b11, score2}; //ten's digit
        else if (XPos[10:6] == 5'b01110)
			char_selection = {2'b11, score1}; //one's digit
	   else 
	     char_selection = 6'b100000;
	
	else		//this block displays in crash
	if ((YPos[9:5]==5'b01110) & crash)
  	   if (XPos[10:6] == 5'b01000)
         	char_selection = 6'd1;//A
	   else if (XPos[10:6] == 5'b01001)
	   		char_selection = 6'd18;//R
	   else if (XPos[10:6] == 5'b01010)
	   		char_selection = 6'd7;   //G
        else if (XPos[10:6] == 5'b01011)
			char_selection = 6'd8;	  //H
	   else 
	     char_selection = 6'b100000;

	   else if (YPos[9:5]==5'b00111 & arrow[2])
        if (XPos[10:6] == 5'b00100)
        	 char_selection = 6'd31; // LEFT ARROW
        else   
      	 char_selection = 6'b100000;
	   
	   else if (YPos[9:5]==5'b00111 & arrow[3])
	   if (XPos[10:6] == 5'b01111)
         	char_selection = 6'd29; //RIGHT ARROW
 	     else   
      	char_selection = 6'b100000;
 	
	   else if (YPos[9:5]==5'b00100 & arrow[0])
        if (XPos[10:6] == 5'b01001)
     	char_selection = 6'd30; //TOP ARROW
	    else   
         char_selection = 6'b100000;

        else if (YPos[9:5]==5'b01010 & arrow[1])
        if (XPos[10:6] == 5'b01001)
     	char_selection = 6'd28; //BOTTOM ARROW
	    else   
         char_selection = 6'b100000;
	
	else if (YPos[9:5] == 5'b00011 & apilot)
        if (XPos[10:6] == 5'b00110)
        	 char_selection = 6'd1;//A
        else if (XPos[10:6] == 5'b00111)
         	char_selection = 6'd21;//U
	   else if (XPos[10:6] == 5'b01000)
	   		char_selection = 6'd20;//T
	   else if (XPos[10:6] == 5'b01001)
	   		char_selection = 6'd15;	  //O
        else if (XPos[10:6] == 5'b01010)
			char_selection = 6'd16;	  //P
	   else if (XPos[10:6] == 5'b01011)
			char_selection = 6'd9;	  //I
	   else if (XPos[10:6] == 5'b01100)
			char_selection = 6'd12;	  //L
	   else if (XPos[10:6] == 5'b01101)
			char_selection = 6'd15;	  //O
	   else if (XPos[10:6] == 5'b01110)
			char_selection = 6'd20;	  //T
	  else   
     	    char_selection = 6'b100000; 	  
	
	else   
      char_selection = 6'b100000;
end
   
   wire cross_hair, game_area, skull_area,pilot_area;

   assign cross_hair =(((XPos>11'd642 & XPos<11'd646)  &( YPos>(10'd236)&YPos<(10'd246)))| 
		    		 ((YPos==10'd239 | YPos==10'd240) &(XPos>(11'd635)&XPos<(11'd651))));

   assign title_area = (YPos[9:5] == 5'b00010); 
   assign pilot_area = (YPos[9:5] == 5'b00011);  

   assign game_area = ( YPos>10'd178 & YPos<10'd304 & XPos>11'd392 & XPos<11'd896);

   assign message_area = (YPos[9:5]==5'b01110);

   wire score_frames = (YPos>10'd375 & YPos<10'd415 &  XPos>11'd300 & XPos<11'd960);
   wire score_framel = (YPos>10'd365 & YPos<10'd425 &  XPos>11'd280 & XPos<11'd980);
   
   assign score_frame = score_framel & (~score_frames); 
   
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
 
   wire mult;

 // wire red = crazy? disp_square:(disp_square&game_area);
  
  assign vga_red_d =  mult? {2{reds |(color&message_area&crash) | score_frame | (pilot_area&color)}}: 
  				{2{reds&(game_area)|(color&message_area&crash) | score_frame | (pilot_area&color)}}; //fade (disp_square & (game_area&~crazy)); 
  
  assign vga_blue_d = mult? {2{((blacks)&(~cross_hair)&(~reds))|(color&(~message_area)&(~title_area)) | (pilot_area&color)}}:
  				 {2{(game_area&(~blacks)&(~cross_hair)&(~reds))|(color&(~message_area)&(~title_area)) | (pilot_area&color)}};
  
  assign vga_green_d = mult? {2{cross_hair | (greens)| score_frame |(color & title_area) | (pilot_area&color)}}: 
  				{2{cross_hair | (game_area&greens)| score_frame |(color & title_area) | (pilot_area&color)}};


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


   Tunnel TunnelCruiser(.clk(clock),.rst(reset),.speed(speed),.enable(1'b1),.oldata(oldata),.up1(up),
   				    .down1(down),.left1(left),.right1(right),.topready(topready),.bramdata(bramdata),
				    .ewrite(ewrite),.ymap(read_address),.score1(score1),.score2(score2),
				    .score3(score3),.crashed(crash),.arrow(arrow),.apilot(apilot),.mult(mult));

   assign vga_addr={X[8:2],Y[6:1]};//{X[8:2],Y[6:1]};

   assign oldata=bselect? childress_out:yao_ming_out;
   
   assign childress_addr=bselect? read_address:vga_addr;
   assign yao_ming_addr=bselect? vga_addr:read_address;   

   assign vga_data = bselect? yao_ming_out:childress_out;

   bram1 childress (.addra(bramdata[14:2]),.addrb(childress_addr),.clka(clock),.clkb(clock),
   			 .dina(bramdata[1:0]),.doutb(childress_out),.wea(bselect&ewrite)); 
   
   bram2 yao_ming(.addra(bramdata[14:2]),.addrb(yao_ming_addr),.clka(clock),.clkb(clock),
   			 .dina(bramdata[1:0]),.doutb(yao_ming_out),.wea((~bselect)&ewrite)); 
   

   always@(vga_data or X or Y) begin
	case(vga_data)
	 2'b00: begin
	 	   reds1=1'b0;
		   blacks1=1'b0;
		   greens1=1'b0;
		   end
	2'b01: begin
		  reds1=1'b0;
	 	  greens1=((~Y[0])&(X[1]));
  	 	  blacks1=1'b0;
		  end
	 2'b10: begin
	 	   blacks1=X[1];
		   greens1=1'b0;
		   reds1 = 1'b0;
		   end
   	 2'b11: begin
	 	   blacks1=1'b0;
		   greens1=1'b0;
		   reds1=1'b1;
		   end
     default: begin
		 blacks1=1'b0;
		 greens1 = 1'b0;
		 reds1 = 1'b0;
		 end
	endcase
   end


endmodule