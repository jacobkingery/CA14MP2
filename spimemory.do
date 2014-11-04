vlog -reportprogress 300 -work work spimemory.v finitestatemachine.v shiftregister.v inputconditioner.v tri_buff.v register.v DataMemory.v
vsim -voptargs="+acc" testSPIMemory
virtual type {{0 GET} {1 GOT} {2 READ1} {3 READ2} {4 READ3} {5 WRITE1} {6 WRITE2} {7 DONE}} state_type
virtual function {(state_type) /testSPIMemory/spimem/fsm/state} state_virtual
add wave -position insertpoint \
sim:/testSPIMemory/clk \
sim:/testSPIMemory/sclk \
sim:/testSPIMemory/spimem/sclk_cond \
sim:/testSPIMemory/cs \
sim:/testSPIMemory/mosi \
sim:/testSPIMemory/miso \
sim:/testSPIMemory/spimem/fsm/count \
sim:/testSPIMemory/spimem/fsm/state_virtual
run 110000
wave zoom full