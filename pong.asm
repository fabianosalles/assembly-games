;
; TicTacTe for 8086 processor using emu8086 sintax
; Fabiano Salles <fabiano.salles@gmail.com>
; ------------------------------------------------------------
; This program run in VGA mode 13h using direct VGA addressing
; ------------------------------------------------------------

use16 						; 16bit bin (dos COM)
org	0x0100

include 'macro/struct.inc'

; -------------------------------------------------------
;  DEFINES
; -------------------------------------------------------
	OFFSCREEN_BASE   	equ 0x1000
	OFFSCREEN_SEGMENT	equ fs	
	VGA_BASE			equ 0xA000	
	VGA_SEGMENT			equ gs
	VGA_WORDS_COUNT		equ 0x7D00 		; number of words in display memory (320 * 200 / 2) 	
	COLOR_WHITE			equ 0x0F 		; white over a black background
	COLOR_GRAY			equ 0x08        ; gray over a black background
	USE_VSYNC			equ 0		    ; 0=disabled, 1=enabled 
	MAXX				equ 320-1
	MAXY				equ 200-1
	PLAYER_HEIGHT		equ 28
	PLAYER_WIDTH		equ 4
	PLAYER_OFFSET		equ 2 			; space between player and field
	BALL_SIZE			equ 4
	
; -------------------------------------------------------
;  DATA TYPES 
; -------------------------------------------------------
struct Ball
	x			dw ?    				; max x = 320, a word is necessary
	y			dw ?					; max y = 200, a byte is enough
ends

struct Player
	x			dw	?
	y			dw	?
	height		dw  PLAYER_HEIGHT
	width		dw  PLAYER_WIDTH
	score		dw  0
ends

; -------------------------------------------------------
;  CODE
; -------------------------------------------------------
	start:
        cli 						; disable interrupts 
        mov		ax, cs           	; code,data,stack share same segment 
        mov		ds, ax 
        mov		ss, ax 
        xor		sp, sp 
		
        add		ax, OFFSCREEN_BASE  	; Offscreen buffer segment 
        mov		OFFSCREEN_SEGMENT, ax 
        mov		ax, VGA_BASE      		; Video memory segment 
        mov		VGA_SEGMENT, ax 		; will be in gs 
        sti								; wer'e done so, reenable interrupts

        ; Setup normal string direction flag so 
        ; string instructions increment pointers 		
        cld 	; DF = 0 

        ; Enter 320x200 graphics video mode 
        mov     ax, 0x0013 		; AH = sub-function (set video mode) 
								; AL = desired video mode 
        int 	0x10      		; invoke BIOS VIDEO service 
	
	init_vars:
	;init players
		mov [player1.x], PLAYER_OFFSET
		mov [player1.y], ((MAXY+1)/2)-(PLAYER_HEIGHT/2)		
		
		mov [player2.x], MAXX-PLAYER_WIDTH-PLAYER_OFFSET+1
		mov [player2.y], ((MAXY+1)/2)-(PLAYER_HEIGHT/2)
		
	;centralize the ball on screen
		mov [ball.x], (MAXX+1) / 2
		mov [ball.y], (MAXY+1) / 2
		
	main_loop:
	
        ; Get offscreen buffer segment into ES 
        mov		ax, OFFSCREEN_SEGMENT
        mov		es, ax 

        ; Clear offscreen buffer to black 
        xor     di, di     				; initial destination offset 
        xor     ax, ax     				; bk-fg pixel color (twice) 
        mov     cx, VGA_WORDS_COUNT 	; number of words in display memory (320 * 200 / 2) 
        rep     stosw     				; write two pixels each pass 
	
	draw_field:
		
		; Render the middle line (field divider)
		mov     al, COLOR_GRAY
		mov		bx, 0			; y
		mov		di, 160 	; x
		mov		cx, MAXY+1		; length
		call 	line_v
		
		; Render left horizontal line
		mov     al, COLOR_WHITE  	; color (white on black) 
		mov		bx, 0			; y
		mov		di, 0  			; x
		mov		cx, MAXY+1		; length
		call 	line_v
		
		; Render right horizontal line
		mov		bx, 0			; y
		mov		di, MAXX 		; x
		mov		cx, MAXY+1		; length
		call 	line_v
		
		; Render top line into offscreen buffer 
        mov     al, COLOR_WHITE  	; color (white on black) 
        mov     bx, 0     			; y 
        mov     di, 0     			; x 
        mov     cx, MAXX+1  		; length 
        call    line_h

        ; Render bottom line into offscreen buffer         
        mov     bx, MAXY   			; y 
        mov     di, 0     			; x 
        mov     cx, MAXX+1   			; length 
        call    line_h		
		
	draw_ball:
        ; Paint single pixel into offscreen buffer         
		mov		bx, [ball.y]					; y
		mov 	di, [ball.x]					; x
		sub		bx, BALL_SIZE / 2
		sub     di, BALL_SIZE / 2
		mov		cx, BALL_SIZE
		mov		dx, BALL_SIZE
		call 	fill_rect
		
		
	draw_players:
		; Draw player 1
		mov		bx, [player1.y]					; y
		mov 	di, [player1.x]					; x
		mov		cx, [player1.width]
		mov		dx, PLAYER_HEIGHT
		call 	fill_rect
		
		; Draw player 2
		mov		bx, [player2.y]					; y
		mov 	di, [player2.x]					; x
		mov		cx, [player2.width]
		mov		dx, PLAYER_HEIGHT
		call 	fill_rect		
		
  
	swap_buffes:
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
        rep     movsw ; move two pixels each pass 
        ; Restore data segment register 
        mov     ax, cs 
        mov     ds, ax 
		
		; Wait for a keypress
		mov		ah, 0x01 				; AH = sub-function (check for keystroke) 
        int		0x16    				; invoke BIOS KEYBOARD service 
        jz 		main_loop   			; continue to loop until keystroke is found 

	exit:
        ; Remove keystroke from keyboard buffer 
        mov 	ah, 0x00 				; AH = sub-function (remove keystroke) 
        int 	0x16    				; invoke BIOS KEYBOARD service 

        ; Enter 80x25 text video mode 
        mov 	ax, 0x0003 				; AH = sub-function (set video mode) 
										; AL = desired video mode 
        int 	0x10      				; invoke BIOS VIDEO service 

        ; Return to operating system 
        int     0x20 
        jmp     $    ; just in case 
		
		
