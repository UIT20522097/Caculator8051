ORG 00H
SJMP 30H

ORG 30H
Setup: ;Khoi tao cac bien xay dung
RS EQU	P0.0
EN EQU	P0.2
ByteSpace		EQU	04	   ; 01 <= ByteSpace <= 16
BitSpace		EQU	ByteSpace * 8  
AddressTranF 	EQU 20H
AddressTranB	EQU AddressTranF + ByteSpace - 1
AddressTempF 	EQU 30H
AddressTempB	EQU AddressTempF + ByteSpace - 1
AddressNum1F	EQU 40H
AddressNum1B	EQU AddressNum1F + ByteSpace - 1
AddressNum2F 	EQU 50H
AddressNum2B	EQU	AddressNum2F + ByteSpace - 1
AddressResuF 	EQU 60H
AddressResuB	EQU	AddressResuF + ByteSpace - 1
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
	 CALL	Delay20
LJMP Main

Delay20: ;Create delay time 20ms
MOV TH0, #HIGH(-20000)
MOV TL0, #LOW(-20000)
SETB TR0
JNB TF0, $
CLR TF0
CLR TR0
RET

Delay60: ;Create delay time 60ms
MOV TH1, #HIGH(-60000)
MOV TL1, #LOW(-60000)
SETB TR1
JNB TF1, $
CLR TF1
CLR TR1
RET

WriteCmd:	
	MOV 	P2, A	
	CLR 	RS				; RS = 0 for command
	SETB 	EN				; EN = 1 for high pulse
	CALL	Delay20			; Call DELAY subroutine
	CLR 	EN				; EN = 0 for low pulse
	RET

WriteData: 	
	MOV 	P2, A	
	SETB 	RS				; RS = 1 for data
	SETB 	EN				; EN = 1 for high pulse
	CALL	Delay20			; Call DELAY subroutine
	CLR 	EN				; EN = 0 for low pulse
	RET

Main:
; Waiting press keyboard
CALL GetKeyBoard
CALL Delay60
CALL Delay60
CALL Delay60
CALL Delay60
SJMP Main

Getkeyboard: ; Get value on the keys
MOV P1,#0FEH ; Keys: 7,8,9,?
JNB P1.4,JumpSw7
JNB P1.5,JumpSw8
JNB P1.6,JumpSw9
JNB P1.7,JumpSwchia
MOV P1,#0FDH ; Keys: 4,5,6,x
JNB P1.4,JumpSw4
JNB P1.5,JumpSw5
JNB P1.6,JumpSw6
JNB P1.7,JumpSwnhan
MOV P1,#0FBH ; Keys: 1,2,3,-
JNB P1.4,JumpSw1
JNB P1.5,JumpSw2
JNB P1.6,JumpSw3
JNB P1.7,JumpSwtru
MOV P1,#0F7H ; Keys: ON/C,0,=,+
JNB P1.4,JumpSwon
JNB P1.5,JumpSw0
JNB P1.6,JumpSwbang
JNB P1.7,JumpSwcong
SJMP Getkeyboard

JumpSw0: LJMP Sw0
JumpSw1: LJMP Sw1
JumpSw2: LJMP Sw2
JumpSw3: LJMP Sw3
JumpSw4: LJMP Sw4
JumpSw5: LJMP Sw5
JumpSw6: LJMP Sw6
JumpSw7: LJMP Sw7
JumpSw8: LJMP Sw8
JumpSw9: LJMP Sw9
JumpSwcong: LJMP Swcong
JumpSwtru: LJMP Swtru
JumpSwnhan: LJMP Swnhan
JumpSwchia: LJMP Swchia
JumpSwbang: LJMP Swbang
JumpSwon: LJMP Swon

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
MOV A, 71H
JNZ ReCallSwcong
MOV 71H, #'+'
MOV A, 71H
CALL WriteData
ReCallSwcong: RET
Swtru:
MOV A, 71H
JNZ ReCallSwtru
MOV 71H, #'-'
MOV A, 71H
CALL WriteData
ReCallSwtru: RET
Swnhan:
MOV A, 71H
JNZ ReCallSwnhan
MOV 71H, #'x'
MOV A, 71H
CALL WriteData
ReCallSwnhan: RET
Swchia:
MOV A, 71H
JNZ ReCallSwchia
MOV 71H, #'-'
MOV A, 71H
CALL WriteData
ReCallSwchia: RET
Swon:  ; Clear the registers
CALL Delay60
MOV R0, #00H
MOV R3, #80H
CALL CreateRegister
MOV SP, #07H
LJMP 00H
RET
Swbang:
CALL ProcessResult
CALL InitDisplayResult
CALL HandleDisplayResult
RET

