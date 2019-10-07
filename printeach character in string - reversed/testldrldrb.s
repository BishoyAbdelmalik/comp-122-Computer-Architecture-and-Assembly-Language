ldr r0,=data ;point to string

ldr r1,[r0]  ;pick up word

ldrb r2,[r0] ;pick up first byte

add r0,r0,#1 ;index to next

;ldr r1,[r0]  won't work...not on word boundary

ldrb r2,[r0]  ;pick up second byte

swi 0x11

data: .asciz "ABCD"
