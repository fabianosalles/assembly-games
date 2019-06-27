/**
 * VGA GRAPHICS DRIVER FOR MODE 13h (320x200x256) and MODE X (320x240x256)
 * Author: Fabiano Salles
 * Based on Dave Roberts's PC Game Programming and the VGA tutorial at
 * www.brackeen.com/vga
 * ------
 * This is meant to be compiled with Tubro C++ 3.0 and run under 
 * large memory model, so if compiling outise the ide, remember
 * to include -ml switch.
 */

#ifndef _VGA_
#define _VGA_

#include <memory.h>

#define VGA_BIOS_INT        (0x10)      /* the BIOS video interrupt. */
#define BIOS_INT_VIDEO      (0x10)      /* the BIOS video interrupt. */
#define BIOS_WRITE_PIXEL    (0x0C)      /* BIOS func to plot a pixel. */
#define BIOS_SET_VIDEO_MODE (0x00)      /* BIOS func to set the video mode. */
#define MODE_GRAPHIC        (0x13)      /* use to set 256-color mode. */
#define MODE_TEXT           (0x03)      /* use to set 80x25 text mode. */

#define SCREEN_WIDTH        (320)       /* width in pixels of mode 0x13 */
#define SCREEN_HEIGHT       (200)       /* height in pixels of mode 0x13 */
#define NUM_COLORS          (256)       /* number of colors in mode 0x13 */

#define MODE13_WIDTH        (320)
#define MODE13_HEIGHT       (200)

#define MODEX_WIDTH         (320)
#define MODEX_HEIGHT        (240)

#define MODEY_WIDTH         (320)
#define MODEY_HIGHT         (200)


/* VGA GENERAL REGISTERS */
#define MISC_OUTPUT_REG             (0x3C2) /* write port for misc. output vga register */
#define MISC_OUTPUT_REG_READ        (0x3CC) /* read port for misc output vga register */

#define FEATURE_CONTROL_REG         (0x3DA) /* write port for vga feature control register */
#define FEATURE_CONTROL_REG_READ    (0x3CA) /* read port for vga feature vgacontrol register */

#define INPUT_STAT_0_REG            (0x3C2) /* input status for register #0 */
#define INPUT_STAT_1_REG            (0x3DA) /* input status for register #1 */


/* Sequencer registers */

#define SEQ_INDEX_REG               (0x3C4) /* sequencer index register */
#define SEQ_DATA_REG                (0x3C5) /* sequencer data register */

#define RESET_INDEX                 (0)
#define CLOCKING_MODE_INDEX         (1)
#define MAP_MASK_INDEX              (2)
#define CHARACTER_MAP_SELECT_INDEX  (3)
#define MEMORY_MODE_INDEX           (4)


/* CRTC registers */

#define CRTC_INDEX_REG              (0x3D4) 
#define CRTC_DATA_REG               (0x3D5)

#define HORIZ_TOTAL_INDEX           (0x00)
#define RORIZ_DISPLAY_END_INDEX     (0x01)
#define START_HORIZ_BLANK_INDEX     (0x02)
#define END_HORIZ_BLANK_INDEX       (0x03)
#define START_HORIZ_RETRACE         (0x04)
#define END_HORIZ_RETRACE           (0x05)
#define VERT_TOTAL_INDEX            (0x06)
#define OVERFLOW_INDEX              (0x07)
#define PRESET_ROW_SCAN_INDEX       (0x08)
#define MAX_SCANLINE_INDEX          (0x09)
#define CURSOR_START_INDEX          (0x0A)
#define CURSOR_END_INDEX            (0x0B)
#define START_ADDRESS_HIGH_INDEX    (0x0C)
#define START_ADDRESS_LOW_INDEX     (0x0D)
#define CURSOR_LOCATION_HIGH_INDEX  (0x0E)
#define CURSOR_LOCATION_LOW_INDEX   (0x0F)
#define VERT_RETRACE_START_INDEX    (0x10)
#define VERT_RETRACE_END_INDEX      (0x11)
#define VERT_DISPLAY_END_INDEX      (0x12)
#define OFFSET_INDEX                (0x13)
#define UNDERLINE_LOCATION_INDEX    (0x14)
#define START_VERT_BLANK_INDEX      (0x15)
#define END_VERT_BLANK_INDEX        (0x16)
#define MODE_CONTROL_INDEX          (0x17)
#define LINE_COMPARE_INDEX          (0x18)


/* Gaphics Control Registers */

#define GC_INDEX_REG              (0x3CE) /* Graphics Control Index Register */
#define GC_DATA_REG                 (0x3CF) /* Graphics Control Data Register */

#define SET_RESET_INDEX             (0)
#define SET_RESET_ENABLE_INDEX      (1)
#define COLOR_COMPARE_INDEX         (2)
#define DATA_ROTATE_INDEX           (3)
#define READ_MAP_SELECT_INDEX       (4)
#define MODE_INDEX                  (5)
#define MISC_INDEX                  (6)
#define COLOR_DONT_CARE_INDEX       (7)
#define BIT_MASK_INDEX              (8)

