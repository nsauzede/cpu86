Quick run with GHDL:

1) Open a terminal session
2) Navigate to the web_cpu88/GHDL directory. 
3) Execute run.sh:

  sh run.sh

The simulation output should look something like this:

GHDL$ sh run.sh 
*** Compiling the CPU86 processor ***
*** Compiling Opencores 16750 UART ***
../Opencores/slib_fifo.vhd:56:46:warning: universal integer bound must be numeric literal or attribute
*** Compiling example top level, CPU86+ROM+UART ***
*** compiling Testbench for CPU86+ROM+UART ***
../testbench/sram.vhd:352:16:warning: procedure "do_dump" is never referenced
Running Testbench in command line mode
Initializing SRAM with zero ...
Loading SRAM from file loadfname.dat ... 
RD UART : MON88 8088/8086 Monitor ver 0.12
RD UART : Copyright WWW.HT-LAB.COM 2005-2008
RD UART : All rights reserved.
RD UART :
RD UART : Cmd>R
RD UART : AX=0000 BX=0001 CX=0002 DX=0003 SP=0100 BP=0005 SI=0006 DI=0007
RD UART : DS=0380 ES=0380 SS=0380 CS=0380 IP=0100   ODIT-SZAPC=0000-00100
RD UART : 0380:0100 0000           ADD    [BX+SI], AL
RD UART : Cmd>DM 0100-0124
RD UART : 0380:0100  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
RD UART : 0380:0110  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
RD UART : 0380:0120  00 00 00 00                                       ....

Note that it might take considerable time to show this output.

To run with a wave trace, add --vcd argument and view the trace with GTKWave.

  sh run.sh --vcd=cpu86.vcd
  gtkwave cpu86.vcd

Please note that the file can be quite big -- around 10G -- if you leave it
running for the full 200ms. Either terminate it early, modify the 200ms value
at the bottom of run.sh, or convert it to FST with vcd2fst.
