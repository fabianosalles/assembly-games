;
; Pong for 8086 processor using fasm syntax
; Fabiano Salles <fabiano.salles@gmail.com>
; ------------------------------------------------------------
; This program run in VGA mode 13h using direct VGA addressing
; ------------------------------------------------------------
; Use W and A to move player 1.
; Use Up and down keys to move player 2.
;

use16 						; 16bit bin (dos COM)
org	0x0100

include 'inc/vga13h.inc'

; -------------------------------------------------------
;  DEFINES
; -------------------------------------------------------
	OFFSCREEN_BASE   		equ 0x1000
	OFFSCREEN_SEGMENT		equ fs
	VGA_BASE				equ 0xA000
	VGA_SEGMENT				equ gs
	VGA_WORDS_COUNT			equ 0x7D00 ; number of words in display memory (320 * 200 / 2) 	
	USE_VSYNC				equ 0		; 0=disabled, 1=enabled 
	MAXX					equ 320-1
	MAXY					equ 200-1
	PLAYER_HEIGHT			equ 28
	PLAYER_WIDTH			equ 4
	PLAYER_OFFSET			equ 2 		; space between player and field
	BALL_SIZE				equ 4
	
	VK_SCAPE				equ 01h
	VK_W                 	equ 11h
	VK_S                 	equ 1Fh
	VK_UP					equ 48h	
	VK_DOWN					equ 50h	
	VK_LEFT					equ 4Bh			
	VK_RIGHT				equ 4Dh				
	
	jmp start
	
;left arrow	: 4Bh 
;up arrow	: 48h
;right arrow: 4D
;down arrow	: 50 D0
	
; -------------------------------------------------------
;  DATA TYPES 
; -------------------------------------------------------
struc Ball x, y, speedX, speedY {
		.x			dw x  	; max x = 320, a word is necessary
		.y			dw y	; max y = 200, a byte is enough
		.speedX		dw 0
		.speedY		dw 0
		
}
struc Player x, y, speed, score {
		.x			dw	x
		.y			dw	y		
		.speed	dw speed
		.score	dw score
}

; -------------------------------------------------------
; DATA 
; -------------------------------------------------------
	ball		Ball 0, 0, 0, 0 
	player1 	Player ?, ?, 5, 0
	player2 	Player ?, ?, 5, 0
	lastKey		db ?
	buffer   	db "$"


; -------------------------------------------------------
;  MACROS
; -------------------------------------------------------
	
macro SwapBuffers{
	; Preload registers for fast swap 
	; once vertical reset is detected 
	mov		ax, OFFSCREEN_SEGMENT  
	mov		ds, ax 
	xor		si, si 		
	mov		ax, VGA_SEGMENT
	mov		es, ax 
	xor		di, di 		
	mov		cx, VGA_WORDS_COUNT ; number of words to move (320 * 200 / 2) 	
	; Wait for vertical reset 
if USE_VSYNC
	mov     dx,0x03DA 
vend:  
	in      al,dx 
	test    al,0x08 
	jz      vend 
vres:  
	in      al,dx 
	test    al,0x08 
	jnz     vres 
end if 
	; Copy offscreen buffer into video memory 
	rep     movsw 	; move two pixels each pass 
	; Restore data segment register 
	mov     ax, cs 
	mov     ds, ax 	
}

macro DrawBall{		
	; Paint single pixel into offscreen buffer         
	SetDrawColor COLOR_WHITE
	mov	bx, [ball.y]					; y
	mov di, [ball.x]					; x
	sub	bx, BALL_SIZE / 2
	sub di, BALL_SIZE / 2
	mov	cx, BALL_SIZE
	mov	dx, BALL_SIZE
	call 	fill_rect			
}

macro DrawField{
	SetDrawColor COLOR_LGRAY
	VertiLine 160, 0, SCREEN_H			; Render the middle line (field divider)		
	
	SetDrawColor COLOR_WHITE
	VertiLine 0, 0, SCREEN_H			; Render left horizontal line
	VertiLine MAXX, 0, SCREEN_H		; Render right horizontal line
	HorizLine 0, 0, SCREEN_W			; Render top line into offscreen buffer 
	HorizLine 0, MAXY, SCREEN_W 		; Render bottom line into offscreen buffer         	
}

