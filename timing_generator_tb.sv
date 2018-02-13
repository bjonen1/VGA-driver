

module timing_generator_tb(output dummy); //this output is here so quartus will not get mad when we compile it as the top level modiule

//wires to connect to the DUT
    reg  fifo_empty;
    wire [23:0]  fifo_data;
    reg clk, rst;
    reg  fifo_rreq;
    wire [7:0]  red, green, blue;
    wire  hsync, vsync, sync_n, blank_n;




//these memories hold the pixels recieved from the VGA (simulates a recieving video screen
    reg [7:0] red_pixels_rec [(640*480 -1) : 0];
    reg [7:0] blue_pixels_rec [(640*480 -1) : 0];
    reg [7:0] green_pixels_rec [(640*480 -1) : 0];


//task that waits one clock cycle. simple but makes the code easier to understand
task wait_num_pixel;
    input [31:0] pixels;
    
    repeat (pixels) begin
         @(posedge clk);
         #1;
    end
endtask


//counting variables
int i;
int j;

//monitoring the sync_n signal
wire expected_sync_n;
assign expected_sync_n = hsync ^ vsync;
wire match_sync_n = (expected_sync_n) ^ sync_n ? 0 : 1;

//this tells the simulator when to capture color data
reg active_video;

//this is a variable that the recieved color data is checked against
reg [7:0] expected_val;

//keeps track of how many frames we have simulated
int frame;

//this holds the color values for the pixel data. Because we are not simulating with a FIFO, we will increment this value 
// and assign the R, G, B color lines to it's value as if it was data from the FIFO
reg [7:0] red_blue_green_data_pointer;


//Instantiation of our DUT
timing_generator DUT(  
    .clk(clk),
    .rst(rst),
    .fifo_empty(fifo_empty),
    .fifo_data(fifo_data),
    .fifo_rreq(fifo_rreq),
    .red(red),
     .green(green), 
     .blue(blue),
    .hsync(hsync), 
    .vsync(vsync), 
    .sync_n(sync_n),
     .blank_n(blank_n)
);



initial begin
    //initialze signals, pulse reset
    //mimick the FIFO being loaded with a falling edge on fifo_empty
    clk = 0;
    rst = 1;
    fifo_empty = 1;
    active_video = 0;
    red_blue_green_data_pointer = 0;
    @(posedge clk);
    fifo_empty = 0;
    rst = 0;


    //start active video so our simualted VGA reciever knows that color data is valid
    active_video = 1;

    @(posedge clk);
        
    $monitor("Error on sync_n! at time %d", match_sync_n, $time);
    #1;

    
   //active video
    for (frame = 0; frame < 40; frame = frame + 1) begin

