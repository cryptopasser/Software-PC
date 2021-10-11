/*
This Program or Software under MIT License, To know more please see License.txt File.
Author: MathInDOS
Date: 18 November 2020
Copyright (C) 2018-2020 MathInDOS
*/

#include "algor.h"


/* This algorithums were taken from Darkbox

  Darkbox - A Fast and Portable Console IO Server
  Copyright (C) 2016-2018 Teddy ASTIE
  
  Permission to use, copy, modify, and/or distribute this software for any
  purpose with or without fee is hereby granted, provided that the above
  copyright notice and this permission notice appear in all copies.

  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  
*/

/* Start from here */

void tool_draw_line(int Ax, int Ay, int Bx, int Bx)
{
	
    /* Code based on :
      https://rosettacode.org/wiki/Bitmap/Bresenham%27s_line_algorithm#C
    */
    int dx = abs(Bx-Ax), sx = Ax < Bx ? 1 : -1;
    int dy = abs(By-Ay), sy = Ay < By ? 1 : -1;
    int err = (dx > dy ? dx : -dy) / 2, e2;
	
    while (true) {
    tool_gotoxy(origin_x + Ax, origin_y + Ay);
    putchar(' ');
    if (Ax == Bx && Ay == By)
        break;
    e2 = err;
    if (e2 >-dx) {
    err -= dy;
    Ax += sx;
	
	}
    

    if (e2 < dy) {
    err += dx;
    Ay += sy;
    }
    }
}

void tool_draw_box(int x, int y, int w, int h)
{
    int hollow = read_int();

    for (int ix = x; ix < (x + w); ix++)
    for (int iy = y; iy < (y + h); iy++)
    if (!hollow || (ix == x || ix == (x + w - 1) || iy == y || iy == (y + h - 1))) {
    tool_gotoxy(origin_x + ix, origin_y + iy);
    putchar(' ');
	}
}

void tool_draw_circle(int x, int y, int r)
{
    int rx = r, ry = 0;
    int err = 0;

    #define circle_plot(cx, cy) do { \
    tool_gotoxy((cx) + origin_x, (cy) + origin_y); \
    putchar(' '); \
    } while (0)

    while (rx >= ry) {
        circle_plot(x + rx, y + ry);
        circle_plot(x + ry, y + rx);
        circle_plot(x - ry, y + rx);
        circle_plot(x - rx, y + ry);
        circle_plot(x - rx, y - ry);
        circle_plot(x - ry, y - rx);
        circle_plot(x + ry, y - rx);
        circle_plot(x + rx, y - ry);

        if (err <= 0) {
            ry++;
            err += 2 * ry + 1;
            } else {
              rx--;
              err -= 2 * rx + 1;
            }
          }
          #undef circle_plot
}

/* End of Start */
