module finitestatemachine(cs, sclk_pos, rw, sr_we, dm_we, addr_we, miso_en);
input cs;
input sclk_pos;
input rw;
output sr_we;
output dm_we;
output addr_we;
output miso_en;

parameter state_GET = 0;
parameter state_GOT = 1;
parameter state_READ_1 = 2;
parameter state_READ_2 = 3;
parameter state_READ_3 = 4;
parameter state_WRITE_1 = 5;
parameter state_WRITE_2 = 6;
parameter state_DONE = 7;

reg[7:0] state = state_DONE;

reg count = 0;
wire reset_count;

count++;
assign sr_we = 0;
assign dm_we = 0;
assign addr_we = 0;
assign miso_en = 0;
assign reset_count = 0;

case (state)
    state_DONE: 
        begin
            assign reset_count = 1;
            if (!cs) begin
                state <= state_GET;
            end
        end
    state_GET:
        begin
            if (count == 8) begin
                state <= state_GOT;
            end
        end
    state_GOT:
        begin
            assign reset_count = 1;
            assign addr_we = 1;
            if (rw) begin
                state <= state_READ_1;
            end
            else begin
                state <= state_WRITE_1;
            end
        end
    state_READ_1:
       begin
            state <= state_READ_2;
        end 
    state_READ_2:
        begin
            assign sr_we = 1;
            state <= state_READ_3;
        end
    state_READ_3:
        begin
            assign miso_en = 1;
            if (count == 8) begin
                state <= state_DONE;
            end
        end
    state_WRITE_1:
        begin
            if (count == 8) begin
                state <= state_WRITE_2;
            end
        end
    state_WRITE_2:
        begin
            assign dm_we = 1;
            state <= state_DONE;
        end

if (reset_count) begin
    count <= 0;
end




endmodule