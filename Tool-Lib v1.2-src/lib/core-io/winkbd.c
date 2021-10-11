/*
This Program or Software under MIT License, To know more please see License.txt File.
Author: MathInDOS
Date: 18 November 2020
Copyright (C) 2018-2020 MathInDOS
*/

#include <stdio.h>
#include <conio.h>

void tool_win_kbd(void)
{
	int winkbd = _getch();
	if((!winkbd) || (0xe0 == winkbd))
	{
		winkbd = _getch();
	    winkbd += 256;
	}
}

