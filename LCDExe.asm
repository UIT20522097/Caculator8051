$NOMOD51
$INCLUDE (8051.MCU)
RS		EQU	P0.0
EN		EQU	P0.2

;====================================================================
      org   0000h
      jmp   Start

;====================================================================

      org   0100h
Start:	
	
Init:
	 MOV 	A, #0FFH	; Loads A with all 1's
	 MOV 	P2, #00H	; Initializes P2 as output port
	
	 MOV	A, #38H		; 8-bit, 2 line, 5x7 dots
	 CALL	WriteCmd
	 MOV	A, #0EH		; Display ON cursor, ON
	 CALL	WriteCmd
	 MOV	A, #01H		; Clear display
	 CALL	WriteCmd
	 
Error:	
	 MOV	A, #85H		
	 CALL	WriteCmd
	 MOV	A, #06H		
	 CALL	WriteCmd
	 MOV	R6, #5
	 MOV	R7, #0
	 MOV	DPTR, #Error1
Next1:	 
	 MOV	A, R7
	 MOVC	A, @A + DPTR
	 CALL	WriteData
	 INC	R7
	 DJNZ	R6, Next1
	 MOV	A, #0CH		
	 CALL	WriteCmd
	 SJMP	$
OutRange:
	 MOV	A, #82H		
	 CALL	WriteCmd
	 MOV	A, #06H		
	 CALL	WriteCmd
	 MOV	R6, #12
	 MOV	R7, #0
	 MOV	DPTR, #OutRange1
Next2:	 
	 MOV	A, R7
	 MOVC	A, @A + DPTR
	 CALL	WriteData
	 INC	R7
	 DJNZ	R6, Next2
	 MOV	A, #0CH		
	 CALL	WriteCmd
	 SJMP	$
WriteCmd:	
	MOV 	P2, A	
	CLR 	RS				; RS = 0 for command
	SETB 	EN				; EN = 1 for high pulse
	CALL	Delay			; Call DELAY subroutine
	CLR 	EN				; EN = 0 for low pulse
	RET
WriteData: 	
	MOV 	P2, A	
	SETB 	RS				; RS = 1 for data
	SETB 	EN				; EN = 1 for high pulse
	CALL	Delay			; Call DELAY subroutine
	CLR 	EN				; EN = 0 for low pulse
	RET
Delay: 	MOV 	R3, #50
L2: 	MOV 	R4, #255	
L1: 	DJNZ 	R4, L1
	DJNZ 	R3, L2
	RET
	
Error1: DB	'ERROR'
OutRange1: DB	'OUT OF RANGE'
;====================================================================
Finish:
      END
