
import tetris::*;


module matrix_controller #(
  parameter height_p = 24 //[3,22]
  ,parameter width_p = 10 //[0,9]
  ,parameter depth_p = 1
)
(
  input clk_i
  ,input reset_i

  ,input tile_opcode_e opcode_i
  ,input [7:0] opcode_op_i
  ,input op_v_i
  ,output ready_o

  ,output [height_p-7:0][width_p-7:0][depth_p-1:0] scope_o

  // memory interface with ROM
  ,output [4:0] rom_addr_o
  ,input shape_info_t rom_data_i

);

typedef enum {eIDLE, ePreOperation, eOperation, ePostOperation, eFail} state_e;

state_e current_state_r, current_state_n;

always_ff @(posedge clk_i) begin
  if(reset_i) begin
    current_state_r <= eIDLE;
  end 
  else
    current_state_r <= current_state_n;
end

always_comb unique case(current_state_r) 
  eIDLE: begin
    if(op_v_i)
      current_state_n = ePreOperation;
    else
      current_state_n = eIDLE;
  end
  ePreOperation: begin
    // check whether this operation is valid
    if(operation_is_valid)
      current_state_n = eOperation;
    else
      current_state_n = opcode_r == eNewTile ? eFail :eIDLE; // invalid instructions will not be execute
  end
  eOperation: begin
    if(operation_cycle_counter_r == '0)
      current_state_n = ePostOperation;
    else
      current_state_n = eOperation;
  end
  ePostOperation: begin
    if(operation_cycle_counter_r == '0)
      current_state_n = eIDLE;
    else
      current_state_n = ePostOperation;
  end
  eFail: begin
    current_state_n = eFail;
  end
  default: begin
    current_state_n = current_state_r == eFail ? eFail : eIDLE;
  end
endcase

logic [height_p-1:0][width_p-1:0][depth_p-1:0] matrix_r;

logic operation_is_valid;
always_comb begin
  if(current_state_r == ePreOperation) begin
    unique case(tetris) 
      eNOP: operation_is_valid = 1'b0;
      eNewTile: operation_is_valid = current_state_r != eFail;
      eRotate: begin
        if(current_tile_pos_max.x_m > )
      end
    endcase
  end
  else operation_is_valid = 1'b0;
end

reg [5:0] operation_cycle_counter_r;

logic [5:0] operation_cycle_counter_pre;
logic [5:0] operation_cycle_counter_exe;
logic [5:0] operation_cycle_counter_pos;

point_t current_tile_pos_r;

shape_info_t current_tile_r;
point_t current_tile_min;
assign current_tile_min.x_m = current_tile_pos_r.x_m + current_tile_r.min_x_m;
assign current_tile_min.y_m = current_tile_pos_r.y_m + current_tile_r.min_y_m;

point_t current_tile_max;
assign current_tile_max.x_m = current_tile_pos_r.x_m + current_tile_r.max_x_m;
assign current_tile_max.y_m = current_tile_pos_r.y_m + current_tile_r.max_y_m;


//dealing with rotate
shape_info_t rotate_tile_r;

point_t rotate_tile_min;
assign rotate_tile_min.x_m = current_tile_pos_r.x_m + rotate_tile_r.min_x_m;
assign rotate_tile_min.y_m = current_tile_pos_r.y_m + rotate_tile_r.min_y_m;
point_t rotate_tile_max;
assign rotate_tile_max.x_m = current_tile_pos_r.x_m + rotate_tile_r.max_x_m;
assign rotate_tile_max.y_m = current_tile_pos_r.y_m + rotate_tile_r.max_y_m;




tile_type_e current_tile_shape_type_r
reg [1:0] current_tile_angle_type_r; // for dealing with rotate.

tile_opcode_e opcode_r;
reg [5:0] opcode_counter_r;

assign ready_o = current_state_r = eIDLE;

endmodule