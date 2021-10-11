'SwissRailwayClock by Moon Princess! (Sofia)
'License is gplv3

'Note: Even FreeBasic avaible for Linux too but I use WinAPI and GDIPlus so it's not working on Linux.
'Tank u soo much... ;3

#Include "fbgfx.bi"
#Include "String.bi"
#Include "vbcompat.bi"
#Define WIN_INCLUDEALL
#Include "windows.bi"
#Include "/win/commctrl.bi"
#Define WM_TRAYICON WM_APP + 1

#Ifdef __Fb_64bit__
   #Inclib "gdiplus"
   #Include Once "win/gdiplus-c.bi"
   #Define GCL_HICON (-14)
   #Define GCL_HICONSM (-34)
#Else
   #Include Once "win/gdiplus.bi"
   Using gdiplus
#Endif


Using FB

Declare Sub Update() 
Declare Function GenerateClockBg(fDiameter As Ushort) As Any Ptr 
Declare Function Base91Decode(sString As String, Byref iBase91Len As Ulong) As Ubyte Ptr
Declare Function _GDIPlus_BitmapCreateFromMemory2(aBinImage As Ubyte Ptr, iLen As Ulong, bBitmap_GDI As Bool = False) As Any Ptr
Declare Function WndProc(hWnd As HWND, uMsg As UINT, wParam As WPARAM, lParam As LPARAM) As Integer
Declare Sub _GDIPlus_BitmapApplyFilter_FastBoxBlur(Byval hImage As Any Ptr, range As Ulong)
Declare Sub FastBoxBlurH(hImage As Any Ptr, range As Ulong)
Declare Sub FastBoxBlurV(hImage As Any Ptr, range As Ulong)
Declare Function _WinAPI_IniRead(sIniFile As String, sSection As String, sKey As String, sDefault As String = "default") As String
Declare Function _WinAPI_IniWrite(sIniFile As String, sSection As String, sKey As String, sValue As String = "default") As Integer
Declare Sub CreateTransparentSettingWindow()
Declare Sub CreateTransparentBgSettingWindow()
Declare Sub CreateGUISizeSettingWindow()
Declare Function _WinAPI_CreateToolTip(hDlg As HWND, sToolTipText As String, bBalloon As Ubyte = 1) As HWND

#Define CRLF  Chr(13) + Chr(10)

Dim Shared gdipToken As ULONG_PTR
Dim Shared GDIp As GdiplusStartupInput 
GDIp.GdiplusVersion = 1
If GdiplusStartup(@gdipToken, @GDIp, NULL) <> 0 Then End

SetPriorityClass(GetCurrentProcess(), BELOW_NORMAL_PRIORITY_CLASS)

Dim As Integer sW, sH
Screeninfo(sW, sH)
Dim Shared As Ushort iW, iH
Dim Shared As Short ScreenW_old, ScreenH_old, ScreenL_old, ScreenT_old

iW = CUShort(_WinAPI_IniRead(Exepath & "\SwissRailwayClock.ini", "Settings", "WinSize", Str(200)))
iW = Iif(iW < 64, 64, Iif(iW > 800, 800, iW))
iH = iW
Dim Shared As Single fDefaultPosX, fDefaultPosY
fDefaultPosX = (sW - iW) / 2
fDefaultPosY = (sH - iH) / 2
Dim As Short xPos = CShort(_WinAPI_IniRead(Exepath & "\SwissRailwayClock.ini", "Settings", "x", Str(fDefaultPosX)))
Dim As Short yPos = CShort(_WinAPI_IniRead(Exepath & "\SwissRailwayClock.ini", "Settings", "y", Str(fDefaultPosY)))
Dim Shared As Byte iAutostart, iAlwaysOnTop, iClickThru
Dim Shared As UByte iAlpha, iBgTransparency
iAutostart = CByte(_WinAPI_IniRead(Exepath & "\SwissRailwayClock.ini", "Settings", "Autostart", "-1"))
iAutostart = IIf(iAutostart < -1 Or iAutostart > 1 Or iAutostart = 0, -1, iAutostart)
iAlwaysOnTop = CByte(_WinAPI_IniRead(Exepath & "\SwissRailwayClock.ini", "Settings", "AlwaysOnTop", "1"))
iAlwaysOnTop = IIf(iAlwaysOnTop < -1 Or iAlwaysOnTop > 1 Or iAlwaysOnTop = 0, 1, iAlwaysOnTop)
iAlpha = CUByte(_WinAPI_IniRead(Exepath & "\SwissRailwayClock.ini", "Settings", "Transparency", "255"))
iClickThru = Cbyte(_WinAPI_IniRead(Exepath & "\SwissRailwayClock.ini", "Settings", "ClickThru", "-1"))
iBgTransparency = Cubyte(_WinAPI_IniRead(Exepath & "\SwissRailwayClock.ini", "Settings", "BgTransparency", "255"))
ScreenW_old = CShort(_WinAPI_IniRead(Exepath & "\SwissRailwayClock.ini", "Settings", "ScreenW", Str(0)))
ScreenH_old = CShort(_WinAPI_IniRead(Exepath & "\SwissRailwayClock.ini", "Settings", "ScreenH", Str(0)))
ScreenL_old = CShort(_WinAPI_IniRead(Exepath & "\SwissRailwayClock.ini", "Settings", "ScreenL", Str(0)))
ScreenT_old = CShort(_WinAPI_IniRead(Exepath & "\SwissRailwayClock.ini", "Settings", "ScreenT", Str(0)))

Dim Shared As Single fPi, fRad, fDeg
fPi = Acos(-1)
fRad = fPi / 180
fDeg = 180 / fPi

'Region Windows GUI
Dim Shared WinClass As WNDCLASSEX
Dim Msg As MSG
Dim Shared As UByte bGUITrans, bGUISize, bGUIMsgbox
bGUITrans = 0
bGUISize = 0
bGUIMsgbox = 0
Dim Shared As String sTitle
sTitle = "Swiss Railway Clock (Idea get from a image)"

With WinClass
	.style         = CS_HREDRAW Or CS_VREDRAW
	.lpfnWndProc   = @WndProc
	.cbClsExtra    = NULL
	.cbWndExtra    = NULL
	.hInstance     = GetModuleHandle(NULL)
	.hIcon         = LoadIcon(NULL, "FB_PROGRAM_ICON")
	.hCursor       = LoadCursor(NULL, IDC_ARROW)
	.hbrBackground = GetStockObject(WHITE_BRUSH)
	.lpszMenuName  = NULL
	.lpszClassName = Strptr(sTitle)
	.cbSize		   = Sizeof(WNDCLASSEX)
End With

Dim Shared As Integer iStyleEx = 0
If iAlwaysOnTop = 1 Then iStyleEx = WS_EX_TOPMOST
If iClickThru = 1 Then iStyleEx = iStyleEx Or WS_EX_TRANSPARENT

Dim Shared As HWND hGUI, hGUI_TransparentSettings, hSlider_TransparentSettings, hLabel_TransparentSettings, hButton_TransparentSettings, _
              hGUI_GUISizeSettings, hSlider_GUISizeSettings, hLabel_GUISizeSettings, hButton_GUISizeSettings, _
              hGUI_TransparentBgSettings, hSlider_TransparentBgSettings, hLabel_TransparentBgSettings, hButton_TransparentBgSettings
Dim Shared As Long iSliderPos
Dim Shared As PAINTSTRUCT tPaintStruct

RegisterClassEx(@WinClass)
hGUI = CreateWindowEx(	WS_EX_LAYERED Or WS_EX_TOOLWINDOW Or iStyleEx, _
						WinClass.lpszClassName, sTitle, _
						WS_POPUP Or WS_VISIBLE, _
						xPos, yPos, _
						0, 0, _
						NULL, NULL, WinClass.hInstance, NULL)


