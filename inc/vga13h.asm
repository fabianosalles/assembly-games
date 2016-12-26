;
; VGA 13h
; Routines to work with VGA Mode 13h
; ASM FILE


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
