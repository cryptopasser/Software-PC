Dim fileobj,App_x86,App_x64
App_x86 = "MonitorOff.exe"
App_x64 = "MonitorOff_x64.exe"

Set fileobj = CreateObject("Scripting.FileSystemObject")
If (fileobj.FileExists(App_x86)) Then
	Set fileobj = WScript.CreateObject( "WScript.Shell" )
	fileobj.Run(App_x86 + " /Config")
Else if (fileobj.FileExists(App_x64)) Then
	Set fileobj = WScript.CreateObject( "WScript.Shell" )
	fileobj.Run(App_x64 + " /Config")
Else
	x=msgbox(App_x86 + " not found!" ,16, "www.sordum.org")
End If
End If
Set fileobj = Nothing
