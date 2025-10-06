module blinky(input clk, output led);
  reg [24:0] cnt = 0;
  always @(posedge clk) cnt <= cnt + 1;
  assign led = cnt[24];
endmodule
