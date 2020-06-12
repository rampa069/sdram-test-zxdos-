//-------------------------------------------------------------------------------------------------
module clock
//-------------------------------------------------------------------------------------------------
(
	input         i,
	output        o,
	output        sdramCk,
	output        locked
);
//-------------------------------------------------------------------------------------------------

IBUFG Ibufg(.I(i), .O(ci));

DCM_SP #
(
	.CLKIN_PERIOD          (20.000),
	.CLKFX_DIVIDE          ( 1    ),
	.CLKFX_MULTIPLY        ( 2    )  // 100 MHz
)
Dcm
(
	.RST                   (1'b0),
	.DSSEN                 (1'b0),
	.PSCLK                 (1'b0),
	.PSEN                  (1'b0),
	.PSINCDEC              (1'b0),
	.CLKIN                 (ci),
	.CLKFB                 (fb),
	.CLK0                  (c0),
	.CLK90                 (),
	.CLK180                (),
	.CLK270                (),
	.CLK2X                 (),
	.CLK2X180              (),
	.CLKFX                 (co),
	.CLKFX180              (),
	.CLKDV                 (),
	.PSDONE                (),
	.LOCKED                (locked),
	.STATUS                ()
);

BUFG BufgFB(.I(c0), .O(fb));
BUFG Bufg000(.I(co), .O(o));

ODDR2 oddr2
(
	.Q       (sdramCk), // 1-bit DDR output data
	.C0      ( o     ), // 1-bit clock input
	.C1      (~o     ), // 1-bit clock input
	.CE      (1'b1   ), // 1-bit clock enable input
	.D0      (1'b1   ), // 1-bit data input (associated with C0)
	.D1      (1'b0   ), // 1-bit data input (associated with C1)
	.R       (1'b0   ), // 1-bit reset input
	.S       (1'b0   )  // 1-bit set input
);

//-------------------------------------------------------------------------------------------------
endmodule
//-------------------------------------------------------------------------------------------------
