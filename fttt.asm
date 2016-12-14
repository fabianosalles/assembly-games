;
; Fabiano Salles <fabiano.salles@gmail.com>
; TicTacTe for 8086 processor using emu8086 sintax
; 
	format MZ					; multi segment format
	use16 						; code starts at offset 100h
	entry			main:start	; exe entry point
	stack			100h		; stack size
	include 'macro/proc32.inc'

;
; constants 
;
    PLAYER_NAME_SIZE    equ 33   ; 32 bytes para o nome +1 para o $
    P1_CHAR             equ 78h  ; x
    P1_COLOR            equ 0Fh  ; white
    P2_CHAR             equ 4Fh  ; o    
    P2_COLOR            equ 09h  ; light blue    
    GAME_TEXT_COLOR     equ 07h  ; light gray  
    GAME_TEXT_SHADOW    equ 08h  ; dark gray        
    GAME_TEXT_SUCCESS   equ 0Ah  ; light green
    GAME_TEXT_ERRO      equ 0Ch  ; light red

	SYMBOL_LIGHT_SMILE	equ	01h
	SYMBOL_DARK_SMILE	equ	02h
	SYMBOL_HEART		equ 03h
	SYMBOL_DIAMOND		equ 04h
	SYMBOL_CLUBS		equ 05h
	SYMBOL_SPADES		equ 06h 
	SYMBOL_MALE			equ 0Ch
	SYMBOL_FEMALE		equ 0Bh
	SYMBOL_X			equ 78h
	SYMBOL_O			equ 6Fh

; game states
    ST_MENU            equ 0h ; o jogo está no menu inicial
    ST_JOGANDO         equ 1h ; o jogo está rolando
    ST_GAME_OVER       equ 2h ; game over  
    ST_VITORIA         equ 3h  

segment text
; variáveis
    player_1            DB P1_CHAR, P1_COLOR, "Player 1                        $"
    player_2            DB P2_CHAR, P2_COLOR, "Player 2                        $"
    
    game_state          DB 0  ; 0 = menu, 1 = playing, 2 = game over
    current_player      DB 1      
    current_color       DB 0
    current_char        DB 0
    new_line            DB 13,10,"$" ; new line chars    
    game_over_message   DB "GAME OVER", 13, 10, "$"        
    str_game_divider    DB '-------------------------------------------------------------------------------$'
    str_game_header     DB '                             [  ASM TIC TAC TOE  ]                             $'
    grid                DB 9 DUP(0)  
    grid_buffer         DB '                                     |   |   ', 13, 10
                        DB '                                  ---+---+---', 13, 10
                        DB '                                     |   |   ', 13, 10
                        DB '                                  ---+---+---', 13, 10
                        DB '                                     |   |   ', 13, 10, '$'                                                
    str_player1_set_name  	DB 'Player 1, inform your name : $' 
    str_player2_set_name  	DB 'Player 2, inform your name : $' 
    str_player_set_color 	DB 'Choose your colour         : $'
    str_player_set_char  	DB 'Choose your symbol         : $'
	str_ftr_cores       	DB 'Colors   : 1.white 2.blue 3.green 4.red$'
    str_ftr_simbolos     	DB 'Symbols  : 1.', 01   ; sorriso claro
                                   DB ' 2.', 02    ; sorriso escuro
                                   DB ' 3.', 03    ; copa (coração)
                                   DB ' 4.', 04    ; losango (ouro)
                                   DB ' 5.', 05    ; paus
                                   DB ' 6.', 06    ; espadas
                                   DB ' 7.', 11    ; macho  
                                   DB ' 8.', 12    ; fêmea
                                   DB ' 9.x 0.o  $'
    
    str_ok              DB 'Ok!$'
    str_iniciando       DB 'Starting...$'
    str_type_position   DB ', inform a position : $'
    str_vitoria         DB 'VICTORY!!!', 13, 10
                        DB 'The player $' 
    str_votoria_suf     DB ' wins!$' ; sufixo;
    str_game_over       DB 'Game over!', 13, 10
                        DB 'TIE!$'   
    str_bye             DB ' $'              
  

segment main    

; this macro prints a char in AL and advances
; the current cursor position:
macro putc char {
	push    ax
	mov     al, byte char
	mov     ah, 0Eh
	int     10h     
	pop     ax
}


