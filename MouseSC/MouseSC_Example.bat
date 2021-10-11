@Echo Off

Set tApp=MouseSC.exe
Set tCmd=/PrimaryButton:Left /Speed:10 /PointerPrecision:Enable /VerticalScroll:3 /HorizontalScroll:3

IF Not %PROCESSOR_ARCHITECTURE% == x86 Set tApp=MouseSC_x64.exe
If Not Exist "%~dp0\%tApp%" (
    Echo The file %tApp% was not found
	pause & exit
)

"%~dp0\%tApp%" %tCmd%
"%~dp0\%tApp%"
Pause
