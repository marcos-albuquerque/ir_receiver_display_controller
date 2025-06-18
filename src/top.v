
module top (
    input clk_50M_i,
    input rst_i,
    input ir_i,
    output clk_38k_o,
    output data_o,
    output [3:0] digit_o
);
    
    // wirings for the nec_demodulator

    wire [7:0] addr_code_o;
    wire [7:0] cmd_code_o;
    wire fail_o;
    wire valid_o;

    nec_demodulator  nec_demodulator_inst (
        .clk_i(clk_50M_i),
        .rst_i(rst_i),
        .ir_i(ir_i),
        .addr_code_o(addr_code_o),
        .cmd_code_o(cmd_code_o),
        .fail_o(fail_o),
        .valid_o(valid_o)
    );

    // wiring control_unit

    wire stand_by_o;
    wire mode_o;
    wire ch_vol_o;
    wire [7:0] cmd_o;
    wire [7:0] num_o;


    control_unit  control_unit_inst (
        .clk_i(clk_50M_i),
        .rst_i(rst_i),
        .valid_i(valid_o),
        .cmd_i(cmd_code_o),
        .stand_by_o(stand_by_o),
        .mode_o(mode_o),
        .ch_vol_o(ch_vol_o),
        .cmd_o(cmd_o),
        .num_o(num_o)
    );

    // wiring for encoder 
    
    wire [27:0] digit_values_o;

    encoder  encoder_inst (
        .mode_i(mode_o),
        .ch_vol_i(ch_vol_o),
        .cmd_i(cmd_o),
        .num_i(num_o),
        .digit_values_o(digit_values_o)
    );

    // wiring display driver

    wire clk_38k_o_;
    wire data_o_;
    wire [3:0] digit_o_;
    
    clock_divider # (
        .FREQUENCY_IN(50_000_000),
        .FREQUENCY_OUT(37990)
    )
    clock_divider_inst (
        .clk_i(clk_50M_i),
        .rst_i(rst_i),
        .clk_pulse_o(clk_38k_o_)
    );


    display_driver  display_driver_inst (
        .clk_50M_i(clk_50M_i),
        .clk_38k_i(clk_38k_o_),
        .rst_i(rst_i),
        .stand_by_i(stand_by_o),
        .digit_values_i(digit_values_o),
        .data_o(data_o_),
        .digit_o(digit_o_)
    );


    assign clk_38k_o = clk_38k_o_; 
    assign data_o = data_o_;
    assign digit_o = digit_o_; 

endmodule