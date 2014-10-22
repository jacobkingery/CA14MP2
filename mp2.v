// This is the top-level module for the project!
// Set this as the top module in Xilinx, and place all your modules within this one.
module mp2(led, gpioBank1, gpioBank2, clk, sw, btn);
output reg [7:0] led;
output reg [3:0] gpioBank1;
input[3:0] gpioBank2;
input clk;
input[7:0] sw;
input[3:0] btn;

// Your MP2 code goes here!

endmodule
