module ff(clk, in, out, rst);

parameter bw = 8;

input clk;
input [bw-1:0] in;
output reg [bw-1:0] out;
input rst;


always@(posedge clk) begin

	if(rst) out <= {(bw){1'b0}};
	else out <= in;

end
endmodule
