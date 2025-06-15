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

    task get_cmd(input [7:0] cmd);
        begin
            cmd_i = cmd;  // POWER ON/OFF
            valid_i = 1'b1; #20;
            valid_i = 1'b0; #60;
        end
    endtask

    initial begin
        // Initializantion
        cmd_i = 8'h00;  // None button pressed
        valid_i = 1'b0;
        rst_i = 1'b1; #10;
        rst_i = 1'b0; #20;
        
        // Power on
        get_cmd(8'h7F);

        // changing channels
        get_cmd(8'hC7); // CH-
        get_cmd(8'hC7);

        get_cmd(8'hE7); // CH+
        get_cmd(8'hE7);
        get_cmd(8'hE7);
        get_cmd(8'hE7);
        get_cmd(8'hE7);
        get_cmd(8'hE7);

        // Power off
        get_cmd(8'h7F);

        // changing volume
        get_cmd(8'hF7); // VOL-

        // Power on
        get_cmd(8'h7F);

        // changing volume
        get_cmd(8'hF7); // VOL-
        #320;
        get_cmd(8'hCF); // VOL+
        #120;
        get_cmd(8'hCF);
        #90;
        get_cmd(8'hCF);
        #40;
        get_cmd(8'hCF);
        #40;
        get_cmd(8'hCF);
        #40;
        get_cmd(8'hCF);
        #40;
        get_cmd(8'hCF);
        #320;

        get_cmd(8'h5F); // OK/PLAY/PAUSE
        #320;
    end
endmodule
