// Created by prof. Mingu Kang @VVIP Lab in UCSD ECE department
// Please do not spread this code without permission 

`timescale 1ns/1ps

module fullchip_tb;

parameter total_cycle = 8;   // how many streamed Q vectors will be processed
parameter bw = 8;            // Q & K vector bit precision
parameter bw_psum = 2*bw+4;  // partial sum bit precision
parameter pr = 8;           // how many products added in each dot product//16 originally..testing for 8 
parameter col = 8;           // how many dot product units are equipped

integer qk_file ; // file handler
integer qk_scan_file ; // file handler


integer  captured_data;
integer  weight [col*pr-1:0];
`define NULL 0




integer  K[col-1:0][pr-1:0];
integer  Q[total_cycle-1:0][pr-1:0];
integer  result[total_cycle-1:0][col-1:0];
real expected_norm_result[total_cycle-1:0][col-1:0];
reg signed [bw_psum-1:0] temp_result;
integer  result_fn[total_cycle-1:0][col-1:0];//Tanish
reg  [bw_psum*col-1:0] temp16b_tbtest[total_cycle:0];//for finding errors in testbench-Tanish

// Expected outputs after normalization
reg [bw_psum*col-1:0] expected_norm_output[total_cycle:0];

integer  sum[total_cycle-1:0];

integer i,j,k,t,p,q,s,u,m,r;

integer error = 0;



reg reset = 1;
reg clk = 0;
reg [pr*bw-1:0] mem_in; 
reg ofifo_rd = 0;

wire [bw_psum*col-1:0] out;//My additon

reg [bw_psum-1:0] sfp_out;
// Ajay: Increased inst bitwidth for sfp control signals
wire [19:0] inst;
reg qmem_rd = 0;
reg qmem_wr = 0; 
reg kmem_rd = 0; 
reg kmem_wr = 0;
reg pmem_rd = 0; 
reg pmem_wr = 0; 
reg execute = 0;
reg load = 0;
reg [2:0] qkmem_add = 0;//was 3:0
reg [2:0] pmem_add = 0;//was 3:0


reg acc = 0;// SFP
reg div = 0;// SFP
reg sfp_pmem_wr = 0; // SFP
assign inst[19] = sfp_pmem_wr;
assign inst[17] = div; // SFP
assign inst[18] = acc; // SFP
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



reg signed [bw_psum-1:0] temp5b;
reg signed [bw_psum-1:0] norm_reg_result;
reg signed [bw_psum-1:0] temp5b_norm;
real temp_sum;
real sfp_out_real;
reg signed [bw_psum*col-1:0] temp16b;
reg signed [bw_psum*col-1:0] temp16b_norm;


reg [bw_psum+3:0] sum_in = 1;
reg [bw_psum+3:0] sum_this_core;
reg signed [bw_psum-1:0] sum_2core;

// Store current verification index for comparing correct output value
integer current_verify_idx = 0;

fullchip #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) fullchip_instance (
      .reset(reset),
      .clk(clk), 
      .mem_in(mem_in), 
      .inst(inst),
      .out(out)
);


initial begin 

  $dumpfile("fullchip_tb.vcd");
  $dumpvars(0,fullchip_tb);



///// Q data txt reading /////

