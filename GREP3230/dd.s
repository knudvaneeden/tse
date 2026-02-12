/****************************************************************************\

    DD.S

    Display a dialog resource.

    Version         v2.00/24.10.96
    Copyright       (c) 1996 by DiK

    Overview:

    This macro displays a dialog resource for testing.

    Command Line Format:

    DD [filename]

    where:

        filename    name of the dialog resource to be displayed

    Usage notes:

    If a filename is included at the macro command line DD loads and
    displays the specified file. Otherwise, DD will ask the user for
    the name of the input file, unless the file extension of the current
    file is .D. In this case, DD will load the corresponding .DLG file.

    History

    v2.00/24.10.96  adaption to TSE32
                    þ added buffered video output
                    þ fixed lower case hex digits
                    þ fixed size of name strings
                    þ fixed quoting long filenames
    v1.20/25.03.96  first version

\****************************************************************************/

/****************************************************************************\
    constants
\****************************************************************************/

#include "dialog.si"

/****************************************************************************\
    shared code
\****************************************************************************/

#define INC_UNQUOTE 1

#include "scver.si"
#include "scruns.si"
#include "sctoken.si"

/****************************************************************************\
    global variables
\****************************************************************************/

string dlgname[255]                     // name of input file

integer usrfile                         // buffer id (user file)
integer dlgbuff                         // ditto (binary resource)

/****************************************************************************\
    callbacks for painting user defined controls
\****************************************************************************/

proc PaintCntrl( integer state )
    integer line, clr
    integer x1 = CurrChar(POS_X1)
    integer y1 = CurrChar(POS_Y1)
    integer y2 = CurrChar(POS_Y2)
    integer len = CurrChar(POS_X2) - x1

    // paint field and title

    if state == STATE_ACTIVE
        ExecMacro("DlgGetColor List_Current")
    else
        ExecMacro("DlgGetColor List_Normal")
    endif
    clr = Val(Query(MacroCmdLine))
    if clr < 0
        clr = Color( Black On Cyan )
    endif

#ifdef WIN32
    BufferVideo()
#endif

    Set(Attr,clr)
    for line = y1 to y2-1
        VGotoXY(x1,line)
        PutLine(GetText(POS_TITLE,255),len)
    endfor

#ifdef WIN32
    UnBufferVideo()
#endif

end

public proc DlgResPaintCntrl()
    PaintCntrl(Val(Query(MacroCmdLine)))
end

public proc DlgResExecCntrl()
    PaintCntrl(STATE_ACTIVE)
end

public proc DlgResGotoCntrl()
    integer move_focus = Val(Query(MacroCmdLine))

    Set(MacroCmdLine,Str(move_focus <> EVENT_GROUP))
end

public proc DlgResBtnDown()
    if CurrChar(POS_CNTRL) in CNTRL_BUTTON,CNTRL_DEFBTN
        ExecMacro("DlgTerminate")
    endif
end

public proc DlgResDataInit()
    if CheckVersion("DD",2,0)
        ExecMacro("DlgTerminate")
        return ()
    endif
end

/****************************************************************************\
    display dialog
\****************************************************************************/

proc Display()
    if ExecDialog("dialog DlgRes")
        Message("Return code of dialog was: ",Query(MacroCmdLine))
    else
        Warn("DD: Cannot load dialog run time library")
    endif
end

/****************************************************************************\
    translate resource (hex to binary)
\****************************************************************************/

integer proc Translate()
    integer c
    string bin_info[9]

    // remove datadef statement

    EndFile()
    if GetText(1,3) <> "end"
        return (FALSE)
    endif
    KillLine()
    BegFile()
    if GetText(1,8) <> "datadef "
        return (FALSE)
    endif
    KillLine()

    // remove indention

    if not lReplace("^ #","","gnx")
        return (FALSE)
    endif

    // remove Chr-functions

    if not (lReplace("Chr(0x","","gn")
            and lReplace(")","","gn")
            and lReplace("+","","gn"))
        return (FALSE)
    endif

    // handle title and hint

    if not (lReplace("'FF'",Chr(255),"gin") and lReplace("'","","gn"))
        return (FALSE)
    endif

    // translate hex to binary

    repeat
        bin_info = ""
        for c = 1 to 17 by 2
            bin_info = bin_info + Chr(Val(GetText(c,2),16))
        endfor
        MarkColumn(CurrLine(),1,CurrLine(),18)
        KillBlock()
        BegLine()
        InsertText(bin_info,_INSERT_)
    until not Down()
    BegFile()

    return (TRUE)
end

/****************************************************************************\
    setup
\****************************************************************************/

integer proc Init()
    integer hist
    integer current
    string msg[48] = "Enter name of dialog resource file:"

    // determine filenames

    usrfile = GetBufferId()
    dlgname = UnQuotePath(Query(MacroCmdLine))

    if not (Length(dlgname) and FileExists(dlgname))
        current = CurrExt() == ".d" or CurrExt() == ".dlg"
        hist = GetFreeHistory("DLG:bin")
        if current
            dlgname = SplitPath(CurrFileName(),_DRIVE_|_PATH_|_NAME_) + ".dlg"
        elseif ExecDialog("DlgOpen -x -t -y")
            if Val(Query(MacroCmdLine)) == 2
                dlgname = GetHistoryStr(hist,1)
            else
                return (FALSE)
            endif
        else
            dlgname = "*.dlg"
            if not AskFilename(msg,dlgname,_MUST_EXIST_,hist)
                return (FALSE)
            endif
        endif
    endif

    // load resource file

    dlgbuff = CreateTempBuffer()
    if not (dlgbuff and InsertFile(dlgname))
        Warn("DD: Cannot load dialog resource")
        return (FALSE)
    endif

    return (TRUE)
end

/****************************************************************************\
    shutdown
\****************************************************************************/

proc Done()

    // clear work space

    AbandonFile(dlgbuff)
    GotoBufferId(usrfile)

    // purge self

    PurgeMacro(CurrMacroFileName())
end

/****************************************************************************\
    main program
\****************************************************************************/

proc Main()
    if Init()
        GotoBufferId(dlgbuff)
        if Translate()
            Display()
        else
            Alarm()
            Warn("DD: invalid dialog resource")
        endif
    endif
    Done()
end

