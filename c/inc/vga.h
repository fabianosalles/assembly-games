/**
 * VGA GRAPHICS DRIVER FOR MODE 13h (320x200x256)
 * Author: Fabiano Salles
 * ------
 * This is meant to be compiled with Tubro C++ 3.0 and run under 
 * large memory model, so if compiling outise the ide, remember
 * to include -ml switch.
 */

#include <memory.h>

#define BIOS_INT_VIDEO      0x10      /* the BIOS video interrupt. */
#define BIOS_WRITE_PIXEL    0x0C      /* BIOS func to plot a pixel. */
#define BIOS_SET_VIDEO_MODE 0x00      /* BIOS func to set the video mode. */
#define MODE_GRAPHIC        0x13      /* use to set 256-color mode. */
#define MODE_TEXT           0x03      /* use to set 80x25 text mode. */

#define SCREEN_WIDTH        320       /* width in pixels of mode 0x13 */
#define SCREEN_HEIGHT       200       /* height in pixels of mode 0x13 */
#define NUM_COLORS          256       /* number of colors in mode 0x13 */


unsigned char *FRAME_BUFFER=(unsigned char *)0xA0000000L;  

void set_video_mode(unsigned char mode){
    asm{
        mov ah, BIOS_SET_VIDEO_MODE
        mov al, mode
        int BIOS_INT_VIDEO
    }  
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


void rect(int left, int top, int right, int bottom, unsigned char color){
    
}