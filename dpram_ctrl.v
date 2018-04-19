/*dpram_ctrl.v by Brandt Hill
* Controls some DPRAM, 1024 16-bit words
* for use on a DE0 or DE2 board
* For ECE641, 
*/
module dpram_ctrl(clk, A, Din, RD, WR, Dout, Done);
	input clk;					//MHz Clock
	input [14:0] A; 			//Address input for reading or writing
	input [15:0] Din; 			//Input Data that will be written
	wire [15:0] Q;				//Current data being output from memory
	input RD;					//Input bit for reading data
	input WR;					//Input bit for writing data
	reg [15:0] Data;			//Data that will be written to memory 			(Prev. output)
	reg [14:0] Wr_A;			//Address to be written to						(Prev. output)
	reg [14:0] Rd_A;			//Address to be read from						(Prev. output)
	output reg [15:0] Dout;		//Current data that's been read from memory
	wire clkout;				//Basically the same as clk but for the memory	(Prev. output)
	reg WE;						//Write enable (active low)						(Prev. output)
	output reg Done;			//Output signals when a read/write is done
	reg [2:0] cs;				//Current state
	parameter [2:0] 	Idle = 3'b000, WrStart = 3'b001, WrCont = 3'b010, WrDone = 3'b011,
						RdStart = 3'b100, RdCont = 3'b101, RdDone = 3'b110, Err = 3'b111;
	parameter Writes = 1'b1;	//Since write enable is active low				
	
	assign clkout = clk;

	always@(posedge clk)
		case(cs)
			Idle:		//Starting state		
				if(WR)
					begin
						cs = WrStart;
						Wr_A = A;
						Data = Din;
						Done = 1'b0;
					end
				else if(RD)
					begin
						cs = RdStart;
						WE = ~Writes;
						Rd_A = A;
						Done = 1'b0;
					//Dout = {16{1'b0}};
					end
				else
					begin
						cs = Idle;
						Done = 1'b0;
						//Dout = {16{1'b0}};	//Reset data when not actively reading
					end
			WrStart:	//Starting the writing process, set write enable active		
				begin
					cs = WrCont;
					WE = Writes;
				end
			WrCont:		//Give some extra time to write
				begin
					cs = WrDone;
				end
			WrDone:		//Should be done writing now, set done	
				begin
					cs = Idle;
					WE = ~Writes;
					Done = 1'b1;
				end
			RdStart:	//Starting the reading process	
				begin
					cs = RdCont;
					//Dout = Q;
				end
			RdCont:		//Give some extra time to read
				begin
					cs = RdDone;
					//Dout = Q;
				end
			RdDone:		//Should be done reading now, set done
				begin
					cs = Idle;
					Dout = Q;
					Done = 1'b1;
				end
			default:
				begin
					cs = Idle;
					Done = 1'b0;
					Dout = {16{1'b0}};
				end
		endcase
dpram ram(.clock(clkout), .data(Data), .rdaddress(Rd_A), .wraddress(Wr_A), .wren(WE), .q(Q));		
endmodule