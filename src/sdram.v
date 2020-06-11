//-------------------------------------------------------------------------------------------------
module sdram
//-------------------------------------------------------------------------------------------------
(
	input  wire       clock,
	input  wire       init,
	output reg        ready,
	output wire       running,
	output reg        error,
	output reg        sdramCs,
	output reg        sdramRas,
	output reg        sdramCas,
	output reg        sdramWe,
	output reg [ 1:0] sdramDqm,
	inout  wire[15:0] sdramD,
	output reg [ 1:0] sdramBa,
	output reg [12:0] sdramA
);
//-------------------------------------------------------------------------------------------------
`include "sdram_cmd.v"
//-------------------------------------------------------------------------------------------------

reg[15:0] sdramDo;
assign sdramD = sdramWe ? 16'bZ : sdramDo;

//-----------------------------------------------------------------------------

reg init2;
wire reset = init && !init2;
always @(posedge clock) init2 <= init;

reg[15:0] di;
reg[23:0] addr;
reg[ 4:0] count;

always @(posedge reset, posedge clock)
if(reset)
begin
	NOP;												// default state is NOP

	error <=  1'b0;
	ready <=  1'b0;
	di    <= 16'd0;
	addr  <= 24'd0;
	count <=  5'd0;
end
else
begin
	NOP;												// default state is NOP
	count <= count+5'd1;

	if(!ready)
		case(count)
		// init
		 0: INHIBIT;
		 8: PRECHARGE(1'b1);							//  8    PRECHARGE: all, tRP's minimum value is 20ns
		12: REFRESH;									// 11    REFRESH, tRFC's minimum value is 66ns
		20: REFRESH;									// 20    REFRESH, tRFC's minimum value is 66ns
		28: LMR(13'b000_1_00_010_0_000);				// 29    LDM: CL = 2, BT = seq, BL = 1, wait 2T
		31: ready <= 1'b1;
		endcase
	else
		case(count)
		// write
		 0: ACTIVE(addr[23:22], addr[21:9]);			// 32    ACTIVE: bank = 0, row = 0, wait 2T
		 3: WRITE(2'b00, di, 2'b00, addr[8:0], 1'b0);	// 35    WRITE: dqm = 00, data, bank = 0, col = 0, wait CL
		// read
		 8: ACTIVE(addr[23:22], addr[21:9]);			// 50    ACTIVE: bank = 0, row = 0, wait 2T
		11: READ(2'b00, 2'b00, addr[8:0], 1'b0);		// 53    READ, dqm = 00, bank = 0, col = 0, wait CL
		14: error <= sdramD != di; // || &addr;
		// next
		30: di  <= di+16'd1;
		31: addr <= addr+24'd1;
		endcase
end

assign running = addr[22];

//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------
