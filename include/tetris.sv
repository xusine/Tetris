package tetris;

typedef enum [2:0] {eNOP, eNewTile, eRotate, eDown, eLeft, eRight, eClear} tile_opcode_e;

typedef enum bit [2:0] {eNon = 3'd0, eSquire = 3'd1, eRightL = 3'd2, eI = 3'd3, eLeftL = 3'd4, eRightZ = 3'd5, eLeftZ = 3'd6, eT = 3'd7} tile_type_e;

// newTile: type(4:0), position(2:0)(10-6) (fetch->put(3 clock)->)
// Rotate, Down, Left, Right, Clear: 0

typedef struct packed{
    logic [3:0][3:0] shape_m
    ,logic [1:0] max_x_m
    ,logic [1:0] max_y_m
    ,logic [1:0] min_x_m // bias for actual X
    ,logic [1:0] min_y_m // bias for actual Y
} shape_info_t;

parameter scene_width_p = 16;
parameter scene_height_p = 32;

typedef struct packed{
  logic [$clog2(scene_width_p):0] x_m
  ,logic [$clog2(scene_height_p):0] y_m
} point_t;

endpackage