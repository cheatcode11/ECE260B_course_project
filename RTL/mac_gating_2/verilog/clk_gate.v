module clk_gate(clk, en, gated_clk);

input clk;
input en;
output gated_clk;

reg en_latch;

always@(negedge clk)begin

en_latch <= en;

end

assign gated_clk = en_latch && clk;

endmodule
