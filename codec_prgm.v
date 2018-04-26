module codec_prgm (
	ar,
	clk_br,
	SCLK,//I2C CLOCK
 	SDAT,//I2C DATA
	data_codec,
	activate, 
	done
);
	input  ar;
	input  clk_br;
	input  [23:0]data_codec;	
	input  activate;		
 	inout  SDAT;	
	output SCLK;
	output done;	
	

reg ack_enable;
reg bit_sent;
reg sclk_enable;
reg done;
reg [23:0]data_sent;
reg [5:0]counter;

assign SCLK=sclk_enable | ( ((counter >= 4) & (counter <=30))? ~clk_br :1'b0 );

assign SDAT=ack_enable?1'bz:bit_sent ;

always @(negedge ar or posedge clk_br )
	if(~ar)
		counter = 0;
	else
	
    	begin
			if (activate==0) 
				counter=0;
			else 
				if (counter < 6'd33)
				 counter=counter+6'd1;	
		end

always @(negedge ar or posedge clk_br )
  if(~ar)
   begin
     done=0;bit_sent=1; sclk_enable=1;ack_enable=1'b0;
   end
  else
   case (counter)
	6'd0  : begin  done=0;bit_sent=1; sclk_enable=1;ack_enable=1'b0;end
	//start
	6'd1  : begin data_sent=data_codec;bit_sent=0;ack_enable=1'b0;end
	6'd2  : sclk_enable=0;
	//SLAVE ADDR
	6'd3  : bit_sent=data_sent[23];
	6'd4  : bit_sent=data_sent[22];
	6'd5  : bit_sent=data_sent[21];
	6'd6  : bit_sent=data_sent[20];
	6'd7  : bit_sent=data_sent[19];
	6'd8  : bit_sent=data_sent[18];
	6'd9  : bit_sent=data_sent[17];
	6'd10 : bit_sent=data_sent[16];	
	6'd11 : ack_enable=1'b1;//ACK

	//SUB ADDR
	6'd12  : begin bit_sent=data_sent[15];ack_enable=1'b0; end
	6'd13  : bit_sent=data_sent[14];
	6'd14  : bit_sent=data_sent[13];
	6'd15  : bit_sent=data_sent[12];
	6'd16  : bit_sent=data_sent[11];
	6'd17  : bit_sent=data_sent[10];
	6'd18  : bit_sent=data_sent[9];
	6'd19  : bit_sent=data_sent[8];	
	6'd20  : ack_enable=1'b1;//ACK

	//DATA
	6'd21  : begin bit_sent=data_sent[7];ack_enable=1'b0;end
	6'd22  : bit_sent=data_sent[6];
	6'd23  : bit_sent=data_sent[5];
	6'd24  : bit_sent=data_sent[4];
	6'd25  : bit_sent=data_sent[3];
	6'd26  : bit_sent=data_sent[2];
	6'd27  : bit_sent=data_sent[1];
	6'd28  : bit_sent=data_sent[0];	
	6'd29  : ack_enable=1'b1;//ACK

	
	//stop
    6'd30 : begin bit_sent=1'b0;sclk_enable=1'b0; ack_enable=1'b0; end	
    6'd31 : sclk_enable=1'b1; 
    6'd32 : begin bit_sent=1'b1; done=1; end 

	endcase


endmodule
