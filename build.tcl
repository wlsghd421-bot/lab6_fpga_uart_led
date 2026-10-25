# 프로젝트 만들기 (Spartan-7 xc7s75fgga484-1)
create_project -force uart_led vivado_out -part xc7s75fgga484-1
add_files [glob src/*.v]
add_files -fileset constrs_1 constraints/mcu_fpga_uart.xdc
set_property top mcu_fpga_uart [current_fileset]
update_compile_order -fileset sources_1

# 합성 -> 구현 -> 비트스트림
launch_runs synth_1 -jobs 4
wait_on_run synth_1
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

# 결과 보고서
open_run impl_1
report_utilization -file vivado_out/utilization.txt
report_timing_summary -file vivado_out/timing.txt
puts "BIT: [glob vivado_out/uart_led.runs/impl_1/*.bit]"
