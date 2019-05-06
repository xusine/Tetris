package tetris;

typedef enum logic [2:0] {eNop, eNew, eMoveLeft, eMoveRight, eMoveDown, eRotate, eCommit, eCheck} opcode_e /*verilator public*/;

typedef enum logic [2:0] {eNon = 3'd0, eSquire = 3'd1, eRightL = 3'd2, eI = 3'd3, eLeftL = 3'd4, eRightZ = 3'd5, eLeftZ = 3'd6, eT = 3'd7} tile_type_e /*verilator public*/;

typedef enum logic [1:0] {eNonDir, eDown, eLeft, eRight} direction_e /*verilator public*/;
// newTile: type(4:0), position(2:0)(10-6) (fetch->put(3 clock)->)
// Rotate, Down, Left, Right, Clear: 0

typedef logic [3:0][3:0] shape_t;

typedef struct packed{
    logic [1:0] min_y_m; // bias for actual Y
    logic [1:0] min_x_m; // bias for actual X
    logic [1:0] max_y_m;
    logic [1:0] max_x_m;
    shape_t shape_m;
} shape_info_t /*verilator public*/;

parameter scene_width_p = 16;
parameter scene_height_p = 16;

typedef struct packed{
  logic [$clog2(scene_height_p):0] y_m;
  logic [$clog2(scene_width_p):0] x_m;
} point_t /*verilator public*/;

function void displayMatrix(
  input shape_t shape_i
);
  for(integer i = 0; i < 4; ++i) begin
      for(integer j = 0; j < 4; ++j)
        $write("%b",shape_i[i][j]);
      $display("");
    end
endfunction

endpackage