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
  ,input reset_i

  ,input left_i
  ,input right_i
  ,input rotate_i
  ,input start_i

  ,output [4:0] vga_r_o
  ,output [5:0] vga_g_o
  ,output [4:0] vga_b_o

  ,output vga_h_o
  ,output vga_v_o
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

wire reset_top;
wire clk_64hz;

wire [4:0] av_keys /* synthesis syn_noclockbuf=1 */;

anti_vibrator #(
  .width_p(5)
)ant_vir(
  .clk_i(clk_64hz)
  ,.keys_i({reset_i, left_i, right_i, rotate_i, start_i})
  ,.keys_o(av_keys)
);

reg [4:0] av_keys_r /* synthesis syn_noclockbuf=1 */;
always_ff @(posedge clk_i) begin
  av_keys_r <= av_keys;
end

wire [4:0] actual_keys = ~av_keys_r & av_keys;
assign reset_top = actual_keys[4];

wire [$clog2(vga_width_p)-1:0] vga_x;
wire [$clog2(vga_height_p)-1:0] vga_y;
wire vga_xy_v;

wire [$clog2(logic_width_p)-1:0] logic_x = vga_x >> 4;
wire [$clog2(logic_height_p)-1:0] logic_y = vga_y >> 4;
wire logic_mm_data;
wire logic_cm_data;

logic [bit_depth_p-1:0] vga_r = {bit_depth_p{logic_mm_data}};
logic [bit_depth_p-1:0] vga_g = {bit_depth_p{logic_cm_data}};
logic [bit_depth_p-1:0] vga_b = '0;

game_top_logic #(
  .width_p(logic_width_p)
  ,.height_p(logic_height_p)
)top_logic(
  .clk_i(frequency_divider_r[2])
  ,.reset_i(reset_top)

  ,.left_i(actual_keys[3])
  ,.right_i(actual_keys[2])
  ,.rotate_i(actual_keys[1])
  ,.start_i(actual_keys[0])

  ,.dis_logic_x_i(logic_x)
  ,.dis_logic_y_i(logic_y)
  ,.dis_logic_mm_o(logic_mm_data)
  ,.dis_logic_cm_o(logic_cm_data)
  ,.dis_logic_next_block_o()

  ,.lose_o()
  ,.score_o()

  ,.clk_64hz_o(clk_64hz)
);

wire [bit_depth_p-1:0] vga_r_fo;
assign vga_r_o = vga_r_fo[7:3];
wire [bit_depth_p-1:0] vga_g_fo;
assign vga_g_o = vga_g_fo[7:2];
wire [bit_depth_p-1:0] vga_b_fo;
assign vga_b_o = vga_b_fo[7:3];

vga_controller #(
  .bit_depth_p(bit_depth_p)
) vga_driver (
  .clk_i(clk_vga)
  ,.reset_i(reset_top)

  ,.r_i(vga_r)
  ,.g_i(vga_g)
  ,.b_i(vga_b)

  ,.x_o(vga_x)
  ,.y_o(vga_y)
  ,.xy_v_o(vga_xy_v)

  ,.r_o(vga_r_fo)
  ,.g_o(vga_g_fo)
  ,.b_o(vga_b_fo)

  ,.hs_o(vga_h_o)
  ,.vs_o(vga_v_o)
);

endmodule
