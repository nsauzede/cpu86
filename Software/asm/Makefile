SREC_CAT:=srec_cat

all:
	nasm hello2.asm
#	ndisasm.exe -b 16 hello2 -o 0x100
#	 hello2 -binary -execution-start-address 0x380 -offset 0x100 -o hello2.hex -intel
#	$(SREC_CAT) hello2 -binary -offset 0x100 -o hello2.hex -intel
	$(SREC_CAT) hello2 -binary -offset 0x100 -o hello2.hex -Intel -Address_Length 3 --Execution_Start_Address 0x100 --disable footer
	@echo "Now you just have to paste the following lines in MON88 console : (notice it begins with 'l' intel hex load command)"
	@echo -n "l" ; cat hello2.hex

#	nasm hello.asm
#	ndisasm.exe -b 16 hello -o 0x100
##	$(SREC_CAT) hello2 -binary -execution-start-address 0x380 -offset 0x100 -o hello2.hex -intel
#	$(SREC_CAT) hello -binary -offset 0x100 -o hello.hex2 -intel −−address−length=3 && cat hello.hex2
