module controller_tb;

reg clk;
reg reset;
reg start;

reg q_full;
reg k_full;
reg ld_done;
reg ofifo_wr;
reg ofifo_full;
reg sfp_ready;
reg int_fifo_full;

wire q_full_wire;
wire k_full_wire;
wire ld_done_wire;
wire ofifo_wr_wire;
wire ofifo_full_wire;
wire sfp_ready_wire;
wire int_fifo_full_wire;


wire [18:0] inst;
wire done;

controller DUT(
 .clk(clk),
 .reset(reset),
 .start(start),
 .q_full(q_full),
 .k_full(k_full),
 .ld_done(ld_done),
 .ofifo_wr(ofifo_wr),
 .ofifo_full(ofifo_full),
 .sfp_ready(sfp_ready),
 .int_fifo_full(int_fifo_full),
 .inst(inst),
 .done(done)
);

integer i,j,k,l;

assign q_full_wire = inst[4] & inst[12] & inst[13] & inst[14];
assign k_full_wire = inst[2] & inst[12] & inst[13] & inst[14];
assign ld_done_wire = inst[3] & inst[12] & inst[13] & inst[14];
assign ofifo_wr_wire = inst[5] & inst[7] & inst[12] & inst[13] & inst[14];
//assign ofifo_full_wire = ofifo_wr_wire;

initial begin

  $dumpfile("controller_tb.vcd");
  $dumpvars(0,controller_tb);

clk = 1;
reset = 0;
start = 0;

q_full = 0;
k_full = 0;
ld_done = 0;
ofifo_wr = 0;
ofifo_full = 0;
sfp_ready = 0;
int_fifo_full = 0;

#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;reset = 1;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;reset = 0;
#0.5 clk = 1;
#0.5 clk = 0;
#0.5 clk = 1;
#0.5 clk = 0;start = 1;
#0.5 clk = 1;
#0.5 clk = 0;start = 0;
#0.5 clk = 1;
#0.5 clk = 0;

for(i = 0; i<64; i=i+1) begin
#0.5 clk = 1;
#0.5 clk = 0;
end


$finish;

end

always@(posedge clk) begin

q_full     <= q_full_wire;
k_full     <= k_full_wire;
ld_done    <= ld_done_wire;
ofifo_wr   <= ofifo_wr_wire;
ofifo_full <= ofifo_wr_wire;


end

endmodule
