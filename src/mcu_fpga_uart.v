`timescale 1ns/1ps
// MCU(PC10, TX)에서 확장 GPIO로 받은 문자를 PC로 되돌려 보내고 LED를 제어합니다.
module mcu_fpga_uart #(
    parameter integer CLK_HZ = 50_000_000,
    parameter integer BAUD = 9_600
)(
    input wire clk_50mhz,
    input wire rst_p,
    input wire mcu_rxd,      // 확장 GPIO RX (MCU PC10에서 연결)
    output wire pc_txd,      // 보드 내부 USB-UART TX (F6)
    output wire led1         // 과제 7: LED1
);
    localparam integer DIV = (CLK_HZ + BAUD/2) / BAUD;
    wire [7:0] rx_data;
    wire rx_valid, rx_framing_error, tx_ready;
    reg tx_valid;
    reg [7:0] tx_data;

    uart_rx #(.DIV(DIV)) u_rx(.clk(clk_50mhz), .rst_p(rst_p), .rx(mcu_rxd),
        .data(rx_data), .valid(rx_valid), .framing_error(rx_framing_error));
    uart_tx #(.DIV(DIV)) u_tx(.clk(clk_50mhz), .rst_p(rst_p), .valid(tx_valid),
        .data(tx_data), .ready(tx_ready), .tx(pc_txd));
    led_command u_cmd(.clk(clk_50mhz), .rst_p(rst_p), .valid(rx_valid),
        .data(rx_data), .led_on(led1));

    always @(posedge clk_50mhz) begin
        if (rst_p) begin tx_valid<=0; tx_data<=0; end
        else begin
            tx_valid <= 0;
            if (rx_valid) begin
                if (tx_ready) begin tx_data <= rx_data; tx_valid <= 1; end
            end
        end
    end
endmodule