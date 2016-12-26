;
; Pong for 8086 processor using emu8086 syntax
; Fabiano Salles <fabiano.salles@gmail.com>
; ------------------------------------------------------------
; This program run in VGA mode 13h using direct VGA addressing
; ------------------------------------------------------------

use16 						; 16bit bin (dos COM)
org	0x0100

include 'macro/struct.inc'
include 'inc/vga13h.inc'

; -------------------------------------------------------
;  DEFINES
; -------------------------------------------------------
	OFFSCREEN_BASE   	equ 0x1000
	OFFSCREEN_SEGMENT	equ fs	
	VGA_BASE			equ 0xA000	
	VGA_SEGMENT			equ gs
	VGA_WORDS_COUNT		equ 0x7D00 		; number of words in display memory (320 * 200 / 2) 	
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
;  MACROS
; -------------------------------------------------------
	macro PrepareBuffer{
		; Get offscreen buffer segment into ES 
        mov		ax, OFFSCREEN_SEGMENT
        mov		es, ax 

        ; Clear offscreen buffer to black 
        xor     di, di     				; initial destination offset 
        xor     ax, ax     				; bk-fg pixel color (twice) 
        mov     cx, VGA_WORDS_COUNT 	; number of words in display memory (320 * 200 / 2) 
        rep     stosw     				; write two pixels each pass 
	}
	
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
		mov		bx, [ball.y]					; y
		mov 	di, [ball.x]					; x
		sub		bx, BALL_SIZE / 2
		sub     di, BALL_SIZE / 2
		mov		cx, BALL_SIZE
		mov		dx, BALL_SIZE
		call 	fill_rect			
	}
	
	macro DrawField{
		SetDrawColor COLOR_GRAY
		VertiLine 160, 0, SCREEN_H			; Render the middle line (field divider)		
		
		SetDrawColor COLOR_WHITE
		VertiLine 0, 0, SCREEN_H			; Render left horizontal line
		VertiLine MAXX, 0, SCREEN_H			; Render right horizontal line
		HorizLine 0, 0, SCREEN_W			; Render top line into offscreen buffer 
		HorizLine 0, SCREEN_H, SCREEN_W 	; Render bottom line into offscreen buffer         	
	}
	
	macro DrawPlayers{
		SetDrawColor COLOR_WHITE
		FillRect [player1.x], [player1.y], [player1.width], PLAYER_HEIGHT
		FillRect [player2.x], [player2.y], [player2.width], PLAYER_HEIGHT		
	}

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
	
		PrepareBuffer			
		DrawField		
		DrawBall
		DrawPlayers				
		SwapBuffers
  
		
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
		


    
include 'inc/vga13h.asm'
		
; -------------------------------------------------------
; DATA 
; -------------------------------------------------------
	ball	Ball		
	player1 Player
	player2 Player


