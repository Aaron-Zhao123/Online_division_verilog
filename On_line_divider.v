module On_line_divider(clk,x_value,d_value,q_plus_vec,q_minus_vec,d_plus_vec,d_minus_vec,enable_input,STATE,cnt_master,computation_cycle,q_plus_sel_dis,q_minus_sel_dis,v_upper_plus_dis,v_upper_minus_dis,v_plus_dis,v_minus_dis,cin_dis,cout_dis,carry_feedback,carry_propogate,rd_addr,wr_addr,q_value,residue_upper_plus_dis,residue_upper_minus_dis,w_upper_plus,w_upper_minus,w_plus,w_minus,residue_plus_dis,residue_minus_dis,we_w_ram,w_plus_shifted_dis,w_minus_shifted_dis,d_plus_sel_dis,d_minus_sel_dis,carry_feedback_two,carry_propogte_two,d_plus_add_dis,d_minus_add_dis,tmp_read_data_dis,tmp_write_data_dis,sel_dis,d_upper_plus_dis,d_upper_minus_dis,d_upper_plus_add_dis,d_upper_minus_add_dis,cnt_d,cnt_p,borrower_up_dis,addr_p_write,error_flag_dis,fixing_dis);
output error_flag_dis;
input clk;
input[1:0] x_value,d_value;
output[1:0] q_value;
wire[1:0] q_value;
output[3:0] q_plus_vec,q_minus_vec,d_plus_vec,d_minus_vec;
output enable_input;
wire[1:0] d_delayed,x_delayed;
wire[3:0] q_plus_selected,q_minus_selected,d_plus_selected,d_minus_selected;
wire we_input_ram;
wire[3:0] residue_plus,residue_minus,w_value_plus,w_value_minus;
wire[3:0] v_plus,v_minus,v_plus_new,v_minus_new;
wire[3:0] residue_upper_plus,residue_upper_minus;
wire[3:0] v_upper_plus_result,v_upper_minus_result;
wire[3:0] q_vec_out_plus,q_vec_out_minus;
output[1:0] STATE;
output[8:0] cnt_master;
output[6:0] computation_cycle;
output[7:0] tmp_read_data_dis;
output[7:0] tmp_write_data_dis;
output[8:0] cnt_d,cnt_p;

output[6:0] addr_p_write;
output[1:0] sel_dis;
output[1:0] d_upper_plus_dis,d_upper_minus_dis;
output[3:0] residue_upper_plus_dis,residue_upper_minus_dis;
assign residue_upper_plus_dis=residue_upper_plus;
assign residue_upper_minus_dis=residue_upper_minus;
wire[1:0] cin_one,cout_one,cin_two,cout_two;
wire[1:0] d_upper_plus,d_upper_minus;
assign d_upper_plus_dis=d_upper_plus;
assign d_upper_minus_dis=d_upper_minus;
wire borrower_up;
output borrower_up_dis;
assign borrower_up_dis=borrower_up;
wire error_flag;
assign error_flag_dis=error_flag;
//-------------------------- STAGE 1-----------------------------------------------
//testing for STAGE 1
//output[15:0] tmp_read_data_dis;
//output[15:0] tmp_write_data_dis;
//output[1:0] sel_dis;
//output[8:0] cnt_dis;
// test declarations finished

// stage one: storing a input and outputing input vecs
output fixing_dis;
wire fixing;

assign fixing_dis=fixing;
wire[1:0] prev_q;
counter count(enable_input,clk,cnt_master);
computation_control FSM(cnt_master,clk,computation_cycle,enable_input,we_input_ram,STATE,q_value,error_flag,fixing,prev_q);
generate_CA_REG	CA_REG(STATE,rd_addr,addr_p_write,computation_cycle,d_value,q_value,d_plus_vec,d_minus_vec,q_plus_vec,q_minus_vec,clk,cnt_master,cnt_d,cnt_p,error_flag,we_input_ram,tmp_read_data_dis,tmp_write_data_dis,sel_dis,d_upper_plus,d_upper_minus,fixing);
// -----------------------------STAGE 1 finished------------------------------


