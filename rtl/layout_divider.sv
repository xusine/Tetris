module layout_divider #(
    parameters width_p=100,
    parameters height_p=72
    
)( 
    input [$clog2(width_p)-1:0] x_i ,// x input
    input [$clog2(height_p)-1:0] y_i ,// y input
    output logic socre_v,//1 stands for 
);
always_comb begin     
    if (x_i<20&&x_i>80&&y_i<20&&y_i>80) begin
        socre_v ='0;
    end
    else begin
        socre_v ='1;
    end
end

endmodule