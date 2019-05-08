// -------------------------------------------------------
// -- top.sv for Zybo
// -------------------------------------------------------
import tetris::*;
module top #(
  parameter integer bit_depth_p = 8
  ,parameter integer vga_width_p = 800
  ,parameter integer vga_height_p = 600
  
  ,parameter integer logic_width_p = scene_width_p
  ,parameter integer logic_height_p = scene_height_p
)(
  input clk_i //=50MHz

  ,input left_i
  ,input right_i
  ,input rotate_i
  ,input start_i

  ,output [4:0] vga_r_o
  ,output [5:0] vga_g_o
  ,output [4:0] vga_b_o

  ,output vga_h_o
  ,output vga_v_o

  ,output [3:0] state_o // for debugging.
);

wire clk_vga;
wire clk_8Mhz;
wire clkfbout_clock_gen;
clk_gen clk_src (
  .clk_in1(clk_i)
  ,.clk_out1(clk_vga)
  ,.clk_out2(clk_8Mhz)
);

reg [2:0] frequency_divider_r;
always_ff @(posedge clk_8Mhz)
  frequency_divider_r <= frequency_divider_r + 1;

wire [$clog2(vga_width_p)-1:0] vga_x;
wire [$clog2(vga_height_p)-1:0] vga_y;
wire vga_xy_v;

wire [$clog2(logic_width_p)-1:0] logic_x;
wire [$clog2(logic_height_p)-1:0] logic_y;
wire logic_mm_data;
wire logic_cm_data;

wire [3:0][3:0] next_block;
wire [3:0][3:0] score;

game_top_logic #(
  .width_p(logic_width_p)
  ,.height_p(logic_height_p)
)top_logic(
  .clk_i(frequency_divider_r[2])
  ,.reset_i(!start_i)

  ,.left_i(left_i)
  ,.right_i(right_i)
  ,.rotate_i(rotate_i)
  ,.start_i(start_i)

  ,.dis_logic_x_i(logic_x)
  ,.dis_logic_y_i(logic_y)
  ,.dis_logic_mm_o(logic_mm_data)
  ,.dis_logic_cm_o(logic_cm_data)
  ,.dis_logic_next_block_o(next_block)

  ,.lose_o()
  ,.score_o(score)
  ,.state_o(state_o)
);

wire [bit_depth_p-1:0] vga_r_fo;
assign vga_r_o = vga_r_fo[7:3];
wire [bit_depth_p-1:0] vga_g_fo;
assign vga_g_o = vga_g_fo[7:2];
wire [bit_depth_p-1:0] vga_b_fo;
assign vga_b_o = vga_b_fo[7:3];

layout_map map(
  .clk_i(clk_vga)
  ,.reset_i(!start_i)

  ,.scene_x_o(logic_x)
  ,.scene_y_o(logic_y)

  ,.cm_i(logic_cm_data)
  ,.mm_i(logic_mm_data)

  ,.next_block_i(next_block)
  ,.score_i(score)

  ,.vga_r_o(vga_r_fo)
  ,.vga_g_o(vga_g_fo)
  ,.vga_b_o(vga_b_fo)

  ,.vga_h_o(vga_h_o)
  ,.vga_v_o(vga_v_o)
);

endmodule
