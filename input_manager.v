module input_manager #(
    parameter integer CLK_FREQ_HZ = 1000000,
    parameter integer DEBOUNCE_MS = 20
) (
    input  wire        clk,
    input  wire        reset_n,
    input  wire [15:0] button_in,
    output wire        key_valid,
    output wire [3:0]  key_data,
    output wire        hash_key,
    output wire        admin_key,
    output wire        clear_key,
    output wire [2:0]  input_count,
    output wire [15:0] pass_buffer
);

    wire [15:0] btn_state;
    wire [15:0] btn_pulse;

    genvar i;
    generate
        for (i = 0; i < 16; i = i + 1) begin : debouncers
            button_debounce #(
                .CLK_FREQ_HZ(CLK_FREQ_HZ),
                .DEBOUNCE_MS(DEBOUNCE_MS)
            ) u_button_debounce (
                .clk(clk),
                .reset_n(reset_n),
                .btn_in(button_in[i]),
                .btn_state(btn_state[i]),
                .btn_pulse(btn_pulse[i])
            );
        end
    endgenerate

    key_encoder u_key_encoder (
        .key_in(btn_pulse),
        .key_valid(key_valid),
        .key_data(key_data),
        .hash_key(hash_key),
        .admin_key(admin_key),
        .clear_key(clear_key)
    );

    input_buffer u_input_buffer (
        .clk(clk),
        .reset_n(reset_n),
        .clear_key(clear_key),
        .key_valid(key_valid),
        .hash_key(hash_key),
        .admin_key(admin_key),
        .key_data(key_data),
        .input_count(input_count),
        .pass_buffer(pass_buffer)
    );

endmodule
