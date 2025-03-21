// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module mac_array_wrapper (clk, reset, in, out, fifo_wr, inst);

parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+6;
parameter pr = 8;

input clk;
input reset;
output [bw_psum*col-1:0] out;
input  [pr*bw-1:0] in;
input  [1:0] inst; // [1]: execute, [0]: load 
output [col-1:0] fifo_wr;

wire [pr*bw-1:0] mac_array_in;
wire [pr-1:0] mac_array_q_zero;
wire [1:0] mac_array_inst;

mac_array_gated  #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) MAC_ARRAY(
	.clk(clk),
	.reset(reset),
	.in(mac_array_in),
	.out(out),
	.fifo_wr(fifo_wr),
	.inst(mac_array_inst),
	.q_zero(mac_array_q_zero)

);

mac_input_pipeline MAC_IP(

	.clk(clk),
	.reset(reset),
	.in_in(in),
	.inst_in(inst),
	.in_out(mac_array_in),
	.inst_out(mac_array_inst),
	.q_zero(mac_array_q_zero)
);


endmodule

