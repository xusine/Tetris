module matrix_memory #(
  parameter width_p = 16
  ,parameter height_p = 32
  ,parameter debug_p = 0
)(
  input clk_i
  ,input reset_i

  // read port 1, for scanner
  ,input [$clog2(height_p)-1:0] read_line_addr_1_i
  ,output [width_p-1:0] read_line_data_1_o

  // read port 2, for executor_check
  ,input [$clog2(height_p)-1:0] read_line_addr_2_i
  ,output [width_p-1:0] read_line_data_2_o

  // read port 3, for current memory
  ,input point_t read_block_addr_i
  ,output logic [3:0][3:0] read_block_data_o

  // read port 4, for executor commit
  ,input point_t read_block_addr_2_i
  ,output logic [3:0][3:0] read_block_data_2_o

  // write port 1, for executor_check
  ,input [$clog2(height_p)-1:0] write_addr_i
  ,input [width_p-1:0] write_data_i
  ,input v_w_i

  // write port 2, for executor commit
  ,input point_t write_block_addr_i
  ,input [3:0][3:0] write_block_data_i
  ,input v_block_i

  // is ready
  ,output is_ready_o

);

logic [height_p-1:0][width_p-1:0] mem_r;
logic [3:0][3:0] block_memory_r;

typedef enum bit [0:0] {eNORMAL, eBLOCK} state_e;

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

point_t write_block_addr_r;

wire [$clog2(height_p):0] actual_write_y = write_block_addr_r.y_m + state_block_counter_r[3:2];
wire [$clog2(width_p):0] actual_write_x = write_block_addr_r.x_m + state_block_counter_r[1:0];
always_ff @(posedge clk_i) begin
  if(reset_i) begin
    mem_r <= '0;
  end
  else if(v_w_i & current_state_n == eNORMAL) begin
    mem_r[write_addr_i] <= write_data_i;
  end
  else if(current_state_n == eBLOCK | v_block_i) begin
    if((actual_write_y < height_p) & (actual_write_x < width_p))
      mem_r[actual_write_y[$clog2(height_p)-1:0]][actual_write_x[$clog2(width_p)-1:0]] <= block_memory_r[state_block_counter_r[3:2]][state_block_counter_r[1:0]];
  end
end

always_ff @(posedge clk_i) begin
  if(reset_i) begin
    block_memory_r <= '0;
    write_block_addr_r <= '0;
  end
  else begin
    if(v_block_i) begin
      block_memory_r <= write_block_data_i;
      write_block_addr_r <= write_block_addr_i;
    end
  end
end

wire [3:0][$clog2(height_p):0] read_addr_y;
wire [3:0][$clog2(width_p):0] read_addr_x;

for(genvar i = 0; i < 4; ++i) begin
  assign read_addr_y[i] = read_block_addr_i.y_m + i;
  assign read_addr_x[i] = read_block_addr_i.x_m + i;
  for(genvar j = 0; j < 4; ++j) begin
    //assign read_block_data_o[i][j] = ( (read_addr_y[i] >= height_p & read_addr_y[i] < 2*height_p - 4) | read_addr_x[j] >= width_p) ? 1'b1
    //                                  : mem_r[read_addr_y[i][$clog2(height_p)-1:0]][read_addr_x[j][$clog2(width_p)-1:0]];
    always_comb begin
      if(read_addr_x[j] >= width_p)
        read_block_data_o[i][j] = 1'b1;
      else if(read_addr_y[i] >= height_p && read_addr_y[i] < 2*height_p - 4)
        read_block_data_o[i][j] = 1'b1;
      else if(read_addr_y[i] >= 2*height_p - 4 && read_addr_y[i] < 2*height_p)
        read_block_data_o[i][j] = 1'b0;
      else 
        read_block_data_o[i][j] = mem_r[read_addr_y[i][$clog2(height_p)-1:0]][read_addr_x[j][$clog2(width_p)-1:0]];
    end
  end
end

wire [3:0][$clog2(height_p):0] read_addr_y_2;
wire [3:0][$clog2(width_p):0] read_addr_x_2;

for(genvar i = 0; i < 4; ++i) begin
  assign read_addr_y_2[i] = read_block_addr_2_i.y_m + i;
  assign read_addr_x_2[i] = read_block_addr_2_i.x_m + i;
  for(genvar j = 0; j < 4; ++j) begin
    //assign read_block_data_2_o[i][j] = ( (read_addr_y_2[i] >= height_p & read_addr_y_2[i] < 2*height_p - 4) | read_addr_x_2[j] >= width_p) ? 1'b1
    //                                  : mem_r[read_addr_y_2[i][$clog2(height_p)-1:0]][read_addr_x_2[j][$clog2(width_p)-1:0]];
    always_comb begin
      if(read_addr_x_2[j] >= width_p)
        read_block_data_2_o[i][j] = 1'b1;
      else if(read_addr_y_2[i] >= height_p && read_addr_y_2[i] < 2*height_p - 4)
        read_block_data_2_o[i][j] = 1'b1;
      else if(read_addr_y_2[i] >= 2*height_p - 4)
        read_block_data_2_o[i][j] = 1'b0;
      else 
        read_block_data_2_o[i][j] = mem_r[read_addr_y_2[i][$clog2(height_p)-1:0]][read_addr_x_2[j][$clog2(width_p)-1:0]];
    end
  end
end

assign read_line_data_1_o = mem_r[read_line_addr_1_i][width_p-1:0];
assign read_line_data_2_o = mem_r[read_line_addr_2_i][width_p-1:0];

assign is_ready_o = (current_state_r == eNORMAL);

if(debug_p)
  always_ff @(posedge clk_i) begin
    //integer i = 0;
    //$display("=================Memory Info At %s:%d==================", current_state_r.name(),state_block_counter_r);
    //for(i = 0; i < height_p; i = i + 1) 
    //  $display("%d:%b",i,mem_r[i]);
    $display("===========Matrix Memory=============");
    $display("Block output 1:");
    displayMatrix(read_block_data_o);
    $display("Block output 2:");
    displayMatrix(read_block_data_2_o);
  end


endmodule