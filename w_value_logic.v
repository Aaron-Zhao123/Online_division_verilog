module w_value_logic(computation_cycle,STATE,clk,v_upper_plus_result,v_upper_minus_result,w_plus,w_minus,carry_feedback,carry_propogate,cin,cout,residue_plus,residue_minus,rd_addr,wr_addr,w_upper_shifted_plus,w_upper_shifted_minus);

input[6:0] computation_cycle;

input[1:0] STATE;
input clk;
input carry_feedback,carry_propogate;
input[5:0] v_upper_plus_result,v_upper_minus_result;
input[1:0] cout;
output[1:0] cin;
reg[1:0] cin;
input[3:0] w_plus,w_minus;
output[3:0] residue_plus,residue_minus;
output[5:0] w_upper_shifted_plus,w_upper_shifted_minus;

reg[5:0] w_upper_shifted_plus,w_upper_shifted_minus;
wire[5:0] w_upper_plus,w_upper_minus;
reg[1:0] tmp,shift_in;
wire[3:0] w_plus_shifted,w_minus_shifted;
reg enable_shift,enable_shift_upper_bits;
reg we;
output[6:0] rd_addr,wr_addr;
reg[6:0] rd_addr,wr_addr;
//testing
//finished

initial begin
	tmp<=2'b0;
	shift_in<=2'b0;
	rd_addr<=7'b0;
	wr_addr<=6'b0;
	we<=1'b0;
end


//------------------------PART 1 : updating the value of w_upper bits and control cin,cout for adder 2----------- 
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
		tmp<=cout;
	end
	else begin
		tmp<=2'b0;
	end
end //ascynchronously control when should the addition be finished, thus cout could affect v_upper bits value

assign w_upper_plus=v_upper_plus_result[4:0]+tmp[1];    
assign w_upper_minus=v_upper_minus_result[4:0]+tmp[0]; // put lower bits values to the upper w values

//-------------------------PART 1 DONE------------------------------------
//now we have both w_upper values and w_plus,w_minus values

//---------------------PART 2: RAM initilization and addressing--------------------------

// detect when should shifting the w[j] result be available
always@(*) begin //setting conditions
	case(STATE)
		2'b01: begin
			enable_shift_upper_bits<=1'b0;
			if(carry_feedback==1'b1) //this indicates the first cycle in 01 state
				enable_shift<=1'b1;
			else
				enable_shift<=1'b0;
		end
		2'b11: begin
			enable_shift_upper_bits<=1'b1;
			enable_shift<=1'b0;
		end
		default: begin
			enable_shift_upper_bits<=1'b0;
			enable_shift<=1'b0;
		end
	endcase
end

// logic of shifting lower bits
always@(posedge clk) begin
	if(enable_shift==1'b1) begin
		shift_in[1]<=w_plus[3];
		shift_in[0]<=w_minus[3];
	end
	else begin
		shift_in<=2'b0;
	end
end
assign w_plus_shifted={w_plus[2:0],shift_in[1]};
assign w_minus_shifted={w_minus[2:0],shift_in[0]};

//logic of shifting higher bits
always@(posedge clk) begin
	if(enable_shift_upper_bits==1'b1) begin
		w_upper_shifted_plus<={w_upper_plus[4:0],shift_in[1]};
		w_upper_shifted_minus<={w_upper_minus[4:0],shift_in[0]};
	end
end

w_value_ram w_ram({w_plus_shifted,w_minus_shifted},wr_addr,rd_addr,we,clk,{residue_plus,residue_minus});

always@(*)begin
	case(STATE)
		2'b01:begin
			if(carry_feedback==1'b1) begin //this indicates the first cycle in 01 state
				we<=1'b0;
				wr_addr<=computation_cycle;
				rd_addr<=computation_cycle;
			end	
			else begin
				we<=1'b1;
				wr_addr<=computation_cycle;
				rd_addr<=computation_cycle;
			end
		end
		2'b11:begin
			we<=1'b1;
			wr_addr<=computation_cycle;
			rd_addr<=computation_cycle;
		end
		2'b10:begin
			if(computation_cycle) begin
				we<=1'b1;
				wr_addr<=computation_cycle;
				rd_addr<=computation_cycle;
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
	