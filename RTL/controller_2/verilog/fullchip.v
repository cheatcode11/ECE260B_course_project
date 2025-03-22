// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module fullchip (clk, mem_in, reset,out, start);

parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 8;//was 16

input  clk; 
input  [pr*bw-1:0] mem_in; 
input  reset;
input start;

//My addition
output [bw_psum*col-1:0] out;

wire [bw_psum+3:0] sum_out_from0;
wire [bw_psum+3:0] sum_out_from1;
wire [bw_psum+3:0] sum_in_to0;
wire [bw_psum+3:0] sum_in_to1;
wire sum_out_ready0;
wire sum_rd_vld0;
wire sum_out_ready1;
wire sum_rd_vld1;

wire o_empty0;
wire o_empty1;
wire o_full0;
wire o_full1;


core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance0 (
      .reset(reset), 
      .clk(clk), 
      .mem_in(mem_in), 
      .out(out),
      .sum_out(sum_out_from0),
      .sum_out_vld(sum_out_vld0),
      .sum_in(sum_in_to0),
      .sum_rd_vld(~o_empty1),
      .fifo_ext_rd(fifo_rd_1to0),
      .start(start)
);

fifo_depth16 #(.bw(bw_psum+4)) fifo_0to1 (
      .rd_clk(clk),
      .wr_clk(clk),
      .rd(fifo_rd_0to1),
      .wr(sum_out_vld0),
      .reset(reset),
      .o_full(o_full0),
      .o_empty(o_empty0),
      .in(sum_out_from0),
      .out(sum_in_to1)
);
fifo_depth16 #(.bw(bw_psum+4)) fifo_1to0 (
      .rd_clk(clk),
      .wr_clk(clk),
      .rd(fifo_rd_1to0),
      .wr(sum_out_vld1),
      .reset(reset),
      .o_full(o_full1),
      .o_empty(o_empty1),
      .in(sum_out_from1),
      .out(sum_in_to0)
);

core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance1 (
      .reset(reset), 
      .clk(clk), 
      .mem_in(mem_in), 
      .out(out),
      .sum_out(sum_out_from1),
      .sum_out_vld(sum_out_vld1),
      .sum_in(sum_in_to1),
      .sum_rd_vld(~o_empty0),
      .fifo_ext_rd(fifo_rd_0to1),
      .start(start)
);


endmodule
