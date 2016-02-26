@echo Create Bootstrap_rtl.vhd from jump to 0000:0400 file
A86.com +L1 +P0 +W0 +T0 +G2 +S  jump0400.asm  jump0400.bin
..\..\bin\bin2case.exe jump0400.bin Bootstrap_rtl.vhd 8 
