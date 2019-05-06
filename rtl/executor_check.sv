module executor_check #(
  parameter integer width_p = 16
  ,parameter integer height_p = 32
  ,parameter debug_p = 1
)(
  input clk_i
  ,input reset_i
  ,input v_i
  ,output done_o

  // matrix memory interface
  ,output [$clog2(height_p)-1:0] mm_read_addr_o
  ,input [width_p-1:0] mm_read_data_i
  ,output [$clog2(height_p)-1:0] mm_write_addr_o
  ,output [width_p-1:0] mm_write_data_o
  ,output mm_write_v_o

  ,output [$clog2(height_p)-1:0] combine_number_o

);

typedef enum bit [1:0] {eIDLE, eCheck, eMove} state_e;
// FSM
state_e state_r;
// Memory address
reg [$clog2(height_p)-1:0] mm_addr_r_r;
reg [$clog2(height_p)-1:0] mm_addr_w_r;
reg [$clog2(height_p)-1:0] combine_num_r;
always_ff @(posedge clk_i) begin
  if(reset_i) begin
    state_r <= eIDLE;
  end
  else unique case(state_r)
    eIDLE: state_r <= v_i ? eCheck : eIDLE;
    eCheck: begin
      if(mm_read_data_i == '1) begin
        state_r <= eMove;
      end
      else if(mm_addr_r_r == '0) begin
        state_r <= eIDLE;
      end
    end
    eMove: begin
      if(mm_addr_w_r == '0) state_r <= eCheck;
      else  state_r <= eMove;
    end
    default: begin

    end
  endcase
end

assign mm_read_addr_o = mm_addr_r_r;
assign mm_write_addr_o = mm_addr_w_r;
assign done_o = state_r == eCheck && mm_addr_r_r == 0 && mm_read_data_i != '1;
assign combine_number_o = combine_num_r;

// update memory address
always_ff @(posedge clk_i) begin
  if(reset_i) begin
    mm_addr_r_r <= height_p-1;
    mm_addr_w_r <= height_p-1;
    combine_num_r <= '0;
  end
  else unique case(state_r) 
    eIDLE: begin
      mm_addr_r_r <= height_p-1;
      mm_addr_w_r <= height_p-1;
      combine_num_r <= '0;
    end
    eCheck: begin
      mm_addr_r_r <= mm_addr_r_r - 1;
      if(mm_read_data_i != '1) begin
        mm_addr_w_r <= mm_addr_w_r - 1;
      end
      else begin
        combine_num_r <= combine_num_r + 1;
      end
    end
    eMove: begin
      if(mm_addr_w_r == 0) begin // ?
        mm_addr_w_r <= height_p-1;
        mm_addr_r_r <= height_p-1;
      end
      else begin
        mm_addr_r_r <= mm_addr_r_r - 1;
        mm_addr_w_r <= mm_addr_w_r - 1;
      end
    end
    default: begin

    end
  endcase
end
assign mm_write_data_o = (mm_addr_w_r == height_p - 1) ? '0 : mm_read_data_i;
assign mm_write_v_o = state_r == eMove;
if(debug_p)
always_ff @(posedge clk_i) begin
  $display("==============Executor Check==============");
  $display("From executor_check: state_r:%s",state_r.name());
  $display("From executor_check: mm_addr_r:%b",mm_addr_r_r);
  $display("From executor_check: mm_addr_w:%b",mm_addr_r_r);
end
endmodule
