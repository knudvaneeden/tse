/****************************************************************************\

    InpBox.S

    CUA style input boxes for SAL

    Version         v2.10/30.11.00
    Copyright       (c) 1995-2000 by DiK

    Overview:

    This macro is a run time library which implements simple input boxes
    using Dialog.S. This macro is not meant to be directly executed by the
    user.

    Usage notes:

    See Program.Doc for instructions on how to use InpBox.S from within
    your own macros.

    History

    v2.10/30.11.00  adaption to TSE32 v3.0
                    þ added global variable DlgMsgText
                    þ fixed truncation of larger inputs
                    þ fixed size of edit contros
    v1.20/25.03.96  maintenance
                    þ added help call back
                    þ fixed clearing of blocks
    v1.10/12.01.96  maintenance
                    þ fixed Ok hotkey
    v1.00/11.10.95  first version

\****************************************************************************/

/****************************************************************************\
    use global variable DlgMsgText
\****************************************************************************/

#define INC_MSGTEXT 1

/****************************************************************************\
    global constants
\****************************************************************************/

#include "dialog.si"

constant ID_EDIT    = 10

constant BOX_HEIGHT = 5
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

integer history                         // history id for edit control

string text[255]                        // contents of edit control
string help_call[32]                    // help function call back

/****************************************************************************\
    push button resource
\****************************************************************************/

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

datadef btn_okcanhelp
    Chr(CNTRL_GROUP) + Chr(0) + Chr(0) + Chr(0) +
        Chr(0) + Chr(0) + Chr(0) + Chr(0) + Chr(0) + Chr(0)
        + " " + Chr(END_OF_TITLE)
    Chr(CNTRL_DEFBTN) + Chr(ID_OK) + Chr(1) + Chr(1) +
        Chr(07) + Chr(BOX_HEIGHT) + Chr(15) + Chr(BOX_HEIGHT+1) + Chr(2)
        + "kOk" + Chr(END_OF_TITLE)
    Chr(CNTRL_BUTTON) + Chr(ID_CANCEL) + Chr(1) + Chr(1) +
        Chr(21) + Chr(BOX_HEIGHT) + Chr(29) + Chr(BOX_HEIGHT+1) + Chr(0)
        + " Cancel" + Chr(END_OF_TITLE)
    Chr(CNTRL_BUTTON) + Chr(ID_HELP) + Chr(1) + Chr(1) +
        Chr(35) + Chr(BOX_HEIGHT) + Chr(43) + Chr(BOX_HEIGHT+1) + Chr(0)
        + " Help" + Chr(END_OF_TITLE)
    Chr(CNTRL_GROUP) + Chr(0) + Chr(0) + Chr(0) +
        Chr(0) + Chr(0) + Chr(0) + Chr(0) + Chr(0) + Chr(0)
        + " " + Chr(END_OF_TITLE)
end

/****************************************************************************\
    make dialog resource
\****************************************************************************/

proc Make()
    integer use_text, end_edit
    string title[32], prompt[45]
    string command[255] = Query(MacroCmdLine)

    // parse command line

    GotoBufferId(resource)

    history   = Val(GetToken(command,Chr(13),1))
    title     = GetToken(command,Chr(13),2)
    prompt    = GetToken(command,Chr(13),3)
    text      = GetToken(command,Chr(13),4)
    help_call = GetToken(command,Chr(13),5)
    use_text  = Val(GetToken(command,Chr(13),6))

    if use_text
        text = GetGlobalStr(DlgMsgText)
    endif

    // compute right boundary of edit control

    end_edit = iif( history, 42, 45 )

    // insert push button resource

    if Length(help_call)
        InsertData(btn_okcanhelp)
    else
        InsertData(btn_okcan)
    endif
    BegFile()

    // insert open control

    if history
        InsertLine(Format(
            Chr(CNTRL_OPEN),                        // cntrl
            Chr(0),                                 // id
            Chr(1),                                 // en
            Chr(0),                                 // group
            Chr(end_edit),                          // x1
            Chr(3),                                 // y1
            Chr(end_edit+3),                        // x2
            Chr(4),                                 // y2
            Chr(0),                                 // hkpos
            " ",                                    // htkey
            Chr(END_OF_TITLE)                       // delim
        ))
    endif

    // insert edit control

    InsertLine(Format(
        Chr(CNTRL_EDIT),                        // cntrl
        Chr(ID_EDIT),                           // id
        Chr(1),                                 // en
        Chr(0),                                 // group
        Chr(5),                                 // x1
        Chr(3),                                 // y1
        Chr(end_edit),                          // x2
        Chr(12),                                // y2
        Chr(0),                                 // hkpos
        " ",                                    // htkey
        text,                                   // title
        Chr(END_OF_TITLE)                       // delim
    ))

    // insert prompt text

    InsertLine(Format(
        Chr(CNTRL_LTEXT),                       // cntrl
        Chr(0),                                 // id
        Chr(1),                                 // en
        Chr(0),                                 // group
        Chr(5),                                 // x1
        Chr(2),                                 // y1
        Chr(45),                                // x2
        Chr(3),                                 // y2
        Chr(0),                                 // hkpos
        " ",                                    // htkey
        prompt,                                 // title
        Chr(END_OF_TITLE)                       // delim
    ))

    // insert dialog header

    InsertLine(Format(
        Chr(CNTRL_DIALOG),                      // cntrl
        Chr(0),                                 // id
        Chr(1),                                 // en
        Chr(0),                                 // group
        Chr(BOX_LEFT),                          // x1
        Chr(BOX_TOP),                           // y1
        Chr(BOX_RIGHT),                         // x2
        Chr(BOX_BOTTOM),                        // y2
        Chr(0),                                 // hkpos
        " ",                                    // htkey
        title,                                  // title
        Chr(END_OF_TITLE)                       // delim
    ))
end

/****************************************************************************\
    message response function
\****************************************************************************/

public proc InpBoxDataInit()
    ExecMacro(Format("DlgSetData ",ID_EDIT," ",history))
end

public proc InpBoxDataDone()
    ExecMacro(Format("DlgGetTitle ",ID_EDIT))
    text = Query(MacroCmdLine)
end

public proc InpBoxBtnDown()
    if CurrChar(POS_ID) == ID_HELP
        ExecMacro(help_call)
    else
        ExecMacro("DlgTerminate")
    endif
end

/****************************************************************************\
    execute dialog
\****************************************************************************/

proc Exec()
    GotoBufferId(resource)
    if not ExecMacro("dialog InpBox")
        Warn("InpBox: Cannot load dialog run time library")
    endif
end

/****************************************************************************\
    setup and shutdown
\****************************************************************************/

integer proc Init()
    usr_buff = GetBufferId()
    resource = CreateTempBuffer()
    if not resource
        Warn("InpBox: Cannot initialize data")
        return (FALSE)
    endif
    return (TRUE)
end

proc Done()
    SetGlobalStr(DlgMsgText,text)
    Set(MacroCmdLine,Format(Chr(Val(Query(MacroCmdLine))),text))
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

