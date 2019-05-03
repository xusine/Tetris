import tetris::*;
module current_tile_memory(
  input clk_i
  ,input reset_i

  // set empty
  ,input empty_i
  ,input fetch_next_i
  
  // set new tile
  ,input tile_type_e tile_type_i
  ,input [1:0] tile_type_angle_i
  ,input tile_type_v_i

  // set new point
  ,input point_t new_pos_i
  ,input pos_v_i

  // output information
  ,output point_t pos_o
  ,output shape_t shape_o
  ,output tile_type_e type_o
  ,output [1:0] angle_o

  // output information
  ,output tile_type_e next_type_o
  ,output [1:0] next_angle_o
  ,output shape_t next_shape_o

  // Movement Information
  ,output [2:0] move_avail_o
  ,output tile_in_game_area_o

  // ROM interface
  ,output logic [4:0] rom_read_addr_o
  ,input shape_info_t rom_read_data_i

  ,output ready_o

  // matrix memory interface
  ,output point_t mm_addr_o
  ,input [3:0][3:0] mm_data_i
);

typedef enum bit [2:0] {eIDLE, eJudgeLeft, eJudgeRight, eJudgeDown, eSetNext} state_e;
// FSM
state_e state_r;
always_ff @(posedge clk_i) begin
  if(reset_i | empty_i) begin
    state_r <= eIDLE;
  end
  else unique case(state_r) 
    eIDLE: begin
      if(pos_v_i | tile_type_v_i)
        state_r <=  eJudgeLeft;
      else if(fetch_next_i)
        state_r <= eSetNext;
      else
        state_r <= eIDLE;
    end
    eJudgeLeft: state_r <= eJudgeRight;
    eJudgeRight: state_r <= eJudgeDown;
    eJudgeDown: state_r <= eIDLE;
    eSetNext: state_r <= eIDLE;
  endcase
end
// Data path
tile_type_e tile_type_r;
reg [1:0] tile_angle_r;
point_t pos_r;
shape_t shape_r;
reg [1:0] tile_min_y_r;
reg tile_in_game_area_r;
always_ff @(posedge clk_i) begin
  if(reset_i | empty_i) begin
    tile_type_r <= eNon;
    tile_angle_r <= '0;
    pos_r <= '0;
    shape_r <= '0;
    tile_min_y_r <= '0;
    tile_in_game_area_r <= '0;
  end
  else begin 
    if(state_r == eIDLE & tile_type_v_i) begin
      tile_type_r <= tile_type_i;
      tile_angle_r <= tile_type_angle_i;
      shape_r <= rom_read_data_i.shape_m;
      tile_min_y_r <= rom_read_data_i.min_y_m;
    end
    if(state_r == eIDLE & pos_v_i) begin
      pos_r <= new_pos_i;
      tile_in_game_area_r <= (new_pos_i.y_m + tile_min_y_r >= 0);
    end
  end
end

assign pos_o = pos_r;
assign type_o = tile_type_r;
assign angle_o = tile_angle_r;
assign shape_o = shape_r;
assign tile_in_game_area_o = tile_in_game_area_r;


// Movement availability
wire operation_is_not_valid = &(mm_data_i & shape_r);
reg [2:0] move_valid_r;
always_ff @(posedge clk_i) begin
  if(reset_i | empty_i) begin
    move_valid_r <= '0;
  end
  else unique case(state_r)
    eJudgeLeft: begin
      move_valid_r[0] <= ~ operation_is_not_valid;
    end
    eJudgeRight: begin
      move_valid_r[1] <= ~ operation_is_not_valid;
    end
    eJudgeDown: begin
      move_valid_r[2] <= ~ operation_is_not_valid;
    end
    default: begin

    end
  endcase
end

assign move_avail_o = move_valid_r;

always_comb unique case(state_r)
  eIDLE: begin
    mm_addr_o = pos_r;
  end
  eJudgeLeft: begin
    mm_addr_o.x_m = pos_r.x_m - 1;
    mm_addr_o.y_m = pos_r.y_m;
  end
  eJudgeRight: begin
    mm_addr_o.x_m = pos_r.x_m + 1;
    mm_addr_o.y_m = pos_r.y_m;
  end
  eJudgeDown: begin
    mm_addr_o.x_m = pos_r.x_m;
    mm_addr_o.y_m = pos_r.y_m + 1;
  end
endcase

// random number generator
reg [4:0] random_addr_r;
wire [15:0] rg_out;
wire [4:0] random_addr_n = rg_out[14:10] ^ rg_out[9:5] ^ rg_out[4:0];

union_random_generator #(
  .width_p(16)
  ,.lfsr_num(4)
  ,.mask_p({294,7444, 18223, 51})
) rg (
  .clk_i(clk_i)
  ,.reset_i(reset_i)
  ,.random_o(rg_out)
);

// next tile information
shape_t next_shape_r;
always_ff @(posedge clk_i) begin
  if(reset_i) begin
    random_addr_r <= '0;
    next_shape_r <= '0;
  end
  else if (state_r == eIDLE & fetch_next_i) begin
    random_addr_r <= random_addr_n[4:2] == 0 ? {~random_addr_n[4:2], random_addr_n[1:0]} : random_addr_n;
  end
  else if(state_r == eSetNext) begin
    next_shape_r <= rom_read_data_i.shape_m;
  end
end

always_comb begin
  if(state_r == eIDLE)
    rom_read_addr_o = {tile_type_i,tile_type_angle_i};
  else if(state_r == eSetNext)
    rom_read_addr_o = random_addr_r;
end

assign next_type_o = random_addr_r[4:2];
assign next_tile_angle_o = random_addr_r[1:0];
assign next_shape_o = next_shape_r;


endmodule