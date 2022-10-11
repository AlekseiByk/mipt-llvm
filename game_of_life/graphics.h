#pragma once

#include <SFML/Graphics.hpp>
#include "stdint.h"
#include <vector>

sf::RenderWindow w;
sf::Event event;

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
void win_put_pixel(int x, int y, bool state);
void win_flush();
void win_clear();

void win_init(size_t horiz, size_t vertic) 
{
    srand(time(NULL));
    w.create(sf::VideoMode(horiz, vertic), "Game of Death");
}

bool win_is_running() 
{
    return  w.isOpen();
}

void win_is_closed() 
{
    while (w.pollEvent(event)) 
    {
        if (event.type == sf::Event::Closed)
            w.close();
    }
}

void win_put_pixel(int x, int y, uint8_t state) 
{
    sf::Color color = sf::Color::Black;
    switch (state) {
    case RED: 
        color = sf::Color::Red;
        break;
    case GREEN: 
        color = sf::Color::Green;
        break;
    case BLUE: 
        color = sf::Color::Blue;
        break;
    case R_GR: 
        color = sf::Color::Yellow;
        break;
    case R_BL: 
        color = sf::Color::Magenta;
        break;
    case GR_BL: 
        color = sf::Color::Cyan;
        break;
    case R_GR_BL: 
        color = sf::Color::White;
        break;
    default : 
        color = sf::Color::Black;
    }

    sf::Vertex vertex({(float) x, (float) y}, color);
    w.draw(&vertex, 1, sf::Points);
}

void win_flush() 
{
    w.display();
}

void win_clear() 
{
    w.clear(sf::Color::Black);
}

const int array[] = {0,1,0,2,0,4};
uint8_t state_rand()
{
    //return std::vector<int> {0,1,2,4}[rand() % 4];
    return array[rand() % 6];
}