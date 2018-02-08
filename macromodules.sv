

module FF( clk,  rst,  d,  q,  en);
input clk, rst, en;
parameter bit_width = 8;
input [bit_width-1:0] d;
output reg [bit_width-1:0] q;

always @(posedge clk, posedge rst) begin
    if(rst) q <= 0;
    else if (en) q <= d;
end

endmodule