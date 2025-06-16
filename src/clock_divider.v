module clock_divider #(
    parameter FREQUENCY_IN = 50_000_000,
    parameter FREQUENCY_OUT = 37_990
) (
    input clk_i,
    input rst_i,
    output clk_pulse_o
);

    localparam integer CLK_COUNT_VAL = (FREQUENCY_IN/FREQUENCY_OUT) - 1;
    localparam COUNTER_SIZE = $clog2(CLK_COUNT_VAL);

    reg [COUNTER_SIZE-1:0] counter;
    reg clk_pulse_o_;

    always @(posedge clk_i) begin
        if (rst_i) begin
            counter <= 0;
            clk_pulse_o_ <= 0;
        end else if (counter < CLK_COUNT_VAL) begin
            counter <= counter + 1;
            clk_pulse_o_ <= 0;
        end else begin
            counter <= 0;
            clk_pulse_o_ <= 1;
        end
    end

    assign clk_pulse_o = clk_pulse_o_;
endmodule