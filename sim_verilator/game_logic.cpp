#include<verilated.h>
#include<stdio.h>
#include "test_template.hpp"

#include "../obj_dir/Vgame_top_logic.h"
#include "../obj_dir/Vgame_top_logic_tetris.h"


template<typename T> void displayCurrentInfo(TestWrapper<T> &dut){
    puts("Board Info:");
    for(int i = 0; i < 16; ++i){
        dut->dis_logic_y_i = i;
        for(int j = 0; j < 16; ++j){
            dut->dis_logic_x_i = j;
            dut->eval();
            if(dut->dis_logic_mm_o)
                printf("1 ");
            else if(dut->dis_logic_cm_o)
                printf("* ");
            else
                printf("0 ");
        }
        puts("");
    }
}

int main(int argc, char **argv){
    Verilated::commandArgs(argc, argv);
    TestWrapper<Vgame_top_logic> wrapper;

    wrapper->clk_i = 0;
    wrapper->reset_i = 0;
    wrapper->left_i = 0;
    wrapper->right_i = 0;
    wrapper->rotate_i = 0;

    wrapper->start_i = 0;
    wrapper->dis_logic_x_i = 0;
    wrapper->dis_logic_y_i = 0;

    wrapper->eval();


    wrapper.reset();

    wrapper.tick(false);
    wrapper.tick(false);

    wrapper->start_i = 1;
    wrapper->eval();
    for(int i = 0; i < 512; ++i){
        wrapper.tick(false);
        if(wrapper->debug_turn_finished_o)
            displayCurrentInfo(wrapper);
    }
        
    return 0;
}