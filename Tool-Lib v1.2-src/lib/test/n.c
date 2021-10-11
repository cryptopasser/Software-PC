/*
This Program or Software under MIT License, To know more please see License.txt File.
Author: MathInDOS
Date: 18 November 2020
Copyright (C) 2018-2020 MathInDOS
*/


#include "winpos.c"
#include <conio.h>
#include <shellapi.h>
#include <stdio.h>

// WINBASEAPI HWND WINAPI GetConsoleWindow(VOID);
int main(int argc, char *arg[])
{
	tool_window_pos(atol(arg[1]),atol(arg[2]));
	tool_get_title();
	return 0;
}

