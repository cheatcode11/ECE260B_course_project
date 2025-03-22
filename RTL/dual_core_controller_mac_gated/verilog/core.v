// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module core (clk, sum_out, sum_out_vld, mem_in, fifo_ext_rd, out,/* inst,*/ reset, sum_in, sum_rd_vld,start, out_valid);

parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 8;

output [bw_psum+3:0] sum_out; //sum out to the other core
output sum_out_vld; //internal fifo of this core is no longer empty, can be read
output [bw_psum*col-1:0] out;
wire   [bw_psum*col-1:0] pmem_out;
input [bw_psum+3:0] sum_in; //sum to be recieved from the other core
input  sum_rd_vld; //internal fifo of the other core is no longer empty, can be read
input  [pr*bw-1:0] mem_in;
output  fifo_ext_rd;
input  clk;
//input  [19:0] inst; //increasing the sfp instruction width 
input  reset;
input start;
output reg out_valid;

wire  [pr*bw-1:0] mac_in;
wire  [pr*bw-1:0] kmem_out;
wire  [pr*bw-1:0] qmem_out;
wire  [bw_psum*col-1:0] pmem_in;
wire  [bw_psum*col-1:0] fifo_out;
wire  [bw_psum*col-1:0] sfp_out;
wire  [bw_psum*col-1:0] array_out;
wire  [col-1:0] fifo_wr;
wire  ofifo_rd;
wire [2:0] qkmem_add;
wire [2:0] pmem_add;

wire  qmem_rd;
wire  qmem_wr; 
wire  kmem_rd;
wire  kmem_wr; 
wire  pmem_rd;
wire  pmem_wr;

wire q_full;
wire k_full;
wire ld_done;
wire exec_done;
wire out_wr;
wire p_full;

wire ofifo_full;
wire fifo_valid;
wire div ; 
wire acc ;
wire sfp_pmem_wr ;
wire [bw_psum*col-1:0] sfp_in;
// SFP signals
assign sfp_pmem_wr = controller_inst[19];
assign acc = controller_inst[18];
assign div = controller_inst[17]; 

assign ofifo_rd = controller_inst[16];
assign qkmem_add = controller_inst[15:12];
assign pmem_add = controller_inst[11:8];
assign qmem_rd = controller_inst[5];
assign qmem_wr = controller_inst[4];
assign kmem_rd = controller_inst[3];
assign kmem_wr = controller_inst[2];
assign pmem_rd = controller_inst[1];
assign pmem_wr = controller_inst[0];
assign mac_in  = controller_inst[6] ? kmem_out : qmem_out;

assign pmem_in = (sfp_pmem_wr) ? sfp_out : fifo_out;
assign out = pmem_out;

wire [19:0] controller_inst;
wire out_valid_wire;

controller_2 CONTROLLER(
	.clk(clk),
	.reset(reset),
	.start(start),
	.q_full(q_full),
	.k_full(k_full),
	.ld_done(ld_done),
	.ofifo_wr(),
	.ofifo_full(),
	.sfp_ready(),
	.int_fifo_full(),
	.inst(controller_inst),
	.exec_done(exec_done),
	.out_wr(out_wr),
	.p_full(p_full),
	.op_valid(out_valid_wire)

);

mac_array_wrapper_c #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) mac_array_instance (
        .in(mac_in), 
        .clk(clk), 
        .reset(reset), 
        .inst(controller_inst[7:6]),     
        .fifo_wr(fifo_wr),     
	.out(array_out),
	.ld_done(ld_done),
	.exec_done(exec_done),
	.out_wr(out_wr)
);

ofifo #(.bw(bw_psum), .col(col))  ofifo_inst (
        .reset(reset),
        .clk(clk),
        .in(array_out),
        .wr(fifo_wr),
        .rd(ofifo_rd),
        .o_valid(fifo_valid),
        .out(fifo_out),
	.o_full(ofifo_full)
);


sram_w16_c #(.sram_bit(pr*bw)) qmem_instance (
        .CLK(clk),
        .D(mem_in),
        .Q(qmem_out),
        .CEN(!(qmem_rd||qmem_wr)),
        .WEN(!qmem_wr), 
        .A(qkmem_add),
	.full(),
	.almost_full(q_full),
	.rst(reset)
);

sram_w16_c #(.sram_bit(pr*bw)) kmem_instance (
        .CLK(clk),
        .D(mem_in),
        .Q(kmem_out),
        .CEN(!(kmem_rd||kmem_wr)),
        .WEN(!kmem_wr), 
        .A(qkmem_add),
	.full(),
	.almost_full(k_full),
	.rst(reset)
);

sram_w16_c #(.sram_bit(col*bw_psum)) psum_mem_instance (
        .CLK(clk),
        .D(pmem_in),
        .Q(pmem_out),
        .CEN(!(pmem_rd||pmem_wr)),
        .WEN(!pmem_wr), 
        //.WEN(pmem_wr), //Tanish
        .A(pmem_add),
	.full(),
	.almost_full(p_full),
	.rst(reset)
);

sfp_row #(.bw(bw), .bw_psum(bw_psum), .col(col)) sfp_instance(
	.clk(clk),
        .reset(reset),
        .div(div),
        .acc(acc),
	.fifo_ext_rd(fifo_ext_rd),   
	.sum_in(sum_in),
        .sum_rd_vld(sum_rd_vld), 
	.sfp_in(pmem_out),
	.sfp_out(sfp_out),
	.sum_out(sum_out),
        .sum_out_vld(sum_out_vld)
);


  //////////// For printing purpose ////////////
  always @(posedge clk) begin
      //if(pmem_wr)
         //$display("Memory write to PSUM mem add %x %x ", pmem_add, pmem_in); 
         //$display("Memory obtained from PSUM mem add %x %x ", pmem_add, pmem_out); 
     out_valid  <= out_valid_wire;
  end



endmodule
