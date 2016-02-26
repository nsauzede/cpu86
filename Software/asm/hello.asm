;-------------------------------------------------------------------------------
; Hello World using int21 display string routine 	   
;-------------------------------------------------------------------------------
	   	ORG  	0100h		    			; result in .com start IP=0100

		MOV     DX,OFFSET MESS              ; String offset in DX, Segment in DS
        MOV		AX,0900h					; Call print string bios service
		INT		21h							; in mon88
		
;waitk:	MOV		AH,01						; Get char
;		INT		21h
;		CMP		AL,'q'						; 'q' pressed?
;		JNE		waitk						; No, then wait

	   	MOV		AX,04C00h					; exit with code 0 (in AL)
        INT     021h                    	; back to bootloader/monitor

MESS  	DB    	0Ah,0Dh,"*** Hello World ***",0
	    DB    	0Ah,0Dh,"Press q to return to MON88......",0
