.equ SWI_Exit, 0x11
.equ SWI_RdInt , 0x6c
.equ SWI_PrInt, 0x6b
.equ SWI_PrStr, 0x69
.equ SWI_Print_Char, 0x00

	.data
array:
	.word 3,-7,2,-2,10 

	.text
	.global _start
_start:
	ldr r0,=array
	mov r3, #5 
	mov r2,#0
loop_begin:
	ldr r1, [r0] 		; read integer from array
	add r2,r2,r1
	;; increment to the next array element
	;; add 4 because words are 4 bytes long
	add r0, r0, #4
	;; decrement number of elements left
	sub r3, r3, #1
	;;if we have none left, we are done
	cmp r3, #0
	bne loop_begin
	mov r0, #1 		; write to standard output
	mov r1,r2		
	swi SWI_PrInt	; print the integer

exit:
	swi SWI_Exit