// Mostly copied from prior work
module register(q, d, wrenable, clk);
parameter width = 8;
input[width-1:0] d;
input wrenable;
input clk;
output reg [width-1:0] q;

always @(posedge clk) begin
  if(wrenable) begin
    q <= d;
    end
end
endmodule

module register_breakable(q, d, wrenable, clk, faultactive);
parameter width = 8;
input[width-1:0] d;
input wrenable;
input clk;
input faultactive;
output reg [width-1:0] q;

always @(posedge clk) begin
  if(wrenable) begin
    q <= d;
    end
end
endmodule
