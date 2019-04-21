// Warning: this file is only used for test!
module tetris_rom(
  input [4:0] addr_i
  ,output [23:0] data_o
)
  logic [31:0][23:0] mem_r;
  assign data_o = mem_r[addr_i];
  initial begin
    $readmemb("./../rom/teris_rom.txt",mem_r);
  end
endmodule