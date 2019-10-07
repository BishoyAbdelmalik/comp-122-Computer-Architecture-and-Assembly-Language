;; Author: Bishoy Abdelmalik
;; Date: 4/21/2019
;;
;; I used asci codes to manipulate so at first the program will read the string from the file into an array
;; after that it will start looping through that array and printing each character to the standardout and doing the modifications needed
;; after it prints each character it will save that character back into the array so if the character has changed we will have the changed string into an array
;; lastly it will just open the output file and output the char array in it 

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
output: 
.asciz "output.txt"

CharArray: .skip 80

.text
;; open the input file
;; load the file name 
ldr r0, = filename
;; set it to read mode
mov r1,#0
;; open the file
swi SWI_Open

;; preparing the array that we will read the string into
;; load empty array with space for 80 chars
ldr r1,=CharArray

;; read the string
;; load number of bytes to read
mov r2,#80
;; read
swi SWI_RdStr

mov r4, #80 ;; set a counter for the loop we will decrement that value at the end of each loop
mov r5,#0	;; save the counter to go back to the beginning of the array at the end
loop_begin:
	ldrb r0, [r1] 		;; read char from string
	
	bl numberCheck		;; branch to numberCheck  to check if it has a numbers after current char
	
	bl print	;; branch to print  to print the char and store the char to the array
	
	;; add 1 because characters are 1 bytes long
	add r1, r1, #1 ;; add 1 to the array
	add r5, r5, #1 ;; add 1 to r5 to save the counter to go back to the beginning of the array at the end
	;; decrement number of elements left
	sub r4, r4, #1
	cmp r0,#46 ;; if current char is a . capitalize the next letter
	beq capitalizeNextLetter
	
	
	cmp r4, #0 ;; if counter is not 0 loop again to begining 
	bne loop_begin
	b exit
capitalizeNextLetter:
	ldrb r0, [r1] 		;; read char from string
	
	cmp r0,#32 ;; check if there is a white space
	;; add 1 to move to the next char if we have a white space
	addeq r1, r1, #1
	addeq r5, r5, #1
	swieq SWI_Print_Char
	;;if we have a white space then move back to capitalizeNextLetter
	beq capitalizeNextLetter
	;;if its capitalized 
	cmp r0,#91 ;; if its capitalized 
	bmi loop_begin ;; move to the begining of the loop
	;; if its not capitalized
	sub r0,r0,#32  ;; capitalize it 
	bl print
	;; add 1 because characters are 1 bytes long
	add r1, r1, #1
	add r5, r5, #1
	b loop_begin

numberCheck:
	;; add 3 to move forward 3 char when we read
	add r1, r1, #3
	
	cmp r0,#32 ;; check if current char is a white space
	
	;;if current char is a white space
	;; subtract 3 to go back to the right char 
	subeq r1, r1, #3
	;; r14 have the address of the next instruction after the BL
	moveq pc, r14 ;; go back if it were a white space
	
	;; if its not white space we will read the char that is 3 char away from the current one 
	ldrb r8, [r1] 		;;; read char from string
	;; use asci code 58 which is : the first item after the characters 
	cmp r8, #58 ;; check if its a number
	
	;; if the character is more than : meaning it can not be a number
	;; subtract 3 to go back to the right char
	subpl r1, r1, #3
	movpl pc, r14 ;; go back if its more than 58
	
	;; if its less than 58 we check if its more than 47 
	;; 47 is the ascii for / the first character before the numbers
	cmp r8, #47 ;; check if its a number
	;; if it is more 
	subpl r0,r0,#32 ;; its a number then make the current letter capitalized
	
	;;return
	;; subtract 3 to go back to the right char
	sub r1, r1, #3
	mov pc, r14 ;; go back
	
	
print:
	swi SWI_Print_Char ;;print
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
	mov pc, r14 ;; go back to the next line after the BL

	

exit:
	bl save_changes
	swi SWI_Close
	swi SWI_Exit
