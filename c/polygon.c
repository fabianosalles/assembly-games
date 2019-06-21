/**
 * Random Polygon Demo on mode 13h custom driver
 * Autor: Fabiano Salles
 */
#include <stdlib.h>
#include <stdio.h>
#include <dos.h>
#include "inc/sys.h"
#include "inc/vga.h"

void draw_triangle(){
    int num_vertices = 3;
    int vertices[6] = { 
        160, 10,        
        310, 190,
        10, 190
    };
    draw_polygon(num_vertices, vertices, 15);    
}

void draw_random_polys(int count){
    int const MAX_VERTEXES = 5;    
    int i, j, k;
    unsigned char color;
    int vertex_buffer[16] = { 0 };

    for (i=0; i< count; i++){
        k = (rand() % (MAX_VERTEXES -3)) + 3;        
        for (j=0; j < k*2; j+=2){
            vertex_buffer[j+0] = rand() % SCREEN_WIDTH;  //x
            vertex_buffer[j+1] = rand() % SCREEN_HEIGHT; //y
        }
        color = rand() % NUM_COLORS;
        draw_polygon(k, vertex_buffer, color);
    }
}

float profile(int count, void( *func)(int)){
    float start = *RTC;
    func(count);    
    return (*RTC - start)/RTC_FREQUENCY;
}

int main(void){
    int i;
    float time=0.0;
    const COUNT = 5 * 1000;
    srand(*RTC);
    set_video_mode(MODE_GRAPHIC);
    clear_screen(rand() % NUM_COLORS);

    time = profile(COUNT, draw_random_polys);

    set_video_mode(MODE_TEXT);

    printf("%d random polygons in %.2f seconds.\n", COUNT, time);
    printf("%.2f polygons per second.\n", (float)COUNT/time);

    return 0;
}
