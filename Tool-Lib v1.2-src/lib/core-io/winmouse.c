/*
This Program or Software under MIT License, To know more please see License.txt File.
Author: MathInDOS
Date: 18 November 2020
Copyright (C) 2018-2020 MathInDOS
*/

#include <stdio.h>
#include <windows.h>
#include "winmouse.h"

void tool_mouse(char move, int *x, int *y, int *c)
{
	HANDLE console = GetStdHandle(STD_INPUT_HANDLE);
	DWORD e;
	SetConsoleMode(console, ENABLE_PROCESSED_INPUT | ENABLE_MOUSE_INPUT);

	INPUT_RECORD ir;

	*c = NONE;

	do {
		do
			ReadConsoleInput(console, &ir, 1, &e);
		while (ir.EventType != MOUSE_EVENT);

		COORD mouse_pos = ir.Event.MouseEvent.dwMousePosition;
		*x = mouse_pos.X;
		*y = mouse_pos.Y;

		DWORD m_bs = ir.Event.MouseEvent.dwButtonState;
		DWORD m_ef = ir.Event.MouseEvent.dwEventFlags;

		if (m_bs & FROM_LEFT_1ST_BUTTON_PRESSED)
			*c = (m_ef & DOUBLE_CLICK) ? D_LEFT_BUTTON : LEFT_BUTTON;
		
		else if(m_bs & RIGHTMOST_BUTTON_PRESSED)
			*c = (m_ef & DOUBLE_CLICK) ? D_RIGHT_BUTTON : RIGHT_BUTTON;

		else {
			*c = NONE;
			if (move)
				break;
		}

	} while (*c == NONE);
}


	