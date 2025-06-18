`timescale 1ns/1ps

module top_tb ();
    reg clk_50M_i;
    reg rst_i;
    reg ir_i;
    wire clk_38k_o;
    wire data_o;
    wire [3:0] digit_o;

    reg [31:0] data;

    top  top_inst (
        .clk_50M_i(clk_50M_i),
        .rst_i(rst_i),
        .ir_i(ir_i),
        .clk_38k_o(clk_38k_o),
        .data_o(data_o),
        .digit_o(digit_o)
    );

    initial begin
        clk_50M_i = 0;
        forever #10 clk_50M_i = ~clk_50M_i; // Period T = 20ns
    end

    task pulse_low(input integer cycles);
        integer i;
        begin
            for (i = 0; i < cycles; i = i + 1) begin
                @(posedge clk_50M_i)
                    ir_i = 0;
            end
        end
    endtask

    task pulse_high(input integer cycles);
        integer i;
        begin
            for (i = 0; i < cycles; i = i + 1) begin
                @(posedge clk_50M_i)
                    ir_i = 1;
            end
        end
    endtask

    task send_bit(input b);
        begin
            pulse_low(1);
            if (b) begin // 1
                pulse_low(28125);
                pulse_high(3*28125);
            end else begin // 0
                pulse_low(28125);
                pulse_high(28125);
            end
        end
    endtask

    task send_command(input [31:0] data);
        integer i;

        begin
            // 9ms start pulse and 4.5ms space
            pulse_low(16*28125);
            pulse_high(8*28125);

            //sending MSB first
            for (i = 31; i >= 0; i = i - 1) begin
                send_bit(data[i]);
            end

            // final pulse
            pulse_low(28125);
            pulse_high(28125);
        end
    endtask

    initial begin
        // Initializing
        ir_i = 1'b1;
        rst_i = 1'b1;
        #20;
        rst_i = 1'b0;
        #100;

        // POWER ON
        data = 32'h004D_807F;
        send_command(data);
        ir_i = 1'b1;

        #1_000_000;

        // VOL+
        data = 32'h004D_30CF;
        send_command(data);
        ir_i = 1'b1;
        
        #1_000_000;
        // VOL-
        data = 32'h004D_08F7;
        send_command(data);
        #1_000_000;
        // 210ms
    end
endmodule