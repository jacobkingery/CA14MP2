// This is the top-level module for the project!
// Set this as the top module in Xilinx, and place all your modules within this one.
module TopLevelSPIMemory(sclk, miso, mosi, cs, led, clk, sw, btn);
// SPI inputs / outputs - all in leftmost GPIO bank
// GND is pin 5, VCC is pin 6
input sclk; // GPIO pin 1
output miso; // GPIO pin 2
input mosi; // GPIO pin 3
input cs; // GPIO pin 4

// 50MHz system clock and other peripherals
input clk;
input[7:0] sw;
input[3:0] btn;
output [7:0] led;

spiMemory mem (clk, sclk, cs, miso, mosi, sw[0], led);

endmodule