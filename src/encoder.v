module encoder (
    input mode_i,
    input ch_vol_i,
    input [7:0] cmd_i,
    input [7:0] num_i,
    output [27:0] digits_val_o
);

    reg [11:0] bcd_digit;
    reg [3:0] v_or_c;
    reg [6:0] seg1, seg2, seg3, seg4;

    always @(*) begin
        if (mode_i == 0) begin
            if (ch_vol_i) begin
                v_or_c <= 14;
            end else begin
                v_or_c <= 12;
            end
        end
    end

    bin2bcd  bin2bcd_inst (
        .bin(mode_i ? cmd_i : num_i),
        .bcd(bcd_digit)
    );

    to_7segment  to_7segment_inst1 (
        .digit(bcd_digit[3:0]),
        .segments(seg1)
    );

    to_7segment  to_7segment_inst2 (
        .digit(bcd_digit[7:4]),
        .segments(seg2)
    );

    to_7segment  to_7segment_inst3 (
        .digit(mode ? ~bcd_digit[3:0]: bcd_digit[11:8]),
        .segments(seg3)
    );
    
    to_7segment  to_7segment_inst4 (
        .digit(mode ? ~bcd_digit[7:4] :v_or_c),
        .segments(seg4)
    );

    assign digits_val_o = {seg4, seg3, seg2, seg1};

endmodule