#!/bin/sh
export LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:/lib/x86_64-linux-gnu
#nasm spi.s -o a
#nasm hello.s -o a
nasm bios.s -o a
srec_cat -Output a.ihex -Intel a -Binary -offset 0x0000 -Data_Only
#echo cres1000 > a2.ihex
#echo >> a2.ihex
echo l > a2.ihex
echo >> a2.ihex
cat a.ihex >> a2.ihex
# either following line to exec (don't terminate upload),
#echo ":0400000303800880EE" >> a2.ihex
#echo ":0400000303800080F6" >> a2.ihex
#echo ":040000030380000076" >> a2.ihex

# or following to terminate normal upload
echo ":00000001FF" >> a2.ihex
# 

#echo >> a2.ihex
#echo bs1000 >> a2.ihex
#echo >> a2.ihex
#echo dm00000080 >> a2.ihex
#echo >> a2.ihex

#abcd
#
#: LEN ADH ADL TYP CHK
#types:
#DATA 00
#EOF 01
#EAD 02 => set ES (Extended Segment Address Record)	:02000002USBACH
#SSA 03 => RETF (Start Segment Address Record)		:04000003CSCSIPIPCH
#    04 (Extended Linear Address Record)
#
#l:00000001FF
#
#:  00  00  00  01  FF
#
#:05000000616263640A67
#l
#:05080000616263640A5F:00000001FF
#
#: 02 00 00 02 00 00 FC
#
#l
#:05080000616263640A5F:00000001FF
