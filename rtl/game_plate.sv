import tetris::*;
module game_plate #(
  parameter integer width_p = 16
  ,parameter integer height_p = 32
)(
  input clk_i
  ,input reset_i
  
  // FIFO interface
  ,input opcode_e opcode_i
  ,input opcode_empty_i
  ,output opcode_read_i

  // ports for display unit
  ,input [$clog2(width_p)-1:0] dis_logic_x_i
  ,input [$clog2(height_p)-1:0] dis_logic_y_i
  ,output dis_logic_mm_o // in matrix memory
  ,output dis_logic_cm_o // current state memory
  ,output [3:0][3:0] dis_logic_next_block

  // game information
  ,output line_elimination_o
  ,output lose_o
);

typedef enum bit [3:0] {eFetch, eDecode,eNew, eNewNext, eMove, eRotate, eCommit, eCheck, eLost} state_e;

state_e state_r, state_n; // state
opcode_e opcode_r;
direction_e move_direction;
always_comb unique case(opcode_r)
  eMoveLeft: move_direction = eLeft;
  eMoveRight: move_direction = eRight;
  eMoveDown: move_direction = eDown;
  default: move_direction = eNonDir;
endcase
// FSM
logic executor_is_done;
wire is_lost_n;

always_ff @(posedge clk_i) begin
  if(reset_i) begin
    state_r <= eFetch;
  end
  else unique case(state_r) 
    eFetch: begin
      if(!opcode_empty_i) state_r <= eDecode;
      else state_r <= eFetch;
    end
    eDecode: begin
      unique case(opcode_r) 
        eNew: state_r = eNew;
        eMoveLeft: state_r = eMove;
        eMoveRight: state_r = eMove;
        eMoveDown: state_r = eMove;
        eRotate: state_r = eRotate;
        eCommit: state_r = eCommit;
        eCheck: state_r = eCheck;
      endcase
    end
    eNew: begin
      if(executor_is_done) state_r <= eNewNext;
    end
    eLost: begin
      if(!is_lost_n) state_r <= eFetch;
    end
    default: begin
      if(executor_is_done) state_r <= eFetch;
    end
  endcase
end

logic new_is_done, move_is_done, rotate_is_ready, commit_is_done, check_is_done;
always_comb unique case(state_r)
  eNew: executor_is_done = new_is_done;
  eMove: executor_is_done = move_is_done;
  eRotate: executor_is_done = rotate_is_ready;
  eCommit: executor_is_done = commit_is_done;
  eCheck: executor_is_done = check_is_done;
  default: executor_is_done = '1;
endcase

logic [width_p-1:0] scanner_output_data_o;
assign dis_logic_mm_o = scanner_output_data_o[dis_logic_x_i];

wire [$clog2(height_p)-1:0] executor_check_read_addr;
wire [width_p-1:0] executor_check_read_data;

point_t block_memory_read_addr;
wire [3:0][3:0] block_memory_read_data;

wire [$clog2(height_p)-1:0] executor_check_write_addr;
wire [width_p-1:0] executor_check_write_data;
wire executor_check_write_v;

point_t block_memory_write_addr;
wire [3:0][3:0] block_memory_write_data;
wire executer_commit_write_v;

matrix_memory #(
  .width_p(width_p)
  ,.height_p(height_p)
) mm (
  .clk_i(clk_i)
  ,.reset_i(reset_i)
  // scanner read port
  ,.read_line_addr_1_i(dis_logic_y_i)
  ,.read_line_data_1_o(scanner_output_data_o)
  // executor check read port
  ,.read_line_addr_2_i(executor_check_read_addr)
  ,.read_line_data_2_o(executor_check_read_data)
  // current_tile_memory
  ,.read_block_addr_i(block_memory_read_addr)
  ,.read_block_data_o(block_memory_read_data)
  // First row
  ,.first_row_i()
  // executor check
  ,.write_addr_i(executor_check_write_addr)
  ,.write_data_i(executor_check_write_data)
  ,.v_w_i(executor_check_write_v)
  // executor commit
  ,.write_block_addr_i(block_memory_write_addr)
  ,.write_block_data_i(block_memory_write_data)
  ,.v_block_i(executer_commit_write_v)
  ,.is_ready_o(mm_ready)
);

wire cm_empty;

tile_type_e cm_set_tile_type, new_set_tile_type, rotate_set_tile_type;
assign cm_set_tile_type = state_r == eNew ? new_set_tile_type : rotate_set_tile_type;

wire [1:0] new_set_tile_angle;
wire [1:0] rotate_set_tile_angle;
wire [1:0] cm_set_tile_angle = state_r == eNew ? new_set_tile_angle : rotate_set_tile_angle;

wire new_set_v, rotate_set_v, cm_set_v;
assign cm_set_v = state_r == eNew ? new_set_v : rotate_set_v;

