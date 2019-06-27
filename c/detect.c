#include <stdio.h>
#include "inc/vga.h";

int main(void){
    if (DetectVGA() == 1)
        printf("The graphics card is a VGA. Cool!!!\n");
    else
        printf("The graphics card is not a VGA. Sorry.\n");
   return 0; 
}