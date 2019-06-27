#include <stdio.h>
#include <stdlib.h>
#include <dos.h>
#include "inc/vga.h"


unsigned short *low_res_clock=(unsigned short *)0x0000046C; 


void plot_pixel_bios(int x,int y, unsigned char color){
    union REGS regs;
    regs.h.ah = BIOS_WRITE_PIXEL;
    regs.h.al = color;
    regs.x.cx = x;
    regs.x.dx = y;
    int86(BIOS_INT_VIDEO, &regs, &regs);
}

void plot_pixel_bios_asm(int x, int y, unsigned char color){
    asm{
        mov ah, BIOS_WRITE_PIXEL
        mov al, color
        mov cx, x
        mov dx, y
        int BIOS_INT_VIDEO
    }
}




float profile(
        void (*test_func)(long count, void(*plot_func)(int x,int y, unsigned char color)),
        unsigned int count,
        void(*plot_func)(int x,int y, unsigned char color)){
    float start;    
    start = *low_res_clock;
    test_func(count, plot_func);    
    return (*low_res_clock - start) / 18.2;
}


void random_pixels(long count, void(*plot_func)(int x,int y, unsigned char color)){
    int x, y;
    unsigned long i;
    unsigned char color;

    for( i=0; i < count; i++ ) {
        x = rand()%SCREEN_WIDTH;
        y = rand()%SCREEN_HEIGHT;
        color = rand()%NUM_COLORS;
        if (plot_func == NULL)
            FRAME_BUFFER[ (y<<8) + (y<<6) + x] = color;
        else
            plot_func(x, y, color);
    }
}


int main(void){
    const long PXCOUNT = 60*1000;
    float function_speed[4];
    srand(*low_res_clock);
    set_video_mode(MODE_GRAPHIC);
    

    function_speed[0] = profile(random_pixels, PXCOUNT, plot_pixel_bios);
    function_speed[1] = profile(random_pixels, PXCOUNT, plot_pixel_bios_asm);
    function_speed[2] = profile(random_pixels, PXCOUNT, put_pixel_fast);
    function_speed[3] = profile(random_pixels, PXCOUNT, NULL);

    set_video_mode(MODE_TEXT);
    printf("plot_pixel_bios         %f seconds\n", function_speed[0]);
    printf("plot_pixel_bios_asm     %f seconds\n", function_speed[1]);
    printf("plot_pixel_fast         %f seconds\n", function_speed[2]);
    printf("plot_pixel_fast_inline  %f seconds\n", function_speed[3]);
    
   
    return 0;
}
