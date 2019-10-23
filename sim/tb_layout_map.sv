module tb_vga_controller;

wire [$clog2(800)-1:0] x_o;
wire [$clog2(600)-1:0] y_o;
wire xy_v_o;

wire r_i = xy_v_o ? '1 : 0;
wire g_i = xy_v_o ? '1 : 0;
wire b_i = xy_v_o ? '1 : 0;

logic clk_i;
logic reset_i;
logic r_o;
logic g_o;
logic b_o;
logic hs_o;
logic vs_o;

layout_map #(
  .bit_depth_p(1)
) vga_dtu(
  .clk_i(clk_i)
  ,.reset_i(reset_i)
 
  ,.cm_i(0)
  ,.mm_i(0)

  ,.next_block_i($random)
  ,.score_i({4'd4, 4'd2, 4'd2, 4'd3})


  ,.vga_r_o(r_o)
  ,.vga_g_o(g_o)
  ,.vga_b_o(b_o)
  ,.vga_h_o(hs_o)
  ,.vga_v_o(vs_o)
);
bsg_nonsynth_clock_gen #(
  .cycle_time_p(10)
)
clk
(
  .o(clk_i)
);
bsg_nonsynth_reset_gen #(
  .num_clocks_p(1)
  ,.reset_cycles_lo_p(1)
  ,.reset_cycles_hi_p(5)
)
reset
(
  .clk_i(clk_i)
  ,.async_reset_o(reset_i)
);
integer i = 0;

always @(posedge hs_o) begin
  $write("\n");
end
always @(posedge vs_o) begin
   if(i != 20) begin
     $write("===========================================\n");
    i = i + 1;
  end
  else $finish;
 
end
always_ff @(posedge clk_i) begin
  if(!reset_i) begin
    $write("%b",r_o);
  end
end

endmodule
