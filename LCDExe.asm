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
	
Init:
	 MOV 	A, #0FFH	; Loads A with all 1's
	 MOV 	P2, #00H	; Initializes P2 as output port
	
	 MOV	A, #38H		; 8-bit, 2 line, 5x7 dots
	 CALL	WriteCmd
	 CALL	Delay
	 MOV	A, #0EH		; Display ON cursor, ON
	 CALL	WriteCmd
	 CALL	Delay
	 MOV	A, #01H		; Clear display
	 CALL	WriteCmd
	 CALL	Delay
	 MOV	A, #06H		; Auto increment mode, i.e., when we send char, cursor position moves right
	 CALL	WriteCmd
	 CALL	Delay

Result:	
	 MOV	60H, #1
	 MOV	61H, #2
	 MOV	62H, #3
	 MOV	63H, #4
	 MOV	64H, #5
	 MOV	65H, #6
	 MOV	66H, #7
	 MOV	67H, #8
	 MOV	68H, #9
	 MOV	69H, #8
	 MOV	6AH, #7
	 MOV	6BH, #6
	 MOV	6CH, #5
	 MOV	6DH, #4
	 MOV	6EH, #3
	 MOV	6FH, #2
	 MOV	R0, #60H
	 MOV	A, #0CFH
	 CALL	WriteCmd
	 MOV	A, #04H
	 CALL	WriteCmd

	 MOV	R7, #16
	 CALL	Execute
Next:	 
	 DJNZ	R7, Execute
Again:	 SJMP	Again	
Execute:
	 MOV	A, @R0
	 ADD	A, #00110000B
	 CALL	WriteData
	 CALL	Delay
	 INC	R0
	 SJMP	Next
WriteCmd:	
	MOV 	P2, A	
	CLR 	RS				; RS = 0 for command
	CLR 	RW				; RW = 0 for write
	SETB 	EN				; EN = 1 for high pulse
	CALL	Delay			; Call DELAY subroutine
	CLR 	EN				; EN = 0 for low pulse
	RET
WriteData: 	
	MOV 	P2, A	
	SETB 	RS				; RS = 1 for data
	CLR 	RW				; RW = 0 for write
	SETB 	EN				; EN = 1 for high pulse
	CALL	Delay			; Call DELAY subroutine
	CLR 	EN				; EN = 0 for low pulse
	RET
Delay: 	MOV 	R3, #255
L2: 	MOV 	R4, #255	
L1: 	DJNZ 	R4, L1
	DJNZ 	R3, L2
	RET
	

;====================================================================
Finish:
      END
