module top_module (
    input  wire        clk_1khz,
    input  wire        rst,         // active-high; connect to physical reset button for ALARM release
    input  wire [12:0] TACT_SW,
    output wire [7:0]  LEDR
);

    // Key encoding from TACT_SW (§1-1)
    wire        key_valid  = |TACT_SW[9:0];
    wire [3:0]  digit_in   = TACT_SW[0] ? 4'd0 :
                             TACT_SW[1] ? 4'd1 :
                             TACT_SW[2] ? 4'd2 :
                             TACT_SW[3] ? 4'd3 :
                             TACT_SW[4] ? 4'd4 :
                             TACT_SW[5] ? 4'd5 :
                             TACT_SW[6] ? 4'd6 :
                             TACT_SW[7] ? 4'd7 :
                             TACT_SW[8] ? 4'd8 :
                             TACT_SW[9] ? 4'd9 : 4'd0;
    wire        enter      = TACT_SW[10];
    wire        change     = TACT_SW[11];
    wire        auto_open  = TACT_SW[12];

    // FSM outputs
    wire [2:0]  state;
    wire        unlock_on;
    wire        alarm_on;
    wire        key_led;
    wire [3:0]  input_count_led;

    fsm_module u_fsm (
        .clk            (clk_1khz),
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

    // LED mapping (§1-2)
    assign LEDR[3:0] = input_count_led;
    assign LEDR[4]   = key_led;
    assign LEDR[5]   = unlock_on;
    assign LEDR[6]   = alarm_on;
    assign LEDR[7]   = auto_open;

endmodule
