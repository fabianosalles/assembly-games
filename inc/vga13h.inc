;
; VGA 13h
; Routines to work with VGA Mode 13h
; DEF FILE

; -------------------------------------------------------
;  DEFINES
; -------------------------------------------------------		
	SCREEN_W			equ 320
	SCREEN_H			equ 200
	
	COLOR_BLACK			equ 0x00
	COLOR_BLUE			equ 0x01
	COLOR_GREEN			equ 0x02
	COLOR_CYAN			equ 0x03
	COLOR_RED			equ 0x04
	COLOR_MAGENTA		equ 0x05
	COLOR_BORWN			equ 0x06
	COLOR_LGRAY			equ 0x07	
	COLOR_LDGRAY		equ 0x08
	COLOR_LBLUE			equ 0x09
	COLOR_LGREEN		equ 0x0A
	COLOR_LCYAN			equ 0x0B
	COLOR_LMAGENTA		equ 0x0C	 
	COLOR_YELLOW		equ 0x0D
	COLOR_WHITE			equ 0x0E


; -------------------------------------------------------
;  MACROS
; -------------------------------------------------------		

	macro SetDrawColor DrawColor{
		mov 	al, DrawColor
	}			
			
	macro VertiLine x, y, l{    
		mov		di, x
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
    