macro DrawPlayers{
	SetDrawColor COLOR_WHITE
	FillRect [player1.x], [player1.y], PLAYER_WIDTH, PLAYER_HEIGHT
	FillRect [player2.x], [player2.y], PLAYER_WIDTH, PLAYER_HEIGHT		
}


macro gotoXY linha, coluna{            
	mov     ah, 02h      ; ah=02 set cursor position
	mov     bh, 0        ; page number
	mov     dh, coluna   ; row
	mov     dl, linha    ; column
	int     10h          ; call bios function
}

; dx = text address
; bx = color
; cx = count of chars to apply the color
macro print texto, tamanho, cor{
	mov     dx, word texto
	mov     cx, tamanho 
	mov     bx, cor    
	mov     ax, 0920h           ; AH=Function number AL=Space character  
	int     10h                 ; INT 10h/AH=9 - write character and attribute at cursor position.
	int     21h                 ; INT 21h/AH=9 - output of a string at DS:DX. String must be terminated by '$'. 
}

	
; -------------------------------------------------------
;  CODE
; -------------------------------------------------------
start:
   cli 							; disable interrupts 
   mov	ax, cs           		; code,data,stack share same segment 
   mov	ds, ax 
   mov	ss, ax 
   xor	sp, sp 

   add	ax, OFFSCREEN_BASE  	; Offscreen buffer segment 
   mov	OFFSCREEN_SEGMENT, ax 
   mov	ax, VGA_BASE      		; Video memory segment 
   mov	VGA_SEGMENT, ax 		; will be in gs 
   sti							; we'e done so, reenable interrupts

   ; Setup normal string direction flag (string instructions increment pointers)
   cld 								; Clear Direction Flag for string instructions
   mov   ax, 0x0013 				; Enter 320x200 graphics video mode 
   int	0x10      					; invoke BIOS VIDEO service 

   init_vars: 						;init players
		mov [player1.x], PLAYER_OFFSET
		mov [player1.y], ((MAXY+1)/2)-(PLAYER_HEIGHT/2)		

		mov [player2.x], MAXX-PLAYER_WIDTH-PLAYER_OFFSET
		mov [player2.y], ((MAXY+1)/2)-(PLAYER_HEIGHT/2)		

		;centralize the ball on screen and set initial speed
		mov [ball.x], (MAXX+1) / 2
		mov [ball.y], (MAXY+1) / 2		
		mov [ball.speedX], 	2
		mov [ball.speedY], 	2
   
   main_loop:	
		call   prepareBuffer			
		call   captureInput		
		call   updateData
		DrawField
		DrawBall		
		DrawPlayers				
		call  printHUD
		SwapBuffers
				
		cmp	[lastKey], VK_SCAPE		
		jne main_loop
   
   exit:			
		mov	ax, 0003h 	; Enter 80x25 text video mode 
		int 10h      	; invoke BIOS VIDEO service 		
		int 20h			; Return to operating system (DOS)
		jmp $    		; just in case 

; end of :start   

		
; -------------------------------------------------------
;  SUB ROUTINES
; -------------------------------------------------------
prepareBuffer:   
   mov   ax, OFFSCREEN_SEGMENT ; Get offscreen buffer segment into ES 
   mov   es, ax 
                                 ; Clear offscreen buffer to black 
   xor   di, di     				; initial destination offset 
   xor   ax, ax     				; bk-fg pixel color (twice) 
   mov   cx, VGA_WORDS_COUNT 	; number of words in display memory (320 * 200 / 2) 
   rep   stosw     				; write two pixels each pass 
   ret
	
		
