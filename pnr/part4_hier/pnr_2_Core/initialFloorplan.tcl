# Floorplan
#floorPlan -site core -s 500 1000 10.0 10.0 10.0 10.0

floorPlan -site core -r 1 0.50 10.0 10.0 10.0 10.0
globalNetConnect VDD -type pgpin -pin VDD -inst * -verbose
globalNetConnect VSS -type pgpin -pin VSS -inst * -verbose

addRing -spacing {top 1 bottom 1 left 1 right 1} -width {top 2 bottom 2 left 2 right 2}  -layer {top M1 bottom M1 left M2 right M2} -center 1 -type core_rings -nets {VSS  VDD}

setAddStripeMode -break_at {block_ring}

### Note: Change the number of strip  by looking at the layout #########
addStripe -number_of_sets 15  -spacing 2 -layer M5 -width 1 -nets { VSS VDD } -direction horizontal -start 30 -stop 600
#################################################



setObjFPlanBox Instance qmem_instance 100 50 300 250
setObjFPlanBox Instance kmem_instance 100 350 300 550
setObjFPlanBox Instance psum_mem_instance 350 200 550 400 


#addHaloToBlock {3 3 3 3} qmem_instance
#addHaloToBlock {3 3 3 3} kmem_instance
#addHaloToBlock {3 3 3 3} psum_mem_instance



addRing -nets {VDD VSS} -type block_rings -around each_block -layer {top M1 bottom M1 left M2 right M2} -width {top 3 bottom 3 left 3 right 3} -spacing {top 0.5 bottom 0.5 left 0.5 right 0.5} 


globalNetConnect VDD -type pgpin -pin VDD -sinst qmem_instance -verbose -override
globalNetConnect VSS -type pgpin -pin VSS -sinst kmem_instance -verbose -override        
globalNetConnect VSS -type pgpin -pin VSS -sinst psum_mem_instance -verbose -override        

sroute 


