create_project -in_memory -part xc7a35tcpg236-1

read_verilog dbgtest.v
read_xdc board.xdc

synth_design -top dbgtest

opt_design
power_opt_design
place_design
phys_opt_design
route_design
phys_opt_design

write_bitstream u8dbg.bit -force
