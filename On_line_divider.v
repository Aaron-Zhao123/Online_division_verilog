module On_line_divider(clk,x_value,d_value,q_plus_vec,q_minus_vec,d_plus_vec,d_minus_vec,enable_input,STATE,cnt_master,computation_cycle,q_plus_sel_dis,q_minus_sel_dis,v_upper_plus_dis,v_upper_minus_dis,v_plus_dis,v_minus_dis,cin_dis,cout_dis,carry_feedback,carry_propogate,rd_addr,wr_addr,q_value,residue_upper_plus_dis,residue_upper_minus_dis);

input clk;
input[1:0] x_value,d_value;
output[1:0] q_value;
wire[1:0] q_value;
output[3:0] q_plus_vec,q_minus_vec,d_plus_vec,d_minus_vec;
output enable_input;
wire[1:0] d_delayed;
wire[3:0] q_plus_selected,q_minus_selected,d_plus_selected,d_minus_selected;
wire we_input_ram;
wire[3:0] residue_plus,residue_minus,w_value_plus,w_value_minus;
wire[3:0] v_plus,v_minus,v_plus_new,v_minus_new;
wire[5:0] residue_upper_plus,residue_upper_minus;
wire[5:0] v_upper_plus_result,v_upper_minus_result;
output[1:0] STATE;
output[8:0] cnt_master;
output[6:0] computation_cycle;

output[5:0] residue_upper_plus_dis,residue_upper_minus_dis;
assign residue_upper_plus_dis=residue_upper_plus;
assign residue_upper_minus_dis=residue_upper_minus;
wire[1:0] cin_one,cout_one,cin_two,cout_two;

//-------------------------- STAGE 1-----------------------------------------------
//testing for STAGE 1
//output[15:0] tmp_read_data_dis;
//output[15:0] tmp_write_data_dis;
//output[1:0] sel_dis;
//output[8:0] cnt_dis;
// test declarations finished

// stage one: storing a input and outputing input vecs
counter count(enable_input,clk,cnt_master);
computation_control FSM(cnt_master,clk,computation_cycle,enable_input,we_input_ram,STATE);
generate_CA_REG	CA_REG(computation_cycle,q_value,d_value,q_plus_vec,q_minus_vec,d_plus_vec,d_minus_vec,clk,cnt_master,we_input_ram);
// -----------------------------STAGE 1 finished------------------------------


//----------------------------STAGE 2-----------------------------
//stage two includes SDVM block,a [2:1]ADDER and also V_upper_bits reg and corresponding adder_logic block
// 4 bits wide addition of three numbers is performed, includes the effect of x_value as well

// testing procedures
output[3:0] q_plus_sel_dis,q_minus_sel_dis;
//output[3:0] d_plus_sel_dis,d_minus_sel_dis;
assign q_plus_sel_dis=q_plus_selected;
assign q_minus_sel_dis=q_minus_selected;
//assign d_plus_sel_dis=d_plus_selected;
//assign d_minus_sel_dis=d_minus_selected;
 
output[5:0] v_upper_plus_dis,v_upper_minus_dis;  
assign v_upper_plus_dis=v_upper_plus_result;
assign v_upper_minus_dis=v_upper_minus_result;
output[3:0] v_plus_dis,v_minus_dis;
assign v_plus_dis=v_plus_new;
assign v_minus_dis=v_minus_new;
output[1:0] cin_dis,cout_dis;
assign cin_dis=cin_one;
assign cout_dis=cout_one;
output carry_feedback,carry_propogate;
//finished testing

D_FF_two_bits D(d_value,d_delayed,clk,1'b1);
SDVM selector1(clk,q_plus_vec,q_minus_vec,~d_delayed,q_plus_selected,q_minus_selected);
four_bits_adder adder1(q_plus_selected,q_minus_selected,residue_plus,residue_minus,v_plus,v_minus,cin_one,cout_one);
V_value_logic adder1_logic(x_value,v_plus,v_minus,v_plus_new,v_minus_new,clk,cnt_master,computation_cycle,STATE,residue_upper_plus,residue_upper_minus,cout_one,v_upper_plus_result,v_upper_minus_result,cin_one,carry_feedback,carry_propogate);

//--------------------------STAGE 2 finished----------------------------

//-------------------------------------STAGE 3----------------------------------
// stage three contains V block, SELD bolck, thus the output qj+1 could be calculated

SDVM selector2(clk,d_plus_vec,d_minus_vec,q_value,d_plus_selected,d_minus_selected);
V_block Sample(v_upper_plus_result,v_upper_minus_result,q_value);

//-------------------------------STAGE 4----------------------------------
// [2:1] adder and residue ram
//wired shift before storing to the ram
output[6:0] rd_addr,wr_addr;

four_bits_adder adder2(v_plus_new,v_minus_new,d_plus_selected,d_minus_selected,w_value_plus,w_value_minus,cin_two,cout_two);

w_value_logic W_block(computation_cycle,STATE,clk,v_upper_plus_result,v_upper_minus_result,w_value_plus,w_value_minus,carry_feedback,carry_propogate,cin_two,cout_two,residue_plus,residue_minus,rd_addr,wr_addr,residue_upper_plus,residue_upper_minus);





endmodule
