Quick run: 

1) Open a DOSBox/Cygwin shell 
2) Navigate to the web_cpu88/Modelsim directory. 
3) Execute run.bat 

Modelsim is executed in command line mode. The simulation output should look something 
like this:

# Initializing SRAM with zero ...
# Loading SRAM from file loadfname.dat ...
# RD UART : MON88 8088/8086 Monitor ver 0.12
# RD UART : Copyright WWW.HT-LAB.COM 2005-2008
# RD UART : All rights reserved.
# RD UART :
# RD UART : Cmd>R
# RD UART : AX=0000 BX=0001 CX=0002 DX=0003 SP=0100 BP=0005 SI=0006 DI=0007
# RD UART : DS=0380 ES=0380 SS=0380 CS=0380 IP=0100   ODIT-SZAPC=0000-00100
# RD UART : 0380:0100 0000           ADD    [BX+SI], AL
# RD UART : Cmd>DM 0100-0124
# RD UART : 0380:0100  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
# RD UART : 0380:0110  00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
# RD UART : 0380:0120  00 00 00 00                                       ....

Note that it might take considerable time to show this output if you have a slow PC and/or
using an OEM version of Modelsim (for example Xilinx' Modelsim XE).

For Modelsim SE6.5a users, if you get a SIGSEGV error message then try to run without vopt (-novopt)

# ** Fatal: (SIGSEGV) Bad handle or reference.
#    Time: 0 ns  Iteration: 0  Process: /cpu86_top_tb/u_12/memory File: ../testbench/sram.vhd
# FATAL ERROR while loading design
# Error loading design