// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 
module sram_w16_c (CLK,rst, D, Q, CEN, WEN, A, full, almost_full);

  parameter sram_bit = 128;
  input  CLK;
  input  WEN;
  input  CEN;
  input  [sram_bit-1:0] D;
  input  [2:0] A;
  input rst;
  output reg [sram_bit-1:0] Q;
  output full;
  output almost_full;

  reg [sram_bit-1:0] memory0;
  reg [sram_bit-1:0] memory1;
  reg [sram_bit-1:0] memory2;
  reg [sram_bit-1:0] memory3;
  reg [sram_bit-1:0] memory4;
  reg [sram_bit-1:0] memory5;
  reg [sram_bit-1:0] memory6;
  reg [sram_bit-1:0] memory7;
  reg [7:0] pntr;

  always @ (posedge CLK) begin
   if(rst) pntr <= 8'b00000000;
   else if (!CEN && WEN) begin // read 
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

assign full = (pntr == 8'b11111111)? 1'b1:1'b0;
assign almost_full = (pntr == 8'b11111110 | pntr == 8'b11111101 | pntr == 8'b11111011 | pntr == 8'b11110111 | pntr == 8'b11101111 | pntr == 8'b11011111 | pntr == 8'b10111111 | pntr == 8'b01111111)? 1'b1:1'b0;

endmodule

