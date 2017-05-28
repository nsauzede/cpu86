# Papilio2 LCD SPI

This project builds upon work in the Drigmorn1 project and does the following:

* Uses Papilio Duo
* Uses LCD wing for Sharp LCD screens (3x6 bits colors)
* Instantiates Open source 808x processor and a rudimentary VGA-like controller
* The integrated MON88 monitor allows to alter the memory, such as the video memory
* Currently, all text is white, but any of the 4096 available colors could be used.
* Instantiates SPI master, connected to external SD card

isram:		65536 bytes	at: 0x00000-0x0FFFF (internal BRAM)
 vram:		 8192 bytes	 at: 0x0E000-0x0FFFF (video RAM - VGA text)
esram:		65536 bytes at: 0x10000-0x1FFFF (external SRAM)
bootstrap:	256 bytes	at: 0xFFF00-0xFFFFF

VRAM_BAR=0x0E000="111" & addr_read

## Links

* [Open source 808x IP](http://www.ht-lab.com/cpu86.htm)
* [Papilio Duo](http://papilio.cc/index.php?n=Papilio.DUOStart)
* [Papilio LCD wing (Sharp LCD screens)](https://www.logre.eu/wiki/Ecran_Sharp_LQ084V1DG21/en)
* [Recreating ancient 8088 PC on FPGA (in french)](https://www.logre.eu/wiki/PC_8088_sur_FPGA)
