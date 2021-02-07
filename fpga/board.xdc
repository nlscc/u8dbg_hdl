# constraints file for Basys3 board

# clock pin
set_property PACKAGE_PIN W5 [get_ports clk]
	set_property IOSTANDARD LVCMOS33 [get_ports clk]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

# output pins to MCU
set_property PACKAGE_PIN J1 [get_ports {JA[0]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {JA[0]}]
set_property PACKAGE_PIN L2 [get_ports {JA[1]}]
	set_property IOSTANDARD LVCMOS33 [get_ports {JA[1]}]

# USB UART
set_property PACKAGE_PIN B18 [get_ports RsRx]
	set_property IOSTANDARD LVCMOS33 [get_ports RsRx]
set_property PACKAGE_PIN A18 [get_ports RsTx]
	set_property IOSTANDARD LVCMOS33 [get_ports RsTx]

set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]
