/*
union_random_generator.sv
a combination of several random generator to make sure 
*/

module union_random_generator #(
  parameter width_p = 32
  ,parameter lfsr_num = 4
	,parameter integer mask_p[lfsr_num-1:0] = {1,3,4,2}
)(
	input clk_i
	,input reset_i

	,output [width_p-1:0] random_o
);

wire [lfsr_num-1:0][width_p-1:0] random_lo;

generate
	for(genvar i = 0; i < lfsr_num; ++i) begin: RANDOM_GENERATOR_ARRAY
		random_generator #(
			.width_p(width_p)
			,.mask_p(mask_p[i])
			,.seed_p(i*i + 2 * i + 4)
		)
		rg[i]
		(
			clk_i
			,reset_i
			,random_lo[i]
		);
	end
endgenerate

wire [lfsr_num-1:0][width_p-1:0] random_lo_xor;
assign random_lo_xor[0] = random_lo[0];

generate
	for(genvar i = 1; i < lfsr_num; ++i) begin
		assign random_lo_xor[i] = random_lo_xor[i-1] ^ random_lo[i];
	end	
endgenerate

assign random_o = random_lo_xor[lfsr_num-1];
endmodule