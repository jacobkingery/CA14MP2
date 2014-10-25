module tri_buff (out, in, en);
output out;
input in;
input en;

if (en) begin
    assign out = in;
end
else begin
    assign out = 1'bz;    
end
endmodule