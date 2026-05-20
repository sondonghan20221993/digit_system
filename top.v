module top (
    input  wire        clk,
    input  wire        reset_n,
    input  wire [15:0] button_in,
    output wire [7:0]  led
);

    wire        key_valid;
    wire [3:0]  key_data;
    wire        hash_key;
    wire        admin_key;
    wire        clear_key;
    wire        inside_unlock_btn;
    wire [2:0]  input_count;
    wire [15:0] pass_buffer;

    input_manager #(
        .CLK_FREQ_HZ(1000000),
        .DEBOUNCE_MS(20)
    ) u_input_manager (
        .clk(clk),
        .reset_n(reset_n),
        .button_in(button_in),
        .key_valid(key_valid),
        .key_data(key_data),
        .hash_key(hash_key),
        .admin_key(admin_key),
        .clear_key(clear_key),
        .inside_unlock_btn(inside_unlock_btn),
        .input_count(input_count),
        .pass_buffer(pass_buffer)
    );

    assign led[0] = key_valid;
    assign led[1] = hash_key;
    assign led[2] = admin_key;
    assign led[3] = clear_key;
    assign led[6:4] = input_count;
    assign led[7] = inside_unlock_btn;

endmodule
