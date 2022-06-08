ORG 00H
LJMP Setup


ORG 30H
RS EQU	P0.0
RW EQU	P0.1
EN EQU	P0.2
AddressTran EQU 20H
AddressTemp EQU 60H
AddressNum1 EQU 30H
AddressNum2 EQU 40H
AddressResu EQU 50H
; Cac thanh ghi >=70H tro di dung de lam bo nho tam rieng biet (Cac thanh ghi da su dung <=76H)
Setup: ;Khoi tao cac bien xay dung
; A, B la thanh ghi khong co dinh
; R0 Pointer Dynamic
; R1 Pointer Dynamic
MOV R2, #32 ; R2, #32,
MOV R3, #4 ; R3 #4,
; R4 Value Dynamic
; R5 Value Dynamic
; R6 Value Dynamic 
; R7 = 3 and Value Dynamic
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
lReset: ; Control Pin RST
MOV R0, #00H
MOV R3, #80H
LCALL CreateRegister
CLR P3.0
RET

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
CALL  lReset
RET
Swbang:
CALL ProcessResult
MOV  76H, #AddressResu
MOV  R5, #0
CALL StoreBCDResult
CALL SetupResultDisplay
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
CALL ProcessConvertNumberBCDtoBIN
RET

ProcessResult: ; Xu ly phep toan xuat ra ket qua
MOV	A, 71H
CJNE A, #11, Greater11R
CALL Phepcong
CLR C
SJMP ReCallProcessResult
Greater11R:
CJNE A, #12, Greater12R
CALL Pheptru
SJMP ReCallProcessResult
Greater12R:
CJNE A, #13, Greater13R
CALL Phepnhan
CLR C
SJMP ReCallProcessResult
Greater13R:
CALL Phepchia
CLR C
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
	 MOV	R0, #AddressNum1
	 MOV	A, #0CFH
	 CALL	WriteCmd
	 MOV	A, #04H
	 CALL	WriteCmd
	 RET	
Execute:
	 MOV	A, @R0
	 ADD	A, #00110000B
	 CALL	WriteData
	 INC	R0
	 RET
Negative:
	 MOV	A, #0C0H
	 CALL	WriteCmd
	 MOV	A, #00101101B
	 CALL	WriteData

SetupResultDisplay:
CALL ResultNumber
MOV R5, #4
ResultDisplay: ; In ket qua ra man hinh
CALL Execute
DJNZ R5, ResultDisplay
RET

StoreBCDResult:		; Value @76H = BCDNumber
CALL ProcessConvertNumberBINtoBCD
MOV R0, 76H ; Value @76H = AddressTemp
MOV @R0, 75H
INC 76H
INC R5
MOV R0, #AddressResu
MOV R3, #4

CALL CheckEqualZero
JNZ StoreBCDResult
RET

ProcessConvertNumberBINtoBCD:  ; Ket qua tra ve 75H
SetupConvertNumberBINtoBCD:
MOV R0, #AddressNum1
MOV R1, #AddressResu
MOV R3, #4
CALL InitTransportRegister

MOV R0, #AddressResu
MOV R3, #4
CALL CreateRegister

MOV R0, #AddressNum2
MOV R3, #4
CALL CreateRegister

MOV 43H, #10
LCALL Phepchia
MOV 75H, 33H
RET

CheckEqualZero: ; If Value @R0 == 0 R3 byte then A = 1 else A = 0
MOV A, @R0
JZ ContinueCheck
MOV A, #0
SJMP ReCallCheckEqualZero
ContinueCheck:
INC R0
DJNZ R3, CheckEqualZero
MOV A, #1
ReCallCheckEqualZero: RET

InitTransportRegister:	; @R0 = @R1	vs R3 byte
MOV A, @R1
MOV @R0, A
INC R0
INC R1
DJNZ R3, InitTransportRegister
RET

ProcessConvertNumberBCDtoBIN:  ; Chuyen doi so BCD sang Binary
MOV R3, #4
MOV R0, #AddressTran
MOV R6, 71H
MOV 74H, #10
CLR C
CJNE R6,#0, NumberTwo
NumberOne:
MOV R1, #AddressNum1
PUSH 01H
SJMP SetupConvert
NumberTwo:
MOV R1, #AddressNum2
PUSH 01H
SetupConvert:

CALL InitTransportRegister	  ; ValueTran = Value @R1
MOV A, R1
MOV R0, A 
MOV R3, #4

CALL CreateRegister  ; Value @R1 = 0 4 byte
POP 01H
CLR C
MOV R4, #4 
Convert: ; Dich phai thanh ghi Multiplier
MOV A, 74H
RRC A
MOV 74H, A
JC AddAndShiftLeft
CLR C
MOV	R3, #4
MOV R0, #AddressTran
MOV R7, #3
PUSH 01H
ACALL ShiftLeft
CLR C
POP 01H
MOV	R3, #4
MOV R0, #AddressTran
MOV R7, #3
SJMP ReturnConvert 
AddAndShiftLeft: ; Cong Product va dich trai thanh ghi Multiplicand
CLR C
MOV	R3, #4
MOV R0, #AddressTran
MOV R7, #3
PUSH 01H
ACALL ProcessAdd
CLR C
POP 01H
MOV	R3, #4
MOV R0, #AddressTran
MOV R7, #3
PUSH 01H
ACALL ShiftLeft
CLR C
POP 01H
MOV	R3, #4
MOV R0, #AddressTran
MOV R7, #3
ReturnConvert:DJNZ R4, Convert
MOV R0, #AddressTran
MOV	R3, #4
CALL CreateRegister
MOV 23H, 70H 			; Value @Trans = Value Current
MOV R0, #AddressTran
MOV	R3, #4
MOV R7, #3
CALL ProcessAdd
CLR C
;	TEST NUMBER
;CALL SetupResultDisplay
ReCallProcessConvertNumberBCDtoBIN: RET