$display("##### Q data txt reading #####");


  qk_file = $fopen("qdata.txt", "r");

  //// To get rid of first 3 lines in data file ////
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);


  for (q=0; q<total_cycle; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          Q[q][j] = captured_data;
          //$display("%d\n", Q [q][j]);
    end
  end
/////////////////////////////////




  for (q=0; q<2; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
  end




///// K data txt reading /////

$display("##### K data txt reading #####");

  for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
  end
  reset = 0;

  qk_file = $fopen("kdata_core0.txt", "r");

  //// To get rid of first 4 lines in data file ////
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);




  for (q=0; q<col; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          K[q][j] = captured_data;
    end
  end
/////////////////////////////////








/////////////// Estimated result printing /////////////////


$display("##### Computing Estimated results #####");

for (t=0; t<total_cycle; t=t+1) begin
     
       temp16b_tbtest[t]= 0;
       expected_norm_output[t] = 0;
     
  end
  for (t=0; t<total_cycle; t=t+1) begin
     for (q=0; q<col; q=q+1) begin
       result[t][q] = 0;
     end
  end

  for (t=0; t<total_cycle; t=t+1) begin
	  temp_sum = 0;
     for (q=0; q<col; q=q+1) begin
         for (k=0; k<pr; k=k+1) begin
            result[t][q] = result[t][q] + Q[t][k] * K[q][k];
         end

         temp5b = result[t][q];
	 // Update sum
	 temp_sum = temp_sum + ((result[t][q] < 0) ? (-1 * result[t][q]) : (result[t][q]));
         temp16b = {temp16b[139:0], temp5b};
     end

     temp16b_tbtest[t] =temp16b;
	// Normalized values
	for(q = 0; q < col; q = q+1) begin
		temp_result = result[t][q];
		sum_this_core = temp_sum;
		// Ajay: currently hardcoded to 10. Change when 2 core is
		// implemented
		sum_2core = 10;
		temp5b_norm = temp_result / sum_2core;
		temp16b_norm = {temp16b_norm[139:0], temp5b_norm};
	end
	expected_norm_output[t] = temp16b_norm;
  end
///// Qmem writing  /////
$display("Done computing estimated results");

$display("##### Qmem writing  #####");

  for (q=0; q<total_cycle; q=q+1) begin

    #0.5 clk = 1'b0;  
    qmem_wr = 1;  if (q>0) qkmem_add = qkmem_add + 1; 
    
    mem_in[1*bw-1:0*bw] = Q[q][0];
    mem_in[2*bw-1:1*bw] = Q[q][1];
    mem_in[3*bw-1:2*bw] = Q[q][2];
    mem_in[4*bw-1:3*bw] = Q[q][3];
    mem_in[5*bw-1:4*bw] = Q[q][4];
    mem_in[6*bw-1:5*bw] = Q[q][5];
    mem_in[7*bw-1:6*bw] = Q[q][6];
    mem_in[8*bw-1:7*bw] = Q[q][7];

    #0.5 clk = 1'b1;  

  end


  #0.5 clk = 1'b0;  
  qmem_wr = 0; 
  qkmem_add = 0;
  #0.5 clk = 1'b1;  
///////////////////////////////////////////

$display("Done writing to Qmem");



///// Kmem writing  /////

$display("##### Kmem writing #####");

  for (q=0; q<col; q=q+1) begin

    #0.5 clk = 1'b0;  
    kmem_wr = 1; if (q>0) qkmem_add = qkmem_add + 1; 
    
    mem_in[1*bw-1:0*bw] = K[q][0];
    mem_in[2*bw-1:1*bw] = K[q][1];
    mem_in[3*bw-1:2*bw] = K[q][2];
    mem_in[4*bw-1:3*bw] = K[q][3];
    mem_in[5*bw-1:4*bw] = K[q][4];
    mem_in[6*bw-1:5*bw] = K[q][5];
    mem_in[7*bw-1:6*bw] = K[q][6];
    mem_in[8*bw-1:7*bw] = K[q][7];

    #0.5 clk = 1'b1;  

  end

  #0.5 clk = 1'b0;  
  kmem_wr = 0;  
  qkmem_add = 0;
  #0.5 clk = 1'b1;  
///////////////////////////////////////////



  for (q=0; q<2; q=q+1) begin
    #0.5 clk = 1'b0;  
    #0.5 clk = 1'b1;   
  end


$display("##### Done writing to Kmem #######");

/////  K data loading  /////
$display("##### K data loading to processor #####");

  for (q=0; q<col+1; q=q+1) begin
    #0.5 clk = 1'b0;  
    load = 1; 
    if (q==1) kmem_rd = 1;
    if (q>1) begin
       qkmem_add = qkmem_add + 1;
    end

    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;  
  kmem_rd = 0; qkmem_add = 0;
  #0.5 clk = 1'b1;  

  #0.5 clk = 1'b0;  
  load = 0; 
  #0.5 clk = 1'b1;  

///////////////////////////////////////////

 for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
 end





///// execution  /////
$display("##### execute #####");

  for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk = 1'b0;  
    execute = 1; 
    qmem_rd = 1;

    if (q>0) begin
       qkmem_add = qkmem_add + 1;
    end

    #0.5 clk = 1'b1;  
  end

  #0.5 clk = 1'b0;  
  qmem_rd = 0; qkmem_add = 0; execute = 0;
  #0.5 clk = 1'b1;  


///////////////////////////////////////////

 for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
 end




////////////// Direct FIFO → SFP → PMEM flow ///////////////////

$display("##### Direct FIFO -> SFP -> PMEM flow #####");
if (q>0) begin
       pmem_add = pmem_add + 1;
    end
// Modified flow: MAC → FIFO → SFP → PMEM (single PMEM access)
for (q=0; q<total_cycle; q=q+1) begin
    // Read from FIFO and process through SFP
    #0.5 clk = 1'b0;
    ofifo_rd = 1;
    
    // First compute the sum (acc operation in SFP)
    acc = 1;
    div = 0;
    #0.5 clk = 1'b1;
    #0.5 clk = 1'b0;
    
    // Need to wait for a cycle for SFP processing
    ofifo_rd = 0;
    acc = 0;
    #0.5 clk = 1'b1;
    #0.5 clk = 1'b0;
    
    // Compute division in SFP
    div = 1;
    #0.5 clk = 1'b1;
    #0.5 clk = 1'b0;
    div = 0;
    
    // Now write normalized result directly to PMEM
   #0.5 clk = 1'b1;
    #0.5 clk = 1'b0;
    sfp_pmem_wr = 1;

    pmem_wr = 1;
    
    #0.5 clk = 1'b1;
    #0.5 clk = 1'b0;
    pmem_wr = 0;
    sfp_pmem_wr = 0;
    
    // Check MAC operation output
    if(out != temp16b_tbtest[q]) begin
        $display("FAILED MAC output test for cycle %0d. MAC Hardware out = %h   Expected out = %h", q, out, temp16b_tbtest[q]);
    end
    else
        $display("******* MAC OUTPUT TEST PASSED for cycle %0d *********", q);
    
    // Increment PMEM address for next write
    if (q < total_cycle-1) begin
        pmem_add = pmem_add + 1;
    end
    
    #0.5 clk = 1'b1;
end

#0.5 clk = 1'b0;
acc = 0;
div = 0;
pmem_add = 0; // Reset address counter for readback
#0.5 clk = 1'b1;

// Wait a few cycles for hardware to stabilize
for (q=0; q<5; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
end

// Read and verify normalized output from PMEM
$display("##### Verify normalized results in PMEM #####");

for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk = 1'b0;

    pmem_rd = 1;
    #0.5 clk = 1'b1;
    #0.5 clk = 1'b0;
    
    // Compare the hardware output with the expected output for the current cycle
    if(out == expected_norm_output[q])
        $display("******* NORM OUTPUT TEST PASSED for cycle %0d *********", q);
    else
        $display("FAILED. Norm output did not match for cycle %0d. Hardware out = %h   Expected out = %h", q, out, expected_norm_output[q]);
    
    // Increment PMEM address for next read
    if (q < total_cycle-1) begin
        pmem_add = pmem_add + 1;
    end
    
    #0.5 clk = 1'b1;

end

pmem_rd = 0; 
pmem_add = 0;
#0.5 clk = 1'b1;

///////////////////////////////////////////

#10 $finish;

end

endmodule
