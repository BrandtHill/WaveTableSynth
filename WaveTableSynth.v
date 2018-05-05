
    
module WaveTableSynth( 

	input clk_50,
	input ar,

	// I2C Connection for the Audio Codec
	inout SDAT,
	output SCLK,

	// Audio Codec clock and data paths
	output AUD_DACDAT,
	input AUD_ADCDAT,
    output AUD_XCK,
	input AUD_BCLK,
    input AUD_DACLRCK,
    input AUD_ADCLRCK,
    input bitcrush,

	// PS2 Keyboard data and Clock
	input  ps2_clk,
	input	ps2_dat,

	// LED debug signals
	output [15:0] bitmask,
	output [7:0] debug
	);         


	wire [3:0] keyVal; 			   	// A value from kb to WT; 0-12 that determines the note.
	wire [1:0] waveSelect;		    // wire kb to WT; Most significant 2 bits of address.
	wire [15:0] waveSample;			// 16 bit wave sample from WT to Audio Codec

	wire keyOn; 					// wire between kb to WT; 1 if key pressed, 0 if key released.


	kbd keyboard_inst (.ar(ar), .clk(clk_50), .ps2_clk(ps2_clk), .ps2_dat(ps2_dat), .bitmask(bitmask), .keyval(keyVal), .keyOn(keyOn), .select(waveSelect));
	WaveTable waveTable_inst (.clk_50(clk_50), .ar(ar), .bclk(AUD_BCLK), .daclrck(AUD_DACLRCK), .waveSelect(waveSelect), .keyOn(keyOn), .keyVal(keyVal), .dataOut(waveSample), .debug(debug));

	
	adc_proj( 
        .clk_50(clk_50),
		.ar(ar),
		.SDAT(SDAT),
		.SCLK(SCLK),
		.AUD_DACDAT(AUD_DACDAT),
		.AUD_ADCDAT(AUD_ADCDAT),
	    .AUD_XCK(AUD_XCK),
		.AUD_BCLK(AUD_BCLK),
        .AUD_DACLRCK(AUD_DACLRCK),
        .AUD_ADCLRCK(AUD_ADCLRCK),
        .bitcrush(bitcrush),
		.Din(waveSample)
	);

endmodule	