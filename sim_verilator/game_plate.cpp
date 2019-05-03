#include<verilated.h>
#include<stdio.h>
#include "../obj_dir/Vgame_plate.h"
#include "test_template.hpp"

int main(int argc, char **argv){
    Verilated::commandArgs(argc, argv);
    TestWrapper<Vgame_plate> wrapper;
    auto dut = wrapper.dut();
    // initial value
    dut->clk_i = 0;
    dut->reset_i = 0;
    dut->opcode_i = 0;
    dut->opcode_v_i = 0;
    dut->dis_logic_x_i = 0;
    dut->dis_logic_y_i = 0;
    dut->eval();

    // reset
    wrapper.reset();

    puts("Reset Finished!");

    wrapper.tick();

    dut->opcode_i = 3;
    dut->opcode_v_i = 1;
    wrapper.tick();
    while(!dut->done_o)
        wrapper.tick();

        

    return 0;
}