module V_value_logic(cnt_master_dis,x_value,v_plus,v_minus,v_plus_new,v_minus_new,clk,cnt_master,computation_cycle,STATE,v_upper_plus,v_upper_minus,cout,v_upper_plus_result,v_upper_minus_result,cin,carry_feedback,carry_propogate,borrower_up);

input[8:0] cnt_master_dis;
input[3:0] v_plus,v_minus;
output[3:0] v_plus_new,v_minus_new;
reg[3:0] v_plus_new,v_minus_new;

input[1:0] x_value;
input[8:0] cnt_master;
// carry enable is seted, then cout of the adder is feeded to the V_upper_bits
input[3:0] v_upper_plus,v_upper_minus;
input[1:0] STATE;
input[6:0] computation_cycle;
input[1:0] cout;
input clk;
output carry_feedback;
output carry_propogate;
reg carry_feedback;
reg carry_propogate;
output[1:0] cin;
reg[1:0] cin;
output[3:0] v_upper_plus_result,v_upper_minus_result;
wire[3:0] v_upper_plus_result,v_upper_minus_result;
reg[3:0] tmp_plus,tmp_minus;
wire[1:0] remainder;
assign remainder=cnt_master[1:0];
reg stay;
output borrower_up;
reg borrow_stored,borrower_low,borrower_up;


initial begin
	cin<=2'b0;
	tmp_plus<=4'b0;
	tmp_minus<=4'b0;
end

always @(posedge clk) begin
	if(STATE==2'b01)
		stay<=1'b0;
	else
		stay<=1'b1;
end


// controlling logic depends on STATE
always@(*) begin
	case(STATE)
		2'b10: begin // if 10 as zero row, always enable the propogate
			carry_feedback<=1'b0;
			if(computation_cycle==7'b0||cnt_master==9'b100) begin
				carry_propogate<=1'b1;
			end
			else begin
				carry_propogate<=1'b0;
			end
		end
		2'b01: begin 
			carry_propogate<=1'b0;

			if(remainder==2'b00&&stay==1'b1)
				carry_feedback<=1'b0;
			else 
				carry_feedback<=1'b1;
		end
		2'b11: begin
			carry_propogate<=1'b1;
			carry_feedback<=1'b0;
		end
		default: begin
			carry_feedback<=1'b0;
			carry_propogate<=1'b0;
		end
	endcase
end

			
			


always@(posedge clk) begin
	if(carry_feedback==1'b1) begin
		cin<=cout;
	end
	else begin
		cin<=2'b0;
	end
end //controls when should cout feeds back to cin

always@(*) begin //carry propogate should be high at the cycle for which carrry is recieved
	if(carry_propogate==1'b1) begin //notice tmp[0] goest to MSB of v_plus,v_minus, tmp is 4bits to take account of the carry out of the addition 
		tmp_plus={1'b0,cout[1],v_plus[3],v_plus[2]}+{1'b0,1'b0,1'b0,x_value[1]};// x_value is added at the 7th bit
		tmp_minus={1'b0,cout[0],v_minus[3],v_minus[2]}+{1'b0,1'b0,1'b0,x_value[0]};
		v_plus_new<={tmp_plus[1:0],v_plus[1:0]};
		v_minus_new<={tmp_minus[1:0],v_minus[1:0]};
		
	end
	else begin
		v_plus_new<=v_plus;
		v_minus_new<=v_minus;
		tmp_plus=3'b0;
		tmp_minus=3'b0;		
	end
end //ascynchronously control when should the addition be finished, thus cout could affect v_upper bits value

assign v_upper_plus_result=v_upper_plus+{1'b0,1'b0,tmp_plus[3:2]};
assign v_upper_minus_result=v_upper_minus+{1'b0,1'b0,tmp_minus[3:2]};

//logic that feeds back borrower

always@(*) begin
	borrower_up<=1'b0;
	borrower_low<=1'b0;
	if(STATE==2'b10&&(cnt_master_dis==9'b100||cnt_master_dis==9'b11))begin
		if(v_plus_new<v_minus_new) begin
			borrower_up<=1'b1;
		end
	end
	else begin
		if(carry_feedback==1'b1) begin
			if((v_plus_new-borrow_stored)<v_minus_new)begin
				borrower_low<=1'b1;
			end
			else begin
				borrower_low<=1'b0;
			end
		end
		else if(carry_propogate==1'b1)begin
			borrower_low<=1'b0;
			if((v_plus_new-borrow_stored)<v_minus_new)begin
				borrower_up<=1'b1;
			end
			else begin
				borrower_up<=1'b0;
			end
		end
	end
end
always@(posedge clk) begin
	if(carry_feedback==1'b1)begin
		borrow_stored<=borrower_low;
	end
end



endmodule
