module D_FF_two_bits(in,out,clk,enable);

input clk;
input enable;
input[1:0] in;
output[1:0] out;
reg[1:0] out;

initial begin
	out<=2'b0;
end

always@(posedge clk) begin
	if(enable==1'b1) begin
		out<=in;
	end
	else begin
		out<=2'b0;
	end
end

endmodule
