.equ SWI_print,0x6b
.equ SWI_exit,0x11
 
mov r2,r15
mov r1,#1
add r0,r0,r1
cmp r0,#10
movmi r15,r2
mov r1, r0
mov R0,#1 @ mode is Output view 
swi SWI_print
swi SWI_exit

