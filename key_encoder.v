module key_encoder (
    input  wire [15:0] key_in,
    output reg         key_valid,
    output reg  [3:0]  key_data,
    output reg         hash_key,
    output reg         admin_key,
    output reg         clear_key,
    output reg         inside_unlock_btn
);

    always @(*) begin
        key_valid  = 1'b0;
        key_data   = 4'd0;
        hash_key   = 1'b0;
        admin_key  = 1'b0;
        clear_key  = 1'b0;
        inside_unlock_btn = 1'b0;

        case (key_in)
            16'b0000_0000_0000_0001: begin key_valid = 1'b1; key_data = 4'd0; end
            16'b0000_0000_0000_0010: begin key_valid = 1'b1; key_data = 4'd1; end
            16'b0000_0000_0000_0100: begin key_valid = 1'b1; key_data = 4'd2; end
            16'b0000_0000_0000_1000: begin key_valid = 1'b1; key_data = 4'd3; end
            16'b0000_0000_0001_0000: begin key_valid = 1'b1; key_data = 4'd4; end
            16'b0000_0000_0010_0000: begin key_valid = 1'b1; key_data = 4'd5; end
            16'b0000_0000_0100_0000: begin key_valid = 1'b1; key_data = 4'd6; end
            16'b0000_0000_1000_0000: begin key_valid = 1'b1; key_data = 4'd7; end
            16'b0000_0001_0000_0000: begin key_valid = 1'b1; key_data = 4'd8; end
            16'b0000_0010_0000_0000: begin key_valid = 1'b1; key_data = 4'd9; end
            16'b0000_0100_0000_0000: begin key_valid = 1'b1; hash_key  = 1'b1; end
            16'b0000_1000_0000_0000: begin key_valid = 1'b1; admin_key = 1'b1; end
            16'b0001_0000_0000_0000: begin key_valid = 1'b1; clear_key = 1'b1; end
            16'b0010_0000_0000_0000: begin inside_unlock_btn = 1'b1; end
            default: begin end
        endcase
    end

endmodule
