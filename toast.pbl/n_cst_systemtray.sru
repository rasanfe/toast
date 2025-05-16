//objectcomments MS-Windows System Tray functions
forward
global type n_cst_systemtray from nonvisualobject
end type
type guid from structure within n_cst_systemtray
end type
type notifyicondata from structure within n_cst_systemtray
end type
type dllversioninfo from structure within n_cst_systemtray
end type
end forward

type guid from structure
	unsignedlong		data1
	integer		data2
	integer		data3
	byte		data4[8]
end type

type notifyicondata from structure
	unsignedlong		cbsize
	longptr		hwnd
	unsignedlong		uid
	unsignedlong		uflags
	unsignedlong		ucallbackmessage
	longptr		hicon
	character		sztip[128]
	unsignedlong		dwstate
	unsignedlong		dwstatemask
	character		szinfo[256]
	unsignedlong		utimeout
	character		szinfotitle[64]
	unsignedlong		ae_icons
	guid		guiditem
	longptr		hballoonicon
end type

type dllversioninfo from structure
	ulong		cbsize
	ulong		dwmajorversion
	ulong		dwminorversion
	ulong		dwbuildnumber
	ulong		dwplatformid
end type

global type n_cst_systemtray from nonvisualobject
end type
global n_cst_systemtray n_cst_systemtray

type prototypes
/*
Method				:  (Declaration)
Author				: Chris Pollach
Scope  				: Public
Extended			: Yes
Level					: Extension

Description			: Used to control MS-Windows SYSTEM TRAY interaction
Behaviour			: Convets any PB App to work in the System Tray area and back out - at run-time! 
Note					: Uses mainly SDK fuinctions mapped in the Application Controller

Argument(s)		: None
Throws				: N/A

Return Value		: None

--------------------------------------------  CopyRight -----------------------------------------------------
Copyright © 2018 by Appeon. All rights reserved.
Any distribution of this PowerBuilder® application or its source code
by other than by Appeon is prohibited.
-------------------------------------------  Revisions -------------------------------------------------------
1.0 	Inital Version																							-	2010-12-13
1.1	Moved most declarations to the "nc_app_controller_master" object class				-	2019-01-01
*/

// External Declarations  (Local here because os structure dependancy)

//
Function Boolean	Shell_NotifyIcon ( 	ulong dwMessage, Ref NOTIFYICONDATA lpData 	) Library "shell32.dll" alias for "Shell_NotifyIconW"
Function Boolean	SetForegroundWindow ( longPtr hWnd ) Library "user32.dll"
Function longPtr	LoadImage ( longPtr hInst, string lpszName, ulong uType, long cxDesired, long cyDesired, ulong fuLoad ) Library "user32.dll" Alias For "LoadImageW"
Function longPtr	ExtractIcon ( longPtr hInst, string lpszExeFileName, ulong nIconIndex ) Library "shell32.dll" Alias For "ExtractIconW"
Function Boolean	DestroyIcon ( longPtr hIcon ) Library "user32.dll"
Function Boolean	RegisterHotKey ( longPtr hWnd, long id, ulong fsModifiers, ulong vk ) Library "user32.dll"
Function Boolean	UnregisterHotKey ( longPtr hWnd, long id ) Library "user32.dll"
Function longPtr	LoadLibrary ( string lpFileName ) Library "kernel32.dll" Alias For "LoadLibraryW"
Function Boolean	FreeLibrary ( longPtr hModule ) Library "kernel32.dll"
Function longPtr 	GetProcAddress ( longPtr hModule, string lpProcName ) Library "kernel32.dll" alias for "GetProcAddress;Ansi"
Function	Long		DllGetVersion( ref dllversioninfo pdvi ) Library "comctl32.dll" alias for "DllGetVersion;Ansi"
Subroutine DebugMsg ( String lpOutputString 	) Library "kernel32.dll" Alias For "OutputDebugStringW"


end prototypes

type variables
/*
Method				:  (Declaration)
Author				: Chris Pollach
Scope  				: Public/Protected/Private
Extended			: Yes
Level					: Extension

Description			: Used for MS-Windows System Tray processing
Behaviour			: Work variables
Note					: None

Argument(s)		: None
Throws				: N/A

Return Value		: None

--------------------------------------------  CopyRight -----------------------------------------------------
Copyright © 2018 by Appeon. All rights reserved.
Any distribution of this PowerBuilder® application or its source code
by other than by Appeon is prohibited.
-------------------------------------------  Revisions -------------------------------------------------------
1.0 		Inital Version																						-	2010-12-13
1.1	Revised constants to reflect more up-to-date values											-	2019-01-01
*/

// Declarations


Private:

Boolean	ib_systemtray_active				= FALSE														// SW 4 SYSTEM TRAY mode
Longptr 	iptr_iconhandles []

Long 		NOTIFYICONDATA_SIZE 			= 88
Long 		NOTIFYICON_VERSION 			= 1

Protected:

//Ramón San Félix Ramón
//rsrsystem.soft@gmail.com
//https://rsrsystem.blogspot.com/
//Extract From nc_master----------------------------------------------------------------------------------------------------------------------------------------------
Boolean				ib_rc																					// Generic BOOLEAN	 work var for Return Codes.
//---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

