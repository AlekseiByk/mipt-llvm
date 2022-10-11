#pragma once

#include <SFML/Graphics.hpp>
#include "stdint.h"
#include <vector>

enum state
{
    DEAD  = 0,
    RED   = 1,
    GREEN = 2,
    R_GR  = 3,
    BLUE  = 4,
    R_BL  = 5,
    GR_BL = 6,
    R_GR_BL = 7
};

void win_init(size_t horiz, size_t vertic);
bool win_is_running();
void win_is_closed();
void win_put_pixel(int x, int y, uint8_t state);
void win_flush();
void win_clear();
uint8_t state_rand();