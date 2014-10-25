module inputconditioner(clk, noisysignal, conditioned, positiveedge, negativeedge);
output reg conditioned = 0;
output reg positiveedge = 0;
output reg negativeedge = 0;
input clk, noisysignal;

parameter counterwidth = 3;
parameter waittime = 3;

reg[counterwidth-1:0] counter =0;
reg synchronizer0 = 0;
reg synchronizer1 = 0;

always @(posedge clk) begin
    if(conditioned == synchronizer1) begin
        counter <= 0;
        // edge detection 
        positiveedge <= 0;
        negativeedge <= 0;
        // end
    end
    else begin
        if (counter == waittime) begin
            counter <= 0;
            conditioned <= synchronizer1;
            // our added code for edge detection
            if (synchronizer1 == 1) 
                positiveedge <= 1;
            else
                negativeedge <= 1;
            // end our code
        end
        else 
            counter <= counter+1;
    end
    synchronizer1 = synchronizer0;
    synchronizer0 = noisysignal;
end
endmodule

module shiftregister(clk, peripheralClkEdgeNeg, parallelLoad, parallelDataIn, serialDataIn, parallelDataOut, serialDataOut);
parameter width = 8;
input               clk; // fpga clock
input               peripheralClkEdgeNeg; // falling edge clock signal from the other guy
input               parallelLoad; // which mode are we in? S in P out or P in S out. Set by button zero on the FPGA.
output[width-1:0]   parallelDataOut; // return the entire shift register.
output              serialDataOut; // the next bit of output data (serial). Set on the falling edge of the communication clock.
input[width-1:0]    parallelDataIn; // grab a fixed value, load into shift register. (0xA5)
input               serialDataIn; // the next bit of input data (serial). read on the rising edge of the communication clock

reg[width-1:0]      shiftregistermem;

assign serialDataOut = shiftregistermem[width-1];
assign parallelDataOut = shiftregistermem;

always @(posedge clk) begin
    if (parallelLoad) begin
        shiftregistermem <= parallelDataIn;
    end
    else if (peripheralClkEdgeNeg) begin // this one loses if both happen at the same time.
        shiftregistermem <= shiftregistermem << 1;
        shiftregistermem[0] <= serialDataIn;
        //{serialDataOut, shiftregistermem} <= {shiftregistermem, serialDataIn};
    end
end
endmodule


// This is the top-level module for the project!
// Set this as the top module in Xilinx, and place all your modules within this one.
module TopLevelShiftRegisterBringup(led, gpioBank1, gpioBank2, clk, sw, btn);
output [7:0] led;
output reg [3:0] gpioBank1
input[3:0] gpioBank2;
input clk;
input[7:0] sw;
input[3:0] btn;

// Your MP2 code goes here!
wire cond0, posedge0, negedge0;
inputconditioner ic0 (clk, btn[0], cond0, posedge0, negedge0);
wire cond1, posedge1, negedge1;
inputconditioner ic1 (clk, sw[0], cond1, posedge1, negedge1);
wire cond2, posedge2, negedge2;
inputconditioner ic2 (clk, sw[1], cond2, posedge2, negedge2);

wire sDout;
shiftregister sr (clk, negedge2, negedge0, 32'hA5, cond1, led[7:0], sDout);

endmodule
