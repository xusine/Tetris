module anti_vibrator #(
  parameter width_p = -1
  ,parameter pos_valid_p = 1
)(
  input clk_i /*=25Hz*/
  ,input reset_i

  ,input [width_p-1:0] keys_i // 0 enabled

  ,output [width_p-1:0] keys_o;
);

reg [width_p-1:0] keys_r;

assign keys_o = keys_r;


generate if(pos_valid_p == 1)
  always_ff@(posedge clk_i) begin
    if(reset_i) begin
      keys_r <= '0;
    end
    else
      keys_r <= ~keys_i;
  end
else 
  always_ff@(posedge clk_i) begin
    if(reset_i) begin
      keys_r <= '0;
    end
    else
      keys_r <= keys_i;
  end
endgenerate

endmodule