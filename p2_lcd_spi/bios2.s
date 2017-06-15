BITS 16
CPU 8086

; BIOS not using MON88 interrupt service routines, to be ROMABLE at any address
; GPL license
; contains some MON88 parts (GPLv2+) from HT-LAB http://www.ht-lab.com
; contains some MyMon (MON86) (GPLv3) from N.Sauzede git@github.com:nsauzede/mon86.git

;SPI at 0400-0407
%define spi_clk_div_port 0x0404
%define spi_receive_port 0x0403
%define spi_transmit_port 0x0402
%define spi_status_port 0x0401
%define spi_cs_ctl_port 0x0400

; 16550 UART settings, use COM1
;----------------------------------------------------------------------

; Actel 9.8421MHz
;   Xtal=40MHz-> 9.8421E6/38400/16=16
;BRATE_LOW   EQU 16
;BRATE_HIGH  EQU 0

; Assume Clk=40MHz
;   Xtal=40MHz-> 40MHz/38400/16=65.10->65
BRATE_LOW   EQU 65
BRATE_HIGH  EQU 0

; UART settings, COM1
COM1        EQU     03F8h
COM2        EQU     02F8h
COMPORT     EQU     COM1

THRE        EQU     020h                        ; Transmit Holding Register Empty (bit5)
TEMT        EQU     040h                        ; Transmitter Empty (bit6 or LSR)
DR          EQU     001h                        ; Data Ready (bit1 of LSR)

THR         EQU     COMPORT                     ; point to Transmit data port
RBR         EQU     COMPORT                     ; point to Receive data port
LSR         EQU     COMPORT+5                   ; Line Status Register
MCR         EQU     COMPORT+4                   ; Modem, control register
DLL         EQU     COMPORT+0                   ; LSB Divisor, DLAB=1
DLM         EQU     COMPORT+1                   ; MSB Divisor, DLAB=1
LCR         EQU     COMPORT+3                   ; Line Control Register     
FCR         EQU     COMPORT+2                   ; Fifo Control Register
IIR         EQU     COMPORT+2                   ; Interrupt Identification register
IER         EQU     COMPORT+1                   ; Interrupt Enable register, DLAB=0


ORG 0x0000

; we define stack area (MON88 insists on that)
times 0x100 db 0x90

; this is the BIOS entry point
entry:
	cli
;	mov al,'B'
;	call txchar
;	jmp $

;mov sp,0x0380
;;mov sp,0x1000
;mov ss,sp
;mov sp,0x0100

	mov ax,cs
; assume ds=cs for local prints
	mov ds,ax

; hook interrupt vectors at [0:xxx]
	xor di,di
	mov es,di
%if 1
; hook int3h vector at [0:0xc]
%if 1
	mov di,(3h)*4
%else
	mov di,(23h)*4
%endif
	;mov di,(1h)*4
	mov ax,int3_handler
	stosw
	mov ax,cs
	stosw
%endif
%if 1
; hook int1h vector at [0:0x4]
	mov di,(1h)*4
	mov ax,int3_handler
	stosw
	mov ax,cs
	stosw
%endif
; hook int13h vector at [0:0x4c]
	mov di,(13h)*4
; FIXME : on CPU86, following MOVs don't work ? MON88 after-effect ?
	;mov word [di],int13_handler
	;mov word [di+2],ax
	mov ax,int13_handler
	stosw
	mov ax,cs
	stosw
; hook int16h vector at [0:0x58]
	mov di,(16h)*4
	mov ax,int16_handler
	stosw
	mov ax,cs
	stosw

	mov di,(1eh)*4
	mov ax,int13_fdpt
	stosw
	mov ax,cs
	stosw

	call _init_serial

	xor di,di

%if 0
	mov ax,0x7001
	mov bx,0x6002
	mov cx,0x5003
	mov dx,0x4004
	mov si,0x3005
	mov di,0x2006
	mov bp,0x1007
;	int 1
	int3
%endif
	MOV     DX,welcome
	call print

	mov dx,0x500
	mov al,0x01
	out dx,al

