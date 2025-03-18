// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 

`include "/home/linux/ieng6/ee260bwi25/public/PDKdata/verilog/tcbn65gplus.v"


    
module fullchip_gated (clk, mem_in, inst, reset,out);

parameter col = 8;
parameter bw = 8;
parameter bw_psum = 2*bw+4;
parameter pr = 8;//was 16

input  clk; 
input  [pr*bw-1:0] mem_in; 
input  [16:0] inst; 
input  reset;

//My addition
output [bw_psum*col-1:0] out;


core_gated #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) core_instance (
      .reset(reset), 
      .clk(clk), 
      .mem_in(mem_in), 
      .inst(inst),
      .out(out)
);

    // Instantiating CKLNQD2
    reg Q;
    wire TE, E, CP;
    CKLNQD2 my_instance (
        .TE(TE),
        .E(E),
        .CP(CP),
        .Q(Q)
    );
   

endmodule

/*
/ type: CKLNDx
`celldefine
module CKLNQD2 (TE, E, CP, Q);
    input TE, E, CP;
    output Q;
    reg notifier;

  `ifdef NTC // Reserve for NTC.
    wire TE_d, E_d, CP_d ;
    pullup (CDN);
    pullup (SDN);
    or (D_i, E_d, TE_d);
    not (CPB, CP_d);
    tsmc_dla (Q_buf, D_i, CPB, CDN, SDN, notifier);
    and         (Q, Q_buf, CP_d);
    not ( E_bar_b, E_d );
    not ( TE_bar_b, TE_d );
    `ifdef TETRAMAX
    `else
      tsmc_xbuf(E_bar,E_bar_b,1'b1);
    `endif
    `ifdef TETRAMAX
    `else
      tsmc_xbuf(TE_bar,TE_bar_b,1'b1);
    `endif
  `else // Reserve for non NTC.
    pullup (CDN);
    pullup (SDN);
    or (D_i, E, TE);
    not (CPB, CP);
    tsmc_dla (Q_buf, D_i, CPB, CDN, SDN, notifier);
    and         (Q, Q_buf, CP);
    not ( E_bar_b, E );
    not ( TE_bar_b, TE );
    `ifdef TETRAMAX
    `else
      tsmc_xbuf(E_bar,E_bar_b,1'b1);
    `endif
    `ifdef TETRAMAX
    `else
      tsmc_xbuf(TE_bar,TE_bar_b,1'b1);
    `endif
  `endif

    specify
       // old version
       (posedge CP => (Q +: E))=(0, 0);
       (negedge CP => (Q +: 1'b0))=(0, 0);
       //
       // new Mar 23, 2001 
       (CP => Q)=(0, 0);
       $width(negedge CP, 0, 0, notifier);
  `ifdef NTC       // Reserve for NTC.
       $setuphold(posedge CP &&& E_bar, negedge  TE, 0, 0, notifier, , ,CP_d, TE_d);
       $setuphold(posedge CP &&& E_bar, posedge  TE, 0, 0, notifier, , ,CP_d, TE_d);
       $setuphold(posedge CP &&& TE_bar, negedge  E, 0, 0, notifier, , ,CP_d, E_d);
       $setuphold(posedge CP &&& TE_bar, posedge  E, 0, 0, notifier, , ,CP_d, E_d);
  `else           // Reserve for non NTC.
       $setuphold(posedge CP &&& E_bar, negedge  TE, 0, 0, notifier);
       $setuphold(posedge CP &&& E_bar, posedge  TE, 0, 0, notifier);
       $setuphold(posedge CP &&& TE_bar, negedge  E, 0, 0, notifier);
       $setuphold(posedge CP &&& TE_bar, posedge  E, 0, 0, notifier);
  `endif
    endspecify

endmodule
`endcelldefine
*/
