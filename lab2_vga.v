
//=======================================================
//  This code is generated by Terasic System Builder
//=======================================================

module lab2_vga(

	//////////// CLOCK //////////
	input 		          		CLOCK_50,     // use this clock as your clock input
	input 		          		CLOCK2_50,    // you don't have to use this one
	input 		          		CLOCK3_50,    // you don't have to use this one
	input 		          		CLOCK4_50,    // you don't have to use this one

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
	output		     [7:0]		VGA_B,
	output		          		VGA_BLANK_N,
	output		          		VGA_CLK,
	output		     [7:0]		VGA_G,
	output		          		VGA_HS,
	output		     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS
);

// Change these wire and reg definations as you wish.
wire clk_25m;
wire fifo_empty, fifo_full;
wire [23:0] data_dp_fifo,picture_pixel,fifo_pixel_data;
wire [12:0] mem_addr;
wire locked_dcm;
wire re;
wire [12:0] display_address;

wire [23:0] fifo_data_out;
wire fifo_wr_en, fifo_rd_en;
reg start_display;

// use PUSH BUTTON [0] to generate a low active reset signal
wire rst = ~KEY[0];

// Don't modify the code below
assign HEX5 = 7'b0010010; //5
assign HEX4 = 7'b0010010; //5
assign HEX3 = 7'b0011001; //4
assign HEX2 = 7'b1000000; //0
assign HEX1 = 7'b1000000; //0
assign HEX0 = 7'b0100100; //2

// Add your logic for the VGA project

endmodule
