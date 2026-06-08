module gpio_key_input (
    input  wire       clk,
    input  wire       reset_n,
    input  wire [3:0] gpio_d,
    input  wire       gpio_valid,
    input  wire       gpio_enter,
    input  wire       gpio_change,
    input  wire       lock,
    output reg  [3:0] digit_in,
    output reg        key_valid,
    output reg        enter,
    output reg        change,
    output wire       auto_open
);
    reg prev_valid, prev_enter, prev_change;

    assign auto_open = 1'b0;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            prev_valid  <= 1'b0;
            prev_enter  <= 1'b0;
            prev_change <= 1'b0;
            digit_in    <= 4'd0;
            key_valid   <= 1'b0;
            enter       <= 1'b0;
            change      <= 1'b0;
        end else begin
            prev_valid  <= gpio_valid;
            prev_enter  <= gpio_enter;
            prev_change <= gpio_change;

            key_valid <= 1'b0;
            enter     <= 1'b0;
            change    <= 1'b0;

            if (gpio_valid && !prev_valid && !lock) begin
                digit_in  <= gpio_d;
                key_valid <= 1'b1;
            end
            if (gpio_enter && !prev_enter && !lock)
                enter <= 1'b1;
            if (gpio_change && !prev_change && !lock)
                change <= 1'b1;
        end
    end

endmodule
