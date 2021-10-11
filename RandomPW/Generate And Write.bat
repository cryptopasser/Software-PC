@Echo Off

Set TargetFile="%~dp0\pass.txt"

RandomPW.exe Pass1:/w >> %TargetFile%
Echo. >> %TargetFile%
RandomPW.exe Pass2:/w >>%TargetFile%
Echo. >> %TargetFile%
