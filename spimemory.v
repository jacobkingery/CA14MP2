module spiMemory(clk, sclk_pin, cs_pin, miso_pin, mosi_pin, faultinjector_pin, leds);
input		clk;
input		sclk_pin;
input		cs_pin;
output		miso_pin;
input		mosi_pin;
input		faultinjector_pin;
output[7:0]		leds;

wire cs_cond, cs_pos, cs_neg;
inputconditioner cs (clk, cs_pin, cs_cond, cs_pos, cs_neg);

wire sclk_cond, sclk_pos, sclk_neg;
inputconditioner sclk (clk, sclk_pin, sclk_cond, sclk_pos, sclk_neg);

wire mosi_cond, mosi_pos, mosi_neg;
inputconditioner mosi (clk, mosi_pin, mosi_cond, mosi_pos, mosi_neg);

wire address;
register #(8) addrlatch (address, sr_pout, addr_we, clk);

wire dm_dout;
DataMemory datamem (clk, dm_dout, address, dm_we, sr_pout);

wire sr_pout, sr_sout;
shiftregister sr (clk, sclk_pos, sr_we, dm_dout, mosi_cond, sr_pout, sr_sout);

wire miso_prebuff;
register #(8) dff (miso_prebuff, sr_sout, sclk_neg, clk);

tri_buff outbuff (miso_pin, miso_prebuff, miso_buff);

// need to be set from FSM
wire sr_we, dm_we, addr_we, miso_buff;
endmodule

