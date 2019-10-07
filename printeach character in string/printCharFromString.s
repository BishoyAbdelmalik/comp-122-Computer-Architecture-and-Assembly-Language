.equ SWI_Exit, 0x11
.equ SWI_RdInt , 0x6c
.equ SWI_PrInt, 0x6b
.equ SWI_PrStr, 0x69
.equ SWI_Print_Char, 0x00

	.data
string:
	.asciz "ABCDE" 

	.text
	.global _start
_start:
	ldr r2,=string
	mov r3, #5 
loop_begin:
	ldrb r0, [r2] 		; read char from string
	swi SWI_Print_Char
	;; increment to the next character element
	;; add 1 because characters are 1 bytes long
	add r2, r2, #1
	;; decrement number of elements left
	sub r3, r3, #1
	;;if we have none left, we are done
	cmp r3, #0
	bne loop_begin
		
	swi SWI_PrInt	; print the integer

exit:
	swi SWI_Exit