module generate_CA_REG(computation_cycles,x_input,y_input,x_plus,x_minus,y_plus,y_minus,clk,cnt,we);

//This module makes use of a RAM, for which it writes single values of x and y
// reads the x_string and y_string


parameter Num_bits=4;
output[Num_bits-1:0] x_plus,x_minus,y_plus,y_minus;
input clk;
input[8:0] cnt;
input[6:0] computation_cycles;
input[1:0] x_input,y_input;
input we;

wire[6:0] addr;
reg[15:0] tmp_write_data;
wire[15:0] tmp_read_data;
wire[1:0] sel;
/*
//testing module
output[15:0] tmp_read_data_dis;
output[15:0] tmp_write_data_dis;
output[1:0] sel_dis;
output[8:0] cnt_dis;
assign sel_dis=sel;
assign cnt_dis=cnt;
assign tmp_read_data_dis=tmp_read_data;
assign tmp_write_data_dis=tmp_write_data;
//testing declaration finished
*/
initial begin
	tmp_write_data<=16'b0;
end




assign sel=cnt[1:0];
assign addr=computation_cycles;
single_clk_ram	ram1(tmp_write_data,addr,we,clk,tmp_read_data); //read and write to ram at the same time

always@(negedge clk) begin
		if(we==1'b1) begin
			case(sel)
				2'b00:begin
					tmp_write_data<={tmp_read_data[15:4],{x_input[1:0],y_input[1:0]}};
				end
				2'b01:begin
					tmp_write_data<={tmp_read_data[15:8],{x_input[1:0],y_input[1:0]},tmp_read_data[3:0]};
				end
				2'b10:begin
					tmp_write_data<={tmp_read_data[15:12],{x_input[1:0],y_input[1:0]},tmp_read_data[7:0]};
				end
				2'b11:begin
					tmp_write_data<={{x_input[1:0],y_input[1:0]},tmp_read_data[11:0]};
				end
				default:begin
					tmp_write_data<=16'b0;
				end
			endcase
		end
end





assign 		x_plus[3]=tmp_read_data[3];
assign		x_minus[3]=tmp_read_data[2];
assign		y_plus[3]=tmp_read_data[1];
assign		y_minus[3]=tmp_read_data[0];
assign		x_plus[2]=tmp_read_data[7];
assign		x_minus[2]=tmp_read_data[6];
assign		y_plus[2]=tmp_read_data[5];
assign		y_minus[2]=tmp_read_data[4];
assign		x_plus[1]=tmp_read_data[11];
assign		x_minus[1]=tmp_read_data[10];
assign		y_plus[1]=tmp_read_data[9];
assign		y_minus[1]=tmp_read_data[8];
assign		x_plus[0]=tmp_read_data[15];
assign		x_minus[0]=tmp_read_data[14];
assign		y_plus[0]=tmp_read_data[13];
assign		y_minus[0]=tmp_read_data[12];


endmodule
