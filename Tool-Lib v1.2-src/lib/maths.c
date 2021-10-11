/*
This Program or Software under MIT License, To know more please see License.txt File.
Author: MathInDOS
Date: 18 November 2020
Copyright (C) 2018-2020 MathInDOS
*/

#include <stdio.h>
#include <stdlib.h>
#include <time.h>


int tool_fib(int n)
{
	if(n <= 2) exit(1);
	return tool_fib(n-1) + tool_fib(n-2);
}

void tool_square(int nums)
{
	if(nums==NULL) exit(1);
	printf("%d", nums*nums);
}

void tool_cube(int numc)
{
	if(numc==NULL) exit(1);
	printf("%d", numc*numc*numc);
}

void tool_isgrater(int x, int y)
{
	if(x > y) printf("TRUE");
	if(x < y) printf("FALSE");
	if(x == y) printf("EQUAL");
}

void tool_islower(int x, int y)
{
	if(x < y) printf("TRUE");
	if(x >	y) printf("FALSE");
	if(x == y) printf("EQUAL");
}

void tool_isequal(int x, int y)
{
	if(x == y) printf("EQUAL");
	if(x != y) printf("NOTEQUAL");
}

void tool_msiny(int x)
{
	x += x*2;
	printf("%d",x);
	
}

void tool_rnd(int maxrnd)
{
	srand((unsigned)time(NULL));
	int i = rand() % maxrnd;
	printf("%d", i);
}

void tool_chk_num(int num)
{
	if(num==NULL) exit(1);
switch(num) { case 0: printf("NOTHING!"); break; case 1: printf("1"); break; case 2: printf("0"); break; case 3: printf("1"); break;
case 4: printf("0"); break; case 5: printf("1"); break; case 6: printf("0"); break; case 7:printf("1"); break; case 8: printf("0"); break;
case 9: printf("1"); break; default: exit(1);}

}

void tool_hex_to_dec(const char *num)
{
	int g_dec = (int)strtol(num, NULL, 16);
	char dec1 = g_dec / 16;
	char dec2 = g_dec % 16;
	printf("%d", dec2 | dec1 << 4);
}




