`timescale 1ns/1ps

module display_driver_tb ();

    reg clk_50M_i;
    reg clk_38k_i;
    reg rst_i;
    reg [27:0] digit_values_i;
    wire data_o;
    wire [3:0] digit_o;

    wire clk_38k_o;

    clock_divider # (
        .FREQUENCY_IN(50_000_000),
        .FREQUENCY_OUT(37990)
    )
    clock_divider_inst (
        .clk_i(clk_50M_i),
        .rst_i(rst_i),
        .clk_pulse_o(clk_38k_o)
    );

    display_driver  display_driver_inst (
        .clk_50M_i(clk_50M_i),
        .clk_38k_i(clk_38k_o),
        .rst_i(rst_i),
        .digit_values_i(digit_values_i),
        .data_o(data_o),
        .digit_o(digit_o)
    );

    initial begin
        clk_50M_i = 0;
        forever #10 clk_50M_i = ~clk_50M_i; // Period T = 20ns
    end

    initial begin
        rst_i = 1'b1; #80;
        rst_i = 1'b0;

        //                      C      _        0         1
        digit_values_i = 28'b1001110_0000000_1111110_0110000;
        #1000000; // 1ms
    end
    
endmodule