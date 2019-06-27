/**
 * Get mouse info.
 */

#include <stdio.h>
#include "inc/mouse.h"

int main(void){

    mouse_info i;
    switch (get_mouse_info(&i)){
    case ME_SUCCESS:
        printf("Mouse detected!\n");
        printf("\tTYPE:\t");
        switch(i.type){
            case MOUSE_TYPE_BUS: printf("bus mouse\n"); break;
            case MOUSE_TYPE_HP : printf("mouse HP\n"); break;
            case MOUSE_TYPE_INPORT: printf("InPort mouse\n"); break;
            case MOUSE_TYPE_PS2: printf("PS2 mouse\n"); break;
            case MOUSE_TYPE_SERIAL: printf("resial mouse\n"); break;
        }
        printf("\tIRQ:\t%d\n", i.irq);
        printf("\tDRIVER:\t%d.%d\n", i.major_version, i.minor_version);            
        break;
    
    case ME_NO_DRIVER_FOUND:
        printf("No mouse driver found.\n");
        break;

    }

}