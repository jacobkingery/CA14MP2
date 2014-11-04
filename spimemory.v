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

// Input conditioners
inputconditioner cs (clk, cs_pin, cs_cond, cs_pos, cs_neg);
inputconditioner sclk (clk, sclk_pin, sclk_cond, sclk_pos, sclk_neg);
inputconditioner mosi (clk, mosi_pin, mosi_cond, mosi_pos, mosi_neg);

// Address latch
register #(8) addrlatch (address, sr_pout, addr_we, clk);

// Data memory, breakable version
DataMemory_breakable datamem (clk, dm_dout, address[7:1], dm_we, sr_pout, faultinjector_pin);
// DataMemory datamem (clk, dm_dout, address[7:1], dm_we, sr_pout);

// Shift register
shiftregister sr (clk, sclk_pos, sr_we, dm_dout, mosi_cond, sr_pout, sr_sout);

// MISO register and tri-state buffer
register #(1) dff (miso_prebuff, sr_sout, sclk_neg, clk);
tri_buff outbuff (miso_pin, miso_prebuff, miso_en);

// Finite state machine
finitestatemachine fsm (clk, cs_cond, sclk_pos, sr_pout[0], sr_we, dm_we, addr_we, miso_en);
    
endmodule

module testSPIMemory;
reg clk;
reg sclk;
reg cs = 1;
wire miso;
reg mosi;
reg fault = 1;
wire[7:0] leds;

spiMemory spimem (clk, sclk, cs, miso, mosi, fault, leds);

// Our clock
initial clk=0;
always #10 clk = !clk;

// 'master' clock
initial sclk=0;
always #1000 sclk = !sclk;

initial begin
    // Emulate master by controlling CS and MOSI
    cs = 1;
    #2000

    // WRITE 0x55 to address 1
    cs = 0;
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 1;
    #2000
    mosi = 0;

    #2000
    mosi = 0;
    #2000
    mosi = 1;
    #2000
    mosi = 0;
    #2000
    mosi = 1;
    #2000
    mosi = 0;
    #2000
    mosi = 1;
    #2000
    mosi = 0;
    #2000
    mosi = 1;

    #2000
    cs = 1;
    mosi = 0;

    // WRITE 0x0 to address 1
    #2000
    cs = 0;
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 1;
    #2000
    mosi = 0;

    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;

    #2000
    cs = 1;
    mosi = 0;

    // READ from address 1, should be 0x55
    #8000
    cs = 0;
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 0;
    #2000
    mosi = 1;
    #2000
    mosi = 1;
    #18000
    cs = 1;
end

endmodule