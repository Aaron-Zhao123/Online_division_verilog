module w_value_logic_fix(STATE,cnt_master,computation_cycle,clk,carry_feedback,v_upper_plus,v_upper_minus,d_plus_selected,d_minus_selected,w_plus_res,w_minus_res,d_plus_controlled,d_minus_controlled,w_plus_shifted,w_minus_shifted,residue_plus,residue_minus,w_upper_plus,w_upper_minus,res_upper_plus,res_upper_minus,cout_two,cin_two,carry_feedback_two,carry_propogte_two,rd_addr,wr_addr,we,d_upper_plus,d_upper_minus,d_upper_plus_add,d_upper_minus_add,q_value,error_flag);

input[1:0] STATE;
input error_flag;
input[8:0] cnt_master;
input[6:0] computation_cycle;
input[1:0] q_value;
input clk;
input carry_feedback;
input[3:0] v_upper_plus,v_upper_minus;
input[3:0] d_plus_selected,d_minus_selected;
input[3:0] w_plus_res,w_minus_res; // sum added from adder 2
output[3:0] d_plus_controlled,d_minus_controlled,w_plus_shifted,w_minus_shifted,residue_plus,residue_minus; // used to add in outside adder2
reg[3:0] d_plus_controlled,d_minus_controlled;
output[3:0] w_upper_plus,w_upper_minus;
output[3:0] res_upper_plus,res_upper_minus;
reg[3:0] res_upper_plus_reserved,res_upper_minus_reserved;
reg[3:0] res_upper_plus,res_upper_minus;
input[1:0] cout_two;
output[1:0] cin_two;
output carry_feedback_two;
output carry_propogte_two;
output[6:0] wr_addr;
output[6:0] rd_addr;
output we;
reg we;
reg[6:0] wr_addr,rd_addr;
reg[1:0] cin_two;
output [3:0] d_upper_plus_add,d_upper_minus_add;
reg[3:0] d_upper_plus_add,d_upper_minus_add;
reg[3:0] d_plus_delayed,d_minus_delayed,w_plus_shifted,w_minus_shifted;
wire[1:0] cout_three;
reg[1:0] cin_three;
wire[6:0] max_cycle;
wire[1:0] remainder;
reg carry_feedback_two;
reg carry_propogte_two;
reg[1:0] tmp_shift_out,tmp_shift_in;
input[1:0] d_upper_plus,d_upper_minus;
wire[1:0] d_upper_plus_sel,d_upper_minus_sel;
reg stay;

SDVM_3bit selector3(clk,d_upper_plus,d_upper_minus,~q_value,d_upper_plus_sel,d_upper_minus_sel);

six_bits_adder adder(v_upper_plus,v_upper_minus,d_upper_plus_add,d_upper_minus_add,w_upper_plus,w_upper_minus,cin_three,cout_three);

//---------------this logic controls w[j+1]=v[j]+d_sel---------------------------
assign max_cycle=cnt_master[8:2];
assign remainder=cnt_master[1:0];
initial begin
	tmp_shift_out<=2'b0;
	tmp_shift_in<=2'b0;
//	d_shift_out<=2'b0;
//	d_shift_in<=2'b0;
end
initial begin
	cin_three<=2'b0;
	w_plus_shifted<=4'b0;
	w_minus_shifted<=4'b0;
	d_plus_delayed<=4'b0;
	d_minus_delayed<=4'b0;
	d_plus_controlled<=4'b0;
	d_minus_controlled<=4'b0;
	d_upper_plus_add<=4'b0;
	d_upper_minus_add<=4'b0;
	we<=1'b1;
	res_upper_plus<=4'b0;
	res_upper_minus<=4'b0;
	wr_addr<=7'b0;
	rd_addr<=7'b0;
	cin_two<=2'b0;
	
end



always@(posedge clk) begin
	d_plus_delayed<=d_plus_selected;
	d_minus_delayed<=d_minus_selected;
end


always@(posedge clk)begin
	if(carry_feedback_two) begin
		cin_two<=cout_two;
	end
	else begin	
		cin_two<=2'b0;
	end
