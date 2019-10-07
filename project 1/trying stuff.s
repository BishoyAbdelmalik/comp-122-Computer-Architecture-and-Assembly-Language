.equ SWI_Exit, 0x11
.equ SWI_OPEN, 0x66
.equ SWI_READ_int, 0x6c
.equ SWI_READ_str, 0x6a
.equ SWI_MeAlloc, 0x12
.equ SWI_DAlloc, 0x13
.equ SWI_Print_Int, 0x6b

filein: .asciz "integers.txt"
sep: .asciz "    "
ldr r0,=filein
ldr r5,=sep


mov r1,#0 
swi SWI_OPEN
;;keeping the file handle in another register 
mov r3,r0

;;put in r0 number of bytes to be allocated
mov r0,#2
;;allocate memory from heap 
swi SWI_MeAlloc
;;copy allocated memory address to r4
mov r4,r0



;;returning the file handle in register 0
mov r0,r3
swi SWI_READ_int


;;returning the file handle in register 0
mov r0,r3
;; get the allocated memory address
mov r1,r4
mov r2,#1
swi SWI_READ_str




;;returning the file handle in register 0
mov r0,r3
swi SWI_READ_int

swi SWI_DAlloc
swi SWI_Exit