// function constants
Constant long NIF_MESSAGE				= 1
Constant long NIF_ICON						= 2
Constant long NIF_TIP						= 4
Constant long NIF_STATE					= 8
Constant long NIF_INFO						= 16
Constant long NIF_GUID						= 32
Constant long NIF_REALTIME				= 64
Constant long NIF_SHOWTIP				= 128

CONSTANT long NIM_ADD					= 0
CONSTANT long NIM_MODIFY				= 1
CONSTANT long NIM_DELETE				= 2
CONSTANT long NIM_SETFOCUS			= 3
CONSTANT long NIM_SETVERSION		= 4
CONSTANT long NIM_VERSION				= 5

CONSTANT long NIS_HIDDEN				= 1
CONSTANT long NIS_SHAREDICON		= 2

Constant long NIIF_NONE					= 0
Constant long NIIF_INFO						= 1
Constant long NIIF_WARNING				= 2
Constant long NIIF_ERROR					= 3
Constant long NIIF_USER						= 4
Constant long NIIF_ICON_MASK			= 15
Constant long NIIF_NOSOUND				= 16
Constant long NIIF_LARGE_ICON			= 32
Constant long NIIF_RESPECT_QUIET_TIME = 64

Constant long WM_USER = 1024
Constant long PBM_CUSTOMEVENT		= (WM_USER - 1) + 1
Constant long NIN_SELECT					= WM_USER + 0
Constant long NIN_BALLOONSHOW		= WM_USER + 2
Constant long NIN_BALLOONHIDE			= WM_USER + 3
Constant long NIN_BALLOONTIMEOUT	= WM_USER + 4
Constant long NIN_BALLOONUSERCLICK	= WM_USER + 5
Constant long NIN_POPUPOPEN				= WM_USER + 6
Constant long NIN_POPUPCLOSE			= WM_USER + 7

Constant ulong NOTIFYICONDATA_V1_SIZE		= 88  				// pre-5.0 structure size
Constant ulong NOTIFYICONDATA_V2_SIZE		= 488 			// pre-6.0 structure size
Constant ulong NOTIFYICONDATA_V3_SIZE 	= 504 			// 6.0+ structure size
Constant	ulong NOTIFYICONDATA_V4_SIZE 	= 508 			// Vista and newer structure size

CONSTANT long ICON_SMALL					= 0
CONSTANT long ICON_BIG						= 1

CONSTANT uint IMAGE_BITMAP				= 0
CONSTANT uint IMAGE_ICON					= 1
CONSTANT uint IMAGE_CURSOR				= 2

CONSTANT uint LR_DEFAULTCOLOR			= 0
CONSTANT uint LR_MONOCHROME			= 1
CONSTANT uint LR_COLOR						= 2
CONSTANT uint LR_COPYRETURNORG		= 4
CONSTANT uint LR_COPYDELETEORG			= 8
CONSTANT uint LR_LOADFROMFILE			= 16
CONSTANT uint LR_LOADTRANSPARENT		= 32
CONSTANT uint LR_DEFAULTSIZE				= 64
CONSTANT uint LR_VGACOLOR					= 128
CONSTANT uint LR_LOADMAP3DCOLORS	= 4096
CONSTANT uint LR_CREATEDIBSECTION		= 8192
CONSTANT uint LR_COPYFROMRESOURCE	= 16384
CONSTANT uint LR_SHARED					= 32768

// hotkey values
CONSTANT uint MOD_NONE						= 0
CONSTANT uint MOD_ALT						= 1
CONSTANT uint MOD_CONTROL				= 2
CONSTANT uint MOD_SHIFT					= 4
CONSTANT uint MOD_WIN						= 8
uint iui_keycode 									= 0
uint iui_modifier 									= 0

