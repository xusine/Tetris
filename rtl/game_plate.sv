import tetris::*;
module game_plate #(
  parameter integer width_p = scene_width_p
  ,parameter integer height_p = scene_height_p
  ,parameter debug_p = 1
)(
  input clk_i
  ,input reset_i
  
  // FIFO interface
  ,input opcode_e opcode_i
  ,input opcode_v_i
  ,output ready_o

  // ports for display unit
  ,input [$clog2(width_p)-1:0] dis_logic_x_i
  ,input [$clog2(height_p)-1:0] dis_logic_y_i
  ,output dis_logic_mm_o // in matrix memory
  ,output dis_logic_cm_o // current state memory
  ,output [3:0][3:0] dis_logic_next_block_o

  // game information
  ,output [2:0] line_elimination_o
  ,output line_elimination_v_o
  ,output lose_o
  ,output done_o // for Verilator simulation

  ,output block_cannot_move_down_o

  ,input yumi_i
);

typedef enum bit [3:0] {eFetch, eDecode,eOpNew, eOpNewNext, eOpMove, eOpRotate, eOpCommit, eOpCheck, eOpCheckLost ,eOpLost, eOpNop, eOpDone} state_e;

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
wire cm_is_empty;

logic lose_r;
assign lose_o = lose_r;
logic new_is_done, move_is_done, rotate_is_done, commit_is_done, check_is_done;
always_ff @(posedge clk_i) begin
  if(reset_i) begin
    state_r <= eFetch;
  end
  else unique case(state_r) 
    eFetch: begin
      if(lose_r) state_r <= eOpLost;
      else if(opcode_v_i) state_r <= eDecode;
      else state_r <= eFetch;
    end
    eDecode: begin
      unique case(opcode_r) 
        eNop: state_r <= eOpNop;
        eNew: state_r <= eOpNew;
        eMoveLeft: state_r <= cm_is_empty ? eOpNop : eOpMove;
        eMoveRight: state_r <= cm_is_empty ? eOpNop : eOpMove;
        eMoveDown: state_r <= cm_is_empty ? eOpNop : eOpMove;
        eRotate: state_r <= cm_is_empty ? eOpNop : eOpRotate;
        eCommit: state_r <= cm_is_empty ? eOpNop : eOpCommit;
        eCheck: state_r <= eOpCheck;
        default: begin

        end
      endcase
    end
    eOpNop: begin
      state_r <= eOpDone;
    end
    eOpNew: begin
      if(new_is_done) state_r <= eOpNewNext;
    end
    eOpMove: begin
      if(move_is_done) state_r <= move_direction == eDown ? eOpCheckLost : eOpDone;
    end
    eOpCheckLost: begin
      state_r <= eOpLost;
    end
    eOpLost: begin
      if(!lose_r) state_r <= eOpDone;
    end
    eOpDone: begin
      if(yumi_i) state_r <= eFetch;
      else state_r <= eOpDone;
    end
    default: begin
      if(executor_is_done) state_r <= eOpDone;
    end
  endcase
end

always_ff @(posedge clk_i) begin
  if(reset_i)
    opcode_r <= eNop;
  else if(state_r == eFetch)
    if(opcode_v_i)
      opcode_r <= opcode_i;
    else
      opcode_r <= eNop;
    
end

always_comb unique case(state_r)
  eOpMove: executor_is_done = move_direction == eDown ? 1'b0 : move_is_done;
  eOpRotate: executor_is_done = rotate_is_done;
  eOpCommit: executor_is_done = commit_is_done;
  eOpCheck: executor_is_done = check_is_done;
  eOpNewNext: executor_is_done = 1'b1;
  eOpLost: executor_is_done = 1'b1;
  eOpNop: executor_is_done = 1'b1;
  default: executor_is_done = '0;
endcase

assign done_o = state_r == eOpDone;
assign ready_o = state_r == eFetch;

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
wire mm_ready;

point_t block_memory_read_2_addr;
shape_t block_memory_read_2_data;


