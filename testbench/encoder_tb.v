`timescale 1ns/1ps

module encoder_tb();
    reg mode_i;
    reg ch_vol_i;
    reg [7:0] cmd_i;
    reg [7:0] num_i;
    wire [27:0] digits_val_o;

    encoder  uut(
        .mode_i(mode_i),
        .ch_vol_i(ch_vol_i),
        .cmd_i(cmd_i),
        .num_i(num_i),
        .digits_val_o(digits_val_o)
    );

    initial begin
        mode_i = 1'b0;
        ch_vol_i = 1'b0;
        cmd_i = 8'h0;
        num_i = 8'd0;
        #40;

        num_i = 8'd1;
        #120;

        num_i = 8'd63;
        #120;

        num_i = 8'd62;
        #120;

        num_i = 8'd63;
        #120;

        num_i = 8'd1;
        #120;

        num_i = 8'd2;
        #120;

        num_i = 8'd3;
        #120;

        num_i = 8'd4;
        #120;

        num_i = 8'd5;
        #120;

        ch_vol_i = 1'b1;
        num_i = 8'd0;
        #120;

        ch_vol_i = 1'b1;
        num_i = 8'd2;
        #120;

        ch_vol_i = 1'b1;
        num_i = 8'd3;
        #120;

        ch_vol_i = 1'b1;
        num_i = 8'd4;
        #120;

        // 13*120 + 40 = 13(100+10+10) + 40
        // 1300 + 260 + 40 = 1600ns = 1.6us
    end
endmodule