%if 0
; to debug the "repe cmpsb" issue
	int3
	xor si,si
	mov ds,si
	mov es,si
	xor di,di
	mov cx,0xb
	repz cmpsb
	jmp $
%endif

; read sectors from drive
; ah=02 al=sectors_count
; ch=cylinder cl=sector
; dh=head dl=drive
; [es:bx]=buffer
%if 1
mov ax,0x0201
%else
mov ax,0x0202
%endif
mov cx,0x0001
mov dx,0x0000
mov bx,0x0000
mov es,bx
mov bx,0x7c00
int 13h
jnc nerr0

err0:
mov dx,0x500
mov al,0x0f
out dx,al
;jmp $
jmp exit

nerr0:
mov dx,0x500
mov al,0x02
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

; these values at boot from QEMU
	xor bp,bp
	xor cx,cx
	xor dx,dx
	xor bx,bx
	xor si,si
	xor di,di
	xor ax,ax
	mov ds,ax
	mov es,ax
	mov ss,ax
	mov sp,0x6ef0
	mov ax,0x202
	push ax
	popf
	mov ax,0xaa55
	int3
	jmp 0:0x7c00
;	jmp $

exit:
	int3	; return to our monitor

die:	; return to MON88
	MOV     AX,04C00h
	int 0x21

; clobbers AL, DX
_init_serial:
; Set baudrate for 16550
;----------------------------------------------------------------------
INITCOM:    MOV     AL,080h                     ; Init 16550, DLAB=1
            MOV     DX,LCR
            OUT     DX,AL

            MOV     AL,BRATE_LOW                ; 25MHz/(16*38400)=41 (40.6).
            MOV     DX,DLL
            OUT     DX,AL                       ; Set low byte Latch Divisor

            MOV     AL,BRATE_HIGH               ;
            MOV     DX,DLM
            OUT     DX,AL                       ; Set high byte Latch Divisor

            MOV     AL,03
            MOV     DX,LCR
            OUT     DX,AL                       ; 8 Bits, No Parity, 1 Stop Bit, DLAB=0

            MOV     AL,0C7h
            MOV     DX,FCR
            OUT     DX,AL                       ; FIFO Control Register

            MOV     AL,08h                      ; out1 low, out2 high, for debug only...
            MOV     DX,MCR
            OUT     DX,AL
            ret


s_ax: db 'ax',0
s_bx: db 'bx',0
s_cx: db 'cx',0
s_dx: db 'dx',0
s_sp: db 'sp',0
s_bp: db 'bp',0
s_si: db 'si',0
s_di: db 'di',0
s_ds: db 'ds',0
s_es: db 'es',0
s_ss: db 'ss',0
s_cs: db 'cs',0
s_ip: db 'ip',0
s_fl: db 'fl',0

; entering int13
; in our mon
;ax=0201 bx=7C00 cx=0001 dx=0000 sp=00F4 bp=0005 si=0006 di=0000
;ds=E000 es=0000 ss=0380 cs=E000 ip=02FE fl=F06E

; in MON88
;AX=0201 BX=7C00 CX=0001 DX=0000 SP=00FA BP=0005 SI=0006 DI=0000
;DS=E000 ES=0000 SS=0380 CS=E000 IP=02FE   ODIT-SZAPC=0000-01010
;E000:02FE CC             INT    3

int3_handler:
	push bp
	mov bp,sp
	push di
	push es
	push si
	push ds
	push dx
	push cx
	push bx
	push ax
