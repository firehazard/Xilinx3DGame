module CoordTrans(cruiserx,cruisery,absquarex,absquarey,squarex,squarey);
	input [6:0] cruiserx, cruisery, absquarex, absquarey;
	output [8:0] squarex, squarey;
	assign squarex = absquarex-cruiserx+9'd64;
	assign squarey = absquarey-cruisery+9'd32;
endmodule