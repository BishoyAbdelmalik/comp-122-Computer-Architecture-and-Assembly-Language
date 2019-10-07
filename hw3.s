.equ SWI_Print_Int, 0x6B
	.equ SWI_Exit, 0x11
	.equ SWI_Print_Char, 0x00
	.equ SWI_Open, 0x66
	
.data
filename:
.asciz "Input.txt"

.text

ldr r0, = filename
mov r1,#0
swi SWI_Open

;;ldr r0,=InFileHandle 
;;ldr r0,[r0]
ldr r1,=CharArray
 mov r2,#80
swi 0x6a

ldrb r0, [r1] ;; gets the last character of the string


swi SWI_Print_Char

;;bcs ReadError ...
InFileHandle: .word 0
CharArray: .skip 80
