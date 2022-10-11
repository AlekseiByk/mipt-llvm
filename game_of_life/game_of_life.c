#include <cassert>
#include "graphics.h"


#define X_SIZE 600
#define Y_SIZE 400

uint8_t buff[X_SIZE*Y_SIZE];
uint8_t tmp[X_SIZE*Y_SIZE];

void init_area();
void draw_area();
void calc_area();
void step_area();

int main() {
    win_init(X_SIZE, Y_SIZE);
    init_area();

    while(win_is_running()) 
    {
        win_is_closed();
        win_clear();
        
        draw_area();
        calc_area();
        step_area();
    }
    
}

void init_area() 
{
    for(size_t x = 0; x < X_SIZE; ++x)
        for(size_t y = 0; y < Y_SIZE; ++y)
            buff[x + y * X_SIZE] = state_rand();
}

size_t count_neighb(int x, int y) 
{
    size_t neighb = 0;
    for(int cur_x = x - 1; cur_x <= x + 1; ++cur_x) 
        for(int cur_y = y - 1; cur_y <= y + 1; ++cur_y) 
        {
            if((cur_x == x) && (cur_y == y)) 
                continue;

            if (cur_x < 0 || (size_t) cur_x >= X_SIZE ||
                cur_y < 0 || (size_t) cur_y >= Y_SIZE) 
                continue;
            
            uint8_t cur_state = buff[cur_y + cur_x * Y_SIZE];

            if (cur_state) 
            {
                ++neighb;
                neighb |= (cur_state << 4);
            }
        }
    return neighb;
}

uint8_t determine_state(int x, int y) 
{
    size_t neighb = count_neighb(x, y);
    if (buff[y + x * Y_SIZE] == DEAD)
    {
        if ((neighb & 0b1111) == 3) 
            return (neighb & 0b11110000) >> 4; 
    }
    else
    {
        if (((neighb & 0b1111) > 3) || ((neighb & 0b1111) < 2))
            return DEAD;
        else
            return (neighb & 0b11110000) >> 4;
    }
    return buff[y + x * Y_SIZE];
}

void calc_area() 
{
    for(size_t x = 0; x < X_SIZE; ++x) 
    {
        for(size_t y = 0; y < Y_SIZE; ++y) 
        {
            uint8_t state = determine_state(x, y);
            tmp[y + x * Y_SIZE] = state;
        }
    }
}



void draw_area() 
{
    for(size_t x = 0; x < X_SIZE; ++x)
        for(size_t y = 0; y < Y_SIZE; ++y)
            win_put_pixel(x, y, buff[y + x * Y_SIZE]);
    win_flush();
}

void step_area()
{
    for(size_t x = 0; x < X_SIZE; ++x)
        for(size_t y = 0; y < Y_SIZE; ++y)
            buff[y + x * Y_SIZE] = tmp[y + x * Y_SIZE];
}