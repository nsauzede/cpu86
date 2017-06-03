BITS 16
CPU 8086

;SPI at 0400-0407
%define spi_clk_div_port 0x0404
%define spi_receive_port 0x0403
%define spi_transmit_port 0x0402
%define spi_status_port 0x0401
%define spi_cs_ctl_port 0x0400

ORG 0x0000

; we define stack area (MON86 insists on that)
times 0x100 db 0x90

; this is the BIOS entry point
entry:
cli
;mov sp,0x0380
;;mov sp,0x1000
;mov ss,sp
;mov sp,0x0100

mov ax,cs
; assume ds=cs for local prints
mov ds,ax

; hook int13h vector at [0:0x4c]
xor di,di
mov es,di
mov di,(13h)*4
; FIXME : on CPU86, following MOVs don't work ? MON86 after-effect ?
;mov word [di],int13_handler
;mov word [di+2],ax
mov ax,int13_handler
stosw
mov ax,cs
stosw

mov di,(1eh)*4
mov ax,int13_fdpt
stosw
mov ax,cs
stosw

sti

xor di,di

MOV     DX,welcome
call print

;mov ax,0x0380
;mov di,0x0100
;mov di,0x0000
;mov di,0x0500
; assume es=0

;mov di,0x7c00
;call spi_read
;jmp exit

mov dx,0x500
mov al,0x03
out dx,al

; read sectors from drive
; ah=02 al=sectors_count
; ch=cylinder cl=sector
; dh=head dl=drive
; [es:bx]=buffer
mov ax,0x0201
mov cx,0x0001
mov dx,0x0000
mov bx,0x0000
mov es,bx
mov bx,0x7c00
int 13h
jnc nerr0

err0:
mov dx,0x500
mov al,0x09
out dx,al
;jmp $
jmp exit

nerr0:
mov dx,0x500
mov al,0x01
out dx,al

; DOS boot : (QEMU)
; 0x7c0B : sect size		! 0200
; 0x7c0D : sect per cluster	! 02
; 0x7c0E : resvd sect		! 0001
; 0x7c10 : nb FAT			! 02
; 0x7c11 : max root files	! 0070 (112)
; 0x7c13 : nb sect			! 02d0 (720)
; 0x7c15 : media type		! fd (360kB ?)
; 0x7C16 : sect per FAT		! 0002
; 0x7C18 : sect per track	! 09
; 0x7C1a : nb head			! 0002
; 0x7c1c : hidden sect		! 0000

; 0x7c2a : head
; 0x7c2b : copy of BIOS FDPT patched

; 0x7c37 : after files sect ? (10 * 16 + 1c + 0e) + ((0x20 * 11 + 0b - 1) / 0b)
; 0x7c39 : sectorhi/cyl
; 0x7c3b : sectorlo
; 0x7c3f : IO.SYS MSDOS.SYS ? nbfat * sectperfat + hiddensec + resvdsec

; 0x7d2c : print routine => 7d38 (+ 7d52)
; 0x7d39 : routine calc address to head/sectorhi/cyl/sectorlo => 7d52
; 0x7d53 : read sector routine => 7d75
; 0x7d76 : "\r\nNon-System disk or disk error\r\nReplace and strike any key when ready\r\n"
; 0x7dbf : "\r\nDisk Boot failure\r\n"

; 0x7dd5 : "IO      SYS"
; 0x7de0 : "MSDOS   SYS"
; 0x7dfd : head

; int1E=0x78=floppy disk drive param table (QEMU)
; us : SPT=9; sect=512
;0xaf	0x02	0x25	0x02	0x12	0x1b	0xff	0x6c	0xf6	0x0f	0x08

;DisketteParmRec
;  Offset Size Contents
;  ������ ���� ��������������������������������������������������������������
;   +0      1  rSrtHdUnld   bits 0-3: SRT step rate time
;                           bits 4-7: head unload time
;   +1      1  rDmaHdLd     bit    0: 1=use DMA
;                           bits 2-7: head load time
;   +2      1  bMotorOff    55-ms increments before turning disk motor off
;   +3      1  bSectSize    sector size (0=128, 1=256, 2=512, 3=1024)
;   +4      1  bLastTrack   EOT (last sector on a track)
;   +5      1  bGapLen      gap length for read/write operations
;   +6      1  bDTL         DTL (Data Transfer Length) max transfer when
;                           length not set
;   +7      1  bGapFmt      gap length for format operation
;   +8      1  bFillChar    fill character for format (normally 0f6H '�')
;   +9      1  bHdSettle    head-settle time (in milliseconds)
;  +0aH     1  bMotorOn     motor-startup time (in 1/8th-second intervals)
;          11               length of DisketteParmRec

;int3
jmp 0:0x7c00
;jmp $

exit:
MOV     AX,04C00h
int 0x21

int13_fdpt:
db 0xaf,0x02,0x25,0x02,0x12,0x1b,0xff,0x6c,0xf6,0x0f,0x08

; 0001 => seclo=1%9+1=1? head=1/9%2=0 sechi/cyl=0
; cyl=00 sec=01 head=00
; ax=0201 bx=0000 cx=0001 dx=0000 es=07c0 QEMU
; ax=0201 bx=7c00 cx=0001 dx=0000 es=0000 us

