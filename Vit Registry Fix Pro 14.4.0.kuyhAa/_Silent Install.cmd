@ECHO OFF
color 0B
mode con:cols=110 lines=15
@cls
echo.
echo.
echo.
@echo     Бл          ллл   ллл ллл    ллл ллл       ллл ллл  ллл  ллллллллл  ллллллллл     
@echo       л         ллл ллл   ллл    ллл   ллл   ллл   ллл  ллл лллллллллл лллллллллл     лллллллллллл ллллллл
@echo        Вл       ллллллл   ллл    ллл     ллллл     лллллллл    ллллллл    ллллллл     лл   лл  ллл лл Аллл
@echo       л         ллл ллл   ллл    ллл      ллл      ллл  ллл   лл   ллл   лл   ллл     лл   лл  ллл лллВ  
@echo     Бл   ВВВВВ  ллл   ллл лллллллллл      ллл      ллл  ллл   лллллллл   лллллллл ллл лл   лл  ллл ллллллВ   
@echo.  
@echo                                      SILENT MODE... shh! Jika VerySilent Not Found, Abaikan !                        
echo.                   
@echo off
FOR %%i IN ("Vit Registry Fix*.exe") DO Set FileName="%%i"
%FileName% /SILENT
@start VERYSILENT.url