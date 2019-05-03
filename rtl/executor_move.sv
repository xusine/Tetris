import tetris::*;

module executor_move #(
  parameter integer width_p = 16
  ,parameter integer height_p = 32
)(
  input clk_i
  ,input reset_i
  ,input v_i
  ,output done_o

  // direction
  ,input direction_e direction_i

  // current tile information
  ,input point_t pos_i
  ,input [2:0] move_avail_i
  ,input cm_is_ready_i
  
  ,output point_t new_pos_o
  ,output new_pos_v_o

);

typedef enum bit [1:0] {eIDLE, eWrite, eWaiting} state_e;
state_e state_r;
// whether it's valid to do this operation
logic operation_is_valid;
always_comb unique case(direction_i)
  eNonDir: operation_is_valid = '0;
  eDown: operation_is_valid = move_avail_i[2];
  eLeft: operation_is_valid = move_avail_i[0];
  eRight: operation_is_valid = move_avail_i[1];
  default: operation_is_valid = '0;
endcase
// FSM
always_ff @(posedge clk_i) begin
  if(reset_i)
    state_r <= eIDLE;
  else unique case(state_r)
    eIDLE: begin
      if(v_i & operation_is_valid) state_r <= eWrite;
    end
    eWrite: state_r <= eWaiting;
    eWaiting: state_r <= cm_is_ready_i ? eIDLE : eWaiting;
    default: begin

    end
  endcase
end
assign done_o = state_r == eWaiting & cm_is_ready_i;
assign new_pos_v_o = state_r == eWrite;
// new position register
reg [$clog2(width_p):0] mm_base_addr_x_r;
reg [$clog2(height_p):0] mm_base_addr_y_r;
// latch input
always_ff @(posedge clk_i) begin
  if(reset_i) begin
    mm_base_addr_x_r <= '0;
    mm_base_addr_y_r <= '0;
  end
  else if(state_r == eIDLE && v_i) begin
    unique case(direction_i)
      eNonDir:begin 
        
      end
      eDown: if(move_avail_i[2]) begin
        mm_base_addr_x_r <= pos_i.x_m;
        mm_base_addr_y_r <= pos_i.y_m + 1;
      end 
      eLeft: if(move_avail_i[0]) begin
        mm_base_addr_x_r <= pos_i.x_m - 1;
        mm_base_addr_y_r <= pos_i.y_m;
      end
      eRight: if(move_avail_i[1])begin
        mm_base_addr_x_r <= pos_i.x_m + 1;
        mm_base_addr_y_r <= pos_i.y_m;
      end
    endcase
  end
end
assign new_pos_o.x_m = mm_base_addr_x_r;
assign new_pos_o.y_m = mm_base_addr_y_r;
endmodule
