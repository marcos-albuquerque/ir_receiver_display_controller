module display_driver (
    input clk_50M_i,
    input clk_38k_i,
    input rst_i,
    input [27:0] digit_values_i,
    // output clk_38k_o,
    output data_o,
    output [3:0] digit_o
);
    localparam DIG1 = 2'b00;
    localparam DIG2 = 2'b01;
    localparam DIG3 = 2'b10;
    localparam DIG4 = 2'b11;

    // Draft...
    wire [7:0] digit1 = {1'b0, digit_values_i[6:0]};
    wire [7:0] digit2 = {1'b0, digit_values_i[13:7]};
    wire [7:0] digit3 = {1'b0, digit_values_i[20:14]};
    wire [7:0] digit4 = {1'b0, digit_values_i[27:21]};
    // ==============================================


    // interleave digits
    reg [2:0] timer_1; // timer to send bits
    reg [2:0] timer_2; // timer used for delay

    reg [7:0] reg_data;
    
    // reg [7:0] data_in;
    
    reg load_n;
    reg delay;      // 0: no delay; 1: timer delay
    reg [1:0] digit_idx; // 00: 1, 01: 2, 10: 3, 11: 4
    
    
    // assign data_out = reg_data[0];
    // output reg
    reg data_o_;

    // timer
    always @(posedge clk_50M_i) begin
        if (rst_i) begin
            timer_1 <= 0;
            timer_2 <= 0;
            load_n <= 0;
            delay <= 0;
            digit_idx <= 0;
        end else if (clk_38k_i) begin
            if (timer_1 == 3'd7) begin
                timer_1 <= 0;
                delay <= ~delay;
                if (!delay) begin
                    digit_idx <= digit_idx + 1;
                end
            end else if(!delay) begin
                timer_1 <= timer_1 + 1;
            end

            if (timer_2 == 3'd7) begin
                timer_2 <= 0;
                delay <= ~delay;
            end else if(delay) begin
                timer_2 <= timer_2 + 1;
            end
        end
    end

    task shift(input [7:0] digit);
        begin
            if (!delay) begin
                if (!load_n) begin
                    reg_data <= digit;
                end else begin
                    data_o_ <= reg_data[0];
                    reg_data <= {1'b0, reg_data[7:1]};
                end
            end
        end
    endtask

    always @(posedge clk_50M_i) begin
        if (clk_38k_i) begin
            case (digit_idx)
                DIG1: begin
                    shift(digit1);
                end
                DIG2: begin
                    shift(digit2);
                end
                DIG3: begin
                    shift(digit3);
                end
                DIG4: begin
                    shift(digit4);
                end
            endcase
        end
    end

    // // PISO reg
    // always @(posedge clk_50M_i) begin
    //     if (clk_38k_i) begin
    //         if (!delay) begin
    //             if(!load_n)   reg_data <= data_in;
    //             else reg_data <= {1'b0, reg_data[7:1]};
    //         end
    //     end
    // end

    assign data_o = data_o_;

endmodule
