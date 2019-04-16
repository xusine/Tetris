TEST_LIB=./sim/lib/.
SYNTHESYS_LIB=./rtl/lib/.

VCS=vcs -full64 -sverilog -cc gcc-4.8 -cpp g++-4.8


test_union_randon:
	make clean
	$(VCS) $(TEST_LIB)/*.v \
	./rtl/union_random_generator.sv \
	./rtl/random_generator.sv \
	./test/tb_union_random_generator.sv 
	./simv

test_random:
	make clean
	$(VCS) $(TEST_LIB)/*.v \
	./rtl/random_generator.sv \
	./test/tb_random_generator.sv 
	./simv

clean:
	rm -rf ./rtl/csrc
	rm -rf ./rtl/simv*
	rm -rf csrc
	rm -rf simv*
	rm -f ucli.key