; from now on, we have :
; bp+6 flags
; bp+4 cs
; bp+2 ip
; bp+0 bp
; bp-2 di
; bp-4 es
; bp-6 si
; bp-8 ds
; bp-10 dx
; bp-12 cx
; bp-14 bx
; bp-16 ax
	call _crlf

	mov si,s_ax
	mov ax,[bp-16]	; ax
	call _cprint_str_ax	; ax

	mov si,s_bx
	mov ax,bx
	call _cprint_str_ax	; bx

	mov si,s_cx
	mov ax,cx
	call _cprint_str_ax	; cx

	mov si,s_dx
	mov ax,dx
	call _cprint_str_ax	; dx

	mov si,s_sp
	lea ax,[bp+8]	; sp
	call _cprint_str_ax	; sp

	mov si,s_bp
	mov ax,[bp+0]
	call _cprint_str_ax	; bp

	mov si,s_si
	mov ax,[bp-6]	; si
	call _cprint_str_ax	; si

	mov si,s_di
	mov ax,di
	call _cprint_str_ax	; di

	call _crlf

	mov si,s_ds
	mov ax,ds
	call _cprint_str_ax	; ds

	mov si,s_es
	mov ax,es
	call _cprint_str_ax	; es

	mov si,s_ss
	mov ax,ss
	call _cprint_str_ax	; ss

	mov si,s_cs
	mov ax,[bp+4]	; cs
	mov ds,ax		; store cs for later cs:ip dump..
	call _cprint_str_ax	; cs

	mov si,s_ip
	mov ax,[bp+2]	; ip
	mov bx,ax		; store ip for later cs:ip dump..
;	test WORD [SS:BP+6],0100h
;	jnz not_int_3
;	dec ax			; if int3, must decr shown IP
;not_int_3:
	call _cprint_str_ax	; ip

	mov si,s_fl
	mov ax,[bp+6]	; fl
	and ax,0x0eff	; remove reserved bits
	call _cprint_str_ax	; fl

	mov si,bx
	mov cx,6
dump0:
	lodsb	; read bytes at cs:ip
	call put2hex
	loop dump0

	mov al,'>'
	call txchar
	call rxchar
	cmp al,'s'
	je step
	cmp al,'c'
	je cont
	cmp al,'q'
	je die
	jmp leave
step:
;ODITSZA1P1C=0000-01010
;               T SZ A  P C
;F06E : 1111 0000 0110 1110
	or WORD [SS:BP+6],0100h	; set TF in stack stored flags
	jmp leave
cont:
	and WORD [SS:BP+6],~0100h	; clear TF in stack stored flags
leave:

	pop ax
	pop bx
	pop cx
	pop dx
	pop ds
	pop si
	pop es
	pop di
	pop bp
	iret

; print string from cs:si, '=', AX, ' '
; clobbers ax
_cprint_str_ax:
	push ax
	call cputs
	mov al,'='
	call txchar
	pop ax
	call put4hex
	mov al,' '
	call txchar
	ret

int16_handler:
	push dx
	push bp
	mov bp,sp

;----------------------------------------------------------------------
; Interrupt 16H, I/O function
; Service   00   Wait for keystroke
; Input
; Output    AL   Character, AH=ScanCode=0
; Changed   AX
;----------------------------------------------------------------------
isr16_00:
	cmp ah,0x00
	jne isr16_01

	call rxchar
	xor ah,ah
	jmp isr16_ret

;----------------------------------------------------------------------
; Interrupt 16H, I/O function
; Service   01   Check for keystroke (kbhit)
; Input
; Output    AL   Character, AH=ScanCode=0 ZF=0 when keystoke available
; Changed   AX
;----------------------------------------------------------------------
isr16_01:
;	cmp ah,0x01
;	jne isr16_x
isr16_x:
	mov dx,0x500
	mov al,0x0e
	out dx,al
	jmp $

	xor ah,ah

isr16_ret:
	pop bp
	pop dx
	iret

;----------------------------------------------------------------------
; Receive character in AL, blocking
; AL Changed
;----------------------------------------------------------------------
rxchar:
	PUSH    DX
	MOV     DX,LSR
WAITRX:
	IN      AL,DX
	AND     AL,DR                       ; Character pending?
	JZ      WAITRX                      ; No, then wait
	MOV     DX,RBR
	IN      AL,DX                       ; return result in al
	CALL    txchar                      ; Echo back
	POP     DX
	RET

;----------------------------------------------------------------------
; Transmit character in AL
;----------------------------------------------------------------------
txchar:     PUSH    DX
            PUSH    AX                          ; Character in AL
            MOV     DX,LSR                      ; Read Line Status Register          
