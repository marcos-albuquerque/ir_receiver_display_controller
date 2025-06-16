module encoder (
    input mode_i,                      // 1: cmd; 0: ch/vol
    input ch_vol_i,                    // 1: vol; 0: ch
    input [7:0] cmd_i,
    input [7:0] num_i,                 // channel/volume value
    output [27:0] digit_values_o
);

    wire [11:0] bcd_digit;
    wire [6:0] seg1, seg2, seg3, seg4;
    reg [3:0] v_or_c;

    always @(*) begin
        v_or_c <= 4'd0;
        if (mode_i == 0) begin
            if (ch_vol_i) begin // vol
                v_or_c <= 14;
            end else begin  // ch
                v_or_c <= 12;
            end
        end
    end

    bin2bcd  bin2bcd_inst (
        .bin(mode_i ? cmd_i : num_i),
        .bcd(bcd_digit)
    );

    to_7segment  to_7segment_inst1 ( // LSD
        .digit(bcd_digit[3:0]),
        .segments(seg1)
    );

    to_7segment  to_7segment_inst2 (
        .digit(bcd_digit[7:4]),
        .segments(seg2)
    );

    to_7segment  to_7segment_inst3 (
        .digit(mode_i ? ~bcd_digit[3:0]: bcd_digit[11:8]),
        .segments(seg3)
    );
    
    to_7segment  to_7segment_inst4 ( // MSD
        .digit(mode_i ? ~bcd_digit[7:4] : v_or_c),
        .segments(seg4)
    );

    assign digit_values_o = {seg4, seg3, seg2, seg1};

endmodule