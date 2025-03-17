// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module core (clk, sum_out, sum_out_vld, mem_in, sum_in, out, inst, reset, fifo_ext_rd, sum_rd_vld);

// ------- Parameters -----------
parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 8;

// ------- Outputs -------------
output [bw_psum+3:0] sum_out;	// sum to other core
output sum_out_vld;
output [bw_psum*col-1:0] out;
output fifo_ext_rd;

// ------- Inputs --------------
input [bw_psum+3:0] sum_in;
input sum_rd_vld;
input  [pr*bw-1:0] mem_in;
input  clk;
input  [19:0] inst;    // Ajay: Bitwidth of inst increase by three to control sfp 
input  reset;


wire  [pr*bw-1:0] mac_in;
wire   [bw_psum*col-1:0] pmem_out;
wire  [pr*bw-1:0] kmem_out;
wire  [pr*bw-1:0] qmem_out;
wire  [bw_psum*col-1:0] pmem_in;
wire  [bw_psum*col-1:0] fifo_out;
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
wire sfp_pmem_wr = inst[19];
wire acc = inst[18];
wire div = inst[17];
wire  [bw_psum*col-1:0] sfp_out;

assign ofifo_rd = inst[16];
assign qkmem_add = inst[15:12];
assign pmem_add = inst[11:8];
assign qmem_rd = inst[5];
assign qmem_wr = inst[4];
assign kmem_rd = inst[3];
assign kmem_wr = inst[2];
assign pmem_rd = inst[1];
assign pmem_wr = inst[0];
assign mac_in  = inst[6] ? kmem_out : qmem_out;
assign out = pmem_out;
assign pmem_in = (sfp_pmem_wr) ? sfp_out : fifo_out;

mac_array #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) mac_array_instance (
        .in(mac_in), 
        .clk(clk), 
        .reset(reset), 
        .inst(inst[7:6]),     
        .fifo_wr(fifo_wr),     
	.out(array_out)
);

ofifo #(.bw(bw_psum), .col(col))  ofifo_inst (
        .reset(reset),
        .clk(clk),
        .in(array_out),
        .wr(fifo_wr),
        .rd(ofifo_rd),
        .o_valid(fifo_valid),
        .out(fifo_out)
);


sram_w16 #(.sram_bit(pr*bw)) qmem_instance (
        .CLK(clk),
        .D(mem_in),
        .Q(qmem_out),
        .CEN(!(qmem_rd||qmem_wr)),
        .WEN(!qmem_wr), 
        .A(qkmem_add)
);

sram_w16 #(.sram_bit(pr*bw)) kmem_instance (
        .CLK(clk),
        .D(mem_in),
        .Q(kmem_out),
        .CEN(!(kmem_rd||kmem_wr)),
        .WEN(!kmem_wr), 
        .A(qkmem_add)
);

sram_w16 #(.sram_bit(col*bw_psum)) psum_mem_instance (
        .CLK(clk),
        .D(pmem_in),
        .Q(pmem_out),
        .CEN(!(pmem_rd||pmem_wr)),
        .WEN(!pmem_wr), //Mingu Kang
        //.WEN(pmem_wr), //Tanish
        .A(pmem_add)
);

sfp_row #(.bw(bw), .bw_psum(bw_psum), .col(col)) sfp_instance(
	.clk(clk),
	.div(div),
	.acc(acc), 
	.fifo_ext_rd(fifo_ext_rd),   // 1'b0
	.sum_in(24'b1),   // 24'b0
	//.sum_in(sum_in),
	.sfp_in(pmem_out),
	.sfp_out(sfp_out),
	.sum_out(sum_out),
	.sum_out_ready(sum_out_ready)	
);

  //////////// For printing purpose ////////////
  always @(posedge clk) begin
      //if(pmem_wr)
         //$display("Memory write to PSUM mem add %x %x ", pmem_add, pmem_in); 
  end



endmodule