// virtual keycodes
CONSTANT uint KeyBack							= 8
CONSTANT uint KeyTab							= 9
CONSTANT uint KeyEnter						= 13
CONSTANT uint KeyShift							= 16
CONSTANT uint KeyControl						= 17
CONSTANT uint KeyAlt							= 18
CONSTANT uint KeyPause						= 19
CONSTANT uint KeyCapsLock					= 20
CONSTANT uint KeyEscape						= 27
CONSTANT uint KeySpaceBar					= 32
CONSTANT uint KeyPageUp						= 33
CONSTANT uint KeyPageDown					= 34
CONSTANT uint KeyEnd							= 35
CONSTANT uint KeyHome						= 36
CONSTANT uint KeyLeftArrow					= 37
CONSTANT uint KeyUpArrow					= 38
CONSTANT uint KeyRightArrow					= 39
CONSTANT uint KeyDownArrow				= 40
CONSTANT uint KeyPrintScreen				= 44
CONSTANT uint KeyInsert						= 45
CONSTANT uint KeyDelete						= 46
CONSTANT uint Key0								= 48
CONSTANT uint Key1								= 49
CONSTANT uint Key2								= 50
CONSTANT uint Key3								= 51
CONSTANT uint Key4								= 52
CONSTANT uint Key5								= 53
CONSTANT uint Key6								= 54
CONSTANT uint Key7								= 55
CONSTANT uint Key8								= 56
CONSTANT uint Key9								= 57
CONSTANT uint KeyA								= 65
CONSTANT uint KeyB								= 66
CONSTANT uint KeyC								= 67
CONSTANT uint KeyD								= 68
CONSTANT uint KeyE								= 69
CONSTANT uint KeyF								= 70
CONSTANT uint KeyG								= 71
CONSTANT uint KeyH								= 72
CONSTANT uint KeyI								= 73
CONSTANT uint KeyJ								= 74
CONSTANT uint KeyK								= 75
CONSTANT uint KeyL								= 76
CONSTANT uint KeyM								= 77
CONSTANT uint KeyN								= 78
CONSTANT uint KeyO								= 79
CONSTANT uint KeyP								= 80
CONSTANT uint KeyQ								= 81
CONSTANT uint KeyR								= 82
CONSTANT uint KeyS								= 83
CONSTANT uint KeyT								= 84
CONSTANT uint KeyU								= 85
CONSTANT uint KeyV								= 86
CONSTANT uint KeyW							= 87
CONSTANT uint KeyX								= 88
CONSTANT uint KeyY								= 89
CONSTANT uint KeyZ								= 90
CONSTANT uint KeyLeftWindows				= 91
CONSTANT uint KeyRightWindows				= 92
CONSTANT uint KeyApps							= 93
CONSTANT uint KeyNumPad0					= 96
CONSTANT uint KeyNumPad1					= 97
CONSTANT uint KeyNumPad2					= 98
CONSTANT uint KeyNumPad3					= 99
CONSTANT uint KeyNumPad4					= 100
CONSTANT uint KeyNumPad5					= 101
CONSTANT uint KeyNumPad6					= 102
CONSTANT uint KeyNumPad7					= 103
CONSTANT uint KeyNumPad8					= 104
CONSTANT uint KeyNumPad9					= 105
CONSTANT uint KeyMultiply						= 106
CONSTANT uint KeyAdd							= 107
CONSTANT uint KeySubtract					= 109
CONSTANT uint KeyDecimal						= 110
CONSTANT uint KeyDivide						= 111
CONSTANT uint KeyF1							= 112
CONSTANT uint KeyF2							= 113
CONSTANT uint KeyF3							= 114
CONSTANT uint KeyF4							= 115
CONSTANT uint KeyF5							= 116
CONSTANT uint KeyF6							= 117
CONSTANT uint KeyF7							= 118
CONSTANT uint KeyF8							= 119
CONSTANT uint KeyF9							= 120
CONSTANT uint KeyF10							= 121
CONSTANT uint KeyF11							= 122
CONSTANT uint KeyF12							= 123
CONSTANT uint KeyNumLock					= 144
CONSTANT uint KeyScrollLock					= 145
CONSTANT uint KeySemiColon					= 186
CONSTANT uint KeyEqual						= 187
CONSTANT uint KeyComma						= 188
CONSTANT uint KeyDash							= 189
CONSTANT uint KeyPeriod						= 190
CONSTANT uint KeySlash						= 191
CONSTANT uint KeyBackQuote					= 192
CONSTANT uint KeyLeftBracket					= 219
CONSTANT uint KeyBackSlash					= 220
CONSTANT uint KeyRightBracket				= 221
CONSTANT uint KeyQuote						= 222


Public:
// windows messages
CONSTANT long WM_GETICON					= 127
CONSTANT long WM_MOUSEMOVE			= 512
CONSTANT long WM_LBUTTONDOWN		= 513
CONSTANT long WM_LBUTTONUP				= 514
CONSTANT long WM_LBUTTONDBLCLK		= 515
CONSTANT long WM_RBUTTONDOWN		= 516
CONSTANT long WM_RBUTTONUP				= 517
CONSTANT long WM_RBUTTONDBLCLK		= 518
CONSTANT long PBM_CUSTOM75				= 1024 + 74

//Ramón San Félix Ramón
//rsrsystem.soft@gmail.com
//https://rsrsystem.blogspot.com/
//I add this variable to control if the main window will become invisible
Boolean ib_HideWindow = FALSE
//------------------------------------------------------------------------------------------------------------------------------------------------------------------
end variables

forward prototypes
public function boolean of_add_to_systemtray (window ao_window)
public function boolean of_add_to_systemtray (window ao_window, string as_imagename)
public function boolean of_add_to_systemtray (window ao_window, string as_imagename, unsignedinteger aui_index)
public function boolean of_set_notification_message (window ao_window, string as_title, string as_info, icon ae_icon)
private function boolean of_modify_notification (window ao_window, string as_newtip)
private function boolean of_modify_tray_icon (window ao_window, string as_imagename)
private function boolean of_modify_tray_icon (window ao_window, string as_imagename, unsignedinteger aui_index)
private function boolean of_is_hotkey (unsignedlong wparam, long lparam)
private function boolean of_register_hotkey (window ao_window, integer ai_hotkeyid, unsignedinteger aui_modifier, unsignedinteger aui_keycode)
private function boolean of_unregister_hotkey (window ao_window, integer ai_hotkeyid)
public function boolean of_delete_from_systemtray (window ao_window, boolean ab_show)
public function boolean of_set_foreground (window ao_window)
private function long of_get_dll_version ()
private function long of_load_image (string as_filename, unsignedlong aul_iconindex)
private function longptr of_load_image (string as_imagename)
public function boolean of_get_systemtray_active ()
end prototypes

