
module WaveTableSynth(clk_50, ar, bclk, daclrck, waveSelect, keyOn, keyVal, dataOut);

	input clk_50, ar; 			//Basic 50 MHz clock and reset button.
	input [3:0] keyVal; 			//A value 0-12 that determines the note.
	input keyOn; 					//1 if key pressed, 0 if key released.
	input bclk, daclrck; 		//These come from audio codec. Bitclock and Left/Right Clock. 
	input [1:0] waveSelect;		//Most significant 2 bits of address.
	reg [12:0] wavePosition; 	//Least significant 13 bits of address.
	reg [7:0] scale; 				//This value is what we'll increment wave's address by.
	reg RD; 							//We read but never write.
	wire [15:0] Dout;				//Dout directly from dpram_ctrl.
	output wire [15:0] dataOut;//This is Dout but in Big Endian and an output port.
	wire [14:0] address; 		//15 bit address.
	wire Done; 						//Basically never used. Feeds into dpram_ctrl
	
	
	module kbd(ar, clk, ps2_clk, ps2_dat, bitmask, keyval, keyOn, select, psclk, psdat);
	module WaveTable(clk_50, ar, bclk, daclrck, waveSelect, keyOn, keyVal, dataOut);
	
//	module adc_proj( Brandt's audio codec code
//  input clk_50,
//  input ar,
//  inout SDAT,
//  output SCLK,
//  output AUD_DACDAT,
//  input AUD_ADCDAT,
//  output AUD_XCK,
//  input AUD_BCLK,
//  input AUD_DACLRCK,
//  input AUD_ADCLRCK,
//  input bitcrush,
//  output daclrck,
//  output dacdat,
//  output adcdat,
//  output bclk,
//  output adclrck,

);