'Region Tray Menu
Dim Shared As NOTIFYICONDATA SystrayIcon
Dim hIcon As hicon = ExtractIcon(getmodulehandle(0), Command(0), 0)
Const WM_SHELLNOTIFY = WM_USER + 5

With SystrayIcon
    .cbSize = Len(SystrayIcon)
    .hWnd = hGUI
    .uId = 1&
    .uFlags = NIF_ICON Or NIF_TIP Or NIF_MESSAGE
    .uCallbackMessage = WM_SHELLNOTIFY
    .hIcon = hIcon
    .szTip = sTitle + Chr(0)
End With

Const ID_About = 1000, ID_Exit = 1001, ID_Reset = 1002, ID_Autostart = 1003, ID_AlwaysOnTop = 1004, ID_SetGUISize = 1005, _
      ID_SetGUITransLevel = 1006, ID_ClickThru = 1007, ID_SetGUIBgTransLevel = 1008
Dim Shared As HANDLE MainMenu, AppMenu, SettingsMenu

MainMenu = CreateMenu()
AppMenu = CreateMenu()
SettingsMenu = CreateMenu()

AppendMenu(AppMenu, MF_STRING, ID_About, "&About")
AppendMenu(AppMenu, MF_SEPARATOR, 0, 0)
AppendMenu(AppMenu, MF_STRING, ID_AlwaysOnTop, "Always on &Top")
AppendMenu(AppMenu, MF_SEPARATOR, 0, 0)
AppendMenu(AppMenu, MF_STRING, ID_Autostart, "Auto&start with Windows")
AppendMenu(AppMenu, MF_SEPARATOR, 0, 0)
AppendMenu(AppMenu, MF_STRING, ID_ClickThru, "Dis&able Movement")
AppendMenu(AppMenu, MF_SEPARATOR, 0, 0)
AppendMenu(AppMenu, MF_STRING, ID_Reset, "&Reset Position")
AppendMenu(AppMenu, MF_SEPARATOR, 0, 0)

AppendMenu(AppMenu, MF_POPUP, Cast(Integer, SettingsMenu), "Settings")
AppendMenu(SettingsMenu, MF_STRING, ID_SetGUISize, "Set &Clock Size")
AppendMenu(SettingsMenu, MF_SEPARATOR, 0, 0)
AppendMenu(SettingsMenu, MF_STRING, ID_SetGUITransLevel, "Set Clock UI Transparency &Level")
AppendMenu(SettingsMenu, MF_SEPARATOR, 0, 0)
AppendMenu(SettingsMenu, MF_STRING, ID_SetGUIBgTransLevel, "Set Clock Background Transparency &Level")
AppendMenu(AppMenu, MF_SEPARATOR, 0, 0)
AppendMenu(AppMenu, MF_STRING, ID_Exit, "E&xit")

InsertMenu(MainMenu, 0, MF_POPUP, Cptr(UINT_PTR, AppMenu), 0)
        
Shell_NotifyIcon(NIM_ADD, @SystrayIcon)

If iAutostart = 1 Then CheckMenuItem(AppMenu, ID_AutoStart, MF_CHECKED)
If iAlwaysOnTop = 1 Then CheckMenuItem(AppMenu, ID_AlwaysOnTop, MF_CHECKED)
If iClickThru = 1 Then CheckMenuItem(AppMenu, ID_ClickThru, MF_CHECKED)

'---------------------

'Region registry
Dim As Any Ptr hReg
Dim As String * 2048 sRegValue
Dim As ZString Ptr sNewRegValue
Dim As DWORD iRegValueLength
Dim As String sRegPath = Chr(34) & Command(0) & Chr(34) & Chr(0)

sNewRegValue = Allocate(Len(sRegPath) + 1)
*sNewRegValue = sRegPath

'open
RegOpenKeyEx(HKEY_CURRENT_USER, "Software\Microsoft\Windows\CurrentVersion\Run", 0, KEY_ALL_ACCESS, @hReg)

If iAutostart = 1 Then
   RegSetValueEx(hReg, "SwissRailwayClock", NULL, REG_SZ, Cast(Byte Ptr, @sNewRegValue[0]), Len(*sNewRegValue))
ElseIf iAutostart = -1 Then
   RegDeleteValue(hReg, "SwissRailwayClock")   
End If ' Some times I make mistake with FreeBasic and AutoIt

RegFlushKey(hReg)

'---------------------


Dim Shared As Any Ptr hBitmap, hHBitmap, hCanvas, hBitmap_Clock, hBrush_Shadow, hBrush_Update, hPen_Update, hScrDC, hMemDC, hOld

Dim Shared As Point pSize
Dim Shared As Point pSource
Dim Shared As BLENDFUNCTION pBlend
pSize.X = iW
pSize.Y = iH
With pBlend
      .BlendOp = AC_SRC_OVER
      .BlendFlags = 0
      .SourceConstantAlpha = iAlpha
      .AlphaFormat = AC_SRC_ALPHA
End With

hScrDC = GetDC(hGUI)
hMemDC = CreateCompatibleDC(hScrDC)

GdipCreateBitmapFromScan0(iW, iH, 0, PixelFormat32bppARGB, 0, @hBitmap)
GdipGetImageGraphicsContext(hBitmap, @hCanvas)
GdipSetSmoothingMode(hCanvas, SmoothingModeHighQuality)
GdipSetPixelOffsetMode(hCanvas, PixelOffsetModeHalf)

Dim Shared As Ulong iShadowColor, iShadowColor2 = &h90000000
iShadowColor = &h20A0A0A0
GdipCreateSolidFill(iShadowColor, @hBrush_Shadow)
GdipCreateSolidFill(0, @hBrush_Update)
GdipCreatePen1(&hFFA02020, 1, 2, @hPen_Update)


'String positions
Dim As RectF tLayout

Dim Shared As Ushort fDiameter, fMin_next
Dim Shared As Single fShadowAngle, fRadius, fMSec
fDiameter = iW
fRadius = fDiameter / 2

hBitmap_Clock = GenerateClockBg(fDiameter)

Dim Shared As Single fSec, fHr, fAmplitude = 3
Dim Shared As Ubyte iSec, iMin, iHr, iHr_Delta, bProcessShutdown = 0

Dim Shared As SYSTEMTIME tTime

GetSystemTime(@tTime)
iMin = tTime.wMinute
fMin_next = iMin
iHr_Delta = CUByte(Format(Now(), "hh")) - tTime.wHour

SetTimer(hGUI, 1, 30, Cast(Any Ptr, @Update))

Dim As Double fTimer = Timer
Dim As RECT tDesktop
Dim As hwnd hHWND_Dt
Dim as Integer dx, dy, dw, dh, ScreenL, ScreenT, ScreenR, ScreenB, ScreenW, ScreenH
Dim tPos As RECT

hHWND_Dt = FindWindow("Progman","Program Manager")
GetWindowRect(hHWND_Dt, @tDesktop)
ScreenL = tDesktop.left
ScreenR = tDesktop.right
ScreenT = tDesktop.top
ScreenB = tDesktop.bottom
ScreenW = tDesktop.right + Abs(ScreenL)
ScreenH = tDesktop.bottom + Abs(ScreenT)

SetProcessShutdownParameters(&h3FF, 0)

While GetMessage(@Msg, 0, 0, 0)
	TranslateMessage(@Msg)
	DispatchMessage(@Msg)
	If Timer - fTimer > 1 Then
		hHWND_Dt = FindWindow("Progman","Program Manager")
		GetWindowRect(hHWND_Dt, @tDesktop)
		dx = tDesktop.left
		dy = tDesktop.top
		dw = tDesktop.right + Abs(dx)
		dh = tDesktop.bottom + Abs(dy)
		GetWindowRect(hGUI, @tPos)
		If tPos.Left < (dx - iW) Or tPos.Left > dw Or tPos.Top < (dy - iW) Or tPos.Top > dh Then 
			'SetWindowPos(hGUI, 0, Abs((ScreenW - ScreenR + xPos) / ScreenW * dw - dx - iW), Abs((ScreenH - ScreenB + yPos) / ScreenH * dh - dy - iH), 0, 0, 0)
			SetWindowPos(hGUI, 0, (xPos + Abs(ScreenL_old)) / ScreenW_old * dw - fDiameter * 0.70, (yPos + Abs(ScreenT_old)) / ScreenH_old * dh, 0, 0, 0)
		End If
		fTimer = Timer
	End If
	If bProcessShutdown = 1 Then Exit While
