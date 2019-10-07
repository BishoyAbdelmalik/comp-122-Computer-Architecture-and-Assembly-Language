.equ SWI_Exit, 0x11
.equ SWI_OPEN, 0x66
.equ SWI_READ, 0x6c
.equ SWI_Print, 0x6b
filein: .asciz "nested_if_test_int.txt"

ldr r0,=filein
mov r1,#0 
swi SWI_OPEN
swi SWI_READ
cmp r0,#10
;;move if the last compare result in positive number to the else branch
bpl else
	cmp r0,#7
	;;move if the last compare result in positive number to the nestedelse branch	
	bpl nestedelse
		;;move 1 to r0 to prepare for print
		mov r0,#1
		b print
		
	nestedelse:
		;;move 1 in r1 to prepare for print
		mov r1,#1
		b print
else:
	;;move 1 in r1 to prepare for print
	mov r1,#2
	b print

exit:
	swi SWI_Exit

print:
	;;move 1 to r0 to prepare for print
	mov r0,#1
	swi SWI_Print
	b exit