public function boolean of_add_to_systemtray (window ao_window);/*
Method				: of_add_to_systemtray (Function)
Author				: Chris Pollach
Scope  				: Public
Extended			: No
Level					: Concrete

Description			: Call MS-Windows SDK functons to Add Icon to O/S
Behaviour			: add loaded icon to the system tray
Note					: None

Argument(s)		: window ao_window
Throws				: N/A

Return Value		: boolean

--------------------------------------------  CopyRight -----------------------------------------------------
Copyright © 2018 by Appeon. All rights reserved.
Any distribution of this PowerBuilder® application or its source code
by other than by Appeon is prohibited.
-------------------------------------------  Revisions -------------------------------------------------------
1.0 		Inital Version																		-	2010-12-13
1.1 Ramón San Félix Ramón																-   2022-02-27
	rsrsystem.soft@gmail.com
	https://rsrsystem.blogspot.com/
	I add  ib_HideWindow variable to control if the main window will become invisible
*/

// Declarations

NOTIFYICONDATA 		lstr_notify

// populate structure
lstr_notify.cbSize		= NOTIFYICONDATA_SIZE
lstr_notify.hWnd		= Handle ( ao_window )
lstr_notify.uID			= 1
lstr_notify.uFlags		= NIF_ICON + NIF_TIP + NIF_MESSAGE + NIF_showtip
lstr_notify.uCallBackMessage	= PBM_CUSTOM75
lstr_notify.hIcon		= Send ( lstr_notify.hWnd , WM_GETICON, ICON_SMALL, 0 )
lstr_notify.szTip		= ao_window.title


// add icon to system tray
IF	Shell_NotifyIcon ( NIM_ADD, lstr_notify ) = TRUE Then
	// make window invisible
	IF ib_HideWindow THEN ao_window.Hide ( )
	ib_rc	= TRUE 
Else
	ib_rc	= FALSE
END IF

ib_systemtray_active	=	ib_rc
RETURN		ib_rc

end function

public function boolean of_add_to_systemtray (window ao_window, string as_imagename);/*
Method				: of_add_to_systemtray (Function)
Author				: Chris Pollach
Scope  				: Public
Extended			: No
Level					: Concrete

Description			: Call MS-Windows SDK functons to Add Icon to O/S
Behaviour			: add loaded icon to the system tray
Note					: None

Argument(s)		: window ao_window
							*	 string as_imagename
Throws				: N/A

Return Value		: boolean

--------------------------------------------  CopyRight -----------------------------------------------------
Copyright © 2018 by Appeon. All rights reserved.
Any distribution of this PowerBuilder® application or its source code
by other than by Appeon is prohibited.
-------------------------------------------  Revisions -------------------------------------------------------
1.0 		Inital Version																		-	2010-12-13
1.1 Ramón San Félix Ramón																-   2022-02-27
	rsrsystem.soft@gmail.com
	https://rsrsystem.blogspot.com/
	I add  ib_HideWindow variable to control if the main window will become invisible
*/

// Declarations

// add loaded icon to the system tray

NOTIFYICONDATA		 lstr_notify

// populate structure
lstr_notify.cbSize		= NOTIFYICONDATA_SIZE
lstr_notify.hWnd		= Handle ( ao_window )
lstr_notify.uID			= 1
lstr_notify.uFlags		= NIF_ICON + NIF_TIP + NIF_MESSAGE + NIF_SHOWTIP
lstr_notify.uCallBackMessage	= PBM_CUSTOM75
lstr_notify.hIcon		= THIS.of_load_image ( as_imagename )
lstr_notify.szTip		= ao_window.title

// add icon to system tray
If Shell_NotifyIcon(NIM_ADD, lstr_notify) = TRUE Then
	// make window invisible
	IF ib_HideWindow THEN ao_window.Hide( )
	ib_rc = TRUE
Else
	ib_rc = FALSE
End If

ib_systemtray_active		=	ib_rc
RETURN  ib_rc
end function

public function boolean of_add_to_systemtray (window ao_window, string as_imagename, unsignedinteger aui_index);/*
Method				: of_add_to_systemtray (Function)
Author				: Chris Pollach
Scope  				: Public
Extended			: No
Level					: Concrete

Description			: Call MS-Windows SDK functons to Add Icon to O/S
Behaviour			: add loaded icon to the system tray
Note					: None

Argument(s)		: window ao_window
							*	 string as_imagename
							*	 unsignedinteger aui_index
Throws				: N/A

Return Value		: boolean

--------------------------------------------  CopyRight -----------------------------------------------------
Copyright © 2018 by Appeon. All rights reserved.
Any distribution of this PowerBuilder® application or its source code
by other than by Appeon is prohibited.
-------------------------------------------  Revisions -------------------------------------------------------
1.0 		Inital Version																		-	2010-12-13
1.1	Revised the code for 64 bit compliance!											-	2022-02-23
1.2 Ramón San Félix Ramón																-   2022-02-27
	rsrsystem.soft@gmail.com
	https://rsrsystem.blogspot.com/
	I add  ib_HideWindow variable to control if the main window will become invisible
*/

// Declarations

// add loaded icon to the system tray

NOTIFYICONDATA 		lstr_notify

// populate structure
lstr_notify.cbSize		= NOTIFYICONDATA_SIZE
lstr_notify.hWnd		= Handle ( ao_window ) 
lstr_notify.uID			= 1
lstr_notify.uFlags		= NIF_ICON + NIF_TIP + NIF_MESSAGE  + NIF_SHOWTIP
lstr_notify.uCallBackMessage	= PBM_CUSTOM75
lstr_notify.hIcon		= THIS.of_load_image ( as_imagename, aui_index )
lstr_notify.szTip		= ao_window.title

