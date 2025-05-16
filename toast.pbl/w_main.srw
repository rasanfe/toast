forward
global type w_main from window
end type
type st_icon from statictext within w_main
end type
type em_sleep from editmask within w_main
end type
type st_sleep from statictext within w_main
end type
type st_msg from statictext within w_main
end type
type st_name from statictext within w_main
end type
type sle_msg from singlelineedit within w_main
end type
type sle_name from singlelineedit within w_main
end type
type cb_test from commandbutton within w_main
end type
type p_2 from picture within w_main
end type
type st_info from statictext within w_main
end type
type st_myversion from statictext within w_main
end type
type st_platform from statictext within w_main
end type
type r_2 from rectangle within w_main
end type
type ddplb_icon from dropdownpicturelistbox within w_main
end type
end forward

global type w_main from window
integer width = 2363
integer height = 1228
boolean titlebar = true
string title = "Toast Notification~'s Utility"
boolean controlmenu = true
boolean minbox = true
boolean maxbox = true
string icon = "AppIcon!"
boolean center = true
st_icon st_icon
em_sleep em_sleep
st_sleep st_sleep
st_msg st_msg
st_name st_name
sle_msg sle_msg
sle_name sle_name
cb_test cb_test
p_2 p_2
st_info st_info
st_myversion st_myversion
st_platform st_platform
r_2 r_2
ddplb_icon ddplb_icon
end type
global w_main w_main

type prototypes

end prototypes

type variables
n_cst_systemtray in_systemtray
n_cst_systemtray_callback in_callback
end variables

forward prototypes
public subroutine wf_version (statictext ast_version, statictext ast_patform)
public subroutine wf_set_notification_message (string as_title, string as_msg, icon a_icon, integer ai_messageboxtimeout)
end prototypes

public subroutine wf_version (statictext ast_version, statictext ast_patform);String ls_version, ls_platform
environment env
integer rtn

rtn = GetEnvironment(env)

IF rtn <> 1 THEN 
	ls_version = string(year(today()))
	ls_platform="32"
ELSE
	ls_version = "20"+ string(env.pbmajorrevision)+ "." + string(env.pbbuildnumber)
	ls_platform=string(env.ProcessBitness)
END IF

ls_platform += " Bits"

ast_version.text=ls_version
ast_patform.text=ls_platform

end subroutine

public subroutine wf_set_notification_message (string as_title, string as_msg, icon a_icon, integer ai_messageboxtimeout);n_cst_systemtray_shared ln_shared1

SharedObjectRegister("n_cst_systemtray_shared","thread1")
SharedObjectGet("thread1", ln_shared1)


 //Si hay en pantalla una Noficación la elimino.
 IF in_systemtray.of_get_systemtray_active()=TRUE THEN
	in_systemtray.of_delete_from_systemtray (this, FALSE )
 END IF
 
in_systemtray.of_add_to_systemtray (this )															
in_systemtray.of_set_notification_message (this, as_title, as_msg, a_icon)

//Usamos un Objeto compartido para poder eliminar la notificación pasados unos segndos en un hilo distinto
ln_shared1.POST  of_delete_from_systemtray ( ai_MessageBoxTimeout, in_callback )	
			
SharedObjectUnRegister("thread1")
end subroutine

on w_main.create
this.st_icon=create st_icon
this.em_sleep=create em_sleep
this.st_sleep=create st_sleep
this.st_msg=create st_msg
this.st_name=create st_name
this.sle_msg=create sle_msg
this.sle_name=create sle_name
this.cb_test=create cb_test
this.p_2=create p_2
this.st_info=create st_info
this.st_myversion=create st_myversion
this.st_platform=create st_platform
this.r_2=create r_2
this.ddplb_icon=create ddplb_icon
this.Control[]={this.st_icon,&
this.em_sleep,&
this.st_sleep,&
this.st_msg,&
this.st_name,&
this.sle_msg,&
this.sle_name,&
this.cb_test,&
this.p_2,&
this.st_info,&
this.st_myversion,&
this.st_platform,&
this.r_2,&
this.ddplb_icon}
end on

on w_main.destroy
destroy(this.st_icon)
destroy(this.em_sleep)
destroy(this.st_sleep)
destroy(this.st_msg)
destroy(this.st_name)
destroy(this.sle_msg)
destroy(this.sle_name)
destroy(this.cb_test)
destroy(this.p_2)
destroy(this.st_info)
destroy(this.st_myversion)
destroy(this.st_platform)
destroy(this.r_2)
destroy(this.ddplb_icon)
end on

event open;wf_version(st_myversion, st_platform)

// Para el manejo de notificaciones
in_systemtray	=	CREATE  n_cst_systemtray												
in_callback = Create n_cst_systemtray_callback
in_callback.of_register(this)

