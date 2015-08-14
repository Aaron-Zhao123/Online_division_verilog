module V_value_logic(x_value,v_plus,v_minus,v_plus_new,v_minus_new,clk,cnt_master,computation_cycle,STATE,v_upper_plus,v_upper_minus,cout,v_upper_plus_result,v_upper_minus_result,cin,carry_feedback,carry_propogate);

input[3:0] v_plus,v_minus;
output[3:0] v_plus_new,v_minus_new;
reg[3:0] v_plus_new,v_minus_new;

input[1:0] x_value;
input[8:0] cnt_master;
// carry enable is seted, then cout of the adder is feeded to the V_upper_bits
input[5:0] v_upper_plus,v_upper_minus;
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
output[5:0] v_upper_plus_result,v_upper_minus_result;
wire[5:0] v_upper_plus_result,v_upper_minus_result;
reg[3:0] tmp_plus,tmp_minus;
wire[1:0] remainder;
assign remainder=cnt_master[1:0];
reg stay;

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
			if(computation_cycle==7'b0) begin
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

always@(*) begin
	if(carry_propogate==1'b1) begin
		tmp_plus={1'b0,cout[1],v_plus[3]}+{1'b0,1'b0,x_value[1]};
		tmp_minus={1'b0,cout[0],v_minus[3]}+{1'b0,1'b0,x_value[0]};
		v_plus_new<={tmp_plus[0],v_plus[2:0]};
		v_minus_new<={tmp_minus[0],v_minus[2:0]};
		
	end
	else begin
		v_plus_new<=v_plus;
		v_minus_new<=v_minus;
		tmp_plus=4'b0;
		tmp_minus=4'b0;		
	end
end //ascynchronously control when should the addition be finished, thus cout could affect v_upper bits value

assign v_upper_plus_result=v_upper_plus+{1'b0,1'b0,tmp_plus};
assign v_upper_minus_result=v_upper_minus+{1'b0,1'b0,tmp_minus};

endmodule
