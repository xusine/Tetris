TEST_LIB=./sim/lib/.
SYNTHESYS_LIB=./rtl/lib/.

VCS=vcs -full64 -sverilog -cc gcc-4.8 -cpp g++-4.8

test_game_plate:
	make clean
	$(VCS) include/tetris.sv \
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