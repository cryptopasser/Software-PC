Dim fileobj,App_x86,App_x64,Target_Key
App_x86 = "sWinKey.exe"
App_x64 = "sWinKey_x64.exe"
Target_Key = "R"

Set fileobj = CreateObject("Scripting.FileSystemObject")
If (fileobj.FileExists(App_x86)) Then
	Set fileobj = WScript.CreateObject( "WScript.Shell" )
	fileobj.Run(App_x86 + " " + Target_Key)
Else if (fileobj.FileExists(App_x64)) Then
	Set fileobj = WScript.CreateObject( "WScript.Shell" )
	fileobj.Run(App_x64 + " " + Target_Key)
Else
	x=msgbox(App_x86 + " not found!" ,16, "www.sordum.org")
End If
End If
Set fileobj = Nothing
