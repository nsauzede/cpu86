Description :
=============
Here is a port of CPU86, the Free VHDL CPU8088 IP core.

The original website is :
- http://ht-lab.com/cpu86.htm

Original Readme is [here](readme.txt)

Original platform/implementation was :
- [Enterpoint Drigmorn1 board](https://www.enterpoint.co.uk/shop/home/17-drigmorn1.html), Xilinx ISE 12.1 

I have ported the project to newer :
- [GadgetFactory Papilio](http://store.gadgetfactory.net/papilio-one-500k-spartan-3e-fpga-dev-board/), Xilinx ISE 14.7 (last one supporting old FPGAS)
- [Arrow Max1000 FPGA](https://www.arrow.com/en/products/max1000/arrow-development-tools), Intel Quartus Prime 17.x

Basic usage instructions :
==========================
Prerequisites :
- Quartus 17.0.2
- Terminal emulator (eg: Tera Term)
- nasm
- make
- srec (eg: srecord-1.64-win32)

To test cpu86 on the Max1000 board, open "cpu86/mx_sdram/top.qpf" in Quartus
Build the max1k_88_top.sof bitstream (takes about 3min)
Plug the Max1000 to USB port
In a terminal emulator, open the Max1000 Serial port (eg: COM14) at 4800 baudrate
Now launch the Quartus programmer and click on "Start"
Then in the terninal you should see :
```
MON88 8088/8086 Monitor ver 0.12
Copyright WWW.HT-LAB.COM 2005-2008
All rights reserved.

Cmd>
```

Now you can try to build/execute a small assembly test.
Go to Software/asm, and run :
```
cpu86/Software/asm$ make
nasm hello2.asm
srec_cat.exe hello2 -binary -offset 0x100 -o hello2.hex -intel −−address−length=3 --Execution_Start_Address 0x100 --disable footer
Now you just have to hit 'l' in MON88 and paste the following hex output :
:020000020000FC
:20010000BA4F01E831008CD98EC1BE3D01BF4301E80E00BE3D01BF4901E80500B8004CCD50
:2001200021B90600F3A67508BA5F01E80900EB06BA6E01E80100C3B80009CD21C3434F559F
:20014000434F55414F55434F55434F55434F550A0D2A2A2A2048656C6C6F202A2A2A000ACD
:200160000D2A2A2A2053414D45202A2A2A000A0D2A2A2A20444946464552454E54202A2A50
:020180002A0053
:0400000300000100F8
```
And follow the above instructions

More to come in the [wiki](https://github.com/nsauzede/cpu86/wiki)..

Stay tuned and/or Have fun !
