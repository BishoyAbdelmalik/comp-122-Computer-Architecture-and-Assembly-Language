;;Name: Bishoy Abdelmalik
;;Date: 3/25/2019
;;Class: comp 122

.equ SWI_Exit, 0x11
.equ SWI_OPEN, 0x66
.equ SWI_Close, 0x68
.equ SWI_RdInt , 0x6c
.equ SWI_PrInt, 0x6b
.equ SWI_PrStr, 0x69

filein: .asciz "integers.txt"
		.align

containsStr: .asciz "File contains: "
			.align

firstIntIs: .asciz " integers.\nFirst integer x is "
			.align

thereAre: .asciz ", There are "
   		.align

greaterThan: .asciz " integers greater than "
			.align

maxPosInt: .asciz " and The maximum positive integer is "
			.align

emptyFileException: .asciz "Error: File is Empty or Doesn't have Valid Integers"
					.align

fileNotFoundException: .asciz "Error: File not found please check file name and location"
						.align
na: .asciz "N/A"
		.align

ldr r0,=filein
;;set the file opening mode to read
mov r1,#0 
swi SWI_OPEN

;;check if file open returned an error
cmp r0,#-1
beq fileNotFound

;;keeping the file handle in another register 
mov r3,r0

;;fix the comment say what each register is used for
;;make sure r5,r6 and r7 is empty 
mov r6,#0 ;;will have first value to serve as x
mov r7,#0 ;;will store the biggest value
mov r5,#0 ;;count how many ints in the file

;;read first value 
swi SWI_RdInt 
;;exit if end of file reached
bcs emptyOrInvalidFile	
;; add 1 to r5
add r5,r5,#1
;; save the first value to r4 to serve as x later
mov r4,r0
;;intialize r7 with the first number assuming its the biggest value
mov r7,r0




read:
	;;returning the file handle in register 0
	mov r0,r3
	swi SWI_RdInt
	;;exit if end of file reached
	bcs printResult	
	;; add 1 to r5
	add r5,r5,#1
	;;compare the current value with the value x(first value)
	CMP r0,r4
	;;add 1 if the current number is greater than x 
	addpl r6,r6,#1
	;;compare the current value with the biggest value
	cmp r0,r7
	;;move the current value in r7 if its the biggest value so far
	movpl r7,r0
	b read

printResult:
	;;move 1 to r0 for Stdout
	mov r0,#1
	
	;;say what the strings contains
	;; load the asciz string to r1 
	ldr r1,=containsStr
	swi SWI_PrStr
	;;put the number of numbers in the file in r1 to print it
	mov r1,r5
	swi SWI_PrInt
	;; load the asciz string to r1
	ldr r1,=firstIntIs
	swi SWI_PrStr
	;;put first value (x) in the file in r1 to print it
	mov r1,r4
	swi SWI_PrInt
	;; load the asciz string to r1
	ldr r1,=thereAre
	swi SWI_PrStr
	;;put number of values bigger than x in r1 to print it
	mov r1,r6
	swi SWI_PrInt
	;; load the asciz string to r1
	ldr r1,=greaterThan
	swi SWI_PrStr
	;;put x r1 to print it
	mov r1,r4
	swi SWI_PrInt
	;; load the asciz string to r1
	ldr r1,=maxPosInt
	swi SWI_PrStr
	
	;;check if the biggest number is bigger or equal than 0 to handle the case if all the numbers are negative
	cmp r7,#0
	bmi printNA
	
	;;put biggest value in r1 to print it
	mov r1,r7
	swi SWI_PrInt
	b exit
printNA:
	;; load the asciz string to r1
	ldr r1,=na
	swi SWI_PrStr
	b exit


exit:
	swi SWI_Close
	swi SWI_Exit
	
fileNotFound:
	;;move 1 to r0 for Stdout
	mov r0,#1
	;; load the asciz string to r1
	ldr r1,=fileNotFoundException
	swi SWI_PrStr
	b exit
emptyOrInvalidFile:
	;;move 1 to r0 for Stdout
	mov r0,#1
	;; load the asciz string to r1
	ldr r1,=emptyFileException
	swi SWI_PrStr
	b exit