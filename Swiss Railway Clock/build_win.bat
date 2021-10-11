@echo off&fbc -c Resource.rc -o Resource.o&fbc SwissRailwayClock.bas Resource.o -s gui -strip
del *.obj>nul&del *.o>nul 
echo Done!
pause>nul