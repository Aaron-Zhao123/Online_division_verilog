module generate_CA_REG(STATE,rd_addr,addr_p_write,computation_cycles,x_input,p_input,x_plus,x_minus,p_plus,p_minus,clk,cnt,cnt_d,cnt_p,error_flag,we,tmp_read_data_dis,tmp_write_data_dis,sel_dis,d_upper_plus,d_upper_minus,fixing);

//This module makes use of a RAM, for which it writes single values of x and y
// reads the x_string and y_string

input error_flag;
parameter Num_bits=4;
output[Num_bits-1:0] x_plus,x_minus,p_plus,p_minus;
input clk;
input[8:0] cnt;
input[6:0] computation_cycles;
wire[6:0] comp_cycle_d,comp_cycle_p;
input[1:0] x_input,p_input;
input[1:0] STATE;
input we;
input fixing;

input[6:0] rd_addr;
reg[6:0] rd_addr_delayed;
output[8:0] cnt_d,cnt_p;
reg[6:0] addr_d_read,addr_d_write;
output[6:0] addr_p_write;
reg[6:0] addr_p_read,addr_p_write;
wire[8:0] cnt_d;
reg[8:0] cnt_p;
reg start_p,start;
reg we_p;
reg we_d;
reg clear;

output[1:0] d_upper_plus,d_upper_minus;
reg[1:0] d_upper_plus,d_upper_minus;
reg[7:0] tmp_write_data_x,tmp_write_data_p;
wire[7:0] tmp_read_data_x,tmp_read_data_p;
wire[1:0] sel;
wire[1:0] sel_p,sel_d;
//reg[1:0] sel_p_chosen,sel_p_delayed;
reg we_d_one,we_d_two,we_d_three,we_d_four;

//testing module
output[7:0] tmp_read_data_dis;
output[7:0] tmp_write_data_dis;
reg[7:0] tmp_data_p;
output[1:0] sel_dis;
assign sel_dis=sel;
assign tmp_read_data_dis=tmp_read_data_p;
assign tmp_write_data_dis=tmp_write_data_p;
//testing declaration finished



initial begin
	tmp_write_data_x<=8'b0;
	tmp_write_data_p=8'b0;
	tmp_data_p<=8'b0;
	d_upper_plus<=2'b0;
	d_upper_minus<=2'b0;
	start<=1'b0;
	we_p<=1'b1;
	we_d<=1'b1;
	cnt_p<=9'b0;
	we_d_one<=1'b0;
	we_d_two<=1'b0;
	we_d_three<=1'b0;
	we_d_four<=1'b0;
	addr_p_read<=7'b0;
	clear<=1'b0;
	rd_addr_delayed<=7'b0;
	//sel_p_chosen<=2'b0;
	//sel_p_delayed<=2'b0;
end
/*
always@(*)begin 
	case(	)
		2'b10:begin
			if(computation_cycles==7'b0||cnt[1:0]==2'b00)begin
				we_p<=1'b1;
			end
			else begin
				we_p<=1'b0;
			end
		end
		2'b11:
			we_p<=1'b1;
		default:
			we_p<=1'b0;
	endcase
end
*/
assign cnt_d=cnt-9'b10;

assign comp_cycle_d=cnt_d[8:2];
assign comp_cycle_p=cnt_p[8:2];
/*
always@(*) begin
	
	if(STATE==2'b10) begin
		if(computation_cycles==7'b0)begin
			cnt_p<=cnt-9'b11;
		end
		else if(cnt[1:0]==2'b00) begin
		 cnt_p<=cnt-9'b11;
		end
		else begin 
			cnt_p<=cnt-9'b11;
		end
	end
	else begin 
		cnt_p<=cnt-9'b11;
	end
	
end
*/

