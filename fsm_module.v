module fsm_module (
    input  wire        clk,
    input  wire        rst,
    input  wire [3:0]  digit_in,
    input  wire        key_valid,
    input  wire        enter,
    input  wire        change,
    input  wire        auto_open,
    output reg  [2:0]  state,
    output reg         unlock_on,
    output reg         alarm_on,
    output reg         key_led,
    output reg  [3:0]  input_count_led
);

    localparam IDLE   = 3'd0;
    localparam INPUT  = 3'd1;
    localparam CHECK  = 3'd2;
    localparam UNLOCK = 3'd3;
    localparam ALARM  = 3'd4;
    localparam CHANGE = 3'd5;

    reg [15:0] input_buffer;
    reg [15:0] saved_password;
    reg [1:0]  digit_count;   // mod-4 circular counter
    reg [1:0]  fail_count;

    reg key_prev, enter_prev, change_prev, auto_open_prev;

    wire key_pulse       = key_valid & ~key_prev;
    wire enter_pulse     = enter     & ~enter_prev;
    wire change_pulse    = change    & ~change_prev;
    wire auto_open_pulse = auto_open & ~auto_open_prev;

    // Thermometer: shift left until full, then wrap to 0001 (§6-2)
    // Called after the digit_count increment has already occurred
    function [3:0] next_led;
        input [3:0] cur;
        begin
            if (cur == 4'b1111)
                next_led = 4'b0001;   // 5th+ digit wraps
            else
                next_led = {cur[2:0], 1'b1};
        end
    endfunction

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            key_prev       <= 1'b0;
            enter_prev     <= 1'b0;
            change_prev    <= 1'b0;
            auto_open_prev <= 1'b0;
        end else begin
            key_prev       <= key_valid;
            enter_prev     <= enter;
            change_prev    <= change;
            auto_open_prev <= auto_open;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state           <= IDLE;
            unlock_on       <= 1'b0;
            alarm_on        <= 1'b0;
            key_led         <= 1'b0;
            input_count_led <= 4'b0000;
            input_buffer    <= 16'h0000;
            saved_password  <= 16'h1234;
            digit_count     <= 2'd0;
            fail_count      <= 2'd0;
        end else begin
            key_led <= 1'b0;

            case (state)
                IDLE: begin
                    unlock_on       <= 1'b0;
                    alarm_on        <= 1'b0;
                    input_buffer    <= 16'h0000;
                    digit_count     <= 2'd0;
                    input_count_led <= 4'b0000;

                    if (auto_open_pulse) begin
                        state     <= UNLOCK;
                        unlock_on <= 1'b1;
                    end else if (key_pulse) begin
                        state           <= INPUT;
                        input_buffer    <= {12'h000, digit_in};
                        digit_count     <= 2'd1;
                        input_count_led <= 4'b0001;
                        key_led         <= 1'b1;
                    end
                end

                INPUT: begin
                    if (auto_open_pulse) begin
                        state           <= UNLOCK;
                        unlock_on       <= 1'b1;
                        input_buffer    <= 16'h0000;
                        digit_count     <= 2'd0;
                        input_count_led <= 4'b0000;
                    end else if (key_pulse) begin
                        input_buffer    <= {input_buffer[11:0], digit_in};
                        digit_count     <= digit_count + 1'b1;
                        input_count_led <= next_led(input_count_led);
                        key_led         <= 1'b1;
                    end else if (enter_pulse) begin
                        state <= CHECK;
                    end
                end

                CHECK: begin
                    if (input_buffer == saved_password) begin
                        state      <= UNLOCK;
                        unlock_on  <= 1'b1;
                        fail_count <= 2'd0;
                    end else if (fail_count == 2'd2) begin
                        state    <= ALARM;
                        alarm_on <= 1'b1;
                    end else begin
                        state      <= IDLE;
                        fail_count <= fail_count + 1'b1;
                    end
                end

                UNLOCK: begin
                    if (change_pulse) begin
                        state           <= CHANGE;
                        input_buffer    <= 16'h0000;
                        digit_count     <= 2'd0;
                        input_count_led <= 4'b0000;
                    end else if (enter_pulse) begin
                        state     <= IDLE;
                        unlock_on <= 1'b0;
                    end
                end

                ALARM: begin
                    // rst only (handled by async reset)
                end

                CHANGE: begin
                    if (key_pulse) begin
                        input_buffer    <= {input_buffer[11:0], digit_in};
                        digit_count     <= digit_count + 1'b1;
                        input_count_led <= next_led(input_count_led);
                        key_led         <= 1'b1;
                    end else if (enter_pulse) begin
                        saved_password  <= input_buffer;
                        state           <= IDLE;
                        unlock_on       <= 1'b0;
                        input_buffer    <= 16'h0000;
                        digit_count     <= 2'd0;
                        input_count_led <= 4'b0000;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
