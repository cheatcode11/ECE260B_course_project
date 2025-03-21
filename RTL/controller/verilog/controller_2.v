module controller_2(clk, reset, start, q_full, k_full, ld_done, ofifo_wr, ofifo_full, sfp_ready, int_fifo_full, inst_out, done );

input clk;
input reset;
input start;

input q_full;  // Q SRAM is full
input k_full;  // K SRAM is full
input ld_done; // extract ld_ready_q from each mac column and NOR them to exit the LOAD stage
input ofifo_wr; // AND all the ofifo_wr signals from each mac col to exit exec stage
input ofifo_full; //o_full signal from ofifo
input sfp_ready;
input int_fifo_full;

output reg [18:0] inst_out;
output done;

reg [3:0] current_state;
reg [3:0] nxt_state;
reg [3:0] pre_state;
reg [18:0] inst;

//States
// 0000  - 0 //idle
// 0001  - 1 //q write
// 0010  - 2 //k write
// 0011  - 3 //k load
// 0100  - 4 //exec
// 0101  - 5 //ofifo_write
// 0110  - 6 //sfp_accum
// 0111  - 7 //sfp _hold
// 1000  - 8 //sfp_div
// 1001  - 9 //write_pmem
//
//



/*
assign inst[18:17] = sfp something;
assign inst[16] = ofifo_rd;
assign inst[15:12] = qkmem_add;
assign inst[11:8]  = pmem_add;
assign inst[7] = execute;
assign inst[6] = load;
assign inst[5] = qmem_rd;
assign inst[4] = qmem_wr;
assign inst[3] = kmem_rd;
assign inst[2] = kmem_wr;
assign inst[1] = pmem_rd;
assign inst[0] = pmem_wr;
*/

reg [4:0] counter;


localparam IDLE = 4'b0000,
           Q_WRITE = 4'b0001,
           K_WRITE = 4'b0010,
           K_LOAD= 4'b0011,
           EXEC = 4'b0100,
           OFIFO_WRITE = 4'b0101,
           SFP_ACCUM = 4'b0110,
           SFP_HOLD = 4'b0111,
           SFP_DIV = 4'b1000,
           WRITE_PMEM = 4'b1001;

always @(posedge clk)
begin

    if (reset) begin
    	current_state <= IDLE;
	nxt_state <= IDLE;
	pre_state <= IDLE;
	counter       <= {{1'b0},{IDLE}};
	inst          <= 19'd0;
    end
    else begin
    
    case(current_state)
	    IDLE : if(start) begin
		       nxt_state <= Q_WRITE;
	       end 
	
	    Q_WRITE : begin
		    if(~q_full) begin
			inst[15:12] <= counter[3:0];
			counter <= counter + 1;
	 	    end else begin
			nxt_state <= K_WRITE;
			counter   <= 5'b00000;
			inst[15:12] <= 4'b0000;
		    end
	            end
            K_WRITE : begin
		    if(~k_full) begin
		    	inst[15:12] <= counter[3:0];
			counter     <= counter + 1;
		    end else begin
			nxt_state   <= K_LOAD;
		        counter     <= 5'b00000;
			inst[15:12] <= 4'b0000;
		    end
	            end
	    K_LOAD: begin
		    if(~ld_done) begin
		    	inst[15:12] <= counter[3:0];
			counter     <= counter + 1;
		    end else begin
			nxt_state   <= EXEC;
		        counter     <= 5'b00000;
			inst[15:12] <= 4'b0000;
		    end

         	    end
             EXEC: begin
             end
	     OFIFO_WRITE: begin
	     end
		    
    endcase

    if(current_state == Q_WRITE && nxt_state == Q_WRITE && pre_state == Q_WRITE) inst[4] = 1'b1;
    else inst[4] = 1'b0;

    if(current_state == K_WRITE && nxt_state == K_WRITE && pre_state == K_WRITE) inst[2] = 1'b1;
    else inst[2] = 1'b0;
 
    if(current_state == K_LOAD && nxt_state == K_LOAD && pre_state == K_LOAD) inst[3] = 1'b1;
    else inst[3] = 1'b0;

    if(current_state == K_LOAD && nxt_state == K_LOAD) inst[6] = 1'b1;
    else if (pre_state == K_LOAD && current_state == EXEC) inst[6] = 1'b0;

   
    //inst <= inst_reg;
    current_state <= nxt_state;
    pre_state <= current_state;
    inst_out <= inst;

    end
end

assign done = ~|current_state;

endmodule

