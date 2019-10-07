;; Author: Bishoy Abdelmalik
;; Date: 5/5/2019
;;
;; I used asci codes to manipulate the string from the input file so at first the program will read the string from the file into an array
;; after that it will start looping through that array check if the letters require modificationsif they do it will perform them then save them back in the array
;; lastly it will just open the output file and output the char array in it and print the success message to the stdout
;; if any error occurs such as file reading error or empty file it will output the error to the stdout and the output file 

.equ SWI_Exit, 0x11
.equ SWI_RdInt , 0x6c
.equ SWI_RdStr, 0x6a
.equ SWI_PrInt, 0x6b
.equ SWI_Print_Char, 0x00
.equ SWI_PrStr, 0x69
.equ SWI_Open, 0x66
.equ SWI_Close, 0x68

.data
filename:
.asciz "Input.txt"
.align
output: 
.asciz "output.txt"
.align



fileNotFoundException:.asciz "Error: Input File not found or file name is wrong"
					  .align
emptyFileException: .asciz "Error: Input File is Empty"
					.align
donemsg: .asciz "File modifications are saved in output.txt "
					.align
CharArray: .skip 200
.align

.text
;; open the input file
;; load the file name 
ldr r0, = filename
;; set it to read mode
mov r1,#0
;; open the file
swi SWI_Open
;;check if file open returned an error
cmp r0,#-1
beq fileNotFound ;; if it did branch to fileNotFound to print error message
;; preparing the array that we will read the string into
;; load empty array with space for 200 chars
ldr r1,=CharArray

;; read the string
;; load number of bytes to read
mov r2,#200
;; read
swi SWI_RdStr
;;check if number of bytes is 0 meaning read nothing
cmp r0,#0
beq emptyFile ;;if it read nothing means the file is empty
mov r0,#0 ;;reset r0 to 0 to start reading the chars
mov r5,#0	;; save the counter to go back to the beginning of the array at the end
loop_begin:
	ldrb r0, [r1] 		;; read char from string
	cmp  r0,#0          ;;no characters read means EOF
    beq  exit               ;;so close and exit 
	bl checkForSpecialChar ;;this branch will check if the current char is a special char
	bl print	;; branch to print to store the char to the array
	
	bl moveOneCharForward ;;adds one to the counter and the array
	cmp r0,#32 ;; if current char is a space capitalize the next letter
	beq capitalizeNextLetter
	
	b loop_begin
capitalizeNextLetter:
	ldrb r0, [r1] 		;; read char from string
	
	cmp r0,#32 ;; check if there is a white space
	bleq moveOneCharForward
	;;if we have a white space then move back to capitalizeNextLetter
	beq capitalizeNextLetter
	;;if its capitalized 
	cmp r0,#91 ;; if its capitalized 
	bmi loop_begin ;; move to the begining of the loop
	cmp r0,#97 ;; compare the char to a to check if its a letter  
	bmi loop_begin ;; move to the begining of the loop
	cmp r0,#122 ;; compare the char to a to check if its a letter  
	bpl loop_begin ;; move to the begining of the loop
	;; if its not capitalized
	sub r0,r0,#32  ;; capitalize it 
	bl print ;; branch to print to store the char to the array
	bl moveOneCharForward  ;;adds one to the counter and the array
	b loop_begin
checkForSpecialChar:
	cmp r0,#127 ;; if its more than 127
	movpl pc, r14 ;; go back to the next instruction after the branch was called
	cmp r0,#123 ;; if its more than 123(a special char because its more than 123 but less than 127)
	bpl makeItAsterisk ;;branch to change the char to an * 
	cmp r0,#97 ;; if current char is < 123 check if its bigger than 97
	movpl pc, r14 ;; if its bigger go back
	cmp r0,#91 ;; if current char is >91 but smaller than 97
	bpl makeItAsterisk ;;branch to change the char to an * 
	cmp r0,#65 ;; if current char is < 91 check if its bigger than 65
	movpl pc, r14 ;; go back
	cmp r0,#58 ;; if current char is >58 check if its smaller than 65
	bpl makeItAsterisk ;;branch to change the char to an *
	cmp r0,#48 ;; if current char is < 58 check if its bigger than 48 
	movpl pc, r14 ;; go back
	cmp r0,#33 ;; if current char is >33 check if its smaller than 48
	bpl makeItAsterisk ;;branch to change the char to an *
	mov pc, r14 ;; go back

	
makeItAsterisk:
	mov r0,#42 ;; 42 is the ascii value of *
	mov pc, r14 ;; go back to the instruction after checkForSpecialChar was called 

	
	
print:
	strb r0,[r1] ;;save the printed char back in the array
	mov pc, r14 ;; go back



save_changes:
	;; subtract the counter to go back to the array beggining 
	sub r1, r1, r5
	mov r4, r1 ;; save the array to r4
	;; open the output file 
	ldr r0, = output
	mov r1,#1 ;; set it to write mode
	swi SWI_Open ;; open the file
	mov r1,r4 ;;move the array back in r4
	swi SWI_PrStr ;; print the string 
	b done
	
	
moveOneCharForward:
	;; add 1 because characters are 1 bytes long
	add r1, r1, #1
	add r5, r5, #1 ;;for the counter 
	mov pc, r14 ;; go back to the next line after the BL

fileNotFound:
	;;move 1 to r0 for Stdout
	mov r0,#1
	;; load the asciz string to r1
	ldr r1,=fileNotFoundException
	swi SWI_PrStr
	;; open the output file 
	ldr r0, = output
	mov r1,#1 ;; set it to write mode
	swi SWI_Open ;; open the file
	ldr r1,=fileNotFoundException
	swi SWI_PrStr ;; print the string 
	swi SWI_Close
	swi SWI_Exit
emptyFile:
	;;move 1 to r0 for Stdout
	mov r0,#1
	;; load the asciz string to r1
	ldr r1,=emptyFileException
	swi SWI_PrStr
	;; open the output file 
	ldr r0, = output
	mov r1,#1 ;; set it to write mode
	swi SWI_Open ;; open the file
	ldr r1,=emptyFileException
	swi SWI_PrStr ;; print the string 
	swi SWI_Close
	swi SWI_Exit

	
done:
	;;move 1 to r0 for Stdout
	mov r0,#1
	;; load the asciz string to r1
	ldr r1,=donemsg
	swi SWI_PrStr
	mov pc, r14 ;; go back to the next line after the BL

exit:
	bl save_changes
	swi SWI_Close
	swi SWI_Exit
