module SDVM(clk,STATE,vec_in_plus,vec_in_minus, digit_select, vec_out_plus,vec_out_minus);

input clk;
input[1:0] STATE;
parameter Num_bits=4;
input [Num_bits-1:0] vec_in_plus,vec_in_minus;
input[1:0] digit_select;
output [Num_bits-1:0] vec_out_plus,vec_out_minus;
reg [Num_bits-1:0] vec_out_plus,vec_out_minus;

wire [1:0] tmp_one_cycle_delay;//tmp_two_cycle_delay,tmp_three_cycle_delay;
reg[1:0] digit_select_delayed;
//reg[2:0] detect;
//reg signal;

initial begin 
	vec_out_plus<=4'b0;
	vec_out_minus<=4'b0;
end


D_FF_two_bits D1(digit_select,tmp_one_cycle_delay,clk,1'b1);
//D_FF_two_bits D2(tmp_one_cycle_delay,tmp_two_cycle_delay,clk,1'b1);
//D_FF_two_bits D3(tmp_two_cycle_delay,tmp_three_cycle_delay,clk,1'b1);

/*
always@(*) begin
	detect=cnt_master[8]+cnt_master[7]+cnt_master[6]+cnt_master[5]+cnt_master[4]+cnt_master[3];

	if(detect==3'b1&&cnt_master[0]==1'b1&&STATE==2'b11) begin
		signal<=1'b1;
	end
	else begin
		signal<=1'b0;
	end
end
*/


always@(*) begin
	//if(STATE==2'b00) begin
		digit_select_delayed=tmp_one_cycle_delay;
	//end

	/*else if(STATE!=2'b00 && signal==1'b1) begin
			digit_select_delayed=tmp_three_cycle_delay;
	//end
	
	else begin
		digit_select_delayed=tmp_two_cycle_delay;
	end
*/
end


	
always@* begin
	case(digit_select_delayed)
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
