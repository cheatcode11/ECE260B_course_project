// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
//
//Code is hardcoded for an 8 element vector ie pr = 8
//
module mac_col_gated (clk, reset, out, q_in, q_out, i_inst, fifo_wr, o_inst, q_zero, q_zero_out/*, k_zero*/);

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
output reg fifo_wr;
output [pr-1:0] q_zero_out;
input [pr-1:0] q_zero;


reg    load_ready_q;
reg    [3:0] cnt_q;
reg    [1:0] inst_q;
reg    [1:0] inst_2q;


wire signed [bw-1:0] query_q_0;
wire signed [bw-1:0] query_q_1;
wire signed [bw-1:0] query_q_2;
wire signed [bw-1:0] query_q_3;
wire signed [bw-1:0] query_q_4;
wire signed [bw-1:0] query_q_5;
wire signed [bw-1:0] query_q_6;
wire signed [bw-1:0] query_q_7;

reg [pr*bw-1:0] query_q;

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
reg   [pr-1:0] q_zero_reg2;
reg   [pr-1:0] k_zero_reg2;


wire  signed [bw_psum-1:0] psum;

assign o_inst = inst_q;
//assign fifo_wr = inst_2q[1];
assign q_out  = query_q;
assign q_zero_out = q_zero_reg;
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


	.a_zero(q_zero_reg2),  //made change here
	.b_zero(k_zero_reg2)
); 

wire clk_gate_0;
wire clk_gate_1;
wire clk_gate_2;
wire clk_gate_3;
wire clk_gate_4;
wire clk_gate_5;
wire clk_gate_6;
wire clk_gate_7;


clk_gate CLK_GATE_0(.clk(clk), .en(~q_zero_reg[0]), .gated_clk(clk_gate_0));
ff QUERY_Q_0(.clk(clk_gate_0), .in(q_in[bw*1-1:bw*0]), .out(query_q_0), .rst(reset) );

clk_gate CLK_GATE_1(.clk(clk), .en(~q_zero_reg[1]), .gated_clk(clk_gate_1));
ff QUERY_Q_1(.clk(clk_gate_1), .in(q_in[bw*2-1:bw*1]), .out(query_q_1), .rst(reset) );

clk_gate CLK_GATE_2(.clk(clk), .en(~q_zero_reg[2]), .gated_clk(clk_gate_2));
ff QUERY_Q_2(.clk(clk_gate_2), .in(q_in[bw*3-1:bw*2]), .out(query_q_2), .rst(reset) );

clk_gate CLK_GATE_3(.clk(clk), .en(~q_zero_reg[3]), .gated_clk(clk_gate_3));
ff QUERY_Q_3(.clk(clk_gate_3), .in(q_in[bw*4-1:bw*3]), .out(query_q_3), .rst(reset) );

clk_gate CLK_GATE_4(.clk(clk), .en(~q_zero_reg[4]), .gated_clk(clk_gate_4));
ff QUERY_Q_4(.clk(clk_gate_4), .in(q_in[bw*5-1:bw*4]), .out(query_q_4), .rst(reset) );

clk_gate CLK_GATE_5(.clk(clk), .en(~q_zero_reg[5]), .gated_clk(clk_gate_5));
ff QUERY_Q_5(.clk(clk_gate_5), .in(q_in[bw*6-1:bw*5]), .out(query_q_5), .rst(reset) );

clk_gate CLK_GATE_6(.clk(clk), .en(~q_zero_reg[6]), .gated_clk(clk_gate_6));
ff QUERY_Q_6(.clk(clk_gate_6), .in(q_in[bw*7-1:bw*6]), .out(query_q_6), .rst(reset) );

clk_gate CLK_GATE_7(.clk(clk), .en(~q_zero_reg[7]), .gated_clk(clk_gate_7));
ff QUERY_Q_7(.clk(clk_gate_7), .in(q_in[bw*8-1:bw*7]), .out(query_q_7), .rst(reset) );



always @ (posedge clk) begin
  if (reset) begin
    cnt_q <= 0;
    load_ready_q <= 1;
    inst_q <= 0;
    inst_2q <= 0;
    q_zero_reg <= 'd0;
  end
  else begin
    inst_q <= i_inst;
    inst_2q <= inst_q;
    query_q <= q_in;

    if (inst_q[0]) begin

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

	 k_zero_reg2 <= q_zero_reg;

         load_ready_q <= 0;
       end
       else if (load_ready_q)
         cnt_q <= cnt_q + 1;
    end
    else if(inst_q[1]) begin
      
      q_zero_reg2 <= q_zero_reg;

    end

      q_zero_reg <= q_zero;
      fifo_wr = inst_2q[1];
  end
end

endmodule
