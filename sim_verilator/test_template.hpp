#include<cstdio>
template<typename DUT>
class TestWrapper{
public:
    TestWrapper(){
        m_dut = new DUT;
        m_tick = 0;
        m_dut->clk_i = 0;
        m_dut->reset_i = 0;
    }
    ~TestWrapper(){
        if(m_dut)
            delete m_dut;
    }

    DUT *dut(){
        return m_dut;
    }

    void reset(){
        m_dut->reset_i = 1;
        m_dut->clk_i = 1;
        m_dut->eval();
        printf("=================Reset at Cycle %d=======================\n",m_tick);
        m_dut->clk_i = 0;
        m_dut->reset_i = 0;
        m_dut->eval();
        ++m_tick;
    }

    int cycleNumber() const{
        return m_tick;
    }

    void setCycleNumber(int cycle = 0){
        m_tick = cycle;
    }

    void tick(bool display = true){
        if(display)
            printf("=================Cycle %d=======================\n",m_tick);
        m_dut->clk_i = 1;
        m_dut->eval();
        m_dut->clk_i = 0;
        m_dut->eval();
        ++m_tick;
    }
private:
    DUT *m_dut;
    int m_tick;
};

template<typename T, size_t s = sizeof(T)> void dumpBits(const T * const p){
    const char *cp = reinterpret_cast<const char *>(p);
	for(size_t i = s; i > 0; --i){
		// dump cp[i]
		char tmp = cp[i - 1];
		for(int j = 7; j >=0; --j){
			std::printf("%u",(tmp & 0x80)>>7);
			tmp <<= 1;
		}
		std::printf(" ");
	}
	std::printf("\n");
}

