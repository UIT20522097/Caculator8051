 ORG 00H
LJMP 30H


ORG 30H
RS EQU	P0.0
RW EQU	P0.1
EN EQU	P0.2
; Cac thanh ghi >=70H tro di dung de lam bo nho tam rieng biet (Cac thanh ghi da su dung <=76H)
Setup: ;Khoi tao cac bien xay dung
; A, B la thanh ghi khong co dinh
; R0 Pointer Dynamic
; R1 Pointer Dynamic
; R2 Value Dynamic
; R3 Value Dynamic
; R4 Value Dynamic
; R5 Value Dynamic
; R6 Value Dynamic
; R7 Value Dynamic
;MOV IE, #10000100B ; External interrupt with P3.2 
MOV TMOD, #00010001B ; Timer0 mode 1 and Timer1 mode1
; LCD display
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

Main:
; Waiting press keyboard
CALL GetKeyBoard
CALL ProcessKey
CALL Delay1
CALL Delay1
CALL Delay1
CALL Delay1
CALL Delay1
CALL Delay1
SJMP Main

Getkeyboard: ; Get value on the keys
MOV P1,#0FEH ; Keys: 7,8,9,�
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
;CALL  lReset
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
MOV A, #00101011B
RET
Greater11:
CJNE A, #12, Greater12
MOV A, #00101101B
RET
Greater12:
CJNE A, #13, Greater13
MOV A, #01111000B
RET
Greater13:
MOV A, #11111101B
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

Negative:
	 MOV	A, #0C0H
	 CALL	WriteCmd
	 MOV	A, #00101101B
	 CALL	WriteData
Error:
	 CLR	A
	 MOV	DPTR, #Error1
	 MOVC	A, @A + DPTR
OutRange:
	 CLR	A
	 MOV	DPTR, #OutRange1
	 MOVC	A, @A + DPTR
SetupResultDisplay:
CALL ResultNumber
ResultDisplay: ; In ket qua ra man hinh
CALL Execute
DJNZ R5, ResultDisplay
RET


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
ADD A, R4
CJNE R5, #1, StoreNumber
MOV R2, A
SJMP ReCallProcessConvertNumberBCDtoBIN
StoreNumber: MOV R3, A
ReCallProcessConvertNumberBCDtoBIN: RET

Phepcong:
MOV A, R2
ADD A, R3
MOV 50H, A
RET

Pheptru:
MOV A, R2
SUBB A, R3
MOV 50H, A
RET

Phepnhan:
MOV A, R2
MOV B, R3
MUL AB
MOV 50H, A
RET

Phepchia:
MOV A, R2
MOV B, R3
DIV AB
MOV 50H, A
RET

ProcessConvertNumberBINtoBCD:
MOV A, 50H
MOV B, #10
DIV AB
MOV 50H, A
CALL Execute
MOV A, 50H
JNZ ProcessConvertNumberBINtoBCD
RET 

Error1: DB	"Error!"
OutRange1: DB	"Out of range!"
END
