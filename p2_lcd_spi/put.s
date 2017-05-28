BITS 16
CPU 8086

put4hex:
	XCHG    AL,AH                       ; Write AX in hex
	CALL    put2hex
	XCHG    AL,AH
	CALL    put2hex
	RET

put2hex:
	PUSH    AX                          ; Save the working register
	SHR     AL,1
	SHR     AL,1
	SHR     AL,1
	SHR     AL,1
	CALL    PUTHEX1                     ; Output it
	POP     AX                          ; Get the LSD
	CALL    PUTHEX1                     ; Output
	RET

PUTHEX1:
	PUSH    AX                          ; Save the working register
	AND     AL, 0FH                     ; Mask off any unused bits
	CMP     AL, 0AH                     ; Test for alpha or numeric
	JL      NUMERIC                     ; Take the branch if numeric
	ADD     AL, 7                       ; Add the adjustment for hex alpha
NUMERIC:
	ADD     AL, '0'                     ; Add the numeric bias
	CALL    _txchar                     ; Send to the console
	POP     AX
	RET

crlf:
	push ax
	mov al,0xa
	call _txchar
	mov al,0xd
	call _txchar
	pop ax
	ret

_txchar:
	mov ah,0x0E
	int 10h
	ret
