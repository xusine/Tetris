import tetris::*;
import layout_parameters::*;

module layout_map #(
  parameter integer logic_width_p = 100
  ,parameter integer logic_height_p = 72

  ,parameter integer physical_width_p = 800
  ,parameter integer physical_height_p = 600

  ,parameter integer bit_depth_p = 8
)(
  input clk_i // = 36MHz
  ,input reset_i
  // interaction with game logic core
  ,output [$clog2(scene_width_p)-1:0] scene_x_o
  ,output [$clog2(scene_height_p)-1:0] scene_y_o
  ,input cm_i
  ,input mm_i

  ,input [3:0][3:0] next_block_i
  ,input [7:0][3:0] score_i

  ,output [bit_depth_p-1:0] vga_r_o
  ,output [bit_depth_p-1:0] vga_g_o
  ,output [bit_depth_p-1:0] vga_b_o
  ,output vga_h_o
  ,output vga_v_o

);

logic [$clog2(logic_width_p)-1:0] logic_x;
logic [$clog2(logic_height_p)-1:0] logic_y;

wire [$clog2(physical_width_p)-1:0] phy_x_ori;
wire [$clog2(physical_height_p)-1:0] phy_y_ori;
wire phy_xy_v_ori;

wire [$clog2(physical_width_p)-1:0] phy_x;
wire [$clog2(physical_height_p)-1:0] phy_y = phy_y_ori - 12;

wire phy_x_avail = phy_xy_v_ori & phy_y >= 0 & phy_y < 576;

assign logic_x = phy_x >> 3;
assign logic_y = phy_y >> 3;

logic [bit_depth_p-1:0] vga_r;
logic [bit_depth_p-1:0] vga_g;
logic [bit_depth_p-1:0] vga_b;


always_comb begin
  
end

vga_controller #(
  ,.bit_depth_p(bit_depth_p)
) vga_driver (
  .clk_i(clk_i)
  ,.reset_i(reset_i)

  ,.r_i(vga_r)
  ,.g_i(vga_g)
  ,.b_i(vga_b)

  ,.x_o(phy_x_ori)
  ,.y_o(phy_y_ori)
  ,.xy_v_o(xy_v_o)

  ,.r_o(vga_r_o)
  ,.g_o(vga_g_o)
  ,.b_o(vga_b_o)
  ,.hs_o(vga_h_o)
  ,.vs_o(vga_v_o)
);




endmodule

