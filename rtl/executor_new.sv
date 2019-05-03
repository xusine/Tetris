import tetris::*;

module executor_new #(
  parameter integer height_p = 32 //[3,22]
  ,parameter integer width_p = 16 //[0,9]
)(
  input clk_i
  ,input reset_i

  ,input tile_type_e tile_type_i
  ,input [1:0] tile_type_angle_i
  ,input v_i
  ,input cm_is_ready_i

  // current tile interface
  ,output tile_type_e tile_type_o
  ,output [1:0] tile_type_angle_o
  ,output point_t pos_o
  ,output v_o

  ,output done_o

);

typedef enum {eIDLE, eFetch, eUpdate, eWaiting} state_t;
// Update FSM
state_t state_r;
always_ff @(posedge clk_i) begin
  if(reset_i)
    state_r <= eIDLE;
  else begin
    unique case(state_r) 
      eIDLE: begin
        if(v_i)
          state_r <= eFetch;
      end
      eFetch: begin
        state_r <= eUpdate;
      end
      eUpdate: begin
        state_r <= eWaiting;
      end
      eWaiting: begin
        state_r <= cm_is_ready_i ? eIDLE : eWaiting;
      end
    endcase
  end
end

tile_type_e type_r;
reg [1:0] angle_r;
// update angle_r and type_r
always_ff @(posedge clk_i) begin
  if(reset_i) begin
    type_r <= eNon;
    angle_r <= '0;
  end
  else if(state_r == eIDLE && v_i) begin
    type_r <= tile_type_i;
    angle_r <= tile_type_angle_i;
  end
end
// update point
shape_info_t tile_rom_read_data;
point_t point_r;
always_ff @(posedge clk_i) begin
  if(reset_i) begin
    point_r <= '0;
  end
  else if(state_r == eFetch) begin
    point_r.x_m <= width_p/2 - 2;
    point_r.y_m <= ~tile_rom_read_data.max_y_m; // -(y+1) = -y - 1 = ~y
  end
end
// ROM
memory_pattern #(
  .width_p(24)
  ,.depth_p(32)
) rom (
  .addr_i({type_r, angle_r})
  ,.data_o(tile_rom_read_data)
);


// output ports
assign done_o = state_r == eWaiting & cm_is_ready_i;

assign pos_o = point_r;
assign tile_type_o = type_r;
assign tile_type_angle_o = angle_r;
assign v_o = state_r == eUpdate;

endmodule

