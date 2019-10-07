message: .ascii "Hello World\n"
mov r7,#4
mov r0,#1
ldr r1, =message
mov r2,#12
swi 0x11