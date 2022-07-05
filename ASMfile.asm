ORG 00H
SJMP 30H

RS EQU	P0.0
EN EQU	P0.2
Setup: ;Khoi tao cac bien xay dung
MOV TMOD, #00010001B ; Timer0 mode 1 and Timer1 mode1
; Init LCD display
InitLCD:
	 MOV 	A, #0FFH	; Loads A with all 1's
	 MOV 	P2, #00H	; Initializes P2 as output port

	 MOV	A, #01H		; Clear display
	 CALL	WriteCmd	
	 MOV	A, #38H		; 8-bit, 2 line, 5x7 dots
	 CALL	WriteCmd
	 MOV	A, #0EH		; Display ON cursor, ON
	 CALL	WriteCmd
	 MOV	A, #06H		; Auto increment mode, i.e., when we send char, cursor position moves right
	 CALL	WriteCmd
	 CALL	Delay
LJMP Main

Delay: ;Create delay time 20ms
MOV TH0, #HIGH(-20000)
MOV TL0, #LOW(-20000)
SETB TR0
JNB TF0, $
CLR TF0
CLR TR0
RET

Delay1: ;Create delay time 65ms
MOV TH1, #0
MOV TL1, #0
SETB TR1
JNB TF1, $
CLR TF1
CLR TR1
RET

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

Main:
; Waiting press keyboard
CALL GetKeyBoard
CALL ProcessKey
CALL Delay1
CALL Delay1
CALL Delay1
CALL Delay1
CALL Delay1
SJMP Main

Getkeyboard: ; Get value on the keys
MOV P1,#0FEH ; Keys: 7,8,9,?
JNB P1.4,Sw7
JNB P1.5,Sw8
JNB P1.6,Sw9
JNB P1.7,Swchia
MOV P1,#0FDH ; Keys: 4,5,6,x
JNB P1.4,Sw4
JNB P1.5,Sw5
JNB P1.6,Sw6
JNB P1.7,Swnhan
MOV P1,#0FBH ; Keys: 1,2,3,-
JNB P1.4,Sw1
JNB P1.5,Sw2
JNB P1.6,Sw3
JNB P1.7,Swtru
MOV P1,#0F7H ; Keys: ON/C,0,=,+
JNB P1.4,Swon
JNB P1.5,Sw0
JNB P1.6,Swbang
JNB P1.7,Swcong
SJMP Getkeyboard

Sw0:
MOV 70H, #0
CALL ProcessNumber
RET
Sw1:
MOV 70H, #1
CALL ProcessNumber
RET
Sw2:
MOV 70H, #2
CALL ProcessNumber
RET
Sw3:
MOV 70H, #3
CALL ProcessNumber
RET
Sw4:
MOV 70H, #4
CALL ProcessNumber
RET
Sw5:
MOV 70H, #5
CALL ProcessNumber
RET
Sw6:
MOV 70H, #6
CALL ProcessNumber
RET
Sw7:
MOV 70H, #7
CALL ProcessNumber
RET
Sw8:
MOV 70H, #8
CALL ProcessNumber
RET
Sw9:
MOV 70H, #9
CALL ProcessNumber
RET
Swcong:
MOV 71H, #11
CALL ProcessOperator
RET
Swtru:
MOV 71H, #12
CALL ProcessOperator
RET
Swnhan:
MOV 71H, #13
CALL ProcessOperator
RET
Swchia:
MOV 71H, #14
CALL ProcessOperator
RET
Swon:  ; Clear the registers

MOV SP, #07H
LJMP 00H
RET
Swbang:
CALL ProcessResult
CALL ResultNumber
CALL ProcessConvertNumberBINtoBCD
RET

;	Cac ham dac trung

InitTransportRegister:	; @R0 = @R1	vs R3 byte
MOV A, @R1
MOV @R0, A
INC R0
INC R1
DJNZ R3, InitTransportRegister
RET

CreateRegister: ; @R0 = 0   R3 byte
MOV @R0, #0
INC R0
DJNZ R3, CreateRegister
RET

