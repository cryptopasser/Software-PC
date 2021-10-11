/*
This Program or Software under MIT License, To know more please see License.txt File.
Author: MathInDOS
Date: 18 November 2020
Copyright (C) 2018-2020 MathInDOS
*/


#ifndef H_WINMOUSE
#define H_WINMOUSE

#ifndef ENABLE_PROCESSED_INPUT
#define ENABLE_PROCESSED_INPUT 0x0001
#endif

#ifndef ENABLE_MOUSE_INPUT
#define ENABLE_MOUSE_INPUT 0x0010
#endif

#define MOUSE_INPUT 0x0000
#define MOUSE_AUTO_INPUT 0x0001


// This mouse-enum is taken from DarkBox.
// Copyright (C) 2016 Teddy ASTIE (TSnake41)

// Start

enum {
	NONE = 0,
    LEFT_BUTTON,
    RIGHT_BUTTON,
    D_LEFT_BUTTON,
    D_RIGHT_BUTTON,
    MIDDLE_BUTTON,
    SCROLL_UP,
    SCROLL_DOWN,
    RELEASE
};

// End


void tool_mouse(char move, int *x, int *y, int *c);

#endif

