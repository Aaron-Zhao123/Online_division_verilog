module four_bits_parallel_adder(x_plus,x_minus,y_plus,y_minus,residue_plus,residue_minus,results_plus,results_minus,z_plus,z_minus,cin_one,cin_two,cout_one,cout_two);
// Parallel adder module with three inputs in signed representation 


parameter bits=4;
input[bits-1:0] x_plus,x_minus,y_plus,y_minus;
input[bits-1:0] residue_minus,residue_plus;


input[1:0] cin_one,cin_two;
output[1:0] cout_one,cout_two;
output[bits-1:0] results_plus,results_minus;
//for testing 
output[bits-1:0] z_plus,z_minus;
//finsihed testing module declaration
wire[1:0] c_temp;


wire[bits-1:0] z_plus_temp,z_minus_temp;

//testing
assign z_plus=z_plus_temp;
assign z_minus=z_minus_temp;
//finished



four_bits_adder	adder1(x_plus,x_minus,y_plus,y_minus,z_plus_temp,z_minus_temp,cin_one,cout_one);



four_bits_adder	adder2(z_plus_temp,z_minus_temp,residue_plus,residue_minus,results_plus,results_minus,cin_two,cout_two);


endmodule