Wend

Killtimer(hGUI, 1)
GetWindowRect(hGUI, @tPos)

_WinAPI_IniWrite(Exepath & "\SwissRailwayClock.ini", "Settings", "x", Str(tPos.Left))
_WinAPI_IniWrite(Exepath & "\SwissRailwayClock.ini", "Settings", "y", Str(tPos.Top))
_WinAPI_IniWrite(Exepath & "\SwissRailwayClock.ini", "Settings", "WinSize", Str(iW))
_WinAPI_IniWrite(Exepath & "\SwissRailwayClock.ini", "Settings", "Autostart", Str(iAutostart))
_WinAPI_IniWrite(Exepath & "\SwissRailwayClock.ini", "Settings", "AlwaysOnTop", Str(iAlwaysOnTop))
_WinAPI_IniWrite(Exepath & "\SwissRailwayClock.ini", "Settings", "Transparency", Str(iAlpha))
_WinAPI_IniWrite(Exepath & "\SwissRailwayClock.ini", "Settings", "BgTransparency", Str(iBgTransparency))
_WinAPI_IniWrite(Exepath & "\SwissRailwayClock.ini", "Settings", "ClickThru", Str(iClickThru))
_WinAPI_IniWrite(Exepath & "\SwissRailwayClock.ini", "Settings", "ScreenL", Str(dx))
_WinAPI_IniWrite(Exepath & "\SwissRailwayClock.ini", "Settings", "ScreenT", Str(dy))
_WinAPI_IniWrite(Exepath & "\SwissRailwayClock.ini", "Settings", "ScreenR", Str(tDesktop.right))
_WinAPI_IniWrite(Exepath & "\SwissRailwayClock.ini", "Settings", "ScreenB", Str(tDesktop.bottom))
_WinAPI_IniWrite(Exepath & "\SwissRailwayClock.ini", "Settings", "ScreenW", Str(dw))
_WinAPI_IniWrite(Exepath & "\SwissRailwayClock.ini", "Settings", "ScreenH", Str(dh))

If iAutostart = 1 Then
   RegSetValueEx(hReg, "SwissRailwayClock", NULL, REG_SZ, Cast(Byte Ptr, @sNewRegValue[0]), Len(*sNewRegValue))
ElseIf iAutostart = -1 Then
   RegDeleteValue(hReg, "SwissRailwayClock")   
EndIf

RegFlushKey(hReg)

'close
RegCloseKey(hReg)

Deallocate(sNewRegValue)


'release resources
Shell_NotifyIcon(NIM_DELETE, @SystrayIcon)
DestroyIcon(hIcon)
ReleaseDC(0, hScrDC)
DeleteDC(hMemDC)
GdipDeleteBrush(hBrush_Shadow)
GdipDeleteBrush(hBrush_Update)
GdipDeletePen(hPen_Update)
GdipDisposeImage(hBitmap_Clock)
GdipDisposeImage(hBitmap)
GdipDeleteGraphics(hCanvas)
GdiplusShutdown(gdipToken)


