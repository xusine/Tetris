module executor_new_tile #(
  parameter height_p = 32 //[3,22]
  ,parameter width_p = 16 //[0,9]
)(
  input clk_i
  ,input reset_i

  ,input [$clog2(width_p)-1:0] pos_x_i
  ,input [$clog2(height_p)-1:0] pos_y_i
  ,input [4:0] shape_type_i
  ,input v_i

  ,output [$clog2(height_p)-1:0] read_addr_o
  ,input [width_p-1:0] read_data_i
  ,output [$clog2(height_p)-1:0] write_addr_o
  ,output [width_p-1:0] write_data_o

);

typedef enum {eIDLE, eJudge, e} state_t;

endmodule