CreateRegister: ; @R0 = 0   R3 byte
MOV @R0, #0
INC R0
DJNZ R3, CreateRegister
RET

ProcessAdd:	; @R1 += @R0	R3 byte
MOV A, R0
ADD A, R7
MOV R0, A
MOV A, R1
ADD A, R7
MOV R1, A
MOV A, @R1
ADDC A, @R0
MOV @R1, A
DEC R7
DJNZ R3, ProcessAdd
; If (C high) ... 
ReCallProcessAdd: RET

ProcessSub:	; @R1 -= @R0  R3 byte
MOV A, R0
ADD A, R7
MOV R0, A
MOV A, R1
ADD A, R7
MOV R1, A
MOV A, @R1
SUBB A, @R0
MOV @R1, A
DEC R7
DJNZ R3, ProcessSub
ReCallProcessSub: RET

ShiftLeft: ; @R0 << 1 vs  R3 byte
MOV A, R0
ADD A, R7
MOV R0, A
MOV A, @R0
RLC A
MOV @R0, A
DEC R7
DJNZ R3,ShiftLeft
; If(C high) check 74H != 0
ReCallShiftLeft: RET

ShiftRight: ; @R0 >> 1 vs  R3 byte
MOV A, @R0
RRC A
MOV @R0, A
INC R0
DJNZ R3,ShiftRight
ReCallShiftRight: RET

Process2Complement:	; @R0 = -@R0	4 byte
Process1Complement: ; Bu 1
MOV A, R0
ADD A, R7
MOV R0, A
MOV A, @R0
CPL A
MOV @R0, A
DEC R7
DJNZ R3,Process1Complement
MOV R0,	#AddressNum1
MOV R3, #4
SETB C
MOV R7, #3
ProcessInc1: ; Value @R0 ++ R3 byte
MOV A, R0
ADD A, R7
MOV R0, A
MOV A, @R0
ADDC A, #0
MOV @R0, A
DEC R7
DJNZ R3, ProcessInc1
ReCallProcess2Complement :RET

; Xu ly phep cong tru nhan chia 
Phepcong:
MOV R0, #AddressNum2
MOV R1,	#AddressNum1
MOV R3, #4

ACALL ProcessAdd
MOV R0, #AddressResu
MOV R1,	#AddressNum1
MOV R3, #4

LCALL InitTransportRegister ;
RET

Pheptru:
MOV R0, #AddressNum2
MOV R1,	#AddressNum1
MOV R3, #4

ACALL ProcessSub
; Xu ly truong hop so am
JNC UntilPheptru
MOV R0,	#AddressNum1
MOV R3, #4

ACALL Process2Complement ; C high
SETB C
UntilPheptru:
MOV R0, #AddressResu
MOV R1,	#AddressNum1
MOV R3, #4

LCALL InitTransportRegister
RET

Phepnhan:
Setupnhan:
CLR C
MOV R2, #32
Fornhan:
MOV R0, #AddressNum2
MOV R3, #4

LCALL ShiftRight
JC ProcessAddInMul
SJMP ProcessUntilFornhan
ProcessAddInMul:
CLR C
MOV R1, #AddressResu
MOV R0, #AddressNum1
MOV R3, #4
MOV R7, #3
LCALL ProcessAdd
ProcessUntilFornhan:
CLR C
MOV R0, #AddressNum1
MOV R3, #4
MOV R7, #3
LCALL ShiftLeft
DJNZ R2, Fornhan
RET

Phepchia:
Setupchia:
MOV R2, #32
CLR C
Forchia:
MOV R0, #AddressNum1
MOV R3, #4
MOV R7, #3
LCALL ShiftLeft

MOV R0, #AddressResu
MOV R3, #4
MOV R7, #3
LCALL ShiftLeft

CLR C
MOV R0, #AddressTran
MOV R1, #AddressResu
MOV R3, #4
LCALL InitTransportRegister

MOV R0, #AddressNum2
MOV R1, #AddressResu
MOV R3, #4
MOV R7, #3
LCALL ProcessSub

JNC ProcessNoCYInDivide
MOV R0, #AddressResu
MOV R1, #AddressTran
MOV R3, #4
LCALL InitTransportRegister

SJMP JumpForchia
ProcessNoCYInDivide:
SETB C
MOV R0, #AddressNum1
MOV R3, #4
MOV R7, #3
LCALL ProcessInc1

JumpForchia: DJNZ R2, Forchia
; Chuyen Tran = Resu ; Resu = Num1; Num1 = Tran
MOV R0, #AddressTran
MOV R1, #AddressResu
MOV R3, #4
LCALL InitTransportRegister

MOV R0, #AddressResu
MOV R1, #AddressNum1
MOV R3, #4
LCALL InitTransportRegister

MOV R0, #AddressNum1
MOV R1, #AddressTran
MOV R3, #4
LCALL InitTransportRegister

RET

ErrorLabel:	DB "Error"
OutRangeLable: DB "Out Range"
RequestLable: DB "Press ON/C"

END