Function WndProc(hWnd As HWND, uMsg As UINT, wParam As WPARAM, lParam As LPARAM) As Integer
   Select Case hWnd
      Case hGUI
         Select Case uMsg
            Case WM_QUERYENDSESSION
				   bProcessShutdown = 1
      	   Case WM_CLOSE
      			PostQuitMessage(0)	
      			Return 0
      	   Case WM_NCHITTEST
      			Return HTCAPTION
      		Case WM_KEYDOWN
      			If wParam = VK_ESCAPE Then
      				PostQuitMessage(0)
      				Return 0
      			EndIf
      	   Case WM_SHELLNOTIFY
               If lParam = WM_RBUTTONDOWN Then
                  Dim tPOINT As Point
                  GetCursorPos(@tPOINT)
                  SetForegroundWindow(hWnd)
                  TrackPopupMenuEx(AppMenu, TPM_LEFTALIGN Or TPM_RIGHTBUTTON, tPOINT.x, tPOINT.y, hWnd, NULL)
                  PostMessage(hWnd, WM_NULL, 0, 0)
               End If
      	   Case WM_COMMAND
      	      Select Case Loword (wParam)
      	         Case ID_About
      	            If bGUIMsgbox = 0 Then
      	               bGUIMsgbox = 1
      	               Messagebox(0, sTitle & CRLF & CRLF & "Created by Moon Princess! (Sofia)" & CRLF & CRLF & CRLF & "Free for everyone, license gplv3", "About", 0)
      	               bGUIMsgbox = 0
      	            EndIf
      	         Case ID_Exit
         				PostQuitMessage(0)
         				Return 0
      	         Case ID_Reset
      	            SetWindowPos(hGUI, 0, fDefaultPosX, fDefaultPosY, 0, 0, 0)
      	         Case ID_Autostart
      	            If iAutostart = -1 Then
      	               CheckMenuItem(AppMenu, ID_AutoStart, MF_CHECKED)
      	            Else
      	               CheckMenuItem(AppMenu, ID_AutoStart, MF_UNCHECKED)
      	            EndIf
      	            iAutostart *= -1
                  Case ID_SetGUITransLevel
      	            If bGUITrans = 0 Then 
      	               bGUITrans = 1
      	               CreateTransparentSettingWindow()
      	            EndIf
      	         Case ID_SetGUIBgTransLevel
     	               CreateTransparentBgSettingWindow()
      	         Case ID_SetGUISize
      	            If bGUISize = 0 Then
      	               bGUISize = 1
      	               CreateGUISizeSettingWindow()
      	            End If    	            
      	         Case ID_AlwaysOnTop
      	            If iAlwaysOnTop = -1 Then
      	               CheckMenuItem(AppMenu, ID_AlwaysOnTop, MF_CHECKED)
      				   SetWindowPos(hGUI, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE)
      	            Else
      	               CheckMenuItem(AppMenu, ID_AlwaysOnTop, MF_UNCHECKED)
      				   SetWindowPos(hGUI, HWND_NOTOPMOST, 0, 0, 0, 0, SWP_NOMOVE Or SWP_NOSIZE)
      	            EndIf
      	            iAlwaysOnTop *= -1
      				Case ID_ClickThru
      	            If iClickThru = -1 Then
      	               CheckMenuItem(AppMenu, ID_ClickThru, MF_CHECKED)
      				   SetWindowLongPtr(hGUI, GWL_EXSTYLE, GetWindowLongPtr(hGUI, GWL_EXSTYLE) Or WS_EX_TRANSPARENT)
      	            Else
      	               CheckMenuItem(AppMenu, ID_ClickThru, MF_UNCHECKED)
      				   SetWindowLongPtr(hGUI, GWL_EXSTYLE, GetWindowLongPtr(hGUI, GWL_EXSTYLE) Xor WS_EX_TRANSPARENT)    				   
      	            EndIf
      					iClickThru *= -1
      	      End Select
         End Select
      Case hGUI_TransparentSettings
			Select Case uMsg
			   Case WM_CREATE
			   Case WM_PAINT
					Dim As HBRUSH hBrush = CreateSolidBrush(&hF0F0F0)
					BeginPaint(hGUI_TransparentSettings, @tPaintStruct)
					FillRect(tPaintStruct.hdc, @tPaintStruct.rcPaint, hBrush)
					EndPaint(hGUI_TransparentSettings, @tPaintStruct)
					DeleteObject(hBrush)
				Case WM_COMMAND
					Select Case lParam  
					   Case hButton_TransparentSettings   
						   DestroyWindow(hGUI_TransparentSettings)
						   bGUITrans = 0
						   Return 0
					End Select
			   Case WM_CLOSE
		         DestroyWindow(hGUI_TransparentSettings)
		         bGUITrans = 0
		         Return 0
			   Case WM_KEYDOWN
      			If wParam = VK_ESCAPE Then
      				DestroyWindow(hGUI_TransparentSettings)
      				bGUITrans = 0
      				Return 0
      			EndIf
			   Case WM_HSCROLL
		      	Select Case lParam
		      	   Case hSlider_TransparentSettings
				         iSliderPos = SendMessage(hSlider_TransparentSettings, TBM_GETPOS, 0, 0)
				         SetWindowText(hLabel_TransparentSettings, Str(iSliderPos))
				         pBlend.SourceConstantAlpha = iSliderPos
				         iAlpha = iSliderPos
		      	End Select
			End Select
      Case hGUI_TransparentBgSettings
			Select Case uMsg
			   Case WM_CREATE
			   Case WM_PAINT
					Dim As HBRUSH hBrush = CreateSolidBrush(&hF0F0F0)
					BeginPaint(hGUI_TransparentBgSettings, @tPaintStruct)
					FillRect(tPaintStruct.hdc, @tPaintStruct.rcPaint, hBrush)
					EndPaint(hGUI_TransparentBgSettings, @tPaintStruct)
					DeleteObject(hBrush)
				Case WM_COMMAND
					Select Case lParam  
					   Case hButton_TransparentBgSettings   
						   DestroyWindow(hGUI_TransparentBgSettings)
						   bGUITrans = 0
						   Return 0
					End Select
			   Case WM_CLOSE
		         DestroyWindow(hGUI_TransparentBgSettings)
		         bGUITrans = 0
		         Return 0
			   Case WM_KEYDOWN
      			If wParam = VK_ESCAPE Then
      				DestroyWindow(hGUI_TransparentBgSettings)
      				bGUITrans = 0
      				Return 0
      			EndIf
			   Case WM_HSCROLL
		      	Select Case lParam
		      	   Case hSlider_TransparentBgSettings
				         iSliderPos = SendMessage(hSlider_TransparentBgSettings, TBM_GETPOS, 0, 0)
				         SetWindowText(hLabel_TransparentBgSettings, Str(iSliderPos))
				         iBgTransparency = iSliderPos
				         Killtimer(hGUI, 1)
				         GdipDisposeImage(hBitmap_Clock)
                     hBitmap_Clock = GenerateClockBg(fDiameter)
                     SetTimer(hGUI, 1, 30, Cast(Any Ptr, @Update))
		      	End Select
			End Select
      Case hGUI_GUISizeSettings
			Select Case uMsg
				Case WM_CREATE
			   Case WM_PAINT
					Dim As HBRUSH hBrush = CreateSolidBrush(&hF0F0F0)
					BeginPaint(hGUI_GUISizeSettings, @tPaintStruct)
					FillRect(tPaintStruct.hdc, @tPaintStruct.rcPaint, hBrush)
					EndPaint(hGUI_GUISizeSettings, @tPaintStruct)
					DeleteObject(hBrush)
				Case WM_COMMAND
					Select Case lParam  
					   Case hButton_GUISizeSettings   
						   DestroyWindow(hGUI_GUISizeSettings)
						   bGUISize = 0
						   Return 0
					End Select
			   Case WM_CLOSE
		         DestroyWindow(hGUI_GUISizeSettings)
		         bGUISize = 0
		         Return 0
			   Case WM_KEYDOWN
      			If wParam = VK_ESCAPE Then
      				DestroyWindow(hGUI_GUISizeSettings)
      				bGUISize = 0
      				Return 0
      			EndIf
      Case WM_HSCROLL
		      	Select Case lParam
		      	   Case hSlider_GUISizeSettings
				         iSliderPos = SendMessage(hSlider_GUISizeSettings, TBM_GETPOS, 0, 0)
				         SetWindowText(hLabel_GUISizeSettings, Str(iSliderPos))
				         Killtimer(hGUI, 1)
				         iW = iSliderPos
				         iH = iW
				         fDiameter = iW
                     fRadius = fDiameter / 2
                     pSize.X = iW
                     pSize.Y = iW
                     GdipDisposeImage(hBitmap_Clock)
                     GdipDisposeImage(hBitmap)
                     GdipDeleteGraphics(hCanvas)
                     GdipCreateBitmapFromScan0(iW, iH, 0, PixelFormat32bppARGB, 0, @hBitmap)
                     GdipGetImageGraphicsContext(hBitmap, @hCanvas)
                     GdipSetSmoothingMode(hCanvas, SmoothingModeHighQuality)
                     GdipSetPixelOffsetMode(hCanvas, PixelOffsetModeHalf)                    
                     hBitmap_Clock = GenerateClockBg(fDiameter)
                     SetTimer(hGUI, 1, 30, Cast(Any Ptr, @Update))
		      	End Select
		   End Select
   End Select
	Return DefWindowProc(hWnd, uMsg, wParam, lParam)
End Function

Sub CreateTransparentBgSettingWindow()
	Dim As Short iW = 275, iH = 115, iDesktopPosX = GetSystemMetrics(SM_CXSCREEN) - iW, iDesktopPosY
	Dim As HWND hTaskbar = FindWindow("Shell_TrayWnd", Null)
	Dim As RECT tRECT
	GetWindowRect(hTaskbar, @tRECT)
	iDesktopPosY = tRECT.top - iH
	hGUI_TransparentBgSettings = CreateWindowEx(WS_EX_APPWINDOW Or WS_EX_DLGMODALFRAME, _
                  									WinClass.lpszClassName, _ 'Class name
                  									"Transparency Background Setting", _ 'GUI name
                  									(WS_SYSMENU Or WS_CAPTION Or WS_VISIBLE), _
                  									iDesktopPosX - 4, _ 'x
                  									iDesktopPosY - 4, _ 'y
                  									iW, iH, _ 'w, h
                  									hGUI, _ 'hParent
                  									NULL, _ 'hMenu
                  									NULL, _ 'hInstance
                  									NULL) 'lpParam
	hSlider_TransparentBgSettings = CreateWindowEx(NULL, TRACKBAR_CLASS, "Trackbar Control", _
                              						WS_VISIBLE Or WS_CHILD Or TBS_NOTICKS Or TBS_ENABLESELRANGE Or TBS_TOOLTIPS Or TBS_BOTH, _
                              						4, 4, 200, 40, hGUI_TransparentBgSettings, NULL, NULL, NULL)
	SendMessage(hSlider_TransparentBgSettings, TBM_SETRANGE,TRUE, MAKELONG(0, 255))
	SendMessage(hSlider_TransparentBgSettings, TBM_SETPOS, TRUE, iBgTransparency) 
	hLabel_TransparentBgSettings = CreateWindowEx(NULL, "static", "", WS_VISIBLE Or WS_CHILD Or SS_CENTER Or SS_CENTERIMAGE Or SS_SUNKEN, 207, 9, 50, 18, hGUI_TransparentBgSettings, NULL, NULL, NULL)
	SetWindowText(hLabel_TransparentBgSettings, Str(iBgTransparency))
	hButton_TransparentBgSettings = CreateWindowEx(NULL, "Button", "Ok", WS_VISIBLE Or WS_CHILD, 4, 50, 260, 30, hGUI_TransparentBgSettings, NULL, NULL, NULL)
	'DestroyIcon(Cast(HANDLE, GetClassLong(hGUI_TransparentSettings, GCL_HICON)))
	'SetClassLong(hGUI_TransparentSettings, GCL_HICON, 0)
	'SetClassLong(hGUI_TransparentSettings, GCL_HICONSM, 0)
	_WinAPI_CreateToolTip(hSlider_TransparentBgSettings, "255 is opaque, 0 is full transparent")  
End Sub

