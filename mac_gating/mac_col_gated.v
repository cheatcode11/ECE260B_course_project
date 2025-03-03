// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
//
//Code is hardcoded for an 8 element vector ie pr = 8
//
module mac_col_gated (clk, reset, out, q_in, q_out, i_inst, fifo_wr, o_inst, q_zero);

parameter bw = 8;
parameter bw_psum = 2*bw+6;
parameter pr = 8;
parameter col_id = 9;

output signed [bw_psum-1:0] out;
input  signed [pr*bw-1:0] q_in;
output signed [pr*bw-1:0] q_out;
input  clk, reset;
input  [1:0] i_inst; // [1]: execute, [0]: load 
output [1:0] o_inst; // [1]: execute, [0]: load 
output fifo_wr;
input [pr-1:0] q_zero;
input [pr-1:0] k_zero;

reg    load_ready_q;
reg    [3:0] cnt_q;
reg    [1:0] inst_q;
reg    [1:0] inst_2q;

//reg   signed [pr*bw-1:0] query_q;
//reg   signed [pr*bw-1:0] key_q;

reg signed [bw-1:0] query_q_0;
reg signed [bw-1:0] query_q_1;
reg signed [bw-1:0] query_q_2;
reg signed [bw-1:0] query_q_3;
reg signed [bw-1:0] query_q_4;
reg signed [bw-1:0] query_q_5;
reg signed [bw-1:0] query_q_6;
reg signed [bw-1:0] query_q_7;

reg signed [bw-1:0] key_q_0;
reg signed [bw-1:0] key_q_1;
reg signed [bw-1:0] key_q_2;
reg signed [bw-1:0] key_q_3;
reg signed [bw-1:0] key_q_4;
reg signed [bw-1:0] key_q_5;
reg signed [bw-1:0] key_q_6;
reg signed [bw-1:0] key_q_7;



reg   [pr-1:0] q_zero_reg;
reg   [pr-1:0] k_zero_reg;

wire  signed [bw_psum-1:0] psum;

assign o_inst = inst_q;
assign fifo_wr = inst_2q[1];
assign q_out  = {{query_q_0},{query_q_1},{query_q_2},{query_q_3},{query_q_4},{query_q_5},{query_q_6},{query_q_7}};
assign out = psum;

mac_8in_gated #(.bw(bw), .bw_psum(bw_psum), .pr(pr)) mac_8in_gated_instance (
	.clk(clk),
	.out(psum),

	.a_0(query_q_0),
	.a_1(query_q_1),
	.a_2(query_q_2),
	.a_3(query_q_3),
	.a_4(query_q_4),
	.a_5(query_q_5),
	.a_6(query_q_6),
	.a_7(query_q_7),

	.b_0(key_q_0),
	.b_1(key_q_1),
	.b_2(key_q_2),
	.b_3(key_q_3),
	.b_4(key_q_4),
	.b_5(key_q_5),
	.b_6(key_q_6),
	.b_7(key_q_7),


	.a_zero(q_zero_reg),
	.b_zero(k_zero_reg)
); 


always @ (posedge clk) begin
  if (reset) begin
    cnt_q <= 0;
    load_ready_q <= 1;
    inst_q <= 0;
    inst_2q <= 0;
  end
  else begin
    inst_q <= i_inst;
    inst_2q <= inst_q;
    if (inst_q[0]) begin

       query_q_0 <= q_in[bw*1-1:bw*0];
       query_q_1 <= q_in[bw*2-1:bw*1];
       query_q_2 <= q_in[bw*3-1:bw*2];
       query_q_3 <= q_in[bw*4-1:bw*3];
       query_q_4 <= q_in[bw*5-1:bw*4];
       query_q_5 <= q_in[bw*6-1:bw*5];
       query_q_6 <= q_in[bw*7-1:bw*6];
       query_q_7 <= q_in[bw*8-1:bw*7];


       if (cnt_q == 9-col_id)begin
         cnt_q <= 0;

         key_q_0 <= q_in[bw*1-1:bw*0];
	 key_q_1 <= q_in[bw*2-1:bw*1];
         key_q_2 <= q_in[bw*3-1:bw*2];
	 key_q_3 <= q_in[bw*4-1:bw*3];
         key_q_4 <= q_in[bw*5-1:bw*4];
	 key_q_5 <= q_in[bw*6-1:bw*5];
         key_q_6 <= q_in[bw*7-1:bw*6];
	 key_q_7 <= q_in[bw*8-1:bw*7];


	 k_zero_reg[0] <= q_zero[0];
	 k_zero_reg[1] <= q_zero[1];
	 k_zero_reg[2] <= q_zero[2];
	 k_zero_reg[3] <= q_zero[3];
	 k_zero_reg[4] <= q_zero[4];
	 k_zero_reg[5] <= q_zero[5];
	 k_zero_reg[6] <= q_zero[6];
	 k_zero_reg[7] <= q_zero[7];


         load_ready_q <= 0;
       end
       else if (load_ready_q)
         cnt_q <= cnt_q + 1;
    end
    else if(inst_q[1]) begin
      //out     <= psum;
       query_q_0 <= q_in[bw*1-1:bw*0];
       query_q_1 <= q_in[bw*2-1:bw*1];
       query_q_2 <= q_in[bw*3-1:bw*2];
       query_q_3 <= q_in[bw*4-1:bw*3];
       query_q_4 <= q_in[bw*5-1:bw*4];
       query_q_5 <= q_in[bw*6-1:bw*5];
       query_q_6 <= q_in[bw*7-1:bw*6];
       query_q_7 <= q_in[bw*8-1:bw*7];

      q_zero_reg[0] <= q_zero[0];
      q_zero_reg[1] <= q_zero[1];
      q_zero_reg[2] <= q_zero[2];
      q_zero_reg[3] <= q_zero[3];
      q_zero_reg[4] <= q_zero[4];
      q_zero_reg[5] <= q_zero[5];
      q_zero_reg[6] <= q_zero[6];
      q_zero_reg[7] <= q_zero[7];



    end

      

  end
end

endmodule

