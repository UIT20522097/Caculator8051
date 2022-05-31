ORG 00H
SJMP 30H

ORG 13H;Xu ly External Interrupt
;Trigger(P3.3 low)
LCALL GetKeyBoard
LCALL ProcessKey
CLR P3.0
ACALL Delay
SETB P3.3
RETI

ORG 30H
AddressTran EQU 20H
AddressTemp EQU 60H
AddressNum1 EQU 30H
AddressNum2 EQU 40H
AddressResu EQU 50H
; Cac thanh ghi >=70H tro di dung de lam bo nho tam rieng biet (Cac thanh ghi da su dung <=75H)
Setup: ;Khoi tao cac bien xay dung 
; A, B la thanh ghi khong co dinh
MOV R0, #AddressTemp ; Pointer of the number sequence(60H - 6FH)
; R1 Pointer Dynamic
MOV R2, #32	; R2, #32,
MOV R3, #4 ; R3 #4,
MOV R4, #8 ; R4 #8,
; R5 70H,
; R6 71H,
MOV R7, #16 ; R7 #16,
MOV IE, #10000100B ; External interrupt with P3.3 
MOV TMOD, #01H ; Timer 0 mode 1
Configure: ; Do something

Reset: ;Reset value
RET
Delay: ;Create delay time  20ms
MOV TH0, #HIGH(-20000)
MOV TL0, #LOW(-20000)
SETB TR0
JNB TF0, $
CLR TF0
CLR TR0
RET
Main:
JB P3.0, $
SETB P3.0
; Do somethings while waiting Presskeyboard

SJMP Main

Getkeyboard: ; Get value on the keys
MOV P1,#0FEH ; Keys: 7,8,9,÷
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
LCALL Reset
RET
Swbang:
LCALL ProcessResult
RET
ProcessKey:
CLR C
MOV R5, 70H
CJNE R5, #10, DivideOperatorNumber
DivideOperatorNumber:
JC KeyNumber
KeyOperator:
MOV 71H, 70H
MOV 72H, R0  ; Luu vi tri cua so thu nhat
RET
KeyNumber:
MOV @R0, 70H
MOV 73H, @R0
INC R0
RET
ProcessResult: ; Xu ly phep toan xuat ra ket qua
RET

ProcessConvertNumberBINtoBCD:  ; Ket qua tra ve 75H

RET

InitTransportRegister:	; @R0 = @R1	vs R3 byte
MOV A, @R1
MOV @R0, A
INC R0
INC R1
DJNZ R3, InitTransportRegister
RET

ProcessConvertNumberBCDtoBIN:  ; Chuyen doi so BCD sang Binary
PUSH 04H
PUSH 03H
MOV R0, #AddressTran
MOV R6, 71H
MOV 74H, #10
CLR C
PUSH 00H
CJNE R6,#0, NumberTwo
NumberOne:
MOV R1, #AddressNum1
PUSH 01H
SJMP SetupConvert
NumberTwo:
MOV R1, #AddressNum2
PUSH 01H
SetupConvert:
DEC R3
ACALL InitTransportRegister	  ; Gan ValueTran = Value @R1
POP 01H
POP 00H
POP 03H 
Convert: ; Dich phai thanh ghi Multiplier
MOV A, 74H
RRC A
MOV 74H, A
JC AddAndShiftLeft
CLR C
PUSH 03H
PUSH 00H
PUSH 01H
DEC R3
ACALL ShiftLeft
POP 01H
POP 00H
POP 03H
SJMP ReturnConvert 
AddAndShiftLeft: ; Cong Product va dich trai thanh ghi Multiplicand
CLR C
PUSH 03H
PUSH 00H
PUSH 01H
DEC R3
ACALL ProcessAdd
CLR C
POP 01H
POP 00H
POP 03H
PUSH 03H
PUSH 00H
PUSH 01H
DEC R3
ACALL ShiftLeft
POP 01H
POP 00H
POP 03H  
ReturnConvert:DJNZ R4, Convert
POP 04H
DEC R3
MOV A, R1
ADD A, R3
MOV R1, A
MOV A, @R1
ADD A, 73H
UntilProcessConvertNumberBCDtoBIN:
MOV A, R1
ADD A, R3
MOV R1, A
MOV A, @R1
ADDC A, #00H
DJNZ R3, ProcessAdd
ReCallProcessConvertNumberBCDtoBIN: RET

