module tri_buff (out, in, en);
output out;
input in;
input en;

assign out = (en) ? in : 1'bz;

endmodule

module tri_buff_breakable (out, in, en, faultactive);
output out;
input in;
input en;
input faultactive;

assign out = (en) ? in : 1'bz;

endmodule