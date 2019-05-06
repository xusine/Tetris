module game_top_logic #(
  parameter integer width_p = scene_width_p
  ,parameter integer height_p = scene_height_p
  ,parameter debug_p = 1
)(
  input clk_i // = 1MHz
  ,input reset_i

  ,input left_i
  ,input right_i
  ,input rotate_i

  ,input start_i // start signal

  // interaction with vga scanner
  ,input [$clog2(width_p)-1:0] dis_logic_x_i
  ,input [$clog2(height_p)-1:0] dis_logic_y_i
  ,output dis_logic_mm_o // in matrix memory
  ,output dis_logic_cm_o // current state memory
  ,output [3:0][3:0] dis_logic_next_block_o

  // game status
  ,output lose_o
  ,output [7:0][3:0] score_o

  // clock signal
  ,output clk_1hz_o
  ,output clk_4hz_o
  ,output clk_64hz_o
  ,output clk_128hz_o

);

typedef enum logic[3:0] {eStart, eIdle, eUserInteract,eSystemNew,  eSystemDown, eSystemCommit, eSystemCheck, eAddScore, eLost} state_e;
typedef enum logic[1:0] {eUserNop, eUserLeft, eUserRight, eUserRotate} user_op_e;

reg [19:0] frequency_divider_r;
always_ff @(posedge clk_i) begin
  if(reset_i) frequency_divider_r <= '0;
  else frequency_divider_r <= frequency_divider_r + 1;
end
wire clk_4hz = frequency_divider_r[17:0] == '1;
reg clk_4hz_r;
always_ff @(posedge clk_i) begin
  if(reset_i) clk_4hz_r <= '0;
  else clk_4hz_r <= clk_4hz;
end
wire pos_4hz = clk_4hz & ~clk_4hz_r;
wire clk_1hz = frequency_divider_r == '1;
reg clk_1hz_r;
always_ff @(posedge clk_i) begin
  if(reset_i) clk_1hz_r <= '0;
  else clk_1hz_r <= clk_4hz;
end
wire pos_1hz = clk_1hz & ~clk_1hz_r;

assign clk_1hz_o = frequency_divider_r[19];
assign clk_4hz_o = frequency_divider_r[17];
assign clk_128hz_o = frequency_divider_r[12];
assign clk_64hz_o = frequency_divider_r[13];

wire op_is_done;
wire add_score_done;
state_e state_r, state_n;
user_op_e user_op_r;

always_ff @(posedge clk_i) begin
  if(reset_i) user_op_r <= eUserNop;
  else if(pos_4hz) begin
    if(left_i) user_op_r <= eUserLeft;
    else if(right_i) user_op_r <= eUserRight;
    else if(rotate_i) user_op_r <= eUserRotate;
  end
end

always_comb unique case(state_r)
  eStart: if(start_i) state_n = eSystemNew; else state_n = eStart;
  eIdle: begin
    if(pos_1hz) state_n = eSystemDown;
    else if((left_i | right_i | rotate_i) & pos_4hz) state_n = eUserInteract;
    else state_n = eIdle;
  end
  eSystemNew: begin
    if(pos_1hz) state_n = eIdle;
    else state_n = eSystemNew;
  end
  eUserInteract: begin
    if(op_is_done & pos_4hz) state_n = eIdle;
    else state_n = eUserInteract;
  end
  eSystemDown: begin
    if (lose_o & pos_4hz) state_n = eLost;
    else if(op_is_done) state_n = eSystemCommit;
    else state_n = eSystemDown;
  end
  eSystemCommit: begin
    if(op_is_done & pos_4hz) state_n = eSystemCheck;
    else state_n = eSystemCommit;
  end
  eSystemCheck: begin
    if(op_is_done & pos_4hz) state_n = eAddScore;
    else state_n = eSystemCheck;
  end
  eAddScore: begin
    if(add_score_done) state_n = eIdle;
    else state_n = eAddScore;
  end
  eLost: begin
    state_n = eLost;
  end
  default: begin
    state_n = state_r;
  end
endcase

always_ff @(posedge clk_i) begin
  if(reset_i)
    state_r <= eStart;
  else
    state_r <= state_n;
end

opcode_e opcode_to_append;

always_comb unique case(state_r)
  eSystemDown: opcode_to_append = eMoveDown;
  eSystemCommit: opcode_to_append = eCommit;
  eSystemCheck: opcode_to_append = eCheck;
  eSystemNew: opcode_to_append = eNew;
  eUserInteract: unique case(user_op_r)
    eUserLeft: opcode_to_append = eMoveLeft;
    eUserRight: opcode_to_append = eMoveRight;
    eUserRotate: opcode_to_append = eRotate;
    default: opcode_to_append = eNop;
  endcase
  default: opcode_to_append = eNop;
endcase

wire plate_yumi = state_n != state_r;
wire [2:0] line_eliminate_n;
game_plate #(
  .width_p(width_p)
  ,.height_p(height_p)
  ,.debug_p(debug_p)
) plate (
  .clk_i(clk_i)
  ,.reset_i(reset_i)

  ,.opcode_i(opcode_to_append)
  ,.opcode_v_i(opcode_to_append != eNop)
  ,.ready_o()

  ,.dis_logic_x_i(dis_logic_x_i)
  ,.dis_logic_y_i(dis_logic_y_i)
  ,.dis_logic_mm_o(dis_logic_mm_o)
  ,.dis_logic_cm_o(dis_logic_cm_o)
  ,.dis_logic_next_block_o(dis_logic_next_block_o)

  ,.line_elimination_o(line_eliminate_n)
  ,.line_elimination_v_o()
  ,.lose_o(lose_o)
  ,.done_o(op_is_done)

  ,.yumi_i(plate_yumi)
);

logic [7:0][3:0] score_r;
reg [1:0] score_update_cnt_r;

always_ff @(posedge clk_i) begin
  if(reset_i) begin
    score_r <= '0;
    score_update_cnt_r <= '0;
  end
  else if(state_r == eStart) begin
    score_r <= '0;
    score_update_cnt_r <= '0;
  end
  else if(state_r == eAddScore) begin
    unique case(score_update_cnt_r)
      2'b00: score_r[0] <= score_r[0] + line_eliminate_n;
      2'b01: begin
        score_r[1] <= score_r[1] + 4'(score_r[0] >= 10);
        score_r[0] <= score_r[0] >= 10 ? score_r[0] - 10 : score_r[0];
      end
      2'b10: begin
        score_r[2] <= score_r[2] + 4'(score_r[1] >= 10);
        score_r[1] <= score_r[1] >= 10 ? score_r[1] - 10 : score_r[1];
      end
      2'b11: begin
        score_r[3] <= score_r[3] + 4'(score_r[2] >= 10);
        score_r[2] <= score_r[2] >= 10 ? score_r[2] - 10 : score_r[2];
      end
    endcase
    score_update_cnt_r <= score_update_cnt_r + 1;
  end
end
assign add_score_done = score_update_cnt_r == '1;
assign score_o = score_r;

endmodule
