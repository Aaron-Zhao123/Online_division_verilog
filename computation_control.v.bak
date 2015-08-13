module computation_control(cnt_master,clk,computation_cycle,enable_for_input,we,STATE);

// this block computes the cycles which are at computation at the moment
// also provides enable for Multiplier to know when to fetch from outside input data and also controls writing to the CA_RAM

//testing
output[1:0] STATE;
// finished

input[8:0] cnt_master;
input clk;

output[6:0] computation_cycle;// this would always be the address
output enable_for_input;
output we;

wire[6:0] cycle_num;
wire[1:0] remainder;
reg[6:0] computation_cycle;
reg enable_for_input;
parameter ZERO_ROW=2'b00;
parameter READ_PRE_LINES=2'b01;
parameter READ_WRITE_NEW_LINE=2'b10;
parameter CLEAR=2'b11;
reg[1:0] STATE;
reg we;
reg[1:0] stay;
initial begin
	computation_cycle=7'b0000000;
	enable_for_input<=1'b1;
	we<=1'b1;
	STATE<=ZERO_ROW;
	stay<=1'b0;
end

assign cycle_num=cnt_master[8:2];
assign remainder=cnt_master[1:0];




always@(posedge clk) begin
	case(STATE)
		ZERO_ROW: begin
			if(cnt_master==9'b11)begin
				we<=1'b0;
			end
			if(cnt_master==9'b100)begin
				stay<=1'b1;
				we<=1'b0;
				computation_cycle<=1'b1;
			end
			if(stay==1'b1)begin
				STATE<=READ_WRITE_NEW_LINE;
				computation_cycle<=cycle_num;
				we<=1'b1;

			end
			else begin
				STATE<=ZERO_ROW;
			end

		end
		
		READ_WRITE_NEW_LINE: begin //10
			we<=1'b0;
			STATE<=READ_PRE_LINES;
							//this value is load

		//	if(cnt_master[1:0]!=2'b11)

			computation_cycle<=computation_cycle-1'b1;

		end
		
		
		READ_PRE_LINES: begin //01
			if(computation_cycle==0) begin
				we<=1'b0;
				STATE<=CLEAR;
				if(cnt_master==9'b111 || cnt_master==9'b1111 || cnt_master==9'b11111 ||cnt_master==9'b111111 ||cnt_master==9'b1111111 || cnt_master==9'b11111111)
					computation_cycle<=cycle_num+1'b1;
				else 
					computation_cycle<=cycle_num;
				
			end
			
			if(computation_cycle>0)begin
				STATE<=READ_PRE_LINES;
				computation_cycle<=computation_cycle-1'b1;
				we<=1'b0;
			end
		end
		
		CLEAR:begin //11

					we<=1'b1;
					STATE<=READ_WRITE_NEW_LINE;
					computation_cycle<=cycle_num;

		end
	endcase	
end

always @(*) begin
	case(STATE)
		ZERO_ROW: begin
			if(cnt_master==9'b100)
				enable_for_input<=1'b0;
			else
				enable_for_input<=1'b1;
		end
		CLEAR:
			enable_for_input=1'b0;
		READ_WRITE_NEW_LINE:
			enable_for_input=1'b0;
		READ_PRE_LINES: begin
			if(computation_cycle==7'b0)
				enable_for_input=1'b1;
			else 
				enable_for_input=1'b0;
		end
		default:
			enable_for_input=1'b1;
	endcase
end
endmodule
