#include "io.h"

#define DIM 1024
#define DM1 (DIM-1)
#define _sq(x) ((x)*(x))
#define _cb(x) abs((x)*(x)*(x))
#define putchar(x) outb(x)
 
unsigned char GR(int,int);
unsigned char BL(int,int);

unsigned char RD(int i,int j){
    float s=3./(j+99);
    return ((int)((i+DIM)*s+j*s)%2+(int)((DIM*2-i)*s+j*s)%2)*127;
}
unsigned char GR(int i,int j){
    float s=3./(j+99);
    return ((int)((i+DIM)*s+j*s)%2+(int)((DIM*2-i)*s+j*s)%2)*127;
}
unsigned char BL(int i,int j){
    float s=3./(j+99);
    return ((int)((i+DIM)*s+j*s)%2+(int)((DIM*2-i)*s+j*s)%2)*127;
}

void pixel_write(int,int);

int main(){
    print("P6\n1024 1024\n255\n");
    for(int j=0;j<DIM;j++)
        for(int i=0;i<DIM;i++)
            pixel_write(i,j);
    return 0;
}
void pixel_write(int i, int j){
    static unsigned char color[3];
    color[0] = RD(i,j)&255;
    color[1] = GR(i,j)&255;
    color[2] = BL(i,j)&255;
    for (int k = 0; k < 3; ++k)
      putchar(color[k]);
    sleep(5);
}
