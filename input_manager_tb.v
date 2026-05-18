`timescale 1ns / 1ps

module input_manager_tb;

    reg         clk;
    reg         reset_n;
    reg [15:0]  button_in;
    integer     i;

    wire        key_valid;
    wire [3:0]  key_data;
    wire        hash_key;
    wire        admin_key;
    wire        clear_key;
    wire [2:0]  input_count;
    wire [15:0] pass_buffer;

    input_manager #(
        .CLK_FREQ_HZ(1000000),
        .DEBOUNCE_MS(20)
    ) dut (
        .clk(clk),
        .reset_n(reset_n),
        .button_in(button_in),
        .key_valid(key_valid),
        .key_data(key_data),
        .hash_key(hash_key),
        .admin_key(admin_key),
        .clear_key(clear_key),
        .input_count(input_count),
        .pass_buffer(pass_buffer)
    );

    initial begin
        clk = 1'b0;
        // Run the 50 MHz clock long enough to cover the whole stimulus sequence.
        for (i = 0; i < 8000000; i = i + 1) begin
            #10 clk = ~clk;
        end
    end

    initial begin
        reset_n   = 1'b0;
        button_in = 16'b0;

        #5_000_000;
        reset_n = 1'b1;
        #5_000_000;

        button_in[1] = 1'b1;
        #30_000_000;
        button_in[1] = 1'b0;
        #30_000_000;

        button_in[2] = 1'b1;
        #30_000_000;
        button_in[2] = 1'b0;
        #30_000_000;

        button_in[3] = 1'b1;
        #30_000_000;
        button_in[3] = 1'b0;
        #30_000_000;

        button_in[4] = 1'b1;
        #30_000_000;
        button_in[4] = 1'b0;
        #30_000_000;

        button_in[12] = 1'b1;
        #30_000_000;
        button_in[12] = 1'b0;
        #30_000_000;

        $finish;
    end

endmodule
