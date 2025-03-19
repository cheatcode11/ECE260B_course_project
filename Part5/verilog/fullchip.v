// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module fullchip (clk1, clk0, mem_in0, mem_in1, inst, reset,out);

parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 8;//was 16

input  clk0;
input   clk1;
input  [pr*bw-1:0] mem_in0;
input  [pr*bw-1:0] mem_in1;
input  [19:0] inst; 
input  reset;

//My addition
output [2*col*bw_psum-1:0] out;

wire [bw_psum+3:0] sum_out_from0;
wire [bw_psum+3:0] sum_out_from1;
wire [bw_psum+3:0] sum_in_to0;
wire [bw_psum+3:0] sum_in_to1;
wire sum_out_vld0;
wire sum_rd_vld0;
wire sum_out_vld1;
wire sum_rd_vld1;

wire o_empty0;
wire o_empty1;
wire o_full0;
wire o_full1;



core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance0 (
      .reset(reset), 
      .clk(clk0), 
      .mem_in(mem_in0), 
      .inst(inst),
      .out(out[col*bw_psum-1:0]),
      .sum_out(sum_out_from0),
      .sum_out_vld(sum_out_vld0),
      .sum_in(sum_in_to0),
      .sum_rd_vld(~o_empty1),
      .fifo_ext_rd(fifo_rd_1to0)
);

async_fifo #(.data_width(bw_psum+4)) fifo_0to1 (
      .wr_clk(clk0),
      .wr_rst(reset),
      .rd_clk(clk1),
      .rd_rst(reset),
      .wr(sum_out_vld0),
      .rd(fifo_rd_0to1),
      .wr_data(sum_out_from0),
      .rd_data(sum_in_to1),
      .full(o_full0),
      .empty(o_empty0)
);
async_fifo #(.data_width(bw_psum+4)) fifo_1to0 (
      .wr_clk(clk1),
      .wr_rst(reset),
      .rd_clk(clk0),
      .rd_rst(reset),
      .wr(sum_out_vld1),
      .rd(fifo_rd_1to0),
      .wr_data(sum_out_from1),
      .rd_data(sum_in_to0),
      .full(o_full1),
      .empty(o_empty1)
);

core #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance1 (
      .reset(reset), 
      .clk(clk1), 
      .mem_in(mem_in1), 
      .inst(inst),
      .out(out[2*col*bw_psum-1:col*bw_psum]),
      .sum_out(sum_out_from1),
      .sum_out_vld(sum_out_vld1),
      .sum_in(sum_in_to1),
      .sum_rd_vld(~o_empty0),
      .fifo_ext_rd(fifo_rd_0to1)
);


endmodule
