`timescale 1ns/1ps  
module testbench();

reg clk;
/*wire[3:0] residue_plus,residue_minus;
wire[1:0] data_out;*/
reg [1:0] x_value,d_value;

wire[1:0] q_value;
wire[3:0] q_plus_dis,q_minus_dis,d_plus_dis,d_minus_dis,q_plus_sel_dis,q_minus_sel_dis,v_plus_dis,v_minus_dis;
wire[5:0] v_upper_plus_dis,v_upper_minus_dis;
wire read_indicator,carry_feedback,carry_propogate;
wire[1:0] cin,cout;
wire[6:0] computation_cycle_dis;
//wire we_dis;
wire[1:0] STATE;
wire[8:0] cnt_master_dis;
wire[6:0] rd_addr,wr_addr;
wire[5:0] residue_upper_plus,residue_upper_minus;

/*wire[8:0] v_plus,v_minus;
wire[3:0] x_plus_sel_dis,x_minus_sel_dis,y_plus_sel_dis,y_minus_sel_dis;
wire[2:0] sample_V_dis;
wire[1:0] cout_four_bits_dis_one,cout_four_bits_dis_two,cin_four_bits_dis_one,cin_four_bits_dis_two;
wire[8:0]w_plus_dis,w_minus_dis;
wire[3:0] sum_plus,sum_minus;
wire[3:0] z_plus,z_minus;
wire[6:0] write_addr,read_addr;*/
//wire enable_shift_dis,enable_adder_dis;
//wire[8:0] z_plus_dis,z_minus_dis;
integer data_in_file;
integer scan_file;
//integer data_out_file;

On_line_divider divider(clk,x_value,d_value,q_plus_dis,q_minus_dis,d_plus_dis,d_minus_dis,read_indicator,STATE,cnt_master_dis,computation_cycle_dis,q_plus_sel_dis,q_minus_sel_dis,v_upper_plus_dis,v_upper_minus_dis,v_plus_dis,v_minus_dis,cin,cout,carry_feedback,carry_propogate,rd_addr,wr_addr,q_value,residue_upper_plus,residue_upper_minus);



initial begin
	clk=0;
	x_value=2'b0;
	d_value=2'b0;
	while(1)
		#10 clk=~clk;
end
// clock module, 50Mhz clk



initial begin
  data_in_file=$fopen("H:/UROP research/verilog/Online_divider_arbitary_precision/input.txt","r");
 // data_out_file=$fopen("H:/UROP research/verilog/Online_divider_arbitary_precision/output.dat","w");
end

always@(posedge clk) begin
	if(read_indicator)
		scan_file=$fscanf(data_in_file,"%b %b",x_value,d_value);
	 
//	if(STATE==2'b11||(STATE==2'b00&&cnt_dis!=9'b0000&&computation_cycle_dis!=7'b1))
		//$fwrite(data_out_file,"%b\n",data_out);
end

endmodule
