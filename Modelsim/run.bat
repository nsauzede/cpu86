vdel -all
vlib work

@echo *** Compiling the CPU86 processor ***
vcom -93 -work work -quiet ../cpu86_rtl/cpu86pack.vhd
vcom -93 -work work -quiet ../cpu86_rtl/cpu86instr.vhd
vcom -93 -work work -quiet ../cpu86_rtl/biufsm_fsm.vhd
vcom -93 -work work -quiet ../cpu86_rtl/a_table.vhd
vcom -93 -work work -quiet ../cpu86_rtl/d_table.vhd
vcom -93 -work work -quiet ../cpu86_rtl/n_table.vhd
vcom -93 -work work -quiet ../cpu86_rtl/r_table.vhd
vcom -93 -work work -quiet ../cpu86_rtl/m_table.vhd
vcom -93 -work work -quiet ../cpu86_rtl/formatter_struct.vhd
vcom -93 -work work -quiet ../cpu86_rtl/regshiftmux_regshift.vhd
vcom -93 -work work -quiet ../cpu86_rtl/biu_struct.vhd
vcom -93 -work work -quiet ../cpu86_rtl/dataregfile_rtl.vhd
vcom -93 -work work -quiet ../cpu86_rtl/segregfile_rtl.vhd
vcom -93 -work work -quiet ../cpu86_rtl/divider_rtl_ser.vhd
vcom -93 -work work -quiet ../cpu86_rtl/multiplier_rtl.vhd
vcom -93 -work work -quiet ../cpu86_rtl/alu_rtl.vhd
vcom -93 -work work -quiet ../cpu86_rtl/ipregister_rtl.vhd
vcom -93 -work work -quiet ../cpu86_rtl/datapath_struct.vhd
vcom -93 -work work -quiet ../cpu86_rtl/proc_rtl.vhd
vcom -93 -work work -quiet ../cpu86_rtl/cpu86_struct.vhd

@echo *** Compiling Opencores 16750 UART ***
vcom -93 -work work -quiet ../Opencores/uart_baudgen.vhd
vcom -93 -work work -quiet ../Opencores/slib_clock_div.vhd
vcom -93 -work work -quiet ../Opencores/slib_edge_detect.vhd
vcom -93 -work work -quiet ../Opencores/slib_input_filter.vhd
vcom -93 -work work -quiet ../Opencores/uart_interrupt.vhd
vcom -93 -work work -quiet ../Opencores/slib_input_sync.vhd
vcom -93 -work work -quiet ../Opencores/slib_counter.vhd
vcom -93 -work work -quiet ../Opencores/slib_mv_filter.vhd
vcom -93 -work work -quiet ../Opencores/uart_receiver.vhd
vcom -93 -work work -quiet ../Opencores/slib_fifo.vhd
vcom -93 -work work -quiet ../Opencores/uart_transmitter.vhd
vcom -93 -work work -quiet ../Opencores/uart_16750.vhd


@echo *** Compiling example top level, CPU86+ROM+UART ***
vcom -93 -work work -quiet ../top_rtl/Bootstrap_rtl.vhd
vcom -93 -work work -quiet ../top_rtl/uart_top_struct.vhd
vcom -93 -work work -quiet ../top_rtl/cpu86_top_struct.vhd

@echo *** compiling Testbench for CPU86+ROM+UART ***
vcom -93 -work work -quiet ../testbench/uartrx.vhd
vcom -93 -work work -quiet ../testbench/uarttx.vhd
vcom -93 -work work -quiet ../testbench/sram.vhd
vcom -93 -work work -quiet ../testbench/utils.vhd
vcom -93 -work work -quiet ../testbench/tester_behaviour.vhd
vcom -93 -work work -quiet ../testbench/cpu86_top_tb_struct.vhd

@echo Running Testbench in command line mode
vsim -c -do tb.tcl
