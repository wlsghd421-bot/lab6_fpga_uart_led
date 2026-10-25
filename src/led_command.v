`timescale 1ns/1ps
// 받은 문자에 따라 LED 상태를 정합니다.
// '0'(0x30) 끄기, '1'(0x31) 켜기, '2'(0x32) 반전, 그 밖의 문자는 유지합니다.
module led_command(
    input wire clk, rst_p,
    input wire valid,
    input wire [7:0] data,
    output reg led_on
);
    always @(posedge clk) begin
        if (rst_p) led_on <= 1'b0;
        else if (valid) begin
            case (data)
                8'h30: led_on <= 1'b0;
                8'h31: led_on <= 1'b1;
                8'h32: led_on <= ~led_on;
                default: led_on <= led_on;
            endcase
        end
    end
endmodule