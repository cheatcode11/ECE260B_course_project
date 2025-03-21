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


//using them for norm*value calculations done for two cores
//Using norm_core0.txt and norm_core1.txt

integer  N[2*col-1:0][pr-1:0];
integer  V[total_cycle-1:0][pr-1:0];
integer  K[2*col-1:0][pr-1:0];
integer  Q[total_cycle-1:0][pr-1:0];

//Debugging variables
integer  result[total_cycle-1:0][2*col-1:0];
reg signed [bw_psum-1:0] abs_result;

reg  [bw_psum*col-1:0] temp16b_tbtest[total_cycle:0];//for finding errors in testbench-Tanish
reg  [bw_psum*col-1:0] temp16b_tbtest0[total_cycle:0];//for finding errors in testbench-Tanish
reg  [bw_psum*col-1:0] temp16b_tbtest1[total_cycle:0];//for finding errors in testbench-Tanish

reg signed [bw_psum-1:0] temp5b;
reg signed [bw_psum-1:0] temp5b_norm;
reg signed [bw_psum+4-1:0]temp_sum0[total_cycle-1:0];
reg signed [bw_psum+4-1:0]temp_sum1[total_cycle-1:0];

reg signed [bw_psum*col-1:0] temp16b;
reg [bw_psum-1:0] norm_result;
reg [bw_psum*col-1:0] norm;
integer  sum[total_cycle-1:0];

// Expected outputs after normalization
reg [bw_psum*col-1:0] expected_norm_output0[total_cycle:0];
reg [bw_psum*col-1:0] expected_norm_output1[total_cycle:0];
reg [bw_psum*col-1:0] core0_mac_expected_out[total_cycle:0];
reg [bw_psum*col-1:0] core1_mac_expected_out[total_cycle:0];
reg [bw_psum*col-1:0] core0_mac_expected_nv[total_cycle:0];
reg [bw_psum*col-1:0] core1_mac_expected_nv[total_cycle:0];
integer i,j,k,t,p,q,s,u,m,r;

integer error = 0;

reg reset = 1;
reg clk = 0;
reg [pr*bw-1:0] mem_in_core0; 
reg [pr*bw-1:0] mem_in_core1; 
reg ofifo_rd = 0;
wire [2*col*bw_psum-1:0] out;
reg [bw_psum-1:0] sfp_out;

//Increased bit width to support SFP operation
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
reg acc = 0;
reg div = 0;
reg sfp_pmem_wr = 0; // SFP

//----------------------------------------------------------//
//----Instruction Set-------------------------------------------//
assign inst[19] = sfp_pmem_wr;
assign inst[17] = div;
assign inst[18] = acc;
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



//------------------------------------------------------------------//
//-------------------------------------------------------------------//


//Instantiating the fullchip module
fullchip #(.bw(bw), .bw_psum(bw_psum), .col(col), .pr(pr)) fullchip_instance (
      .reset(reset),
      .clk0(clk),
      .clk1(clk),
      .mem_in0(mem_in_core0), 
      .mem_in1(mem_in_core1), 
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




///// K data0 txt reading /////

$display("##### K data Core 0 txt reading #####");

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

///// K data1 txt reading /////

