#ifndef H_WINAPI
#define H_WINAPI

#define DEFAULT_CMD_COLOR  0x0007

void tool_gotoxy(int x, int y);
void tool_cursor_state(int state);
void tool_clear_screen(void);
void tool_change_color(char*color);
void tool_default_color(void);
void tool_default_color(void);
void tool_cursor_size(int size);
void tool_get_time(void);
void tool_millisleep(int sleep);
void tool_secondsleep(int sleep);
void tool_buffer_size(int x, int y);
void tool_flush_console(void);

#endif

