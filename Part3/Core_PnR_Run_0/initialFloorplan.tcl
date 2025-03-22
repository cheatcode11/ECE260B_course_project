# Floorplan
#floorPlan -site core -s 500 1000 10.0 10.0 10.0 10.0

floorPlan -site core -s 1800 900 25.0 25.0 25.0 25.0
globalNetConnect VDD -type pgpin -pin VDD -inst * -verbose
globalNetConnect VSS -type pgpin -pin VSS -inst * -verbose

addRing -spacing {top 3 bottom 3 left 3 right 3} -width {top 5 bottom 5 left 5 right 5}  -layer {top M1 bottom M1 left M2 right M2} -center 1 -type core_rings -nets {VSS  VDD}

#################################################



setObjFPlanBox Instance kmem_instance 150 550 900 700
setObjFPlanBox Instance qmem_instance 950 550 1700 700
setObjFPlanBox Instance psum_mem_instance 550 250 1300 400 


addHaloToBlock {10 10 10 10} qmem_instance
addHaloToBlock {10 10 10 10} kmem_instance
addHaloToBlock {10 10 10 10} psum_mem_instance

flipOrRotateObject -rotate R90 -name qmem_instance
flipOrRotateObject -flip MY -name qmem_instance

flipOrRotateObject -rotate R90 -name kmem_instance
flipOrRotateObject -flip MY -name kmem_instance

flipOrRotateObject -rotate R90 -name qmem_instance
flipOrRotateObject -flip MY -name qmem_instance

flipOrRotateObject -rotate R90 -name kmem_instance
flipOrRotateObject -flip MY -name kmem_instance


#flipOrRotateObject -rotate R90 -name psum_mem_instance
#flipOrRotateObject -rotate R90 -name psum_mem_instance
flipOrRotateObject -flip MY -name psum_mem_instance
flipOrRotateObject -flip MX -name psum_mem_instance

timeDesign -preplace -prefix preplace


setAddStripeMode -break_at {block_ring}

### Note: Change the number of strip  by looking at the layout #########
#addStripe -number_of_sets 10  -spacing 3 -layer M5 -width 2 -nets { VSS VDD } -direction horizontal -start 55

addStripe -nets {VSS VDD} -spacing 2 -layer M5 -direction horizontal -width 2 -number_of_sets 1 -start_from bottom -start 70.0
addStripe -nets {VSS VDD} -spacing 2 -layer M5 -direction horizontal -width 2 -number_of_sets 1 -start_from bottom -start 140.0
addStripe -nets {VSS VDD} -spacing 2 -layer M5 -direction horizontal -width 2 -number_of_sets 1 -start_from bottom -start 210.0
addStripe -nets {VSS VDD} -spacing 2 -layer M5 -direction horizontal -width 2 -number_of_sets 1 -start_from bottom -start 280.0
addStripe -nets {VSS VDD} -spacing 2 -layer M5 -direction horizontal -width 2 -number_of_sets 1 -start_from bottom -start 350.0
addStripe -nets {VSS VDD} -spacing 2 -layer M5 -direction horizontal -width 2 -number_of_sets 1 -start_from bottom -start 420.0
addStripe -nets {VSS VDD} -spacing 2 -layer M5 -direction horizontal -width 2 -number_of_sets 1 -start_from bottom -start 490.0
addStripe -nets {VSS VDD} -spacing 2 -layer M5 -direction horizontal -width 2 -number_of_sets 1 -start_from bottom -start 570.0
addStripe -nets {VSS VDD} -spacing 2 -layer M5 -direction horizontal -width 2 -number_of_sets 1 -start_from bottom -start 640.0
addStripe -nets {VSS VDD} -spacing 2 -layer M5 -direction horizontal -width 2 -number_of_sets 1 -start_from bottom -start 710.0
addStripe -nets {VSS VDD} -spacing 2 -layer M5 -direction horizontal -width 2 -number_of_sets 1 -start_from bottom -start 780.0
addStripe -nets {VSS VDD} -spacing 2 -layer M5 -direction horizontal -width 2 -number_of_sets 1 -start_from bottom -start 830.0
#addStripe -nets {VSS VDD} -spacing 2 -layer M5 -direction horizontal -width 2 -number_of_sets 1 -start_from bottom -start 530.0
#addStripe -nets {VSS VDD} -spacing 2 -layer M5 -direction horizontal -width 2 -number_of_sets 1 -start_from bottom -start 575.0
#addStripe -nets {VSS VDD} -spacing 2 -layer M5 -direction horizontal -width 2 -number_of_sets 1 -start_from bottom -start 615.0
#addStripe -nets {VSS VDD} -spacing 2 -layer M5 -direction horizontal -width 2 -number_of_sets 1 -start_from bottom -start 660.0
#addStripe -nets {VSS VDD} -spacing 2 -layer M5 -direction horizontal -width 2 -number_of_sets 1 -start_from bottom -start 700.0
#addStripe -nets {VSS VDD} -spacing 2 -layer M5 -direction horizontal -width 2 -number_of_sets 1 -start_from bottom -start 750.0
#addStripe -nets {VSS VDD} -spacing 2 -layer M5 -direction horizontal -width 2 -number_of_sets 1 -start_from bottom -start 800.0
#addStripe -nets {VSS VDD} -spacing 2 -layer M5 -direction horizontal -width 2 -number_of_sets 1 -start_from bottom -start 850.0


addRing -nets {VDD VSS} -type block_rings -around each_block -layer {top M1 bottom M1 left M2 right M2} -width {top 2.5 bottom 2.5 left 2.5 right 2.5} -spacing {top 2.5 bottom 2.5 left 2.5 right 2.5} 


globalNetConnect VDD -type pgpin -pin VDD -sinst qmem_instance -verbose -override
globalNetConnect VDD -type pgpin -pin VDD -sinst kmem_instance -verbose -override        
globalNetConnect VDD -type pgpin -pin VDD -sinst psum_mem_instance -verbose -override  


globalNetConnect VSS -type pgpin -pin VSS -sinst qmem_instance -verbose -override
globalNetConnect VSS -type pgpin -pin VSS -sinst kmem_instance -verbose -override        
globalNetConnect VSS -type pgpin -pin VSS -sinst psum_mem_instance -verbose -override

sroute
