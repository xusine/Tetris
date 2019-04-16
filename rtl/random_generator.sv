/*
	A LFSR Random generator
*/

module random_generator #(
	parameter width_p = 65
	,parameter mask_p = 1'b1
)(
	input clk_i
	,input reset_i

	,input [width_p-1:0] seed_i
	,input v_i

	,output[width_p-1:0] random_o
	,output v_o
);


typedef enum {eIDLE, eGEN} state_e;

state_e current_state_r, current_state_n;

always_ff@(posedge clk_i) begin
	if(reset_i)
		current_state_r <= eIDLE;
	else
		current_state_r <= current_state_n;
end

assign current_state_n = v_i ? eGEN : current_state_r;

reg [width_p-1:0] random_r;

logic [width_p-1:0] random_n;


always_ff @(posedge clk_i) begin
	if(reset_i) 
		random_r <= width_p'(0);
	else
		random_r <= random_n ^ random_r;
end

assign random_o = random_r;
assign v_o = current_state_r != eIDLE;

wire [width_p-1:0] feedback;

always_comb unique case(current_state_r) 
	eIDLE: begin
		if(v_i)
			random_n = seed_i;
		else
			random_n = '0;
	end
	eGEN: random_n = feedback;
endcase

generate
	for(genvar i = 1; i < width_p; ++i) begin
		if(mask_p &(1 << i))
			assign feedback[i] = random_r[width_p-1] ^ random_r[i-1];
		else
			assign feedback[i] = random_r[i-1];
	end
endgenerate

assign feedback[0] = random_r[width_p-1];

endmodule