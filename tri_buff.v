module tri_buff (out, in, en);
output out;
input in;
input en;

assign out = (en) ? in : 1'bz;

// if (en) begin
//     assign out = in;
// end
// else begin
//     assign out = 1'bz;    
// end
endmodule