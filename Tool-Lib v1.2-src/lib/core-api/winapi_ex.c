#include <windows.h>
#include "winapi_ex.h"

void tool_quickedit_mode(int mode)
{
	DWORD dwMode;
	HANDLE hOut = GetStdHandle(STD_INPUT_HANDLE);
	GetConsoleMode(hOut, &dwMode);
	dwMode = dwMode | ENABLE_EXTENDED_FLAGS | ENABLE_MOUSE_INPUT;
	
	if(mode==0)
		dwMode = dwMode & ~ENABLE_QUICKEDIT_MODE;
	else
		dwMode = dwMode | ENABLE_QUICKEDIT_MODE;
	SetConsoleMode(hOut, dwMode);
}



	