Sub CreateTransparentSettingWindow()
	Dim As Short iW = 275, iH = 115, iDesktopPosX = GetSystemMetrics(SM_CXSCREEN) - iW, iDesktopPosY
	Dim As HWND hTaskbar = FindWindow("Shell_TrayWnd", Null)
	Dim As RECT tRECT
	GetWindowRect(hTaskbar, @tRECT)
	iDesktopPosY = tRECT.top - iH
	hGUI_TransparentSettings = CreateWindowEx(WS_EX_APPWINDOW Or WS_EX_DLGMODALFRAME, _
                  									WinClass.lpszClassName, _ 'Class name
                  									"Transparency Setting", _ 'GUI name
                  									(WS_SYSMENU Or WS_CAPTION Or WS_VISIBLE), _
                  									iDesktopPosX - 4, _ 'x
                  									iDesktopPosY - 4, _ 'y
                  									iW, iH, _ 'w, h
                  									hGUI, _ 'hParent
                  									NULL, _ 'hMenu
                  									NULL, _ 'hInstance
                  									NULL) 'lpParam
	hSlider_TransparentSettings = CreateWindowEx(NULL, TRACKBAR_CLASS, "Trackbar Control", _
                              						WS_VISIBLE Or WS_CHILD Or TBS_NOTICKS Or TBS_ENABLESELRANGE Or TBS_TOOLTIPS Or TBS_BOTH, _
                              						4, 4, 200, 40, hGUI_TransparentSettings, NULL, NULL, NULL)
	SendMessage(hSlider_TransparentSettings, TBM_SETRANGE,TRUE, MAKELONG(0, 255))
	SendMessage(hSlider_TransparentSettings, TBM_SETPOS, TRUE, iAlpha) 
	hLabel_TransparentSettings = CreateWindowEx(NULL, "static", "", WS_VISIBLE Or WS_CHILD Or SS_CENTER Or SS_CENTERIMAGE Or SS_SUNKEN, 207, 9, 50, 18, hGUI_TransparentSettings, NULL, NULL, NULL)
	SetWindowText(hLabel_TransparentSettings, Str(iAlpha))
	hButton_TransparentSettings = CreateWindowEx(NULL, "Button", "Ok", WS_VISIBLE Or WS_CHILD, 4, 50, 260, 30, hGUI_TransparentSettings, NULL, NULL, NULL)
	'DestroyIcon(Cast(HANDLE, GetClassLong(hGUI_TransparentSettings, GCL_HICON)))
	'SetClassLong(hGUI_TransparentSettings, GCL_HICON, 0)
	'SetClassLong(hGUI_TransparentSettings, GCL_HICONSM, 0)
	_WinAPI_CreateToolTip(hSlider_TransparentSettings, "255 is opaque, 0 is full transparent")  
End Sub

Sub CreateGUISizeSettingWindow()
	Dim As Short iW_size = 275, iH_size = 115, iDesktopPosX = GetSystemMetrics(SM_CXSCREEN) - iW_size, iDesktopPosY
	Dim As HWND hTaskbar = FindWindow("Shell_TrayWnd", Null)
	Dim As RECT tRECT
	GetWindowRect(hTaskbar, @tRECT)
	iDesktopPosY = tRECT.top - iH_size
	hGUI_GUISizeSettings = CreateWindowEx(WS_EX_APPWINDOW Or WS_EX_DLGMODALFRAME, _
                  									WinClass.lpszClassName, _ 'Class name
                  									"Size Settings", _ 'GUI name
                  									(WS_SYSMENU Or WS_CAPTION Or WS_VISIBLE), _
                  									iDesktopPosX - 4, _ 'x
                  									iDesktopPosY - 4, _ 'y
                  									iW_size, iH_size, _ 'w, h
                  									hGUI, _ 'hParent
                  									NULL, _ 'hMenu
                  									NULL, _ 'hInstance
                  									NULL) 'lpParam
	hSlider_GUISizeSettings = CreateWindowEx(NULL, TRACKBAR_CLASS, "Trackbar Control", _
                              						WS_VISIBLE Or WS_CHILD Or TBS_NOTICKS Or TBS_ENABLESELRANGE Or TBS_TOOLTIPS Or TBS_BOTH, _
                              						4, 4, 200, 40, hGUI_GUISizeSettings, NULL, NULL, NULL)
	SendMessage(hSlider_GUISizeSettings, TBM_SETRANGE,TRUE, MAKELONG(64, 800))
	SendMessage(hSlider_GUISizeSettings, TBM_SETPOS, TRUE, fDiameter) 
	hLabel_GUISizeSettings = CreateWindowEx(NULL, "static", "", WS_VISIBLE Or WS_CHILD Or SS_CENTER Or SS_CENTERIMAGE Or SS_SUNKEN, 207, 9, 50, 18, hGUI_GUISizeSettings, NULL, NULL, NULL)
	SetWindowText(hLabel_GUISizeSettings, Str(fDiameter))
	hButton_GUISizeSettings = CreateWindowEx(NULL, "Button", "Ok", WS_VISIBLE Or WS_CHILD, 4, 50, 260, 30, hGUI_GUISizeSettings, NULL, NULL, NULL)
	_WinAPI_CreateToolTip(hSlider_GUISizeSettings, "Choose a site from 64 to 800 pixels!")
End Sub

'https://msdn.microsoft.com/en-us/library/windows/desktop/hh298368(v=vs.85).aspx
Function _WinAPI_CreateToolTip(hDlg As HWND, sToolTipText As String, bBalloon As Ubyte = 1) As HWND
	If hDlg = 0 Or Len(sToolTipText) = 0 Then Return 0
	If Len(sToolTipText) > 79 Then Left(sToolTipText, 79)
	Dim hToolTip As HWND
	
	bBalloon = Iif(bBalloon > 1, 1, bBalloon)
	Dim As Long iStyle = bBalloon * TTS_BALLOON
	hToolTip = CreateWindowEx(Null, TOOLTIPS_CLASS, NULL, _
							  WS_POPUP Or TTS_NOPREFIX Or TTS_ALWAYSTIP Or iStyle, _
							  CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, CW_USEDEFAULT, _
							  hDlg, Null, Null, Null)

	If hToolTip = 0 Then Return 0

	Dim tToolInfo As TOOLINFO
	With tToolInfo
		.cbSize = Sizeof(tToolInfo)
		.uFlags = TTF_SUBCLASS
		.hwnd = hDlg
		.hinst = Null
		.lpszText = Strptr(sToolTipText)
		.uId = 0
	End With
	GetClientRect(hDlg, @tToolInfo.rect)

	SendMessage(hToolTip, TTM_ADDTOOL, 0, Cast(LPARAM, @tToolInfo) )
	Return hToolTip
End Function

