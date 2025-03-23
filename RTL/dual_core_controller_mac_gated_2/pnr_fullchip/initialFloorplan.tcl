# Floorplan
floorPlan -site core -r 0.5 1.0 10.0 10.0 10.0 10.0

setObjFPlanBox Instance core0_instance 51 881 200 1161
setObjFPlanBox Instance core1_instance 51 546 200 826

flipOrRotateObject -rotate R90 -name core0_instance
flipOrRotateObject -flip MY -name core0_instance

flipOrRotateObject -rotate R90 -name core1_instance
flipOrRotateObject -flip MY -name core1_instance

addHaloToBlock {3 3 3 3} core0_instance
addHaloToBlock {3 3 3 3} core1_instance

timeDesign -preplace -prefix preplace

#floorPlan -site core -r 1 0.5 10.0 10.0 10.0 10.0
globalNetConnect VDD -type pgpin -pin VDD -inst * -verbose
globalNetConnect VSS -type pgpin -pin VSS -inst * -verbose

addRing -spacing {top 0.5 bottom 0.5 left 0.5 right 0.5} -width {top 1 bottom 1 left 1 right 1}  -layer {top M3 bottom M3 left M2 right M2} -center 1 -type core_rings -nets {VSS  VDD}

addRing -nets {VDD VSS} -type block_rings -around each_block -layer {top M3 bottom M3 left M2 right M2} -width {top 0.5 bottom 0.5 left 0.5 right 0.5} -spacing {top 0.5 bottom 0.5 left 0.5 right 0.5} 


setAddStripeMode -break_at {block_ring}

### Note: Change the number of strip  by looking at the layout #########
addStripe -number_of_sets 20  -spacing 6 -layer M6 -width 2 -nets { VSS VDD } -direction vertical -start 20 
#################################################

globalNetConnect VDD -type pgpin -pin VDD -sinst core0_instance -verbose -override
globalNetConnect VSS -type pgpin -pin VSS -sinst core0_instance -verbose -override

globalNetConnect VDD -type pgpin -pin VDD -sinst core1_instance -verbose -override        
globalNetConnect VSS -type pgpin -pin VSS -sinst core1_instance -verbose -override 




sroute 



