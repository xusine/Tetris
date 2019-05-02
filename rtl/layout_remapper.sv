module layout_remapper #(
  parameter integer logic_width_p = 100
  ,parameter integer logic_height_p = 72    
  ,parameter integer physical_width_p = 800
  ,parameter integer physical_height_p = 600
  ,parameter integer bit_depth_p = 1

  ,parameter integer str_score_start_x = 20
  ,parameter integer str_score_start_y = 20
  ,parameter integer str_next_start_x = 20
  ,parameter integer str_next_start_y = 40
)(

  input clk_i //=36MHz
  ,input reset_i

  ,output [$clog2(logic_width_p)-1:0] x_o
  ,output [$clog2(logic_height_p)-1:0] y_o

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

  wire [7:0] str_score_addr_x = vga_x_i - str_score_start_x * 8;
  wire [5:0] str_score_addr_y = vga_x_i - str_score_start_y * 8;
  logic [31:0] str_score_rom_out;

  score_mem score_mem1 (
	.address({str_score_addr_x[7:5],str_score_addr_y})
	,.clock(clk_i)
	,.q(str_score_rom_out)
  );
  

  wire [6:0] str_next_addr_x = vga_x_i - str_next_start_x * 8;
  wire [5:0] str_next_addr_y = vga_x_i - str_next_start_y * 8;
  logic [31:0] str_next_rom_out;
  next_mem next_mem1(
	.address({str_next_addr_x[6:5],str_next_addr_y})
	,.clock(clk_i)
	,.q(str_next_rom_out)
  );


  always_comb begin
    if(x_o >= str_score_start_x && x_o < str_score_start_x + 32 && y_o >= str_score_start_y & y_o < str_score_start_y + 8) begin
      vga_r_o = r_i & str_score_rom_out[str_score_addr_x[4:0]];
      vga_g_o = g_i & str_score_rom_out[str_score_addr_x[4:0]];
      vga_b_o = b_i & str_score_rom_out[str_score_addr_x[4:0]];
	 end
    else if(x_o >= str_score_start_x && vga_x_i < str_score_start_x + 16 && y_o >= str_next_start_y & y_o < str_next_start_y + 8) begin
      vga_r_o = r_i & str_next_rom_out[str_next_addr_x[4:0]];
      vga_g_o = g_i & str_next_rom_out[str_next_addr_x[4:0]];
      vga_b_o = b_i & str_next_rom_out[str_next_addr_x[4:0]];
	 end
    else begin
      vga_r_o = 1'b1;
      vga_g_o = 1'b1;
      vga_b_o = 1'b1;
	 end
  end


endmodule