/*

    For each frame we send, check the hsync/vsync/color signals simeotanouesly 

*/

    fork

        begin
            repeat (480) begin  //we are sending 480 lines per frame
                if(hsync != 1) $display("hsync incorrect. not 1 during active video at %d", $time/10);
            //  else $display("hsync correct!  %d", $time/10);
                wait_num_pixel(639);
                active_video = 0;
                wait_num_pixel(1);
                if(hsync != 1) $display("hsync incorrect. not 1 during front porch at %d", $time/10);
                // else $display("hsync correct! %d", $time/10);
                wait_num_pixel(16);
                if(hsync != 0) $display("hsync incorrect. not 0 during sync pulse %d", $time/10);
                // else $display("hsync correct! %d", $time/10);
                wait_num_pixel(96);
                if(hsync != 1 ) $display("hsync incorrect. not 1 during back porch %d", $time/10);
                // else $display("hsync correct! %d", $time/10);    
                wait_num_pixel(48);
            
            end
    end

    begin
            if(vsync != 1) $display("vsync incorrect. not data during active video at %d", $time/10);
            else $display("vsync correct!  %d", $time/10);
            wait_num_pixel(480*800);
            if(vsync != 1) $display("vsync incorrect. not 0 during front porch at %d", $time/10);
            else $display("vsync correct! %d", $time/10);
            wait_num_pixel(10*800);
            if(vsync != 0) $display("vsync incorrect. not 0 during sync pulse %d", $time/10);
            else $display("vsync correct! %d", $time/10);
            wait_num_pixel(2*800);
            if(vsync != 1 ) $display("vsync incorrect. not 0 during back porch %d", $time/10);
            else $display("vsync correct! %d", $time/10);    
            wait_num_pixel(33*800);
    end 

    begin
    repeat (480) begin //we are sending 480 lines per frame
            active_video = 1;
            
            if(red != fifo_data[23:16]) $display("red incorrect. not data during active video at %d, is %x,  should be %x", $time/10, red, fifo_data[23:16]);
            //else $display("red correct!  %d", $time/10);
            wait_num_pixel(640);
            active_video = 0;
            if(red != 0) $display("red incorrect. not 0 during front porch at %d, is %x", $time/10, red);
            //else $display("red correct! %d", $time/10);
   
            wait_num_pixel(16);
            if(red != 0) $display("red incorrect. not 0 during sync pulse %d, is %x", $time/10, red);
            //else $display("red correct! %d", $time/10);
            wait_num_pixel(96);
            if(red != 0 ) $display("red incorrect. not 0 during back porch %d, is %x", $time/10, red);
            //else $display("red correct! %d", $time/10);
            wait_num_pixel(48); 
            end   
    end
    
        begin
        repeat (480) begin //we are sending 480 lines per frame
            #1
            if(blue != fifo_data[7:0]) $display("blue incorrect. not data during active video at %d, is %x, should be %x", $time/10, blue, fifo_data[7:0]);
            //else $display("blue correct!  %d", $time/F0);
            wait_num_pixel(640);
            if(blue != 0) $display("blue incorrect. not 0 during front porch at %d, is %x", $time/10, blue);
            //else $display("blue correct! %d", $time/10);
            wait_num_pixel(16);
            if(blue != 0) $display("blue incorrect. not 0 during sync pulse %d, is %x", $time/10, blue);
            //else $display("blue correct! %d", $time/10);
            wait_num_pixel(96);
            if(blue != 0 ) $display("blue incorrect. not 0 during back porch %d, is %x", $time/10, blue);
            //else $display("blue correct! %d", $time/10);
            wait_num_pixel(48);
            end 
            end   
            
        begin
        repeat (480) begin //we are sending 480 lines per frame
        
            if(green != fifo_data[15:8]) $display("green incorrect. not 1 during active video at %d, is %x, should be %x", $time/10, green, fifo_data[15:8]);
            //else $display("green correct!  %d", $time/10);
            wait_num_pixel(640);
            if(green != 0) $display("green incorrect. not 1 during front porch at %d, is %x", $time/10, green);
            //else $display("green correct! %d", $time/10);
            wait_num_pixel(16);
            if(green != 0) $display("green incorrect. not 0 during sync pulse %d, is %x", $time/10, green);
            //else $display("green correct! %d", $time/10);
            wait_num_pixel(96);
            if(green != 0 ) $display("green incorrect. not 1 during back porch %d, is %x", $time/10, green);
            //else $display("green correct! %d", $time/10);
            wait_num_pixel(48);
            end  
            end

        begin
        repeat (480) begin //we are sending 480 lines per frame
        
            if(blank_n != 1) $display("green incorrect. not 1 during active video at %d, is %d", $time/10, green);
            //else $display("green correct!  %d", $time/10);
            wait_num_pixel(640);
            if(blank_n != 0) $display("green incorrect. not 1 during front porch at %d, is %x", $time/10, green);
            //else $display("green correct! %d", $time/10);
            wait_num_pixel(16);
            if(blank_n != 0) $display("green incorrect. not 0 during sync pulse %d, is %x", $time/10, green);
            //else $display("green correct! %d", $time/10);
            wait_num_pixel(96);
            if(blank_n != 0 ) $display("green incorrect. not 1 during back porch %d, is %x", $time/10, green);
            //else $display("green correct! %d", $time/10);
            wait_num_pixel(48);
            end  
            end

    join

//after the frame has been sent, check the recieved pixel data is what we expect it to be

 expected_val = 0;
    for(j=0; j < 640*480;j++) begin
        if(red_pixels_rec[j] != expected_val) $display("error on red index %d", i);
        if(blue_pixels_rec[j] != expected_val) $display("error on blue index %d", i);
        if(green_pixels_rec[j] != expected_val) begin
             $display("error on green index %d", i);
            while(1) #1;
        end
      
        expected_val++;

        
    end

    $display("Finished checking one frame one frame. Frame %d has completed", frame);
    end
end


//this always block acts as the FIFO, changing the pixel data every clock cycle
// it changes the pixel data on the negedge clk to avoid simulation timing issues that arise from changing it on the posedge
//to mimick FIFO data, we start the pixel data at 0 and incrememt it every clock cycle. This way we have an expected value for 
//what the timing_generator should output without having to use large memories. 
assign fifo_data = {red_blue_green_data_pointer, red_blue_green_data_pointer ,red_blue_green_data_pointer} ;
always @(negedge clk) begin
        
        if(active_video) 
        red_blue_green_data_pointer++;
        
end


//this always block acts as the video reciever, taking in the pixel data and storing it until we finish sending the whole frame.
initial begin
repeat (39) begin
//recives the pixels and stores them in *_pixels_recived
    i = 0;
    while(i < 480*640) begin
        @(posedge clk);
        if(active_video) begin
            {red_pixels_rec[i], green_pixels_rec[i], blue_pixels_rec[i]} = {red[7:0], green[7:0], blue[7:0]};
            i =     1 + i;
        end
    
    end
end

end

always #5 clk = ~clk;

endmodule


