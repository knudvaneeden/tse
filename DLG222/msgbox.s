/****************************************************************************\

    MsgBox.S

    CUA style message boxes for SAL.

    Version         v2.00/24.10.96
    Copyright       (c) 1995-96 by DiK

    Overview:

    This macro is a run time library which implements simple message
    boxes using Dialog.S. This macro is not meant to be directly executed
    by the user.

    Usage notes:

    See Program.Doc for instructions on how to use MsgBox.S from within
    your own macros.

    History

    v2.00/24.10.96  adaption to TSE32
                    þ added new title
    v1.20/25.03.96  maintenance
                    þ fixed clearing of blocks
    v1.10/12.01.96  maintenance
                    þ fixed Ok hotkey
    v1.00/11.10.95  first version

\****************************************************************************/

/****************************************************************************\
    symbolic constants
\****************************************************************************/

#include "dialog.si"
#include "msgbox.si"

/****************************************************************************\
    message box dimensions
\****************************************************************************/

constant BOX_HEIGHT = 3
constant BOX_WIDTH  = 50
constant BOX_TOP    = 7
constant BOX_LEFT   = 16
constant BOX_RIGHT  = BOX_LEFT + BOX_WIDTH - 1
constant BOX_BOTTOM = BOX_TOP + BOX_HEIGHT + 2

/****************************************************************************\
    global variables
\****************************************************************************/

integer resource                        // buffer id (dialog resource)
integer usr_buff                        // ditto (user buffer)

/****************************************************************************\
    push button resources
\****************************************************************************/

datadef btn_ok
    Chr(CNTRL_DEFBTN) + Chr(ID_CANCEL) + Chr(1) + Chr(0) +
        Chr(21) + Chr(BOX_HEIGHT) + Chr(29) + Chr(BOX_HEIGHT+1) + Chr(2)
        + "kOk" + Chr(END_OF_TITLE)
end

datadef btn_can
    Chr(CNTRL_DEFBTN) + Chr(ID_CANCEL) + Chr(1) + Chr(0) +
        Chr(21) + Chr(BOX_HEIGHT) + Chr(29) + Chr(BOX_HEIGHT+1) + Chr(0)
        + " Cancel" + Chr(END_OF_TITLE)
end

datadef btn_okcan
    Chr(CNTRL_GROUP) + Chr(0) + Chr(0) + Chr(0) +
        Chr(0) + Chr(0) + Chr(0) + Chr(0) + Chr(0)
        + " " + Chr(END_OF_TITLE)
    Chr(CNTRL_DEFBTN) + Chr(ID_OK) + Chr(1) + Chr(1) +
        Chr(14) + Chr(BOX_HEIGHT) + Chr(22) + Chr(BOX_HEIGHT+1) + Chr(2)
        + "kOk" + Chr(END_OF_TITLE)
    Chr(CNTRL_BUTTON) + Chr(ID_CANCEL) + Chr(1) + Chr(1) +
        Chr(28) + Chr(BOX_HEIGHT) + Chr(36) + Chr(BOX_HEIGHT+1) + Chr(0)
        + " Cancel" + Chr(END_OF_TITLE)
    Chr(CNTRL_GROUP) + Chr(0) + Chr(0) +
        Chr(0) + Chr(0) + Chr(0) + Chr(0) + Chr(0)
        + " " + Chr(END_OF_TITLE)
end

datadef btn_yesno
    Chr(CNTRL_GROUP) + Chr(0) + Chr(0) + Chr(0) +
        Chr(0) + Chr(0) + Chr(0) + Chr(0) + Chr(0)
        + " " + Chr(END_OF_TITLE)
    Chr(CNTRL_DEFBTN) + Chr(ID_YES) + Chr(1) + Chr(1) +
        Chr(14) + Chr(BOX_HEIGHT) + Chr(22) + Chr(BOX_HEIGHT+1) + Chr(1)
        + "YYes" + Chr(END_OF_TITLE)
    Chr(CNTRL_BUTTON) + Chr(ID_NO) + Chr(1) + Chr(1) +
        Chr(28) + Chr(BOX_HEIGHT) + Chr(36) + Chr(BOX_HEIGHT+1) + Chr(1)
        + "NNo" + Chr(END_OF_TITLE)
    Chr(CNTRL_GROUP) + Chr(0) + Chr(0) + Chr(0) +
        Chr(0) + Chr(0) + Chr(0) + Chr(0) + Chr(0)
        + " " + Chr(END_OF_TITLE)
end

