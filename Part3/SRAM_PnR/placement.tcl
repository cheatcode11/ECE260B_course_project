# Placement
#specifyTopLayer 4
setMaxRouteLayer 4
saveDesign floorplan.enc
setPlaceMode -timingDriven true -reorderScan false -congEffort medium -modulePlan false
setOptMode -effort high -powerEffort high -leakageToDynamicRatio 0.5 -fixFanoutLoad true -restruct true -verbose true
place_opt_design

addFiller -cell {DCAP DCAP4} -merge true

saveDesign placement.enc