; 0005 => seclo=5%9+1=6 head=5/9%2=0 sechi/cyl=0
; cyl=00 sec=06 head=00
; ax=0201 bx=0500 cx=0006 dx=0000 es=0000 QEMU
; ax=0201 bx=0500 cx=0006 dx=0000 es=0000 us

; 000c => seclo=c%9+1=4 head=c/9%2=1 sechi/cyl=0
; cyl=00 sec=04 head=01
; ax=0206 bx=0700 cx=0004 dx=0100 es=0000 QEMU
; ax=0206 bx=0700 cx=0004 dx=0100 es=0000 us

; read sectors from drive
; ah=02 al=sectors_count
; ch=cylinder cl=sector
; dh=head dl=drive
; [es:bx]=buffer
int13_handler:
int3
push ax
push bp
mov bp,sp
push dx
push di
push es
push cx

cmp ah,00h
je int13_reset0
cmp ah,02h
je int13_read0
jmp int13_fail0
int13_reset0:
jmp ok0
int13_read0:
mov di,bx
mov ax,cx
dec ax
call spi_read
test al,al
jz ok0
int13_fail0:
or WORD [SS:BP+8],0001h	; set CF in stack stored flags
ok0:
pop cx
pop es
pop di
pop dx
pop bp
pop ax
;jmp $
iret

print:
mov ax,0900h
INT     21h
ret

;read a sector at ax from SDCARD (SPI mode) into [es:di]
; clobbers ax, flags
; returns al=00 if OK, al=ff if FAIL
spi_read:
push cx
push dx
push bx
mov bx,ax

mov al,0xff
mov dx,spi_clk_div_port
out dx,al
; al already 0xff
mov dx,spi_cs_ctl_port
out dx,al
mov cl,12
mov ah,0xff
loop_init0:
call spi_inout
dec cl
jnz loop_init0
mov al,0xfe
mov dx,spi_cs_ctl_port
out dx,al

mov ah,0x40
call spi_inout
mov ah,0x00
call spi_inout
call spi_inout
call spi_inout
call spi_inout
mov ah,0x95
call spi_inout
mov ah,0xff
call spi_inout
call spi_inout
cmp al,0x01
jne fail0

mov ah,0x48
call spi_inout
mov ah,0x00
call spi_inout
call spi_inout
mov ah,0x01
call spi_inout
mov ah,0xaa
call spi_inout
mov ah,0x87
call spi_inout
mov ah,0xff
call spi_inout
call spi_inout
cmp al,0x01
jne fail0
call spi_inout
call spi_inout
call spi_inout
call spi_inout

mov cl,255
sd_read_loop_init1:
mov ah,0x77
call spi_inout
mov ah,0x00
call spi_inout
call spi_inout
call spi_inout
call spi_inout
mov ah,0x65
call spi_inout
mov ah,0xff
call spi_inout
call spi_inout
cmp al,0x01
jne fail0
mov ah,0x69
call spi_inout
mov ah,0x40
call spi_inout
mov ah,0x00
call spi_inout
call spi_inout
call spi_inout
mov ah,0x77
call spi_inout
mov ah,0xff
call spi_inout
call spi_inout
cmp al,0x00
je sd_read_loop_init1_done
dec cl
jz fail0
call delay_20ms
jmp sd_read_loop_init1
sd_read_loop_init1_done:

mov ah,0x51
call spi_inout
mov ah,0x00
call spi_inout
call spi_inout
mov ah,bh
call spi_inout
mov ah,bl
call spi_inout
mov ah,0x75
call spi_inout
mov ah,0xff
call spi_inout
call spi_inout
cmp al,0x00
jne fail0
;call crlf

wait_token:
mov ah,0xff
call spi_inout
cmp al,0xfe
jz sd_read_loop_begin
jmp wait_token

sd_read_loop_begin:
mov ch,02
begin0:
mov cl,0x00			; 00 means 256 loops
begin1:
mov al,0xff
call spi_inout
stosb
;call put2hex
dec cl
jnz begin1
dec ch
jnz begin0
;call crlf
mov al,0xff
call spi_inout		; read two-
;stosb
;call put2hex
call spi_inout		; -byte checksum
;stosb
;call put2hex

mov al,0xff
call spi_inout
mov al,0xff
mov dx,spi_cs_ctl_port
out dx,al
mov al,0xff
call spi_inout

mov al,0x00	; OK
jmp cont0

fail0:
mov al,0xff	; FAIL

cont0:
;call print
pop bx
pop dx
pop cx
ret

delay_20ms:
push cx
mov cl,255
delay_20ms_loop:
nop
dec cl
jnz delay_20ms_loop
pop cx
ret

; transmit ah
; receive in al
; clobbers dx, flags
spi_inout:
mov al,ah
mov dx,spi_transmit_port
out dx,al
spi_inout1:
mov dx,spi_status_port
in al,dx
test al,0x01
jne spi_inout1
mov dx,spi_receive_port
in al,dx
ret

%include "put.s"

welcome: db 0ah,0dh,'Welcome to CPU86 BIOS (c) N.Sauzede 2017',0xa,0xd,0
FAIL    DB      0Ah,0Dh,"FAIL",0
OK    DB      0Ah,0Dh,"OK",0
