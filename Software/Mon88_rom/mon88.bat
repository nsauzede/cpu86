A86.com +L1 +P0 +W0 +T0 +G2 +S  mon88.asm  mon88.bin
..\..\bin\bin2mem.exe mon88.bin loadfname.dat 0000:0000 
..\..\bin\bin2coe.exe mon88.bin mon88.coe 
..\..\bin\bin2hex.exe mon88.bin mon88.hex -s 0000 -o 0000 -e 0400  
copy loadfname.dat ..\..\Modelsim
copy mon88.coe ..\..\drigmorn1\coregen
pause
