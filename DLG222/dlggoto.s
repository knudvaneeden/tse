/****************************************************************************\

    DlgGoto.S

    Go to a specified line and/or column.

    Version         v2.10/30.11.00
    Copyright       (c) 1995-2000 by DiK

    Overview:

    This macro scrolls the text of the current file so that the specified
    line becomes the current line and the specified column becomes the
    current column. If the current line does change, it will be centered
    on the screen.

    Keys:       (none)

    Command Line Format:

    DlgGoto [-c]

    where:

        none    GotoLine
        -c      GotoColumn

    History

    v2.10/30.11.00  adaption to TSE32 v3.0
                    þ version number only
    v2.00/24.10.96  adaption to TSE32
                    þ version number only
    v1.20/25.03.96  maintenance
                    þ fixed validation routine
                    þ some cleanup of source code
    v1.10/12.01.96  maintenance
                    þ adapted EditChanged callback
    v1.00/11.10.95  first version

\****************************************************************************/

/****************************************************************************\
    global constants
\****************************************************************************/

#include "dialog.si"
#include "dlggoto.si"

/****************************************************************************\
    dialog resource
\****************************************************************************/

#include "dlggoto.dlg"

/****************************************************************************\
    shared code
\****************************************************************************/

#include "scver.si"
#include "scrun.si"

/****************************************************************************\
    global variables
\****************************************************************************/

integer resource                        // dialog resource buffer

integer go_col                          // flag (activate column number)

integer line, rel_line                  // line number and mode
integer column, rel_column              // column number and mode

/****************************************************************************\
    set dialog data
\****************************************************************************/

public proc GotoDataInit()

    // check dialog version

    if CheckVersion("DlgGoto",2,0)
        ExecMacro("DlgTerminate")
        return ()
    endif

    // init data

    ExecMacro(Format("DlgSetTitle ",ID_EDT_LINE," ",line))
    ExecMacro(Format("DlgSetTitle ",ID_EDT_COLUMN," ",column))
    ExecMacro(Format("DlgSetData ",ID_EDT_LINE," ",_GOTOLINE_HISTORY_))
    ExecMacro(Format("DlgSetData ",ID_EDT_COLUMN," ",_GOTOCOLUMN_HISTORY_))
    if go_col
        ExecMacro(Format("DlgExecCntrl ",ID_EDT_COLUMN))
    endif
end

/****************************************************************************\
    get dialog data
\****************************************************************************/

public proc GotoDataDone()
    string text[128]

    ExecMacro(Format("DlgGetTitle ",ID_EDT_LINE))
    text = Query(MacroCmdLine)
    line = Val(text)
    rel_line = text[1] in "+","-"
    ExecMacro(Format("DlgGetTitle ",ID_EDT_COLUMN))
    text = Query(MacroCmdLine)
    column = Val(text)
    rel_column = text[1] in "+","-"
end

/****************************************************************************\
    message response functions
\****************************************************************************/

public proc GotoEditChanged()
    integer rc, char, index
    string text[128]

    text  = Query(MacroCmdLine)
    index = Val(GetToken(text," ",1))
    char  = Val(GetToken(text," ",2))
    text  = GetToken(text," ",3)

    if char <= 0
        rc = TRUE
    elseif index > 1
        rc = char in 48..57
    else
        rc = char in 43,45,48..57
        if text[1] in "+","-"
            rc = rc and Query(Insert) == OFF
        endif
    endif

    if not rc and Query(Beep)
        Alarm()
    endif
    Set(MacroCmdLine,Str(rc))
end

public proc GotoBtnDown()
    case CurrChar(POS_ID)
        when ID_OK          ExecMacro("DlgTerminate")
        when ID_HELP        Help("prompt->Go to column:")
    endcase
end

/****************************************************************************\
    main program
\****************************************************************************/

proc Main()
    integer rc
    string cmd[8] = Query(MacroCmdLine)

    // check command line

    if Length(cmd)
        if cmd == "-c"
            go_col = TRUE
        else
            Warn("DlgRplc: Invalid command line. Using defaults.")
        endif
    endif

    // initialize data

    line = CurrLine()
    column = CurrCol()

    // allocate work space and exec dialog

    PushBlock()
    resource = CreateTempBuffer()
    rc = resource
        and InsertData(dlggoto)
        and ExecDialog("dialog goto")
    AbandonFile(resource)
    PopBlock()
    UpdateDisplay(_HELPLINE_REFRESH_)

    // check return code and search text

    if rc
        if Val(Query(MacroCmdLine)) == ID_OK
            AddHistoryStr(Str(line),_GOTOLINE_HISTORY_)
            AddHistoryStr(Str(column),_GOTOCOLUMN_HISTORY_)
            if rel_line
                line = CurrLine() + line
            endif
            if rel_column
                column = CurrCol() + column
            endif
            GotoLine(line)
            GotoColumn(column)
            if Length(cmd) == 0
                ScrollToCenter()
            endif
        endif
    else
        Warn("DlgGoto: Error executing GotoLine dialog")
    endif

    // purge self

    PurgeMacro(CurrMacroFilename())
end

