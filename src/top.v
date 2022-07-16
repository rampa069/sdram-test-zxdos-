//-------------------------------------------------------------------------------------------------
module top
//-------------------------------------------------------------------------------------------------
(
	input  wire       clock50,
//	input  wire[ 1:0] button,
	output wire[ 1:0] led,
	output wire       SDRAM_CLK,
	output wire       SDRAM_CKE,
	output wire       SDRAM_nCS,
	output wire       SDRAM_nWE,
	output wire       SDRAM_nRAS,
	output wire       SDRAM_nCAS,
	output wire       SDRAM_DQMH,
	output wire       SDRAM_DQML,
	inout  wire[15:0] SDRAM_DQ,
	output wire[ 1:0] SDRAM_BA,
	output wire[12:0] SDRAM_A
);
//-------------------------------------------------------------------------------------------------

clock Clock
(
	.i       (clock50 ),
	.o       (clock   ),
	.sdramCk (SDRAM_CLK ),
	.locked  (init    )
);

//-----------------------------------------------------------------------------

sdram SDram
(
	.clock   (clock   ),
	.init    (init    ),
	.ready   (ready   ),
	.running (running ),
	.error   (error   ),

	.sdramCs (SDRAM_nCS ),
	.sdramRas(SDRAM_nRAS),
	.sdramCas(SDRAM_nCAS),
	.sdramWe (SDRAM_nWE),
	.sdramDqm({SDRAM_DQMH,SDRAM_DQML}),
	.sdramD  (SDRAM_DQ ),
	.sdramBa (SDRAM_BA ),
	.sdramA  (SDRAM_A  )
);

assign SDRAM_CKE = 1'b1;

//-----------------------------------------------------------------------------

reg[23:0] bc; wire blink = bc[23];
always @(posedge clock) bc <= bc+24'd1;

reg[27:0] oc; wire on = !oc[27];
always @(posedge error, posedge clock) if(error) oc <= 28'd0; else if(on) oc <= oc+28'd1;

assign led = { ready&(running^(on&blink)), ready&(~running^(on&blink)) };

//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------
