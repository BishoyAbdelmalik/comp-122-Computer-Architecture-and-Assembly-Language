.equ SWI_Exit, 0x11
.equ SWI_OPEN, 0x66
.equ SWI_READ, 0x6c
.equ SWI_Print, 0x6b
filein: .asciz "int.txt"

ldr r0,=filein
mov r1,#0 
swi SWI_OPEN
swi SWI_READ
;; compate r0 to 0 
cmp r0,#0
;;move -1 to r1
movmi r1,#-1
;; multiply r0 and r1 and save at r0 if negative register is equal 1
mulmi r0,r1,r0
;;move r0 in r1 to prepare for print
mov r1,r0
;;move 1 to r0 to prepare for print
mov r0,#1
;;print
swi SWI_Print

swi SWI_Exit
