module tb_matrix_memory;
  logic clk_li;
  logic reset_li;

  logic [3:0] read_addr_1_li;
  logic [15:0] read_data_1_lo;
  logic v_r1_li;

  logic [3:0] read_addr_2_li;
  logic [15:0] read_data_2_lo;
  logic v_r2_li;

  logic [4:0] read_block_addr_x_li;
  logic [4:0] read_block_addr_y_li;
  logic [3:0][3:0] read_block_data_lo;
  logic v_r3_li;


  logic [3:0] write_addr_li;
  logic [15:0] write_data_li;
  logic v_w_i;

  logic [4:0] write_block_addr_x_li;
  logic [4:0] write_block_addr_y_li;
  logic [3:0][3:0] write_block_data_li;
  logic v_block_i;

  logic is_ready;

  matrix_memory #(
    .word_width_p(16)
    ,.size_p(16)
  )(
    clk_li
    ,reset_li
    ,read_addr_1_li
    ,read_data_1_lo
    ,v_r1_li
    ,read_addr_2_li
    ,read_data_2_lo
    ,v_r2_li
    ,read_block_addr_x_li
    ,read_block_addr_y_li
    ,read_block_data_lo
    ,v_r3_li
    ,write_addr_li
    ,write_data_li
    ,v_w_i
    ,write_block_addr_x_li
    ,write_block_addr_y_li
    ,write_block_data_li
    ,v_block_i
    ,is_ready
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
  integer x = 0;
  always_ff @(posedge clk_li) begin
    if(reset_li) begin
      read_addr_1_li <= '0;
      read_addr_2_li <= 1'b1;
      v_r1_li <= 1'b1;
      v_r2_li <= 1'b1;
      write_addr_li <= '0;
      write_data_li <= '0;
      v_w_i <= 1'b0;
      read_block_addr_x_li <= '0;
      read_block_addr_y_li <= '0;
      v_r3_li <= 1'b0;
      write_block_addr_x_li <= '0;
      write_block_addr_y_li <= '0;
      write_block_data_li <= '0;
      v_block_i <= '0;
    end
    else if(is_ready) begin
      if(x == 0) begin
        $display("Set");
        write_block_addr_x_li <= -1;
        write_block_addr_y_li <= -1;
        write_block_data_li <= '1;
        v_block_i <= 1'b1;
        x <= 1;
      end
      else if(x == 1) begin
        x <= 2;
      end
      else if(x == 2) begin
        $finish;
      end
    end

  end
endmodule