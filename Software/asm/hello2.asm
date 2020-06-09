;-------------------------------------------------------------------------------
; Hello World using int21 display string routine
;-------------------------------------------------------------------------------
ORG  	0100h		    			; result in .com start IP=0100

MOV     DX,HELLO              ; String offset in DX, Segment in DS
call print

mov cx,ds
mov es,cx

mov si,STR1
mov di,DIFF2
call strcmp

mov si,STR1
mov di,SAME2
call strcmp

exit:
MOV	AX,04C00h					; exit with code 0 (in AL)
INT     021h                    	; back to bootloader/monitor

strcmp:
mov cx,6
rep cmpsb

jnz is_different

is_same:
MOV     DX,SAME              ; String offset in DX, Segment in DS
call print
jmp strcmp_exit
is_different:
MOV     DX,DIFF              ; String offset in DX, Segment in DS
call print
strcmp_exit:

ret

print:
MOV	AX,0900h					; Call print string bios service
INT	21h							; in mon88
ret

STR1 db "COUCOU"
DIFF2 db "AOUCOU"
SAME2 db "COUCOU"

HELLO  	DB    	0Ah,0Dh,"*** Hello ***",0

SAME  	DB    	0Ah,0Dh,"*** SAME ***",0
DIFF  	DB    	0Ah,0Dh,"*** DIFFERENT ***",0
