module input_buffer (
    input  wire        clk,
    input  wire        reset_n,
    input  wire        clear_key,
    input  wire        key_valid,
    input  wire        hash_key,
    input  wire        admin_key,
    input  wire [3:0]  key_data,
    output reg  [2:0]  input_count,
    output reg  [15:0] pass_buffer
);

    wire number_key;
    assign number_key = key_valid && !hash_key && !admin_key && !clear_key;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            input_count <= 3'd0;
            pass_buffer <= 16'd0;
        end else if (clear_key) begin
            input_count <= 3'd0;
            pass_buffer <= 16'd0;
        end else if (number_key && input_count < 3'd4) begin
            pass_buffer <= {pass_buffer[11:0], key_data};
            input_count <= input_count + 1'b1;
        end
    end

endmodule
