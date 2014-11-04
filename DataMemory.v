module DataMemory(clk, dataOut, address, writeEnable, dataIn);
parameter addresswidth = 7;
parameter depth = 2**addresswidth;
parameter width = 8;

output reg [width-1:0]  dataOut;

input clk;
input [addresswidth-1:0]    address;
input writeEnable;
input[width-1:0]    dataIn;

reg [width-1:0] memory [depth-1:0];

always @(posedge clk) begin
    if(writeEnable)
        memory[address] <= dataIn;
    dataOut <= memory[address];
    end

integer i;
initial begin
for(i=0;i<depth;i=i+1)
memory[i]=3*i;
end
endmodule

module DataMemory_breakable(clk, dataOut, address, writeEnable, dataIn, faultactive);
parameter addresswidth = 7;
parameter depth = 2**addresswidth;
parameter width = 8;
/*  X is the first flip flop
    Y is the second flip flop
    i is the row (in a 2D array)
    j is the column (in a 2D array)
*/
parameter Xi = 1;
parameter Xj = 0; // LSB of the X register
parameter Yi = Xi + 1;
parameter Yj = width - 1; // MSB of the Y register

output reg [width-1:0]  dataOut;

input clk;
input[addresswidth-1:0]    address;
input writeEnable;
input[width-1:0]    dataIn;
input faultactive;

reg[width-1:0] memory [depth-1:0];

always @(posedge clk) begin
    if(writeEnable) begin
        if (!faultactive || !(address==Xi || address==Yi)) begin
            memory[address] <= dataIn;
            debug <= 1;
        end
        else begin
            debug <= 0;
            if (address == Xi) begin
                memory[address] <= dataIn;
                memory[Yi][Yj] <= dataIn[Xj];
            end
            else begin
                memory[address][Yj-1:0] <= dataIn[Yj-1:0];
            end
        end
    end
    dataOut <= memory[address];
end

integer i;
initial begin
for(i=0;i<depth;i=i+1)
memory[i]=3*i;
end
endmodule
