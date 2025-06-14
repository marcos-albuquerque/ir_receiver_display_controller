`timescale 1ns/1ps

module control_unit_tb ();
    reg clk_i;
    reg rst_i;
    reg valid_i;
    reg [7:0] cmd_i;
    wire stand_by_o;
    wire mode_o;
    wire ch_vol_o;
    wire [7:0] cmd_o;
    wire [7:0] num_o;

    control_unit uut(
        .clk_i(clk_i),
        .rst_i(rst_i),
        .valid_i(valid_i),
        .cmd_i(cmd_i),
        .stand_by_o(stand_by_o),
        .mode_o(mode_o),
        .ch_vol_o(ch_vol_o),
        .cmd_o(cmd_o),
        .num_o(num_o)
    );

    // 50MHz
    initial begin
        clk_i = 1;
        forever #10 clk_i = ~clk_i; // Period T = 20ns
    end

    initial begin
        // Initializantion
        cmd_i = 8'h00;  // None button pressed
        valid_i = 1'b0;
        rst_i = 1'b1; #10;
        rst_i = 1'b0; #20;

        // Sending commands:
        
        // Power on
        cmd_i = 8'h7F;  // POWER ON/OFF
        valid_i = 1'b1; #20;
        cmd_i = 8'h00;  // None button pressed
        valid_i = 1'b0; #20;

        // changing channels
        cmd_i = 8'hC7;  // CH-
        valid_i = 1'b1; #20;
        cmd_i = 8'h00;  // None button pressed
        valid_i = 1'b0; #20; #100;

        cmd_i = 8'hC7;  // CH-
        valid_i = 1'b1; #20;
        cmd_i = 8'h00;  // None button pressed
        valid_i = 1'b0; #20;

        cmd_i = 8'hC7;  // CH-
        valid_i = 1'b1; #20;
        cmd_i = 8'h00;  // None button pressed
        valid_i = 1'b0; #20;

        // cmd_i = 8'hE7;  // CH+
        // valid_i = 1'b1; #40;

        // cmd_i = 8'hE7;  // CH+
        // valid_i = 1'b1; #40;

        // cmd_i = 8'hE7;  // CH+
        // valid_i = 1'b1; #40;

        // cmd_i = 8'hE7;  // CH+
        // valid_i = 1'b1; #40;

        // cmd_i = 8'hE7;  // CH+
        // valid_i = 1'b1; #40;

        // // Power off
        // cmd_i = 8'h7F;  // POWER ON/OFF
        // valid_i = 1'b1; #40;

        // // changing volume
        // cmd_i = 8'hF7;  // VOL-
        // valid_i = 1'b1; #40;

        // // Power on
        // cmd_i = 8'h7F;  // POWER ON/OFF
        // valid_i = 1'b1; #40;

        // // changing volume
        // cmd_i = 8'hF7;  // VOL-
        // valid_i = 1'b1; #40;

        // cmd_i = 8'hF7;  // VOL-
        // valid_i = 1'b1; #40;

        // cmd_i = 8'hF7;  // VOL-
        // valid_i = 1'b1; #40;

        // cmd_i = 8'hCF;  // VOL+
        // valid_i = 1'b1; #40;

        // cmd_i = 8'hCF;  // VOL+
        // valid_i = 1'b1; #40;

        // #9000000; // 9ms

        // cmd_i = 8'hCF;  // VOL+
        // valid_i = 1'b1; #40;

        // cmd_i = 8'hCF;  // VOL+
        // valid_i = 1'b1; #40;

        // cmd_i = 8'hCF;  // VOL+
        // valid_i = 1'b1; #40;

        // cmd_i = 8'h5F;  // OK/PLAY/PAUSE
        // valid_i = 1'b1; #40;

        // cmd_i = 8'hAF;  // MENU
        // valid_i = 1'b1; #40;

        // 24*20 = 480ns
    end
endmodule
