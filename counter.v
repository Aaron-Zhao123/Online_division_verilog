module counter(enable,clk,cnt);
//simple counter for address tracking

input clk;
input enable;
output[8:0] cnt;

parameter initial_state=1'b0;
parameter start_state=1'b1;

	
reg[8:0] cnt;
reg STATE;
initial begin
	cnt<=9'b000000000;
	STATE<=1'b0;
end

// to initlize cnt value the first cycle and -1 cycle both be 0

always@(posedge clk) begin
	case(STATE)
		initial_state: begin
			cnt<=9'b000000000;
			STATE<=start_state;
		end
		start_state: begin
			if(enable==1'b1) begin
				cnt<=cnt+1'b1;
			end
		end
	endcase
end

endmodule