WAITTX:     IN      AL,DX
            AND     AL,THRE                     ; Transmit Holding Register Empty?
            JZ      WAITTX                      ; no, wait
            MOV     DX,THR                      ; point to data port
            POP     AX
            OUT     DX,AL
            POP     DX
            RET

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
;	int3
push bp
mov bp,sp
push dx
push bx
push di
push si
push es
push cx
push ax

cmp ah,00h
je int13_reset0
cmp ah,01h
je int13_status0
cmp ah,02h
je int13_read0
jmp int13_fail0

int13_reset0:
jmp bailout0

int13_status0:
xor ah,ah
jmp ok_code0

s_int13read_cnt: db 13,10,'INT13:cnt',0
s_int13read_cyl: db 'cyl',0
s_int13read_sec: db 'sec',0
s_int13read_head: db 'head',0
s_int13read_drv: db 'drv',0
s_int13read_es: db 'es',0
s_int13read_bx: db 'bx',0
s_int13read_lba: db 'LBA',0
; read sectors from drive
; ah=02 al=sectors_count
; ch=cylinder cl=sector
; dh=head dl=drive
; [es:bx]=buffer
int13_read0:
push ax
mov si,s_int13read_cnt
xor ah,ah
call _cprint_str_ax
mov si,s_int13read_cyl
mov al,ch
call _cprint_str_ax
mov si,s_int13read_sec
mov al,cl
call _cprint_str_ax
mov si,s_int13read_head
mov al,dh
call _cprint_str_ax
mov si,s_int13read_drv
mov al,dl
call _cprint_str_ax
mov si,s_int13read_es
mov ax,es
call _cprint_str_ax
mov si,s_int13read_bx
mov ax,bx
call _cprint_str_ax
pop ax

%if 1
	mov di,bx
	mov bx,ax
	xchg bx,cx	; bx now contains cyl:sec
	mov ch,cl	; ch now contains nsec
;ax<=(ch*2+dh)*SPT+(cl-1)
	shl bh,1	; bh=cyl*2
	add bh,dh	; bh=cyl*2+head
	mov al,9
	mul bh		; ax=(cyl*2+head)*SPT
	xor bh,bh	; bx=sec
	add ax,bx	; ax=(cyl*2+head)*SPT+sec
	dec ax		; ax=(cyl*2+head)*SPT+sec-1
%else
	mov di,bx
	xchg ax,cx
	mov ch,cl
	dec ax
%endif
	push ax
	mov si,s_int13read_lba
	call _cprint_str_ax
	pop ax

;	int3
;read ch sectors (512 bytes) at ax from SDCARD (SPI mode) into [es:di]
; clobbers ax, flags
; returns al=00 if OK, al=ff if FAIL
call _spi_read
mov ah,al
test ah,ah
jz ok_code0
int13_fail0:
or WORD [SS:BP+8],0001h	; set CF in stack stored flags
jmp bailout0

ok_code0:	; this guy patch ah in return ax
pop cx
mov	ch,ah		; ah=return code
push cx

ok_cf0:
and WORD [SS:BP+8],0fffeh	; clear CF in stack stored flags

bailout0:
pop ax
pop cx
pop es
pop si
pop di
pop bx
pop dx
pop bp
;jmp $
iret

print:
;mov ax,0900h
;INT     21h
	push si
	mov si,dx
	call puts
	pop si
	ret

;----------------------------------------------------------------------
; Write zero terminated string to CONOUT
; String pointed to by DS:[SI]
;----------------------------------------------------------------------
puts:       PUSH    SI
            PUSH    AX
            CLD
PRINT_:      LODSB                               ; AL=DS:[SI++]
            OR      AL,AL                       ; Zero?
            JZ      PRINT_X                     ; then leave
            CALL    txchar
            JMP     PRINT_                       ; Next Character
PRINT_X:    POP     AX
            POP     SI
            RET

;----------------------------------------------------------------------
; Write zero terminated string to CONOUT
; String pointed to by CS:[SI]
;----------------------------------------------------------------------
cputs:
	push ds
	push cs
	pop ds
	call puts
	pop ds
	ret

;read ch sectors (512 bytes) at ax from SDCARD (SPI mode) into [es:di]
; clobbers ax, flags
; returns al=00 if OK, al=ff if FAIL
_spi_read:
;	int3
push cx
push dx
push bx
push bp
mov bp,ax

