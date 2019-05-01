`timescale 1ps/1ps
module tb_union_random_generator;

  logic clk_li;
  logic reset_li;
  logic [3:0][7:0] seed_li;
  logic v_li;
  logic [7:0] random_lo;
  logic v_lo;

  union_random_generator #(
    .width_p(8)
    ,.lfsr_num(2)
    ,.mask_p({3,4})
  )ur(
    clk_li
    ,reset_li
    ,random_lo
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
      seed_li[0] = 33;
      seed_li[1] = 75;
      seed_li[2] = 17;
      seed_li[3] = 97;
      v_li = 1'b1;
      i = 0;
    end
    else begin
      $display("%d, %b",i,random_lo);
      i++;
      if(i == 10) $finish;
    end
  end
endmodule