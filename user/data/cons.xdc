set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property PACKAGE_PIN K17 [get_ports clk]
set_property PACKAGE_PIN F16 [get_ports rst]

create_clock -period 20.000 -name clk -waveform {0.000 10.000} [get_ports clk]