#include <stdio.h>
#include <stdlib.h>
#include <dos.h>
#include "inc/sys.h"
#include "inc/vga.h"


void draw_random_lines(int count){
	int i, x0, y0, x1, y1;
	unsigned char color;	
	for(i=0; i< count; i++){
		x0 = rand() % SCREEN_WIDTH;
		x1 = rand() % SCREEN_WIDTH;
		y0 = rand() % SCREEN_HEIGHT;
		y1 = rand() % SCREEN_HEIGHT;
		color = rand() %NUM_COLORS;
		draw_line(x0, y0, x1, y1, color);
	}
}

float profile(int count, void( *func)(int)){
	float start = *RTC;
	func(count);
	return (*RTC-start)/RTC_FREQUENCY;
}

int main(void){
	int i;
	float time = 0.0;
	const COUNT = 5 * 1000;
	srand(*RTC);

	set_mode_13h(MODE_GRAPHIC);	
	time = profile(COUNT, draw_random_lines);	
	set_mode_text(MODE_TEXT);	
	
	printf("%d lines drawed in %.2f seconds using Bresenhan algorithm\n", COUNT, time);
	printf("performance: %2.f lines per second.\n", (float)(COUNT)/time);

	return 0;
}