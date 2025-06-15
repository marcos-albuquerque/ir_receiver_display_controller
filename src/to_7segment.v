module to_7segment(
    input [3:0] digit,
    output [6:0] segments
);

    reg [6:0] segments_;

    always @(*)
        case(digit)
            0: segments_ = 7'b111_1110;
            1: segments_ = 7'b011_0000;
            2: segments_ = 7'b110_1101;
            3: segments_ = 7'b111_1001;
            4: segments_ = 7'b011_0011;
            5: segments_ = 7'b101_1011;
            6: segments_ = 7'b101_1111;
            8: segments_ = 7'b111_0000;
            9: segments_ = 7'b111_1111;
            10: segments_ = 7'b111_0111; // A
            11: segments_ = 7'b001_1111; // B
            12: segments_ = 7'b100_1110; // C
            13: segments_ = 7'b011_1101; // D 
            14: segments_ = 7'b011_1110; // E -> WORKS AS V
            15: segments_ = 7'b100_0111; // F
            default: segments_ = 8'b0000000;
    endcase

    assign segments = segments_;

endmodule