Sub Update() 
	GdipGraphicsClear(hCanvas, &h00000000)
	GdipDrawImageRect(hCanvas, hBitmap_Clock, 0, 0, fDiameter, fDiameter)
	
	Static As Ulong bBounce = 0, f = 0
	GetSystemTime(@tTime)
	fMSec = tTime.wMilliseconds / 1000
	iSec = tTime.wSecond
	iMin = tTime.wMinute
	'iHr = tTime.wHour + iHr_Delta
	iHr = CUByte(Format(Now(), "hh"))

   
	Dim As Single iWidth1 = fDiameter * 0.0375, _
			  iHeight1 = fDiameter / 2.5, _
			  iWidth12 = iWidth1 / 2, _
			  fPosY = fDiameter * 0.2, iWidth2, iWidth22, fPosY2, _
			  m1 = fDiameter * 0.015, fMin_
				  
	'Draw Hour needle
	fHr = 30 * (iHr + iMin / 60)
	GdipTranslateWorldTransform(hCanvas, fRadius, fRadius, MatrixOrderPrepend)
	GdipRotateWorldTransform(hCanvas, fHr, MatrixOrderPrepend)
	GdipTranslateWorldTransform(hCanvas, -fRadius, -fRadius, MatrixOrderPrepend)
	GdipSetSolidFillColor(hBrush_Update, &hFF101010)
	GdipFillRectangle(hCanvas, hBrush_Shadow, _
					  fRadius - iWidth12 + Cos((fShadowAngle - fHr) * fRad) * m1, _
					  fPosY + Sin((fShadowAngle - fHr) * fRad) * m1, _
					  iWidth1, iHeight1)
	GdipFillRectangle(hCanvas, hBrush_Update, _
					  fRadius - iWidth12, _
					  fPosY, _
					  iWidth1, iHeight1)
	GdipResetWorldTransform(hCanvas)
	
	'Draw Minute needle
	If fMin_next <> iMin Then bBounce = 1
	If bBounce = 1 Then
		fMin_ = (6 * ((fMin_next + 1) Mod 60)) + Sin(f * 1.9) * fAmplitude
		If fAmplitude = 0 Then
			fMin_next = iMin
			f = 0
			fAmplitude = 3
			bBounce = 0
		Else
			fAmplitude -= 0.5
			fAmplitude = Iif(fAmplitude <= 0, 0, fAmplitude)
			f += 1
		End If
	Else
		fMin_ = (6 * iMin)
	End If
	GdipTranslateWorldTransform(hCanvas, fRadius, fRadius, MatrixOrderPrepend)
	GdipRotateWorldTransform(hCanvas, fMin_, MatrixOrderPrepend)
	GdipTranslateWorldTransform(hCanvas, -fRadius, -fRadius, MatrixOrderPrepend)		
	iWidth1 = fDiameter * 0.03
	iHeight1 = fRadius
	iWidth12 = iWidth1 / 2
	fPosY = fDiameter * 0.1				   
	GdipFillRectangle(hCanvas, hBrush_Shadow, _
					  fRadius - iWidth12 + Cos((fShadowAngle - fMin_) * fRad) * m1, _
					  fPosY + Sin((fShadowAngle - fMin_) * fRad) * m1, _
					  iWidth1, iHeight1)
	GdipFillRectangle(hCanvas, hBrush_Update, _
					  fRadius - iWidth12, _
					  fPosY, _
					  iWidth1, iHeight1)
	GdipResetWorldTransform(hCanvas)
	
	'Draw Second needle
	fSec = 6 * (iSec * 1.02564 + fMSec)
	If fSec >= 360 Then fSec = 0
	GdipTranslateWorldTransform(hCanvas, fRadius, fRadius, MatrixOrderPrepend)
	GdipRotateWorldTransform(hCanvas, fSec, MatrixOrderPrepend)
	GdipTranslateWorldTransform(hCanvas, -fRadius, -fRadius, MatrixOrderPrepend)		
	fPosY = fDiameter * 0.27
	fPosY2 = fDiameter * 0.19
	iWidth1 = fDiameter * 0.0095
	iHeight1 = fRadius * 1.3 - fPosY
	iWidth12 = iWidth1 / 2
	iWidth2 = fDiameter * 0.083333
	iWidth22 = iWidth2 / 2	
	
	'Draw shadow of Second needle
	GdipFillRectangle(hCanvas, hBrush_Shadow, _
					  fRadius + Cos((fShadowAngle - fSec) * fRad) * m1, _
					  fPosY + Sin((fShadowAngle - fSec) * fRad) * m1, _
					  iWidth1 + fDiameter * 0.006667, iHeight1 + fDiameter * 0.006667)
	GdipFillEllipse(hCanvas, hBrush_Shadow, _
					  fRadius - iWidth22 + Cos((fShadowAngle - fSec) * fRad) * m1, _
					  fPosY2 + Sin((fShadowAngle - fSec) * fRad) * m1, _
					  iWidth2, iWidth2)
	
	'Draw Second needle
	GdipSetSolidFillColor(hBrush_Update, &hFFC01010)
	GdipFillRectangle(hCanvas, hBrush_Update, _
					  fRadius - iWidth12, _
					  fPosY, _
					  iWidth1, iHeight1)
	GdipFillEllipse(hCanvas, hBrush_Update, _
					  fRadius - iWidth22, _
					  fPosY2, _
					  iWidth2, iWidth2)						   
	GdipResetWorldTransform(hCanvas)
	
	'button in the center
	GdipFillEllipse(hCanvas, hBrush_Update, _
					  fRadius - iWidth1, _
					  fRadius - iWidth1, _
					  2 * iWidth1, 2 * iWidth1)	
	GdipDrawEllipse(hCanvas, hPen_Update, _
					  fRadius - iWidth1, _
					  fRadius - iWidth1, _
					  2 * iWidth1, 2 * iWidth1)
   'Draw To Screen
   GdipCreateHBITMAPFromBitmap(hBitmap, @hHBitmap, &hFF000000)
   
	hOld = SelectObject(hMemDC, hHBitmap)
	UpdateLayeredWindow(hGUI, hScrDC, NULL, Cast(Any Ptr, @pSize), hMemDC, Cast(Any Ptr, @pSource), 0, Cast(Any Ptr, @pBlend), ULW_ALPHA)
	SelectObject(hMemDC, hOld)
	DeleteObject(hHBitmap)
End Sub

