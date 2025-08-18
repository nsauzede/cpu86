;***********************************************************************************
; File name     :   jump0400.asm
;
; Purpose       :    
;
; Authors       :   
;
; Reference     :   
;
; Note          :      
; -----------------------------------------------------------------------------------
; Version  Author           Date            Changes
; 0.1      Hans Tiggeler    10 October 04   First Version
;************************************************************************************

_TEXT   SEGMENT BYTE PUBLIC 'CODE'

        ASSUME  cs:_TEXT, SS:NOTHING, DS:NOTHING, ES:NOTHING

;------------------------------------------------------------------------------------
; Reset Vector
;------------------------------------------------------------------------------------
        ORG     000F0h                          ; Top of 256 Byte ROM address space 
               
COLD:   DB      0EAh                            ; Jump to beginning of MON88
        DW      0400h							; located in the bottom 14K
        DW      0000h							; at 0000:0400

_TEXT   ENDS
        END COLD
