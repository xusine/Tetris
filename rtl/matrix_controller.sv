module matrix_controller(
  input clk_i
  ,input reset_i

  ,input tile_opcode_e opcode_i


  // memory interface with Matrix
  ,output [$clog2(height_p)-1:0] mat_addr_o
  ,output [width_p-1:0][depth_p-1:0] mat_data_o
  ,output mat_op_v_o

  ,input [height_p-1:0][width_p-1:0][depth_p-1:0] memory_i 

  // memory interface with ROM
  ,output [4:0] rom_addr_o
  ,input [3:0][3:0] rom_data_i


);

typedef enum {eIDLE, eStart, eOperation, eOperationEnd, eRemove, eEnd} state_e;

state_e current_state_r, current_state_n;

always_ff @(posedge clk_i) begin
  if(reset_i) begin
    current_state_r <= eIDLE;
  end 
  else
    current_state_r <= current_state_n;
end


reg [width_p-1:0] current_tile_pos_x_r;
reg [height_p-1:0] current_tile_pos_y_r;

reg [3:0][3:0] current_tile_r;
reg [2:0] current_tile_shape_type_r
reg [1:0] current_tile_angle_type_r; // for dealing with rotate.

tile_opcode_e opcode_r;
reg [5:0] opcode_counter;



endmodule