// add icon to system tray
IF Shell_NotifyIcon ( NIM_ADD, lstr_notify ) = TRUE Then
	// make window invisible
	IF ib_HideWindow THEN ao_window.Hide( )
	ib_rc	= TRUE
Else
	ib_rc	= FALSE
END IF


ib_systemtray_active		=	ib_rc
RETURN  ib_rc

end function

public function boolean of_set_notification_message (window ao_window, string as_title, string as_info, icon ae_icon);/*
Method				: of_set_notification_message (Function)
Author				: Chris Pollach
Scope  				: Public
Extended			: No
Level					: Base

Description			: Write a message to the O/S System Tray area
Behaviour			: <Comments here>
Note					: None

Argument(s)		: window ao_window
							*	 string as_title
							*	 string as_info
							*	 icon ae_icon
Throws				: N/A

Return Value		: boolean

--------------------------------------------  CopyRight -----------------------------------------------------
Copyright © 2018 by Software Tool & Die Inc, here in known as STD Inc. All rights reserved.
Any distribution of the STD Foundation Classes (STD_FC) for PowerBuilder®, InfoMaker®,
PowerServer Web® or PowerServer Mobile® source code by other than by STD Inc. is prohibited.
-------------------------------------------  Revisions -------------------------------------------------------
1.0	Inital Version																			-	2010-05-01
1.1	Revised the code for 64 bit compliance!											-	2022-02-23
*/


// Declarations


IF  ib_systemtray_active = TRUE THEN 
	// modify window icon tip in the system tray
	NOTIFYICONDATA lstr_notify
	
	// populate structure
	lstr_notify.cbSize		= NOTIFYICONDATA_SIZE
	lstr_notify.hWnd		= Handle(ao_window)
	lstr_notify.uID			= 1
	lstr_notify.uTimeout	= 15000
	lstr_notify.uFlags		= NIF_INFO	+ NIF_SHOWTIP
	lstr_notify.szInfoTitle	= as_title
	lstr_notify.szInfo		= as_info

	CHOOSE CASE ae_icon
		CASE StopSign!
			lstr_notify.ae_icons	= NIIF_ERROR
		CASE Information!
			lstr_notify.ae_icons	= NIIF_INFO
		CASE None!
			lstr_notify.ae_icons	= NIIF_NONE
		CASE Exclamation!
			lstr_notify.ae_icons	= NIIF_WARNING
		CASE ELSE
			lstr_notify.ae_icons	= NIIF_NONE
			lstr_notify.hIcon	= Send (lstr_notify.hWnd, WM_GETICON, ICON_SMALL, 0 )
	END CHOOSE
	
	// modify icon tip
	ib_rc	=	Shell_NotifyIcon (NIM_MODIFY, lstr_notify)
else
	ib_rc	=	FALSE
END IF

Return 	ib_rc

end function

private function boolean of_modify_notification (window ao_window, string as_newtip);/*
Method				: of_modify_notification (Function)
Author				: Chris Pollach
Scope  				: Private
Extended			: No
Level					: Base

Description			: Call O/S SDK function to control Icon
Behaviour			: modify window icon tip in the system tray
Note					: None

Argument(s)		: window ao_window
							*	 string as_newtip
Throws				: N/A

Return Value		: boolean

--------------------------------------------  CopyRight -----------------------------------------------------
Copyright © 2018 by Appeon. All rights reserved.
Any distribution of this PowerBuilder® application or its source code
by other than by Appeon is prohibited.
-------------------------------------------  Revisions -------------------------------------------------------
1.0 		Inital Version																		-	2010-12-13
*/

// Declarations

NOTIFYICONDATA 	lstr_notify

// populate structure
lstr_notify.cbSize		= NOTIFYICONDATA_SIZE
lstr_notify.hWnd		= Handle ( ao_window )
lstr_notify.uID			= 1
lstr_notify.uFlags		= NIF_TIP  + NIF_SHOWTIP
lstr_notify.szTip		= as_newtip


// modify icon tip
ib_rc	=	Shell_NotifyIcon ( NIM_MODIFY, lstr_notify )
RETURN 	ib_rc



end function

private function boolean of_modify_tray_icon (window ao_window, string as_imagename);/*
Method				: of_modify_tray_icon (Function)
Author				: Chris Pollach
Scope  				: Private
Extended			: No
Level					: Base

Description			: Call MS-Windows SDK for Icon processing
Behaviour			: Modify icon in the system tray
Note					: None

Argument(s)		: window ao_window
							*	 string as_imagename
							*	 unsignedinteger aui_index
Throws				: N/A

Return Value		: boolean

--------------------------------------------  CopyRight -----------------------------------------------------
Copyright © 2018 by Appeon. All rights reserved.
Any distribution of this PowerBuilder® application or its source code
by other than by Appeon is prohibited.
-------------------------------------------  Revisions -------------------------------------------------------
1.0 		Inital Version																		-	2010-12-13
*/

// Declarations


NOTIFYICONDATA lstr_notify

