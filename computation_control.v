module computation_control(cnt_master,clk,computation_cycle,enable_for_input,we,STATE,q_value,error_flag,fixing,q_previous);

// this block computes the cycles which are at computation at the moment
// also provides enable for Multiplier to know when to fetch from outside input data and also controls writing to the CA_RAM

//testing
input [1:0] q_value;
output [1:0] q_previous;
reg [1:0] q_previous;
output[1:0] STATE;
// finished

input[8:0] cnt_master;
input clk;

output[6:0] computation_cycle;// this would always be the address
output enable_for_input;
output we;

wire[1:0] remainder;
wire[6:0] cycle_num;
reg[6:0] computation_cycle;
reg enable_for_input;
parameter READ_ONLY=2'b01;
parameter READ_WRITE_NEW_LINE=2'b10;
parameter CLEAR=2'b11;
parameter Error=2'b00;
reg[1:0] STATE;
reg we;
initial begin
	computation_cycle=7'b0000000;
	enable_for_input<=1'b1;
	we<=1'b1;
	STATE<=READ_WRITE_NEW_LINE;
end

assign cycle_num=cnt_master[8:2];
assign remainder=cnt_master[1:0];

output fixing;
output error_flag;
reg error_flag;
reg fixing;

initial begin
	q_previous<=2'b0;
	error_flag<=1'b0;
	fixing<=1'b0;
end

always@(posedge clk) begin
	q_previous<=q_value;
end


always@(*) begin
	error_flag<=1'b0;
	if(STATE==2'b11&&fixing==1'b0) begin
		if(q_value!=q_previous)begin
			error_flag<=1'b1;
		end
	end
end


always@(posedge clk) begin
	case(STATE)
		READ_WRITE_NEW_LINE: begin //10

							//this value is load

		//	if(cnt_master[1:0]!=2'b11)
			
			if(computation_cycle==7'b0&&remainder==2'b11) begin // use remainder to identify when to end for Zero Row
				we<=1'b0;
				STATE<=READ_WRITE_NEW_LINE;
				computation_cycle<=cycle_num+1'b1;

			end
			else if (remainder==2'b00&&cnt_master!=9'b0) begin
				computation_cycle<=cycle_num;
				STATE<=READ_ONLY;
				we<=1'b1;

			end
			else if(computation_cycle==7'b0&&remainder!=2'b11)begin
				we<=1'b1;
				STATE<=READ_WRITE_NEW_LINE;
				computation_cycle<=cycle_num;
			
			end
			else begin
				we<=1'b0;
				STATE<=READ_ONLY;
				computation_cycle<=cycle_num-1'b1;
			end
		end
		
		
		READ_ONLY: begin //01
		
			if(computation_cycle==0) begin
				we<=1'b0;
				STATE<=CLEAR;
				if(remainder==2'b11) begin
					computation_cycle<=cycle_num+1'b1;
				end
				else begin
				computation_cycle<=cycle_num;
				end
			end
			
			if(computation_cycle>0)begin
				STATE<=READ_ONLY;
				computation_cycle<=computation_cycle-1'b1;
				we<=1'b0;
			end
			
		/*	if(fixing==1'b1) begin
			*/	
		end
		
		CLEAR:begin //11


					STATE<=READ_WRITE_NEW_LINE;
					if(remainder==2'b11) begin
						computation_cycle<=cycle_num+1'b1;
						we<=1'b0;
					end 
					else begin
						computation_cycle<=cycle_num;
						we<=1'b1;
					end
					if(error_flag==1'b1) begin
						STATE<=Error;
						we<=1'b0;
						fixing<=1'b1;
					end
					if(fixing==1'b1) begin
						fixing<=1'b0;
					end
		end
		
		Error: begin //00
				if(computation_cycle>0)begin
					STATE<=Error;
					computation_cycle<=computation_cycle-1'b1;
					we<=1'b0;
				end
				if(computation_cycle==0) begin
					we<=1'b0;
					STATE<=CLEAR;	
					fixing<=1'b1;
				end
		end
	endcase	
end

always @(*) begin
	case(STATE)
		CLEAR:begin//11
			if(error_flag==1'b1) begin
				enable_for_input=1'b0;
			end
			else begin
				enable_for_input=1'b1;
			end
		end
		READ_WRITE_NEW_LINE: begin//10 state
			enable_for_input=1'b1;
			if (remainder==2'b00&&cnt_master!=9'b0) begin
				enable_for_input=1'b0;
			end
			if (cycle_num!= 7'b0) 
				enable_for_input=1'b0;
		end	
		READ_ONLY: begin //01 state
			enable_for_input=1'b0;
			
		end
		default:
			enable_for_input=1'b1;
	endcase
end
endmodule
