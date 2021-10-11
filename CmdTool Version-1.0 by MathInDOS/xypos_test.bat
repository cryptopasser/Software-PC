@echo off
set !col1!=%14
set !col2!=%19
REM Make screen colors by %1[your number (1-9) [0] == Black]
cmdtool c %!col1!% & cmdtool g 13 09 "Hello World!"
cmdtool s 1
cmdtool c %!col2!% & cmdtool g 13 09 "Hello World!"
cmdtool c 12 & cmdtool g 13 08 "Hello World!"
pause>nul
exit
