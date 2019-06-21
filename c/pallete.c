/**
 * Defautl VGA Pallete
 * Autor: Fabiano Salles
 */

#include <dos.h>
#include "inc/vga.h"

void draw_pallete(){
    int x, y;
    const int OFFSET = 16;
    for (x=0; x < NUM_COLORS; x++){
        for (y= OFFSET; y < SCREEN_HEIGHT; y++){
            put_pixel_fast(x, y, (unsigned char)x);
        }
    }
}

int main(void){
    
    set_video_mode(MODE_GRAPHIC);

    draw_pallete();
    while (!kbhit()){
        delay(10);
    }
    

    set_video_mode(MODE_TEXT);
    return 0;
}