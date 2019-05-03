TEST_LIB=./sim/lib/.
SYNTHESYS_LIB=./rtl/lib/.

VCS=vcs -full64 -sverilog -cc gcc-4.8 -cpp g++-4.8

verilator_test_game_plate:
	verilator -Wno-fatal -sv \
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
	-CFLAGS "-g -O3" \
	--exe sim_verilator/game_plate.cpp

	make -C obj_dir -f Vgame_plate.mk

	./obj_dir/Vgame_plate > rep.txt


test_game_plate:
	make clean
	$(VCS) include/tetris.sv \
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
	./rtl/game_plate.sv


test_layout_remapper:
	make clean
	$(VCS) ./rtl/layout_remapper.sv

test_vga_logic:
	make clean
	$(VCS) $(TEST_LIB)/*.v \
	./rtl/vga_controller.sv \
	./sim/tb_vga_controller.sv

	./simv

clean:
	rm -rf ./rtl/csrc
	rm -rf ./rtl/simv*
	rm -rf csrc
	rm -rf simv*
	rm -f ucli.key
	rm -rf obj_dir