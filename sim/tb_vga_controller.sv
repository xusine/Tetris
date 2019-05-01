/*
This testbench is written for FPGA Boards.
If you want to use Verilator to verify this module, please refer to: https://github.com/ZipCPU/vgasim
*/
module tb_vga_controller(
  input clk_i // = 25MHz
  ,input reset_i

  ,output [7:0] r_o
  ,output [7:0] g_o
  ,output [7:0] b_o
  ,output hs_o
  ,output vs_o
);

wire [$clog2(640)-1:0] x_o;
wire [$clog2(480)-1:0] y_o;
wire xy_v_o;

wire [7:0] r_i = x_o < 160 && xy_v_o ? '1 : 0;
wire [7:0] g_i = x_o < 320 && xy_v_o ? '1 : 0;
wire [7:0] b_i = x_o < 640 && xy_v_o ? '1 : 0;

vga_controller vga_dtu(
  .clk_i(clk_i)
  ,.reset_i(~reset_i)
  ,.r_i(r_i)
  ,.g_i(g_i)
  ,.b_i(b_i)
  ,.x_o(x_o)
  ,.y_o(y_o)
  ,.xy_v_o(xy_v_o)

  ,.r_o(r_o)
  ,.g_o(g_o)
  ,.b_o(b_o)
  ,.hs_o(hs_o)
  ,.vs_o(vs_o)
);

endmodule
