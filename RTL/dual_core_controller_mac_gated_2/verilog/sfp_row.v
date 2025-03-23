// Created by prof. Mingu Kang @ VVIP Lab in UCSD ECE department
// Please do not spread this code without permission
module sfp_row (clk, reset, acc, div, fifo_ext_rd, sum_in, sum_rd_vld, sum_out, sfp_in, sfp_out, sum_out_vld);

parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+4;

input clk;
input reset;
input div;
input acc;
input [bw_psum+3:0] sum_in;
input sum_rd_vld;
input [col*bw_psum-1:0] sfp_in;
output [bw_psum+3:0] sum_out;
output [col*bw_psum-1:0] sfp_out;

output sum_out_vld;
output fifo_ext_rd; // Anushka: fifo_ext_rd is now output to handshake fifo

wire [col*bw_psum-1:0] abs;

reg div_q;
wire [bw_psum+3:0] sum_this_core;
wire [bw_psum-1:0] sum_2core;
wire signed [bw_psum-1:0] sfp_in_sign0;
wire signed [bw_psum-1:0] sfp_in_sign1;
wire signed [bw_psum-1:0] sfp_in_sign2;
wire signed [bw_psum-1:0] sfp_in_sign3;
wire signed [bw_psum-1:0] sfp_in_sign4;
wire signed [bw_psum-1:0] sfp_in_sign5;
wire signed [bw_psum-1:0] sfp_in_sign6;
wire signed [bw_psum-1:0] sfp_in_sign7;

wire fifo_int_full;
wire fifo_int_empty;

reg signed [bw_psum-1:0] sfp_out_sign0;
reg signed [bw_psum-1:0] sfp_out_sign1;
reg signed [bw_psum-1:0] sfp_out_sign2;
reg signed [bw_psum-1:0] sfp_out_sign3;
reg signed [bw_psum-1:0] sfp_out_sign4;
reg signed [bw_psum-1:0] sfp_out_sign5;
reg signed [bw_psum-1:0] sfp_out_sign6;
reg signed [bw_psum-1:0] sfp_out_sign7;

reg [bw_psum+3:0] sum_q;
reg fifo_wr;



