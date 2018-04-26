                         
module data_setup (
	clk_50,
	clk_br,
	data_codec,
	done,
	ar,
	activate,
	clk_xck
);
	input  clk_50;
	input  done;
	input  ar;
	output clk_br;
	output [23:0]data_codec;
	output activate;
	output clk_xck;


reg  [10:0]counter;

wire  clk_br=counter[9];//48.8KHz clock
wire  clk_xck=counter[1];//12.5MHz clock

wire  [15:0]ctrl_word[6:0];//data to write to the codec registers
reg  [5:0]address;//address of the registers

wire [23:0]data_codec={8'h34,ctrl_word[address]};
	
wire  activate =((address < 6'd7) && (done==1'b1))? counter[10]:1'b1;

always @(negedge ar or posedge done) begin
	if (~ar) 
		address=0;
	else 
		if (address < 6'd7) 
			address=address+6'd1;
end


assign	ctrl_word[0]= 16'h0c02;	     //power down
assign	ctrl_word[1]= 16'h0ec2;	     //master
assign	ctrl_word[2]= 16'h0812;	     //sound select	
assign	ctrl_word[3]= 16'h1000;		 //mclk	and sampling freq setup
assign	ctrl_word[4]= 16'h001d;		 //LLine in 
assign	ctrl_word[5]= 16'h021d;		 //RLine in
assign	ctrl_word[6]= 16'h1201;		 //active


always @(negedge ar or posedge clk_50 ) 
	if(~ar)
		counter = 0;
	else
		counter=counter+11'd1;


endmodule
