//objectcomments MS-Windows System Tray functions
forward
global type n_cst_systemtray_callback from nonvisualobject
end type
end forward

global type n_cst_systemtray_callback from nonvisualobject
end type
global n_cst_systemtray_callback n_cst_systemtray_callback

type variables
w_main iw_win
end variables

forward prototypes
public subroutine of_delete_from_systemtray ()
public subroutine of_register (w_main aw_win)
end prototypes

public subroutine of_delete_from_systemtray (); //Si hay en pantalla una Noficación la elimino.
 IF iw_win.in_systemtray.of_get_systemtray_active()=TRUE THEN
	iw_win.in_systemtray.of_delete_from_systemtray (iw_win, FALSE )	
 END IF
end subroutine

public subroutine of_register (w_main aw_win);iw_win = aw_win
end subroutine

on n_cst_systemtray_callback.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_cst_systemtray_callback.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

