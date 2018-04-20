/*==========================================================

ECE 641 Spring 2018
Thomas Gorham
(based on kbd_ps2.v from Dr. Gruenbacher)
ps2_controller.v

Handles data input from a ps2 keyboard.
Keyboards do not require bidirectional data, so only input
is implemented. Output comes in the form of a bitmask
representing piano keys from C to B with minors included
where appropriate (notes range from index 0 to index 11).
Special indices:    12: [
                    13: ]
                    14: \
                    15: unrecognized
==========================================================*/

module kbd(ar, clk, ps2_clk, ps2_dat, bitmask, keyval, keyOn, select, psclk, psdat);
	input	ar;
	input	clk;
	input  ps2_clk;
	input	ps2_dat;
	output reg [19:0] bitmask;
	output reg [3:0] keyval;
	output reg keyOn;
	output reg [1:0] select;
	output psclk, psdat;
	
    // For debugging timing waveforms
	assign psclk = ps2_clk;
	assign psdat = ps2_dat;
	
	
	reg [7:0] code;
  // We need to filter the ps2 clock for edges
	reg	ps2_clk_filt;
	reg [7:0] filter_sr;
	
	always @(negedge ar or posedge clk)
        if(~ar) begin
            // Initialize to all zeros
            ps2_clk_filt <= 1'b0;
            filter_sr <= 8'b0;
        end else begin
            // Shift filter_sr towards LSB (right shift) and insert ps2_clk as bit MSB
            filter_sr <= {ps2_clk, filter_sr[7:1]};
            
            if(filter_sr == 8'hff) // If ps2_clk has been high for 8 cycles
                ps2_clk_filt <= 1'b1; // Set filtered value high
            else if(filter_sr == 8'h00) // If ps2_clk has been low for 8 cycles
                ps2_clk_filt <= 1'b0; // Set filtered value low
        end
    
	reg [3:0]	   bit_count;
	reg			       currently_receiving;
  reg          received_stop;
	reg [3:0]    bitindex;

	always @(negedge ar or posedge ps2_clk_filt)
		if(~ar) begin
            // Initialize values to zero
            bit_count <= 0;
            code <= 7'h00;
            currently_receiving <= 1'b0;
            bitmask <= 0;
		end else begin
            // When not receiving, listen for ps2_dat to drop low (start bit)
            if(~currently_receiving && ps2_dat == 1'b0) begin
                currently_receiving <= 1'b1;
                bit_count <= 0;
            end else begin
                // Always increment bit count when triggered and receiving
                if(currently_receiving) begin
                    bit_count <= bit_count + 1'b1;

                    if(bit_count <= 4'd8)
                        code <= {ps2_dat, code[7:1]}; // Shift in the latest ps2 data bit_count
                    else begin
                        // We've received 8 bits!
                        // If we receive F0, the next index received will be
                        // the subject of a stop code
                        if(code == 8'hF0) begin
                            received_stop <= 1;
                        end else if(received_stop) begin
                            // If the last character received was a stop code clear that bit
                            bitmask[bitindex] <= 0;
                            received_stop <= 0;
                        end else begin
                            // Last character received was not a stop code
                            // so we should mark a bit high
                            bitmask[bitindex] <= 1;
                            // Output the currently held key
                            keyval <= bitindex;
                            keyOn <= 1;
                        end
                        
                        currently_receiving <= 1'b0;
                    end
                end
            end
        end
			
							
	// This always block defines the lookup table that converts
  // scan codes into bit positions for the output vector
	always@(code)
		case(code)
			8'h1A: bitindex = 0;   //Z
			8'h1B: bitindex = 1;   //S
			8'h22: bitindex = 2;   //X
			8'h21: bitindex = 3;   //C
			8'h2B: bitindex = 4;   //F
			8'h2A: bitindex = 5;   //V
			8'h34: bitindex = 6;   //G
			8'h32: bitindex = 7;   //B
			8'h31: bitindex = 8;   //N
			8'h3B: bitindex = 9;   //J
			8'h3A: bitindex = 10;  //M
			8'h42: bitindex = 11;  //K
			8'h41: bitindex = 12;  //<
			8'h4E: bitindex = 13;  //+
			8'h79: bitindex = 14;  //-
			default: bitindex = 15;//
		endcase
	
	wire pianoKeys;
	assign pianoKeys = bitmask[11:0];
	
	always @(negedge ar or posedge clk)
	if(~ar) begin
      // Initialize values to zero
      keyOn <= 0;
	end else begin
		if(~(&pianoKeys)) begin
		  keyOn <= 0;  
		end
  end
  
  //Process +/- keys
  reg plus_prev, minus_prev;
  wire plus_rising, minus_rising;
  assign plus_rising = (plus_prev==0)&&(bitmask[13]==1);
  assign minus_rising = (minus_prev==0)&&(bitmask[14]==1);
  
  always @(negedge ar or posedge clk)
	if(~ar) begin
      // Initialize values to zero
      select <= 0;
      plus_prev <= 0;
      minus_prev <= 0;
	end else begin
		if(plus_rising)
		  select <= select + 1;
		if(minus_rising)
		  select <= select - 1;
		
		plus_prev <= bitmask[13];
		minus_prev <= bitmask[14];
  end
	endmodule
	