captureInput:
	pusha		
	in 	al, 060h    	; get key code				
	cmp   al, VK_W
	jne   captureInput.s
	sub   [player1.y], 5
	.s:
	cmp   al, VK_S
	jne   captureInput.up
	add   [player1.y], 5
	.up:
	cmp 	al, VK_UP
	jne	captureInput.down
	sub   [player2.y], 5			
	.down:
	cmp 	al, VK_DOWN
	jne	captureInput.return
	add   [player2.y], 5			
	.return:		
	mov	[lastKey], al	; save the last readed key	
	popa
	ret

updateData:
	pusha

	@@:   ; validate top position
	cmp	[player1.y], 0
	jge	@f
	mov	[player1.y], 0		
			
	; validate vbottom position
	; if (p1.y + PLAYER_HEIGHT > MAXY) { p1.y = MAXY-PLAYER_HEIGHT }
	@@: 	
	mov	ax, [player1.y]
	add	ax, PLAYER_HEIGHT
	cmp	ax, MAXY
	jbe	@f
	mov	[player1.y], (MAXY-PLAYER_HEIGHT)	
	
	; update ball position based on it's speed vector
	; ball.x += ball.speedX 
	; ball.y += ball.sppedY
	@@:   	
	mov ax, [ball.speedX]
	mov bx, [ball.speedY]
	add	[ball.x], ax	
	add	[ball.y], bx				

	; validate ball position (Y axixs)
	@@: ; if (ball.y > (MAXY - BALL_SIZE)) || ( ball.y <= 0)) { ball.speedY = -ball.speedY }
	cmp	[ball.y], (MAXY - BALL_SIZE -1)
	jg	updateData.negY
	cmp	[ball.y], 0	
	jg	@f
	.negY:
	neg	[ball.speedY]		

	; validate ball position (X axixs)
	@@: ; if (ball.x > (MAXY - BALL_SIZE)) || (ball.x <=0)) { ball.speedY = -ball.speedY }
	cmp [ball.x], (MAXX - BALL_SIZE +1)
	jg updateData.negX
	cmp [ball.x], 0
	jg @f
	.negX:
	neg [ball.speedX]

	; if ( ball.x < 0) 
			
	.collisions: ; collisions	
	;call ballCollidedP1
	;cmp  ax, ax
	;jz   @f
	;neg  [ball.speedX]
	@@:
	call ballCollidedP2
	cmp  ax, ax
	jz  @f
	neg  [ball.speedX]
	
	@@:
	.return:
	popa
	ret

ballCollidedP1:         
   mov   ax, [player1.x]
   mov   bx, [player1.y]
   mov   cx, ax
   add   cx, PLAYER_WIDTH
   mov   dx, [player1.y]
   add   dx, PLAYER_HEIGHT
   call  ballCollideRect;        
   ret   

ballCollidedP2:
   ;int   03h   ;software break point
   mov   ax, [player2.x]
   mov   bx, [player2.y]
   mov   cx, MAXX-PLAYER_OFFSET
   mov   dx, [player2.y]
   add   dx, PLAYER_HEIGHT
   call  ballCollideRect;        
   ret   
   

;------------------------------------------------------------------------ 
; ballCollideRect - check if the ball collided with a rect
; return ( (b.x >= x0 && bx. <= x1) && (b.y >= y1 && b.y <= y2))
; Input: 
;   AX = x0
;   BX = y0 
;   CX = x1
;   DX = y1
;   return value = AX;   
; TODO: correct the faulty implementation
;------------------------------------------------------------------------ 	
ballCollideRect:      
   cmp   ax, [ball.x]
   jge   ballCollideRect.true   
   jmp   ballCollideRect.false         
   .true:         
   mov   ax, 01h
   ret   
   .false:      
   mov   ax, 00h   
   ret
	
	
printHUD:
   gotoXY 10, 30
   print buffer, 2, COLOR_WHITE

   ;gotoXY  0, 10      
   ; print   str_game_divider, 80, GAME_TEXT_ERRO    
   ; gotoXY  0, 11
   ; print   str_game_over, 180, GAME_TEXT_ERRO   
   
   ret
		
include 'inc/vga13h.asm'			
	
