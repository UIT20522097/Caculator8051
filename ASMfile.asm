ORG 00H
SJMP 30H


ORG 30H
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
RET
Sw1:
MOV 70H, #1
RET
Sw2:
MOV 70H, #2
RET
Sw3:
MOV 70H, #3
RET
Sw4:
MOV 70H, #4
RET
Sw5:
MOV 70H, #5
RET
Sw6:
MOV 70H, #6
RET
Sw7:
MOV 70H, #7
RET
Sw8:
MOV 70H, #8
RET
Sw9:
MOV 70H, #9
RET
Swcong:
MOV 70H, #11
RET
Swtru:
MOV 70H, #12
RET
Swnhan:
MOV 70H, #13
RET
Swchia:
MOV 70H, #14
RET
Swon:
MOV 70H, #0
MOV 71H, #0
MOV R0, #0
MOV R1, #0
MOV R2, #0
MOV R3, #0
MOV R4, #0
MOV R5, #0
MOV R6, #0
MOV R7, #0
MOV SP, #07H
LJMP 00H
RET
Swbang:
CALL ProcessResult
CALL ResultNumber
CALL ProcessConvertNumberBINtoBCD
RET

ProcessKey:
CLR C
MOV R5, 70H
CJNE R5, #10, DivideOperatorNumber
DivideOperatorNumber:
JC KeyNumber
KeyOperator:
MOV A, 71H
JNZ ReCallKeyOperator
CALL ConvertOperatorToLCD
CALL WriteData
MOV 71H, 70H
ReCallKeyOperator:RET

KeyNumber:
MOV	A, 70H
ADD	A, #00110000B
CALL WriteData
MOV R4, 70H
CALL ProcessConvertNumberBCDtoBIN
RET


ProcessResult: ; Xu ly phep toan xuat ra ket qua
MOV	A, 71H
CJNE A, #11, Greater11R
CALL Phepcong
SJMP ReCallProcessResult
Greater11R:
CJNE A, #12, Greater12R
CALL Pheptru
SJMP ReCallProcessResult
Greater12R:
CJNE A, #13, Greater13R
CALL Phepnhan
SJMP ReCallProcessResult
Greater13R:
CALL Phepchia
ReCallProcessResult: RET

ConvertOperatorToLCD:
MOV	A, 70H
CJNE A, #11, Greater11
MOV A, #00101011B  ; Ma dau
RET
Greater11:
CJNE A, #12, Greater12
MOV A, #00101101B  ; Ma dau
RET
Greater12:
CJNE A, #13, Greater13
MOV A, #01111000B  ; Ma dau
RET
Greater13:
MOV A, #11111101B  ; Ma dau
RET

ResultNumber:
	 MOV	A, #0CH
	 CALL	WriteCmd
	 MOV	A, #0CFH
	 CALL	WriteCmd
	 MOV	A, #04H
	 CALL	WriteCmd
	 RET
	 	
Execute:
	 MOV	A, B
	 ADD	A, #00110000B
	 CALL	WriteData
	 RET

Error:
     MOV	A, #01H
	 CALL	WriteCmd	
	 MOV	A, #85H		
	 CALL	WriteCmd
	 MOV	A, #06H		
	 CALL	WriteCmd
	 MOV	R6, #6
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
	 CALL	CheckKeyOn
OutRange:
	 MOV	A, #01H
	 CALL	WriteCmd
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
	 CALL	CheckKeyOn

ProcessConvertNumberBCDtoBIN:  ; Chuyen doi so BCD sang Binary
MOV A, 71H
JNZ NumberTwo
NumberOne:
MOV A, R2
MOV R5, #1
SJMP SetupConvert
NumberTwo:
MOV A, R3
MOV R5, #2
SetupConvert:
MOV B, #10
MUL AB
MOV R6, B
CJNE R6, #0, CallOutRange
ADD A, R4
JC CallOutRange
CJNE R5, #1, StoreNumber
MOV R2, A
SJMP ReCallProcessConvertNumberBCDtoBIN
StoreNumber: MOV R3, A
ReCallProcessConvertNumberBCDtoBIN: RET

CallOutRange: CALL OutRange

Phepcong:
MOV A, R2
ADD A, R3
JC CallOutRange
MOV 50H, A
RET

Pheptru:
MOV A, R2
SUBB A, R3
JC CallOutRange
MOV 50H, A
RET

Phepnhan:
MOV A, R2
MOV B, R3
MUL AB
MOV R6, B
CJNE R6, #0, CallOutRange
MOV 50H, A
RET

Phepchia:
MOV A, R3
JZ CallError
MOV A, R2
MOV B, R3
DIV AB
MOV 50H, A
RET

CallError: CALL Error

ProcessConvertNumberBINtoBCD:
MOV A, 50H
MOV B, #10
DIV AB
MOV 50H, A
CALL Execute
MOV A, 50H
JNZ ProcessConvertNumberBINtoBCD
SJMP CheckKeyOn
RET 


CheckKeyOn:	; Check key ON/C
MOV P1,#0F7H ; Keys: ON/C,0,=,+
JNB P1.4,CallSwon
SJMP CheckKeyOn 
CallSwon: CALL Swon


Error1: DB	"ERROR!"
OutRange1: DB	"OUT RANGE!"
END
