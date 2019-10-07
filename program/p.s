.equ SWI_Exit, 0x11
.equ SWI_OPEN, 0x66
.equ SWI_READ, 0x6c
.equ SWI_Print, 0x6b
filein: .asciz "INT.txt"
ldr r0,=filein
mov r1,#0 
swi SWI_OPEN
swi SWI_READ
mov r1,r0
mov r0,#1
swi SWI_Print

swi SWI_Exit