; dx = endereço do texto
; bx = cor 
; cx = o número de caracteres a colorir
macro print texto, tamanho, cor{
    mov     dx, word texto
    mov     cx, tamanho 
    mov     bx, cor    
    mov     ax, 0920h           ; AH=Function number AL=Space character  
    int     10h                 ; INT 10h/AH=9 - write character and attribute at cursor position.
    int     21h                 ; INT 21h/AH=9 - output of a string at DS:DX. String must be terminated by '$'. 
}


start:    
; set segment registers
    mov     ax, text        ; load the data segment address into ax
    mov     ds, ax          ; set the data current segment
    
; enable mode 3h (16 colors 80 x 25)
; setup_screen 
    mov     ax, 1003h   
    mov     bx, 0
    int     10h    
    
    main_loop:  
        call    clear_screen
        call    draw_scene
        jmp     main_loop  
    
    return_to_os:
        print   str_bye, 10, GAME_TEXT_COLOR      ; reseta a cor do console      
        mov     ax, 4C00h                       ; al = retur code = 0 ; no erros        
        int     21h                             ;INT 21h / AH=4Ch - return control to the operating system (stop program).    
        ret
        
           
       
; set the video to mode 03 
; (setar o modo de vídeo sempre apaga o buffer da tela)
;   ah = 0 (set video mode function)
;   al = 3 (text mode) 80 x 25 16 colors                                           
clear_screen:
    mov     ax, 0003h     
    int     10h         
    ret

                                        
; read keyboard and return content in ah    
get_key:
    mov     ah, 1       
    int     21h    
    mov     ah, 0
    ret     

    
macro gotoXY linha, coluna{
    push    ax
    push    bx
    push    dx    
; configura parâmetros e função 
    mov     ah, 02h    
    mov     bh, 0      
    mov     dh, coluna
    mov     dl, linha
    int     10h             ;chama a função          
; restauração dos registradores
    pop     dx    
    pop     bx
    pop     ax
}


macro print_addr texto, position, tamanho, cor{
    mov     dx, texto
    add     dx, position  
    mov     cx, tamanho 
    mov     bx, cor    
    mov     ax, 0920h           ; AH=Function number AL=Space character  
    int     10h                 ; BIOS function
    int     21h                 ; DOS function
}


;
; char must be in al register
;
proc print_char 	
    cmp     al, 0
    je      print_char_exit
    
    push    bx
    push    cx                 

    mov     ah, 9h              ; function 9h write character and attribute at cursor position.        
    mov     bh, 0               ; page number
    mov     bl, [current_color] ; color atrib
    mov     cx, 1               ; number of times to print the char
    int     10h                 ; call the function
                                
    pop     cx
    pop     bx
                
	print_char_exit:
    ret
endp

beep:
    push dx
    push ax
    
    mov dl, 07h
    mov ah, 2    
    int 21h
    
    pop ax
    pop dx
    
    ret
    
;
; lê uma posião do teclado e salva o conteúdo no grid
; (deve ser um input de 1 a 9)
; o joga
;le_jogada macro jogador
le_jogada:
	inicio:    
		call    get_key                    ; le a jogada em ah
		cmp     al, 31h       
		jl      invalido                   ; o valor deve estar entre 1 e 9 (31h e 39h em ascii)
		cmp     al, 39h                    ; vamos validar com 2 cmp's
		jg      invalido
		
		sub     al, 31h                   ; converte o ascii no índice o grid
		mov     si, grid                  ; carrega o endereço do grid em si        
		add     si, ax                    ; desloca di até a posição selecionada 	
		
		; temos um indice válio, mas ele está livre?    
		cmp     byte[ds:si], 0                  		
		jne     invalido    
		
		; configura o jogador
		cmp     [current_player], 1
		jne     set_p2_grid_char
		jmp     set_p1_grid_char

	set_p1_grid_char:
		mov     bl, [player_1+0]
		mov     [ds:si], bl                 ; salva a jogada na posicao correta do grid            
		jmp     return
		
	set_p2_grid_char:    
		mov     bl, [player_2+0]
		mov     [ds:si], bl                 ; salva a jogada na posicao correta do grid        
		jmp     return
		
	invalido:
	   call beep        
	   call clear_last_char   
	   jmp  inicio

	return:
		ret

   