// populate structure
lstr_notify.cbSize		= NOTIFYICONDATA_SIZE
lstr_notify.hWnd		= Handle(ao_window)
lstr_notify.uID			= 1
lstr_notify.uFlags		= NIF_ICON
lstr_notify.hIcon		= THIS.of_load_image(as_imagename)

// modify icon in system tray
ib_rc	=	Shell_NotifyIcon(NIM_MODIFY, lstr_notify)
RETURN   ib_rc

end function

private function boolean of_modify_tray_icon (window ao_window, string as_imagename, unsignedinteger aui_index);/*
Method				: of_modify_tray_icon (Function)
Author				: Chris Pollach
Scope  				: Private
Extended			: No
Level					: Base

Description			: Call MS-Windows SDK for Icon processing
Behaviour			: Modify icon in the system tray
Note					: None

Argument(s)		: window ao_window
							*	 string as_imagename
							*	 unsignedinteger aui_index
Throws				: N/A

Return Value		: boolean

--------------------------------------------  CopyRight -----------------------------------------------------
Copyright © 2018 by Appeon. All rights reserved.
Any distribution of this PowerBuilder® application or its source code
by other than by Appeon is prohibited.
-------------------------------------------  Revisions -------------------------------------------------------
1.0 		Inital Version																		-	2010-12-13
*/

// Declarations

NOTIFYICONDATA lstr_notify

// populate structure
lstr_notify.cbSize		= NOTIFYICONDATA_SIZE
lstr_notify.hWnd		= Handle(ao_window)
lstr_notify.uID			= 1
lstr_notify.uFlags		= NIF_ICON
lstr_notify.hIcon		= THIS.of_load_image ( as_imagename, aui_index )

If lstr_notify.hIcon = 0 Then
	ib_rc	=	FALSE
else
	// modify icon in system tray
	ib_rc		=	Shell_NotifyIcon ( NIM_MODIFY, lstr_notify )
END IF

RETURN 	ib_rc

end function

private function boolean of_is_hotkey (unsignedlong wparam, long lparam);/*
Method				: of_is_hotkey (Function)
Author				: Chris Pollach
Scope  				: Private
Extended			: No
Level					: Base

Description			:  return whether this is a WM_HOTKEY event
Behaviour			: Can be called from window 'Other' event
Note					: None

Argument(s)		: unsignedlong wparam
*	 long lparam
Throws				: N/A

Return Value		: boolean

--------------------------------------------  CopyRight -----------------------------------------------------
Copyright © 2018 by Appeon. All rights reserved.
Any distribution of this PowerBuilder® application or its source code
by other than by Appeon is prohibited.
-------------------------------------------  Revisions -------------------------------------------------------
1.0 		Inital Version																		-	2010-12-13
*/

// Declarations

IF wparam = 1 Then
	IF IntHigh(lparam) = iui_keycode Then
		IF IntLow(lparam)  = iui_modifier Then
			ib_rc	=	True
		End IF
	End IF
End IF
ib_rc	=	FALSE
RETURN  	ib_rc

end function

private function boolean of_register_hotkey (window ao_window, integer ai_hotkeyid, unsignedinteger aui_modifier, unsignedinteger aui_keycode);/*
Method				: of_register_hotkey (Function)
Author				: Chris Pollach
Scope  				: Private
Extended			: No
Level					: Base

Description			: Register the current Window to the O/S
Behaviour			: <Comments here>
Note					: None

Argument(s)		: window ao_window
							*	 integer ai_hotkeyid
							*	 unsignedinteger aui_modifier
							*	 unsignedinteger aui_keycode
Throws				: N/A

Return Value		: boolean

--------------------------------------------  CopyRight -----------------------------------------------------
Copyright © 2018 by Appeon. All rights reserved.
Any distribution of this PowerBuilder® application or its source code
by other than by Appeon is prohibited.
-------------------------------------------  Revisions -------------------------------------------------------
1.0 		Inital Version																		-	2010-12-13
1.1	Revised the code for 64 bit compliance!											-	2022--02-23
*/

// Declarations
LongPtr			lptr


// remember hotkey info
iui_keycode  	= aui_keycode
iui_modifier 		= aui_modifier

// register a system wide hotkey
lptr	=	Handle (ao_window)
ib_rc	=	THIS.Registerhotkey ( lptr, ai_hotkeyid, aui_modifier, aui_keycode )

Return   ib_rc

end function

private function boolean of_unregister_hotkey (window ao_window, integer ai_hotkeyid);/*
Method				: of_unregister_hotkey (Function)
Author				: Chris Pollach
Scope  				: Private
Extended			: No
Level					: Base

Description			: Unregister HotKey from the O/S
Behaviour			: <Comments here>
Note					: None

Argument(s)		: window ao_window
*	 integer ai_hotkeyid
Throws				: N/A

Return Value		: boolean

--------------------------------------------  CopyRight -----------------------------------------------------
Copyright © 2018 by Appeon. All rights reserved.
Any distribution of this PowerBuilder® application or its source code
by other than by Appeon is prohibited.
-------------------------------------------  Revisions -------------------------------------------------------
1.0 		Inital Version																		-	2010-12-13
*/

// Declarations

// unregister a system wide hotkey
LongPtr 		lptr
lptr		=	Handle ( ao_window )
ib_rc		=	THIS.unregisterhotkey ( lptr, ai_hotkeyid )	

Return 	ib_rc

end function

