`timescale 1ps/1ps
module tb_random_generator;

  logic clk_li;
  logic reset_li;
  logic [3:0] seed_li;
  logic v_li;
  logic [3:0] random_lo;
  logic v_lo;

  random_generator #(
    .width_p(4)
    ,.mask_p(4'b0100)
  )(
    clk_li
    ,reset_li
    ,seed_li
    ,v_li
    ,random_lo
    ,v_lo
  );

  bsg_nonsynth_clock_gen #(
    .cycle_time_p(10)
  )
  clk
  (
    .o(clk_li)
  );
  bsg_nonsynth_reset_gen #(
    .num_clocks_p(1)
    ,.reset_cycles_lo_p(1)
    ,.reset_cycles_hi_p(5)
  )
  reset
  (
    .clk_i(clk_li)
    ,.async_reset_o(reset_li)
  );

  integer i;

  always_ff @(posedge clk_li) begin
    if(reset_li) begin
      seed_li = 4'b0110;
      v_li = 1'b1;
      i = 0;
    end
    else if(v_lo) begin
      $display("%d, %b",i,random_lo);
      i++;
      if(i == 10) $finish;
    end
  end
endmodule