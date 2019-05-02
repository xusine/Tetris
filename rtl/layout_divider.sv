module layout_divider #(
    parameter width_p=100,
    parameter height_p=72
    
)( 
    input [$clog2(width_p)-1:0] x_i ,// x input
    input [$clog2(height_p)-1:0] y_i ,// y input
    output logic score_v,
    output logic next_v,
    output r_o,
    output g_o,
    output b_o
);

always_comb begin     
    if (x_i == 20&&y_i==20) begin
        score_v ='1;
        next_v = '0;
        r_o = 1;
        g_o = 0;
        b_o = 0;
    end
    else if(x_i == 20&&y_i == 40) begin
        score_v ='0;
        next_v = '1;
        r_o = 0;
        g_o = 0;
        b_o = 1;
    end
    else begin
        score_v ='0;
        next_v = '0;
        r_o = 0;
        g_o = 0;
        b_o = 0;                
end

endmodule