;
; seleciona um símbolo da lista de opções
; os valores podem ser de 0 a 9
; retorna em al
select_player_symbol:
	read_symbol:        
		call    get_key                 ; le a opção e joga em al    
		cmp     al, 30h
		jl      invalid_symbol
		cmp     al, 39h
		jg      invalid_symbol     
		sub     al, 30h                  ; converte o ascii em     		
		
; the symbol selection is valid. let's adjust the glyth code
; fom 1 to 6 is already right
		cmp		al, 0
		je		set_symbol_0
		cmp		al, 7
		je		set_symbol_male
		cmp		al, 8
		je		set_symbol_female
		cmp		al, 9
		je		set_symbol_x
		jmp 	invalid_symbol
		
	set_symbol_x:
		mov		al, SYMBOL_X
		jmp 	select_player_symbol_return
		
	set_symbol_0:		
		mov		al, SYMBOL_O
		jmp 	select_player_symbol_return
		
	set_symbol_male:
		mov		al, SYMBOL_MALE
		jmp 	select_player_symbol_return
		
	set_symbol_female:
		mov		al, SYMBOL_FEMALE		
		jmp 	select_player_symbol_return
		
	invalid_symbol:
		call    beep
		call    clear_last_char
		jmp     read_symbol
		
	select_player_symbol_return:
		ret
       
;
; selecina uma cor da lista de opções
; os valores possíveis são 1..4
;       
select_player_color:
	read_color:
		call    get_key
		cmp     al, 31h     ; 1
		jl      invalid_color
		cmp     al, 34h     ; 4
		jg      invalid_color
		
		sub     al, 30h
		ret
	invalid_color:
		call    beep
		call    clear_last_char
		jmp     read_color    

   
clear_last_char:
   putc    8                       ; backspace.
   putc    ' '                     ; clear position.
   putc    8                       ; backspace again.       
   ret


;***************************************************************
; This macro defines a procedure to get a $ terminated
; string from user, the received string is written to buffer
; at DS:DI, buffer size should be in DX.
; Procedure stops the input when 'Enter' is pressed.
;***************************************************************              
get_string:
    PUSH    AX
    PUSH    CX
    PUSH    DI
    PUSH    DX
    
    MOV     CX, 0                   ; char counter.    
    CMP     DX, 1                   ; buffer too small?
    JBE     empty_buffer            ;    
    DEC     DX                      ; reserve space for last zero.    
    
    ;============================
    ; loop to get and processes key presses:    
    wait_for_key:
    
    MOV     AH, 0                   ; get pressed key.
    INT     16h    
    CMP     AL, 13                  ; 'RETURN' pressed?
    JZ      exit
    
    CMP     AL, 8                   ; 'BACKSPACE' pressed?
    JNE     add_to_buffer
    JCXZ    wait_for_key            ; nothing to remove!
    DEC     CX
    DEC     DI
    putc    8                       ; backspace.
    putc    ' '                     ; clear position.
    putc    8                       ; backspace again.
    JMP     wait_for_key
    
    add_to_buffer:    
            CMP     CX, DX          ; buffer is full?
            JAE     wait_for_key    ; if so wait for 'BACKSPACE' or 'RETURN'...    
            MOV     [DI], AL
            INC     DI
            INC     CX            
            ; print the key:
            MOV     AH, 0Eh
            INT     10h
    
    JMP     wait_for_key
    ;============================
    
    exit:    
    ; terminate by $:
    MOV     word[DI], '$'
        
    empty_buffer:    
    POP     DX
    POP     DI
    POP     CX
    POP     AX
    RET

	
;
; ajustar cor em função do jogador 
; o jogardor
proc adjust_grid_color    
    mov     ch, [grid+bx] 
    cmp     ch, 0               ; compara o caractere grid[bx] a ser impresso
    je      set_null            ;
    
    cmp     ch, [player_1+0]
    je      set_p1
    jmp     set_p2    
    
    set_null:    
    mov     [current_color], GAME_TEXT_COLOR
    jmp     adjust_grid_char_return        

    set_p1:    
    mov     cl, [player_1+1]     
    mov     [current_color], cl
    jmp     adjust_grid_char_return     
    
    
    set_p2:    
    mov     cl, [player_2+1]    
    mov     [current_color], cl    
    jmp     adjust_grid_char_return     
    
	adjust_grid_char_return:        
    ret    
endp    
    