matrix_memory #(
  .width_p(width_p)
  ,.height_p(height_p)
  ,.debug_p(0)
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
  // executor commit
  ,.read_block_addr_2_i(block_memory_read_2_addr)
  ,.read_block_data_2_o(block_memory_read_2_data)
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
assign cm_set_tile_type = state_r == eOpNew ? new_set_tile_type : rotate_set_tile_type;

wire [1:0] new_set_tile_angle;
wire [1:0] rotate_set_tile_angle;
wire [1:0] cm_set_tile_angle = state_r == eOpNew ? new_set_tile_angle : rotate_set_tile_angle;

wire new_set_v, rotate_set_v, cm_set_v;
assign cm_set_v = state_r == eOpNew ? new_set_v : rotate_set_v;

point_t cm_new_point, new_new_point, move_new_point;
assign cm_new_point = state_r == eOpNew ? new_new_point : move_new_point;

wire cm_set_point_v, move_set_point_v;
assign cm_set_point_v = state_r == eOpNew ? new_set_v : move_set_point_v;

point_t cm_pos;
shape_t cm_shape;
tile_type_e cm_type;
wire [1:0] cm_angle;

tile_type_e cm_n_type;
shape_t cm_n_shape;
assign dis_logic_next_block_o = cm_n_shape;
wire [1:0] cm_n_angle;

wire [3:0] cm_move_avail;
wire cm_tile_in_game_area;
wire cm_is_ready;

assign block_memory_read_2_addr = cm_pos;

current_tile_memory #(
  .debug_p(1)
)cm(
  .clk_i(clk_i)
  ,.reset_i(reset_i)

  ,.empty_i(cm_empty) // executer commit
  ,.fetch_next_i(state_r == eOpNewNext)
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
  ,.is_empty_o(cm_is_empty)
  // Next block information
  ,.next_type_o(cm_n_type)
  ,.next_angle_o(cm_n_angle)
  ,.next_shape_o(cm_n_shape)
  // For Commit
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
  ,.v_i(state_r == eOpNew)
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
  ,.v_i(state_r == eOpMove)
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
  ,.v_i(state_r == eOpRotate)

  ,.done_o(rotate_is_done)

  ,.rotate_avail_i(cm_move_avail[3])

  ,.type_i(cm_type)
  ,.angle_i(cm_angle)
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
  ,.v_i(state_r == eOpCommit)
  ,.done_o(commit_is_done)

  ,.pos_i(cm_pos)
  ,.shape_i(cm_shape)
  ,.empty_o(cm_empty)

  ,.shape_on_board_i(block_memory_read_2_data)

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
  ,.v_i(state_r == eOpCheck)
  ,.done_o(check_is_done)

  ,.mm_read_addr_o(executor_check_read_addr)
  ,.mm_read_data_i(executor_check_read_data)

  ,.mm_write_addr_o(executor_check_write_addr)
  ,.mm_write_data_o(executor_check_write_data)
  ,.mm_write_v_o(executor_check_write_v)

  ,.combine_number_o(line_elimination_o)
);

assign line_elimination_v_o = executor_is_done && state_r == eOpCheck;

always_ff @(posedge clk_i) begin
  if(reset_i) lose_r <= '0;
  else if (state_r == eOpCheckLost)
    lose_r <= !cm_tile_in_game_area & ~cm_move_avail[2];
end
wire [$clog2(width_p):0] cm_addr_x = dis_logic_x_i - cm_pos.x_m;
wire [$clog2(height_p):0] cm_addr_y = dis_logic_y_i - cm_pos.y_m;
assign dis_logic_cm_o = (cm_addr_x < 4 && cm_addr_y < 4) ? cm_shape[cm_addr_y[1:0]][cm_addr_x[1:0]] : '0;
assign block_cannot_move_down_o = ~cm_move_avail[2];
if(debug_p)
  always_ff @(posedge clk_i) begin
    $display("==========Game Plate============");
    $display("current_state: %s",state_r.name());
    $display("current_opcode_i: %s",opcode_i.name());
  end
endmodule

