

module timing_generator_tb(output dummy);

    reg  fifo_empty;
    reg [23:0]  fifo_data;
    reg clk, rst;
    reg  fifo_rreq;
    wire [7:0]  red, green, blue;
    wire  hsync, vsync, sync_n, blank_n;

task wait_num_pixel;
    input [31:0] pixels;
    
    repeat (pixels) begin
         @(posedge clk);
         #1;
    end
endtask

wire expected_sync_n;
assign expected_sync_n = hsync ^ vsync;
wire match_sync_n = (expected_sync_n) ^ sync_n ? 0 : 1;
reg active_video;

reg [23:0] screen [640][480];
int frame;
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
    clk = 0;
    rst = 1;
    fifo_empty = 1;
    active_video = 0;
    @(posedge clk);
    fifo_empty = 0;
    fifo_data = 24'h00000000;
    rst = 0;

    @(posedge clk);
        
    active_video = 1;
    $monitor("Error on sync_n! at time %d", match_sync_n, $time);
    #1;

    
   //active video
for (frame = 0; frame < 10; frame = frame + 1) begin
   fork

    begin
        repeat (480) begin
            if(hsync != 1) $display("hsync incorrect. not 1 during active video at %d", $time/10);
          //  else $display("hsync correct!  %d", $time/10);
            wait_num_pixel(640);
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
   repeat (480) begin
        active_video = 1;
        
        if(red != fifo_data[23:16]) $display("red incorrect. not data during active video at %d, is %x,  should be %x", $time/10, red, fifo_data[23:16]);
        //else $display("red correct!  %d", $time/10);
        wait_num_pixel(639);
        active_video = 0;
        wait_num_pixel(1);
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
      repeat (480) begin
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
      repeat (480) begin
      
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
      repeat (480) begin
      
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

    begin

    end


   join
$display("completed one frame %d", frame);
end
end

always @(negedge clk) begin
        if(active_video)
        fifo_data = fifo_data + 1;
end

int i,j;
int expected;
initial begin
    i = 0;
    j = 0;
    while(j < 480) begin
        @(posedge clk);
        #1;
        if(active_video) begin
            screen[i][j] = {red[7:0], green[7:0], blue[7:0]};
            i = 1 + i;
            if(i == 640) begin
                i = 0;
                j = 1 + j;
            end
        end
    
    end
    expected = 0;
    for(j = 0; j < 480; j = 1 + j) begin
        for(i = 0; i < 640; i = 1 + i) begin
            if(screen[i][j] != expected) begin 
                #1 
                $display("error on screen index %d %d. Should be %d, is %d", i, j, expected, screen[i][j]);
                while(1) #1;
            end
            expected = 1 + expected;

         end

    end
    
    $display("finished checking the first frame!");
    while(1) #1;
end

always #5 clk = ~clk;

endmodule


