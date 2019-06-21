/**
 * PONG FOR DOS
 * Author: Fabiano Salles
 * ------
 * This is meant to be compiled with Tubro C++ 3.0 and run under 
 * large memory model, so if compiling outise the ide, remember
 * to include -ml switch.
 */

#include <stdio.h>
#include "inc/vga.h"
																																			

int main(void){
	printf("Initializing video mode.\n");

	set_video_mode(MODE_GRAPHIC);



	set_video_mode(MODE_TEXT);
	printf("Bye.\n");

  return 0;
}																																																																										