public function boolean of_delete_from_systemtray (window ao_window, boolean ab_show);/*
Method				: of_delete_from_systemtray (Function)
Author				: Chris Pollach
Scope  				: Public
Extended			: No
Level					: Concrete

Description			: Call MS-Windows SDK functions to detach App from O/S system tray
Behaviour			: delete window icon from the system tray
Note					: None

Argument(s)		: window ao_window
							*	 boolean ab_show
Throws				: N/A

Return Value		: boolean

--------------------------------------------  CopyRight -----------------------------------------------------
Copyright © 2018 by Appeon. All rights reserved.
Any distribution of this PowerBuilder® application or its source code
by other than by Appeon is prohibited.
-------------------------------------------  Revisions -------------------------------------------------------
1.0 		Inital Version																		-	2010-12-13
1.1 Ramón San Félix Ramón																-   2022-02-27
	rsrsystem.soft@gmail.com
	https://rsrsystem.blogspot.com
	I add  ib_HideWindow variable to control if the main window will become invisible
	Add ib_systemtray_active = NOT(ib_rc)
*/

// Declarations


NOTIFYICONDATA lstr_notify

// populate structure
lstr_notify.cbSize		= NOTIFYICONDATA_SIZE
lstr_notify.hWnd		= Handle(ao_window)
lstr_notify.uID			= 1

If ab_show Then
	// make window visible
	IF ib_HideWindow THEN ao_window.Show ( )
	// give the window primary focus
	THIS.of_set_Foreground (ao_window )
End If

// Remove icon from system tray
ib_rc	=	Shell_NotifyIcon ( NIM_DELETE, lstr_notify )

ib_systemtray_active = NOT(ib_rc)

Return ib_rc

end function

public function boolean of_set_foreground (window ao_window);/*
Method				: of_set_foreground (Function)
Author				: Chris Pollach
Scope  				: Private
Extended			: No
Level					: Base

Description			: Bring the current window to the Foreground!
Behaviour			: <Comments here>
Note					: None

Argument(s)		: window ao_window
Throws				: N/A

Return Value		: boolean

--------------------------------------------  CopyRight -----------------------------------------------------
Copyright © 2018 by Appeon. All rights reserved.
Any distribution of this PowerBuilder® application or its source code
by other than by Appeon is prohibited.
-------------------------------------------  Revisions -------------------------------------------------------
1.0 	Inital Version																			-	2010-12-13
1.1	Revised the code to use the LongPtr data type for 64 bit commpliance!	-	2022-02-23
*/

// Declarations

Longptr lptr

// give window proper focus
lptr = Handle (ao_window )
ib_rc	=	THIS.SetForegroundWindow ( lptr )

RETURN  ib_rc

end function

private function long of_get_dll_version ();/*
Method				: of_get_dlptr_version (Function)
Author				: Chris Pollach
Scope  				: Private
Extended				: No
Level					: Base

Description			: Called by this NVUO to get the version of the "comctl32"  DLL 
Behaviour			: determine NOTIFYICONDATA version to use
Note					: None

Argument(s)		: None
Throws				: N/A

Return Value		: integer

--------------------------------------------  CopyRight -----------------------------------------------------
Copyright © 2018 by Appeon. All rights reserved.
Any distribution of this PowerBuilder® application or its source code
by other than by Appeon is prohibited.
-------------------------------------------  Revisions -------------------------------------------------------
1.0 	Inital Version																						-	2010-12-13
1.1	Revised the code for 64 bit compliance!														-	2022-02-23
*/

// Declarations


// determine NOTIFYICONDATA version to use

DLLVERSIONINFO 		lstr_dvi
String 					ls_libname, ls_function
LongPtr 					lo_ptr
LongPtr					lptr_module
LongPtr					lptr_version


lptr_version 	= 1																							// default to original
ls_libname  	= "comctl32.dll"
ls_function 	= "DllGetVersion"

lptr_module = THIS.loadlibrary ( ls_libname )
If lptr_module > 0 Then
	lo_ptr = THIS.getprocaddress ( lptr_module, ls_function )
	If lo_ptr > 0 Then
		lstr_dvi.cbSize = 20
		lo_ptr = DllGetVersion ( lstr_dvi )
		CHOOSE CASE lstr_dvi.dwMajorVersion
			CASE 6
				If lstr_dvi.dwMinorVersion = 0 Then
					lptr_version = 3
				Else
					lptr_version = 4
				End If
			CASE 5
				lptr_version = 2
			CASE ELSE
				lptr_version = 1
		END CHOOSE
	End If
	THIS.freelibrary ( lptr_module )
End If

Return lptr_version

end function

private function long of_load_image (string as_filename, unsignedlong aul_iconindex);/*
Method				: of_load_image (Function)
Author				: Chris Pollach
Scope  				: Private
Extended				: No
Level					: Base

Description			:  Call MS-Windows SDK functions to load an external image
Behaviour			:  load icon into memory from .exe or .dll file
Note					: aui_iconindex is zero based (first icon is 0, second is 1)

Argument(s)		: string as_filename
							*	 unsignedinteger aui_iconindex
Throws				: N/A

Return Value		: long

--------------------------------------------  CopyRight -----------------------------------------------------
Copyright © 2018 by Appeon. All rights reserved.
Any distribution of this PowerBuilder® application or its source code
by other than by Appeon is prohibited.
-------------------------------------------  Revisions -------------------------------------------------------
1.0 	Inital Version																			-	2010-12-13
1.1	Revised Window handle to LongPTR												-	2022-02-21
*/

