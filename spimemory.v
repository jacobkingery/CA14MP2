module spiMemory(clk, sclk_pin, cs_pin, miso_pin, mosi_pin, faultinjector_pin, leds);
input		clk;
input		sclk_pin;
input		cs_pin;
output		miso_pin;
input		mosi_pin;
input		faultinjector_pin;
output[7:0]		leds;

endmodule
