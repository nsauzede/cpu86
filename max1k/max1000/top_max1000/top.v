module top (
	input CLK12M,
	input USER_BTN,
	output reg [7:0] LED,
	inout [8:1] PIO,
	
	inout [5:0] BDBUS,
	inout [14:0] D
);

// BDBUS[0] is USB UART TX (FPGA RX)
// BDBUS[1] is USB UART RX (FPGA TX)

drigmorn1_top drigmorn1_top (
	.CLOCK_40MHZ(CLK12M),
	.CTS(1'b1),
	.PIN3(USER_BTN),
	.RXD(BDBUS[0]),
	.LED1(LED[0]),
	.LED2N(LED[1]),
	.LED3N(LED[2]),
	.PIN4(LED[3]),
	.RTS(),
	.TXD(BDBUS[1])
);
endmodule
