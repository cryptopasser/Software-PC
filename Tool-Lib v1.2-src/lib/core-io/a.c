/*
This Program or Software under MIT License, To know more please see License.txt File.
Author: MathInDOS
Date: 18 November 2020
Copyright (C) 2018-2020 MathInDOS
*/

#include "winconfig.h"

int main(int argc, char *argv[])
{
	int x, y, c;
	tool_mouse(MOUSE_INPUT, &x, &y, &c);
	goto show;
	
	show:
	printf("%d %d %d", x, y, c);
	return 0;
}
