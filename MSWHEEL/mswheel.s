// MSWHEEL.S -- Wheel mouse support for TSE/32
// Chris Antos, chrisant@microsoft.com



///////////////////////////////////////////////////////////////////////////
// Globals

integer s_fInitialized = FALSE
integer s_cEnabled = 1

integer g_fAlt
integer g_fCtrl
integer g_fShift
integer g_fGrey

string c_stSection[] = "TSEWheel"
string c_stAlt[] = "Alt"
string c_stCtrl[] = "Ctrl"
string c_stShift[] = "Shift"
string c_stGrey[] = "Grey"



///////////////////////////////////////////////////////////////////////////
// External DLL Integration

dll "mswheel.dll"
    integer proc Startup()
    proc Shutdown()
    proc SetEnable(integer fEnable)
    proc SetMode(integer fKeys)
    proc SetKeyFlags(integer fAlt, integer fCtrl, integer fShift, integer fGrey)
end


proc CallShutdown()
    if s_fInitialized
        Shutdown()
    endif
end



///////////////////////////////////////////////////////////////////////////
// Public Macros

// call this to disable wheel processing temporarily, e.g. when a macro
// invokes the TSE Dos() or Shell() commands.  calls may be nested, and
// maintain an overall counter; when the counter is > 0 the wheel is enabled.
public proc MSWHEEL_DisableWheel()
    if s_fInitialized
        s_cEnabled = s_cEnabled - 1
        if s_cEnabled == 0
            SetEnable(FALSE)
        endif
    endif
end

// call this to reenable wheel processing.  calls may be nested, and maintain
// an overall counter; when the counter is > 0 the wheel is enabled.
public proc MSWHEEL_EnableWheel()
    if s_fInitialized
        s_cEnabled = s_cEnabled + 1
        if s_cEnabled == 1
            SetEnable(TRUE)
        endif
    endif
end

// call this to make the wheel send TSE keystrokes.  this is the normal mode
// while editing in the TSE window.
public proc MSWHEEL_SetKeyMode()
    if s_fInitialized
        SetMode(TRUE)
    endif
end

// call this to make the wheel send WM_VSCROLL messages.  this is appropriate
// when the TSE ShowEntryScreen() or lShowEntryScreen() commands are used.
public proc MSWHEEL_SetMessageMode()
    if s_fInitialized
        SetMode(FALSE)
    endif
end



///////////////////////////////////////////////////////////////////////////
// Configuration Menu

constant c_cchKey = 30


string proc BuildKeyName(integer fUp)
    string st[c_cchKey] = ""

    if g_fCtrl
        st = st + "Ctrl"
    endif
    if g_fAlt
        st = st + "Alt"
    endif
    if g_fShift
        st = st + "Shift"
    endif

    if Length(st)
        st = st + " "
    endif

    if g_fGrey
        st = st + "Grey"
    endif

    st = st + "Cursor"

    return("<" + st + iif(fUp, "Up>", "Down>"))
end


string proc Xstr(integer x)
    return(iif(x, "X", " "))
end


proc ToggleX(var integer x)
    x = not x
end


menu CfgMenu()
title = "TSE Wheel Mouse"
history
"Up key:" [BuildKeyName(TRUE):c_cchKey],, Skip
"Down key:" [BuildKeyName(FALSE):c_cchKey],, Skip
"",, Divide
"&Ctrl" [Xstr(g_fCtrl):1], ToggleX(g_fCtrl), CloseBefore, "Toggle <Ctrl> in the up/down keys."
"&Alt" [Xstr(g_fAlt):1], ToggleX(g_fAlt), CloseBefore, "Toggle <Alt> in the up/down keys."
"&Shift" [Xstr(g_fShift):1], ToggleX(g_fShift), CloseBefore, "Toggle <Shift> in the up/down keys."
"&Grey" [Xstr(g_fGrey):1], ToggleX(g_fGrey), CloseBefore, "Toggle <Grey> in the up/down keys."
end


proc DoCfgMenu()
    if not s_fInitialized
        Warn("MSWHEEL could not be initialized.")
        return()
    endif

    loop
        CfgMenu()

        if not MenuOption()
            break
        endif

        WriteProfileInt(c_stSection, c_stAlt, g_fAlt)
        WriteProfileInt(c_stSection, c_stCtrl, g_fCtrl)
        WriteProfileInt(c_stSection, c_stShift, g_fShift)
        WriteProfileInt(c_stSection, c_stGrey, g_fGrey)

        SetKeyFlags(g_fAlt, g_fCtrl, g_fShift, g_fGrey)
    endloop
end



///////////////////////////////////////////////////////////////////////////
// Auto Macros

proc WhenLoaded()
    Hook(_ON_ABANDON_EDITOR_, CallShutdown)

    s_fInitialized = Startup()

    if s_fInitialized
        SetEnable(TRUE)
        SetMode(TRUE)
    endif

    g_fAlt = GetProfileInt(c_stSection, c_stAlt, FALSE)
    g_fCtrl = GetProfileInt(c_stSection, c_stCtrl, TRUE)
    g_fShift = GetProfileInt(c_stSection, c_stShift, FALSE)
    g_fGrey = GetProfileInt(c_stSection, c_stGrey, FALSE)

    SetKeyFlags(g_fAlt, g_fCtrl, g_fShift, g_fGrey)
end


proc WhenPurged()
    CallShutdown()
end



///////////////////////////////////////////////////////////////////////////
// Main

proc Main()
    if EquiStr(Query(MacroCmdLine), "-menu")
        DoCfgMenu()
    endif
end

