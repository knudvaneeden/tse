/****************************************************************************\

    TestDlg4.S

    Example dialog

    Version         v2.01/17.03.97
    Copyright       (c) 1995-97 by DiK

    History

    v2.01/17.03.97  first version

\****************************************************************************/

/****************************************************************************\
    global constants
\****************************************************************************/

#include "dialog.si"
#include "testdlg4.si"

/****************************************************************************\
    dialog resource
\****************************************************************************/

#include "testdlg4.dlg"

/****************************************************************************\
    global variables
\****************************************************************************/

integer tick
integer count
integer start
integer handle

/****************************************************************************\
    helper routine
\****************************************************************************/

proc SetTime()
    integer h,m,s,hun

    GetTime(h,m,s,hun)
    ExecMacro(Format("DlgSetTitle ",
        ID_CLOCK," ",h:2:"0",":",m:2:"0",":",s:2:"0"))
end

/****************************************************************************\
    init und shutdown
\****************************************************************************/

public proc TestDataInit()
    tick = GetClockTicks()
    SetTime()
end

public proc TestDataDone()
    if handle
        FindFileClose(handle)
    endif
end

/****************************************************************************\
    idle callback
\****************************************************************************/

public proc TestIdle()
    integer next_tick = GetClockTicks()

    if next_tick > tick
        tick = next_tick
        SetTime()
    endif

    if handle
        if FindNextFile(handle,_NORMAL_)
            count = count + 1
            ExecMacro(Format("DlgSetTitle ",ID_FILE," ",FFName()))
        else
            FindFileClose(handle)
            handle = 0
            Message(count," files found / ",
                GetClockTicks()-start," ticks passed")
            ExecMacro(Format("DlgSetEnable ",ID_START," 1"))
        endif
    endif
end

/****************************************************************************\
    button callback
\****************************************************************************/

proc StartScan()
    integer code
    string dir[255]

    ExecMacro(Format("DlgGetTitle ",ID_FOLDER))
    dir = Query(MacroCmdLine)
    code = FileExists(dir)
    if code < 0 or (code & _DIRECTORY_) == 0
        Alarm()
        return()
    endif

    count = 1
    start = GetClockTicks()
    handle = FindFirstFile(AddTrailingSlash(Dir)+"*",_NORMAL_)
    if handle
        ExecMacro(Format("DlgSetTitle ",ID_FILE," ",FFName()))
        ExecMacro(Format("DlgSetEnable ",ID_START," 0"))
    endif
end

public proc TestBtnDown()
    case CurrChar(POS_ID)
        when ID_START   StartScan()
    endcase
end

/****************************************************************************\
    main program
\****************************************************************************/

proc main()
    integer resource

    resource = CreateTempBuffer()
    if resource and InsertData(TestDlg4)
        ExecMacro("dialog test")
    endif
    AbandonFile(resource)
    PurgeMacro(CurrMacroFilename())
end

