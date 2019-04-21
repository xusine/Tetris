import tetris::*;
module current_tile_memory(
  input clk_i
  ,input reset_i
  
  ,input tile_type_e tile_type_i
  ,input [1:0] tile_type_angle_i
  ,input tile_type_v_i

  ,input point_t new_pos_i
  ,input pos_v_i

  ,output point_t pos_o
  ,output point_t min_pos_o
  ,output point_t max_pos_o
  ,output shape_info_t shape_info_o

  ,output [4:0] tile_rom_read_addr_i
  ,input shape_info_t tile_rom_read_data_i

);


tile_type_e tile_type_r;
reg [1:0] tile_angle_r;
point_t pos_r;
always_ff @(posedge clk_i) begin
  if(reset_i) begin
    tile_type_r <= eNon;
    tile_angle_r <= '0;
    pos_r <= '0;
  end
  else if(tile_type_v_i) begin
    tile_type_r <= tile_type_i;
    tile_angle_r <= tile_type_angle_i;
  end
  else if(pos_v_i) begin
    pos_r <= new_pos_i;
  end
end

assign pos_o = pos_r;

shape_info_t shape_info_r;

always_ff @(posedge clk_i) begin
  if(reset_i)
    shape_info_r <= '0;
  else 
    shape_info_r <= tile_rom_read_data_i;
end

assign shape_info_o = shape_info_r;


assign max_pos_o.x_m = pos_o.x_m + shape_info_r.max_x_m;
assign max_pos_o.y_m = pos_o.y_m + shape_info_r.max_y_m;
assign min_pos_o.x_m = pos_o.x_m + shape_info_r.min_x_m;
assign min_pos_o.y_m = pos_o.y_m + shape_info_r,min_y_m;

assign tile_rom_read_addr_i = {tile_type_r,tile_angle_r};


endmodule