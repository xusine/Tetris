package tetris;

typedef enum [2:0] {eNOP, eNewTile, eRotate, eDown, eLeft, eRight, eClear} tile_opcode_e;

typedef enum bit [2:0] {eSquire = 3'b0, eRightL - 3'b1, eI = 3'b2, eLeftL = 3'b3, eRightZ = 3'b4, eLeftZ = 3'b5, eT = 3'b6} tile_type_e;

// newTile: type(4:0), position(2:0)(10-6) (fetch->put(3 clock)->)
// Rotate, Down, Left, Right, Clear: 0

typedef struct packed{
    logic [3:0][3:0] shape_m
    ,logic [1:0] max_x_m
    ,logic [1:0] max_y_m
    ,logic [1:0] min_x_m // bias for actual X
    ,logic [1:0] min_y_m // bias for actual Y
} shape_info_t;


endpackage