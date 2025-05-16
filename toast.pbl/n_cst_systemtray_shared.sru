//objectcomments MS-Windows System Tray functions
forward
global type n_cst_systemtray_shared from nonvisualobject
end type
end forward

global type n_cst_systemtray_shared from nonvisualobject
end type
global n_cst_systemtray_shared n_cst_systemtray_shared

type variables

end variables

forward prototypes
public subroutine of_delete_from_systemtray (integer ai_messageboxtimeout, n_cst_systemtray_callback a_callback)
end prototypes

public subroutine of_delete_from_systemtray (integer ai_messageboxtimeout, n_cst_systemtray_callback a_callback);IF ai_MessageBoxTimeout > 0 THEN
	sleep(ai_MessageBoxTimeout)
END IF   


a_callback.POST  of_delete_from_systemtray()
end subroutine

on n_cst_systemtray_shared.create
call super::create
TriggerEvent( this, "constructor" )
end on

on n_cst_systemtray_shared.destroy
TriggerEvent( this, "destructor" )
call super::destroy
end on