Function GenerateClockBg(fDiameter As Ushort) As Any Ptr
	Dim As Any Ptr hBitmap_Logo, hBitmap_tmp, hGfx, hGfx2
	
	'decompress base91 encoded image
	Dim As Ulong iLines, bCompressed, iFileSize, iCompressedSize
	Dim As String sBaseType, sBase91, aB91(1)

	Restore __fblogopng:
	Read iLines
	Read bCompressed
	Read iFileSize
	Read iCompressedSize
	Read sBaseType
	For i As Ushort = 0 To iLines - 1
	   Read aB91(0)
	   sBase91 &= aB91(0)
	Next

	Dim As Ulong iLenB91
	Static As Ubyte Ptr aBinary
	aBinary = Base91Decode(sBase91, iLenB91)
	
	Dim As Any Ptr hBitmap, hBrush, hBrushL, hPen, hPenL, hFamily, hStringFormat, hFont
	GdipCreateBitmapFromScan0(fDiameter, fDiameter, 0, PixelFormat32bppARGB, 0, @hBitmap)
	GdipGetImageGraphicsContext(hBitmap, @hGfx)
	GdipSetSmoothingMode(hGfx, 4)
	GdipSetPixelOffsetMode(hGfx, 4)
	GdipSetTextRenderingHint(hGfx, 4)
	GdipCreateSolidFill(iBgTransparency Shl 24 Or &hFFFFFF, @hBrush)
	
	Dim As Single fBorderSize = fDiameter * 0.03333
	GdipCreatePen1(iShadowColor2, fBorderSize, 2, @hPen)
	Dim As Single fSize = fDiameter * 0.9475 - fBorderSize / 2, fRadius = fDiameter / 2, fShadow_vx = fDiameter * 0.0095, fShadow_vy = fDiameter * 0.01
	
	GdipFillEllipse(hGfx, hBrush, fBorderSize, fBorderSize, fSize, fSize)
	fShadowAngle = Atn(fShadow_vy / fShadow_vx) * fDeg
	If fShadow_vx < 0 And fShadow_vy >= 0 Then fShadowAngle += 180
	If fShadow_vx < 0 And fShadow_vy < 0 Then fShadowAngle -= 180
	GdipDrawEllipse(hGfx, hPen, fBorderSize + fShadow_vx, fBorderSize + fShadow_vy, fSize, fSize)
	_GDIPlus_BitmapApplyFilter_FastBoxBlur(hBitmap, fDiameter * 0.015)
	
	Dim As GpPointF tPoint1, tPoint2
	tPoint1.x = 0
	tPoint1.y = 0
	tPoint2.x = fSize
	tPoint2.y = fSize
	GdipCreateLineBrush(@tPoint1, @tPoint2, &hAFFFFFFF, &hFF000000, 3, @hBrushL)
	GdipSetLineSigmaBlend(hBrushL, 0.6, 1.0)
	GdipSetLineGammaCorrection(hBrushL, TRUE)
	GdipCreatePen2(hBrushL, fBorderSize, UnitPixel, @hPenL)
	GdipDrawEllipse(hGfx, hPenL, fBorderSize, fBorderSize, fSize, fSize)

	GdipSetSolidFillColor(hBrush, &hFF000000)
	
	GdipTranslateWorldTransform(hGfx, fRadius, fRadius, 0)
	GdipRotateWorldTransform(hGfx, -6.0, MatrixOrderPrepend)
	GdipTranslateWorldTransform(hGfx, -fRadius, -fRadius, 0)
	
	Dim As Single iWidth1 = fDiameter * 0.026667, iHeight1 = fDiameter / 10, iWidth12 = iWidth1 / 2, fPosY = fDiameter * 0.083333, _
		  iWidth2 = fDiameter * 0.013333, iHeight2 = fDiameter * 0.0416667, iWidth22 = iWidth2 / 2
		  
	For i As Ubyte = 0 To 59
		GdipTranslateWorldTransform(hGfx, fRadius, fRadius, 0)
		GdipRotateWorldTransform(hGfx, 6.0, MatrixOrderPrepend)
		GdipTranslateWorldTransform(hGfx, -fRadius, -fRadius, 0)	
		If (i Mod 5) = 0 Then
			GdipFillRectangle(hGfx, hBrush, fRadius - iWidth12, fPosY, iWidth1, iHeight1)
		Else
			GdipFillRectangle(hGfx, hBrush, fRadius - iWidth22, fPosY, iWidth2, iHeight2)
		End If
	Next
	GdipResetWorldTransform(hGfx)
	
	Dim As GpRectF tLayout
	
	tLayout.Width = fRadius * 0.4
	tLayout.height = fRadius * 0.4
	tLayout.x = fRadius - fRadius * 0.2
	tLayout.y = fRadius + fRadius * 0.15
	
	GdipCreateFontFamilyFromName("Segoe Script", Null, @hFamily)
	GdipCreateStringFormat(0, 0, @hStringFormat)
	GdipCreateFont(hFamily, fDiameter * 0.025, FontStyleBold, UnitPoint, @hFont)
	GdipSetStringFormatAlign(hStringFormat, StringAlignmentCenter)
	GdipSetStringFormatLineAlign(hStringFormat, StringAlignmentCenter)
	GdipSetTextRenderingHint(hCanvas, TextRenderingHintAntiAliasGridFit)
	GdipDrawString(hGfx, "Clock by" & CrLf & "Sofia!", -1, hFont, @tLayout, hStringFormat, hBrush)
	
	Dim As Single fLogoSize = fDiameter * 15, fLogoW, fLogoH, fTmp
	hBitmap_tmp = _GDIPlus_BitmapCreateFromMemory2(@aBinary[0], iFileSize)
	GdipGetImageDimension(hBitmap_tmp, @fLogoW, @fLogoH)
	fTmp = fLogoW
	fLogoW = fLogoSize / fLogoH
	fLogoH = fLogoSize / fTmp
	GdipCreateBitmapFromScan0(fLogoW, fLogoH, 0, PixelFormat32bppARGB, 0, @hBitmap_Logo)
	GdipGetImageGraphicsContext(hBitmap_Logo, @hGfx2)
	GdipSetInterpolationMode(hGfx2, 7)
	GdipDrawImageRect(hGfx2, hBitmap_tmp, 0, 0, fLogoW, fLogoH)
	GdipDrawImageRect(hGfx, hBitmap_Logo, fRadius - fLogoW / 2, fRadius / 1.75, fLogoW, fLogoH)
    GdipDisposeImage(hBitmap_tmp)

	GdipDisposeImage(hBitmap_Logo)
	GdipDeleteFont(hFont)
	GdipDeleteFontFamily(hFamily)
	GdipDeleteStringFormat(hStringFormat)
	GdipDeleteBrush(hBrush)
	GdipDeleteBrush(hBrushL)
	GdipDeletePen(hPen)
	GdipDeletePen(hPenL)
	GdipDeleteGraphics(hGfx)
	GdipDeleteGraphics(hGfx2)
	Return hBitmap
End Function

Function _GDIPlus_BitmapCreateFromMemory2(aBinImage As Ubyte Ptr, iLen As Ulong, bBitmap_GDI As Bool = False) As Any Ptr
	Dim As HGLOBAL hGlobal
	Dim As LPSTREAM hStream
	Dim As Any Ptr hBitmap_Stream
	Dim As Any Ptr hMemory = GlobalAlloc(GMEM_MOVEABLE, iLen)
	Dim As Any Ptr lpMemory = GlobalLock(hMemory)
	RtlCopyMemory(lpMemory, @aBinImage[0], iLen)
	GlobalUnlock(hMemory)
	CreateStreamOnHGlobal(hMemory, 0, @hStream)
	GdipCreateBitmapFromStream(hStream, @hBitmap_Stream)
	IUnknown_Release(hStream)

	If bBitmap_GDI = TRUE Then
		Dim hBitmap_GDI As Any Ptr
		GdipCreateHBITMAPFromBitmap(hBitmap_Stream, @hBitmap_GDI, &hFF000000)
		GdipDisposeImage(hBitmap_Stream)
		Return hBitmap_GDI
	EndIf

	Return hBitmap_Stream
End Function

'https://lotsacode.wordpress.com/2010/12/08/fast-blur-box-blur-With-accumulator/
Sub _GDIPlus_BitmapApplyFilter_FastBoxBlur(Byval hImage As Any Ptr, range As Ulong)
	If (range Mod 2) = 0 Then range += 1
	FastBoxBlurH(hImage, range)
	FastBoxBlurV(hImage, range)
End Sub

Sub FastBoxBlurH(hImage As Any Ptr, range As Ulong)
	Dim As Single w, h
	GdipGetImageDimension(hImage, @w, @h)
	
	Dim As BitmapData tBitmapData
	Dim As Rect tRect = Type(0, 0, w, h)
	
	Dim As Long halfRange = range \ 2, index = 0, NewColors(0 To w), hits, a, r, g, b, oldPixel, col, newPixel
	
	GdipBitmapLockBits(hImage, Cast(Any Ptr, @tRect), ImageLockModeRead Or ImageLockModeWrite, PixelFormat32bppARGB, @tBitmapData)
	For y As Uinteger = 0 To h - 1
		a = 0
		r = 0
		g = 0
		b = 0
		hits = 0
		For x As Integer = -halfRange To w - 1
			oldPixel = x - halfRange - 1
			If oldPixel >= 0 Then
				col = Cast(Ulong Ptr, tBitmapData.Scan0)[index + oldPixel]
				If col <> 0 Then
					a -= Cubyte(col Shr 24)
					r -= Cubyte(col Shr 16)
					g -= Cubyte(col Shr 8)
					b -= Cubyte(col)
				End If
				hits -= 1
			End If
			newPixel = x + halfRange
			If newPixel < w Then
				col = Cast(Ulong Ptr, tBitmapData.Scan0)[index + newPixel]
				If col <> 0 Then
					a += Cubyte(col Shr 24)
					r += Cubyte(col Shr 16)
					g += Cubyte(col Shr 8)
					b += Cubyte(col)
				End If
				hits += 1
			End If
			If x >= 0 Then
				NewColors(x) = (Cubyte(a / hits) Shl 24) Or (Cubyte(r / hits) Shl 16) Or (Cubyte(g / hits) Shl 8) Or Cubyte(b / hits)
			End If
		Next
		For x As Uinteger = 0 To w - 1
			Cast(Ulong Ptr, tBitmapData.Scan0)[index + x] = NewColors(x)
		Next
		index += w
	Next
	GdipBitmapUnlockBits(hImage, @tBitmapData)
End Sub

