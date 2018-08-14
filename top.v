module top(input            SysClk,
           input            SysRst,

           input [7:0]     DataIn,
           input [3:0]      AddressIn,
           input            WRITEIn,
           input            CLEARIn,

           output           CLROut,
           output reg [7:0] CSOut,
		   output reg       DINex,
		   output reg       SCLK);
	
	//Input Buffer
	reg [7:0] DataInBuf;
	reg [3:0]  AddressInBuf;
	
	//Other Regs
	reg CurrentState;
	reg NextState;
	reg [3:0] SerialCounter;
	reg [5:0] SysClkCounter;
	
	//Direct Clear Input and Output
	assign CLROut = CLEARIn;
	
	//State Refresh
	always@(posedge SysClk,negedge SysRst)
	begin
		if(SysRst == 1'b0)
			CurrentState <= 1'b0;
		else
		    CurrentState <= NextState;
	end
	
	
	//State Change
	always@(*)
	begin
		case(CurrentState)
		//Idle State
		1'b0:
		begin
			if(WRITEIn == 1'b0)
				NextState = 1'b0;
			else
				NextState = 1'b1;
		end
		//8-bit Send State
		1'b1:
		begin
			if(SerialCounter == 4'd0)
				NextState = 1'b0;
			else
				NextState = 1'b1;
		end
		endcase
	end
	
	
	//State Output
	always@(posedge SysClk,negedge SysRst)
	begin
	    //System Reset
		if (SysRst==1'b0)
		begin
		  CSOut <= 8'b1111_1111;
		  DINex <= 1'b0;
		  SCLK  <= 1'b0;
		  SerialCounter <= 0;
		  SysClkCounter <= 0;
		end
		else
		begin
			case(CurrentState)
			//Idle State: do nothing
			0:
			begin
				CSOut <= 8'b1111_1111;
				DINex <= 1'b0;
				SCLK  <= 1'b0;
				SerialCounter <= 8;
				SysClkCounter <= 0;
				
				DataInBuf <= DataIn;
				AddressInBuf <= AddressIn;
				
			end
		    //8-bit Send State
			1:
			begin
				//Decode Address
			    CSOut <= AddressInBuf[3]?8'b1111_1111:(~(8'b0000_0001<<AddressInBuf[2:0]));
				if(SysClkCounter==1)
				begin
					//Prepare Serial Data at Negedge of SCLK
					SysClkCounter <= SysClkCounter + 1;
				    DINex <= DataInBuf >> (SerialCounter - 1);//Shift for Serial Output
				end
				else if(SysClkCounter==24)
				begin
				    //4820 Acquire Data at Posedge of SCLk
					SCLK <= 1'b1;
					SysClkCounter <= SysClkCounter + 1;
				end
				else if(SysClkCounter==49)//SCLK Frequency:50MHz/50=1MHz
				begin
					SCLK <= 1'b0;
					SysClkCounter <= 0;
					SerialCounter <= SerialCounter - 1;
				end
				else
					SysClkCounter <= SysClkCounter + 1;

			end	
			endcase
		end
	end
endmodule
           		   