// This is the top-level module for the project!
// Set this as the top module in Xilinx, and place all your modules within this one.
module TopLevelShiftRegisterBringup(led, gpioBank1, gpioBank2, clk, sw, btn);
output[7:0] led;
output[3:0] gpioBank1;
input[3:0] gpioBank2;
input clk;
input[7:0] sw;
input[3:0] btn;

// So Xilinx doesn't complain
assign gpioBank1 = gpioBank2;

// Input conditioners
wire cond0, posedge0, negedge0;
inputconditioner ic0 (clk, btn[0], cond0, posedge0, negedge0);
wire cond1, posedge1, negedge1;
inputconditioner ic1 (clk, sw[0], cond1, posedge1, negedge1);
wire cond2, posedge2, negedge2;
inputconditioner ic2 (clk, sw[1], cond2, posedge2, negedge2);

// Shift register
wire sDout;
shiftregister sr (clk, negedge2, negedge0, 32'hA5, cond1, led[7:0], sDout);

endmodule
