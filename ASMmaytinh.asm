ORG 00H
LJMP 30H

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

Setup: ;Khoi tao cac bien xay dung 
; A la thanh ghi khong co dinh
MOV R0, #AddressTemp ; Pointer of the number sequence(30H - 3FH)
; R1 Available
; R2 Available
; R3 Available
; R4 Available
; R5 70H,
; R6 71H
; R7 #15,
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

ProcessConvertNumberBCDtoBIN:  ; Chuyen doi so BCD sang Binary
MOV R7, #15
MOV R0, #AddressTran
MOV R6, 71H
CJNE R6,#0, NumberTwo
NumberOne:
MOV R1, #AddressNum1

NumberTwo:
MOV R1, #AddressNum2
RET

END	