module SDVM(clk,vec_in_plus,vec_in_minus, digit_select, vec_out_plus,vec_out_minus);

input clk;
parameter Num_bits=4;
input [Num_bits-1:0] vec_in_plus,vec_in_minus;
input[1:0] digit_select;
output [Num_bits-1:0] vec_out_plus,vec_out_minus;
reg [Num_bits-1:0] vec_out_plus,vec_out_minus;

//wire [1:0] tmp_one_cycle_delay;
reg[1:0] digit_select_delayed;

initial begin 
	vec_out_plus<=4'b0;
	vec_out_minus<=4'b0;
end


//D_FF_two_bits D1(digit_select,tmp_one_cycle_delay,clk,1'b1);




	
always@* begin
	case(digit_select)
		2'b00: begin
			vec_out_plus<=4'b0;
			vec_out_minus<=4'b0;
		end
		2'b10: begin 
			vec_out_plus<=vec_in_plus;
			vec_out_minus<=vec_in_minus;//if digit is 1
		end
		2'b01: begin
			vec_out_plus<=~vec_in_plus;
			vec_out_minus<=~vec_in_minus;//if digit is -1
		end
		default: begin 
			vec_out_plus<=4'b0;
			vec_out_minus<=4'b0;
		end
	endcase

end
endmodule
