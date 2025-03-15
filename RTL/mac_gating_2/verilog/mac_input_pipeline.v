module mac_input_pipeline(clk, reset, in_in, inst_in, in_out, inst_out, q_zero);

parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+6;
parameter pr = 8;

input  clk;
input  [pr*bw-1:0] in_in;
input  reset;
input  [1:0] inst_in; // [1]: execute, [0]: load 

output  reg [pr*bw-1:0] in_out;
output  reg [1:0] inst_out; // [1]: execute, [0]: load 
output  reg [pr-1:0] q_zero;

reg  [pr*bw-1:0] in_out_reg;
reg  [1:0] inst_out_reg; // [1]: execute, [0]: load 

wire [bw-1:0] q_zero_0;
wire [bw-1:0] q_zero_1;
wire [bw-1:0] q_zero_2;
wire [bw-1:0] q_zero_3;
wire [bw-1:0] q_zero_4;
wire [bw-1:0] q_zero_5;
wire [bw-1:0] q_zero_6;
wire [bw-1:0] q_zero_7;



always@(posedge clk) begin
	if(reset) begin
	in_out <= 64'd0;
	inst_out <= 2'b00;
	q_zero <= 8'd0;
	in_out_reg <= 64'd0;
	inst_out_reg <= 2'b00;
        end
	else begin
	q_zero[0] <= q_zero_0;
	q_zero[1] <= q_zero_1;
	q_zero[2] <= q_zero_2;
	q_zero[3] <= q_zero_3;
	q_zero[4] <= q_zero_4;
	q_zero[5] <= q_zero_5;
	q_zero[6] <= q_zero_6;
	q_zero[7] <= q_zero_7;

	in_out_reg <= in_in;
	inst_out_reg <= inst_in;

	in_out <= in_out_reg;
	inst_out <= inst_out_reg;
	
	//in_out <= in_in;
	//inst_out <= inst_in;
	end
end

assign q_zero_0 = ~|in_in[bw*1-1: bw*0];
assign q_zero_1 = ~|in_in[bw*2-1: bw*1];
assign q_zero_2 = ~|in_in[bw*3-1: bw*2];
assign q_zero_3 = ~|in_in[bw*4-1: bw*3];
assign q_zero_4 = ~|in_in[bw*5-1: bw*4];
assign q_zero_5 = ~|in_in[bw*6-1: bw*5];
assign q_zero_6 = ~|in_in[bw*7-1: bw*6];
assign q_zero_7 = ~|in_in[bw*8-1: bw*7];

endmodule
