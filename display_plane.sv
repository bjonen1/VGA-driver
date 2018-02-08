`timescale 1 ps / 1 ps
module display_plane(input clock, input [23:0] ROM_data, input reset, input [9:0] wrusedw, output reg [12:0] address, output reg [23:0] FIFO_data, output reg wrreq);

	reg [3:0] pxl_cnt;
	reg [3:0] vert_cnt;
	reg [9:0] hor_cnt;
	
	reg incr_pxl_cnt, incr_vert_cnt, incr_hor_cnt, incr_address;

	typedef enum reg {idle, write} state_t;
	state_t state, next_state;
	
	always_ff @(posedge clock, posedge reset)
		if (reset)begin
			state<=idle;
			address<=24'h0;
			pxl_cnt <= 0;
			vert_cnt <= 0;
			hor_cnt <= 0;
		end
		else begin
			state <= next_state;
			
			if (incr_address)
				address <= address+1;
			else if (incr_vert_cnt)
				address <= address - 79; //go back to beginning of the horizontal line
			else
				address <= address;
				
			if (incr_pxl_cnt)
				pxl_cnt <= pxl_cnt + 1;
			else 
				pxl_cnt <= 0; //we are either incrementing or going back to idle.
				
			if (incr_hor_cnt)
				hor_cnt <= hor_cnt + 1;
			else if (hor_cnt == 640)
				hor_cnt <= 0;
			else
				hor_cnt <= hor_cnt;
				
			if (incr_vert_cnt)
				vert_cnt <= vert_cnt + 1;
			else if (vert_cnt == 7 && hor_cnt == 640) //ver_cnt == 8
				vert_cnt <= 0;
			else
				vert_cnt <= vert_cnt;
				
		end
			

	always_comb begin
		incr_address = 0;
		incr_pxl_cnt = 0;
		incr_vert_cnt = 0;
		incr_hor_cnt = 0;
		wrreq = 0;
		
		case (state)
			idle: begin	
				if (wrusedw < 10'd500)
					next_state = write;
				else 
					next_state = idle;
			end
			
			write:begin
				
				FIFO_data = ROM_data;
				if (pxl_cnt < 4'd8)begin
					next_state = write;
					incr_pxl_cnt = 1;
					incr_hor_cnt = 1;
					wrreq = 1;
				end
				else begin
					next_state = idle;
					if (hor_cnt < 640)begin
						incr_address = 1;
						
					end
					else if (hor_cnt == 640 && vert_cnt < 7) //else if (hor_cnt == 640 && vert_cnt < 8)1
						incr_vert_cnt = 1;
					else 
						incr_address = 1; //if pxl cnt is 8, and hor cnt is 480 and vert cnt is 8 then just go to next address
				end
			end
		endcase
	end
endmodule

`timescale 1 ps / 1 ps
module display_plane_TB();
	reg clock;
	wire [23:0] ROM_data;
	reg reset;
    reg[9:0] wrusedw;
	
	wire[12:0] address;
	wire [23:0] FIFO_data;
	wire wrreq;
	
	display_plane display_plane1(clock,ROM_data,reset,wrusedw,address, FIFO_data, wrreq);
	ROM2 rom2(address, clock, ROM_data);
	initial begin
		clock = 0;
		reset =1;

		wrusedw = 10'd0;
		
		repeat (5) @(posedge clock);
		reset = 0;
	end
		
	always
	#1 clock =~ clock;
endmodule