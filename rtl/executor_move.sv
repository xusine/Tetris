import tetris::*;

module executor_move #(
  parameter integer width_p = 16
  ,parameter integer height_p = 32
)(
  input clk_i
  ,input reset_i
  ,input v_i
  ,output ready_o

  // direction
  ,input direction_e direction_i

  // matrix memory read interface
  ,output [$clog2(width_p):0] mm_addr_r_x_o
  ,output [$clog2(height_p):0] mm_addr_r_y_o
  ,input [3:0][3:0] mm_data_i

  // current tile information
  ,input shape_t shape_i
  ,input point_t pos_i
  ,input [2:0] move_avail_i
  
  ,output point_t new_pos_o
  ,output new_pos_v_o

);

typedef enum [1:0] {eIDLE, eJudge, eWrite} state_e;
state_e state_r;
// whether it's valid to do this operation
wire operation_is_not_valid = &(shape_i & mm_data_i);
// FSM
always_ff @(posedge clk_i) begin
  if(reset_i)
    state_r <= eIDLE;
  else unique case(state_r)
    eIDLE: begin
      if(v_i) state_r <= eJudge;
    end
    eJudge: state_r <= operation_is_not_valid ? eIDLE : eWrite;
    eWrite: state_r <= eIDLE;
    default: begin

    end
  endcase
end
assign ready_o = state_r == eIDLE;
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
      eUp:begin 
        mm_base_addr_x_r <= pos_i.x_m;
        mm_base_addr_y_r <= pos_i.y_m - 1;
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

assign mm_addr_r_x_o = mm_base_addr_x_r;
assign mm_addr_r_y_o = mm_base_addr_y_r;
assign new_pos_o.x_m = mm_base_addr_x_r;
assign new_pos_o.y_m = mm_base_addr_y_r;
endmodule
