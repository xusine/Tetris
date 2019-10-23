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

  ,input logic [3:0][3:0] next_block_i
  ,input logic [3:0][3:0] score_i

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

wire [$clog2(physical_width_p)-1:0] phy_x = phy_x_ori;
wire [$clog2(physical_height_p)-1:0] phy_y = phy_y_ori - 12;

wire phy_x_avail = phy_xy_v_ori & phy_y >= 0 & phy_y < 576;

assign logic_x = phy_x >> 3;
assign logic_y = phy_y >> 3;

logic [bit_depth_p-1:0] vga_r;
logic [bit_depth_p-1:0] vga_g;
logic [bit_depth_p-1:0] vga_b;

logic [8:0] str_score_memory_addr;
logic [31:0] str_score_memory_data;

memory_str_score #(
  .width_p(32)
  ,.depth_p(512)
)mem_score(
  .addr_i(str_score_memory_addr)
  ,.data_o(str_score_memory_data)
);

logic [9:0] str_number_memory_addr;
logic [31:0] str_number_memory_data;
memory_str_number #(
  .width_p(32)
  ,.depth_p(640)
) str_number (
  .addr_i(str_number_memory_addr)
  ,.data_o(str_number_memory_data)
);

logic [7:0] str_memory_next_addr;
logic [31:0] str_memory_next_data;

memory_str_next #(
  .width_p(32)
  ,.depth_p(256)
) str_next (
  .addr_i(str_memory_next_addr)
  ,.data_o(str_memory_next_data)
);

wire [5:0] str_score_y = phy_y - (str_score_pos_p.y_m << 3);
wire [$clog2(physical_width_p)-1:0] str_score_x = phy_x - (str_score_pos_p.x_m << 3);
wire [5:0] str_next_y = phy_y - (str_next_pos_p.y_m << 3);
wire [$clog2(physical_width_p)-1:0] str_next_x = phy_x - (str_next_pos_p.x_m << 3);
wire [5:0] str_num_y = phy_y - (score_pos_p.y_m << 3);
wire [$clog2(physical_width_p)-1:0] score_x = phy_x - (score_pos_p.x_m << 3);
wire [1:0] num_sel = (logic_x - score_pos_p.x_m) >> 2;
wire [1:0] next_block_x = (logic_x - next_block_pos_p.x_m) >> 2;
wire [1:0] next_block_y = (logic_y - next_block_pos_p.y_m) >> 2;
assign scene_x_o = (logic_x - board_pos_p.x_m) >> 1;
assign scene_y_o = {logic_y - board_pos_p.y_m} >> 1;
always_comb begin
  if(
    logic_x >= str_score_pos_p.x_m && logic_x < str_score_pos_p.x_m + str_score_pos_p.w_m &&
    logic_y >= str_score_pos_p.y_m && logic_y < str_score_pos_p.y_m + str_score_pos_p.h_m
  ) begin: STR_SCORE
    str_score_memory_addr = {str_score_x[7:5],str_score_y};
    vga_r = str_score_memory_data[~str_score_x[4:0]] ? '1 : 0;
    vga_g = '0;
    vga_b = '0;
    str_number_memory_addr = '0;
    str_memory_next_addr = '0;
  end
  else if(
    logic_x >= str_next_pos_p.x_m && logic_x < str_next_pos_p.x_m + str_next_pos_p.w_m &&
    logic_y >= str_next_pos_p.y_m && logic_y < str_next_pos_p.y_m + str_next_pos_p.h_m
  ) begin: STR_NEXT
    str_memory_next_addr = {str_next_x[6:5],str_next_y};
    vga_r = '0;
    vga_g = str_memory_next_data[~str_next_x[4:0]] ? '1 : 0;
    vga_b = '0;
    str_number_memory_addr = '0;
    str_score_memory_addr = '0;
  end
  else if(
    logic_x >= score_pos_p.x_m && logic_x < score_pos_p.x_m + score_pos_p.w_m &&
    logic_y >= score_pos_p.y_m && logic_y < score_pos_p.y_m + score_pos_p.h_m
  ) begin: SCORE
    str_number_memory_addr = {score_i[~num_sel],str_num_y};
    vga_r = '0;
    vga_g = '0;
    vga_b = str_number_memory_data[~score_x[4:0]] ? '1 : 0;
    str_score_memory_addr = '0;
  end
  else if(
    logic_x >= next_block_pos_p.x_m && logic_x < next_block_pos_p.x_m + next_block_pos_p.w_m &&
    logic_y >= next_block_pos_p.y_m && logic_y < next_block_pos_p.y_m + next_block_pos_p.h_m
  ) begin: NEXT_BLOCK
    str_number_memory_addr = '0;
    str_score_memory_addr = '0;
    str_memory_next_addr = '0;
    vga_r = '0;
    vga_g = next_block_i[next_block_x][next_block_y] ? '1 : 0;
    vga_b = next_block_i[next_block_x][next_block_y] ? '1 : 0;
  end
  else if(
    logic_x >= board_pos_p.x_m - 1 && logic_x <= board_pos_p.x_m + board_pos_p.w_m && (logic_y == board_pos_p.y_m - 1 || logic_y == board_pos_p.y_m + board_pos_p.h_m)
  ) begin: H_BOUNDARY
    str_number_memory_addr = '0;
    str_score_memory_addr = '0;
    str_memory_next_addr = '0;
    vga_r = '1;
    vga_g = '1;
    vga_b = '1;
  end
  else if(
    logic_y >= board_pos_p.y_m - 1 && logic_y <= board_pos_p.y_m + board_pos_p.h_m && (logic_x == board_pos_p.x_m - 1 || logic_x == board_pos_p.x_m + board_pos_p.w_m)
  ) begin: V_BOUNDARY
    str_number_memory_addr = '0;
    str_score_memory_addr = '0;
    str_memory_next_addr = '0;
    vga_r = '1;
    vga_g = '1;
    vga_b = '1;
  end
  else if(
    logic_x >= board_pos_p.x_m && logic_x < board_pos_p.x_m + board_pos_p.w_m &&
    logic_y >= board_pos_p.y_m && logic_y < board_pos_p.y_m + board_pos_p.h_m
  ) begin: BOARD_POS
    str_number_memory_addr = '0;
    str_score_memory_addr = '0;
    str_memory_next_addr = '0;
    vga_r = cm_i | mm_i ? '1 : '0;
    vga_g = cm_i ? '1: '0;
    vga_b = mm_i ? '1: '0;
  end
  else begin
    str_number_memory_addr = '0;
    str_score_memory_addr = '0;
    str_memory_next_addr = '0;
    vga_r = '0;
    vga_g = '0;
    vga_b = '0;
  end
end

vga_controller #(
  .bit_depth_p(bit_depth_p)
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

