#include <stdlib.h>
#include <stdio.h>
#include "inc/vga.h"
#include "inc/sys.h"


float profile(void (*func)(int), int count){
    float start = *RTC;
    func(count);
    return (*RTC - start)/RTC_FREQUENCY;
}

void draw_rects(int count){
    int i;
    for (i = 0; i < count; i++){
        draw_rect(
            rand() % SCREEN_WIDTH,
            rand() % SCREEN_HEIGHT,
            rand() % SCREEN_WIDTH,
            rand() % SCREEN_HEIGHT,
            rand() % NUM_COLORS
        );
    }
}

void fill_rects(int count){
    int i;
    for (i = 0; i < count; i++){
        draw_rect_fill(
            rand() % SCREEN_WIDTH,
            rand() % SCREEN_HEIGHT,
            rand() % SCREEN_WIDTH,
            rand() % SCREEN_HEIGHT,
            rand() % NUM_COLORS
        );
    }
}

int main(int argc, char **argv){
    int count = 5000;
    float time1, time2;

    if (argc > 1) count = atoi(argv[1]);    

    srand(*RTC);
    set_video_mode(MODE_GRAPHIC);
    
    time1 = profile(draw_rects, count);        
    time2 = profile(fill_rects, count);            

    set_video_mode(MODE_TEXT);

    printf("%d rects drawed in %.2f seconds.\n", count, time1);
    printf("%.2f rects per second.\n\n", count/time1);

    printf("%d rects filled in %.2f seconds.\n", count, time2);
    printf("%.2f rect fills per second.\n", count/time2);

    return 0;
}