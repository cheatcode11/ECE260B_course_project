The MAC unit is rewritten for gating. Two sets of files are available for testing, a 16 input MAC tile wihtout gating anf 8 input MAC tile with gating. 
  > Reaslied out MAC only needs 8 multiplications coz the vector size is 8.
  > Need to convert the 16 input MAC without gating to 8 input for accurate comparison.
  > run filelist for without gating, and run filelist_gated to run gated version.
  > The gated version takes 8 bit q_zero input now, to identify which elements are 0. comparison is done outside the block to ensure timing and prevent recomputation in every MAC col it is passed to.
  > The MAC col to be tested is set at col_id=9 to make the load faster (given design is such that last col is loaded first)
  > 0 is identified in the tb by ~| operation
  > curerntly the mac is not acutually gated, it is behaviorlly implemented where the paths are established. gate should be added to the key_q_* and query_q_* registers using the input 
    q_zero and input k_zero input signals.
  > currently the design stores the q_zero and k_zero signals in registers similar to the loading of key and query, this ensures the pipeline register at the end of the multiplier is reset.
