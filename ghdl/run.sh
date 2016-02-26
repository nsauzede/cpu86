# Just run this to build & execute the CPU86 and the monitor with GHDL on UNIX 
# compatibles:
#
#   sh run.sh
#
# To run with a wave trace, add --vcd argument and view the trace with GTKWave.
#
#   sh run.sh --vcd=cpu86.vcd
#   gtkwave cpu86.vcd
#
# Please note that the file can be quite big -- around 10G -- if you leave it
# running for the full 200ms. Either terminate it early, modify the 200ms value
# at the bottom of this file, or convert it to FST with vcd2fst.

rm -f *.o work-obj93.cf loadfname.dat cpu86_top_tb wave.do

echo '*** Compiling the CPU86 processor ***'
ghdl -a --ieee=synopsys -fexplicit ../cpu86_rtl/cpu86pack.vhd
ghdl -a --ieee=synopsys -fexplicit ../cpu86_rtl/cpu86instr.vhd
ghdl -a --ieee=synopsys -fexplicit ../cpu86_rtl/biufsm_fsm.vhd
ghdl -a --ieee=synopsys -fexplicit ../cpu86_rtl/a_table.vhd
ghdl -a --ieee=synopsys -fexplicit ../cpu86_rtl/d_table.vhd
ghdl -a --ieee=synopsys -fexplicit ../cpu86_rtl/n_table.vhd
ghdl -a --ieee=synopsys -fexplicit ../cpu86_rtl/r_table.vhd
ghdl -a --ieee=synopsys -fexplicit ../cpu86_rtl/m_table.vhd
ghdl -a --ieee=synopsys -fexplicit ../cpu86_rtl/formatter_struct.vhd
ghdl -a --ieee=synopsys -fexplicit ../cpu86_rtl/regshiftmux_regshift.vhd
ghdl -a --ieee=synopsys -fexplicit ../cpu86_rtl/biu_struct.vhd
ghdl -a --ieee=synopsys -fexplicit ../cpu86_rtl/dataregfile_rtl.vhd
ghdl -a --ieee=synopsys -fexplicit ../cpu86_rtl/segregfile_rtl.vhd
ghdl -a --ieee=synopsys -fexplicit ../cpu86_rtl/divider_rtl_ser.vhd
ghdl -a --ieee=synopsys -fexplicit ../cpu86_rtl/multiplier_rtl.vhd
ghdl -a --ieee=synopsys -fexplicit ../cpu86_rtl/alu_rtl.vhd
ghdl -a --ieee=synopsys -fexplicit ../cpu86_rtl/ipregister_rtl.vhd
ghdl -a --ieee=synopsys -fexplicit ../cpu86_rtl/datapath_struct.vhd
ghdl -a --ieee=synopsys -fexplicit ../cpu86_rtl/proc_rtl.vhd
ghdl -a --ieee=synopsys -fexplicit ../cpu86_rtl/cpu86_struct.vhd

echo '*** Compiling Opencores 16750 UART ***'
ghdl -a --ieee=synopsys -fexplicit ../Opencores/uart_baudgen.vhd
ghdl -a --ieee=synopsys -fexplicit ../Opencores/slib_clock_div.vhd
ghdl -a --ieee=synopsys -fexplicit ../Opencores/slib_edge_detect.vhd
ghdl -a --ieee=synopsys -fexplicit ../Opencores/slib_input_filter.vhd
ghdl -a --ieee=synopsys -fexplicit ../Opencores/uart_interrupt.vhd
ghdl -a --ieee=synopsys -fexplicit ../Opencores/slib_input_sync.vhd
ghdl -a --ieee=synopsys -fexplicit ../Opencores/slib_counter.vhd
ghdl -a --ieee=synopsys -fexplicit ../Opencores/slib_mv_filter.vhd
ghdl -a --ieee=synopsys -fexplicit ../Opencores/uart_receiver.vhd
ghdl -a --ieee=synopsys -fexplicit ../Opencores/slib_fifo.vhd
ghdl -a --ieee=synopsys -fexplicit ../Opencores/uart_transmitter.vhd
ghdl -a --ieee=synopsys -fexplicit ../Opencores/uart_16750.vhd


echo '*** Compiling example top level, CPU86+ROM+UART ***'
ghdl -a --ieee=synopsys -fexplicit ../top_rtl/Bootstrap_rtl.vhd
ghdl -a --ieee=synopsys -fexplicit ../top_rtl/uart_top_struct.vhd
ghdl -a --ieee=synopsys -fexplicit ../top_rtl/cpu86_top_struct.vhd

echo '*** compiling Testbench for CPU86+ROM+UART ***'
ghdl -a --ieee=synopsys -fexplicit ../testbench/uartrx.vhd
ghdl -a --ieee=synopsys -fexplicit ../testbench/uarttx.vhd
ghdl -a --ieee=synopsys -fexplicit ../testbench/sram.vhd
ghdl -a --ieee=synopsys -fexplicit ../testbench/utils.vhd
ghdl -a --ieee=synopsys -fexplicit ../testbench/tester_behaviour.vhd
ghdl -a --ieee=synopsys -fexplicit ../testbench/cpu86_top_tb_struct.vhd

echo 'Running Testbench in command line mode'
ln -sf ../Modelsim/loadfname.dat .
ghdl -e --ieee=synopsys -fexplicit cpu86_top_tb
./cpu86_top_tb --stop-time=200ms --ieee-asserts=disable $*
