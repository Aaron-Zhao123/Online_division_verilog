module testing_stage_two(clk,residue_plus,residue_minus,residue_upper_plus,residue_upper_minus);

input clk;
output[3:0] residue_plus,residue_minus;
output[5:0] residue_upper_plus,residue_upper_minus;
reg[3:0] residue_plus,residue_minus;
reg[5:0] residue_upper_plus,residue_upper_minus;


initial begin
	residue_minus=4'b0;
	residue_plus=4'b0;
	residue_upper_plus=6'b0;
	residue_upper_minus=6'b0;
end

always @(posedge clk) begin
	residue_minus=4'b0;
	residue_plus=4'b0;
	residue_upper_plus=6'b0;
	residue_upper_minus=6'b0;
end


endmodule
