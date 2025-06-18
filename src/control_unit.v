
module control_unit (
    input clk_i,
    input rst_i,
    input valid_i,
    input [7:0] cmd_i,
    output stand_by_o,
    output mode_o,
    output ch_vol_o,
    output [7:0] cmd_o,
    output [7:0] num_o
);

    // localparam TIME_5s = 28'd250_000_000;
    localparam TIME_5s = 28'd15; // only for simulation

    localparam STAND_BY    = 3'd0,
               SHOW_CH     = 3'd1,
               PROCESS_CMD = 3'd2,
               SHOW_VOL    = 3'd3,
               SHOW_CMD    = 3'd4;
    
    localparam POWER_ON_OFF = 8'h7F,
               CH_DOWN      = 8'hC7,
               CH_UP        = 8'hE7,
               VOL_DOWN     = 8'hF7,
               VOL_UP       = 8'hCF;

    reg [2:0] state;

    // output regs
    reg stand_by_o_;
    reg mode_o_;
    reg ch_vol_o_;
    reg [7:0] cmd_o_;
    reg [7:0] num_o_;

    // internal regs
    reg [5:0] num_ch; // 1 to 63
    reg [6:0] num_vol; // 0 to 100
    reg valid;

    // timer reg
    reg [27:0] timer_5s; // enought to count up to (5s)

    always @(posedge clk_i) begin
        if (rst_i) begin
            timer_5s <= 0;
        end else if(state == SHOW_VOL || state == SHOW_CMD) begin
            timer_5s <= timer_5s + 1;
        end
    end

    always @(posedge clk_i) begin
        if (state == STAND_BY) begin
            stand_by_o_ <= 1;
        end else if (state == SHOW_CH) begin
            mode_o_ <= 0;
            ch_vol_o_ <= 0; // channel
            num_o_ <= {2'b00, num_ch};
        end else if(state == SHOW_VOL) begin
            mode_o_ <= 0;
            ch_vol_o_ <= 1; // volume
            if (timer_5s == TIME_5s) begin
                timer_5s <= 0;
                state <= SHOW_CH;
            end else begin
                num_o_ <= {1'b0, num_vol};
            end
        end else if(state == SHOW_CMD) begin
            mode_o_ <= 1;
            if (timer_5s == TIME_5s) begin
                timer_5s <= 0;
                mode_o_ <= 0;
                state <= SHOW_CH;
            end else begin
                cmd_o_ <= cmd_i;
            end
        end else if(state == PROCESS_CMD) begin
            timer_5s <= 0;
        end
    end

    always @(posedge clk_i) begin
        if (valid_i) begin
            valid <= 1;
        end
        if (rst_i) begin
            state <= STAND_BY;
            stand_by_o_ <= 1;
            mode_o_ <= 0;
            ch_vol_o_ <= 0;
            cmd_o_ <= 0;
            num_o_ <= 0;
            num_ch <= 1;
            num_vol <= 0;
            valid <= 0;
        end else if(valid) begin
            case (state)
                STAND_BY: begin // state0
                    if (cmd_i == POWER_ON_OFF) begin
                        stand_by_o_ <= 0;
                        valid <= 0;
                        state <= SHOW_CH;
                    end
                end
                SHOW_CH: begin // state1
                    // if (cmd_i != 0) begin
                    state <= PROCESS_CMD;
                    // end
                end
                PROCESS_CMD: begin // state2
                    timer_5s <= 0;
                    valid <= 0;
                    case (cmd_i)
                        POWER_ON_OFF: state <= STAND_BY; // POWER ON/OF
                        CH_DOWN: begin
                            if (num_ch > 1)
                                num_ch <= num_ch - 1;
                            else
                                num_ch <= 63;
                            state <= SHOW_CH;
                        end
                        CH_UP: begin
                            if (num_ch < 63)
                                num_ch <= num_ch + 1;
                            else
                                num_ch <= 1;
                            state <= SHOW_CH;
                        end
                        VOL_DOWN: begin
                            if (num_vol > 0) begin
                                num_vol <= num_vol - 1;
                            end
                            state <= SHOW_VOL;
                        end
                        VOL_UP: begin
                            if (num_vol < 100) begin
                                num_vol <= num_vol + 1;
                            end
                            state <= SHOW_VOL;
                        end
                        default: begin
                            state <= SHOW_CMD;
                        end
                    endcase
                end
                SHOW_VOL: begin // state3
                    if (cmd_i != 0)
                        state <= PROCESS_CMD;
                end
                SHOW_CMD: begin // state4          
                    if (cmd_i != 0)
                        state <= PROCESS_CMD;
                end
                default: state <= STAND_BY;
            endcase
        end
    end
    assign stand_by_o = stand_by_o_;
    assign mode_o = mode_o_;
    assign ch_vol_o = ch_vol_o_;
    assign cmd_o = cmd_o_;
    assign num_o = num_o_;
endmodule