;	Cac ham dac trung

InitDisplayResult: ; Hien thi ket qua goc phai duoi man hinh
MOV	A, #0CH
CALL WriteCmd
MOV	A, #0CFH
CALL WriteCmd
MOV	A, #04H
CALL WriteCmd
RET

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

ShiftLeft:	; @R0 << 1 vs  R3 byte	BackAddress
MOV A, @R0
RLC A
MOV @R0, A
DEC R0
DJNZ R3, ShiftLeft
ReCallShiftLeft: RET

ShiftRight: ; @R0 >> 1 vs  R3 byte
MOV A, @R0
RRC A
MOV @R0, A
INC R0
DJNZ R3,ShiftRight
ReCallShiftRight: RET 

ProcessIncNumber: ; Value @R0 += R4 R3 byte  BackAddress
SetupProcessIncNumber:
MOV A, @R0
ADD A, R4
MOV @R0, A
DEC R0
DEC R3
RunProcessIncNumber: 
MOV A, @R0
ADDC A, #0
MOV @R0, A
DEC R0
DJNZ R3, RunProcessIncNumber
ReCallProcessIncNumber: RET

Process1Complement:	; @R0 = ! @R0 vs R3 byte
MOV A, @R0
CPL A
MOV @R0, A
INC R0
DJNZ R3, Process1Complement
ReCallProcess1Complement: RET

Process2Complement:	; @R0 = -@R0	R3 byte
PUSH 00H
PUSH 03H
CALL Process1Complement
POP 03H
POP 00H
MOV R4, #01
CALL ProcessIncNumber
ReCallProcess2Complement: RET

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

ProcessAdd:	; @R1 += @R0	R3 byte	 BackAddress
MOV A, @R1
ADDC A, @R0
MOV @R1, A
DEC R0
DEC R1
DJNZ R3, ProcessAdd
ReCallProcessAdd: RET

ProcessSub:	; @R1 -= @R0  R3 byte  BackAddress
MOV A, @R1
SUBB A, @R0
MOV @R1, A
DEC R0
DEC R1
DJNZ R3, ProcessSub
ReCallProcessSub: RET

ProcessMul:	; @R1 *= @R0 R3 byte (R5 bit) 	 R1-BackAddress
SetupProcessMul:
PUSH 00H
PUSH 01H
PUSH 03H
MOV R0, #AddressTempF
CALL InitTransportRegister
POP 03H
POP 01H
POP 00H
PUSH 00H
PUSH 01H
PUSH 03H
MOV A, R1
MOV R0, A
CALL CreateRegister
POP 03H
POP 01H
POP 00H 
RunProcessMul:
PUSH 00H
PUSH 01H
PUSH 03H
CALL ShiftRight
POP 03H
POP 01H
POP 00H
PUSH 00H
PUSH 01H
PUSH 03H
JNC SkipRunAddInProcessMul
RunAddInProcessMul:
CLR C
MOV R0, #AddressTempB
CALL ProcessAdd
POP 03H
POP 01H
POP 00H
PUSH 00H
PUSH 01H
PUSH 03H
SkipRunAddInProcessMul:
MOV A, R1
MOV R0, A
CALL ShiftLeft
POP 03H
POP 01H
POP 00H
DJNZ R5, RunProcessMul
ReCallProcessMul: RET

ProcessDiv: ; @R0 % @R1 R3 byte	(R5 bit) BackAddress -> Result = @R0 vs Remainder = @Temp  
SetupDiv:
PUSH 00H
PUSH 01H
PUSH 03H
MOV R0, #AddressTempF
CALL CreateRegister
POP 03H
POP 01H
POP 00H

RunProcessDiv:
CLR C
PUSH 00H
PUSH 01H
PUSH 03H
LCALL ShiftLeft
POP 03H
POP 01H
POP 00H

PUSH 00H
PUSH 01H
PUSH 03H
MOV R0, #AddressTempB
LCALL ShiftLeft
POP 03H
POP 01H
POP 00H

PUSH 00H
PUSH 01H
PUSH 03H
MOV R0, #AddressTranF
MOV R1, #AddressTempF
CALL InitTransportRegister
POP 03H
POP 01H
POP 00H

PUSH 00H
PUSH 01H
PUSH 03H
MOV R0, #AddressNum2B
MOV R1, #AddressTempB
CALL ProcessSub
POP 03H
POP 01H
POP 00H

PUSH 00H
PUSH 01H
PUSH 03H
JNC ProcessNoCYInDivide
MOV R0, #AddressTempF
MOV R1, #AddressTranF
CALL InitTransportRegister
POP 03H
POP 01H
POP 00H
SJMP JumpReRunProcessDiv

