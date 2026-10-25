# Combo II-DLD S75, 50 MHz 클록, UART 9600 8N1.
set_property PACKAGE_PIN B6 [get_ports clk_50mhz]
set_property PACKAGE_PIN K2 [get_ports rst_p]
# MCU PC10(TX)를 연결할 확장 GPIO RX: 핀맵의 EXT1 (G10)
set_property PACKAGE_PIN G10 [get_ports mcu_rxd]
# 보드 내부 USB-UART TX: F6
set_property PACKAGE_PIN F6 [get_ports pc_txd]
# 과제 7: LED1
set_property PACKAGE_PIN L4 [get_ports led1]
set_property IOSTANDARD LVCMOS33 [get_ports *]
create_clock -name clk_50mhz -period 20.000 [get_ports clk_50mhz]
set_false_path -from [get_ports {rst_p mcu_rxd}]