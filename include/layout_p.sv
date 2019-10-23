package layout_parameters;

parameter integer logic_width_p = 100;
parameter integer logic_height_p = 72;

typedef struct packed{
  logic [$clog2(logic_width_p)-1:0] x_m;
  logic [$clog2(logic_height_p)-1:0] y_m;
  logic [$clog2(logic_width_p)-1:0] w_m;
  logic [$clog2(logic_height_p)-1:0] h_m;
} rect_t;

parameter rect_t str_score_pos_p = '{22,11,32,8};
parameter rect_t str_next_pos_p = '{30,38,16,8};
parameter rect_t score_pos_p = '{30,22,16,8}; 
parameter rect_t next_block_pos_p = '{30,49,16,16};
parameter rect_t board_pos_p = '{59,4,32,64};

endpackage

