/*
* Brandt Hill 2018, ECE641 Final Project
* Team Members: Brandt Hill, Harold Vilander, Thomas Gorham
*
*/

module WaveTable(clk_50, ar, bclk, daclrck, waveSelect, keyOn, keyVal, dataOut, debug);

	input clk_50;
	input ar; 		
	input [3:0] keyVal;			//A value 0-12 that determines the note.
	input keyOn; 				//1 if key pressed, 0 if key released.
	input bclk;
	input daclrck; 		        //These come from audio codec. Bitclock and Left/Right Clock. 
	input [1:0] waveSelect;		//Most significant 2 bits of address.
	output wire [15:0] dataOut; //This is Dout but in Big Endian and an output port. goes to codec
	output [7:0] debug;

	reg [7:0] counter; 			//Increments on bit clock, resets on left/right clock posedge.
	reg [12:0] wavePosition; 	//Least significant 13 bits of address.
	reg [7:0] scale; 				//This value is what we'll increment wave's address by.
	reg RD; 							//We read but never write.
	wire [15:0] Dout;				//Dout directly from dpram_ctrl.
	wire [14:0] address; 		//15 bit address.
	wire Done; 						//Basically never used. Feeds into dpram_ctrl
	//reg WR;

	//assign debug ={RD,address[6:0]};
	//assign debug = {|wavePosition[12:0],wavePosition[6:0]};
	assign debug = {Done, |Dout, Dout[15:10]};
										
	//Lookup table for scale values
	//These values are rounded to nearest int.								
	wire [7:0] scaleTable [12:0];
		assign scaleTable[0] = 8'd37;//8'd74;	//A  0
		assign scaleTable[1] = 8'd39;//8'd78;	//A# 1
		assign scaleTable[2] = 8'd41;//8'd83;	//B  2
		assign scaleTable[3] = 8'd44;//8'd88;	//C  3
		assign scaleTable[4] = 8'd46;//8'd93;	//C# 4
		assign scaleTable[5] = 8'd49;//8'd99;	//D  5
		assign scaleTable[6] = 8'd52;//8'd104;	//D# 6
		assign scaleTable[7] = 8'd55;//8'd111;	//E  7
		assign scaleTable[8] = 8'd58;//8'd117;	//F  8
		assign scaleTable[9] = 8'd62;//8'd124;	//F# 9
		assign scaleTable[10] = 8'd66;//8'd132;	//G  10
		assign scaleTable[11] = 8'd69;//8'd139;	//G# 11
		assign scaleTable[12] = 8'd74;//8'd148; //A  12
										

	//2 bit wave select then 13 bit position of wave sample
	assign address = {waveSelect, wavePosition};
	//assign address = 15'h800;

	//Convert Dout from little endian to big endian and output
	assign dataOut = Dout;//{Dout[7:0],Dout[15:8]};
	
	//Iterate through the wave sample, incrementing by scale
	//each Left Right Clock (48.8kHz) unless key isn't on.
	always@(posedge daclrck or negedge ar)
		if(~ar)
			wavePosition = 13'b0;
		else if(keyOn)
			wavePosition = wavePosition + scale;
		else
			wavePosition = 13'b0;

	//Set scale value according to keyVal input
	always@(posedge clk_50 or negedge ar)
		if(~ar)
			scale = 8'b0;
		else if(keyOn)
			scale = scaleTable[keyVal];
		else
			scale = 8'b0;
	
	//Read in a 16 bit sample of the wave once per 48.8kHz cycle
	always@(posedge bclk or negedge ar)
		if(~ar)
			RD = 1'b0;
		else if(counter == 8'd56)
		//else if(lrck_posedge)
			RD = 1'b1;
		else
			RD = 1'b1;

			
			
	always@(posedge bclk or negedge ar)
		if(~ar)		
			counter = 8'b0;
		else if(lrck_posedge)
			counter = 8'b0;
		else
			counter = counter + 8'b1;
	
	//This is all to determine when the Left Right Clock
	//goes high and low for one cycle of the bitclock.
	reg daclrck_prev;
	wire lrck_posedge = (daclrck == 1) && (daclrck_prev == 0);
	wire lrck_negedge = (daclrck == 0) && (daclrck_prev == 1);
	
	always@(posedge bclk or negedge ar)
		if(~ar)
			daclrck_prev = 1'b0;
		else
			daclrck_prev = daclrck;
dpram_ctrl inst (.clk(clk_50), .A(address), .RD(RD), .Din(16'hAFAF),  .WR(1'b0),  .Dout(Dout), .Done(Done));
			
endmodule