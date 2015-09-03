module V_block(v_value_upper_plus,v_value_upper_minus,estimated_q,borrower_up,fixing,pre_p_value);

input[3:0] v_value_upper_plus,v_value_upper_minus;
output[1:0] estimated_q;
reg[1:0] estimated_q;
wire[3:0] v_upper_value;
wire[3:0] v_sample;
input borrower_up;

input fixing;
input pre_p_value;

assign v_upper_value=v_value_upper_plus-v_value_upper_minus-borrower_up;
assign v_sample=v_upper_value;

initial begin 
	estimated_q<=2'b00;
end


always @(*) begin
	if(fixing ==1'b0) begin
		case(v_sample)
			4'b0111: estimated_q<=2'b10;
			4'b0110: estimated_q<=2'b10;
			4'b0101: estimated_q<=2'b10;
			4'b0100: estimated_q<=2'b10;
			4'b0011: estimated_q<=2'b10;
			4'b0010: estimated_q<=2'b10;
			4'b0001: estimated_q<=2'b10;
			4'b0000: estimated_q<=2'b00;
			4'b1111: estimated_q<=2'b00;
			4'b1110: estimated_q<=2'b01;
			4'b1101: estimated_q<=2'b01;
			4'b1100: estimated_q<=2'b01;
			4'b1011: estimated_q<=2'b01;
			4'b1010: estimated_q<=2'b01;
			4'b1001: estimated_q<=2'b01;
			4'b1000: estimated_q<=2'b01;
		endcase
	end
	else begin
		estimated_q<=pre_p_value;
	end
end


endmodule
