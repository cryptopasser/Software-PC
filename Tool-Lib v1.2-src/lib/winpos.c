/*
This Program or Software under MIT License, To know more please see License.txt File.
Author: MathInDOS
Date: 18 November 2020
Copyright (C) 2018-2020 MathInDOS
*/

#include <stdio.h>
#include <stdlib.h>
#include <windows.h>
#include "winpos.h"

WINBASEAPI HWND WINAPI GetConsoleWindow(void);

void tool_window_pos(int x, int y)
{
	RECT bounds;
	HWND hWnd = GetConsoleWindow();
	if (!hWnd) exit(1);
	GetWindowRect(hWnd, &bounds);		
	SetWindowPos(hWnd, HWND_TOP, x, y, bounds.right-bounds.left, bounds.bottom-bounds.top, 0);
}

void tool_get_title(void)
{
    char title[MAX_LENGTH];		
	GetConsoleTitle(title, MAX_LENGTH - 1);
	printf("%s\n", title);
}

	
		