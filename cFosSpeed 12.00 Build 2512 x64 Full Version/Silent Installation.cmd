@ECHO OFF
@cls
Color 09
mode con:cols=70 lines=15
@echo    //////////////////////////////////////////////////////////////
@echo    /                                                            /
@echo    /                CFosSpeed is installing...                  /
@echo    /                                                            /
@echo    /                       Please wait...                       /
@echo    /                  Dont close this window                    /
@echo    /                                                            /
@echo    /                        by Mirkec                           /
@echo    /                                                            /
@echo    /      Team OS : Your Only Destination To Custom OS !!       /
@echo    /                https://www.teamos-hkrg.com/                /
@echo    /                                                            /
@echo    //////////////////////////////////////////////////////////////
@echo off
FOR %%i IN ("cFosSpeed*.exe") DO Set FileName="%%i"
%FileName% /SILENT