;
; desenha o grid do jogo
;
draw_grid:
		
	; 1. denha o  grid vazado  
		gotoXY  0, 4
		print grid_buffer, 370, GAME_TEXT_SHADOW

	; 2. preenche os nove espaços com as jogadas realizadas        
		mov     [current_color], 0      ; cor em cl    
		mov     bx, 0
        
		; primeira linha
		gotoXY  35, 4            
		call 	adjust_grid_color
		mov 	al, [grid+0] 
		call 	print_char 
		inc     bx

		gotoXY  39, 4    
		call 	adjust_grid_color
		mov 	al, [grid+1]
		call 	print_char 
		inc     bx
		
		gotoXY  43, 4
		call 	adjust_grid_color
		mov		al, [grid+2] 
		call	print_char 
		inc     bx
		
		; segunda linha
		gotoXY  35, 6
		call 	adjust_grid_color            
		mov		al, [grid+3] 
		call 	print_char 
		inc     bx

		gotoXY  39, 6
		call 	adjust_grid_color    
		mov		al, [grid+4]
		call	print_char 
		inc     bx
		
		gotoXY  43, 6
		call 	adjust_grid_color
		mov		al, [grid+5] 
		call	print_char 
		inc     bx
		
		; terceira linha
		gotoXY  35, 8
		call 	adjust_grid_color            
		mov		al, [grid+6]
		call 	print_char 
		inc     bx

		gotoXY  39, 8
		call 	adjust_grid_color    
		mov		al, [grid+7]
		call 	print_char
		inc     bx
		
		gotoXY  43, 8
		call 	adjust_grid_color
		mov		al, [grid+8]
		call	print_char
			
	done:                 
		ret                                             

; 
; transforma a cor selecionada do menu
; em um atributo de cor e retorna em al
;1 (branco)  -> F, 2 (azul) -> 9, 3 (verde) ->, A (vermelho) - > C
color_to_attibute:
		cmp al, 1
		je  set_branco       
		cmp al, 2
		je  set_azul      
		cmp al, 3
		je  set_verde    
		cmp al, 4
		je  set_vermelho    
		jmp set_default    
	set_branco:
		mov al, 0fh
		ret    
	set_azul:
		mov al, 09h
		ret    
	set_verde:
		mov al, 0Ah
		ret
	set_vermelho:
		mov al, 0Ch
		ret
	set_default:    
		;qualquer selecção fora do range retorna a cor padrão
		mov al, GAME_TEXT_COLOR    
		ret

;
; checa se não há mais nenum espaço vazio no grid
; retona 1 ou 0 em al
check_grid_is_full:
		cmp [grid+0], 0
		je  check_grid_is_full_retun_false
		cmp [grid+1], 0
		je  check_grid_is_full_retun_false
		cmp [grid+2], 0
		je  check_grid_is_full_retun_false    
		cmp [grid+3], 0
		je  check_grid_is_full_retun_false    
		cmp [grid+4], 0
		je  check_grid_is_full_retun_false
		cmp [grid+5], 0
		je  check_grid_is_full_retun_false
		cmp [grid+6], 0
		je  check_grid_is_full_retun_false    
		cmp [grid+7], 0
		je  check_grid_is_full_retun_false        
		cmp [grid+8], 0
		je  check_grid_is_full_retun_false
						
	check_grid_is_full_retun_true:
		mov al, 1
		ret    

	check_grid_is_full_retun_false:
		mov al, 0
		ret    


;    
; checa se os valores em ch, cl e dh são iguais
; retorna um bool em al
chk_3:
	;primeiro checamos se são todos vazios
		cmp     ch, 0
		jne     chk_3_begin
		cmp     cl, 0
		jne     chk_3_begin
		cmp     dh, 0
		jne     chk_3_begin   
		jmp     chk_3_return_false  ; os 3 valores aão nulos
		
	chk_3_begin:    
		cmp     ch, cl
		jne     chk_3_return_false
				
		cmp     cl, dh
		je      chk_3_return_true
		
	chk_3_return_false:
		mov     al, 0
		ret

	chk_3_return_true:
		mov     al, 1
		ret
    
