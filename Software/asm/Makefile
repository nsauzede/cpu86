SREC_CAT:=~/perso/hack/8088/srecord-1.64-win32/srec_cat.exe

all:
	nasm hello2.asm
#	ndisasm.exe -b 16 hello2 -o 0x100
#	 hello2 -binary -execution-start-address 0x380 -offset 0x100 -o hello2.hex -intel
#	$(SREC_CAT) hello2 -binary -offset 0x100 -o hello2.hex -intel
	$(SREC_CAT) hello2 -binary -offset 0x100 -o hello2.hex -intel −−address−length=3 --Execution_Start_Address 0x100 --disable footer
	@echo "Now you just have to hit 'l' in MON88 and paste the following hex output :"
	@cat hello2.hex

#	nasm hello.asm
#	ndisasm.exe -b 16 hello -o 0x100
##	$(SREC_CAT) hello2 -binary -execution-start-address 0x380 -offset 0x100 -o hello2.hex -intel
#	$(SREC_CAT) hello -binary -offset 0x100 -o hello.hex2 -intel −−address−length=3 && cat hello.hex2
