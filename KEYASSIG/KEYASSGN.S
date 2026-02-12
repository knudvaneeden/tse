/****************************************************************************\

    KeyAssgn.S

    Help for keyboard assignments

    Displays a popup window and asks the user to hit any key.
    The key binding source file (ui_keys.si) is searched for
    the translated key code and, if the code is found, the
    corresponding command and comment are displayed.

    Version         v3.00/18.04.97
    Copyright       (c) 1993-96 by DiK

    History
    v3.01/18.04.97  adaption for public release
    v3.00/22.10.96  adaption to TSE32
    v2.11/09.02.96  adaption new ui
    v2.10/18.09.95  adaption to v2.5 of TSE
    v2.00/28.10.94  adaption to v2.0 of TSE
    v1.10/25.01.94  bug fix
    v1.00/29.12.93  primary release

\****************************************************************************/

#ifndef WIN32
#include ["keytable.si"]
#endif

/****************************************************************************\
    global variables and constants
\****************************************************************************/

constant  KEYWIDTH = 32,
          CMDWIDTH = 192

#ifndef WIN32
integer keyfile
#endif

integer cmdfile
integer tmpfile

string cmd_path[] = "ui\"
string cmd_file[] = "tse.ui"

/****************************************************************************\
    translate key codes
\****************************************************************************/

#ifndef WIN32

integer proc FindCode( integer key, integer width, integer col )
    string hex_name[4]

    hex_name = format(key:width:'0':16)
    if lFind(hex_name,"g")
        repeat
            if col == 0
                if (CurrPos() - 1) mod 4 == 0
                    return (TRUE)
                endif
            else
                if CurrPos() == col
                    return (TRUE)
                endif
            endif
        until not lRepeatFind()
    endif
    return (FALSE)
end

string proc FindKey( integer key )
    integer n
    string key_name[KEYWIDTH]
    string cols[4] = Chr(9) + Chr(9) + Chr(5) + Chr(1)

    GotoBufferId(keyfile)
    if FindCode(key,4,0)
        key_name = SubStr(
            "Shift Ctrl  Alt ",
            ((CurrPos() - 1)/4) * 6 + 1, 6 - CurrPos() /4)
        key_name = key_name + GetText(17,KEYWIDTH)
        return (key_name)
    else
        n = (key & 0xFF) - 0xFA
        if 0 <= n and n <= 3
            if FindCode(key shr 8, 2, Asc(cols[n+1]))
                key_name = SubStr(
                    "CtrlAlt    AltShift   CtrlShift  ShiftShift ",
                    n * 11 + 1, n + 8)
                key_name = key_name + GetText(17,KEYWIDTH)
                return (key_name)
            endif
        endif
    endif
    return (str(key))
end

#else

string proc FindKey( integer key )
    integer n
    string key_name[KEYWIDTH]

    key_name = KeyName(key)
    for n = Length(key_name) downto 1
    	if Asc(key_name[n]) < 32
    		key_name = "<"+Str(key)+">"
    		break
    	endif
    endfor
    return (key_name)
end

#endif

/****************************************************************************\
    find key binding
\****************************************************************************/

proc TranslateKey( var string key )
    GotoBufferId(tmpfile)
    AddLine(key)
    lReplace("{[\\\[\]{}?.*+#@~|^$]}","\\\1","gnx")
    key = GetText(1,CurrLineLen())
    EmptyBuffer()
end

proc FindCmd ( var string cmd, var string dsc, string key, integer first )
    string the_key[KEYWIDTH] = key

    GotoBufferId(cmdfile)
    dsc = ""
    if not lFind(the_key,"gi^")
        TranslateKey(the_key)
        if not lFind(the_key,"gi^")
            cmd = "not assigned"
            return()
        endif
    endif
    if first and lFind("^<.+><.+>","cgx")
        cmd = ""
    else
        if lFind("^<.#> #{.+}{//}|$","cgix")
            MarkFoundText(1)
            cmd = Trim(GetMarkedText())
            if lFind("^<.#> #{.#}//{.#}$","cgx")
                MarkFoundText(2)
                dsc = Trim(GetMarkedText())
            endif
        else
            cmd = "invalid keydefinition"
        endif
    endif
end

/****************************************************************************\
    hooked events
\****************************************************************************/

proc WhenLoaded()
    PushPosition()

#ifndef WIN32
    keyfile = CreateTempBuffer()
    if not ( keyfile and  InsertData(keytable) )
        Warn("Cannot allocate key table")
        PurgeMacro(CurrMacroFileName())
        return()
    endif
#endif

    cmdfile = CreateTempBuffer()
    if not ( cmdfile and InsertFile(LoadDir()+cmd_path+cmd_file) )
        Warn("Cannot load UI file")
        PurgeMacro(CurrMacroFileName())
        return()
    endif

    tmpfile = CreateTempBuffer()
    if not tmpfile
        Warn("Cannot allocate work buffer")
        PurgeMacro(CurrMacroFileName())
        return()
    endif

    Message("Help on keyboard assignment...")
end

proc WhenPurged()

#ifndef WIN32
    AbandonFile(keyfile)
#endif

    AbandonFile(cmdfile)
    AbandonFile(tmpfile)
    PopPosition()
    UpdateDisplay()
end

/****************************************************************************\
    main program
\****************************************************************************/

proc main()
    integer key
    string  key_open[KEYWIDTH] = ""
    string  key_name[KEYWIDTH] = ""
    string  cmd_name[CMDWIDTH] = ""
    string  cmd_desc[CMDWIDTH] = ""

    if PopWinOpen(11,7,70,16,4,"",112)
        Set(Cursor,OFF)
        Set(Attr,112)
        ClrScr()

        repeat
            GotoXY(7,2) ClrEol()
            GotoXY(3,2) ClrEol()
            Write("Hit key for description or press <Esc> to Exit")
            loop
                key = GetKey()
                key_name = key_open + '<' + FindKey(key) + '>'
                FindCmd(cmd_name,cmd_desc,key_name,key_open=="")

                Set(Attr,112)
                GotoXY(3,4) ClrEol() Write(key_name)
                GotoXY(3,5) ClrEol() Write(cmd_name)
                GotoXY(3,7) ClrEol() Write(cmd_desc)

                if Length(cmd_name)
                    key_open = ""
                    break
                else
                    key_open = key_name
                    GotoXY(3,2) ClrEol() Write("TwoKey, hit second key")
                endif
            endloop
        until key == <Escape>

        Delay(9)
        PopWinClose()
        Set(Cursor,ON)
    endif
    PurgeMacro(CurrMacroFileName())
end

