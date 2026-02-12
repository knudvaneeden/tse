/****************************************************************************\

    DlgAscii.S

    Ascii-Chart.

    Version         v2.20/26.02.02
    Copyright       (c) 1995-2002 by DiK

    Overview:

    See on-line help for instructions.

    Keys:       (none)

    Command Line Format:

    DlgAscii [-x] [-oem]

    where:

        -x      don't insert character(s) into buffer,
                but return them via the macro command line

        -oem    display an oem character set
                this switch is operational only for the gui version

    History

    v2.20/26.02.02  adaption to TSE32 v4.0
                    þ added oem display (gui only)
                    þ fixed version checking
    v2.11/11.01.02  maintenance
                    þ fixed copying to the clipboard
    v2.10/30.11.00  adaption to TSE32 v3.0
                    þ centered dialogs and help
    v2.00/24.10.96  adaption to TSE32
                    þ version number only
    v1.20/25.03.96  maintenance
                    þ fixed return to prompt buffer
                    þ some cleanup of source code
    v1.00/12.01.96  first version

\****************************************************************************/

/****************************************************************************\
    global constants
\****************************************************************************/

#include "dialog.si"
#include "dlgascii.si"

/****************************************************************************\
    use the windows clipboard
\****************************************************************************/

#include "scwinclp.si"

/****************************************************************************\
    dialog resource
\****************************************************************************/

#include "dlgascii.dlg"

/****************************************************************************\
    shared code
\****************************************************************************/

#include "scver.si"
#include "scrun.si"
#include "schelp.si"

/****************************************************************************\
    global variables
\****************************************************************************/

integer resource                        // dialog resource buffer
integer curr_chr                        // current character
integer show_oem                        // display oem characters (gui only)
integer clr_ascii_normal                // chart color
integer clr_ascii_select                // ditto
integer clr_ascii_current               // ditto

string text[128]                        // string of selected characters

/****************************************************************************\
    help screen
\****************************************************************************/

constant HLP_WIDTH = 70

helpdef DlgAsciiHelp
    title = "Help on Ascii Chart"
    width = HLP_WIDTH
    height = 19
    y = 3

    ""
    " Summary of commands:"
    ""
    " Ok          add current character to selection"
    " Cancel      close dialog box"
    " Clip        copy selection to clipboard and close"
    " Insert      insert selection into file and close (<Cntrl Enter>)"
    ""
    " Usage:"
    ""
    " Use the cursor keys or click the left mouse button to move the"
    " hilite. Pressing <Enter> or double clicking appends the current"
    " character to the line of selected characters. To copy the string"
    " into the file or to the clipboard use either the Insert or Clip"
    " command. This will also close the ascii chart. <Ctrl Enter> is an"
    " additonal shortcut for the Insert command. If the line of selected"
    " characters is empty the current character is inserted or copied"
    " to the clipboard instead."
    ""
end

/****************************************************************************\
    helper: add character to selection
\****************************************************************************/

proc AddChar()
    ExecMacro(Format("DlgGetTitle ",ID_EDT_TEXT))
    text = Query(MacroCmdLine)
    ExecMacro(Format("DlgSetTitle ",ID_EDT_TEXT," ",text,Chr(curr_chr)))
end

/****************************************************************************\
    ascii chart
\****************************************************************************/

public proc AsciiPaintCntrl()
    integer state = Val(Query(MacroCmdLine))
    integer i,j
    integer x1 = CurrChar(POS_X1)
    integer y1 = CurrChar(POS_Y1)
    string line[32]

    // paint chart

#ifdef WIN32
    BufferVideo()
#endif

    Set(Attr,clr_ascii_normal)
    for j = 0 to 7
        line = ""
        for i = 0 to 31
            line = line + Chr( j shl 5 | i )
        endfor
        VGotoXY(x1,y1+j)

#if EDITOR_VERSION <= 0x3000
        PutStr(line)
#else
        if show_oem
            PutOemLine(line, Length(line))
        else
            PutStr(line)
        endif
#endif

    endfor

    // paint hi-lite

    j = curr_chr shr 5
    i = curr_chr & 0x1F
    VGotoXY(x1+i,y1+j)
    if state == STATE_ACTIVE
        PutAttr(clr_ascii_select,1)
    else
        PutAttr(clr_ascii_current,1)
    endif

#ifdef WIN32
    UnBufferVideo()
#endif

end

public proc AsciiGotoCntrl()
    integer move_focus = Val(Query(MacroCmdLine))

    Set(MacroCmdLine,Str(move_focus <> EVENT_GROUP))
end

public proc AsciiExecCntrl()
    integer code
    integer i,j

    j = curr_chr shr 5
    i = curr_chr & 0x1F

    ExecMacro("DlgInitMouseLoop")

    loop
        ExecMacro(Format("DlgSetTitle ",ID_TXT_DEC," ",Str(curr_chr)))
        ExecMacro(Format("DlgSetTitle ",ID_TXT_HEX," ",Str(curr_chr,16)))

        Set(MacroCmdLine,Str(STATE_ACTIVE))
        AsciiPaintCntrl()

        ExecMacro("DlgGetEvent")
        code = Val(Query(MacroCmdLine))

        case code
            when <PgUp>         j = 0
            when <PgDn>         j = 7
            when <Home>         i = 0
            when <End>          i = 31
            when <CursorUp>     j = j-1  if j < 0  j = 7  endif
            when <CursorDown>   j = j+1  if j > 7  j = 0  endif
            when <CursorLeft>   i = i-1  if i < 0  i = 31 endif
            when <CursorRight>  i = i+1  if i > 31 i = 0  endif

            when <LeftBtn>
                ExecMacro("DlgMouseClick")
                if Val(Query(MacroCmdLine))
                    ExecMacro("DlgMouseDoubleClick")
                    if Val(Query(MacroCmdLine))
                        AddChar()
                    else
                        ExecMacro("DlgMouseXOffset")
                        i = Val(Query(MacroCmdLine))
                        ExecMacro("DlgMouseYOffset")
                        j = Val(Query(MacroCmdLine))
                    endif
                else
                    break
                endif

            otherwise
                break
        endcase

        curr_chr = j shl 5 | i
    endloop

    PushKey(code)
