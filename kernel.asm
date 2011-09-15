; START OF MAIN KERNEL CODE
[BITS 16]
[org 0x0000]

os_main:
	
  mov ax,100h			; Set all segments to match where kernel is loaded
	mov ds, ax			
	mov es, ax			
				

;initialize STACK
	cli								; Clear interrupts
	mov ss, ax			  ; Set stack segment 
	mov sp, 0FFFFh		; Set stack pointer
	sti				        ; Restore interrupts

  ;mov si,welcome
	;call prints

while:
 mov si,stringa
 call prints

 mov di,prompt					;Index start prompt
 mov cx,DIM 					  ; Dimension of prompt
 call gets			
 mov si,prompt
 mov di,temp
 call decode_command
 call search_command
 mov si,temp
 mov cx,DIM
 call fflush
 mov si,tmp
 mov cx,DIM1
 call fflush
 ;call ascii_to_hex
 ;call change_color
jmp while
;================ FUNCTION ====================
prints:
pusha
	mov ax,0h

repeat:
  lodsb
  or al,al
	jz done			         ; If char is zero, end of string
  call putc				       
	jmp repeat

done:
	popa
	ret

putc:
pusha
  mov ah,0Eh
  mov bh,0
  mov bl,7h
	int 10h
popa
ret

getc:
pusha
	mov ax,0x00
	int 16h  
  mov [car],al
popa
ret

gets:
pusha
  cld
for:
  call getc
  mov al,[car]
  call putc 
  cmp al,8
  je .bk
  cmp al,10
  je .end
  cmp al,13
  je .end
  stosb
  inc bx
loop for
.bk:
  dec di
  mov byte [di],32
  mov al,[di]
  call putc
  mov ah,03
  mov bh,0
  int 10h
  dec dl
  mov ah,02h
  int 10h
  jmp for
.end:
 mov al,0x00
 stosb
 call acapo

popa
ret

acapo:
pusha
 mov al,13
 call putc
 mov al,10
 call putc
popa
ret

strcmp:
pusha
 .for:
   mov al,[si]
   mov bl,[di]
   cmp al,bl
   jne .not_eq
   
   cmp al,0
   je .end

	 inc si
   inc di
 jmp .for

.not_eq:
	popa
  stc					; CF = 1
 ret

.end:
  popa
  clc					; CF = 0
 ret

decode_command:
 push ax
 push cx

 mov ax,0
 mov cx,0

 .for:
	 mov al,[si]
   cmp al,32
   je .ignore
   cmp al,0
   je .end
   mov [di],al
   inc di
   inc si
   inc cx
 jmp .for

 .ignore:
   inc si
   inc cx
   mov al,[si]
   cmp al,32
  je .ignore

 .end:
   mov [i],cx
   pop cx
   pop ax
ret

search_command:
 pusha
 mov si,temp
 cmp byte [si],0
 jz .fin
 mov di,clear
 call strcmp
 jnc .cls
 mov si,temp
 mov di,colore
 call strcmp
 jnc .color
 jmp .not_found

 .cls:
   call cls
   popa
 ret
 .color:
   call ascii_to_hex
   mov al,[resto]
   cmp al,0x00
   jg .help_color
   call change_color
   ;cmp byte [car],0
   ;jle .help_color
   popa
 ret
 .help_color:
   mov si,hlp_color
   call prints
   mov si,lst_color1
   call prints
   mov si,lst_color2
   call prints
   mov si,lst_color3
   call prints
   mov si,lst_color4
   call prints
   call acapo
   popa
   mov al,0x00
   mov [resto],al
   mov [color],al
 ret
 .not_found:
   mov si,stringa2
   call prints
   popa
 ret
 .fin:
 popa
 ret

fflush:
  pusha
  mov ax,0
 .for:
   mov [si],al
   inc si
  loop .for
  popa
ret

cls:
pusha
  mov di,0xB800
  mov cx,80*25
 .for:
   mov al,32
   call putc
  loop .for
 
 mov ah,2
 mov dx,0
 mov bh,0
 int 10h
popa
ret

ascii_to_hex:
pusha
 mov si,prompt
 mov di,tmp
 mov ax,si
 add ax,[i]
 mov si,ax
 
 mov cx,0
 mov bx,0
 mov dx,0
.for:
  mov al,[si]
  cmp al,0
  je  conv
  sub al,48
  mov [di],al
  inc di
  inc si
  inc cx
jmp .for

 conv:
  mov si,tmp
 .for:
   dec cx
	 jz end
   push cx
   mov al,1
   mov dl,10
 .for1:
   mul dl
   dec cx
 jnz .for1
 mov dl,[si]
 mul dl
 add bl,al
 pop cx
 inc si
 jmp .for

 end:
  cmp bx,0
  je end1
  mov dl,16
  mov al,[si]
  add al,bl
  div dl
  mov [color],ah
  mov [resto],al
  popa
 ret
 end1:
  mov al,[si]
  mov [color],al
  popa
 ret
change_color:
  pusha
  push es
  mov ax,0x0B800
  mov es,ax
  mov di,0
  mov cx,80*25
.for:
  inc di
  mov al,[color]
  mov byte [es:di],al
  inc di
  loop .for

pop es  
popa
ret  
;============ VARIABILI ========================
 welcome    db "Welcome to kernel!",10, 13, 0
 stringa    db ">", 0
 stringa2   db "Comando non trovato.",10, 13, 0
 clear 		  db "cls", 0
 colore	    db "color", 0
 hlp_color  db "color [numero]",10, 13, "numero :      numero colore desiderato.",10, 13, 10, 13, 0
 lst_color1 db "0 black", 10, 13, "1 blue",10, 13, "2 green",10, 13, "3 cyan",10, 13, "4 red",10, 13, 0
 lst_color2 db "5 magenta",10 ,13, "6 brown",10, 13, "7 bright gray",10, 13, "8 gray",10, 13, 0
 lst_color3 db "9 bright blue",10 ,13, "10 bright green",10, 13, "11 bright cyan",10, 13, 0
 lst_color4 db "12 bright red",10, 13, "13 bright magenta",10, 13, "14 yellow",10, 13, "15 white",10, 13, 0
 prompt times 80 db 32
 temp   times 80 db 0
 tmp    times 4  db 0
 car       db 0						;memorizza temporaneamente il carattere premuto
 color     db 0						;memorizza il colore del testo
 resto     db 0						
 i         dw 0

 DIM  equ 80
 DIM1 equ 4
 textMem equ 0xB8000
