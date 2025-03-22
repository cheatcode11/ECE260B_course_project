module controller_2(clk, reset, start, q_full, k_full, ld_done, ofifo_wr, ofifo_full, sfp_ready, int_fifo_full, inst, done, exec_done, out_wr,p_full,op_valid );

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
input exec_done;
input out_wr;
input p_full;

output reg [19:0] inst;
output done;
output op_valid;

reg [3:0] current_state;
reg [3:0] nxt_state;
reg [3:0] pre_state;
reg [3:0] sub_state;
//reg [18:0] inst;

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
// 1010  - 10//ofifo_hold
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
           WRITE_PMEM = 4'b1001,
	   OFIFO_HOLD = 4'b1010,
	   LOAD_HOLD = 4'b1011,
	   PMEM_WRITE = 4'b1100,
           GEN_OUTPUT = 4'b1101,
	   SFP_SUBSTATE0 = 4'b0001,
	   SFP_SUBSTATE1 = 4'b0010,
	   SFP_SUBSTATE2 = 4'b0011,
	   SFP_SUBSTATE3 = 4'b0100,
	   SFP_SUBSTATE4 = 4'b0101,
	   SFP_SUBSTATE5 = 4'b0110,
	   SFP_SUBSTATE6 = 4'b0111;
always @(posedge clk)
begin

    if (reset) begin
    	current_state <= IDLE;
	nxt_state <= IDLE;
	pre_state <= IDLE;
	sub_state <= IDLE;
	counter       <= {{1'b0},{IDLE}};
	inst          <= 20'd0;
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
			//current_state <= K_WRITE;
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
			//current_state <= K_LOAD;
		        counter     <= 5'b00000;
			inst[15:12] <= 4'b0000;
		    end
	            end
	    K_LOAD: begin
		    if(inst[6] && nxt_state == K_LOAD && current_state == K_LOAD && pre_state == K_WRITE) ;
		    else if(~ld_done) begin
		    	inst[15:12] <= counter[3:0];
			counter     <= counter + 1;
		    end else begin
			nxt_state   <= LOAD_HOLD;
			//current_state <= EXEC;
		        counter     <= 5'b00000;
			inst[15:12] <= 4'b0000;
		    end

         	    end
	     LOAD_HOLD: begin
		     if(counter != 5'b0100)begin
			     inst <= 19'd0;
			     counter <= counter + 1;
		     end
		     else begin
			     nxt_state <= EXEC;
			     counter <= 5'b00000;
		     end
		    end
             EXEC: begin
		     if(~exec_done) begin
		    	inst[15:12] <= counter[3:0];
			counter     <= counter + 1;			
		     end else begin
			nxt_state   <= OFIFO_HOLD;
			//current_state <= OFIFO_HOLD;
		        counter     <= 5'b00000;
			inst[15:12] <= 4'b0000;
		     end
             end
	     OFIFO_HOLD: begin
		     if(~out_wr)begin
			     inst <= 19'd0;
		     end
		     else begin
			     nxt_state <= PMEM_WRITE;
		     end

	     end
	     PMEM_WRITE: begin
		    if(~p_full) begin
			inst[11:8] <= counter[3:0];
			counter <= counter + 1;
	 	    end else begin
			nxt_state <= SFP_HOLD;
			sub_state <= SFP_SUBSTATE0;
			//current_state <= K_WRITE;
			counter   <= 5'b00000;
			inst[11:8] <= 4'b0000;
			inst[0] <= 0;
			inst[1] <= 1;
			inst[17] <=0;
			inst[18] <=0;
			inst[19] <=0;
		    end
		
	     end
	     SFP_HOLD:begin
		     case(sub_state)
			SFP_SUBSTATE0: begin
				if(counter == 9) begin
				   current_state <= GEN_OUTPUT;
				   nxt_state <= GEN_OUTPUT;
				   counter <= 0;
				   inst[11:8] <= 4'b0000;
				   	inst[0] <= 0;
					inst[1] <= 0;
					inst[17] <=0;
					inst[18] <=0;
					inst[19] <=0;
				end
				else  	begin
					sub_state <= SFP_SUBSTATE1;
					inst[0] <= 0;
					inst[1] <= 0;
					inst[17]<=0;
					inst[18] <=1;
					//inst[19] =0;
				end

			end
			SFP_SUBSTATE1:begin
				sub_state <= SFP_SUBSTATE2;
					inst[0]<= 0;
					inst[1] <= 0;
					inst[17] <=0;
					inst[18] <=0;
					//inst[19] =0;

			end
			SFP_SUBSTATE2: begin
				sub_state <= SFP_SUBSTATE3;
					inst[0] <= 0;
					inst[1] <= 0;
					inst[17] <=0;
					inst[18] <=0;
					//inst[19] =0;

			end
			SFP_SUBSTATE3:begin
				sub_state <= SFP_SUBSTATE4;
					inst[0] <= 0;
					inst[1] <= 0;
					inst[17] <=1;
					inst[18] <=0;
					//inst[19] =0;

			end
			SFP_SUBSTATE4: begin
				sub_state <= SFP_SUBSTATE5;
					inst[0] <= 1;
					inst[1] <= 0;
					inst[17] <=0;
					inst[18] <=0;
					inst[19] <=1;

			end
			SFP_SUBSTATE5: begin
				sub_state <= SFP_SUBSTATE6;
					inst[0] <= 1;
					inst[1] <= 0;
					inst[17] <=0;
					inst[18] <=0;
					//inst[19] =0;

			end

			SFP_SUBSTATE6:begin
				sub_state <= SFP_SUBSTATE0;
					inst[0] <= 0;
					inst[1] <= 1;
					inst[17] <=0;
					inst[18] <=0;
					//inst[19] =0;
				counter  <= counter + 1;
				inst[11:8] <= counter[3:0];


			end

		     endcase

	     end
	     GEN_OUTPUT: begin
		     if(counter == 8) begin 
			     nxt_state <= IDLE;
			     inst[19:0] <= 20'd0;
			     counter <= 0;
		     end
		     else begin
			inst[11:8] <= counter;
			counter <= counter + 1;	
		     end
	     end
		    
    endcase

    
    if(q_full && pre_state == Q_WRITE && current_state == Q_WRITE) inst[4] <= 1'b0;
    else if(pre_state == IDLE && current_state == Q_WRITE) inst[4] <= 1'b1;

    if(k_full && current_state == K_WRITE && pre_state == K_WRITE) inst[2] <= 1'b0;
    else if(pre_state == Q_WRITE && current_state == Q_WRITE && nxt_state == K_WRITE) inst[2] <= 1'b1;
 
    if(nxt_state == K_LOAD && inst[15:12] == 4'b0111  && current_state == K_LOAD && pre_state == K_LOAD) inst[3] <= 1'b0;
    else if(pre_state == K_WRITE && current_state == K_LOAD)  inst[3] <= 1'b1;

    if(ld_done && current_state == K_LOAD && pre_state == K_LOAD) inst[6] <= 1'b0;
    else if (nxt_state == K_LOAD && current_state == K_WRITE && pre_state == K_WRITE) inst[6] <= 1'b1;

    if(exec_done && nxt_state == EXEC && current_state == EXEC && pre_state == EXEC) inst[7] <= 1'b0;
    else if(nxt_state == EXEC && current_state == LOAD_HOLD && pre_state == LOAD_HOLD) inst[7] <= 1'b1;

    if(exec_done && nxt_state == EXEC && current_state == EXEC && pre_state == EXEC) inst[5] <= 1'b0;
    else if(nxt_state == EXEC && current_state == LOAD_HOLD && pre_state == LOAD_HOLD) inst[5] <= 1'b1;

    if(p_full && nxt_state == PMEM_WRITE && current_state == PMEM_WRITE && pre_state == PMEM_WRITE) begin 
	    inst[0] <= 1'b0;
	    inst[16] <= 1'b0;
    end
    else if(nxt_state == PMEM_WRITE && current_state == OFIFO_HOLD && pre_state == OFIFO_HOLD) begin
	    inst[0] <= 1'b1;
	    inst[16] <= 1'b1;
    end

    if(current_state == GEN_OUTPUT && nxt_state == IDLE && pre_state == GEN_OUTPUT)begin
	inst[1] <= 1'b0;
    end else if(nxt_state == GEN_OUTPUT && current_state == GEN_OUTPUT) begin
	inst[1] <= 1'b1;
    end    
   
    //inst <= inst_reg;
    current_state <= nxt_state;
    pre_state <= current_state;
        
    end
end

assign done = ~|current_state;
assign op_valid = ({{nxt_state},{current_state},{pre_state}} == {{GEN_OUTPUT},{GEN_OUTPUT},{GEN_OUTPUT}})? 1'b1 : 1'b0;
endmodule