Sub FastBoxBlurV(hImage As Any Ptr, range As Ulong)
	Dim As Single w, h
	GdipGetImageDimension(hImage, @w, @h)
	
	Dim As BitmapData tBitmapData
	Dim As Rect tRect = Type(0, 0, w, h)
	
	Dim As Long halfRange = range \ 2, index, NewColors(0 To h), hits, a, r, g, b, oldPixel, col, newPixel, _
				oldPixelOffset = -(halfRange + 1) * w, newPixelOffset = (halfRange) * w
	
	GdipBitmapLockBits(hImage, Cast(Any Ptr, @tRect), ImageLockModeRead Or ImageLockModeWrite, PixelFormat32bppARGB, @tBitmapData)
		
	For x As Uinteger = 0 To w - 1
		hits = 0
		a = 0
		r = 0
		g = 0
		b = 0
		index = -halfRange * w + x
		For y As Integer = -halfRange To h - 1
			oldPixel = y - halfRange - 1
			If oldPixel >= 0 Then
				col = Cast(Ulong Ptr, tBitmapData.Scan0)[index + oldPixelOffset]
				If col <> 0 Then
					a -= Cubyte(col Shr 24)
					r -= Cubyte(col Shr 16)
					g -= Cubyte(col Shr 8)
					b -= Cubyte(col)
				End If
				hits -= 1
			End If
			newPixel = y + halfRange
			If newPixel < h Then
				col = Cast(Ulong Ptr, tBitmapData.Scan0)[index + newPixelOffset]
				If col <> 0 Then
					a += Cubyte(col Shr 24)
					r += Cubyte(col Shr 16)
					g += Cubyte(col Shr 8)
					b += Cubyte(col)
				End If
				hits += 1
			End If
			If y >= 0 Then
				NewColors(y) = (Cubyte(a / hits) Shl 24) Or (Cubyte(r / hits) Shl 16) Or (Cubyte(g / hits) Shl 8) Or Cubyte(b / hits)
			End If
			index += w
		Next
		For y As Uinteger = 0 To h - 1
			Cast(Ulong Ptr, tBitmapData.Scan0)[y * w + x] = NewColors(y)
		Next
	Next
	GdipBitmapUnlockBits(hImage, @tBitmapData)
End Sub

'https://msdn.microsoft.com/en-us/library/ms724353.aspx
Function _WinAPI_IniRead(sIniFile As String, sSection As String, sKey As String, sDefault As String = "default") As String
	Dim As Zstring * 1024 Buffer
	Dim As Integer iResult = GetPrivateProfileString(sSection, sKey, sDefault, @Buffer, Sizeof(Buffer), sIniFile)
	Return Buffer
End Function

'https://msdn.microsoft.com/en-us/library/ms725500(v=vs.85).aspx
Function _WinAPI_IniWrite(sIniFile As String, sSection As String, sKey As String, sValue As String = "default") As Integer
	Dim As Zstring * 1024 Buffer
	Dim As Integer iResult = WritePrivateProfileString(sSection, sKey, sValue, sIniFile)
	Return iResult
End Function

'thanks to learn coding group Base91Decode
Function Base91Decode(sString As String, Byref iBase91Len As Ulong) As Ubyte Ptr
   Dim As String sB91, sDecoded 
   sB91 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!#$%&()*+,./:;<=>?@[]^_`{|}~´" '´ instead of "
   Dim As Long i, n = 0, c, b = 0, v = -1

   Dim aChr(0 To Len(sString) - 1) As String
   For i = 0 To Ubound(aChr)             
      aChr(i) = Mid(sString, i + 1, 1)
   Next
   
   For i = 0 To Ubound(aChr)
      c = Instr(sB91, aChr(i)) - 1
      If v < 0 Then
         v = c
      Else
         v += c * 91
         b = b Or (v Shl n)
         n += 13 + (((v And 8191) <= 88) * -1)
         Do Until  (n > 7)=0
            sDecoded &= Chr(b And 255)
            b = b Shr 8
            n -= 8
         Loop
         v = -1
      EndIf
   Next
   If (v + 1) Then 
      sDecoded &= Chr((b Or (v Shl n)) And 255) 
   End If
   iBase91Len = Len(sDecoded)

   Static As Ubyte aReturn(0 To Len(sDecoded))
   For i = 0 To Len(sDecoded) - 1
      aReturn(i) = Asc(sDecoded, i + 1)
   Next
   Return @aReturn(0)
End Function

' By file2bas
__fblogopng:
Data 2,0,1153,1414,"Base91"
Data "vuk:eJs4+BAAN/<MCG4DAA´]BABt;LMAAA7f9(}mAABtHOyc:[rn<AAAAAAAAAAAAAAAAAAAAAAAuWV´9,AAC´kUNU8DII#}#~Slo5wT5|AA$AjzLH:OVl|gjw#J1D?vIyB|~~d+josXA#3?:G!q&|O1H5dJ?`5FN^g~q?<V@)Zq1~NzdZ`cB~je:_p1IVdVE<Gv`Bc>t^8hvX_/oC@k~}:Zd{2{[_+!i8(>f]4^[52>q=Rs&zcF#r49<R&@Bkonle8lyBRZp}51[^hHOw3s0D?40,~QAn_{VvkkTT+SB,_IL*:o&T.^?Uf(aqd*Wu$.C&YS%)mT<!Zy%(:GhWT2?M0Y^gL@Tgr$rG%E/38g~k?){JS´!+GL;;.5XiJ`t^YdDcl69,/3)X0Lmb~V.uaZhB*XiVN/{b}=^%/m4B0/?UY9BClk*[=u7Q2pe||>Bma<Xo,@K9w&D0]Y]fL.m{^q6fo#o?s|!5n28B5v4_K{S$|^40VRNi&M9Lj0E{`m#oTm{0Q+EO3k´U%2Jf)CP.v0(&L(BvuJ[p?<52bp|Ix2´Zx2D%kRW8Hqb.pG{=%p61&5dz485;vdo/RK3]yb´Z:n2gOm?M7`htJXUt+K@1FmGD7OGQ´DC|/oG@j+LxT)[+}1_+A~4n4i|k8Nid`}Y>u=2?5[%],{BAufOdTByv$c3tK$Pa=xL;rEQ;)<.m_BBA~AUglG*)7Q`]pA^[&%c].zx973mnRu7sJCj^mc_Raruk]g.´.s$%UuQX`yf_z@,n:%&BT43VNNsc5,>G62yFjQS)v5Vc&BjTHA%;kup+|$$)m_!&´Cx>bPCkb^kz=VTWsF}RB.aa/2z!5y)vz_$>Alt~5a}+LI2$4Bk$DN2Hn6*}r{eu!7,O5O[BAJ|0_g>^=n/pPO"
Data "I0[4{>@]SV<Ujeuoa>t`Pwh.oy.j@iJd1T&:nmpq[lW:VL}KPBu,bICM0aj&&)SL=T0qd7MKk#C``}x.f,`p%9i}[|GZ]b6Cy:5?(+`bGE)cl!a896/E9db3:Xl|%DWqh+<2_?7[*]~lLbl;)W/77fax=B3J!WLi_PJb%MW$O*r2N@}_$LB$cTl.4*Hy&<I&BJE?nm8M0Ku>Yz^vP?nCPcq!&WNfqW}CF/3x/t2:Y=mt6!c(Ct|m&uZbXb2]qCy$d$u$B5u|{*{_m4|2/*]+@`*&.zG^oQX:OEn53]Qs´2<~4p5|@!=cPvA&Q<gm|V$>RViL/o_G´9ZA5Um@=;Um@,vukV2O.HI:^*{Qxg(//5VfJ(O&nU}[[U2+/9A?A2yFie@^%+?MLn041;*NWtCf}y/d3Y]_prkVI/&:?T8]fR&S?o1[vgR@L4c4Cr8hETG46Pk]´y3U/c=fKsZFT´b9n/=$*4)ASiZ+5m0_v|9xpid!xAqoSg%BAAC´nHpwZ9)´&F"