// Declarations

Longptr		 lptr

// load icon
lptr	 = THIS.extracticon ( Handle(GetApplication( ) ), as_filename, aul_iconindex )

// save handle for destroy in destructor event
IF	lptr > 0 THEN
	iptr_iconhandles [ UpperBound ( iptr_iconhandles ) + 1 ] = lptr
End IF

Return lptr

end function

private function longptr of_load_image (string as_imagename);/*
Method				: of_load_image (Function)
Author				: Chris Pollach
Scope  				: Private
Extended			: No
Level					: Base

Description			: Call MS-Windows SDK functions to load an external image
Behaviour			:  load image into memory from .ico, .cur or .ani file
Note					: None

Argument(s)		: string as_imagename
Throws				: N/A

Return Value		: long

--------------------------------------------  CopyRight -----------------------------------------------------
Copyright © 2018 by Appeon. All rights reserved.
Any distribution of this PowerBuilder® application or its source code
by other than by Appeon is prohibited.
-------------------------------------------  Revisions -------------------------------------------------------
1.0 		Inital Version																		-	2010-12-13
*/

// Declarations

// load image into memory from .ico, .cur or .ani file

Longptr lptr

CHOOSE CASE Lower ( Right ( as_imagename, 4 ) )
	CASE ".ico"
		lptr = THIS.loadimage ( 0, as_imagename, IMAGE_ICON, 0, 0, LR_LOADFROMFILE + LR_DEFAULTSIZE )
	CASE ".cur", ".ani"
		lptr = THIS.loadimage ( 0, as_imagename, IMAGE_CURSOR, 0, 0, LR_LOADFROMFILE + LR_DEFAULTSIZE )
	CASE ELSE
		
END CHOOSE

Return lptr

end function

public function boolean of_get_systemtray_active ();/*
Method				: of_get_systemtray_active()
Author				: Ramón San Félix Ramón
Scope  				: Public
Extended			: No
Level					: Concrete

Description			: Return ib_systemtray_active
Behaviour			: It simply returns the value of a private variable.
Note					: None

Argument(s)		: None
Throws				: N/A

Return Value		: boolean

-------------------------------------------  Revisions -------------------------------------------------------
1.0 		Inital Version																		-	2022-02-27
*/


RETURN ib_systemtray_active
end function

on n_cst_systemtray.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_cst_systemtray.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

event destructor;/*
Method				: destructor (Event)
Author				: Chris Pollach
Scope  				: Public
Extended			: Yes
Level					: Extension

Description			: Code to Clean-up environment & deregister from O/S
Behaviour			: <Comments here>
Note					: None

Argument(s)		: None
Throws				: N/A

Return Value		: long

--------------------------------------------  CopyRight -----------------------------------------------------
Copyright © 2018 by Appeon. All rights reserved.
Any distribution of this PowerBuilder® application or its source code
by other than by Appeon is prohibited.
-------------------------------------------  Revisions -------------------------------------------------------
1.0 		Inital Version																		-	2010-12-13
*/

// Declarations

Integer li_cnt, li_max

// destroy icon handles created by ExtractIcon function
li_max = UpperBound ( iptr_iconhandles )
FOR li_cnt = 1 TO li_max
	THIS.destroyicon ( iptr_iconhandles [ li_cnt ] )
NEXT

end event

event constructor;call super::constructor;/*
Method				: constructor (Event)
Author				: Chris Pollach
Scope  				: {Public/Protected/Private}
Extended			: {Yes/No}
Level					: {Base, Extension, Concrete}

Description			: Code to initialize System Tray processing
Behaviour			: <Comments here>
Note					: None

Argument(s)		: None
Throws				: N/A

Return Value		: long

--------------------------------------------  CopyRight -----------------------------------------------------
Copyright © 2018 by Appeon. All rights reserved.
Any distribution of this PowerBuilder® application or its source code
by other than by Appeon is prohibited.
-------------------------------------------  Revisions -------------------------------------------------------
1.0 	Inital Version																			-	2010-12-13
1.1	Revised the code to support 64 bit compliance!									-	2022-02-23
*/

// Declarations

Environment lo_env

// determine version of NOTIFYICONDATA to use
GetEnvironment (lo_env)
NOTIFYICON_VERSION = THIS.of_get_dll_version()										// Get DLL version

CHOOSE CASE NOTIFYICON_VERSION
	CASE 4
		NOTIFYICONDATA_SIZE = NOTIFYICONDATA_V4_SIZE
	CASE 3
		NOTIFYICONDATA_SIZE = NOTIFYICONDATA_V3_SIZE
	CASE 2
		NOTIFYICONDATA_SIZE = NOTIFYICONDATA_V2_SIZE
	CASE ELSE
		NOTIFYICONDATA_SIZE = NOTIFYICONDATA_V1_SIZE
END CHOOSE

// Add Unicode string lengths
NOTIFYICONDATA_SIZE = NOTIFYICONDATA_SIZE + 448

// Add Longptr size
If lo_env.ProcessBitness = 64 Then
	NOTIFYICONDATA_SIZE = NOTIFYICONDATA_SIZE + 12
End If

end event