end

/****************************************************************************\
    additional hot key
\****************************************************************************/

public proc AsciiEvent()
    if Query(Key) == <Ctrl Enter>
        Set(Key,<Alt I>)
    endif
end

/****************************************************************************\
    button response
\****************************************************************************/

proc IdOk()
    AddChar()
    ExecMacro(Format("DlgExecCntrl ",ID_CTR_ASCII))
end

public proc AsciiBtnDown()
    case CurrChar(POS_ID)
        when ID_OK              IdOk()
        when ID_BTN_CLIP        ExecMacro("DlgTerminate")
        when ID_BTN_INSERT      ExecMacro("DlgTerminate")
        when ID_HELP            InitHelp(HLP_WIDTH) QuickHelp(DlgAsciiHelp)
    endcase
end

/****************************************************************************\
    set and get dialog data
\****************************************************************************/

public proc AsciiDataInit()

    // check dialog version

    if CheckVersion("DlgAscii",2,20)
        ExecMacro("DlgTerminate")
        return ()
    endif

    // check for oem display

    if show_oem
        ExecMacro("DlgSetTitle 0 Oem Character Chart")
    endif

    // determine chart colors

    ExecMacro("DlgGetColor AsciiChart_Normal")
    clr_ascii_normal = Val(Query(MacroCmdLine))
    ExecMacro("DlgGetColor AsciiChart_Select")
    clr_ascii_select = Val(Query(MacroCmdLine))
    ExecMacro("DlgGetColor AsciiChart_Current")
    clr_ascii_current = Val(Query(MacroCmdLine))

    // install colors if necessary

    if clr_ascii_normal < 0 or clr_ascii_select < 0 or clr_ascii_current < 0
        clr_ascii_normal = Color( black on cyan )
        clr_ascii_select = Color( bright yellow on red )
        clr_ascii_current = Color( bright yellow on blue )
        ExecMacro(Format("DlgSetColor AsciiChart_Normal ",clr_ascii_normal))
        ExecMacro(Format("DlgSetColor AsciiChart_Select ",clr_ascii_select))
        ExecMacro(Format("DlgSetColor AsciiChart_Current ",clr_ascii_current))
        ExecMacro("DlgSaveSetup")
    endif

    // set ascii value fields

    ExecMacro(Format("DlgSetData ",ID_TXT_DEC," ",Str(curr_chr)))
    ExecMacro(Format("DlgSetData ",ID_TXT_HEX," ",Str(curr_chr,16)))

    // activate chart

    ExecMacro(Format("DlgExecCntrl ",ID_CTR_ASCII))
end

public proc AsciiDataDone()
    ExecMacro(Format("DlgGetTitle ",ID_EDT_TEXT))
    text = Query(MacroCmdLine)
    if Length(text) == 0
        text = Chr(curr_chr)
    endif
end

/****************************************************************************\
    main program
\****************************************************************************/

proc Main()
    integer i, rc
    integer dont_insert = FALSE
    integer bid = GetBufferId()
    string cmd[64] = Query(MacroCmdLine)

    // compute command line

    for i = 1 to NumTokens(cmd, " ")
        case GetToken(cmd, " ", i)
            when "-x"       dont_insert = TRUE
            when "-oem"     show_oem = TRUE
        endcase
    endfor

    // get current character

    if not dont_insert
        curr_chr = Val(Query(MacroCmdLine))
        if curr_chr == 0
            curr_chr = Max(0,CurrChar())
        endif
    endif

    // allocate work space and exec dialog

    UpdateDisplay(_HELPLINE_REFRESH_)
    resource = CreateTempBuffer()
    rc = resource
        and InsertData(dlgascii)
        and ExecDialog("dialog ascii")
    AbandonFile(resource)
    UpdateDisplay(_HELPLINE_REFRESH_)

    // check return code and search text

    cmd = ""
    GotoBufferId(bid)
    if rc
        case Val(Query(MacroCmdLine))
            when ID_BTN_CLIP
                bid = GotoBufferId(Query(ClipBoardId))
                EmptyBuffer()
                InsertText(text)
#ifdef USE_WIN_CLIP
                PushBlock()
                MarkChar()
                BegLine()
                CopyToWinClip()
                EndLine()
                PopBlock()
#endif
                GotoBufferId(bid)
            when ID_BTN_INSERT
                if dont_insert
                    cmd = text
                else
                    InsertText(text)
                endif
        endcase
    else
        Warn("DlgAscii: Error executing ascii chart")
    endif

    // set return code and purge self

    Set(MacroCmdLine,cmd)
    PurgeMacro(CurrMacroFilename())
end

