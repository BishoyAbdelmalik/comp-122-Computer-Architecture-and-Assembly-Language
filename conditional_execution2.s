	.equ SWI_Exit, 0x11

	.text
	.global _start
_start:
	

	;; sets the negative bit in the status register
	mov r1, #10
	mov r2, #20
	cmp r1, r2

	;; move if negative bit set
	;; because the negative bit was set in the
	;; previous cmp instruction, the move occurs
	movmi r3, #50

	
	;; exit program
	swi SWI_Exit
	.end
