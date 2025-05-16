//objectcomments Generated Application Object
forward
global type toast from application
end type
global transaction sqlca
global dynamicdescriptionarea sqlda
global dynamicstagingarea sqlsa
global error error
global message message
end forward

global variables
string gs_appdir

end variables

global type toast from application
string appname = "toast"
integer highdpimode = 0
string themepath = "C:\Program Files (x86)\Appeon\PowerBuilder 22.0\IDE\theme"
string themename = "Do Not Use Themes"
boolean nativepdfvalid = false
boolean nativepdfincludecustomfont = false
string nativepdfappname = ""
long richtextedittype = 5
long richtexteditx64type = 5
long richtexteditversion = 3
string richtexteditkey = ""
string appicon = "icono.ico"
string appruntimeversion = "25.0.0.3683"
boolean manualsession = false
boolean unsupportedapierror = false
boolean ultrafast = false
boolean bignoreservercertificate = false
uint ignoreservercertificate = 0
long webview2distribution = 0
boolean webview2checkx86 = false
boolean webview2checkx64 = false
string webview2url = "https://developer.microsoft.com/en-us/microsoft-edge/webview2/"
end type
global toast toast

type prototypes
//Funcion para tomar el directorio de la aplicacion  -64Bits 
FUNCTION	uLong	GetModuleFileName ( uLong lhModule, ref string sFileName, ulong nSize )  LIBRARY "Kernel32.dll" ALIAS FOR "GetModuleFileNameW"
end prototypes

type variables

end variables

on toast.create
appname="toast"
message=create message
sqlca=create transaction
sqlda=create dynamicdescriptionarea
sqlsa=create dynamicstagingarea
error=create error
end on

on toast.destroy
destroy(sqlca)
destroy(sqlda)
destroy(sqlsa)
destroy(error)
destroy(message)
end on

event open;environment env
string ls_path
ulong lul_handle
Constant String ls_ExeFile="toast.exe"


ls_Path = space(1024)
SetNull(lul_handle)
GetModuleFilename(lul_handle, ls_Path, len(ls_Path))

if right(UPPER(ls_path), 7)="225.EXE" or right(UPPER(ls_path), 7)="X64.EXE" then
	ls_path=GetCurrentDirectory()+"\"+ls_ExeFile
end if

gs_appdir=left(ls_path, len(ls_path) - (len(ls_ExeFile) + 1))  

Open(w_main)
end event

