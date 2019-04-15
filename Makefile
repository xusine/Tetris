TEST_LIB=./test/lib/.
SYNTHESYS_LIB=./hw/lib/.

VCS=vcs -full64 -sverilog -cc gcc-4.8 -cpp g++-4.8


test_union_randon:
	make clean
	$(VCS) $(TEST_LIB)/*.v \
	./hw/union_random_generator.sv \
	./hw/random_generator.sv \
	./test/tb_union_random_generator.sv 
	./simv

test_random:
	make clean
	$(VCS) $(TEST_LIB)/*.v \
	./hw/random_generator.sv \
	./test/tb_random_generator.sv 
	./simv

clean:
	rm -rf ./hw/csrc
	rm -rf ./hw/simv*
	rm -rf csrc
	rm -rf simv*
	rm -f ucli.key