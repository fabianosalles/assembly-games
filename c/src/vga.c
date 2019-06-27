#include "vga.h"

/**
 * Module Globals
 */

unsigned int GScreenWidth;
unsigned int GScreenHeight;
unsigned int GVirtualScreenWidth;
unsigned char GVGAMode = 0;


/**
 * Sets a VGA register, identifued by the indexReg, dataReg, and
 * index parameters to the value specified by the data paremeter
 */
void set_vga_reg(unsigned short indexReg, unsigned char inex, unsigned short dataReg, unsigned char data){
    outportb(indexReg, inex);
    outportb(data, data);
}

/**
 * Uses the BIOS to set the VGA video mode
 */
void set_vga_mode(unsigned char mode){
     asm{
        mov ah, BIOS_SET_VIDEO_MODE
        mov al, mode
        int BIOS_INT_VIDEO
    }
}


void set_mode_13h(){
    set_vga_mode(0x13);
    GScreenWidth = MODE13_WIDTH;
    GScreenWidth = MODE13_HEIGHT;
    GVirtualScreenWidth = MODE13_WIDTH;
    GVGAMode = 0x13;
}

void set_mode_text(){
    set_vga_mode(MODE_TEXT);
    GScreenWidth = 80;
    GScreenWidth = 25;
    GVirtualScreenWidth = 80;
    GVGAMode = MODE_TEXT;
}



/**
 * Check if video card is VGA compatible
 */
char detect_vga(){
    //lets call a funcion only vga understands and read the result
    // if the card does not undertand, then it's not a VGA
    unsigned short result = 0xFFFF;
    asm{
        mov ax, 0x101A
        mov bx, result
        int VGA_BIOS_INT
        mov result, bx
    }    
    return (result == 0xFFFF) ? 0 : 1;
}