//----------------------------STAGE 2-----------------------------
//stage two includes SDVM block,a [2:1]ADDER and also V_upper_bits reg and corresponding adder_logic block
// 4 bits wide addition of three numbers is performed, includes the effect of x_value as well

// testing procedures
output[3:0] q_plus_sel_dis,q_minus_sel_dis;
output[3:0] d_plus_sel_dis,d_minus_sel_dis;
assign q_plus_sel_dis=q_vec_out_plus;
assign q_minus_sel_dis=q_vec_out_minus;
assign d_plus_sel_dis=d_plus_selected;
assign d_minus_sel_dis=d_minus_selected;
 
output[3:0] v_upper_plus_dis,v_upper_minus_dis;  
assign v_upper_plus_dis=v_upper_plus_result;
assign v_upper_minus_dis=v_upper_minus_result;
output[3:0] v_plus_dis,v_minus_dis;
assign v_plus_dis=v_plus_new;
assign v_minus_dis=v_minus_new;
output[1:0] cin_dis,cout_dis;
assign cin_dis=cin_two;
assign cout_dis=cout_one;
output carry_feedback,carry_propogate;

//finished testing


// because q[j] value is used, q_vec_control provides this vec available
//q_vec_control vec_control(cnt_master,computation_cycle,clk,q_plus_vec,q_minus_vec,d_value,STATE,q_vec_out_plus,q_vec_out_minus);

SDVM selector1(clk,q_plus_vec,q_minus_vec,~d_value,q_vec_out_plus,q_vec_out_minus);

four_bits_adder adder1(q_vec_out_plus,q_vec_out_minus,residue_plus,residue_minus,v_plus,v_minus,cin_one,cout_one);

D_FF_two_bits D2(x_value,x_delayed,clk,1'b1);

V_value_logic adder1_logic(cnt_master,x_delayed,v_plus,v_minus,v_plus_new,v_minus_new,clk,cnt_master,computation_cycle,STATE,residue_upper_plus,residue_upper_minus,cout_one,v_upper_plus_result,v_upper_minus_result,cin_one,carry_feedback,carry_propogate,borrower_up);

//--------------------------STAGE 2 finished----------------------------

//-------------------------------------STAGE 3----------------------------------
// stage three contains V block, SELD bolck, thus the output qj+1 could be calculated

SDVM selector2(clk,d_plus_vec,d_minus_vec,~q_value,d_plus_selected,d_minus_selected);
V_block Sample(v_upper_plus_result,v_upper_minus_result,q_value,borrower_up,fixing,prev_q);

//-------------------------------STAGE 4----------------------------------
// [2:1] adder and residue ram
//wired shift before storing to the ram
//testing procedures
output[6:0] rd_addr,wr_addr;
output[3:0] w_upper_plus,w_upper_minus;
output[3:0] w_plus,w_minus,w_plus_shifted_dis,w_minus_shifted_dis,residue_plus_dis,residue_minus_dis,d_plus_add_dis,d_minus_add_dis;
output we_w_ram,carry_feedback_two,carry_propogte_two;
output[3:0] d_upper_plus_add_dis,d_upper_minus_add_dis;

wire[3:0] d_plus_add,d_minus_add;
assign d_plus_add_dis=d_plus_add;
assign d_minus_add_dis=d_minus_add;
assign w_plus=w_value_plus;
assign w_minus=w_value_minus;
assign residue_minus_dis=residue_minus;
assign residue_plus_dis=residue_plus;

four_bits_adder adder2(v_plus_new,v_minus_new,d_plus_add,d_minus_add,w_value_plus,w_value_minus,cin_two,cout_two);

w_value_logic_fix W_block(STATE,cnt_master,computation_cycle,clk,carry_feedback,v_upper_plus_result,v_upper_minus_result,d_plus_selected,d_minus_selected,w_value_plus,w_value_minus,d_plus_add,d_minus_add,w_plus_shifted_dis,w_minus_shifted_dis,residue_plus,residue_minus,w_upper_plus,w_upper_minus,residue_upper_plus,residue_upper_minus,cout_two,cin_two,carry_feedback_two,carry_propogte_two,rd_addr,wr_addr,we_w_ram,d_upper_plus,d_upper_minus,d_upper_plus_add_dis,d_upper_minus_add_dis,q_value,error_flag);




endmodule
