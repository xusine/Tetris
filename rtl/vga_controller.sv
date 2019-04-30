/*
A simple VGA Controller
*/

module vga_controller #(
  parameter integer width_p = 640
  ,parameter integer height_p = 480

  ,parameter integer v_sync_pulse_p = 2
  ,parameter integer v_sync_back_porch_p = 33
  ,parameter integer v_sync_front_porch_p = 10

  ,parameter integer h_sync_pulse_p = 96
  ,parameter integer h_sync_back_porch_p = 48
  ,parameter integer h_sync_front_porch_p = 16

  ,parameter integer bit_depth = 8
)(
  input clk_i // = 25MHz
  ,input reset_i

  ,input [bit_depth-1:0] r_i
  ,input [bit_depth-1:0] g_i
  ,input [bit_depth-1:0] b_i

  ,output [$clog2(width_p)-1:0] x_o
  ,output [$clog2(height_p)-1:0] y_o
  ,output xy_v_o

  ,output [bit_depth-1:0] r_o
  ,output [bit_depth-1:0] g_o
  ,output [bit_depth-1:0] b_o
  
  ,output hs_o
  ,output vs_o
);

reg [bit_depth-1:0] r_r;
reg [bit_depth-1:0] g_r;
reg [bit_depth-1:0] b_r;

always_ff @(posedge clk_i) begin
  if (reset_i) begin
    r_r <= '0;
    g_r <= '0;
    b_r <= '0;
  end
  else begin
    r_r <= r_i;
    g_r <= g_i;
    b_r <= b_i;
  end
end

assign r_o = r_r;
assign g_o = g_r;
assign b_o = b_r;

localparam row_size_lp = h_sync_pulse_p + h_sync_back_porch_p + width_p + h_sync_front_porch_p;
localparam col_size_lp = v_sync_pulse_p + v_sync_back_porch_p + height_p + v_sync_front_porch_p;

reg [$clog2(row_size_lp)-1:0] row_r;
reg [$clog2(col_size_lp)-1:0] col_r;

always_ff @(posedge clk_i) begin
  if(reset_i) begin
    row_r <= '0;
    col_r <= '0;
  end
  else begin
    if(row_r == row_size_lp - 1) begin
      row_r <= '0;
      col_r <= col_r == col_size_lp - 1 ? '0 : col_r + 1;
    end
    else begin
      row_r <= row_r + 1;
    end
  end
end

reg hs_r;
reg vs_r;

always_ff @(posedge clk_i) begin
  if(reset_i) begin
    hs_r <= '0;
    vs_r <= '0;
  end
  else begin
    if(row_r == row_size_lp - 1)
      hs_r <= 1'b1;
    else if(row_r == h_sync_pulse_p - 1)
      hs_r <= 1'b0;
    
    if(col_r == col_size_lp - 1 && row_r == row_size_lp - 1)
      vs_r <= 1'b1;
    else if(col_r == v_sync_pulse_p - 1 && row_r == row_size_lp - 1)
      vs_r <= 1'b0;
  end
end

assign hs_o = hs_r;
assign vs_o = vs_r;

assign x_o = row_r - h_sync_pulse_p - h_sync_back_porch_p + 1;
assign y_o = col_r - v_sync_pulse_p - v_sync_back_porch_p + 1;
wire x_v = row_r >= h_sync_pulse_p + h_sync_back_porch_p - 1 && row_r < h_sync_pulse_p + h_sync_back_porch_p + width_p - 1;
wire y_v = col_r >= v_sync_pulse_p + v_sync_back_porch_p - 1 && col_r < v_sync_pulse_p + v_sync_back_porch_p + height_p - 1;
assign xy_v_o = x_v & y_v;

always_ff @(posedge clk_i) begin
  if(vs_o) begin
  $display("row:%d",row_r);
  $display("col:%d",col_r);
  end
end
endmodule