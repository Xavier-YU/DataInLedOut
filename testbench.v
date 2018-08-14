`timescale 1ns/1ps

module testbench();

	//Port Statement
	reg SysClk;
	reg SysRst;
	
	reg [7:0] DataIn;
	reg [3:0]  AddressIn;
	
	reg WRITEIn;
	reg CLEARIn;
	
	wire CLROut;
	wire [7:0] CSOut;
	wire DINex;
	wire SCLK;
	
	
	//Unit Under Test
	top uut(.SysClk(SysClk),.SysRst(SysRst),.DataIn(DataIn),.AddressIn(AddressIn),.WRITEIn(WRITEIn),.CLEARIn(CLEARIn),.CLROut(CLROut),.CSOut(CSOut),.DINex(DINex),.SCLK(SCLK));
	
	//Real 50MHz System Clock
	always
		#10 SysClk = ~SysClk;
    
	initial
	begin
	//Initiate and Reset
		SysClk = 0;
		SysRst = 0;
		DataIn = 0;
		AddressIn = 0;
		WRITEIn = 0;
		CLEARIn = 1;
	
	//Reset and Idle
		#45
		SysRst = 1;
	
	//First Write
		#80
		WRITEIn = 1;
		DataIn = 8'b1100_0011;
		AddressIn = 4'b0111;

		#200
		WRITEIn = 0;
	
    //Second Write
		#20000
		WRITEIn = 1;
		DataIn = 8'b0011_0101;
		AddressIn = 4'b0010;
		
		#200
		WRITEIn = 0;
    
    //Write Disabled, So Nothing Happen
		#20000
		DataIn = 8'b0011_0101;
		AddressIn = 8'b0111;	
	
    //Invalid Address, So Nothing Happen
		#2000
                WRITEIn = 1;
		DataIn = 8'b0011_0101;
		AddressIn = 8'b1111;	

		#200
		WRITEIn = 0;	
	//Simulation End
		#5000
		$stop;
	end
endmodule