always@(posedge clk) begin
	if(error_flag==1'b0) begin
		if(STATE==2'b10) begin
			if(cnt<9'b10)begin
				cnt_p<=9'b0;
			end
			else if(cnt==9'b11||cnt==9'b100) begin
				cnt_p<=cnt_p+9'b1;
			end
		end
		if(STATE==2'b11) begin
			cnt_p<=cnt_p+9'b1;
		end
	end
end
/*
//addressing of d vector
always@(*) begin
	case(	):
		2'b10: begin
			if(computation_cycles==7'b0||cnt[1:0]==2'b00) begin //zero row control of addresing of d vec and p vec						
				if(cnt<8'b10) begin //declaration of d _vec
					addr_d_read<=7'b0;
					addr_d_write<=7'b0;
					cnt_d<=9'b0;
					start<=1'b0;
				end
				else if (cnt==2'b10) begin
					addr_d_read<=7'b0;
					addr_d_write<=7'b0;
					cnt_d<=9'b0;
					start<=1'b1;	
				end
				else begin
					cnt_d<=cnt-8'b10;
					addr<=cnt_d[8:2];
					start<=1'b1;
				end
				
				we_p<=1'b1;           //declaration of p_vec
				if(cnt<=8'b11) begin  
					addr_p<=7'b0;
					cnt_p<=9'b0;
				end
				else begin
					cnt_p<=cnt-8'b11;
					addr_p<=cnt_p[8:2];
				end
			end	
		end

end
*/

always@(*)  begin//d vec addressing logic
	if(STATE==2'b10)begin //zero row operation
		if((computation_cycles==7'b0||cnt[1:0]==2'b00))begin
			start<=1'b0;
			if(cnt<8'b10) begin //declaration of d _vec
				start<=1'b0;
				addr_d_read<=7'b0;
				addr_d_write<=comp_cycle_d;
			end
			else if (cnt==2'b10) begin
				start<=1'b1;
				addr_d_read<=7'b0;
				addr_d_write<=comp_cycle_d;
			end
			else begin
				start<=1'b1;
				addr_d_read<=rd_addr;
				addr_d_write<=comp_cycle_d;
			end
		end
		else begin   // load in a new value at the start, which is in state 10
			addr_d_write<=comp_cycle_d;
			start<=1'b1;
			we_d<=1'b1;
			addr_d_read<=rd_addr;
		end
	end
	else if (STATE==2'b01&&computation_cycles==7'b0) begin
		start<=1'b0;
		we_d<=1'b0;
		addr_d_write<=comp_cycle_d;
		addr_d_read<=rd_addr;			
	end
	else if(STATE==2'b11)begin
		start<=1'b0;
		we_d<=1'b0;
		addr_d_write<=comp_cycle_d;
		addr_d_read<=rd_addr;		
	end

	else begin
		start<=1'b0;
		we_d<=1'b0;
		addr_d_write<=comp_cycle_d;
		addr_d_read<=rd_addr;
	end
end



assign sel_p=cnt_p[1:0];
assign sel_d=cnt_d[1:0];
assign sel=cnt[1:0];

always@(posedge clk)begin
	rd_addr_delayed<=rd_addr;
	if(cnt<=8'b10)
		case(sel)
			2'b00:begin
				d_upper_plus<={x_input[1],d_upper_plus[0]};
				d_upper_minus<={x_input[0],d_upper_minus[0]};
			end
			2'b01:begin
				d_upper_plus<={d_upper_plus[1],x_input[1]};
				d_upper_minus<={d_upper_minus[1],x_input[0]};
			end

			default:begin
				d_upper_plus<=d_upper_plus;
				d_upper_minus<=d_upper_minus;
			end
		endcase
end

reg flag_full;
initial begin
	flag_full<=1'b0;
end





single_clk_ram ram_p(tmp_write_data_p,addr_p_write,addr_p_read,we_p,clk,tmp_read_data_p);

always@(*) begin // deciding output value 
	if(cnt_p[1:0]!=2'b00) begin
		
		if(comp_cycle_p==rd_addr_delayed&&STATE!=2'b10) begin
			tmp_data_p=tmp_write_data_p;
		end
		else begin
			tmp_data_p=tmp_read_data_p;
		end
	end
	
	else begin	
		if(comp_cycle_p==rd_addr_delayed&&STATE!=2'b10)begin
			tmp_data_p=tmp_write_data_p;
		end

		else begin
			tmp_data_p=tmp_read_data_p;
		end
	end
	
end

// condition when pipelining fails
/*
always @(posedge clk) begin //this always reserve the prevs value of tmp_p_string
	if(STATE==2'b11) begin
		tmp_write_reserve<=tmp_write_data_p;
	end
end

always@(*) begin
	if(STATE==2'b10) begin
		if((computation_cycles==7'b0||cnt[1:0]==2'b00))begin
			sel_p_chosen<=sel_p;
		end
		else begin
			sel_p_chosen<=sel_p_delayed;
		end
	end
	else begin
		sel_p_chosen<=sel_p;
	end
end

always@(posedge clk)begin
	sel_p_delayed=sel_p;
end
*/

always@(posedge clk) begin //refreshing value of tmp_write
	if(clear==1'b1) begin
		tmp_write_data_p<=8'b0;
	end

	else begin	
		if(start_p==1'b1) begin
				case(sel_p)
					2'b00:begin
						tmp_write_data_p[1:0]<=p_input[1:0];		
					end
					2'b01:begin
						tmp_write_data_p[3:2]<=p_input[1:0];
					end
					2'b10:begin
						tmp_write_data_p[5:4]<=p_input[1:0];
					end
					2'b11:begin
						tmp_write_data_p[7:6]<=p_input[1:0];

					end
					default:begin
						tmp_write_data_p=8'b0;
						end
				endcase
		end
		
	end
end
	
always@(*) begin
	if(STATE==2'b11&&sel_p==2'b11)begin
		flag_full<=1'b1;
	end
	else begin
		flag_full<=1'b0;
	end
end
always@(*) begin //start_p logic, outside the ram

	if(flag_full==1'b1) begin
		if(STATE==2'b11) begin
			we_p<=1'b1;
		end
		else begin
			we_p<=1'b0;
		end
		addr_p_write<=comp_cycle_p;
	end
	else begin
		we_p<=1'b0;
		addr_p_write<=comp_cycle_p;
	end
	
end
always@(*) begin //p vec addressing logic
	addr_p_read<=rd_addr;
	clear<=1'b0;
	if(STATE==2'b10) begin
			if(computation_cycles==7'b0||cnt[1:0]==2'b00)begin
				start_p<=1'b1;           
				if(cnt<=8'b01) begin  
					start_p<=1'b0; 
				end
				else begin
					start_p<=1'b1; 
				end
			end

			else begin
				start_p<=1'b0; 
			end
	end
	else if(STATE==2'b11) begin
			start_p<=1'b1;
			if(error_flag==1'b1) begin
				start_p<=1'b0;
				clear<=1'b0;
			end   //dealing with pipelining broken
			else if(flag_full==1'b1) begin
				start_p<=1'b0;
				clear<=1'b1;
			end
			else begin
				clear<=1'b0;
			end
	end
	else if(STATE==2'b00&&computation_cycles==7'b0) begin
		start_p<=1'b1;
		if(flag_full) begin
			start_p<=1'b0;
			clear<=1'b1;
		end
		else begin
			clear<=1'b0;
		end
	end
	else if(flag_full==1'b1) begin
		clear<=1'b1;
		start_p<=1'b0;
	end
	else begin
		start_p<=1'b0;
	end

	
end


/*
always@(negedge clk)begin
		if(we_p==1'b1) begin
			case(sel_p)
				2'b00:begin
					tmp_write_data_p<={tmp_read_data_p[7:2],p_input[1:0]};
				end
				2'b01:begin
					tmp_write_data_p<={tmp_read_data_p[7:4],p_input[1:0],tmp_read_data_p[1:0]};
				end
				2'b10:begin
					tmp_write_data_p<={tmp_read_data_p[7:6],p_input[1:0],tmp_read_data_p[3:0]};
				end
				2'b11:begin
					tmp_write_data_p<={p_input[1:0],tmp_read_data_p[5:0]};
				end
				default:begin
					tmp_write_data_p<=8'b0;
				end
			endcase
		end

end
*/
single_clk_ram_2bit ram1(x_input,addr_d_write,addr_d_read,we_d_one,clk,tmp_read_data_x[7:6]); //read and write to ram at the same time
single_clk_ram_2bit ram2(x_input,addr_d_write,addr_d_read,we_d_two,clk,tmp_read_data_x[5:4]);
single_clk_ram_2bit ram3(x_input,addr_d_write,addr_d_read,we_d_three,clk,tmp_read_data_x[3:2]);
single_clk_ram_2bit ram4(x_input,addr_d_write,addr_d_read,we_d_four,clk,tmp_read_data_x[1:0]);

always@(*) begin
	if(start==1'b1)begin
		case(sel_d)
			2'b00:begin
				we_d_one<=1'b1;
				we_d_two<=1'b0;
				we_d_three<=1'b0;
				we_d_four<=1'b0;
			end
			2'b01:begin
				we_d_one<=1'b0;
				we_d_two<=1'b1;
				we_d_three<=1'b0;
				we_d_four<=1'b0;
			end
			2'b10:begin
				we_d_one<=1'b0;
				we_d_two<=1'b0;
				we_d_three<=1'b1;
				we_d_four<=1'b0;
			end
			2'b11:begin
				we_d_one<=1'b0;
				we_d_two<=1'b0;
				we_d_three<=1'b0;
				we_d_four<=1'b1;
			end
			default:begin
				we_d_one<=1'b0;
				we_d_two<=1'b0;
				we_d_three<=1'b0;
				we_d_four<=1'b0;
			end
		endcase
	end
	else begin
		we_d_one<=1'b0;
		we_d_two<=1'b0;
		we_d_three<=1'b0;
		we_d_four<=1'b0;
	end
end


/*
always@(negedge clk) begin
		if(we_d==1'b1&&start==1'b1) begin
			case(sel_d)
				2'b00:begin
					tmp_write_data_x<={tmp_read_data_x[7:2],x_input[1:0]};
				end
				2'b01:begin
					tmp_write_data_x<={tmp_read_data_x[7:4],x_input[1:0],tmp_read_data_x[1:0]};
				end
				2'b10:begin
					tmp_write_data_x<={tmp_read_data_x[7:6],x_input[1:0],tmp_read_data_x[3:0]};
				end
				2'b11:begin
					tmp_write_data_x<={x_input[1:0],tmp_read_data_x[5:0]};
				end
				default:begin
					tmp_write_data_x<=8'b0;
				end
			endcase
		end
		else if(start==1'b0&&we==1'b1) begin
			tmp_write_data_x<=8'b0;
		end
		
end
*/



assign 		x_plus[3]=tmp_read_data_x[7];
assign		x_minus[3]=tmp_read_data_x[6];

assign		p_plus[3]=tmp_data_p[1];
assign		p_minus[3]=tmp_data_p[0];

assign		x_plus[2]=tmp_read_data_x[5];
assign		x_minus[2]=tmp_read_data_x[4];


assign		p_plus[2]=tmp_data_p[3];
assign		p_minus[2]=tmp_data_p[2];

assign		x_plus[1]=tmp_read_data_x[3];
assign		x_minus[1]=tmp_read_data_x[2];

assign		p_plus[1]=tmp_data_p[5];
assign		p_minus[1]=tmp_data_p[4];

assign		x_plus[0]=tmp_read_data_x[1];
assign		x_minus[0]=tmp_read_data_x[0];

assign		p_plus[0]=tmp_data_p[7];
assign		p_minus[0]=tmp_data_p[6];


endmodule
