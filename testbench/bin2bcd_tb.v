`timescale 1ns/1ps

module bin2bcd_tb();

    reg  [7:0] bin;
    wire [11:0] bcd;

    integer i;

    bin2bcd dut (
        .bin(bin),
        .bcd(bcd)
    );

    initial begin
        bin = 8'd0;
        for (i = 0; i < 256; i = i + 1) begin
            bin = i[7:0];
            #10;
        end
        #10;
    end

endmodule