end

always@(*) begin
	if(carry_propogte_two) begin // control cin_three to achieve add previous cout to current upper positions
		cin_three<=cout_two;
	end
	else begin
		cin_three<=2'b0;
	end
end


always@(*) begin
	case(STATE) 
		2'b10: begin
			if(computation_cycle==7'b0||cnt_master==9'b100) begin // this is the zero row operation
				d_upper_plus_add<={1'b0,1'b0,d_upper_plus_sel}; //d_plus_sel and d_minus_sel are seleted with 0 on the 2 msb of d_upper
				d_upper_minus_add<={1'b0,1'b0,d_upper_minus_sel};
				d_plus_controlled<=d_plus_selected;
				d_minus_controlled<=d_minus_selected;
				carry_feedback_two<=1'b0;
				carry_propogte_two<=1'b1;
			end
			else begin //normally in 10 state, both adders are not in use, 10 state loads q[j] value only
				d_upper_plus_add<=4'b0;
				d_upper_minus_add<=4'b0;
				d_plus_controlled<=4'b0;
				d_minus_controlled<=4'b0;
				carry_feedback_two<=1'b0;
				carry_propogte_two<=1'b0;
			end
		end
		2'b01: begin
			if(remainder==2'b00&&computation_cycle!=7'b0) begin
				d_upper_plus_add<=4'b0;
				d_upper_minus_add<=4'b0;
				d_plus_controlled<=4'b0;
				d_minus_controlled<=4'b0;
				carry_feedback_two<=1'b0;
				carry_propogte_two<=1'b0;
			end
			else if (remainder==2'b00&&computation_cycle==7'b0)begin
				d_upper_plus_add<=4'b0;
				d_upper_minus_add<=4'b0;
				d_plus_controlled<=d_plus_selected;
				d_minus_controlled<=d_minus_selected;
				carry_feedback_two<=1'b1;
				carry_propogte_two<=1'b0;				
			end
			else begin
				if(computation_cycle==(max_cycle-7'b1)) begin // this is when v_plus, v_minus are taking the 4LSB of residue 
					d_upper_plus_add<=4'b0;
					d_upper_minus_add<=4'b0;
					d_plus_controlled<=4'b0;
					d_minus_controlled<=4'b0;
					carry_feedback_two<=1'b1;
					carry_propogte_two<=1'b0;
				end
				else begin
					d_upper_plus_add<=4'b0;
					d_upper_minus_add<=4'b0;	
					d_plus_controlled<=d_plus_selected;
					d_minus_controlled<=d_minus_selected;	
					carry_feedback_two<=1'b1;	
					carry_propogte_two<=1'b0;
				end
			end
		end
		2'b11: begin // at state 11, use both adder2 and adder 3, connect adder2's cout to adder3's cin 
				d_upper_plus_add<={1'b0,1'b0,d_upper_plus_sel}; //d_plus_sel and d_minus_sel are seleted with 0 on the 2 msb of d_upper
				d_upper_minus_add<={1'b0,1'b0,d_upper_minus_sel};
				d_plus_controlled<=d_plus_selected;
				d_minus_controlled<=d_minus_selected;
				carry_feedback_two<=1'b0;	
				carry_propogte_two<=1'b1;
		end
		2'b00: begin
					d_upper_plus_add<=4'b0;
					d_upper_minus_add<=4'b0;	
					d_plus_controlled<=d_plus_selected;
					d_minus_controlled<=d_minus_selected;	
					carry_feedback_two<=1'b1;	
					carry_propogte_two<=1'b0;			
		end
		default: begin
				d_upper_plus_add<=4'b0;
				d_upper_minus_add<=4'b0;
				d_plus_controlled<=4'b0;
				d_minus_controlled<=4'b0;
				carry_feedback_two<=1'b0;
				carry_propogte_two<=1'b0;
		end
   endcase
end
				
//------------------------------------------------------------
//-----------------computing 2w[j](shift) from w[j+1], w[j] is called residue in this scope

//refresh upper values
always @(posedge clk) begin
	if(STATE==2'b11) begin //shift upper bit
		if(error_flag==1'b0) begin
			res_upper_plus<={w_upper_plus[2:0],tmp_shift_out[1]};
			res_upper_minus<={w_upper_minus[2:0],tmp_shift_out[0]};
		end
/*		else begin
			res_upper_plus_reserved<={w_upper_plus[2:0],tmp_shift_out[1]};
			res_upper_minus_reserved<={w_upper_minus[2:0],tmp_shift_out[0]};
		end*/
		//stay<=1'b0;
	end
/*	else if(STATE==2'b00&&computation_cycle==7'b0) begin //reput back the correct res_upper values
		res_upper_plus<=res_upper_plus_reserved;
		res_upper_minus<=res_upper_minus_reserved;
	
	end*/
	else if ((STATE==2'b10 && computation_cycle==7'b0)||(STATE==2'b10&&cnt_master==9'b100)) begin // fist row, shift up
		res_upper_plus<={w_upper_plus[2:0],tmp_shift_out[1]};
		res_upper_minus<={w_upper_minus[2:0],tmp_shift_out[0]};
	end
	/*else if(STATE==2'b01 && remainder==2'b00 && stay==1'b0) begin
		res_upper_plus<={w_upper_plus[4:0],tmp_shift_out[1]};
		res_upper_minus<={w_upper_minus[4:0],tmp_shift_out[0]};
		stay<=1'b1;
	end*/ 

	
end
//computes the lower values based on states, always store their shift out values into a register 



always @ (posedge clk) begin
	tmp_shift_in<=tmp_shift_out;
end




always@ (*) begin
	if(STATE==2'b11 || (STATE==2'b01&&remainder!=2'b00)||(STATE==2'b01&&remainder==2'b00&&computation_cycle!=cnt_master[8:2])||(STATE==2'b00&&remainder!=2'b00)) begin
		w_plus_shifted<={w_plus_res[2:0],tmp_shift_in[1]};
		w_minus_shifted<={w_minus_res[2:0],tmp_shift_in[0]};
		tmp_shift_out<={w_plus_res[3],w_minus_res[3]};
	end
	else if((STATE==2'b10&&computation_cycle==7'b0)|| (STATE==2'b10&&remainder==2'b00)) begin
		w_plus_shifted<={w_plus_res[2:0],1'b0};
		w_minus_shifted<={w_minus_res[2:0],1'b0};
		tmp_shift_out<={w_plus_res[3],w_minus_res[3]};	
	end
	else begin
		w_plus_shifted<=w_plus_res;
		w_minus_shifted<=w_minus_res;
		tmp_shift_out<=2'b00;
	
	end
end


w_value_ram w_ram({w_plus_shifted,w_minus_shifted},wr_addr,rd_addr,we,clk,{residue_plus,residue_minus});



always@(*)begin
	case(STATE)
		2'b01:begin
			if(carry_feedback==1'b1) begin //this indicates the first cycle in 01 state
				we<=1'b1;
				wr_addr<=computation_cycle+1'b1;
				rd_addr<=computation_cycle;
			end	
			else begin
				we<=1'b0;
				wr_addr<=computation_cycle;
				rd_addr<=computation_cycle;
			end
		end
		2'b11:begin
			if(error_flag==1'b0) begin // defend pipelining breaking
				we<=1'b1;
			end
			else begin
				we<=1'b0;
			end
			wr_addr<=7'b0;
			rd_addr<=computation_cycle;
		end
		2'b10:begin
			if(computation_cycle==7'b0) begin
				we<=1'b1;
				wr_addr<=computation_cycle;
				rd_addr<=computation_cycle;
			end
			else if(cnt_master==7'b100) begin
				we<=1'b1;
				wr_addr<=computation_cycle-1'b1;
				rd_addr<=computation_cycle-1'b1;
				end
			else begin
				we<=1'b0;
				wr_addr<=computation_cycle;
				rd_addr<=computation_cycle;
			end
		end

		default:begin
				we<=1'b0;
				wr_addr<=computation_cycle;
				rd_addr<=computation_cycle;
		end
	endcase
end


endmodule
	