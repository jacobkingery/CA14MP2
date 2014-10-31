module spiMemory(clk, sclk_pin, cs_pin, miso_pin, mosi_pin, faultinjector_pin, leds);
input		clk;
input		sclk_pin;
input		cs_pin;
output		miso_pin;
input		mosi_pin;
input		faultinjector_pin;
output[7:0]		leds;

wire cs_cond, cs_pos, cs_neg;
wire sclk_cond, sclk_pos, sclk_neg;
wire mosi_cond, mosi_pos, mosi_neg;
wire[7:0] address;
wire[7:0] dm_dout;
wire[7:0] sr_pout;
wire sr_sout;
wire miso_prebuff;
wire sr_we, dm_we, addr_we, miso_en;

inputconditioner cs (clk, cs_pin, cs_cond, cs_pos, cs_neg);
inputconditioner sclk (clk, sclk_pin, sclk_cond, sclk_pos, sclk_neg);
inputconditioner mosi (clk, mosi_pin, mosi_cond, mosi_pos, mosi_neg);

register #(8) addrlatch (address, sr_pout, addr_we, clk);

DataMemory datamem (clk, dm_dout, address[7:1], dm_we, sr_pout);

shiftregister sr (clk, sclk_pos, sr_we, dm_dout, mosi_cond, sr_pout, sr_sout);

register #(1) dff (miso_prebuff, sr_sout, sclk_neg, clk);
tri_buff outbuff (miso_pin, miso_prebuff, miso_en);

finitestatemachine fsm (clk, cs_cond, sclk_pos, sr_pout[0], sr_we, dm_we, addr_we, miso_en);
endmodule

module testSPIMemory;
reg clk;
reg sclk;
reg cs = 1;
wire miso;
reg mosi;
reg fault = 0;
wire[7:0] leds;

spiMemory spimem (clk, sclk, cs, miso, mosi, fault, leds);

initial clk=0;
always #10 clk = !clk;

initial sclk=0;
always #100 sclk = !sclk;

initial begin
    cs = 1;
    // mosi = 0;
    #200
    cs = 0;
    mosi = 0;
    #200
    mosi = 0;
    #200
    mosi = 0;
    #200
    mosi = 0;
    #200
    mosi = 0;
    #200
    mosi = 0;
    #200
    mosi = 1;
    #200
    mosi = 0;

    #200
    mosi = 0;
    #200
    mosi = 1;
    #200
    mosi = 0;
    #200
    mosi = 1;
    #200
    mosi = 0;
    #200
    mosi = 1;
    #200
    mosi = 0;
    #200
    mosi = 1;

    #200
    cs = 1;
    mosi = 0;
    #800
    cs = 0;
    mosi = 0;
    #200
    mosi = 0;
    #200
    mosi = 0;
    #200
    mosi = 0;
    #200
    mosi = 0;
    #200
    mosi = 0;
    #200
    mosi = 1;
    #200
    mosi = 1;
    #1600
    cs = 1;
end

endmodule