module nec_demodulator (
    input  logic        clk_i,
    input  logic        rst_i,
    input  logic        ir_i,
    output logic [7:0] address,
    output logic [7:0] data,
    output logic valid
);

    typedef enum logic [2:0] {
        IDLE  = 3'b000,
        PULSE = 3'b001,
        SPACE = 3'b010,
        DATA  = 3'b011, 
        DONE  = 3'b100
    } state_t;

    //parameter int SIMULATION_FACTOR;

    `ifdef SIMULATION
        localparam int SIMULATION_FACTOR = 1000;
    `else
        localparam int SIMULATION_FACTOR = 1; // Default
    `endif

    // Timing parameters (50MHz clock, 1 cycle = 20ns)
    localparam logic [31:0] LEADER_PULSE_MIN = 32'd400_000 / SIMULATION_FACTOR; //  8ms / factor
    localparam logic [31:0] LEADER_PULSE_MAX = 32'd500_000 / SIMULATION_FACTOR; //  10ms / factor
    localparam logic [31:0] LEADER_SPACE_MIN = 32'd200_000 / SIMULATION_FACTOR; //  4ms / factor
    localparam logic [31:0] LEADER_SPACE_MAX = 32'd275_000 / SIMULATION_FACTOR; //  5.5ms / factor
    localparam logic [31:0] BIT_0_SPACE_MAX  = 32'd40_000  / SIMULATION_FACTOR; //  800us / factor
    localparam logic [31:0] BIT_1_SPACE_MAX  = 32'd70_000  / SIMULATION_FACTOR; // 1400us / factor

    state_t       state;
    logic [31:0]  counter;           // Time since last edge
    logic         last_ir_synced;           // For edge detection
    logic [31:0]  shift_reg;         // Received data buffer
    logic [5:0]   bit_count;         // Received bits counter (0-31)
    logic         waiting_for_rising; // Waiting for pulse rising edge


    // Synchronizer Logic
    logic ir_i_synced_q1;
    logic ir_i_synced_q2; 

    always_ff @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            ir_i_synced_q1 <= 1'b0;
            ir_i_synced_q2 <= 1'b0;
        end else begin
            ir_i_synced_q1 <= ir_i;       
            ir_i_synced_q2 <= ir_i_synced_q1; 
        end
    end


    // Edge detector and counter
    always_ff @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            last_ir_synced <= 1'b1; // IR idle high
            counter <= '0;
        end else begin
            last_ir_synced <= ir_i_synced_q2;
            counter <= (last_ir_synced != ir_i_synced_q2) ? '0 : counter + 1;
        end
    end

    // Main state machine
    always_ff @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            state              <= IDLE;
            shift_reg          <= '0;
            bit_count          <= '0;
            waiting_for_rising <= 1'b0;
            address            <= '0;
            data               <= '0;
        end else begin
            unique case (state)
                IDLE: begin
                    // Wait for falling edge (start of leader pulse)
                    if (last_ir_synced && !ir_i_synced_q2) begin
                        state <= PULSE;
                    end
                    // Reset counters
                    bit_count          <= '0;
                    shift_reg          <= '0;
                    waiting_for_rising <= 1'b0;
                    address <= '0; 
                    data <= '0;
                end

                PULSE: begin
                    // Rising edge ends pulse measurement
                    if (!last_ir_synced && ir_i_synced_q2) begin
                        if (counter inside {[LEADER_PULSE_MIN:LEADER_PULSE_MAX]}) begin
                            state <= SPACE;
                        end else begin
                            state <= IDLE;  // Invalid pulse
                        end
                    end
                end

                SPACE: begin
                    // Falling edge ends space measurement
                    if (last_ir_synced && !ir_i_synced_q2) begin
                        if (counter inside {[LEADER_SPACE_MIN:LEADER_SPACE_MAX]}) begin
                            state <= DATA;
                            waiting_for_rising <= 1'b0; // Prepare for first data pulse
                        end else begin
                            state <= IDLE;  // Invalid space
                        end
                    end
                end

                DATA: begin
                    if (waiting_for_rising) begin
                        // Rising edge ends pulse (always ~560us)
                        if (!last_ir_synced && ir_i_synced_q2) begin
                            waiting_for_rising <= 1'b0;
                        end
                    end else begin
                        // Falling edge ends space period
                        if (last_ir_synced && !ir_i_synced_q2) begin
                            logic current_bit;

                            // Determine bit value from space duration
                            if (counter < BIT_0_SPACE_MAX) begin
                                current_bit = 1'b0;
                            end else if (counter inside {[BIT_0_SPACE_MAX:BIT_1_SPACE_MAX]}) begin
                                current_bit = 1'b1;
                            end else begin
                                state <= IDLE;  // Invalid bit duration
                                address <= '0;
                                data    <= '0;
                                current_bit = 1'b0; 
                            end

                            if (state == DATA) begin  
                                // Shift new bit into LSB position
                                shift_reg <= {shift_reg[30:0], current_bit};
                                if (bit_count == 31) begin
                                    state <=  DONE;  
                                    shift_reg = {shift_reg[30:0], current_bit};
                                end else begin
                                    bit_count <= bit_count + 1;
                                    waiting_for_rising <= 1'b1; // Wait for pulse end
                                end
                            end
                        end
                    end
                end

                DONE: begin 
                    if ((shift_reg[31:24] == ~shift_reg[23:16]) &&
                        (shift_reg[15:8]  == ~shift_reg[7:0])) begin
                        valid <= 1; 
                        address <= {
                            shift_reg[24], shift_reg[25],
                            shift_reg[26], shift_reg[27],
                            shift_reg[28], shift_reg[29],
                            shift_reg[30], shift_reg[31]
                        };
                        data <= {
                            shift_reg[8], shift_reg[9],
                            shift_reg[10], shift_reg[11],
                            shift_reg[12], shift_reg[13],
                            shift_reg[14], shift_reg[15]
                        };
                    end else begin
                        address <= '0;
                        data    <= '0;
                        valid <= 0;
                    end
                    state <= IDLE;

                end 

                default: state <= IDLE;
            endcase
        end
    end

    // Use to check the waves 
    initial begin
        $dumpfile("nec_demodulator.vcd");
        $dumpvars(0, nec_demodulator);
    end

endmodule    assign signal_falling = signal_falling_;
    assign ir_debounce = ir_debounce_;
endmodule
