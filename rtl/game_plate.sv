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
  ,input [$clog2(width_p)-1:0] dis_logic_y_i
  ,output dis_logic_mm_o // in matrix memory
  ,output dis_logic_cm_o // current state memory
  ,output [3:0][3:0] dis_logic_next_block

  // game information
  ,output line_elimination_o
  ,output lose_o
);

typedef enum bit [2:0] {eFetch, eDecode,eNew, eMove, eRotate, eCommit, eCheck, eLost} state_e;

state_e state_r, state_n; // state
opcode_e opcode_r;
// FSM
wire executor_is_done;
wire is_lost_n;
always_comb unique case(state_n) 
  eFetch: begin
    if(opcode_empty_i) 
      state_n = eDecode;
    else begin
      state_n = eFetch;
    end
  end
  eDecode: begin
    unique case(opcode_r) 
      eNew: state_n = eNew;
      eMoveLeft: state_n = eMove;
      eMoveRight: state_n = eMove;
      eMoveDown: state_n = eMove;
      eRotate: state_n = eRotate;
      eCommit: state_n = eCommit;
      eCheck: state_n = eCheck;
    endcase
  end
  eLost: begin
    if(is_lost_n) state_n = eLost; else state_n = eFetch;
  end
  default: begin
    if(executor_is_done) state_n = eFetch; else state_n = state_r;
  end
endcase

matrix_memory #(
  .word_width_p(width_p)
  ,.size_p(height_p)
) mm (
  
);

current_tile_memory mem(

);

executor_new #(
  .height_p(height_p)
  ,.width_p(width_p)
) exe_new (

);

executor_move #(
  .height_p(height_p)
  ,.width_p(width_p)
) exe_move (

);

executor_rotate #(
  .height_p(height_p)
  ,.width_p(width_p)
) exe_rotate (

);

executor_commit #(
  .height_p(height_p)
  ,.width_p(width_p)
) exe_commit (

);

executor_check #(
  .height_p(height_p)
  ,.width_p(width_p)
) exe_check (

);


endmodule

