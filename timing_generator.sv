
//defines.sv


/*
    DEIFNES based on the VGA timing standard. For this lab, we are using a 640x480 resolution at 25MHz with a 60Hz refresh rate
*/
localparam H_UPPER_BOUND =800 - 1;
localparam V_UPPER_BOUND =525*(H_UPPER_BOUND+1) - 1;


localparam H_ACTIVE_VIDEO_COUNT =640 - 1;
localparam H_FRONT_PORCH_COUNT =16- 1;
localparam H_SYNC_PULSE_COUNT =96- 1;
localparam H_BACK_PORCH_COUNT =48- 1;

localparam V_ACTIVE_VIDEO_COUNT= 480*(H_UPPER_BOUND+1)- 1;
localparam V_FRONT_PORCH_COUNT =10*(H_UPPER_BOUND+1)- 1;
localparam V_SYNC_PULSE_COUNT =2*(H_UPPER_BOUND+1)- 1;
localparam V_BACK_PORCH_COUNT =33*(H_UPPER_BOUND+1)- 1;






localparam HSYNC_OFF_LOW_BOUND = H_ACTIVE_VIDEO_COUNT + H_FRONT_PORCH_COUNT;
localparam HSYNC_OFF_HIGH_BOUND = H_UPPER_BOUND - H_BACK_PORCH_COUNT;

localparam VSYNC_OFF_LOW_BOUND = V_ACTIVE_VIDEO_COUNT + V_FRONT_PORCH_COUNT;
localparam VSYNC_OFF_HIGH_BOUND = V_UPPER_BOUND - V_BACK_PORCH_COUNT;


module timing_generator(  
    input clk, rst,
    input fifo_empty,
    input [23:0] fifo_data,
    output fifo_rreq,
    output [7:0] red, green, blue,
    output hsync, vsync, sync_n, blank_n
);


reg fifo_empty_db1;
wire always_en = 1;

//devounce the fifo_empty signal so we can look for a falling edge, on which we reset the counters
//because our write clock to the FIFO is twice as fast as our read clock, we know that once there is data 
//in the FIFO, it will never be empty again
FF #(1) debounce1(.clk(clk), .rst(rst), .d(fifo_empty), .q(fifo_empty_db1), .en(always_en));
wire FIFO_LOADED = ~fifo_empty & fifo_empty_db1;

//counter registers
reg [23:0] V_counter;
reg [23:0] H_counter;

//start the V counter at zero, and reset it when it reaches it's upper bound OR when the FIFO is loaded with data for the first time.
always @(posedge clk, posedge rst) begin

    if(rst) V_counter <= 0;   
    else if(FIFO_LOADED) V_counter <= 0;
    else if(V_counter == V_UPPER_BOUND) V_counter <= 0;
    else V_counter <= V_counter + 1;

end


//start the H counter at zero, and reset it when it reaches it's upper bound OR when the FIFO is loaded with data for the first time.
always @(posedge clk, posedge rst) begin

    if(rst) H_counter <= 0;   
    else if(FIFO_LOADED) H_counter <= 0;
    else if(H_counter == H_UPPER_BOUND) H_counter <= 0;
    else H_counter <= H_counter + 1;

end

//active video condition determines when color data will be sent and when the RBG lines will be held at zero
//The active video begins the clock cycle after the fifo becomes not empty.

assign active_video_condition =  (H_counter >= 0) && (V_counter >= 0) && (H_counter <= H_ACTIVE_VIDEO_COUNT) && (V_counter <= V_ACTIVE_VIDEO_COUNT);

//constantly request data from the FIFO during an active video condition
assign fifo_rreq = active_video_condition ? 1 : 0;

//clock the data as we receive it from the FIFO
reg [23:0] pixel_data;
always @(posedge clk, posedge rst) begin
    if(rst) pixel_data <= 0;
    else if(FIFO_LOADED) pixel_data <= fifo_data;
    else if(!fifo_empty && active_video_condition) pixel_data <= fifo_data;
end

//HSYNC and VSYNC counters
assign hsync = (H_counter >= 0) && (H_counter >= HSYNC_OFF_LOW_BOUND) && (H_counter < HSYNC_OFF_HIGH_BOUND) ? 0 : 1;
assign vsync = (V_counter >= 0) && (V_counter > VSYNC_OFF_LOW_BOUND) && (V_counter < VSYNC_OFF_HIGH_BOUND) ? 0 : 1;

assign red = (active_video_condition) ? pixel_data[23:16] : 0;
assign green = (active_video_condition) ? pixel_data[15:8] : 0;
assign blue = (active_video_condition) ? pixel_data[7:0] : 0;

//blank_n forces all the RGB values to zero. we want this whenever there is no active video condition
assign blank_n = (H_counter >= 0) && ((H_counter > H_ACTIVE_VIDEO_COUNT) || (V_counter > V_ACTIVE_VIDEO_COUNT))? 0:1;

//sync_n forces the G line down to a special value (encoded sync signal)
assign sync_n = (hsync ^ vsync);

endmodule