import tetris::*;

module executor_commit #(
  parameter integer width_p = 16
  ,parameter integer height_p = 32
  ,parameter debug_p = 1
)(
  input clk_i
  ,input reset_i
  ,input v_i
  ,output done_o

  // current state memory interface
  ,input point_t pos_i
  ,input shape_t shape_i
  ,output empty_o
  ,input shape_t shape_on_board_i

  // matrix memory interface
  ,output point_t mm_write_addr_o
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
    eIDLE: state_r <= v_i ? eWrite : eIDLE;
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
    shape_r <= shape_i | shape_on_board_i;
  end
end

assign mm_write_addr_o = pos_r;
assign mm_write_data_o = shape_r;
assign mm_write_v_o = state_r == eWrite;
assign empty_o = state_r == eEmpty;
assign done_o = state_r == eEmpty;

if(debug_p)
  always_ff @(posedge clk_i) begin
    $display("=========Executor Commit==============");
    $display("From commit: %s",state_r.name());
    $display("From commit: shape_r:");
    for(integer i = 0; i < 4; ++i) begin
      for(integer j = 0; j < 4; ++j)
        $write("%b",shape_r[i][j]);
      $display("");
    end
    $display("From commit: shape_on_board_i:");
    for(integer i = 0; i < 4; ++i) begin
      for(integer j = 0; j < 4; ++j)
        $write("%b",shape_on_board_i[i][j]);
      $display("");
    end

  end

endmodule

