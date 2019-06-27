/**
 * Mouse driver using for dos using INT 0x33
 */

#ifndef _MOUSE_H

#include <assert.h>

/* MOUSE EVENTS */
#define ME_CENTER_RELEASED          (0x40)
#define ME_CENTER_PRESSED           (0x20)
#define ME_RIGHT_RELEASED           (0x10)
#define ME_RIGHT_PRESSED            (0x08)
#define ME_LEFT_RELEASED            (0x02)
#define ME_LEFT_PRESSED             (0x01)

/* BUTTON STATE MASKS */
#define CENTER_BUTTON_MASK          (0x04)
#define RIGHT_BUTTON_MASK           (0x02)
#define LEFT_BUTTON_MASK            (0x01)

/* CONSTATNS */
#define MOUSE_INT                   (0X33)

/* MOUSE DRIVERS FUNCION CODES */

#define MFC_RESET_MOUSE             (0x0000)
#define MFC_SHOW_CURSOR             (0x0001)
#define MFC_HIDE_CURSOR             (0x0002)
#define MFC_POLL_STATUS             (0x0003)
#define MFC_SET_CURSOR_POSITION     (0x0004)
#define MFC_GET_BUTTON_PRESS_INFO   (0x0005)
#define MFC_GET_BUTTON_RELEASE_INFO (0x0006)
#define MFC_SET_X_LIMIT             (0x0007)
#define MFC_SET_Y_LIMIT             (0x0008)
#define MFC_SET_GRAPHICS_CURSOR     (0x0009)
#define MFC_SET_TEXT_CURSOR         (0x000A)
#define MFC_SET_EVENT_HANDLER       (0x000C)
#define MFC_SET_SENSITIVITY         (0x000F)
#define MFC_SET_PROTECTED_AREA      (0x0010)
#define MFC_SET_ACCEL_THRESHOLD     (0x0013)
#define MFC_GET_INFO                (0x0024)


/* PROTOTYPES  */

int reset_mouse(){}
void show_mouse_cursor(){}
void hide_mouse_cursor(){}
unsigned int poll_mouse_status(unsigned int* x, unsigned int *y){}
void set_mouse_position(unsigned int x, unsigned int y){}

unsigned int mouse_press_info(
    unsigned int button,
    unsigned int* counter,
    unsigned int* x,
    unsigned int* y
);

unsigned int mouse_release_info(
    unsigned int button,
    unsigned int* counter,
    unsigned int* x,
    unsigned int* y
);

void set_mouse_limit_x(unsigned int min, unsigned int max){}
void set_mouse_limit_y(unsigned int min, unsigned int max){}

void set_mouse_graphic_cursor(
    int hot_spot_x,
    int hot_spot_y,
    void far *  bmp){}


void set_mouse_text_cursor(unsigned int and_mask, unsigned int xor_mask){}
void set_mouse_event_handler(unsigned int event_mask, void far * handler){}
void set_mouse_sensitivity(unsigned int m_per_8x, unsigned int m_per_8y){}
void set_mouse_protected_area(
    unsigned int left,
    unsigned int top,
    unsigned int right,
    unsigned int bottom
){}

void set_mouse_accel_threshold(unsigned int mickyes_per_second){}

//unsigned short get_mouse_info(mouse_info *info){


#define ME_SUCCESS              0
#define ME_NO_DRIVER_FOUND      1

#define MOUSE_TYPE_BUS      (0x01)
#define MOUSE_TYPE_SERIAL   (0x02)    
#define MOUSE_TYPE_INPORT   (0x03)
#define MOUSE_TYPE_PS2      (0x04)
#define MOUSE_TYPE_HP       (0x05)

typedef struct {
    unsigned char type;
    unsigned char irq;
    unsigned char major_version;
    unsigned char minor_version;
} mouse_info;

/* IMPLEMENTATION */



/**
 * Returns info about the mouse driver in mouse_info pointer;
 * If function succeeded, returns ME_SUCCESS else, return 
 * ME_* error code.
 */
 int get_mouse_info( mouse_info *info ){
    int version;
    unsigned char type, irq, minor, major;        
    asm{
        mov ax, MFC_GET_INFO
        mov bx, 0xFFFF
        int MOUSE_INT        
        mov type, ch
        mov irq, cl
        mov major, bh
        mov minor, bl
        mov version, bx
    }    
    if(version == (int)0xFFFF)
        return ME_NO_DRIVER_FOUND;    
    info->type = type;
    info->irq = irq;
    info->major_version = major;
    info->minor_version = minor;
    return ME_SUCCESS;
}
    
#define _MOUSE_H
#endif
