/*
union_random_generator.sv
a combination of several random generator to make sure 
*/

module union_random_generator #(
  parameter integer width_p = 32
  ,parameter integer lfsr_num = 4
)(
  input clk_i
  ,input reset_i

  ,output [width_p-1:0] random_o
);

wire [lfsr_num-1:0][width_p-1:0] random_lo;


for(genvar i = 0; i < lfsr_num; ++i) begin: RANDOM_GENERATOR_ARRAY
  random_generator #(
    .width_p(width_p)
    ,.mask_p(i*i*i + 3*i + 2*i*i)
    ,.seed_p(i*i + 2 * i + 4)
  )
  rg
  (
    clk_i
    ,reset_i
    ,random_lo[i]
  );
end


wire [lfsr_num-1:0][width_p-1:0] random_lo_xor;
assign random_lo_xor[0] = random_lo[0];


for(genvar i = 1; i < lfsr_num; ++i) begin
  assign random_lo_xor[i] = random_lo_xor[i-1] ^ random_lo[i];
end  


assign random_o = random_lo_xor[lfsr_num-1];
endmodule