;
; Verifica o grid em todas as horizontais, vericais e diagonais
; retorna 1 em al se houve vencedor
;    
check_player_wins:
		cmp     [current_player], 1    
		je      set_curr_char_p1
		jmp     set_curr_char_p2    
		
	set_curr_char_p1:
		mov     al, [player_1+0]     ; 
		mov     [current_char], al    ; current_char =  player1 char
		jmp     check_grid

	set_curr_char_p2:
		mov     al, [player_2+0]     ; 
		mov     [current_char], al    ; current_char =  player2 char
	   
	check_grid:
	;horizontal_1:        
		mov     ch, [grid+0]
		mov     cl, [grid+1]
		mov     dh, [grid+2]    
		call    chk_3
		cmp     al, 1
		je      player_wins      
		
	;horizontal_2:
		mov     ch, [grid+3]
		mov     cl, [grid+4]
		mov     dh, [grid+5]    
		call    chk_3
		cmp     al, 1
		je      player_wins          
		
	;horizontal_3:
		mov     ch, [grid+6]
		mov     cl, [grid+7]
		mov     dh, [grid+8]    
		call    chk_3
		cmp     al, 1
		je      player_wins                

	;vertical_1:
		mov     ch, [grid+0]
		mov     cl, [grid+3]
		mov     dh, [grid+6]    
		call    chk_3
		cmp     al, 1
		je      player_wins                

	;vertical_2:
		mov     ch, [grid+1]
		mov     cl, [grid+4]
		mov     dh, [grid+7]    
		call    chk_3
		cmp     al, 1
		je      player_wins                
		
	;vertical_3:
		mov     ch, [grid+2]
		mov     cl, [grid+5]
		mov     dh, [grid+8]    
		call    chk_3
		cmp     al, 1
		je      player_wins                

	;diagonal_1:
		mov     ch, [grid+0]
		mov     cl, [grid+4]
		mov     dh, [grid+8]    
		call    chk_3
		cmp     al, 1
		je      player_wins                
		
	;diagonal_2:
		mov     ch, [grid+2]
		mov     cl, [grid+4]
		mov     dh, [grid+6]    
		call    chk_3
		cmp     al, 1
		je      player_wins                
		

	nobody_wins:
		mov     al, 0
		ret

	player_wins:
		mov     al, 1
		ret        
       

                    
;
; desenha a cena do jogo de acordo com o estado 
; em que ele se encontra
;             
proc draw_scene
    ; começamos imprimindo o cabeçalho do jogo      
    gotoXY   0, 0  
    print    str_game_divider, 80, GAME_TEXT_COLOR
    gotoXY   0, 1
    print    str_game_header, 80, GAME_TEXT_COLOR
    gotoXY   0, 2
    print    str_game_divider, 80, GAME_TEXT_SHADOW

; desenhamos direfentes telas dependendo o estado do game
; game state: 0 = menu, 1 = jogando, 2 = game over    
    cmp     [game_state], ST_MENU
    je      ds_menu
    cmp     [game_state], ST_JOGANDO
    je      ds_jogando
    cmp     [game_state], ST_VITORIA
    je      ds_game_vitoria
    jmp     ds_game_over      
    
ds_menu:        
    gotoXY   0, 3
    print    str_ftr_simbolos, 80, GAME_TEXT_SHADOW
    gotoXY   0, 4
    print    str_ftr_cores,    80, GAME_TEXT_SHADOW
    gotoXY   0, 5
    print    str_game_divider, 80, GAME_TEXT_COLOR
    
; get player 1 info
    gotoXY   0, 7
    print    str_player1_set_name, 80, GAME_TEXT_COLOR
    
    lea     di, [player_1+2]        ; joga o enderço do player 1 name buffer em di
    mov     dx, PLAYER_NAME_SIZE    ; player name buffer size 
    call    get_string              ; read string and override the buffer
    
    gotoXY  0, 8
    print   str_player_set_char, 0, GAME_TEXT_COLOR    
    call    select_player_symbol    ; sleciona um símbolo e salva em ALs 
    mov     [player_1+0], al        ; salva al no primeiro byte do player (simbolo)
    
    gotoXY  0, 9
    print   str_player_set_color, 0, GAME_TEXT_COLOR
    call    select_player_color     ; le a cor do tecaldo e joga em al
    call    color_to_attibute       ; converte a opção selecionada em um atributo de cor 
    mov     [player_1+1], al        ; salva al no segundo byte do player (cor)
                
    gotoXY  0, 10
    print   str_ok, 3, GAME_TEXT_SUCCESS

