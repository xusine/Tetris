module layout_remapper #(
  parameter integer logic_width_p = 100
  ,parameter integer logic_height_p = 72    
  ,parameter integer physical_width_p = 800
  ,parameter integer physical_height_p = 600
  ,parameter integer bit_depth_p = 1
)(

  input clk_i //=36MHz
  ,input reset_i

  ,output [$clog2(logic_width_p)-1:0] x_o
  ,output [$clog2(logic_height_p)-1:0] y_o

  ,input str_score_v_i
  ,input str_next_v_i

  ,input [bit_depth_p-1:0] r_i
  ,input [bit_depth_p-1:0] g_i
  ,input [bit_depth_p-1:0] b_i

  // vga interface
  ,input [$clog2(physical_width_p)-1:0] vga_x_i
  ,input [$clog2(physical_height_p)-1:0] vga_y_i
  ,input vga_v_i
  ,output logic [bit_depth_p-1:0] vga_r_o
  ,output logic [bit_depth_p-1:0] vga_g_o
  ,output logic [bit_depth_p-1:0] vga_b_o
); 
  assign x_o = vga_v_i ? vga_x_i >> 3 : '0;
  assign y_o = vga_v_i ? (vga_y_i >= 12 && vga_y_i < 588 ? vga_y_i >> 3 : '0) : '0;

  reg [$clog2(physical_width_p)-1:0] str_score_x_r;
  reg [$clog2(physical_height_p)-1:0] str_score_y_r;

  always_ff @(posedge clk_i) begin
    if(reset_i) begin
      str_score_x_r <= '0;
      str_score_y_r <= '0;
    end
    else if(str_score_v_i) begin
      str_score_x_r <= vga_x_i;
      str_score_y_r <= vga_y_i;
    end
  end

  logic [7:0] str_score_addr_x = vga_x_i - str_score_x_r;
  logic [5:0] str_score_addr_y = vga_x_i - str_score_y_r;

  logic [31:0] str_score_rom_out;

  reg [$clog2(physical_width_p)-1:0] str_next_x_r;
  reg [$clog2(physical_height_p)-1:0] str_next_y_r;

  always_ff @(posedge clk_i) begin
    if(reset_i) begin
      str_next_x_r <= '0;
      str_next_y_r <= '0;
    end
    else if(str_next_v_i) begin
      str_next_x_r <= vga_x_i;
      str_next_y_r <= vga_y_i;
    end
  end

  logic [6:0] str_next_addr_x = vga_x_i - str_next_x_r;
  logic [5:0] str_next_addr_y = vga_x_i - str_next_y_r;

  logic [31:0] str_next_rom_out;

  always_comb begin
    if(vga_x_i >= str_score_x_r && vga_x_i < str_score_x_r + 256 && vga_y_i >= str_score_y_r & vga_y_i < str_score_y_r + 64)
      vga_r_o = str_score_rom_out[str_score_addr_x[4:0]];
    else if(vga_x_i >= str_next_x_r && vga_x_i < str_next_x_r + 128 && vga_y_i >= str_next_y_r & vga_y_i < str_next_y_r + 64)
      vga_r_o = str_next_rom_out[str_next_addr_x[4:0]];
    else 
      vga_r_o = r_i;
  end


endmodule

