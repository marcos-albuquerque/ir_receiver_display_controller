
module nec_decoder (
    input clk_i,
    input rst_i,
    input ir_i,
    output [7:0] addr_code_o,
    output [7:0] cmd_code_o,
    output fail_o,
    output done_o
);
    // the 9ms preamble pulse should occur between this range
    localparam TICK_8ms = 19'd400_000;
    localparam TICK_11ms = 19'd520_000;

    // the 4.5ms preamble space should occur between this range
    localparam TICK3ms = 19'd150_000;
    localparam TICK5o5ms = 19'd275_000;

    // the 562.5ms base pulse should occur between this range
    localparam TICK450us = 19'd22_500;
    localparam TICK650us = 19'd32_500;

    // bit 0
    localparam TICK1ms = 19'd50_000;
    localparam TICK1o25ms = 19'd62_500;

    // bit 1
    localparam TICK_2o1ms = 19'd10_5000;
    localparam TICK_2o4ms = 19'd12_0000;

    // States:
    localparam IDLE            = 3'd0,
               PREAMBLE_PULSE  = 3'd1,
               PREAMBLE_SPACE  = 3'd2,
               RECEIVING_PULSE = 3'd3,
               RECEIVING_SPACE = 3'd4,
               DONE            = 3'd5;

    // Difining internal signal of timing
    reg [18:0] timer;       // enought to count to 450000 cycles (max=524287)
    reg [5:0] bit_count;      // to count the amount of bits received
    reg [31:0] shift_reg; // rxbuffer
    reg [2:0] current_state, next_state;

    // These signs will be used to keep track of edges of the IR input
    reg ir_prev;                            // previous value of ir_i
    wire ir_falling, ir_rising;
    assign ir_falling = (ir_prev == 1 && ir_i == 0);
    assign ir_rising  = (ir_prev == 0 && ir_i == 1);

    // outputs regs
    reg [7:0] addr_code_o_;
    reg [7:0] cmd_code_o_;
    reg fail_o_;
    reg done_o_;

    always @(posedge clk_i) begin
        if (rst_i)
            ir_prev <= 1;
        else
            ir_prev <= ir_i;
    end

    always @(posedge clk_i) begin
        if (rst_i) begin
            current_state <= IDLE;
            timer <= 0;
            bit_count <= 0;
            shift_reg <= 0;
            addr_code_o_ <= 0;
            cmd_code_o_ <= 0;
            done_o_ <= 0;
        end else begin
            case (current_state)
                IDLE: begin
                    if (ir_falling) begin
                        timer <= 1;
                        next_state <= PREAMBLE_PULSE;
                    end else
                        next_state <= IDLE;
                end
                PREAMBLE_PULSE: begin // 9ms pulse
                    if (ir_falling) begin
                        timer <= timer + 1;
                    end else if(timer >= TICK_8ms && timer <= TICK_11ms) begin
                        timer <= 1;
                        next_state <= PREAMBLE_SPACE;
                    end else
                        next_state <= IDLE; // timeout error
                end
                PREAMBLE_SPACE: begin // 4.5ms space
                    if (ir_rising) begin
                        timer <= timer + 1;
                    end else if (timer >= TICK3ms && timer <= TICK5o5ms) begin
                        timer <= 1;
                        next_state <= RECEIVING_PULSE;
                    end else
                        next_state <= IDLE; // timeout error
                        fail_o_ = 1;
                end
                RECEIVING_PULSE: begin
                    if (ir_falling) begin
                        timer <= timer + 1;
                    end else if (timer >= TICK450us && timer <= TICK650us) begin
                        timer <= 1;
                        next_state <= RECEIVING_SPACE;
                    end else
                        next_state <= IDLE;
                end
                RECEIVING_SPACE: begin
                    if (ir_rising) begin
                        timer <= timer + 1;
                    end else if (timer >= TICK1ms && timer <= TICK1o25ms) begin // 0
                        shift_reg <= {1'b0, shift_reg[31:1]};
                        bit_count = bit_count + 1;
                        next_state <= RECEIVING_PULSE;
                        timer <= 1;
                    end else if (timer >= TICK_2o1ms && timer <= TICK_2o4ms) begin // 1
                        shift_reg <= {1'b1, shift_reg[31:1]};
                        bit_count = bit_count + 1;
                        next_state <= RECEIVING_PULSE;
                        timer <= 1;
                    end else
                        next_state <= IDLE;
                    
                    if (bit_count == 31) begin
                        next_state <= DONE;
                    end
                end
                DONE: begin
                    addr_code_o_ <= shift_reg[31:15];
                    cmd_code_o_ <= shift_reg[15:0];
                    done_o_ <= 1;
                    next_state <= IDLE;
                end
                default: next_state <= IDLE;
            endcase
        end
    end

    // output assingments
    assign addr_code_o = addr_code_o_;
    assign cmd_code_o = cmd_code_o_;
    assign fail_o = fail_o_;
    assign done_o = done_o_;
endmodule
