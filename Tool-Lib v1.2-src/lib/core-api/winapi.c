#include <stdio.h>
#include <stdlib.h>
#include <windows.h>

static origin_x, origin_y;

void tool_gotoxy(int x, int y)
{
	HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
	
	if(x < 0 || y < 0) exit(1);
	COORD Pos;
	Pos.X = origin_x + x;
	Pos.Y = origin_y + y;
	SetConsoleCursorPosition(hOut, Pos);
	CloseHandle(hOut);
}

void tool_cursor_state(int state)
{
	HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
	CONSOLE_CURSOR_INFO cci;
	GetConsoleCursorInfo(hOut, &cci);
	// int var = (int)strtol(state, NULL, 10);
	switch(state)
	{
		case 0:
		cci.bVisible = TRUE;
		break;
		case 1:
		cci.bVisible = FALSE;
		break;
	}
	SetConsoleCursorInfo(hOut, &cci);
	CloseHandle(hOut);
}

void tool_clear_screen(void)
{
	HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
	DWORD dw;
	COORD crd;
	crd.X = 0;
	crd.Y = 0;
	
	FillConsoleOutputCharacterW(hOut, ' ', dw, crd, &dw);
	tool_gotoxy(0,0);
	CloseHandle(hOut);
}

void tool_change_color(char*color)
{
	HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
	int code = (int)strtol(color, NULL, 16);
	char bg = code / 16;
	char fg = code % 16;
	SetConsoleTextAttribute(hOut, fg | bg<<4);
	CloseHandle(hOut);
}

void tool_default_color(void)
{
	HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
	SetConsoleTextAttribute(hOut, DEFAULT_CMD_COLOR);
}

void tool_cursor_size(int size)
{
	 HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
	 CONSOLE_CURSOR_INFO cci;
	 if(size < 0 || size > 100) exit(1);
	 if(size==0) exit(1);
	 cci.dwSize = size;
	 SetConsoleCursorInfo(hOut, &cci);
	 CloseHandle(hOut);
}

void tool_get_time(void)
{
	SYSTEMTIME st;
	GetLocalTime(&st);
	printf("%d %d %d %d %d %d\n", (int) st.wDayOfWeek, (int)st.wYear, (int)st.wMonth, (int)st.wHour, (int)st.wMinute, (int)st.wSecond);
}

void tool_millisleep(int sleep)
{
	Sleep(sleep);
}

void tool_secondsleep(int sleep)
{
	Sleep(sleep * 1000);
}

void tool_buffer_size(int x, int y)
{
	HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
	COORD Pos;
	Pos.X = x;
	Pos.Y = y;
	SetConsoleScreenBufferSize(hOut, Pos);
	CloseHandle(hOut);
}

void tool_flush_console(void)
{
	HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
	FlushConsoleInputBuffer(hOut);
}




