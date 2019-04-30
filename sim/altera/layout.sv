module layout #(
	parameter integer display_width_p = 640
	,parameter integer display_height_p = 480
	,parameter integer bit_depth_p = 8
)(
	input clk_i
	,input reset_i
	
	// interface with vga_driver
	
	,input [$clog2(display_width_p)-1:0] x_i
	,input [$clog2(display_height_p)-1:0] y_i
	,input xy_v_i
	
	,output [bit_depth_p-1:0] r_o
	,output [bit_depth_p-1:0] g_o
	,output [bit_depth_p-1:0] b_o
);

localparam integer scale_lp = 8;

logic [15:0] memory_output;

wire [$clog2(display_width_p)-4:0] actual_x = x_i >> 3;
wire [$clog2(display_height_p)-4:0] actual_y = y_i >> 3;

wire [$clog2(display_width_p)-8:0] char = x_i >> 7;

mem1 score_memory(
	.address({char[2:0],actual_y[3:0]})
	,.clock(clk_i)
	,.q(memory_output)
);

assign r_o = xy_v_i & memory_output[actual_x[3:0]] ? '1 : 0;
assign g_o = '0;
assign b_o = '0;

endmodule

