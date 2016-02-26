@echo Create Bootstrap_rtl.vhd from Intel Bootloader file
A86.com +L1 +P0 +W0 +T0 +G2 +S  ldintel.asm  ldintel.bin
..\..\bin\bin2case.exe ldintel.bin Bootstrap_intel_rtl.vhd 8 
