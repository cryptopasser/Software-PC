@Echo Off
Title My IP Address - www.sordum.org

Echo Getting the IP address. Please wait.

for /f "tokens=*" %%c in ('"%~dp0\CopyIP.exe" /P') do set MY_IP=%%c

cls
If "%MY_IP%"=="" (
	Echo IP could not be retrieved!

	) Else (
	Echo Current IP Address: %MY_IP%
)
pause