; -------------------------------------------------------
;  GENERAL PURPOSE ROUTINES
; -------------------------------------------------------		
    ;------------------------------------------------------------------------
    ; set_pixel - Render single pixel into offscreen buffer 
    ; Input: 
    ;   AL = color 
    ;   BX = y 
    ;   DI = x 
    ;   ES = offscreen buffer segment 
    ;------------------------------------------------------------------------ 
    set_pixel: 
        pusha 
        shl		bx, 6 
        add		di, bx 
        shl		bx, 2 
        add		di, bx 
        mov		byte[es:di],al 
        popa 
        ret 
		
		
    ;------------------------------------------------------------------------ 
    ; line_h - Render horizontal line into offscreen buffer 
    ; Input: 
    ;   AL = color 
    ;   BX = y 
    ;   DI = x 
    ;   CX = length 
    ;   ES = offscreen buffer segment 
    ;------------------------------------------------------------------------ 
    line_h: 
        pusha 
        shl		bx, 6 
        add		di, bx 
        shl		bx, 2 
        add		di, bx 
        rep		stosb 
        popa 
        ret 
		
	;------------------------------------------------------------------------ 
    ; line_v - Render vertical line into offscreen buffer 
    ; 
    ; Input: 
    ;   AL = color 
    ;   BX = y 
    ;   DI = x 
    ;   CX = length 
    ;   ES = offscreen buffer segment 
    ;------------------------------------------------------------------------ 
    line_v: 
        pusha 
        shl     bx, 6 
        add     di, bx 
        shl     bx, 2 
        add     di, bx 
    .loop: 
        mov     byte[es:di],al 
        add     di,320 
        loop    .loop 
        popa 
        ret 

    ;------------------------------------------------------------------------ 
    ; fill_rect - Renders color filled recatngle into offscreen buffer 
    ; Input: 
    ;   BX = y 
    ;   DI = x 
    ;   CX = width 
    ;   DX = height 
    ;   AL = color 
    ;   ES = offscreen buffer segment 
    ;------------------------------------------------------------------------ 
    fill_rect: 
        pusha 
        mov     si,320 
        sub     si, cx  ; SI = offset to next scan line start 
        shl     bx, 6 
        add     di, bx 
        shl     bx, 2 
        add     di, bx 
    .loop: 
        push    cx 
        rep     stosb 
        pop     cx 
        add     di, si ; advance offset to next scan line start 
        sub     dx, 1  ; move up to the next y position 
        jnz     .loop 
        popa 
        ret 		
    
		
; -------------------------------------------------------
; DATA 
; -------------------------------------------------------
	ball	Ball		
	player1 Player
	player2 Player