$display("##### K data Core 1 txt reading #####");

  for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
  end
  reset = 0;

  qk_file = $fopen("kdata_core1.txt", "r");

  //// To get rid of first 4 lines in data file ////
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);


  for (q=0; q<col; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          K[q+ col][j] = captured_data;
    end
  end
/////////////////////////////////





/////////////// Estimated result printing /////////////////

$display("##### Computing Estimated results CORE0  #####");

for (t=0; t<total_cycle; t=t+1) begin
	// Initialize zeros     
       temp16b_tbtest[t]= 0;
       expected_norm_output0[t] = 0;
     
  end
  for (t=0; t<total_cycle; t=t+1) begin
     for (q=0; q<col; q=q+1) begin
       result[t][q] = 0;
     end
  end

  for (t=0; t<total_cycle; t=t+1) begin
    temp_sum0[t] = 0;
     for (q=0; q<col; q=q+1) begin
         for (k=0; k<pr; k=k+1) begin
            result[t][q] = result[t][q] + Q[t][k] * K[q][k];
         end

         temp5b = result[t][q];
         temp16b = {temp16b[139:0], temp5b};
      // Update sum
         temp_sum0[t] = temp_sum0[t] + ((result[t][q] < 0) ? (-1 * result[t][q]) : (result[t][q]));
     end
     core0_mac_expected_out[t] = temp16b;
     //$display("Core0: MAC exp out = %40h", core0_mac_expected_out[t]);
  end
     //**// temp16b_tbtest[t] =temp16b;

     temp16b = 0;

$display("##### Computing Estimated results CORE1  #####");

for (t=0; t<total_cycle; t=t+1) begin 
       temp16b_tbtest[t]= 0;
       expected_norm_output1[t] = 0;
  end
  for (t=0; t<total_cycle; t=t+1) begin
     for (q=col; q<2*col; q=q+1) begin
       result[t][q] = 0;
     end
  end


  for (t=0; t<total_cycle; t=t+1) begin
    temp_sum1[t] = 0;
     for (q=col; q<2*col; q=q+1) begin
         for (k=0; k<pr; k=k+1) begin
            result[t][q] = result[t][q] + Q[t][k] * K[q][k];
         end

      // Update sum'
         temp5b = result[t][q];
         temp16b = {temp16b[139:0], temp5b};
         temp_sum1[t] = temp_sum1[t] + ((result[t][q] < 0) ? (-1 * result[t][q]) : (result[t][q]));
      end
      core1_mac_expected_out[t] = temp16b;
	//$display("Core 1 mac exp out = %40h", core1_mac_expected_out[t]);
  end

      //** temp16b_tbtest[t] =temp16b;


$display("##### Estimated normalization result CORE0  #####");
  for (t=0; t<total_cycle; t=t+1) begin
     for (q=0; q<col; q=q+1) begin
       abs_result = (result[t][q] < 0) ? (-1 * result[t][q]) : (result[t][q]); 
       norm_result = {abs_result, 8'b0}/(temp_sum0[t][bw_psum+3:7] + temp_sum1[t][bw_psum+3:7]);
       norm = {norm[139:0],norm_result};
     end
     //$display("Norm Prd @Cycle Core 0 %d = %h",t,norm);
     expected_norm_output0[t] = norm;
  end
norm = 0;
$display("##### Estimated normalization result CORE1 #####");
  for (t=0; t<total_cycle; t=t+1) begin
     for (q=col; q<2*col; q=q+1) begin
       abs_result = (result[t][q] < 0) ? (-1 * result[t][q]) : (result[t][q]);
       norm_result = {abs_result, 8'b0}/(temp_sum0[t][bw_psum+3:7] + temp_sum1[t][bw_psum+3:7] );
       norm = {norm[139:0],norm_result};
     end
     expected_norm_output1[t] = norm;
     //$display("Prd @Cycle Core 1 %d = %h",t,norm);
  end

//////////////////////////////////////////////




///// Qmem writing  /////
$display("Done computing estimated results");

$display("##### Qmem writing  #####");

  for (q=0; q<total_cycle; q=q+1) begin

    #0.5 clk = 1'b0;  
    qmem_wr = 1;  if (q>0) qkmem_add = qkmem_add + 1; 
    
    mem_in_core0[1*bw-1:0*bw] = Q[q][0];
    mem_in_core0[2*bw-1:1*bw] = Q[q][1];
    mem_in_core0[3*bw-1:2*bw] = Q[q][2];
    mem_in_core0[4*bw-1:3*bw] = Q[q][3];
    mem_in_core0[5*bw-1:4*bw] = Q[q][4];
    mem_in_core0[6*bw-1:5*bw] = Q[q][5];
    mem_in_core0[7*bw-1:6*bw] = Q[q][6];
    mem_in_core0[8*bw-1:7*bw] = Q[q][7];

    mem_in_core1[1*bw-1:0*bw] = Q[q][0];
    mem_in_core1[2*bw-1:1*bw] = Q[q][1];
    mem_in_core1[3*bw-1:2*bw] = Q[q][2];
    mem_in_core1[4*bw-1:3*bw] = Q[q][3];
    mem_in_core1[5*bw-1:4*bw] = Q[q][4];
    mem_in_core1[6*bw-1:5*bw] = Q[q][5];
    mem_in_core1[7*bw-1:6*bw] = Q[q][6];
    mem_in_core1[8*bw-1:7*bw] = Q[q][7];

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
    
    mem_in_core0[1*bw-1:0*bw] = K[q][0];
    mem_in_core0[2*bw-1:1*bw] = K[q][1];
    mem_in_core0[3*bw-1:2*bw] = K[q][2];
    mem_in_core0[4*bw-1:3*bw] = K[q][3];
    mem_in_core0[5*bw-1:4*bw] = K[q][4];
    mem_in_core0[6*bw-1:5*bw] = K[q][5];
    mem_in_core0[7*bw-1:6*bw] = K[q][6];
    mem_in_core0[8*bw-1:7*bw] = K[q][7];

    mem_in_core1[1*bw-1:0*bw] = K[q+col][0];
    mem_in_core1[2*bw-1:1*bw] = K[q+col][1];
    mem_in_core1[3*bw-1:2*bw] = K[q+col][2];
    mem_in_core1[4*bw-1:3*bw] = K[q+col][3];
    mem_in_core1[5*bw-1:4*bw] = K[q+col][4];
    mem_in_core1[6*bw-1:5*bw] = K[q+col][5];
    mem_in_core1[7*bw-1:6*bw] = K[q+col][6];
    mem_in_core1[8*bw-1:7*bw] = K[q+col][7];

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




////////////// output fifo rd and wb to psum mem ///////////////////

$display("##### move ofifo to pmem #####");
//Begin writing into pmem
  for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk = 1'b0;  
    ofifo_rd = 1; 
    pmem_wr = 1; 

    if (q>0) begin
       pmem_add = pmem_add + 1;
    end
         #0.5 clk = 1'b1;
   end//End of writing
     pmem_wr = 0; pmem_add = 0; ofifo_rd = 0;
 ///////////////////////////////////////////////////////////////////
	 for (q=0; q<5; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
 end
 ////////////////////////////////////////////////////////////////
  for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk = 1'b0; 
    div = 0;
    pmem_wr = 0;
    pmem_rd = 1; 
    //if(q>0) pmem_add = pmem_add + 1;
    #0.5 clk = 1'b1;
    #0.5 clk = 1'b0;

     //$display("Hardware MAC output = %40h", out);
	if(out[col*bw_psum-1:0] == core0_mac_expected_out[q]) begin
	 	$display("******* Core 0 MAC OUTPUT TEST PASSED *********");
	 end
	 else
	 	$display("FAILED Core 0 MAC output test. MAC Hardware out = %h Expected out = %40h", out[col*bw_psum-1:0], core0_mac_expected_out[q]);
         
	if(out[2*col*bw_psum-1:col*bw_psum] == core1_mac_expected_out[q]) begin
	 	$display("******* Core 1 MAC OUTPUT TEST PASSED *********");
	 end
	 else
	 	$display("FAILED Core 1 MAC output test. MAC Hardware out = %h Expected out = %40h", out[col*bw_psum-1:0], core1_mac_expected_out[q]);
	
	  acc = 1;
          pmem_rd = 0;
	  #0.5 clk = 1'b1;
	  #0.5 clk = 1'b0;
	// Need to wait for a cycle. This is how sfp is designed.
	  acc = 0;
	  #0.5 clk = 1'b1;
	  #0.5 clk = 1'b0;
	  #0.5 clk = 1'b1;
	  #0.5 clk = 1'b0;
	  // The compute the division
	  div = 1;
	  #0.5 clk = 1'b1;
	  #0.5 clk = 1'b0;
    div = 0;
    pmem_wr = 1;
    sfp_pmem_wr = 1;
    #0.5 clk = 1'b1;
    
	  #0.5 clk = 1'b0;
	  #0.5 clk = 1'b1;
    pmem_add = pmem_add + 1;
  end
  #0.5 clk = 1'b0;  
  pmem_rd = 0; pmem_add = 0; acc = 0; div = 0; pmem_wr = 0; sfp_pmem_wr = 0;
  #0.5 clk = 1'b1;           
  //MAC output is no more connected to out as was in part1
	
// ******* Read and verify normalized output from pmem ***********
for (q=0; q<total_cycle; q=q+1) begin
	#0.5 clk = 1'b0;
	pmem_rd = 1;
	
	#0.5 clk = 1'b1;
	#0.5 clk = 1'b0;
	#0.5 clk = 1'b1;
	if(fullchip_instance.core_instance0.out == expected_norm_output0[q])
		$display("******* NORM OUTPUT CORE 0 TEST PASSED *********");
	else
		$display("FAILED. Norm output 0 did not match. Hardware out = %40h   Expected out = %40h",fullchip_instance.core_instance0.out , expected_norm_output0[q]);
	
	if(fullchip_instance.core_instance1.out == expected_norm_output1[q])
		$display("******* NORM OUTPUT CORE 1 TEST PASSED *********");
	else
		$display("FAILED. Norm output 1 did not match. Hardware out = %40h   Expected out = %40h", fullchip_instance.core_instance1.out, expected_norm_output1[q]);
	
	pmem_add = pmem_add + 1;
end
     	pmem_rd = 0; pmem_add = 0; div=0;
     	#0.5 clk = 1'b1;
	#0.5 clk = 1'b0;
//end
  


//////////////////////////////////////////////////////
////// Calculating norm * value using norm.txt and value.txt///////////
/////////////////////////////////////////////////////

reset = 1;

for(q=0; q<2;q=q+1) begin
  #0.5 clk = 1'b1;
  #0.5 clk = 1'b0;
  end
reset = 0;

#0.5 clk = 1'b1;
#0.5 clk = 1'b0;


///// Value txt reading /////

$display("##### Value  txt reading #####");

  qk_file = $fopen("vdata.txt", "r");

  //// To get rid of first 3 lines in data file ////
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);


  for (q=0; q<total_cycle; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          V[q][j] = captured_data;
    end
  end
/////////////////////////////////




  for (q=0; q<2; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
  end




///// Norm 0 txt reading /////

$display("##### Norm Core 0 txt reading #####");

  for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
  end
  reset = 0;

  qk_file = $fopen("norm_core0.txt", "r");

  //// To get rid of first 4 lines in data file ////
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);


  for (q=0; q<col; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          N[q][j] = captured_data;
    end
  end
/////////////////////////////////

///// Norm 1 txt reading /////

$display("##### Norm  Core 1 txt reading #####");

  for (q=0; q<10; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
  end
  reset = 0;

  qk_file = $fopen("norm_core1.txt", "r");

  //// To get rid of first 4 lines in data file ////
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);
  qk_scan_file = $fscanf(qk_file, "%s\n", captured_data);


  for (q=col; q<2*col; q=q+1) begin
    for (j=0; j<pr; j=j+1) begin
          qk_scan_file = $fscanf(qk_file, "%d\n", captured_data);
          N[q][j] = captured_data;

    end
  end
/////////////////////////////////



///// Qmem writing  /////

$display("##### Qmem writing  #####");

  for (q=0; q<total_cycle; q=q+1) begin

    #0.5 clk = 1'b0;  
    qmem_wr = 1;  if (q>0) qkmem_add = qkmem_add + 1; 
    
    mem_in_core0[1*bw-1:0*bw] = V[q][0];
    mem_in_core0[2*bw-1:1*bw] = V[q][1];
    mem_in_core0[3*bw-1:2*bw] = V[q][2];
    mem_in_core0[4*bw-1:3*bw] = V[q][3];
    mem_in_core0[5*bw-1:4*bw] = V[q][4];
    mem_in_core0[6*bw-1:5*bw] = V[q][5];
    mem_in_core0[7*bw-1:6*bw] = V[q][6];
    mem_in_core0[8*bw-1:7*bw] = V[q][7];

    mem_in_core1[1*bw-1:0*bw] = V[q][0];
    mem_in_core1[2*bw-1:1*bw] = V[q][1];
    mem_in_core1[3*bw-1:2*bw] = V[q][2];
    mem_in_core1[4*bw-1:3*bw] = V[q][3];
    mem_in_core1[5*bw-1:4*bw] = V[q][4];
    mem_in_core1[6*bw-1:5*bw] = V[q][5];
    mem_in_core1[7*bw-1:6*bw] = V[q][6];
    mem_in_core1[8*bw-1:7*bw] = V[q][7];

    #0.5 clk = 1'b1;  

  end


  #0.5 clk = 1'b0;  
  qmem_wr = 0; 
  qkmem_add = 0;
  #0.5 clk = 1'b1;  
///////////////////////////////////////////

  for (q=0; q<2; q=q+1) begin
    #0.5 clk = 1'b0;  
    #0.5 clk = 1'b1;   
  end






///// Kmem writing  /////

$display("##### Norm value writing #####");

  for (q=0; q<col; q=q+1) begin

    #0.5 clk = 1'b0;  
    kmem_wr = 1; if (q>0) qkmem_add = qkmem_add + 1; 
    
    mem_in_core0[1*bw-1:0*bw] = N[q][0];
    mem_in_core0[2*bw-1:1*bw] = N[q][1];
    mem_in_core0[3*bw-1:2*bw] = N[q][2];
    mem_in_core0[4*bw-1:3*bw] = N[q][3];
    mem_in_core0[5*bw-1:4*bw] = N[q][4];
    mem_in_core0[6*bw-1:5*bw] = N[q][5];
    mem_in_core0[7*bw-1:6*bw] = N[q][6];
    mem_in_core0[8*bw-1:7*bw] = N[q][7];

    mem_in_core1[1*bw-1:0*bw] = N[q+col][0];
    mem_in_core1[2*bw-1:1*bw] = N[q+col][1];
    mem_in_core1[3*bw-1:2*bw] = N[q+col][2];
    mem_in_core1[4*bw-1:3*bw] = N[q+col][3];
    mem_in_core1[5*bw-1:4*bw] = N[q+col][4];
    mem_in_core1[6*bw-1:5*bw] = N[q+col][5];
    mem_in_core1[7*bw-1:6*bw] = N[q+col][6];
    mem_in_core1[8*bw-1:7*bw] = N[q+col][7];

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




/////  Norm data loading  /////
$display("##### Norm data loading to processor #####");

  for (q=0; q<col+1; q=q+1) begin
    #0.5 clk = 1'b0;  
    load = 1; 
    if (q==1) kmem_rd = 1;
    if (q>1) begin
        //load = 1;
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


/////////////// Estimated result printing /////////////////

$display("##### Computing Estimated results CORE0  #####");

for (t=0; t<total_cycle; t=t+1) begin
	// Initialize zeros     
       temp16b_tbtest[t]= 0;
       expected_norm_output0[t] = 0;
     
  end
  for (t=0; t<total_cycle; t=t+1) begin
     for (q=0; q<col; q=q+1) begin
       result[t][q] = 0;
     end
  end

  for (t=0; t<total_cycle; t=t+1) begin
    temp_sum0[t] = 0;
     for (q=0; q<col; q=q+1) begin
         for (k=0; k<pr; k=k+1) begin
            result[t][q] = result[t][q] + V[t][k] * N[q][k];
         end

         temp5b = result[t][q];
         temp16b = {temp16b[139:0], temp5b};
      // Update sum
         temp_sum0[t] = temp_sum0[t] + ((result[t][q] < 0) ? (-1 * result[t][q]) : (result[t][q]));
     end
     core0_mac_expected_nv[t] = temp16b;
     //$display("Core0: MAC exp out = %40h", core0_mac_expected_out[t]);
  end
     //**// temp16b_tbtest[t] =temp16b;

     temp16b = 0;

$display("##### Computing Estimated results CORE1  #####");

for (t=0; t<total_cycle; t=t+1) begin 
       temp16b_tbtest[t]= 0;
       expected_norm_output1[t] = 0;
  end
  for (t=0; t<total_cycle; t=t+1) begin
     for (q=col; q<2*col; q=q+1) begin
       result[t][q] = 0;
     end
  end


  for (t=0; t<total_cycle; t=t+1) begin
    temp_sum1[t] = 0;
     for (q=col; q<2*col; q=q+1) begin
         for (k=0; k<pr; k=k+1) begin
            result[t][q] = result[t][q] + V[t][k] * N[q][k];
         end

      // Update sum'
         temp5b = result[t][q];
         temp16b = {temp16b[139:0], temp5b};
         temp_sum1[t] = temp_sum1[t] + ((result[t][q] < 0) ? (-1 * result[t][q]) : (result[t][q]));
      end
      core1_mac_expected_nv[t] = temp16b;
	//$display("Core 1 mac exp out = %40h", core1_mac_expected_out[t]);
  end


///// execution  /////
$display("##### execute #####");

  for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk = 1'b0;  
    execute = 1; 
    qmem_rd = 1;

    if (q>0) begin
        //execute = 1;
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




////////////// output fifo rd and wb to psum mem ///////////////////

$display("##### move ofifo to pmem #####");
//Begin writing into pmem
  for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk = 1'b0;  
    ofifo_rd = 1; 
    pmem_wr = 1; 

    if (q>0) begin
       pmem_add = pmem_add + 1;
    end
         #0.5 clk = 1'b1;
   end//End of writing
      pmem_wr = 0; pmem_add = 0; ofifo_rd = 0;
 ///////////////////////////////////////////////////////////////////
	 for (q=0; q<5; q=q+1) begin
    #0.5 clk = 1'b0;   
    #0.5 clk = 1'b1;   
 end
 ////////////////////////////////////////////////////////////////
  for (q=0; q<total_cycle; q=q+1) begin
    #0.5 clk = 1'b0; 
    pmem_wr = 0;
    pmem_rd = 1; 
    //if(q>0) pmem_add = pmem_add + 1;
    #0.5 clk = 1'b1;
    #0.5 clk = 1'b0;

     //$display("Hardware MAC output = %40h", out);
	if(fullchip_instance.core_instance0.out == core0_mac_expected_nv[q]) begin
	 	$display("******* Core 0 MAC OUTPUT Norm * Value TEST PASSED *********");
	 end
	 else
	 	$display("FAILED Core 0 MAC output test. MAC Hardware out = %h Expected out = %40h", fullchip_instance.core_instance0.out, core0_mac_expected_nv[q]);
         
	if(fullchip_instance.core_instance1.out == core1_mac_expected_nv[q]) begin
	 	$display("******* Core 1 MAC OUTPUT Norm * Value TEST PASSED *********");
	 end
	 else
	 	$display("FAILED Core 1 MAC output test. MAC Hardware out = %h Expected out = %40h", fullchip_instance.core_instance1.out, core1_mac_expected_nv[q]);
    pmem_rd = 0;
	  #0.5 clk = 1'b1;
	  #0.5 clk = 1'b0;
	// Need to wait for a cycle. This is how sfp is designed.
	  #0.5 clk = 1'b1;
	  #0.5 clk = 1'b0;
	  #0.5 clk = 1'b1;
	  #0.5 clk = 1'b0;
	  // The compute the division
	  #0.5 clk = 1'b1;
	  #0.5 clk = 1'b0;
    #0.5 clk = 1'b1;
	  #0.5 clk = 1'b0;
	  #0.5 clk = 1'b1;
    pmem_add = pmem_add + 1;
  end
  #0.5 clk = 1'b0;  
  pmem_rd = 0; pmem_add = 0; acc = 0; div = 0; pmem_wr = 0; sfp_pmem_wr = 0;
  #0.5 clk = 1'b1;           
  //MAC output is no more connected to out as was in part1     
  	 	$display("******* Run finished:) *********");

end

    
endmodule
