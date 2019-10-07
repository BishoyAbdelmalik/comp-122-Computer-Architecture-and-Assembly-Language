	@capitalize

	;; define some constants
	.equ SWI_Open_File, 0x66
	.equ SWI_Close_File, 0x68
	.equ SWI_Read_Int, 0x6C
	.equ SWI_Print_Int, 0x6B
	.equ SWI_PrChr,0x00			@ Write an ASCII char to Stdout
	.equ SWI_PrStr, 0x69		@ Write a null-ending string to file or stdout
	.equ SWI_RdStr, 0x6A		@read string from file
	.equ SWI_Exit, 0x11
	.equ Stdout , 1
	.equ ASCII_Dot, 0x2e
	.data
Inputfilename: .asciz "input.txt"
Outputfilename: .asciz "output.txt"
InFileHandle: .word 0 
OutFileHandle: .word 0
CharArray: .skip 254
number1: .asciz "122"
number2: .asciz "222"
buffer: .skip 20 ;buffer to hold the number found in the string
mainLoopCounter: .word 0	
FileErrorMsg: .asciz "Error opening the file"
ReadStringErrorMsg: .asciz "Error reading the string from file"
WriteStringErrorMsg: .asciz "Error writing the string to file"

	.text
	.global _start
_start:
	
	;open input file
	ldr r0, =Inputfilename 
	mov r1, #0 		; open for reading
	swi SWI_Open_File	; open the file
	bcs FileError	;check errors
	
	;save the filehandle
	ldr r1, =InFileHandle
	str r0,[r1]
	
	;Read the string
	;r0 has the filehandle
	
	ldr r1, =CharArray
	mov r2, #254
	swi SWI_RdStr
	bcs ErrorReadingString
	
	;close the file
	ldr r0,=InFileHandle
	ldr r0,[r0]
	swi SWI_Close_File
	
	;print the string to stdout for debuging
	mov r0, #Stdout
	;; CharArray is in r1 ldr r1, =CharArray
	;swi SWI_PrStr
	
	;counter
	mov r5,#0
	;put CharArray to r4
	mov r4, r1
	;initialize the flags
	mov r9,#0 ;flag for dot
	mov r3, #0 ;counter for buffer
	
CharReadLoop:
	;; load char from string
	ldrb r0, [r4,r5] 		

	cmp r9,#1
	beq UpperCaseChar
	;test if it is a digit
	bl IsDigit
	;bl IsLowerCaseLetter
	cmp r1, #1
	bne L1
	
	;add the digit to the buffer
	ldr r1, =buffer
	strb r0,[r1,r3]
	;set the buffer counter
	add r3,r3, #1 
	bal LoopNext
	
L1:	
	;we dont have a digit is the flag at 0
	cmp r3,#0 
	blne UpperCaseCS
	
	bl TestDot

UpperCaseChar:
	cmp r0, #' ' ;if we a space loop
	beq LoopNext
	;reset dot flag	
	mov R9,#0
	;try to change the current char to upper case
	bl IsLowerCaseLetter
	cmp r1,#1
	bne TestDot
	bl UpperCase
	strb r0,[r4,r5]
	bal LoopNext
	
TestDot:
	;check we have a dot
	bl IsDot
	
LoopNext:
	;swi SWI_PrChr	; print the char
	;increment counter
	add r5, r5, #1
	; Are we at the end of the string?
	cmp r0, #0 
	bne CharReadLoop
	
	@write to stdout
	mov r0,#1 ;write sdtout
	ldr r1, =CharArray
	swi SWI_PrStr
	
	@write string to output file
	;open output file for writing
	ldr r0, =Outputfilename 
	mov r1, #1 		; open for writing
	swi SWI_Open_File	; open the file
	bcs FileError	;check errors
	
	ldr r1, =CharArray
	swi SWI_PrStr
	;bcs ErrorWritingString
	;close the file
	swi SWI_Close_File
	
	bal Exit

UpperCaseCS:
	;terminate the buffer with 0 so it can be compared
	;add r3,r3,#1
	ldr r1, =buffer
	mov r2,#0
	strb r2,[r1,r3]
	;save r0 
	mov r2,r0
	;save return address
	mov r3,lr
	
	ldr r0, =number1
	bl StrCmp
	cmp r1,#1
	beq UpperCaseCSEqual
	ldr r1, =buffer
	ldr r0, =number2
	bl StrCmp
	cmp r1,#1
	bne UpperCaseCSReturn
UpperCaseCSEqual:
	sub r5,r5,#5
	ldrb r0,[r4,r5]
	bl UpperCase
	strb r0,[r4,r5]
	
	sub r5,r5,#1
	ldrb r0,[r4,r5]
	bl UpperCase
	strb r0,[r4,r5]
	
	add r5,r5,#6
	
UpperCaseCSReturn:
	;restore r0
	mov r0,r2
	;restore return
	mov lr, r3
	mov r3,#0
	bal Return
	
FileError:
	mov r0, #Stdout @ print last message
	ldr r1, =FileErrorMsg
	swi SWI_PrStr
	bal Exit

ErrorWritingString:
	mov r0, #Stdout @ print last message
	ldr r1, =WriteStringErrorMsg
	swi SWI_PrStr
	bal Exit
	
ErrorReadingString:
	mov r0, #Stdout @ print last message
	ldr r1, =ReadStringErrorMsg
	swi SWI_PrStr
	bal Exit

@check the value in r0, set a flag to 1 in r9 if the char is a dot
IsDot:
	cmp r0,#ASCII_Dot
	bne Return
	;set the flag to 1
	mov r9,#1
	bal Return

@compare two strings. r0 has the start of string1 r1 as the start of string2. Result is in r1. 0 means not equal
StrCmp:
	mov r6, #0
	strcmploop:
		ldrb r7, [r0,r6]
		ldrb r8, [r1,r6]
		cmp r7, r8
		bne StrCmpNotEqual
		cmp r7,#0
		beq StrCmpEqual
		add r6, r6, #1
		bal strcmploop
StrCmpEqual:
	mov r1, #1
	bal Return
StrCmpNotEqual:
	mov r1,#0
	bal Return

@reset the buffer
ResetBuffer:
	;counter
	mov r0, #0
	mov r2, #0
	ldr r1, = buffer
BufferLoop:
	strb r2,[r1,r0]
	add r0, r0, #1
	cmp r0,#20
	bne BufferLoop
	bal Return
	
@convert the char in r0 to uppercase
UpperCase:
	sub r0,r0,#'a'-'A'
	bal Return

@check if the char in r0 is a letter, set r1 to 1 if it is otherwise set r1 to 0
IsLowerCaseLetter:
	mov r1,#0
	sub r2,r0, #'a'
	cmp r2,#0
	blt NotLowerCaseLetterReturn
	cmp r2, #'z'-'a' ;25
	bgt NotLowerCaseLetterReturn	
	mov r1, #1
NotLowerCaseLetterReturn:
	bal Return
Return:	
	mov pc, lr
	
@check if the char in r0 is a digit, set r1 to 1 if it is otherwise set r1 to 0
IsDigit:
	mov r1,#0
	sub r2,r0, #'0'
	cmp r2,#0
	blt NotDigitReturn
	cmp r2, #'9'-'0' ;9
	bgt NotDigitReturn
	mov r1, #1
NotDigitReturn:
	bal Return
	
Exit:
	swi SWI_Exit @ stop executing 

	.end