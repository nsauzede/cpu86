;***********************************************************************************
; File name     :   ldintel.asm
;
; Purpose       :   Intel Hex Serial Loader 
;
; Authors       :   
;
; Reference     :   
;
; Note          :      
; -----------------------------------------------------------------------------------
; Version  Author           Date            Changes
; 0.1      Hans Tiggeler    10 October 04   First Version
; 0.2	   Hans Tiggeler    12 November 06  Changed for 16550 UARTs
; 0.3      Hans Tiggeler    30 december 07  Changed for Dragmorn1 board (40Kbyte SRAM)
;************************************************************************************

; Baudrate values
; Drigmorn1 board 40MHz
;   Xtal=40MHz-> 40MHz/38400/16=65.10->65
BRATE_LOW   EQU 65
BRATE_HIGH  EQU 0

COM1        EQU     03F8h 
COM2        EQU     02F8h 
COMPORT		EQU		COM1

THRE 		EQU		020h               			; Transmit Holding Register Empty (bit5)
TEMT		EQU		040h               			; Transmitter Empty (bit6)
DR			EQU		001h               			; Data Ready (bit1 of LSR)
THR			EQU		COMPORT        				; point to Transmit data port
RBR			EQU		COMPORT        				; point to Receive data port
LSR 		EQU		COMPORT+5 					; Line Status Register
MCR			EQU		COMPORT+4					; Modem, control register
DLL			EQU		COMPORT+0					; LSB Divisor, DLAB=1
DLM			EQU		COMPORT+1					; MSB Divisor, DLAB=1
LCR			EQU		COMPORT+3					; Line Control Register		
FCR			EQU    	COMPORT+2					; Fifo Control Register

EOF_REC     EQU     01                          ; End of file record
DATA_REC    EQU     00                          ; Load data record
EAD_REC     EQU     02                          ; Extended Address Record, use to set CS
SSA_REC     EQU     03                          ; Execute Address

_TEXT   SEGMENT BYTE PUBLIC 'CODE'

        ASSUME  cs:_TEXT, SS:NOTHING, DS:NOTHING, ES:NOTHING

COLD:   CLI										; Disable Interrupts
		MOV     AX,CS                           ; Cold entry point
        MOV     DS,AX                           ; DS=F000
        
        XOR     AX,AX                           ; Set SP to top of xKbyteblock
        MOV     SS,AX
;		MOV		AH,080h							; 32K, 0000:8000
		MOV		AH,0A0h
        MOV     SP,AX                           ; Set Stackpointer top of 40K 0000:A000

        MOV     ES,AX                           ; Default load segment=0
                 
INITCOM:MOV		AL,080h							; Init 16550, DLAB=1
		MOV     DX,LCR
		OUT		DX,AL
						
		MOV		AL,BRATE_LOW					; 25MHz/(16*38400)=41 (40.6) 
		MOV		DX,DLL
		OUT		DX,AL							; Set low byte Latch Divisor

		MOV		AL,BRATE_HIGH					; 
		MOV		DX,DLM
		OUT		DX,AL							; Set high byte Latch Divisor

		MOV		AL,03
		MOV		DX,LCR
		OUT		DX,AL							; 8 Bits, No Parity, 1 Stop Bit, DLAB=0
                 
        MOV     AL,'>'							; This is all you get after reset!
        JMP     DISPCH

ERROR:  MOV     AL,'E'                          ; Indicate load error
DISPCH: CALL    TXCHAR