datadef btn_yesnocan
    Chr(CNTRL_GROUP) + Chr(0) + Chr(0) + Chr(0) +
        Chr(0) + Chr(0) + Chr(0) + Chr(0) + Chr(0) + Chr(0)
        + " " + Chr(END_OF_TITLE)
    Chr(CNTRL_DEFBTN) + Chr(ID_YES) + Chr(1) + Chr(1) +
        Chr(07) + Chr(BOX_HEIGHT) + Chr(15) + Chr(BOX_HEIGHT+1) + Chr(1)
        + "YYes" + Chr(END_OF_TITLE)
    Chr(CNTRL_BUTTON) + Chr(ID_NO) + Chr(1) + Chr(1) +
        Chr(21) + Chr(BOX_HEIGHT) + Chr(29) + Chr(BOX_HEIGHT+1) + Chr(1)
        + "NNo" + Chr(END_OF_TITLE)
    Chr(CNTRL_BUTTON) + Chr(ID_CANCEL) + Chr(1) + Chr(1) +
        Chr(35) + Chr(BOX_HEIGHT) + Chr(43) + Chr(BOX_HEIGHT+1) + Chr(0)
        + " Cancel" + Chr(END_OF_TITLE)
    Chr(CNTRL_GROUP) + Chr(0) + Chr(0) + Chr(0) +
        Chr(0) + Chr(0) + Chr(0) + Chr(0) + Chr(0) + Chr(0)
        + " " + Chr(END_OF_TITLE)
end

/****************************************************************************\
    make dialog resource
\****************************************************************************/

proc Make()
    integer i, cntrl
    integer title, buttons
    integer lines, first, offset
    string line[80], header[80]
    string command[254] = Query(MacroCmdLine)

    // parse command line

    GotoBufferId(resource)

    if Length(command) < 2
        buttons = MB_OK
        title = MB_ERROR
        lines = 0
    else
        buttons = Asc(command[1])
        title = Asc(command[2])
        command = DelStr(command,1,2)
        lines = NumTokens(command,Chr(13))
    endif

    // determine title

    if title == MB_TITLE
        first = 2
        offset = 1
        header = SubStr(GetToken(command,Chr(13),1),1,32)
    else
        first = 1
        offset = 0
        case title
            when MB_INFO    header = "Info"
            when MB_PROMPT  header = "Prompt"
            when MB_WARN    header = "Warning"
            when MB_ERROR   header = "Error"
            when MB_FATAL   header = "Fatal Error"
            otherwise       header = ""
        endcase
    endif

    // insert and adapt push button resource

    case buttons
        when MB_CANCEL          InsertData(btn_can)
        when MB_OKCANCEL        InsertData(btn_okcan)
        when MB_YESNO           InsertData(btn_yesno)
        when MB_YESNOCANCEL     InsertData(btn_yesnocan)
        otherwise               InsertData(btn_ok)
    endcase
    BegFile()

    i = NumLines()
    MarkColumn(1,POS_Y1,i,POS_Y1)
    lReplace(Chr(BOX_HEIGHT),Chr(BOX_HEIGHT+lines-offset),"lgn")
    MarkColumn(1,POS_Y2,i,POS_Y2)
    lReplace(Chr(BOX_HEIGHT+1),Chr(BOX_HEIGHT+1+lines-offset),"lgn")

    // scan message text and make text lines

    for i = lines downto first
        line = GetToken(command,Chr(13),i)
        cntrl = Asc(line[1])
        line = line[2:41]
        if not (cntrl in CNTRL_LTEXT,CNTRL_RTEXT)
            cntrl = CNTRL_CTEXT
        endif
        InsertLine(Format(
            Chr(cntrl),                         // cntrl
            Chr(0),                             // id
            Chr(1),                             // en
            Chr(0),                             // group
            Chr(5),                             // x1
            Chr(i+1-offset),                    // y1
            Chr(BOX_WIDTH-5),                   // x2
            Chr(i+2-offset),                    // y2
            Chr(0),                             // hkpos
            " ",                                // htkey
            line,                               // title
            Chr(END_OF_TITLE)                   // delim
        ))
    endfor

    // insert dialog header

    InsertLine(Format(
        Chr(CNTRL_DIALOG),                      // cntrl
        Chr(0),                                 // id
        Chr(1),                                 // en
        Chr(0),                                 // group
        Chr(BOX_LEFT),                          // x1
        Chr(BOX_TOP),                           // y1
        Chr(BOX_RIGHT),                         // x2
        Chr(BOX_BOTTOM+lines-offset),           // y2
        Chr(0),                                 // hkpos
        " ",                                    // htkey
        header,                                 // title
        Chr(END_OF_TITLE)                       // delim
    ))
end

/****************************************************************************\
    message response function
\****************************************************************************/

public proc MsgBoxBtnDown()
    ExecMacro("DlgTerminate")
end

/****************************************************************************\
    execute dialog
\****************************************************************************/

proc Exec()
    GotoBufferId(resource)
    if not ExecMacro("dialog MsgBox")
        Warn("MsgBox: Cannot load dialog run time library")
    endif
end

/****************************************************************************\
    setup and shutdown
\****************************************************************************/

integer proc Init()
    usr_buff = GetBufferId()
    resource = CreateTempBuffer()
    if not resource
        Warn("MsgBox: Cannot initialize data")
        return (FALSE)
    endif
    return (TRUE)
end

proc Done()
    AbandonFile(resource)
    GotoBufferId(usr_buff)
    PurgeMacro(CurrMacroFilename())
end

/****************************************************************************\
    main program
\****************************************************************************/

proc Main()
    PushBlock()
    if Init()
        Make()
        Exec()
    endif
    Done()
    PopBlock()
end

