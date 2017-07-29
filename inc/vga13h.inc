;
; VGA 13h
; Routines to work with VGA Mode 13h
; DEF FILE

; -------------------------------------------------------
;  DEFINES
; -------------------------------------------------------		
	SCREEN_W			equ 320
	SCREEN_H			equ 200
	
	COLOR_WHITE			equ	0x0F
	COLOR_GRAY			equ	0x08

; -------------------------------------------------------
;  MACROS
; -------------------------------------------------------		

	macro SetDrawColor DrawColor{
		mov 	al, DrawColor
	}			
			
	macro VertiLine x, y, l{    
		mov	di, x
		mov 	bx, y
		mov 	cx, l
		call 	line_v
	}

	macro HorizLine x, y, l{
		mov 	di, x
		mov 	bx, y
		mov		cx, l
		call	line_h
	}
	
	macro FillRect x, y, w, h{
		mov		di, x
		mov		bx, y
		mov		cx, w
		mov    	dx, h
		call	fill_rect
	}
    
