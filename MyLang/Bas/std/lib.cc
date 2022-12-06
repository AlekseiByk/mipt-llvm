#include <SFML/Graphics.hpp>
#include <iostream>
#include <limits.h>
#include <stdlib.h>
#include "lib.hh"

sf::RenderWindow window;
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

const int array[] = {0,1,0,2,0,4};

extern "C" {

int __win_rand() {
    return array[rand() % 6];
}

void __win_init_window(unsigned width, unsigned height) {
    window.create(sf::VideoMode(width, height), "Game of Life");
}

void __win_put_pixel(int x, int y, int state) {

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

    sf::Vertex point({static_cast<float>(x), static_cast<float>(y)}, color);
    window.draw(&point, 1, sf::Points);
}

void __win_flush() {
    while (window.pollEvent(event)) {
        if (event.type == sf::Event::Closed)
            window.close();
    }
    window.display();
}

void __win_print(int n) { std::cout << n << std::endl; }

int __win_scan() {
    int n;
    std::cin >> n;
    if (!std::cin) {
        std::cerr << "Problem reading stdin\n"; 
        exit(1);
    }
    return n;
}

}