/*
  A LFSR Random generator
*/

module random_generator #(
  parameter width_p = 65
  ,parameter mask_p = 1'b1
  ,parameter seed_p = 38
)(
  input clk_i
  ,input reset_i

  ,output[width_p-1:0] random_o
);

reg [width_p-1:0] random_r;

logic [width_p-1:0] random_n;


always_ff @(posedge clk_i) begin
  if(reset_i) 
    random_r <= width_p'(seed_p);
  else
    random_r <= random_n ^ random_r;
end

assign random_o = random_r;

wire [width_p-1:0] feedback;

assign random_n = feedback;


for(genvar i = 1; i < width_p; ++i) begin: FEEDBACK
  if((mask_p & (32'b1 << i)) != '0) begin: EXIST_FEEDBACK
    assign feedback[i] = random_r[width_p-1] ^ random_r[i-1];
  end
  else begin: NONE_FEEDBACK
    assign feedback[i] = random_r[i-1];
  end
end


assign feedback[0] = random_r[width_p-1];

endmodule