// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module sram_w16 (CLK, D, Q, CEN, WEN, A);

  parameter sram_bit = 128;
  input  CLK;
  input  WEN;
  input  CEN;
  input  [sram_bit-1:0] D;
  input  [2:0] A;
  output reg [sram_bit-1:0] Q;

  reg [sram_bit-1:0] memory0;
  reg [sram_bit-1:0] memory1;
  reg [sram_bit-1:0] memory2;
  reg [sram_bit-1:0] memory3;
  reg [sram_bit-1:0] memory4;
  reg [sram_bit-1:0] memory5;
  reg [sram_bit-1:0] memory6;
  reg [sram_bit-1:0] memory7;
  reg [7:0] pntr;
  /*
  reg [sram_bit-1:0] memory8;
  reg [sram_bit-1:0] memory9;
  reg [sram_bit-1:0] memory10;
  reg [sram_bit-1:0] memory11;
  reg [sram_bit-1:0] memory12;
  reg [sram_bit-1:0] memory13;
  reg [sram_bit-1:0] memory14;
  reg [sram_bit-1:0] memory15;
  */

/*
  assign Q = (add_q == 0)  ? memory0 : (
             (add_q == 1)  ? memory1 : (
             (add_q == 2)  ? memory2 : (
             (add_q == 3)  ? memory3 : (
             (add_q == 4)  ? memory4 : (
             (add_q == 5)  ? memory5 : (
             (add_q == 6)  ? memory6 : (
             (add_q == 7)  ? memory7 : (
             (add_q == 8)  ? memory8 : (
             (add_q == 9)  ? memory9 : (
             (add_q == 10) ? memory10 : (
             (add_q == 11) ? memory11 : (
             (add_q == 12) ? memory12 : (
             (add_q == 13) ? memory13 : (
             (add_q == 14) ? memory14 : memory15))))))))))))));
*/

  always @ (posedge CLK) begin

   if (!CEN && WEN) begin // read 
     case (A)
	     4'b0000: begin
		     Q <= memory0;
		     pntr[0] <= 0;
	     end
	     4'b0001: begin
		     Q <= memory1;
		     pntr[1] <= 0;
	     end 
	     4'b0010: begin
		     Q <= memory2;
		     pntr[2] <= 0;
	     end
	     4'b0011: begin
		     Q <= memory3;
		     pntr[3] <= 0;
	     end 
	     4'b0100: begin
		     Q <= memory4;
		     pntr[4] <= 0;
	     end
	     4'b0101: begin
		     Q <= memory5;
		     pntr[5] <= 0;
	     end 
	     4'b0110: begin
		     Q <= memory6;
		     pntr[6] <= 0;
	     end
	     4'b0111: begin
		     Q <= memory7;
		     pntr[7] <= 0;
	     end 
    endcase
   end

   else if (!CEN && !WEN) begin // write
     case (A)
	     4'b0000:begin
		     memory0  <= D; 
		     pntr[0]  <= 1;
	     end
	     4'b0001:begin
		     memory1  <= D; 
		     pntr[1]  <= 1;
	     end
	     4'b0010:begin
		     memory2  <= D; 
		     pntr[2]  <= 1;
	     end
	     4'b0011:begin
		     memory3  <= D; 
		     pntr[3]  <= 1;
	     end
	     4'b0100:begin
		     memory4  <= D; 
		     pntr[4]  <= 1;
	     end
	     4'b0101:begin
		     memory5  <= D; 
		     pntr[5]  <= 1;
	     end
	     4'b0110:begin
		     memory6  <= D; 
		     pntr[6]  <= 1;
	     end
	     4'b0111:begin
		     memory7  <= D; 
		     pntr[7]  <= 1;
	     end
    endcase
  end
end

endmodule