START:  CALL    RXCHAR                          ; Wait for ':'
        CMP     AL,':'
        JNE     START

        XOR     CX,CX                           ; CL=Byte count
        XOR     BX,BX                           ; BL=Checksum

        CALL    RXBYTE                          ; Get length in CX
        MOV     CL,AL

        CALL    RXBYTE                          ; Get Address HIGH
        MOV     AH,AL
        CALL    RXBYTE                          ; Get Address LOW
        MOV     DI,AX                           ; DI=Store Address

        CALL    RXBYTE                          ; Get Record Type
        CMP     AL,EOF_REC                      ; End Of File Record
        JE      GOCHECK
        CMP     AL,DATA_REC                     ; Data Record?
        JE      GOLOAD
        CMP     AL,EAD_REC                      ; Extended Address Record?
        JE      GOEAD
        CMP     AL,SSA_REC                      ; Start Segment Address Record?
        JNE     ERROR

GOSSA:  MOV     CX,2                            ; Get 2 word
NEXTW:  CALL    RXBYTE
        MOV     AH,AL
        CALL    RXBYTE
        PUSH    AX                              ; Push CS, IP
        LOOP    NEXTW
		CALL    RXBYTE							; Get Checksum
		SUB		BL,AL							; Remove checksum from checksum
		NOT		AL								; Two's complement
		ADD		AL,1
        CMP     AL,BL                           ; Checksum held in BL
        JNE     ERROR                           
        RETF									; Execute program

GOCHECK:CALL    RXBYTE
		SUB		BL,AL							; Remove checksum from checksum
		NOT		AL								; Two's complement
		ADD		AL,1
        CMP     AL,BL                           ; Checksum held in BL
        JNE     ERROR
        MOV     AL,'.'                          ; After each successful record print a '.'
        JMP     DISPCH

RXNIB:  CALL    RXCHAR                          ; Get Hex Character in AL
        CMP     AL,'0'                          ; Check to make sure 0-9,A-F
        JB      ERROR
        CMP     AL,'F'      
        JA      ERROR
        CMP     AL,'9'      
        JBE     SUB0        
        CMP     AL,'A'      
        JB      ERROR
        SUB     AL,07h                          ; Convert to hex
SUB0:   SUB     AL,'0'                          ; Convert to hex
        RET

GOLOAD: CALL    RXBYTE                          ; Read Bytes
        STOSb                                   ; ES:DI <= AL
        LOOP    GOLOAD
        JMP     GOCHECK

GOEAD:  CALL	RXBYTE
		MOV		AH,AL
		CALL	RXBYTE
		MOV     ES,AX                           ; Set Segment address (ES)
		JMP		GOCHECK

RXBYTE: XCHG	BH,AH							; save AH register
		CALL    RXNIB
        MOV     AH,AL
		SHL		AH,1						   	; Can't use CL
		SHL		AH,1
		SHL		AH,1
		SHL		AH,1
        CALL    RXNIB
        OR      AL,AH
        ADD     BL,AL                           ; Add to check sum
        XCHG	BH,AH							; Restore AH register
        RET

;------------------------------------------------------------------------------------
; Transmit character in AL
; AL,DX Changed
;------------------------------------------------------------------------------------
TXCHAR: PUSH    AX                              ; Character in AL
        MOV     DX,LSR							; Read Line Status Register          
WAITTX: IN      AL,DX                           
        AND     AL,THRE                  		; Transmit Holding Register Empty?
        JZ      WAITTX                          ; no, wait
        MOV     DX,THR              			; point to data port
        POP     AX
        OUT     DX,AL
        RET


;------------------------------------------------------------------------------------
; Receive character in AL, blocking
; AL,DX Changed
;------------------------------------------------------------------------------------
RXCHAR: MOV     DX,LSR
WAITRX:	IN      AL,DX
        AND     AL,DR							; Character pending?
        JZ      WAITRX                          ; No, wait
        MOV     DX,RBR    
        IN      AL,DX                           ; return result in al
        RET


;------------------------------------------------------------------------------------
; Reset Vector
;------------------------------------------------------------------------------------
        ORG     000F0h                          ; Top of 256 Byte ROM address space        
        DB      0EAh                            ; Jump to beginning of program
        DW      COLD
        DW      0FFF0h

_TEXT   ENDS
        END COLD
