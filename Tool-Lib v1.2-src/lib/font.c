/*
This Program or Software under MIT License, To know more please see License.txt File.
Author: MathInDOS
Date: 18 November 2020
Copyright (C) 2018-2020 MathInDOS
*/

#include <stdlib.h>
#include <windows.h>
#include "font.h"
WINBASEAPI WINBOOL WINAPI SetConsoleFont(HANDLE Console, DWORD nSize);

void tool_font(int size)
{
	HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
	SetConsoleFont(hOut, size);
	CloseHandle(hOut);
}