/* Color Registers */
#define COLOR_ADDRESS_WRITE         (0x3C8)
#define COLOR_ADDRESS_READ          (0x3C7)
#define COLOR_DATA                  (0x3C9)

/* Macros for setting frequently used VGA registers directly */

/**
 * Set bitmask register
 */
#define SetBMR(val) outport(GC_INDEX_REG, BIT_MASK_INDEX | (val << 8))

/**
 * Set reset register
 */
#define SetSRR(val) outport(GC_INDEX_REG, SET_RESET_INDEX | (val << 8))

/**
 * Set reset enable register
 */
#define SetSRER(val) outport(GC_INDEX_REG, SET_RESET_ENABLE_INDEX | (val << 8))

/**
 * Set map mask register
 */
#define SetMMR(val) outport(GC_INDEX_REG, MAP_MASK_INDEX | (val << 8))



/* funcion prototypes */

unsigned char *FRAME_BUFFER=(unsigned char *)0xA0000000L;  


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
    outportb(dataReg, data);
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


/**
 * Plot pixel using bios services.
 * Slow, but secure
 */
void put_pixel(int x, int y, unsigned char color){
    asm{
        mov ah, BIOS_WRITE_PIXEL
        mov al, color
        mov cx, x
        mov dx, y
        int BIOS_INT_VIDEO
    }
}

/**
 * Plot pixel to frame buffer.
 * Fast, but do not make any buffer overflow checking
 */
void put_pixel_fast(int x, int y, unsigned char color){
    FRAME_BUFFER[ (y<<8) + (y<<6) + x ] = color;
}

/**
 * Get pixel color from frame buffer
 */
unsigned char get_pixel(int x, int y){
    return FRAME_BUFFER[ (y<<8) + (y<<6) + x ];
}


/**
 * Draws a line using Bresenhan algorithm
 */
void draw_line(int x0, int y0, int x1, int y1, unsigned char color) {
    int dx, dy;
    int sx, sy;
    int err, e2;

    dx = x1-x0; if (dx < 0) dx =-dx;
    dy = y1-y0; if (dy < 0) dy =-dy;

    sx = x0 < x1 ? 1 : -1;
    sy = y0 < y1 ? 1 : -1;

    err = (dx > dy ? dx : -dy)/2;
    while(1){
        FRAME_BUFFER[ (y0<<8) + (y0<<6) + x0 ] = color;
        if (x0==x1 && y0==y1) 
            break;
        e2 = err;
        if (e2 >-dx) { err -= dy; x0 += sx; }
        if (e2 < dy) { err += dx; y0 += sy; }        
    }
    return;
}

void clear_screen(unsigned char color){
    memset(FRAME_BUFFER, color, SCREEN_WIDTH * SCREEN_HEIGHT);
}

/* Draws a polygon of vertex_count vertrexes */
void draw_polygon(int vertex_count, int *vertex_buffer, unsigned char color){
    int i, k;
    for (i=0; i < vertex_count-1; i++){
        k = i << 1; // k=2*i
        draw_line(
            vertex_buffer[k + 0],
            vertex_buffer[k + 1],
            vertex_buffer[k + 2],
            vertex_buffer[k + 3],
            color);        
    } 
    k = vertex_count << 1;
    draw_line(                
        vertex_buffer[k - 2],
        vertex_buffer[k - 1],        
        vertex_buffer[0],
        vertex_buffer[1],
        color);
}


/* Draws a simple rectangle with no fill */
void draw_rect(int left, int top, int right, int bottom, unsigned char color){
    unsigned short top_offset, bottom_offset, i , temp;

    if (top>bottom) {
        temp = top;
        top = bottom;
        bottom=temp;
    }

    if (left>right){
        temp = left;
        left = right;
        right = temp;
    }

    top_offset = (top<<8)+(top<<6);  
    bottom_offset = (bottom<<8)+(bottom<<6);
    for(i=left; i<=right; i++){
        FRAME_BUFFER[top_offset+i]    = color;
        FRAME_BUFFER[bottom_offset+i] = color;
    }
    for(i=top_offset;i<=bottom_offset;i+=SCREEN_WIDTH){
        FRAME_BUFFER[left+i]=color;
        FRAME_BUFFER[right+i]=color;
    }
}

/* Draws a fille rectangle */
void draw_rect_fill(int left, int top, int right, int bottom, unsigned char color){
    unsigned short top_offset, bottom_offset, i, temp,width;

    if (top>bottom){
        temp=top;
        top=bottom;
        bottom=temp;
    }
    if (left>right){
        temp=left;
        left=right;
        right=temp;
    }

    top_offset = (top<<8)+(top<<6) + left;
    bottom_offset= (bottom<<8)+(bottom<<6) + left;
    width = right-left+1;

    for(i=top_offset;i<=bottom_offset;i+=SCREEN_WIDTH)  
        memset(&FRAME_BUFFER[i],color,width);
}

#endif  /* _VGA_ */