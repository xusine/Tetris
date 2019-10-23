module memory_pattern#(
  parameter integer width_p
  ,parameter integer depth_p
)(
  input [$clog2(depth_p)-1:0] addr_i
  ,output logic [width_p-1:0] data_o
);
always_comb unique case(addr_i)
  0: data_o = 0;
  1: data_o = 0;
  2: data_o = 0;
  3: data_o = 0;
  4: data_o = 327731;
  5: data_o = 327731;
  6: data_o = 327731;
  7: data_o = 327731;
  8: data_o = 590626;
  9: data_o = 393329;
  10: data_o = 1704486;
  11: data_o = 4850800;
  12: data_o = 4653296;
  13: data_o = 1909282;
  14: data_o = 4653296;
  15: data_o = 1909282;
  16: data_o = 393332;
  17: data_o = 1705506;
  18: data_o = 4850032;
  19: data_o = 590371;
  20: data_o = 590385;
  21: data_o = 393270;
  22: data_o = 590385;
  23: data_o = 393270;
  24: data_o = 590130;
  25: data_o = 393315;
  26: data_o = 590130;
  27: data_o = 393315;
  28: data_o = 393330;
  29: data_o = 1704546;
  30: data_o = 4850288;
  31: data_o = 590386;
  default: data_o = 'X;
endcase
endmodule
