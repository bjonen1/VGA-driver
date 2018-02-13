
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module lab2_vga(

	//////////// CLOCK //////////
	input 		          		CLOCK2_50,
	input 		          		CLOCK3_50,
	input 		          		CLOCK4_50,
	input 		          		CLOCK_50,

	//////////// SEG7 //////////
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,

	//////////// KEY //////////
	input 		     [3:0]		KEY,

	//////////// VGA //////////
	output		          		VGA_BLANK_N,
	output		     [7:0]		VGA_B,
	output		          		VGA_CLK,
	output		     [7:0]		VGA_G,
	output		          		VGA_HS,
	output		     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS
	
);

//debug   

  assign HEX0 = rdreq;
  assign HEX1 = wrreq;
  assign HEX2 = rdempty;
  assign HEX3 = locked;
  assign HEX4 = q[6:0];
  assign HEX5 = address[6:0];
  

// press button[0] to generate a low active reset signal
   wire reset = ~KEY[0];

//=======================================================
//  REG/WIRE declarations
//=======================================================

	wire [23:0] ROM_data;
	
	wire[12:0] address;
	wire [23:0] FIFO_data;
	wire wrreq;
	wire clk2, locked;
	
	
	//new for FIFO instead of TB control
	wire rdreq;
	wire [23:0] q;
	wire rdempty,wrfull;
	wire [9:0] rdusedw;
	wire [9:0] wrusedw;
	


//=======================================================
//  Structural coding
//=======================================================

	
	VGA25Mhz PLL25Mhz(CLOCK2_50,   //  refclk.clk
		reset,      //   reset.reset
		VGA_CLK, // outclk0.clk
		locked);
	
	//assign clk2 = (~locked) ? 1 : ~KEY[0];
	
	display_plane display_plane1(CLOCK2_50,ROM_data,reset,wrusedw,address, FIFO_data, wrreq);
	ROM2 rom2(address, CLOCK2_50, ROM_data);
	FIFO2 FIFO2(FIFO_data,VGA_CLK,rdreq,CLOCK2_50,wrreq,q,rdempty,rdusedw,wrfull,wrusedw);
	
	timing_generator timing_generator1(.clk(VGA_CLK), .rst(reset), .fifo_empty(rdempty),.fifo_data(q),.fifo_rreq(rdreq), .red(VGA_R), 
	.green(VGA_G), .blue(VGA_B), .hsync(VGA_HS), .vsync(VGA_VS), .sync_n(VGA_SYNC_N), .blank_n(VGA_BLANK_N));

endmodule