`timescale 1ns / 1ps

// Lock feature testbench: input_manager(lock) + fsm_module 연동 검증
// - ALARM 상태에서 TACT_SW 입력이 차단되는지 확인
// - RESET 후 입력이 다시 동작하는지 확인
module lock_tb;

    reg        clk;
    reg        reset_n;
    reg [12:0] tact_sw;

    wire [3:0] digit_in;
    wire       key_valid, enter, change, auto_open;
    wire [2:0] state;
    wire       unlock_on, alarm_on, key_led;
    wire [3:0] input_count_led;

    // input_manager: lock = alarm_on (ALARM 상태에서 입력 차단)
    input_manager #(.CLK_FREQ_HZ(1000), .DEBOUNCE_MS(20)) U_INPUT (
        .clk(clk), .reset_n(reset_n), .tact_sw(tact_sw),
        .lock(alarm_on),
        .digit_in(digit_in), .key_valid(key_valid),
        .enter(enter), .change(change), .auto_open(auto_open)
    );

    // fsm_module (폴더 버전 — auto_lock_timer 없는 구버전)
    fsm_module FSM (
        .clk(clk), .rst(~reset_n),
        .digit_in(digit_in), .key_valid(key_valid),
        .enter(enter), .change(change), .auto_open(auto_open),
        .state(state), .unlock_on(unlock_on), .alarm_on(alarm_on),
        .key_led(key_led), .input_count_led(input_count_led)
    );

    always #500 clk = ~clk; // 1 kHz (period = 1000 ns)

    // debounce MAX_COUNT = 20 클럭 -> 25클럭 유지로 확실히 통과
    task press_sw;
        input integer idx;
        begin
            tact_sw[idx] = 1'b1;
            repeat(25) @(posedge clk); #1;
            tact_sw[idx] = 1'b0;
            repeat(25) @(posedge clk); #1;
        end
    endtask

    // 4자리 숫자 + enter 입력
    task enter_password;
        input [3:0] d0, d1, d2, d3;
        begin
            press_sw(d0); press_sw(d1); press_sw(d2); press_sw(d3);
            press_sw(10); // ENTER
        end
    endtask

    initial begin
        clk = 0; reset_n = 0; tact_sw = 13'b0;
        repeat(5) @(posedge clk); #1;
        reset_n = 1;
        repeat(2) @(posedge clk); #1;

        // --- [1] 틀린 비밀번호 3회 -> ALARM ---
        $display("=== [1] 틀린 비밀번호 3회 입력 -> ALARM ===");
        repeat(3) begin
            enter_password(4'd9, 4'd9, 4'd9, 4'd9);
            @(posedge clk); #1;
            $display("  state=%0d alarm_on=%b", state, alarm_on);
        end
        $display("  >> ALARM 진입: state=%0d alarm_on=%b (expect state=4, alarm=1)", state, alarm_on);

        // --- [2] ALARM 중 버튼 입력 -> 차단 확인 ---
        $display("=== [2] ALARM 중 버튼 입력 시도 (차단 확인) ===");
        tact_sw[1] = 1'b1;           // digit '1' 누름
        repeat(25) @(posedge clk); #1;
        $display("  alarm_on(lock)=%b  key_valid=%b  (expect key_valid=0)", alarm_on, key_valid);
        tact_sw[10] = 1'b1;          // ENTER 누름
        repeat(25) @(posedge clk); #1;
        $display("  alarm_on(lock)=%b  enter=%b      (expect enter=0)", alarm_on, enter);
        tact_sw = 13'b0;
        repeat(25) @(posedge clk); #1;
        $display("  state=%0d (expect ALARM=4, 상태 변화 없음)", state);

        // --- [3] RESET -> IDLE ---
        $display("=== [3] RESET_N 인가 -> IDLE 복귀 ===");
        reset_n = 0;
        repeat(5) @(posedge clk); #1;
        reset_n = 1;
        repeat(2) @(posedge clk); #1;
        $display("  state=%0d alarm_on=%b (expect IDLE=0, alarm=0)", state, alarm_on);

        // --- [4] IDLE 상태에서 버튼 입력 -> 정상 동작 확인 ---
        $display("=== [4] IDLE 상태 버튼 입력 (정상 동작 확인) ===");
        tact_sw[1] = 1'b1;           // digit '1' 누름
        repeat(25) @(posedge clk); #1;
        $display("  alarm_on(lock)=%b  key_valid=%b  (expect key_valid=1)", alarm_on, key_valid);
        tact_sw[1] = 1'b0;
        repeat(25) @(posedge clk); #1;

        $display("=== 테스트 완료 ===");
        $finish;
    end

endmodule
