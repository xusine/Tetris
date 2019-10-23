TEST_LIB=./sim/lib/.
SYNTHESYS_LIB=./rtl/lib/.

VCS=vcs -full64 -sverilog -cc gcc-4.8 -cpp g++-4.8

verilator_test_game_top_logic:
	make clean
	verilator -Wno-fatal -sv \
	--default-language 1800-2017 \
	-cc include/tetris.sv \
	./rom/memory_pattern.sv \
	./rtl/union_random_generator.sv \
	./rtl/random_generator.sv \
	./rtl/executor_commit.sv \
	./rtl/executor_rotate.sv \
	./rtl/executor_move.sv \
	./rtl/executor_new.sv \
	./rtl/executor_check.sv \
	./rtl/matrix_memory.sv \
	./rtl/current_tile_memory.sv \
	./rtl/game_plate.sv \
	./rtl/game_top_logic.sv \
	--top-module game_top_logic \
	-CFLAGS "-g" \
	--exe sim_verilator/game_logic.cpp

	make -C obj_dir -f Vgame_top_logic.mk

	./obj_dir/Vgame_top_logic > rep.txt


verilator_test_game_plate:
	make clean
	verilator -Wno-fatal -sv \
	--default-language 1800-2017 \
	-cc include/tetris.sv \
	./rom/memory_pattern.sv \
	./rtl/union_random_generator.sv \
	./rtl/random_generator.sv \
	./rtl/executor_commit.sv \
	./rtl/executor_rotate.sv \
	./rtl/executor_move.sv \
	./rtl/executor_new.sv \
	./rtl/executor_check.sv \
	./rtl/matrix_memory.sv \
	./rtl/current_tile_memory.sv \
	./rtl/game_plate.sv \
	--top-module game_plate \
	-CFLAGS "-g" \
	--exe sim_verilator/game_plate.cpp

	make -C obj_dir -f Vgame_plate.mk

	./obj_dir/Vgame_plate



test_layout_map:
	make clean
	$(VCS) $(TEST_LIB)/*.v \
	./include/*.sv \
	./rtl/vga_controller.sv \
	./rom/memory_character.sv \
	./rtl/layout_map.sv \
	./sim/tb_layout_map.sv

	./simv > layout_rep.txt


test_union_random_generator:
	make clean
	$(VCS) $(TEST_LIB)/*.v \
	./rtl/random_generator.sv \
	./rtl/union_random_generator.sv \
	./sim/tb_union_random_generator.sv

	./simv > union_random_generator_rep.txt

clean:
	rm -rf ./rtl/csrc
	rm -rf ./rtl/simv*
	rm -rf csrc
	rm -rf simv*
	rm -f ucli.key
	rm -rf obj_dir