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
mov sp,0x0380
;mov sp,0x1000
mov ss,sp
mov sp,0x0100
mov ax,cs
mov ds,ax
xor di,di
mov es,di
;mov di,(20-1)*4
; TODO : fix int13h hook!!
;mov word [di],int13_handler
;mov word [di+2],ax
sti
;mov dx,0x500
;mov al,0x55
;out dx,al
;mov es,ax
;call crlf
;call put4hex
;call crlf

MOV     DX,welcome
call print

;mov ax,0x0380
;mov di,0x0100
;mov di,0x0000
;mov di,0x0500
; assume es=0
mov di,0x7c00
call spi_read
;int 13h
;jmp 0:0x7c00

;exit:
MOV     AX,04C00h
int 0x21

int13_handler:
mov ax,0x0E41
int 10h
iret

print:
mov ax,0900h
INT     21h
ret

;read a sector from SDCARD (SPI mode)
spi_read:
push ax
push cx
push dx
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
;mov ah,0x20
call spi_inout
mov ah,0x00
call spi_inout
mov ah,0x75
call spi_inout
mov ah,0xff
call spi_inout
call spi_inout
cmp al,0x00
jne fail0
call crlf

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
call put2hex
dec cl
jnz begin1
dec ch
jnz begin0
call crlf
mov al,0xff
call spi_inout		; read two-
stosb
call put2hex
call spi_inout		; -byte checksum
stosb
call put2hex

mov al,0xff
call spi_inout
mov al,0xff
mov dx,spi_cs_ctl_port
out dx,al
mov al,0xff
call spi_inout

MOV     DX,OK
jmp cont0
fail0:
MOV     DX,FAIL
cont0:
call print
pop dx
pop cx
pop ax
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
