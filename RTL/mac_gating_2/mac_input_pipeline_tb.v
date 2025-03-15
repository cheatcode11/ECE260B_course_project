module mac_input_pipeline_tb;

reg  clk;
reg  [63:0] in_in;
reg  reset;
reg  [1:0] inst_in; // [1]: execute, [0]: load 

wire   [63:0] in_out;
wire   [1:0] inst_out; // [1]: execute, [0]: load 
wire   [7:0] q_zero;

reg [63:0] out_in_out;
reg [1:0] out_inst_out;
reg [7:0] out_q_zero;

mac_input_pipeline DUT(
.clk(clk),
.reset(reset),
.in_in(in_in),
.inst_in(inst_in),
.in_out(in_out),
.inst_out(inst_out),
.q_zero(q_zero)

);

initial begin

  $dumpfile("mac_input_pipeline_tb.vcd");
  $dumpvars(0,mac_input_pipeline_tb);
clk = 1;
reset = 0;
inst_in = 0;
in_in = 0;

#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0; reset = 1;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0; reset = 0;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0; in_in = 64'hAA_89_32_87_D4_76_90_33;
#0.5 clk = 1;
#0.5 clk = 0;in_in = 64'hAA_89_32_87_D4_76_90_33;
#0.5 clk = 1;
#0.5 clk = 0;in_in = 64'hAA_00_32_33_D4_89_EE_33;
#0.5 clk = 1;
#0.5 clk = 0;in_in = 64'hAA_89_32_00_D4_00_00_33;
#0.5 clk = 1;
#0.5 clk = 0; in_in = 64'hAA_89_32_87_D4_76_90_33;
#0.5 clk = 1;
#0.5 clk = 0;in_in = 64'hD0_00_00_33_D4_19_EE_00;
#0.5 clk = 1;
#0.5 clk = 0;in_in = 64'hAA_00_32_33_D4_89_EE_33;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;


end

always@(posedge clk) begin

out_in_out <= in_out;
out_inst_out <= inst_out;
out_q_zero <= q_zero;

end


endmodule


