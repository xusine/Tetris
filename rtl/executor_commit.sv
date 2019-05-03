import tetris::*;

module executor_commit #(
  parameter integer width_p = 16
  ,parameter integer height_p = 32
)(
  input clk_i
  ,input reset_i
  ,input v_i
  ,output ready_o

  // current state memory interface
  ,input point_t pos_i
  ,input shape_t shape_i
  ,output empty_o

  // matrix memory interface
  ,output [$clog2(width_p)-1:0] mm_write_addr_x_o
  ,output [$clog2(height_p)-1:0] mm_write_addr_y_o 
  ,output [3:0][3:0] mm_write_data_o
  ,output mm_write_v_o
  ,input mm_is_ready_i
);

typedef enum bit [1:0] {eIDLE, eWrite, eWaiting, eEmpty} state_e;
state_e state_r;
always_ff @(posedge clk_i) begin
  if(reset_i) begin
    state_r <= eIDLE;
  end
  else unique case(state_r) 
    eIDLE: state_r <= eIDLE ? eWrite : eIDLE;
    eWrite: state_r <= eWaiting;
    eWaiting: state_r <= mm_is_ready_i ? eEmpty : eWaiting;
    eEmpty: state_r <= eIDLE;
  endcase
end

point_t pos_r;
reg [3:0][3:0] shape_r;
always_ff @(posedge clk_i) begin
  if(reset_i) begin
    pos_r <= '0;
    shape_r <= '0;
  end
  else if(state_r == eIDLE & v_i) begin
    pos_r <= pos_i;
    shape_r <= shape_i;
  end
end

assign mm_write_addr_x_o = pos_r.x_m;
assign mm_write_addr_y_o = pos_r.y_m;
assign mm_write_data_o = shape_r;
assign mm_write_v_o = state_r == eWrite;
assign empty_o = state_r == eEmpty;
assign ready_o = state_r == eIDLE;

endmodule