assign sfp_in_sign0 = (reset) ? {bw_psum{1'b0}} : sfp_in[bw_psum*1-1 : bw_psum*0];
assign sfp_in_sign1 = (reset) ? {bw_psum{1'b0}} : sfp_in[bw_psum*2-1 : bw_psum*1];
assign sfp_in_sign2 = (reset) ? {bw_psum{1'b0}} : sfp_in[bw_psum*3-1 : bw_psum*2];
assign sfp_in_sign3 = (reset) ? {bw_psum{1'b0}} : sfp_in[bw_psum*4-1 : bw_psum*3];
assign sfp_in_sign4 = (reset) ? {bw_psum{1'b0}} : sfp_in[bw_psum*5-1 : bw_psum*4];
assign sfp_in_sign5 = (reset) ? {bw_psum{1'b0}} : sfp_in[bw_psum*6-1 : bw_psum*5];
assign sfp_in_sign6 = (reset) ? {bw_psum{1'b0}} : sfp_in[bw_psum*7-1 : bw_psum*6];
assign sfp_in_sign7 = (reset) ? {bw_psum{1'b0}} : sfp_in[bw_psum*8-1 : bw_psum*7];

assign sfp_out[bw_psum*1-1 : bw_psum*0] = sfp_out_sign0;
assign sfp_out[bw_psum*2-1 : bw_psum*1] = sfp_out_sign1;
assign sfp_out[bw_psum*3-1 : bw_psum*2] = sfp_out_sign2;
assign sfp_out[bw_psum*4-1 : bw_psum*3] = sfp_out_sign3;
assign sfp_out[bw_psum*5-1 : bw_psum*4] = sfp_out_sign4;
assign sfp_out[bw_psum*6-1 : bw_psum*5] = sfp_out_sign5;
assign sfp_out[bw_psum*7-1 : bw_psum*6] = sfp_out_sign6;
assign sfp_out[bw_psum*8-1 : bw_psum*7] = sfp_out_sign7;

  assign abs[bw_psum*1-1 : bw_psum*0] = (sfp_in[bw_psum*1-1]) ?  (~sfp_in[bw_psum*1-1 : bw_psum*0] + 1)  :  sfp_in[bw_psum*1-1 : bw_psum*0];
  assign abs[bw_psum*2-1 : bw_psum*1] = (sfp_in[bw_psum*2-1]) ?  (~sfp_in[bw_psum*2-1 : bw_psum*1] + 1)  :  sfp_in[bw_psum*2-1 : bw_psum*1];
  assign abs[bw_psum*3-1 : bw_psum*2] = (sfp_in[bw_psum*3-1]) ?  (~sfp_in[bw_psum*3-1 : bw_psum*2] + 1)  :  sfp_in[bw_psum*3-1 : bw_psum*2];
  assign abs[bw_psum*4-1 : bw_psum*3] = (sfp_in[bw_psum*4-1]) ?  (~sfp_in[bw_psum*4-1 : bw_psum*3] + 1)  :  sfp_in[bw_psum*4-1 : bw_psum*3];
  assign abs[bw_psum*5-1 : bw_psum*4] = (sfp_in[bw_psum*5-1]) ?  (~sfp_in[bw_psum*5-1 : bw_psum*4] + 1)  :  sfp_in[bw_psum*5-1 : bw_psum*4];
  assign abs[bw_psum*6-1 : bw_psum*5] = (sfp_in[bw_psum*6-1]) ?  (~sfp_in[bw_psum*6-1 : bw_psum*5] + 1)  :  sfp_in[bw_psum*6-1 : bw_psum*5];
  assign abs[bw_psum*7-1 : bw_psum*6] = (sfp_in[bw_psum*7-1]) ?  (~sfp_in[bw_psum*7-1 : bw_psum*6] + 1)  :  sfp_in[bw_psum*7-1 : bw_psum*6];
  assign abs[bw_psum*8-1 : bw_psum*7] = (sfp_in[bw_psum*8-1]) ?  (~sfp_in[bw_psum*8-1 : bw_psum*7] + 1)  :  sfp_in[bw_psum*8-1 : bw_psum*7];
assign sum_2core = (reset) ? 0 : (sum_in[bw_psum+3:7] + sum_q[bw_psum+3:7]);
assign sum_out = sum_q;
assign sum_out_vld = fifo_wr;
assign fifo_ext_rd = (reset) ? 1'b0 : (sum_rd_vld & (~fifo_int_empty));

  fifo_depth16 #(.bw(bw_psum+4)) fifo_inst_int (
     .rd_clk(clk), 
     .wr_clk(clk), 
     .in(sum_q),
     .out(sum_this_core), 
     .rd(div_q), 
     .wr(fifo_wr), 
     .reset(reset),
     .o_full(fifo_int_full),
     .o_empty(fifo_int_empty)
  );


always @(posedge clk) begin
    if (reset) begin
        fifo_wr <= 0;
        sfp_out_sign0 <= 0;
        sfp_out_sign1 <= 0;
        sfp_out_sign2 <= 0;
        sfp_out_sign3 <= 0;
        sfp_out_sign4 <= 0;
        sfp_out_sign5 <= 0;
        sfp_out_sign6 <= 0;
        sfp_out_sign7 <= 0;
        sum_q <= 0;
    end else begin
        div_q <= div;

        if (acc) begin
      
         sum_q <= 
           {4'b0, abs[bw_psum*1-1 : bw_psum*0]} +
           {4'b0, abs[bw_psum*2-1 : bw_psum*1]} +
           {4'b0, abs[bw_psum*3-1 : bw_psum*2]} +
           {4'b0, abs[bw_psum*4-1 : bw_psum*3]} +
           {4'b0, abs[bw_psum*5-1 : bw_psum*4]} +
           {4'b0, abs[bw_psum*6-1 : bw_psum*5]} +
           {4'b0, abs[bw_psum*7-1 : bw_psum*6]} +
           {4'b0, abs[bw_psum*8-1 : bw_psum*7]} ;
         fifo_wr <= 1;

        end else begin
            fifo_wr <= 0;

            if (div_q) begin
	 	        sfp_out_sign0 <= {abs[bw_psum*1-1 : bw_psum*0], 8'b0} / sum_2core;
      		  sfp_out_sign1 <= {abs[bw_psum*2-1 : bw_psum*1], 8'b0} / sum_2core;	       
		        sfp_out_sign2 <= {abs[bw_psum*3-1 : bw_psum*2], 8'b0} / sum_2core; 
		        sfp_out_sign3 <= {abs[bw_psum*4-1 : bw_psum*3], 8'b0} / sum_2core;
		        sfp_out_sign4 <= {abs[bw_psum*5-1 : bw_psum*4], 8'b0} / sum_2core;
		        sfp_out_sign5 <= {abs[bw_psum*6-1 : bw_psum*5], 8'b0} / sum_2core;
		        sfp_out_sign6 <= {abs[bw_psum*7-1 : bw_psum*6], 8'b0} / sum_2core;
		        sfp_out_sign7 <= {abs[bw_psum*8-1 : bw_psum*7], 8'b0} / sum_2core;
            end
        end
    end
end


endmodule
