//-------------------------------------------------------------------------------------------------
module top
//-------------------------------------------------------------------------------------------------
(
	input  wire       clock50,
//	input  wire[ 1:0] button,
	output wire[ 1:0] led,
	output wire       sdramCk,
	output wire       sdramCe,
	output wire       sdramCs,
	output wire       sdramWe,
	output wire       sdramRas,
	output wire       sdramCas,
	output wire[ 1:0] sdramDqm,
	inout  wire[15:0] sdramD,
	output wire[ 1:0] sdramBa,
	output wire[12:0] sdramA
);
//-------------------------------------------------------------------------------------------------

clock Clock
(
	.i       (clock50 ),
	.o       (clock200),
	.locked  (init    )
);

reg sdrck;

always @(posedge clock200) sdrck <= ~sdrck;
BUFG BufgO(.I(sdrck), .O(clock));

//-----------------------------------------------------------------------------

sdram SDram
(
	.clock   (clock   ),
	.init    (init    ),
	.ready   (ready   ),
	.running (running ),
	.error   (error   ),

	.sdramCs (sdramCs ),
	.sdramRas(sdramRas),
	.sdramCas(sdramCas),
	.sdramWe (sdramWe ),
	.sdramDqm(sdramDqm),
	.sdramD  (sdramD  ),
	.sdramBa (sdramBa ),
	.sdramA  (sdramA  )
);

//-----------------------------------------------------------------------------

reg[23:0] bc; wire blink = bc[23];
always @(posedge clock) bc <= bc+24'd1;

reg[27:0] oc; wire on = !oc[27];
always @(posedge error, posedge clock) if(error) oc <= 28'd0; else if(on) oc <= oc+28'd1;

assign led = { ready&(running^(on&blink)), ready&(~running^(on&blink)) };

assign sdramCk = sdrck;
assign sdramCe = 1'b1;

//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------
