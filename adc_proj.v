/* ECE641 Final Project, adapted from Project 4, adc_proj.v
 * Brandt Hill
 * Controller for audio codec that plays data, and can bitcrush.
 */
`timescale 1 ns / 1 ns
 
module adc_proj(
input clk_50,
input ar,

inout SDAT,
output SCLK,
output AUD_DACDAT,
input AUD_ADCDAT,
output AUD_XCK,
input AUD_BCLK,
input AUD_DACLRCK,
input AUD_ADCLRCK,

input bitcrush,

output daclrck,
output dacdat,
output adcdat,
output bclk,
output adclrck,

);

wire clk_br,KEYON,done,activate;
wire [23:0] data_codec;

//debug signals
assign daclrck = AUD_DACLRCK; 	//To be fed into WaveTable
assign bclk = AUD_BCLK;			//To be fed into WaveTable
assign dacdat = AUD_DACDAT; 
assign adcdat = AUD_ADCDAT;	//unused since no analog being fed in
assign adclrck = AUD_ADCLRCK;

wire [15:0] Dout;

//instantiations

data_setup inst1 (.clk_50(clk_50),.clk_br(clk_br),.data_codec(data_codec),.done(done),
	.ar(ar),.activate(activate),.clk_xck(AUD_XCK));

codec_prgm inst2 (.ar(ar), .clk_br(clk_br), .SCLK(SCLK), .SDAT(SDAT), .data_codec(data_codec),
	.activate(activate), .done(done));

reg [31:0] adc_ldat, adc_rdat, dac_ldat, dac_rdat, rdata, ldata;  // Up to 32-bit width
reg	AUD_DACLRCK_prev;  // for detecting edges of LRC w/resp to bclk
wire ldat_ldclr, rdat_ldclr;

always @(posedge bclk or negedge ar)
	if(~ar)
		AUD_DACLRCK_prev = 1'b0;
	else
		AUD_DACLRCK_prev = AUD_DACLRCK;

assign ldat_ldclr = (AUD_DACLRCK == 1'b1) && (AUD_DACLRCK_prev == 1'b0);
assign rdat_ldclr = (AUD_DACLRCK == 1'b0) && (AUD_DACLRCK_prev == 1'b1);

//Push data to dac from either memory or adc data	
always @(posedge bclk or negedge ar)
	if(~ar)
		dac_ldat = 32'b0;
	else
		if(ldat_ldclr) // pos edge of LRC  
			dac_ldat = {Dout,16'h0};
		else if (AUD_DACLRCK == 1'b1)
			dac_ldat = {dac_ldat[30:0], 1'b0};

always @(posedge bclk or negedge ar)
	if(~ar)
		dac_rdat = 32'b0;
	else
		if(rdat_ldclr) // neg edge of LRC
			dac_rdat = {Dout,16'h0};
		else if (AUD_DACLRCK == 1'b0)
			dac_rdat = {dac_rdat[30:0], 1'b0};		
			
// Read out L/R DAC Data
// Implementation in Quartus requires an additional 31 bit delay, although ModelSim 
//	didn't show the need.  Hence the shift register below.

wire dacbit;
reg [30:0] dacout_sr;

assign dacbit = (AUD_DACLRCK == 1'b1)? dac_ldat[31] : dac_rdat[31];

always @(posedge bclk or negedge ar)
if(~ar)
	dacout_sr = 31'b0;
else
	dacout_sr = {dacout_sr[29:0],dacbit};
	 
assign AUD_DACDAT = dacout_sr[30];



endmodule