point_t cm_new_point, new_new_point, move_new_point;
assign cm_new_point = state_r == eNew ? new_new_point : move_new_point;

wire cm_set_point_v, move_set_point_v;
assign cm_set_point_v = state_r == eNew ? new_set_tile_angle : move_set_point_v;

point_t cm_pos;
shape_t cm_shape;
tile_type_e cm_type;
wire [1:0] cm_angle;

tile_type_e cm_n_type;
shape_t cm_n_shape;
assign dis_logic_next_block = cm_n_shape;
wire [1:0] cm_n_angle;

wire [3:0] cm_move_avail;
wire cm_tile_in_game_area;

current_tile_memory cm(
  .clk_i(clk_i)
  ,.reset_i(reset_i)

  ,.empty_i(cm_empty) // executer commit
  ,.fetch_next_i(state_r == eNewNext)
  // For new and rotate
  ,.tile_type_i(cm_set_tile_type)
  ,.tile_type_angle_i(cm_set_tile_angle)
  ,.tile_type_v_i(cm_set_v)
  // For move and new
  ,.new_pos_i(cm_new_point)
  ,.pos_v_i(cm_set_point_v)
  // Output Information
  ,.pos_o(cm_pos)
  ,.shape_o(cm_shape)
  ,.type_o(cm_type)
  ,.angle_o(cm_angle)
  // Next block information
  ,.next_type_o(cm_n_type)
  ,.next_angle_o(cm_n_angle)
  ,.next_shape_o(cm_n_shape)
  // Movement check
  ,.move_avail_o(cm_move_avail)
  ,.tile_in_game_area_o(cm_tile_in_game_area)
  // Handshake 
  ,.ready_o(cm_is_ready)
  // For matrix memory
  ,.mm_addr_o(block_memory_read_addr)
  ,.mm_data_i(block_memory_read_data)
);

executor_new #(
  .height_p(height_p)
  ,.width_p(width_p)
) exe_new (
  .clk_i(clk_i)
  ,.reset_i(reset_i)

  ,.tile_type_i(cm_n_type)
  ,.tile_type_angle_i(cm_n_angle)
  ,.v_i(state_r == eNew)
  ,.cm_is_ready_i(cm_is_ready)

  ,.tile_type_o(new_set_tile_type)
  ,.tile_type_angle_o(new_set_tile_angle)
  ,.pos_o(new_new_point)
  ,.v_o(new_set_v)

  ,.done_o(new_is_done)

);

executor_move #(
  .height_p(height_p)
  ,.width_p(width_p)
) exe_move (
  .clk_i(clk_i)
  ,.reset_i(reset_i)
  ,.v_i(state_r == eMove)
  ,.done_o(move_is_done)

  ,.direction_i(move_direction)

  ,.pos_i(cm_pos)
  ,.move_avail_i(cm_move_avail[2:0])
  ,.cm_is_ready_i(cm_is_ready)

  ,.new_pos_o(move_new_point)
  ,.new_pos_v_o(move_set_point_v)
);

executor_rotate #(
  .height_p(height_p)
  ,.width_p(width_p)
) exe_rotate (
  .clk_i(clk_i)
  ,.reset_i(reset_i)
  ,.v_i(state_r == eRotate)

  ,.done_o(rotate_is_ready)

  ,.rotate_avail_i(cm_move_avail[3])

  ,.type_i(cm_type)
  ,.angle_i(cm_angle)
  ,.pos_i(cm_pos)
  ,.cm_is_ready_i(cm_is_ready)

  ,.type_o(rotate_set_tile_type)
  ,.angle_o(rotate_set_tile_angle)
  ,.set_v_o(rotate_set_v)
);

executor_commit #(
  .height_p(height_p)
  ,.width_p(width_p)
) exe_commit (
  .clk_i(clk_i)
  ,.reset_i(reset_i)
  ,.v_i(state_r == eCommit)
  ,.done_o(commit_is_done)

  ,.pos_i(cm_pos)
  ,.shape_i(cm_shape)
  ,.empty_o(cm_empty)

  ,.mm_write_addr_o(block_memory_write_addr)
  ,.mm_write_data_o(block_memory_write_data)
  ,.mm_write_v_o(executer_commit_write_v)
  ,.mm_is_ready_i(mm_ready)
);

executor_check #(
  .height_p(height_p)
  ,.width_p(width_p)
) exe_check (
  .clk_i(clk_i)
  ,.reset_i(reset_i)
  ,.v_i(state_r == eCheck)
  ,.done_o(check_is_done)

  ,.mm_read_addr_o(executor_check_read_addr)
  ,.mm_read_data_i(executor_check_read_data)

  ,.mm_write_addr_o(executor_check_write_addr)
  ,.mm_write_data_o(executor_check_write_data)
  ,.mm_write_v_o(executor_check_write_v)
);


endmodule

