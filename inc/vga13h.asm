;
; VGA 13h
; Routines to work with VGA Mode 13h
;
VGA_SCREEN_WIDTH	EQU	320
VGA_SCREEN_HEIGHT	EQU	200
VGA_BASE_MEMORY		EQU 0A000h


macro putPixel x, y, color{
	mov cx, x  	; column
	mov dx, y  	; row
	mov ah, 0Ch ; pet pixel
	int 10h
}

