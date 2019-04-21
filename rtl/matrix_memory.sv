module matrix_memory #(
  parameter word_width_p = -1
  ,parameter size_p = -1
)(
  input clk_i
  ,input reset_i

  // read port 1, for scanner
  ,input [$clog2(size_p)-1:0] read_line_addr_1_i
  ,output [word_width_p-1:0] read_line_data_1_o
  ,input v_r1_i

  // read port 2, for executor_check
  ,input [$clog2(size_p)-1:0] read_line_addr_2_i
  ,output [word_width_p-1:0] read_line_data_2_o
  ,input v_r2_i

  // read port 3, for 4*4 block
  ,input [$clog2(word_width_p):0] read_block_addr_x_i
  ,input [$clog2(size_p):0] read_block_addr_y_i
  ,output [3:0][3:0] read_block_data_o
  ,input v_r3_i

  // write port 1, for executor_check
  ,input [$clog2(size_p)-1:0] write_addr_i
  ,input [word_width_p-1:0] write_data_i
  ,input v_w_i

  // write port 2, for 4*4 block
  ,input [$clog2(word_width_p):0] write_block_addr_x_i
  ,input [$clog2(size_p):0] write_block_addr_y_i
  ,input [3:0][3:0] write_block_data_i
  ,input v_block_i

  ,output is_ready_o
);

logic [size_p-1:0][word_width_p-1:0] mem_r;
logic [3:0][3:0] block_memory_r;

typedef enum [0:0] {eNORMAL, eBLOCK} state_e;

state_e current_state_r, current_state_n;

always_ff @(posedge clk_i) begin
  if(reset_i)
    current_state_r <= eNORMAL;
  else
    current_state_r <= current_state_n;
end
reg [3:0] state_block_counter_r;

always_comb unique case(current_state_r)
  eNORMAL: begin
    if(v_block_i)
      current_state_n = eBLOCK;
    else
      current_state_n = eNORMAL;
  end
  eBLOCK: begin
    if(state_block_counter_r == '1)
      current_state_n = eNORMAL;
    else
      current_state_n = eBLOCK;
  end
endcase

// update state_block_counter_r
always_ff @(posedge clk_i) begin
  if(reset_i)
    state_block_counter_r <= '0;
  else if(current_state_r == eBLOCK)
    state_block_counter_r <= state_block_counter_r + 4'b1;
end
// update memory for normal state

reg [$clog2(word_width_p):0] read_block_addr_x_r;
reg [$clog2(size_p):0] read_block_addr_y_r;

reg [$clog2(word_width_p):0] write_block_addr_x_r;
reg [$clog2(size_p):0] write_block_addr_y_r;

wire [$clog2(size_p):0] actual_write_y = write_block_addr_y_r + state_block_counter_r[3:2];
wire [$clog2(word_width_p):0] actual_write_x = write_block_addr_x_r + state_block_counter_r[1:0];
always_ff @(posedge clk_i) begin
  if(reset_i) begin
    mem_r <= '0;
  end
  else if(v_w_i & current_state_n == eNORMAL) begin
    mem_r[write_addr_i] <= write_data_i;
  end
  else if(current_state_n == eBLOCK | v_block_i) begin
    $display("%b, %b",actual_write_y,actual_write_x);
    if((~actual_write_y[$clog2(size_p)]) & (~actual_write_x[$clog2(word_width_p)]))
      $display("0");
      mem_r[actual_write_y][actual_write_x] <= block_memory_r[state_block_counter_r[3:2]][state_block_counter_r[1:0]];
  end
end


reg [$clog2(size_p)-1:0] read_addr_1_r;
reg [$clog2(size_p)-1:0] read_addr_2_r;

always_ff @(posedge clk_i) begin
  if(reset_i) begin
    read_addr_1_r <= '0;
    read_addr_2_r <= '0;
    block_memory_r <= '0;
    read_block_addr_x_r <= '0;
    read_block_addr_y_r <= '0;
    write_block_addr_x_r <= '0;
    write_block_addr_y_r <= '0;
  end
  else begin
    if(v_r1_i)
      read_addr_1_r <= read_line_addr_1_i;
    if(v_r2_i)
      read_addr_2_r <= read_line_addr_2_i;
    if(v_r3_i) begin
      read_block_addr_x_r <= read_block_addr_x_i;
      read_block_addr_y_r <= read_block_addr_y_i;
    end
    if(v_block_i) begin
      block_memory_r <= write_block_data_i;
      write_block_addr_x_r <= write_block_addr_x_i;
      write_block_addr_y_r <= write_block_addr_y_i;
    end
  end
end

wire [3:0][$clog2(size_p):0] read_addr_y;
wire [3:0][$clog2(word_width_p):0] read_addr_x;

for(genvar i = 0; i < 3; ++i) begin
  assign read_addr_y[i] = read_block_addr_y_i + i;
  assign read_addr_x[i] = read_block_addr_x_i + i;
  for(genvar j = 0; j < 3; ++j) begin
    assign read_block_data_o[i][j] = (read_addr_y[i][$clog2(size_p)] | read_addr_x[j][$clog2(word_width_p)]) ? 1'b00
                                      : mem_r[read_addr_y[i][$clog2(size_p)-1:0]][read_addr_x[j][$clog2(word_width_p)-1:0]];

  end
end
assign read_line_data_1_o = mem_r[read_addr_1_r][word_width_p-1:0];
assign read_line_data_2_o = mem_r[read_addr_2_r][word_width_p-1:0];

assign is_ready_o = (current_state_r == eNORMAL);

always_ff @(posedge clk_i) begin
  integer i = 0;
  $display("=================Memory Info At %s:%d==================", current_state_r.name(),state_block_counter_r);
  for(i = 0; i < size_p; i = i + 1) 
    $display("%d:%b",i,mem_r[i]);
end


endmodule