module q_vec_control(cnt_master,computation_cycle,clk,q_plus_vec,q_minus_vec,d_value,STATE,q_delayed_plus,q_delayed_minus);
input[3:0] q_plus_vec,q_minus_vec;
input[8:0] cnt_master;
input[1:0] STATE;
input[1:0] d_value;
input clk;
input[6:0] computation_cycle;

wire[3:0] q_vec_out_plus,q_vec_out_minus;
output[3:0] q_delayed_plus,q_delayed_minus;
reg[3:0] q_delayed_plus,q_delayed_minus;
wire[1:0] d_delayed;
reg[1:0] d_in;

D_FF_two_bits D1(d_value,d_delayed,clk,1'b1);

SDVM selector1(clk,q_plus_vec,q_minus_vec,~d_value,q_vec_out_plus,q_vec_out_minus);
initial begin
	q_delayed_plus<=4'b0;
	q_delayed_minus<=4'b0;
end

always@(posedge clk)begin

	if(STATE==2'b10&&(computation_cycle==7'b0||cnt_master==9'b100)) begin
			q_delayed_plus<=q_vec_out_plus;
			q_delayed_minus<=q_vec_out_minus;
	end

	else if(STATE==2'b11) begin
			q_delayed_plus<=q_vec_out_plus;
			q_delayed_minus<=q_vec_out_minus;
	end
end
/*
initial begin
	q_delayed_plus<=4'b0;
	q_delayed_minus<=4'b0;

end

always@(posedge clk)begin
	if(!((STATE==2'b01||STATE==2'b11)&&cnt_master[1:0]==2'b00))begin
		q_delayed_plus<=q_plus_vec;
		q_delayed_minus<=q_minus_vec;
	end
end


always@(*) begin
	if(STATE==2'b10) begin
		if(computation_cycle==7'b0||cnt_master==9'b100) begin
			q_vec_in_plus<=q_delayed_plus;
			q_vec_in_minus<=q_delayed_minus;
			d_in<=d_delayed;
		end
		else begin
			q_vec_in_plus<=q_plus_vec;
			q_vec_in_minus<=q_minus_vec;
			d_in<=d_delayed;
		end
	end
	else if (STATE==2'b01) begin
			q_vec_in_plus<=q_delayed_plus;
			q_vec_in_minus<=q_delayed_minus;
			d_in<=d_value;
			end
			else begin
				q_vec_in_plus<=q_plus_vec;
				q_vec_in_minus<=q_minus_vec;
				d_in<=d_value;
			end
end*/

endmodule
