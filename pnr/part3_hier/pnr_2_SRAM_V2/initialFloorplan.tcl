# Floorplan
#floorPlan -site core -s 500 1000 10.0 10.0 10.0 10.0

floorPlan -site core -r 1 0.50 25.0 25.0 25.0 25.0
globalNetConnect VDD -type pgpin -pin VDD -inst * -verbose
globalNetConnect VSS -type pgpin -pin VSS -inst * -verbose

addRing -spacing {top 3 bottom 3 left 3 right 3} -width {top 5 bottom 5 left 5 right 5}  -layer {top M1 bottom M1 left M2 right M2} -center 1 -type core_rings -nets {VSS  VDD}

setAddStripeMode -break_at {block_ring}

### Note: Change the number of strip  by looking at the layout #########
addStripe -number_of_sets 15  -spacing 2 -layer M5 -width 3 -nets { VSS VDD } -direction horizontal -start 30 -stop 600
#################################################



setObjFPlanBox Instance kmem_instance 50 200 250 375
setObjFPlanBox Instance qmem_instance 50 400 250 600
setObjFPlanBox Instance psum_mem_instance 350 25 550 225 


addHaloToBlock {3 3 3 3} qmem_instance
addHaloToBlock {3 3 3 3} kmem_instance
addHaloToBlock {3 3 3 3} psum_mem_instance



addRing -nets {VDD VSS} -type block_rings -around each_block -layer {top M1 bottom M1 left M2 right M2} -width {top 0.25 bottom 0.25 left 0.25 right 0.25} -spacing {top 1.5 bottom 1.5 left 1.5 right 1.5} 


globalNetConnect VDD -type pgpin -pin VDD -sinst qmem_instance -verbose -override
globalNetConnect VDD -type pgpin -pin VDD -sinst kmem_instance -verbose -override        
globalNetConnect VDD -type pgpin -pin VDD -sinst psum_mem_instance -verbose -override  


globalNetConnect VSS -type pgpin -pin VSS -sinst qmem_instance -verbose -override
globalNetConnect VSS -type pgpin -pin VSS -sinst kmem_instance -verbose -override        
globalNetConnect VSS -type pgpin -pin VSS -sinst psum_mem_instance -verbose -overrid

sroute 