ProcessNoCYInDivide:
MOV R4, #01
LCALL ProcessIncNumber
POP 03H
POP 01H
POP 00H

JumpReRunProcessDiv: DJNZ R5, RunProcessDiv
ReCallProcessDiv: RET

ProcessMulvs10:	; @R0 *= 10 R3	byte  BackAddress 
PUSH 00H
PUSH 03H
CALL ShiftLeft
POP 03H
POP 00H
PUSH 00H
PUSH 03H
MOV A, R0
SUBB A, #ByteSpace - 1
MOV R1, A
MOV R0, #AddressTempF
CALL InitTransportRegister
POP 03H
POP 00H
PUSH 00H
PUSH 03H
CALL ShiftLeft  
POP 03H
POP 00H
PUSH 00H
PUSH 03H
CALL ShiftLeft
POP 03H
POP 00H
PUSH 00H
PUSH 03H
MOV A, R0
SUBB A, #ByteSpace - 1
MOV R1, A
MOV R0, #AddressTempF
CALL ProcessAdd
POP 03H
POP 00H 
ReCallProcessMulvs10: RET

; Handle Function

ProcessConvertDECtoBIN:
MOV R3, #ByteSpace
MOV A, 71H
JNZ Number2
Number1:
MOV R0, #AddressNum1B
SJMP RunProcessConvertDECtoBIN
Number2:
MOV R0, #AddressNum2B
RunProcessConvertDECtoBIN:
CALL ProcessMulvs10
MOV R4, 70H
CALL ProcessIncNumber
RET

ProcessConvertBINtoBCD:	; @R0 % 10 BackAddress -> Result = @Result vs Remainder = @TempB
MOV R0, #AddressNum2F
MOV R3, #ByteSpace
CALL CreateRegister

MOV R0, #AddressNum2B
MOV R3, #ByteSpace
MOV R4, #10
CALL ProcessIncNumber

MOV R0, #AddressResuB
MOV R1, #AddressNum2B
MOV R3, #ByteSpace
MOV R5, #BitSpace
CALL ProcessDiv
ReCallProcessConvertBINtoBCD: RET

PrintNumber:	; A = Number
ADD	A, #00110000B
CALL WriteData
RET

ProcessNumber:
MOV	A, 70H
CALL PrintNumber
CALL ProcessConvertDECtoBIN
RET

ProcessResult: ; Xu ly phep toan xuat ra ket qua
MOV	A, 71H
JNZ ContinueProcessResult
MOV 71H, #'+'
MOV A, 71H
ContinueProcessResult:
CheckOperatorAdd:
CJNE A, #'+', CheckOperatorSub
CALL HandleAdd
SJMP ReCallProcessResult
CheckOperatorSub:
CJNE A, #'-', CheckOperatorMul
CALL HandleSub
SJMP ReCallProcessResult
CheckOperatorMul:
CJNE A, #'x', CheckOperatorDiv
CALL HandleMul
SJMP ReCallProcessResult
CheckOperatorDiv:
CALL HandleDiv
ReCallProcessResult: RET

HandleAdd:
MOV R0, #AddressNum2B
MOV R1, #AddressNum1B
MOV R3, #ByteSpace
CALL ProcessAdd
MOV R0, #AddressResuF
MOV R1, #AddressNum1F
MOV R3, #ByteSpace
CALL InitTransportRegister
RET

HandleSub:
MOV R0, #AddressNum2B
MOV R1, #AddressNum1B
MOV R3, #ByteSpace
CALL ProcessSub
MOV R0, #AddressResuF
MOV R1, #AddressNum1F
MOV R3, #ByteSpace
CALL InitTransportRegister
RET

HandleMul:
MOV R0, #AddressNum2F
MOV R1, #AddressNum1B 
MOV R3, #ByteSpace
MOV R5, #BitSpace
CALL ProcessMul
MOV R0, #AddressResuF
MOV R1, #AddressNum1F
MOV R3, #ByteSpace
CALL InitTransportRegister
RET

HandleDiv:
MOV R0, #AddressNum1B
MOV R1, #AddressNum2B 
MOV R3, #ByteSpace
MOV R5, #BitSpace
CALL ProcessDiv
MOV R0, #AddressResuF
MOV R1, #AddressNum1F
MOV R3, #ByteSpace
CALL InitTransportRegister
RET

HandleDisplayResult:
CALL ProcessConvertBINtoBCD
MOV A, AddressTempB
CALL PrintNumber
MOV R0, #AddressResuF
CALL CheckEqualZero
JZ HandleDisplayResult
RET

END 