ProcessAdd:	; @R1 += @R0	R3 byte
MOV A, R0
ADD A, R3
MOV R0, A
MOV A, R1
ADD A, R3
MOV R1, A
MOV A, @R1
ADDC A, @R0
MOV @R1, A
DJNZ R3, ProcessAdd
; If (C high) ... 
ReCallProcessAdd: RET

ProcessSub:	; @R1 -= @R0  R3 byte
MOV A, R0
ADD A, R3
MOV R0, A
MOV A, R1
ADD A, R3
MOV R1, A
MOV A, @R1
SUBB A, @R0
MOV @R1, A
DJNZ R3, ProcessSub
ReCallProcessSub: RET

ShiftLeft: ; @R0 << 1 vs  R3 byte
MOV A, R0
ADD A, R3
MOV R0, A
MOV A, @R0
RLC A
MOV @R0, A
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
ADD A, R3
MOV R0, A
MOV A, @R0
CPL A
MOV @R0, A
DJNZ R3,Process1Complement
MOV R0,	#AddressNum1
MOV R3, #4
DEC R3
SETB C
ProcessInc1:
MOV A, R0
ADD A, R3
MOV R0, A
MOV A, @R0
ADDC A, #0
MOV @R0, A
DJNZ R3, ProcessInc1
ReCallProcess2Complement :RET

; Xu ly phep cong tru nhan chia 
Phepcong:
MOV R0, #AddressNum2
MOV R1,	#AddressNum1
MOV R3, #4
DEC R3
ACALL ProcessAdd
MOV R0, #AddressResu
MOV R1,	#AddressNum1
MOV R3, #4
DEC R3
LCALL InitTransportRegister ;
RET

Pheptru:
MOV R0, #AddressNum2
MOV R1,	#AddressNum1
MOV R3, #4
DEC R3
ACALL ProcessSub
; Xu ly truong hop so am
JNC UntilPheptru
MOV R0,	#AddressNum1
MOV R3, #4
DEC R3
ACALL Process2Complement ; C high
UntilPheptru:
MOV R0, #AddressResu
MOV R1,	#AddressNum1
MOV R3, #4
DEC R3
LCALL InitTransportRegister
RET

Phepnhan:
Setupnhan:
CLR C
MOV R2, #32
DEC R2
Fornhan:
MOV R0, #AddressNum2
MOV R3, #4
DEC R3
LCALL ShiftRight
JC ProcessAddInMul
SJMP ProcessUntilFornhan
ProcessAddInMul:
CLR C
MOV R1, #AddressResu
MOV R0, #AddressNum1
MOV R3, #4
DEC R3
LCALL ProcessAdd
ProcessUntilFornhan:
CLR C
MOV R0, #AddressNum1
MOV R3, #4
DEC R3
LCALL ShiftLeft
DJNZ R2, Fornhan
RET

Phepchia:
Setupchia:
MOV R2, #32
DEC R2
CLR C
Forchia:
MOV R0, #AddressNum1
MOV R3, #4
DEC R3
LCALL ShiftLeft
MOV R0, #AddressResu
MOV R3, #4
DEC R3
LCALL ShiftLeft
CLR C
MOV R0, #AddressTran
MOV R1, #AddressResu
MOV R3, #4
DEC R3
LCALL InitTransportRegister
MOV R0, #AddressNum2
MOV R1, #AddressResu
MOV R3, #4
DEC R3
LCALL ProcessSub
JNC ProcessNoCYInDivide
MOV R0, #AddressResu
MOV R1, #AddressTran
MOV R3, #4
DEC R3
LCALL InitTransportRegister
SJMP JumpForchia
ProcessNoCYInDivide:
SETB C
MOV R0, #AddressNum1
MOV R3, #4
DEC R3
LCALL ProcessInc1
JumpForchia: DJNZ R2, Forchia
; Chuyen Tran = Resu ; Resu = Num1; Num1 = Tran
MOV R0, #AddressTran
MOV R1, #AddressResu
MOV R3, #4
DEC R3
LCALL InitTransportRegister
MOV R0, #AddressResu
MOV R1, #AddressNum1
MOV R3, #4
DEC R3
LCALL InitTransportRegister
MOV R0, #AddressNum1
MOV R1, #AddressTran
MOV R3, #4
DEC R3
LCALL InitTransportRegister
RET


END