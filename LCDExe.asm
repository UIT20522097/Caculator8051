$NOMOD51
$INCLUDE (8051.MCU)
RS		EQU	P0.0
RW		EQU	P0.1
EN		EQU	P0.2

;====================================================================
      org   0000h
      jmp   Start

;====================================================================

      org   0100h
Start:	
	 MOV 	A, #0FFH	; Loads A with all 1's
	 MOV 	P2, #0H		; Initializes P2 as output port

	 MOV	A, #01H		; Clear display
	 CALL	WriteCmd	
	 MOV	A, #38H		; 8-bit, 2 line, 5x7 dots
	 CALL	WriteCmd
	 MOV	A, #0EH		; Display ON cursor, ON
	 CALL	WriteCmd
	 MOV	A, #06H		; Auto increment mode, i.e., when we send char, cursor position moves right
	 CALL	WriteCmd
	 CALL	DELAY
Main:
	 MOV	A, #'1'
	 CALL	WriteData
	 MOV	A, #'2'
	 CALL	WriteData
	 MOV	A, #'3'
	 CALL	WriteData
	 MOV	A, #'4'
	 CALL	WriteData
	 MOV	A, #'5'
	 CALL	WriteData
	 SJMP	Main
	 
WriteCmd:	
	MOV 	P2, A	; Load OUT_PORT with contents of A
	CLR 	RS				; RS = 0 for command
	CLR 	RW				; RW = 0 for write
	SETB 	EN				; EN = 1 for high pulse
	CALL	DELAY			; Call DELAY subroutine
	CLR 	EN				; EN = 0 for low pulse
	RET
WriteData: 	
	MOV 	P2, A	; Load OUT_PORT with contents of A
	SETB 	RS				; RS = 1 for data
	CLR 	RW				; RW = 0 for write
	SETB 	EN				; EN = 1 for high pulse
	CALL	DELAY			; Call DELAY subroutine
	CLR 	EN				; EN = 0 for low pulse
	RET
Delay: 	MOV 	R3, #255
L2: 	MOV 	R4, #255	
L1: 	DJNZ 	R4, L1
	DJNZ 	R3, L2
	RET
;====================================================================
      END