; get player 2 info
    gotoXY  0, 12                 
    print    str_player2_set_name, 80, GAME_TEXT_COLOR
    
    lea     di, [player_2+2]         ; joga o enderço do player 1 name buffer em di
    mov     dx, PLAYER_NAME_SIZE    ; player name buffer size 
    call    get_string              ; read string and override the buffer
    
    gotoXY  0, 13
    print    str_player_set_char, 0, GAME_TEXT_COLOR
    call    select_player_symbol 
    mov     [player_2+0], al         ; salva al no primeiro byte do player (simbolo)
    
    gotoXY  0, 14
    print   str_player_set_color, 0, GAME_TEXT_COLOR
    call    select_player_color     ; le a cor do tecaldo e joga em al
    call    color_to_attibute       ; converte a opção selecionada em um atributo de cor 
    mov     [player_2+1], al         ; salva al no segundo byte do player (cor)
    
    gotoXY  0, 15
    print   str_ok, 3, GAME_TEXT_SUCCESS    
    
    gotoXY  0, 17
    print   str_iniciando, 13, GAME_TEXT_SHADOW

    ;Finalmente, mudamos o estado do jogo e retornamos para o loop principal        
    mov     [game_state], ST_JOGANDO        
    mov     [current_player], 1h        ; o jogo iniciará com o jagador 1
    jmp     ds_return    


; Algorithm:
; 1. draw the grid
; 2. capture player move
; 3. check for winner
; 4. swap players
ds_jogando:                              
    call    draw_grid
    gotoXY  10, 10                                               ; posiciona o cursor do prompt
    cmp     [current_player], 1
    jne     dsj_player2
    
dsj_player1:                                                     ; imprime o prompt do jogador 1                           
    print_addr  player_1, 2, PLAYER_NAME_SIZE, GAME_TEXT_COLOR   ;
    print       str_type_position, 0, GAME_TEXT_COLOR            ;
    call        le_jogada   ;player_1                            ; le a jogada do jogar 1                          
    jmp         ds_game_check
    
dsj_player2:                                                     ; imprime o prompt do jogador 2
    print_addr  player_2, 2, PLAYER_NAME_SIZE, GAME_TEXT_COLOR   ;
    print       str_type_position, 0, GAME_TEXT_COLOR            ;
    call        le_jogada   ;player_2                            ; le a jogada do jogar 2           
    jmp         ds_game_check

; passo 3
ds_game_check:    
    call        check_player_wins     
    cmp         al, 1               ; houve uma vencedor?    
    je          _player_win
    call        check_grid_is_full
    cmp         al, 1
    je          _empate
    jmp         ds_swap_players     
    
    _player_win:
        mov     [game_state], ST_VITORIA
        jmp     ds_return
        
    _empate:        
        mov     [game_state], ST_GAME_OVER
        jmp     ds_return

; passo 4
ds_swap_players:     
    cmp         [current_player], 1
    je          set_curr_player_2
    
    set_curr_player_1:    
    mov         [current_player], 1
    jmp         ds_return        
     
    set_curr_player_2:
    mov         [current_player], 2  
    jmp         ds_return        


ds_game_vitoria:
;desenha a tela de vitória     
    call    draw_grid
    gotoXY  0, 10      
    print    str_game_divider, 80, GAME_TEXT_SUCCESS    
    gotoXY  0, 11
    print   str_vitoria, 200, GAME_TEXT_SUCCESS
    cmp     [current_player], 1
    gotoXY  0, 12
    jne     vit_player2

; imprime o nome do jogador 1    
vit_player1:                                                    
    print_addr  player_1, 2, PLAYER_NAME_SIZE, GAME_TEXT_SUCCESS   ;
    jmp     vit_player_continue

; imprime o nome do jogador 2    
vit_player2:            
    print_addr  player_2, 2, PLAYER_NAME_SIZE, GAME_TEXT_SUCCESS   ;

; imprime o sufixo (ganhou!)
vit_player_continue:    
    print   str_votoria_suf, 15, GAME_TEXT_SUCCESS       
    
    jmp     return_to_os


    
ds_game_over:
    call    draw_grid
    gotoXY  0, 10      
    print   str_game_divider, 80, GAME_TEXT_ERRO    
    gotoXY  0, 11
    print   str_game_over, 180, GAME_TEXT_ERRO
    jmp     return_to_os
    
ds_return:    
    ret
endp    
