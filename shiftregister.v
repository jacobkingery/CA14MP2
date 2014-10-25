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



module testshiftregister;
reg             clk;
reg             peripheralClkEdge;
reg             parallelLoad;
wire[7:0]       parallelDataOut;
wire            serialDataOut;
reg[7:0]        parallelDataIn;
reg             serialDataIn; 
// Instantiate with parameter width = 8
shiftregister #(8) sr(clk, peripheralClkEdge, parallelLoad, parallelDataIn, serialDataIn, parallelDataOut, serialDataOut);

initial clk=0;
always #10 clk = !clk;

initial begin
$display("Parallel Data Out | What operation did we just do??"); // header
#10 serialDataIn = 1;
#80 peripheralClkEdge = 1; #20 peripheralClkEdge = 0;
$display("     %b     | Shift in a 1", parallelDataOut);
#40 peripheralClkEdge = 1; #20 peripheralClkEdge = 0; // load two ones
$display("     %b     | Shift in a 1", parallelDataOut);
#60 serialDataIn = 0;
#60 peripheralClkEdge = 1; #20 peripheralClkEdge = 0;
$display("     %b     | Shift in a 0", parallelDataOut);
#40 peripheralClkEdge = 1; #20 peripheralClkEdge = 0; // load two zeros
$display("     %b     | Shift in a 0", parallelDataOut);
#100 serialDataIn = 1;
#40 peripheralClkEdge = 1; #20 peripheralClkEdge = 0;
$display("     %b     | Shift in a 1", parallelDataOut);
#40 peripheralClkEdge = 1; #20 peripheralClkEdge = 0; 
$display("     %b     | Shift in a 1", parallelDataOut);
#40 peripheralClkEdge = 1; #20 peripheralClkEdge = 0;
$display("     %b     | Shift in a 1", parallelDataOut);
#40 peripheralClkEdge = 1; #20 peripheralClkEdge = 0;
$display("     %b     | Shift in a 1", parallelDataOut);
#40 peripheralClkEdge = 1; #20 peripheralClkEdge = 0; // load five ones. this will cause a one to come out of serialDataOut.
$display("     %b     | Shift in a 1", parallelDataOut);
#80 parallelDataIn = 0;
#40 parallelLoad = 1; #20 parallelLoad = 0; // load parallel data, all zeros
$display("     %b     | parallel load a 0", parallelDataOut);
#100 parallelDataIn = 8'b10101010;
#40 parallelLoad = 1; #20 parallelLoad = 0; // load parallel data
$display("     %b     | parallel load 10101010", parallelDataOut);
#80 serialDataIn = 0;
#40 peripheralClkEdge = 1; #20 peripheralClkEdge = 0; // clock in one more zero, a 1 should come out of serialDataOut.
$display("     %b     | Shift in a 0", parallelDataOut);

end

endmodule

