/*
matrix.v
A matirx used to record the 
*/
import tetris::matrix_opcode_e;

module matrix #(
  ,parameter width_p = 10
  ,parameter height_p = 20
  ,parameter depth_p = 2
)(
  input clk_i
  ,input reset_i

  ,input [$clog2(height_p)-1:0] set_row_addr_i
  ,input [width_p-1:0][depth_p-1:0] set_row_data_i
  ,input set_v_i

  ,output [height_p-1:0][width_p-1:0][depth_p-1:0] matrix_o

);

logic [height_p-1:0][width_p-1:0][depth_p-1:0] matrix_r;

assign matrix_o = matrix_r;

// latch the operand

always_ff @(posedge clk_i) begin
  if(reset_i) begin
    matrix_r <= '0;
  end
  else if(set_v_i) begin
    matrix_r[set_row_addr_i] <= set_row_data_i;
  end
end



endmodule