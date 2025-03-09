//Creating a latch for clock gating
//Inputs : clk_in, clk_enable
//Outputs: clk_out

module gating_latch(
     signal_in,
     signal_enable,
     reset,
     signal_out
);
input signed [bw-1:0] signal_in;
input signal_enable, reset;
output reg signed [bw-1:0] signal_out;
parameter bw = 8;

always @(*) begin
    if (reset)  
        signal_out <= 'd0;
    else if (signal_enable)
        signal_out <= signal_in;
end
endmodule