mov al,0xff
mov dx,spi_clk_div_port
out dx,al
; al already 0xff
mov dx,spi_cs_ctl_port
out dx,al
mov cl,12
mov ah,0xff
loop_init0:
call _spi_inout
dec cl
jnz loop_init0
mov al,0xfe
mov dx,spi_cs_ctl_port
out dx,al

mov ah,0x40
call _spi_inout
mov ah,0x00
call _spi_inout
call _spi_inout
call _spi_inout
call _spi_inout
mov ah,0x95
call _spi_inout
mov ah,0xff
call _spi_inout
call _spi_inout
cmp al,0x01
jne fail0

mov ah,0x48
call _spi_inout
mov ah,0x00
call _spi_inout
call _spi_inout
mov ah,0x01
call _spi_inout
mov ah,0xaa
call _spi_inout
mov ah,0x87
call _spi_inout
mov ah,0xff
call _spi_inout
call _spi_inout
cmp al,0x01
jne fail0
call _spi_inout
call _spi_inout
call _spi_inout
call _spi_inout

mov cl,255
sd_read_loop_init1:
mov ah,0x77
call _spi_inout
mov ah,0x00
call _spi_inout
call _spi_inout
call _spi_inout
call _spi_inout
mov ah,0x65
call _spi_inout
mov ah,0xff
call _spi_inout
call _spi_inout
cmp al,0x01
jne fail0
mov ah,0x69
call _spi_inout
mov ah,0x40
call _spi_inout
mov ah,0x00
call _spi_inout
call _spi_inout
call _spi_inout
mov ah,0x77
call _spi_inout
mov ah,0xff
call _spi_inout
call _spi_inout
cmp al,0x00
je sd_read_loop_init1_done
dec cl
jz fail0
call delay_20ms
jmp sd_read_loop_init1
sd_read_loop_init1_done:

;	int3
mov ah,0x51
;mov ah,17|0x40
;mov ah,18|0x40
call _spi_inout
mov ah,0x00
call _spi_inout
call _spi_inout
mov ax,bp			; bp contains sector address
call _spi_inout
mov ax,bp			; bp contains sector address
mov ah,al
call _spi_inout
mov ah,0x75
call _spi_inout
mov ah,0xff
call _spi_inout
call _spi_inout
cmp al,0x00
jne fail0
;call crlf

wait_token:
mov ah,0xff
call _spi_inout
cmp al,0xfe
jz sd_read_loop_begin
jmp wait_token

;	int3
sd_read_loop_begin:
mov bh,02h			; 1 sector=2*256 bytes
begin0:
mov bl,0x00			; 00 means 256 loops
begin1:
mov al,0xff
call _spi_inout
stosb
;call put2hex
dec bl
jnz begin1
dec bh
jnz begin0
;call crlf
mov al,0xff
call _spi_inout		; read two-
;stosb
;call put2hex
call _spi_inout		; -byte checksum (8A08 for first sector of MSDOS3.1)
;stosb
;call put2hex

inc bp
dec ch
jnz sd_read_loop_init1_done

mov al,0xff
call _spi_inout
mov al,0xff
mov dx,spi_cs_ctl_port
out dx,al
mov al,0xff
call _spi_inout

;dec ch
;jnz wait_token
;
;mov ah,12|0x40		; CMD12=STOP
;call _spi_inout
;mov ah,0x00
;call _spi_inout
;call _spi_inout
;call _spi_inout
;call _spi_inout
;mov ah,0x75
;call _spi_inout
;mov ah,0xff
;call _spi_inout
;call _spi_inout
;cmp al,0x00
;jne fail0

mov al,0x00	; OK
jmp cont0

fail0:
mov al,0xff	; FAIL

cont0:
;call print
pop bp
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
_spi_inout:
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

welcome: db 0ah,0dh,'Welcome to CPU86 BIOS2 (c) N.Sauzede 2017',0xa,0xd,0
FAIL    DB      0Ah,0Dh,"FAIL",0
OK    DB      0Ah,0Dh,"OK",0
