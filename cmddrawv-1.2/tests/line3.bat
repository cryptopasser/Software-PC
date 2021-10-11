@echo off
mode 40,30
cmddraw /dline 100 50 200 50 /rgb 255 255 255 /pw 25
:: first ax gives 360 deg last by gives opposite 360 deg
cmddraw /dline 200 75 100 75 /rgb 0 0 255 /pw 25
cmddraw /dline 200 100 100 100 /rgb 255 0 0 /pw 25
pause>nul