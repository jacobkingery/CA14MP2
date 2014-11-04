vlog -reportprogress 300 -work work inputconditioner.v
vsim -voptargs="+acc" testConditioner
add wave -position insertpoint \
sim:/testConditioner/pin \
sim:/testConditioner/clk \
sim:/testConditioner/conditioned \
sim:/testConditioner/rising \
sim:/testConditioner/falling 
run 1000
wave zoom full