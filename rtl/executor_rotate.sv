import tetris::*;

module executor_rotate #(
  parameter integer width_p = 16
  ,parameter integer height_p = 32
)(
  input clk_i
  ,input reset_i
  ,input v_i

  ,output done_o

  ,input rotate_avail_i 
  // current state memory interface
  ,input tile_type_e type_i
  ,input [1:0] angle_i
  ,input point_t pos_i
  ,input cm_is_ready_i

  ,output tile_type_e type_o
  ,output [1:0] angle_o
  ,output set_v_o

);

typedef enum bit [1:0] {eIDLE, eWrite, eWaiting} state_e;
state_e state_r;
always_ff @(posedge clk_i) begin
  if(reset_i) state_r <= eIDLE;
  else unique case(state_r)
    eIDLE: begin
      if(v_i & rotate_avail_i) state_r <= eWrite;
      else state_r <= eIDLE;
    end
    eWrite: begin
      state_r <= eWaiting;
    end
    eWaiting: begin
      state_r <= cm_is_ready_i ? eIDLE : eWaiting;
    end
    default: begin

    end
  endcase
end

point_t base_pos_r;
reg [1:0] angle_r;
tile_type_e type_r;
always_ff @(posedge clk_i) begin
  if(reset_i) begin
    base_pos_r <= '0;
    angle_r <= '0;
    type_r <= eNon;
  end
  else if(state_r == eIDLE && v_i) begin
    base_pos_r <= pos_i;
    angle_r <= angle_i + 1;
    type_r <= type_i;
  end
end

assign type_o = type_r;
assign angle_o = angle_r;
assign set_v_o = state_r == eWrite;
assign done_o = state_r == eWaiting & cm_is_ready_i;

endmodule
