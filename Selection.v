module Selection(in,out);
// the output of out depends on 2integer bits and 1 fractional bit of the input

input [2:0] in;
output [1:0]out;
reg[1:0] out;

always @*
case(in)
	3'b011: out<=2'b10;
	3'b010: out<=2'b10;
	3'b001: out<=2'b10;
	3'b000: out<=2'b00;
	3'b111: out<=2'b00;
	3'b110: out<=2'b01;
	3'b101: out<=2'b01;
	3'b100: out<=2'b01;
endcase

endmodule	