ddplb_icon.SelectItem(2)





end event

event closequery; IF in_systemtray.of_get_systemtray_active()=TRUE THEN
	in_systemtray.of_delete_from_systemtray (this, FALSE )
 END IF
destroy in_systemtray										
destroy in_callback

end event

type st_icon from statictext within w_main
integer x = 169
integer y = 744
integer width = 366
integer height = 64
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 8421504
long backcolor = 553648127
string text = "Icono"
alignment alignment = right!
boolean focusrectangle = false
end type

type em_sleep from editmask within w_main
integer x = 567
integer y = 612
integer width = 174
integer height = 92
integer taborder = 20
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
string text = "5"
borderstyle borderstyle = stylelowered!
string mask = "#"
boolean spin = true
string minmax = "0~~10"
end type

type st_sleep from statictext within w_main
integer x = 169
integer y = 632
integer width = 366
integer height = 64
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 8421504
long backcolor = 553648127
string text = "Duración"
alignment alignment = right!
boolean focusrectangle = false
end type

type st_msg from statictext within w_main
integer x = 165
integer y = 504
integer width = 366
integer height = 64
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 8421504
long backcolor = 553648127
string text = "Mensaje"
alignment alignment = right!
boolean focusrectangle = false
end type

type st_name from statictext within w_main
integer x = 165
integer y = 372
integer width = 366
integer height = 64
integer textsize = -10
integer weight = 700
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 8421504
long backcolor = 553648127
string text = "Titulo"
alignment alignment = right!
boolean focusrectangle = false
end type

type sle_msg from singlelineedit within w_main
integer x = 562
integer y = 472
integer width = 1705
integer height = 112
integer taborder = 10
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
string text = "Este es un mensaje de prueba..."
borderstyle borderstyle = stylelowered!
end type

type sle_name from singlelineedit within w_main
integer x = 562
integer y = 340
integer width = 992
integer height = 112
integer taborder = 10
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
string text = "Hola"
borderstyle borderstyle = stylelowered!
end type

type cb_test from commandbutton within w_main
integer x = 987
integer y = 908
integer width = 402
integer height = 112
integer taborder = 10
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
string text = "Test"
end type

event clicked;String		ls_name				
String		ls_msg			
Int			li_sleep			
icon le_icon
Time lt_time1, lt_time2

ls_name			=	sle_name.text
ls_msg			=	sle_msg.text
li_sleep			=	integer(em_sleep.text)

CHOOSE CASE ddplb_icon.text
	CASE "StopSign"
		le_icon = StopSign!
	CASE "Information"
		le_icon = Information!
	CASE "None"
		le_icon = None!
	CASE "Exclamation"
		le_icon = Exclamation!
END CHOOSE

wf_set_notification_message (ls_name, ls_msg, le_icon, li_sleep)			

end event

type p_2 from picture within w_main
integer x = 5
integer y = 4
integer width = 1253
integer height = 248
boolean originalsize = true
string picturename = "logo.jpg"
boolean focusrectangle = false
end type

type st_info from statictext within w_main
integer x = 1015
integer y = 1060
integer width = 1289
integer height = 52
integer textsize = -7
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 8421504
long backcolor = 553648127
string text = "Copyright © Ramón San Félix Ramón  rsrsystem.soft@gmail.com"
boolean focusrectangle = false
end type

type st_myversion from statictext within w_main
integer x = 1810
integer y = 56
integer width = 489
integer height = 84
integer textsize = -12
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 16777215
long backcolor = 33521664
string text = "Versión"
alignment alignment = right!
boolean focusrectangle = false
end type

type st_platform from statictext within w_main
integer x = 1810
integer y = 144
integer width = 489
integer height = 84
integer textsize = -12
integer weight = 400
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Arial"
long textcolor = 16777215
long backcolor = 33521664
string text = "Bits"
alignment alignment = right!
boolean focusrectangle = false
end type

type r_2 from rectangle within w_main
long linecolor = 33554432
linestyle linestyle = transparent!
integer linethickness = 4
long fillcolor = 33521664
integer width = 2331
integer height = 260
end type

type ddplb_icon from dropdownpicturelistbox within w_main
integer x = 576
integer y = 728
integer width = 558
integer height = 400
integer taborder = 30
integer textsize = -10
integer weight = 400
fontcharset fontcharset = ansi!
fontpitch fontpitch = variable!
fontfamily fontfamily = swiss!
string facename = "Tahoma"
long textcolor = 33554432
string item[] = {"StopSign","Information","None","Exclamation"}
borderstyle borderstyle = stylelowered!
integer itempictureindex[] = {1,2,3,4}
string picturename[] = {"StopSignIcon!","InformationIcon!","NotFound1!","ExclamationIcon!"}
long picturemaskcolor = 536870912
end type

