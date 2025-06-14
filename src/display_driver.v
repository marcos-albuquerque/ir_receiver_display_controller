module display_driver (
    input clk_50M_i,
    input clk_38k_i,
    input [27:0] digits_val_i,
    output clk_38k_o,
    output [3:0] digit_o
);
    // interleave digits
    reg [2:0] timer; // count from 0 to 7

    reg [7:0] reg_data;
    assign data_out = reg_data[0];

    reg [7:0] data_in;

    reg load;

    // PISO reg
    always @(posedge clk_50M_i) begin
        if (clk_38k_i) begin
            if(load)   reg_data <= data_in;
            else reg_data <= {1'b0, reg_data[7:1]};
        end
    end

endmodule
