
module nec_demodulator (
    input clk_i,                // clock 50MHz
    input rst_i,
    input ir_i,                 // Infra-Red input signal
    output [7:0] addr_code_o,
    output [7:0] cmd_code_o,
    output fail_o,
    output valid_o
);

    // States:
    localparam IDLE            = 3'd0,
               PREAMBLE_PULSE  = 3'd1,
               PREAMBLE_SPACE  = 3'd2,
               RECEIVING_ADDR  = 3'd3,
               RECEIVING_CMD   = 3'd4,
               DONE            = 3'd5;
    
    localparam BASE_TIME = 15'd28124;
    localparam HALF_BASE_TIME = 15'd14061;
    
    reg [2:0] state;

    // output regs
    reg [7:0] addr_code_o_, cmd_code_o_;
    reg fail_o_, valid_o_;

    // internal signals
    wire ir_rising;
    wire ir_falling;
    wire ir_debounce;

    reg half_time_flag;
    reg [14:0] base_count;         // 0 to 28124 when half_time_flag = 0
    reg [4:0] bit_count;
    reg [15:0] sr_start_pulse;
    reg sample_pulse;
    // reg [3:0] sr_decode_bit; // 0: 0001; 1: 0111 (inverted logic)
    reg [15:0] sr_address, sr_cmd;

    edge_event edge_event_inst(
        .clk(clk_i),
        .rst(1'b0), 
        .signal_i(ir_i),
        .signal_rising(ir_rising),
        .signal_falling(ir_falling),
        .ir_debounce(ir_debounce)
    );

    always @(posedge clk_i) begin
        if (ir_rising || ir_falling) begin
            half_time_flag <= 1;
            base_count <= 0;
            sample_pulse <= 0;
        end else if (half_time_flag && base_count == HALF_BASE_TIME) begin
            half_time_flag <= 0;
            base_count <= 0;
            sample_pulse <= 1;
        end else if (!half_time_flag && base_count == BASE_TIME) begin
            half_time_flag <= 0;
            base_count <= 0;
            sample_pulse <= 1;
        end else begin
            base_count <= base_count + 1;
            sample_pulse <= 0;
        end
    end

    always @(posedge clk_i) begin
        if (rst_i)
            sr_start_pulse <= 0;
        else if (sample_pulse)
            sr_start_pulse <= {sr_start_pulse[14:0], ir_debounce};
    end

    always @(posedge clk_i) begin

        if (rst_i) begin
            state <= IDLE;
            valid_o_ <= 0;
            fail_o_ <= 0;
            addr_code_o_ <= 0;
            cmd_code_o_ <= 0;
            half_time_flag <= 0;
            bit_count <= 0;
            sr_address <= 0;
            sr_cmd <= 0;
        end else begin
            case (state)
                IDLE: begin
                    sr_address <= 0;
                    sr_cmd <= 0;
                    if (ir_falling) begin
                        half_time_flag <= 1;
                        state <= PREAMBLE_PULSE;
                    end
                end
                PREAMBLE_PULSE: begin // 9ms pulse
                    valid_o_ <= 0;
                    if (ir_rising) begin
                        if (sr_start_pulse == 16'h0000) begin
                            state <= PREAMBLE_SPACE;
                        end else begin
                            fail_o_ <= 1;
                            state <= IDLE;
                        end
                    end
                end
                PREAMBLE_SPACE: begin // 4.5ms space
                    if (ir_falling) begin
                        if (sr_start_pulse[7:0] == 8'hFF) begin
                            state <= RECEIVING_ADDR;
                        end else begin
                            fail_o_ <= 1;
                            state <= IDLE;
                        end
                    end
                end
                RECEIVING_ADDR: begin
                    if (ir_falling) begin
                        if (sr_start_pulse[3:0] == 4'd7) begin
                            sr_address <= {sr_address[14:0], 1'b1};
                            bit_count <= bit_count + 1;
                        end else if(sr_start_pulse[1:0] == 2'd1) begin
                            sr_address <= {sr_address[14:0], 1'b0};
                            bit_count <= bit_count + 1;
                        end  else begin
                            fail_o_ <= 1;
                            state <= IDLE;
                        end
                    end
                    if (bit_count[4]) begin
                        bit_count <= 0;
                        state <= RECEIVING_CMD;
                    end
                end
                RECEIVING_CMD: begin
                    if (ir_falling) begin
                        if (sr_start_pulse[3:0] == 4'd7) begin
                            sr_cmd <= {sr_cmd[14:0], 1'b1};
                            bit_count <= bit_count + 1;
                        end else if(sr_start_pulse[1:0] == 2'd1) begin
                            sr_cmd <= {sr_cmd[14:0], 1'b0};
                            bit_count <= bit_count + 1;
                        end  else begin
                            fail_o_ <= 1;
                            state <= IDLE;
                        end
                    end
                    if (bit_count[4]) begin
                        bit_count <= 0;
                        state <= DONE;
                    end
                end
                DONE: begin
                    if (ir_rising) begin
                        if (sr_cmd[15:8] == ~sr_cmd[7:0]) begin
                            cmd_code_o_ = sr_cmd[7:0];
                            addr_code_o_ = sr_address[7:0];
                            valid_o_ <= 1;
                            state <= IDLE;
                        end else begin
                            fail_o_ <= 1;
                            state <= IDLE;
                        end
                    end
                end
                default: state <= IDLE;
            endcase
        end
    end

    // output assingments
    assign addr_code_o = addr_code_o_;
    assign cmd_code_o = cmd_code_o_;
    assign fail_o = fail_o_;
    assign valid_o = valid_o_;
endmodule

module edge_event (
    input clk, rst,
    input signal_i,
    output signal_rising,
    output signal_falling,
    output ir_debounce
);
    reg signal_rising_, signal_falling_, ir_debounce_;
    reg Q1, Q2, Q3;

    always @(posedge clk) begin
        if (rst) begin
            signal_rising_ <= 0;
            signal_falling_ <= 0;
            Q1 <= 0;
            Q2 <= 0;
            Q3 <= 0;
        end else begin
            Q1 <= signal_i;
            Q2 <= Q1;
            Q3 <= Q2;
        end
        signal_rising_ <= ~Q3 & Q2;
        signal_falling_ <= Q3 & ~Q2;
        ir_debounce_ <= Q3;
    end
    assign signal_rising = signal_rising_;
    assign signal_falling = signal_falling_;
    assign ir_debounce = ir_debounce_;
endmodule
