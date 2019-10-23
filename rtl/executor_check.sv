module executor_check #(
  parameter integer width_p = 16
  ,parameter integer height_p = 32
  ,parameter debug_p = 0
)(
  input clk_i
  ,input reset_i
  ,input v_i
  ,output done_o

  // matrix memory interface
  ,output [$clog2(height_p)-1:0] mm_read_addr_o
  ,input [width_p-1:0] mm_read_data_i
  ,output [$clog2(height_p)-1:0] mm_write_addr_o
  ,output [width_p-1:0] mm_write_data_o
  ,output mm_write_v_o

  ,output [2:0] combine_number_o

);

typedef enum bit [1:0] {eIDLE, eCheck, eMove} state_e;
// FSM
state_e state_r;
// Memory address
reg [$clog2(height_p)-1:0] index_addr_r;

always_ff @(posedge clk_i) begin
  if(reset_i) begin
    state_r <= eIDLE;
  end
  else if(state_r == eIDLE && v_i) begin
    state_r <= eCheck;
  end
  else if(state_r == eCheck) begin
    if(mm_read_data_i == '1) state_r <= eMove;
    else if(index_addr_r == 0) state_r <= eIDLE;
  end
  else if(state_r == eMove) begin
    if(index_addr_r == 0) state_r <= eCheck;
  end
end
reg [2:0] combine_number_r;
assign combine_number_o = combine_number_r;
always_ff @(posedge clk_i) begin
  if(reset_i) combine_number_r <= '0;
  else if(state_r == eIDLE && v_i) combine_number_r <= '0;
  else if(state_r == eCheck && mm_read_data_i == '1) combine_number_r <= combine_number_r + 1;
end

assign mm_read_addr_o = index_addr_r;
assign mm_write_addr_o = index_addr_r + 1;
always_ff @(posedge clk_i) begin
  if(reset_i) index_addr_r <= height_p - 1;
  else if(state_r == eIDLE) index_addr_r <= height_p - 1;
  else if(state_r == eMove && index_addr_r == 0) index_addr_r <= height_p - 1;
  else index_addr_r <= index_addr_r - 1;
end
assign mm_write_data_o = mm_read_data_i;
assign mm_write_v_o = state_r == eMove;
assign done_o = state_r == eCheck && index_addr_r == '0;

if(debug_p)
  always_ff @(posedge clk_i) begin
    $display("==========Executor Check============");
    $display("state:%s",state_r.name());
    $display("index_addr_r:%b",index_addr_r);
    $display("combine_number_r:%d",combine_number_r);
  end
endmodule
