`timescale 1ns / 1ps

module fsm_module_tb;

    reg        clk, rst;
    reg [3:0]  digit_in;
    reg        key_valid, enter, change, auto_open;

    wire [2:0] state;
    wire       unlock_on, alarm_on, key_led;
    wire [3:0] input_count_led;

    fsm_module dut (
        .clk            (clk),
        .rst            (rst),
        .digit_in       (digit_in),
        .key_valid      (key_valid),
        .enter          (enter),
        .change         (change),
        .auto_open      (auto_open),
        .state          (state),
        .unlock_on      (unlock_on),
        .alarm_on       (alarm_on),
        .key_led        (key_led),
        .input_count_led(input_count_led)
    );

    always #500 clk = ~clk; // 1 kHz

    // 1클럭 펄스 태스크
    task press_digit;
        input [3:0] d;
        begin
            digit_in  = d;
            key_valid = 1'b1;
            @(posedge clk); #1;
            key_valid = 1'b0;
            @(posedge clk); #1;
        end
    endtask

    task press_enter;
        begin
            enter = 1'b1;
            @(posedge clk); #1;
            enter = 1'b0;
            @(posedge clk); #1;
        end
    endtask

    task press_change;
        begin
            change = 1'b1;
            @(posedge clk); #1;
            change = 1'b0;
            @(posedge clk); #1;
        end
    endtask

    task press_auto_open;
        begin
            auto_open = 1'b1;
            @(posedge clk); #1;
            auto_open = 1'b0;
            @(posedge clk); #1;
        end
    endtask

    initial begin
        clk = 0; rst = 1; digit_in = 0;
        key_valid = 0; enter = 0; change = 0; auto_open = 0;
        @(posedge clk); #1;
        rst = 0;
        @(posedge clk); #1;

        $display("=== [1] 정상 비밀번호 입력 (1234) → UNLOCK ===");
        press_digit(4'd1);
        press_digit(4'd2);
        press_digit(4'd3);
        press_digit(4'd4);
        press_enter;
        #2; @(posedge clk);
        $display("state=%0d unlock_on=%b alarm_on=%b (expect UNLOCK=3, unlock=1)", state, unlock_on, alarm_on);

        $display("=== [2] UNLOCK → enter → IDLE(재잠금) ===");
        press_enter;
        $display("state=%0d unlock_on=%b (expect IDLE=0, unlock=0)", state, unlock_on);

        $display("=== [3] 틀린 비밀번호 3회 → ALARM ===");
        repeat (3) begin
            press_digit(4'd9); press_digit(4'd9); press_digit(4'd9); press_digit(4'd9);
            press_enter;
            #2; @(posedge clk);
            $display("state=%0d alarm_on=%b fail after attempt", state, alarm_on);
        end
        $display("state=%0d alarm_on=%b (expect ALARM=4, alarm=1)", state, alarm_on);

        $display("=== [4] ALARM → rst → IDLE ===");
        rst = 1; @(posedge clk); #1; rst = 0;
        $display("state=%0d alarm_on=%b (expect IDLE=0, alarm=0)", state, alarm_on);

        $display("=== [5] auto_open → UNLOCK ===");
        press_auto_open;
        $display("state=%0d unlock_on=%b (expect UNLOCK=3)", state, unlock_on);

        $display("=== [6] UNLOCK → change → CHANGE, 새 비번 5678 입력 후 저장 ===");
        press_change;
        $display("state=%0d (expect CHANGE=5)", state);
        press_digit(4'd5); press_digit(4'd6); press_digit(4'd7); press_digit(4'd8);
        press_enter;
        $display("state=%0d unlock_on=%b (expect IDLE=0)", state, unlock_on);

        $display("=== [7] 새 비번 5678로 로그인 ===");
        press_digit(4'd5); press_digit(4'd6); press_digit(4'd7); press_digit(4'd8);
        press_enter;
        #2; @(posedge clk);
        $display("state=%0d unlock_on=%b (expect UNLOCK=3, unlock=1)", state, unlock_on);

        $finish;
    end

endmodule
