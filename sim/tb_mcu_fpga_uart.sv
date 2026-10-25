`timescale 1ns/1ps
module tb;
    localparam integer CLK_HZ = 960, BAUD = 96;   // 비트당 10 클록으로 축소
    localparam integer DIV = 10;
    reg clk = 0, rst = 1, rx = 1;
    always #5 clk = ~clk;
    wire tx, led1;
    mcu_fpga_uart #(.CLK_HZ(CLK_HZ), .BAUD(BAUD)) dut(clk, rst, rx, tx, led1);

    task send(input [7:0] b);
        integer i;
        begin
            rx = 0; repeat (DIV) @(posedge clk);
            for (i = 0; i < 8; i = i + 1) begin rx = b[i]; repeat (DIV) @(posedge clk); end
            rx = 1; repeat (DIV) @(posedge clk);
        end
    endtask

    reg [7:0] got;
    task recv;                       // pc_txd에서 한 바이트 읽기
        integer i;
        begin
            @(negedge tx);
            repeat (DIV + DIV/2) @(posedge clk);
            for (i = 0; i < 8; i = i + 1) begin got[i] = tx; repeat (DIV) @(posedge clk); end
        end
    endtask

    task cmd(input [7:0] b, input expected_led);
        begin
            fork send(b); recv; join
            repeat (3*DIV) @(posedge clk);
            if (got !== b) $fatal(1, "echo mismatch sent=%h got=%h", b, got);
            if (led1 !== expected_led) $fatal(1, "led1 after %h = %b, expected %b", b, led1, expected_led);
        end
    endtask

    initial begin
        repeat (4) @(posedge clk); rst = 0; repeat (5) @(posedge clk);
        cmd("1", 1);   // 켜기
        cmd("1", 1);   // 반복해도 켜짐 유지
        cmd("0", 0);   // 끄기
        cmd("0", 0);
        cmd("2", 1);   // 반전: 꺼짐 -> 켜짐
        cmd("2", 0);   // 반전: 켜짐 -> 꺼짐
        cmd("2", 1);
        cmd("A", 1);   // 그 밖의 문자: 유지
        cmd(8'h01, 1); // 숫자 1(0x01)은 '1'(0x31)과 다름: 유지
        cmd("0", 0);
        cmd("a", 0);
        $display("PASS mcu_fpga_uart: echo, '0' off, '1' on, '2' toggle, others hold");
        $finish;
    end
    initial begin #2000000; $fatal(1, "timeout"); end
endmodule