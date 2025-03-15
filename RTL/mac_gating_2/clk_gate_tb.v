module clk_gate_tb;

reg clk;
reg en;
wire gated_clk;

clk_gate DUT(
.clk(clk),
.en(en),
.gated_clk(gated_clk)
);

initial begin

  $dumpfile("clk_gate_tb.vcd");
  $dumpvars(0,clk_gate_tb);
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0; en =1;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;en = 0;
#0.5 clk = 0;
#0.5 clk = 1;en = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;en = 0;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;en = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;


$finish;

end


endmodule


