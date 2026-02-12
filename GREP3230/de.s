/****************************************************************************\

    DE.S

    Dialog resource editor.

    Version         v2.10/30.11.00
    Copyright       (c) 1996-2000 by DiK

    Overview:

    This macro is the dialog resource editor used with Dialog.S.
    It allows you to interactively build and edit dialog resources.

    Command Line Format:

    DE [filename]

    where:

        filename    name of the dialog resource to be loaded

    Usage notes:

    See Program.Doc for detailed instructions on how to use DE.S to
    build and compile your own dialog resources. See on-line help for
    key assignments and menu commands.

    History

    v2.10/30.11.00  adaption to TSE32 v3.0
                    þ fixed cursor positioning at shutdown
                    þ fixed spurious null events at shutdown
    v2.01/17.03.97  maintenance
                    þ added dynamic coordinate display
    v2.00/24.10.96  adaption to TSE32
                    þ added buffered video output
                    þ fixed size of name strings
                    þ fixed quoting long filenames
    v1.23/27.06.96  maintenance
                    þ fixed menu pop up on excape key
    v1.22/18.06.96  maintenance
                    þ fixed initial PopWinOpen call
    v1.21/29.05.96  maintenance
                    þ use Set(MsgLevel) instead of PushKey(<Escape>)
    v1.20/25.03.96  first version

    Remarks:

    DE must handle events in a special way so that it does not upset
    the painting routines of the dialog run time library. Therefore,
    it ignores the incoming events and waits for its own keystrokes.
    While waiting DE can safely display the marking frame. After
    handling its event DE clears the original event and pushes a
    KEY_NOTHING to force an immediate return from the dialogs event
    handler. NOTE: The marking frame MUST NOT be displayed while
    control is back within the dialog library.

    Limitations:

    þ Cannot undo changes
    þ Cannot handle multiple include files
    þ Cannot mark and move multiple controls
    þ Cannot check identifiers for duplicates

    Acknowledgements:

    þ thanks to Chris Antos and Dave Guyer
        for testing a preliminary version of this program

\****************************************************************************/

/****************************************************************************\
    external constants
\****************************************************************************/

#include "dialog.si"

/****************************************************************************\
    shared code
\****************************************************************************/

#define INC_QUOTE   1
#define INC_UNQUOTE 1

#include "scver.si"
#include "scruns.si"
#include "sctoken.si"

/****************************************************************************\
    constants
\****************************************************************************/

constant                                // main loop continuation flags
    RC_CONT     = 0,
    RC_EXIT     = 1,
    RC_SAVE     = 2,
    RC_IDENT    = 3,
    RC_SOURCE   = 4,
    RC_TEST     = 5

constant                                // mouse click location
    CT_NONE     = FALSE,
    CT_CNTRL    = TRUE,
    CT_DIALOG   = TRUE + 1

#ifdef WIN32
constant
    KEY_CANCEL  = <LeftRightBtn>
#else
constant
    KEY_CANCEL  = <0xE803>
#endif

/****************************************************************************\
    global variables
\****************************************************************************/

string inpname[255] = "*.d"             // input file
string incname[255]                     // file for symbolic constants

integer ticks                           // display (tick count)
integer DlgX1, DlgY1                    // ditto (dialog coordinates)

integer usrfile                         // buffer id (user file)
integer inpfile                         // ditto (input file)
integer incfile                         // ditto (include file)
integer incbuff                         // ditto (include files)
integer dlgbuff                         // ditto (binary resource)
integer tmpbuff                         // ditto (tab order editing)

integer invalid                         // flag (invalid input file)
integer retcode                         // ditto (closing action)
integer testing                         // ditto (currently testing dialog)
integer dirty                           // ditto (source code changed)
integer dragit                          // ditto (move frame, otherwise size)
integer framed                          // ditto (current control is framed)

integer dlged_focus                     // focused control (overrides dialog)
integer ins_X1,ins_Y1                   // insertion position for new cntrl

/****************************************************************************\
    color values
\****************************************************************************/

integer clr_bkgd    = Color( black on black )
integer clr_frame   = Color( bright red on white )

/****************************************************************************\
    current control description
\****************************************************************************/

string cntrl_type[8]
string cntrl_id[16]
string cntrl_en[4]
string cntrl_x1[4]
string cntrl_y1[4]
string cntrl_x2[4]
string cntrl_y2[4]
string cntrl_title[255]
string cntrl_hint[255]

/****************************************************************************\
    compiler syntax
\****************************************************************************/

string rule1[] = '^[ \t]@{[~ \t]#}\c'                   // key words
string rule3[] = '^[ \t]#{[A-Za-z][0-9A-Z_a-z]#}\c'     // identifiers
string rule5[] = '^[ \t]@\#include[ \t]#"\c{.#}"$'      // include statement
string ruleA[] = '^[ \t]@constant[ \t]#'                // partial const defs
string ruleB[] = '\c{[A-Z_a-z][0-9A-Z_a-z]#}'
string ruleC[] = '[ \t]@=[ \t]@{[0-9]#}$'

/****************************************************************************\
    template for new dialogs
\****************************************************************************/

datadef DialogTemplate
    'dialog  0               1 10  5 70 20 "Dialog Template"'
    '#include "xxxxxx.si"'
    '#include "dialog.si"'
    'group'
    'defbtn  ID_OK           1 45  2 57  3 "O&k"'
    'button  ID_CANCEL       1 45  4 57  5 "Cancel"'
    'group'
end

/****************************************************************************\
    help screens
\****************************************************************************/

helpdef MainHelp
    title = "Help on Dialog Editor"
    x = 8
    y = 1
    width = 64
    height = 18

    ""
    " DE is used to interactively build and edit dialog resources."
    " Using DE you can change the position and size of controls,"
    " display and alter their properties and add new controls."
    ""
    " Key assignments"
    ""
    "   F1                  this help"
    "   F10                 pop up main menu"
    "   Alt F10             pop up object menu"
    "   Tab                 mark next control"
    "   Shift Tab           mark previous control"
    "   CursorKey           move marked control"
    "   Ctrl CursorKey      size marked control"
    "   Enter               edit properties of current control"
    "   Ctrl Enter          edit properties of dialog"
    "   Ctrl Del            delete current control"
    ""
    " Mouse key assignments"
    ""
    "   LeftClick           mark control"
    "   LeftDrag            move control"
    "   Ctrl LeftDrag       size control"
    "   RightClick          pop up object menu"
    ""
    " Main menu commands"
    ""
    "   New                 insert a new control"
    "   Refresh             repaint dialog"
    "   Properties          edit properties of dialog"
    "   Help                this help"
    "   Exit                close DE (prompts to save changes)"
    ""
    " Utilities menu commands"
    ""
    "   Tab Order           determine tab order (point and click)"
    "   Add Group           mark groups (point and drag)"
    "   Identifiers         open symbol list"
    "   Edit Source         open source list"
    "   Test Dialog         run dialog in view mode (c.f. DD)"
    ""
    " Object menu commands"
    ""
    "   Duplicate           duplicate control"
    "   Delete              delete control"
    "   Properties          edit properties of current control"
    ""
    " Miscellaneous"
    ""
    "   To abort dragging a control, either type <Escape> or click"
    "   the <RightBtn> while you are still holding the <LeftBtn>."
    "   To remove the frame which marks a control, either press"
    "   <Escape> or click outside the dialog window. Simply click"
    "   multiple times to cycle through controls which are stacked"
    "   on top of each other."
    ""
end

helpdef SourceHelp
    title = "Help on Source Listing"
    x = 8
    y = 1
    width = 64
    height = 18

    ""
    " This list displays the source code of the dialog. It allows"
    " you to quickly position controls. You can also add, duplicate"
    " and edit controls. DE keeps a backup copy of the list so that"
    " you can abort erroneous changes you made."
    ""
    " Key assignments"
    ""
    "   F1                  this help"
    "   F10                 pop up menu"
    "   Ctrl CursorUp       move current line up"
    "   Ctrl CursorDown     move current line down"
    "   Enter               edit current line"
    "   Ins                 insert a new line"
    "   Ctrl Del            delete current line"
    "   Escape              close list (prompts to save changes)"
    ""
    " Mouse key assignments"
    ""
    "   LeftBtn             edit current line"
    "   RightBtn            set cursor and pop up menu"
    ""
    " Menu commands"
    ""
    "   New                 insert a new control"
    "   Edit                edit current control"
    "   Add Group           add a group statement"
    "   Duplicate           duplicate current control"
    "   Delete              delete current control"
    "   Help                this help"
    "   Exit                close list (prompts to save changes)"
    ""
end

helpdef IdentHelp
    title = "Help on Identifier Listing"
    x = 8
    y = 1
    width = 64
    height = 19

    ""
    " This list displays the symbolic constants which have been"
    " defined for the current dialog. You can delete symbols from"
    " the list and add new ones. You can also change the names and"
    " values of the constants. DE keeps a backup copy of the list"
    " so that you can abort erroneous changes you made."
    ""
    " Key assignments"
    ""
    "   F1                  this help"
    "   F10                 pop up menu"
    "   Ctrl CursorUp       move current line up"
    "   Ctrl CursorDown     move current line down"
    "   Enter               edit current symbol"
    "   Ins                 insert a new symbol"
    "   Ctrl Del            delete current symbol"
    "   Escape              close list (prompts to save changes)"
    ""
    " Mouse key assignments"
    ""
    "   LeftBtn             edit current line"
    "   RightBtn            set cursor and pop up menu"
    ""
    " Menu commands"
    ""
    "   New                 insert a new symbol"
    "   Edit                edit current symbol"
    "   Duplicate           duplicate current symbol"
    "   Delete              delete current symbol"
    "   Help                this help"
    "   Exit                close list (prompts to save changes)"
    ""
end

/****************************************************************************\
    painting routines
\****************************************************************************/

proc CloseFrame()
    if framed
        PopWinClose()
        framed = FALSE
    endif
    DlgX1 = Query(PopWinX1)
    DlgY1 = Query(PopWinY1)
end

proc OpenFrame()
    integer x1 = CurrChar(POS_X1) - 2
    integer y1 = CurrChar(POS_Y1) - 2
    integer xl = CurrChar(POS_X2) - x1 - 1
    integer yl = CurrChar(POS_Y2) - y1 - 1
    string err[16] = "out of memory"

    CloseFrame()
    if not (CurrChar(POS_CNTRL) in CNTRL_DIALOG,CNTRL_GROUP)
        x1 = x1 + Query(PopWinX1)
        y1 = y1 + Query(PopWinY1)
        if PopWinOpen(x1,y1,x1+xl,y1+yl,1,"",clr_frame)
            framed = TRUE
        else
            Warn(err)
        endif
    endif
end

proc ClearScreen()
    Set(Attr,clr_bkgd)
    ClrScr()
    GotoBufferId(dlgbuff)
end

proc SetMenuMouse( integer offset )
    MouseStatus()
    Set(X1,Max(1,Query(MouseX))-2)
    Set(Y1,Max(1,Query(MouseY))-offset)
end

proc SetMenuFrame()
    Set(X1,Query(PopWinX1))
    Set(Y1,Query(PopWinY1))
end

proc SetMenuTop()
    Set(X1,1)
    Set(Y1,2)
end

proc UpdateDialog()
    CloseFrame()
    ExecMacro("DlgShowWindow 0")
    ClearScreen()
    ExecMacro("DlgShowWindow 1")
end

proc Terminate( integer code )
    retcode = code
    ExecMacro("DlgTerminate")
end

/****************************************************************************\
    compile input file
\****************************************************************************/

integer proc CompileInput()
    string name[255]
    string err[64] = "Cannot load include file: "

    // save and clear buffers

    if GotoBufferId(incfile)
        SaveFile()
    endif
    EmptyBuffer(incfile)
    EmptyBuffer(incbuff)
    AbandonFile(dlgbuff)

    // compile input file

    GotoBufferId(inpfile)
    if not ExecDialog("DC -k -r")
        Warn("Cannot launch dialog compiler.")
        return (FALSE)
    endif

    // save and check pointer to binary info

    dlgbuff = Val(Query(MacroCmdLine))
    if dlgbuff == 0
        invalid = TRUE
        return (FALSE)
    endif

    // load include files

    GotoBufferId(incfile)
    if not InsertFile(incname,_DONT_PROMPT_)
        Warn(err,incname,".")
        return (FALSE)
    endif

    GotoBufferId(inpfile)
    BegFile()
    while lFind(rule5,"ix")
        MarkFoundText(1)
        name = GetMarkedText()
        GotoBufferId(incbuff)
        BegFile()
        if not InsertFile(name,_DONT_PROMPT_)
            Warn(err,name,".")
            return (FALSE)
        endif
        GotoBufferId(inpfile)
    endwhile

    // goto dialog resource

    GotoBufferId(dlgbuff)
    dirty = FALSE
    return (TRUE)
end

/****************************************************************************\
    compiler functions
\****************************************************************************/

proc SearchControl()
    integer num

    num = CurrLine()
    GotoBufferId(inpfile)
    BegFile()
    repeat
        if CurrChar(1) > 0
        and not (CurrChar(PosFirstNonWhite()) in Asc("#"),Asc("/"))
            num = num - 1
        endif
    until num == 0 or not Down()
end

proc SplitControl()

    // goto current position within source file

    SearchControl()

    // split control (first part)

    lFind('^ *{[~ ]#} *{[~ ]#} *{[~ ]#} *{[~ ]#} *{[~ ]#} *{[~ ]#} *{[~ ]#}\c','cgx')
    MarkFoundText(1)
    cntrl_type = GetMarkedText()
    MarkFoundText(2)
    cntrl_id = GetMarkedText()
    MarkFoundText(3)
    cntrl_en = GetMarkedText()
    MarkFoundText(4)
    cntrl_x1 = GetMarkedText()
    MarkFoundText(5)
    cntrl_y1 = GetMarkedText()
    MarkFoundText(6)
    cntrl_x2 = GetMarkedText()
    MarkFoundText(7)
    cntrl_y2 = GetMarkedText()

    // split control (second part)

    MarkToEol()
    lFind('^ *"{[~"]@}"$|{,"{[~"]@}"$}','lgx')
    MarkFoundText(1)
    cntrl_title = GetMarkedText()
    MarkFoundText(3)
    cntrl_hint = GetMarkedText()

    // go back to resource buffer

    GotoBufferId(dlgbuff)
end

proc CompileControl()
    integer x1 = Val(cntrl_x1)
    integer x2 = Val(cntrl_x2)
    integer y1 = Val(cntrl_y1)
    integer y2 = Val(cntrl_y2)
    integer cntrl, id, hkpos
    string htkey[1]

    // check insertion position

    if x1 < 1 or y1 < 1 or x1 >= x2 or y1 >= y2
        Alarm()
        Warn("Invalid position or size.")
        return ()
    endif

    // goto current position within source file

    SearchControl()

    // insert new control (source file)

    BegLine()
    KillToEol()
    InsertText(Format(
        cntrl_type  :-8,
        cntrl_id    :-16,
        cntrl_en    :1,
        cntrl_x1    :3,
        cntrl_y1    :3,
        cntrl_x2    :3,
        cntrl_y2    :3,
        ' "',cntrl_title,'"',
        iif( Length(cntrl_hint), Format(',"',cntrl_hint,'"') , '' )
    ))

    // compile new control

    case Lower(cntrl_type)
        when "dialog"   cntrl = CNTRL_DIALOG
        when "frame"    cntrl = CNTRL_FRAME
        when "ltext"    cntrl = CNTRL_LTEXT
        when "rtext"    cntrl = CNTRL_RTEXT
        when "ctext"    cntrl = CNTRL_CTEXT
        when "open"     cntrl = CNTRL_OPEN
        when "edit"     cntrl = CNTRL_EDIT
        when "button"   cntrl = CNTRL_BUTTON
        when "defbtn"   cntrl = CNTRL_DEFBTN
        when "radio"    cntrl = CNTRL_RADIO
        when "check"    cntrl = CNTRL_CHECK
        when "combo"    cntrl = CNTRL_COMBO
        when "list"     cntrl = CNTRL_LIST
        when "vscroll"  cntrl = CNTRL_VSCROLL
        when "hscroll"  cntrl = CNTRL_HSCROLL
        when "scredge"  cntrl = CNTRL_SCREDGE
        when "control"  cntrl = CNTRL_CONTROL
    endcase

    if cntrl in CNTRL_DIALOG,CNTRL_EDIT
        hkpos = 0
    else
        hkpos = Pos("&",cntrl_title)
    endif
    if hkpos
        htkey = cntrl_title[hkpos+1]
        cntrl_title = DelStr(cntrl_title,hkpos,1)
    else
        htkey = " "
    endif

    id = Val(cntrl_id)
    if id == 0 and cntrl_id <> "0"
        GotoBufferId(incbuff)
        if lFind(ruleA+cntrl_id+ruleC,"gix")
            MarkFoundText(2)
            id = Val(GetMarkedText())
        endif
    endif

    // insert new control (binary format)

    GotoBufferId(dlgbuff)
    BegLine()
    KillToEol()
    InsertText(Format(
        Chr(cntrl),
        Chr(id),
        Chr(Val(cntrl_en)),
        Chr(0),
        Chr(x1),
        Chr(y1),
        Chr(x2),
        Chr(y2),
        Chr(hkpos),
        htkey,
        cntrl_title,
        Chr(END_OF_TITLE),
        cntrl_hint
    ))

    // mark source changed

    dirty = TRUE
end

/****************************************************************************\
    editor functions
\****************************************************************************/

proc MoveControl( integer x1, integer y1, integer x2, integer y2 )
    SplitControl()
    if Val(cntrl_x1) <> x1 or Val(cntrl_x2) <> x2
    or Val(cntrl_y1) <> y1 or Val(cntrl_y2) <> y2
        cntrl_x1 = Str(x1)
        cntrl_x2 = Str(x2)
        cntrl_y1 = Str(y1)
        cntrl_y2 = Str(y2)
        CompileControl()
        UpdateDialog()
    endif
end

proc DeleteControl()
    if CurrChar(POS_CNTRL) <> CNTRL_DIALOG
        SearchControl()
        KillLine()
        GotoBufferId(dlgbuff)
        KillLine()
        BegFile()
        UpdateDialog()
        dirty = TRUE
    endif
end

proc DuplicateControl()
    integer copies
    integer maximum
    string text[8] = "1"

    if Query(Key) in <LeftBtn>,<RightBtn>
        SetMenuMouse(2)
    else
        SetMenuFrame()
    endif
    if AskNumeric("Copies?",text)
        copies = Val(text)
        maximum = Query(ScreenRows) - Query(PopWinY1)       // framed !
        if copies > maximum
            Warn("Copies do not fit onto screen.")
        else
            do copies times
                SearchControl()
                DupLine()
                GotoBufferId(dlgbuff)
                DupLine()
                SplitControl()
                cntrl_y1 = Str(Val(cntrl_y1)+1)
                cntrl_y2 = Str(Val(cntrl_y2)+1)
                CompileControl()
            enddo
            UpdateDialog()
        endif
    endif
end

/****************************************************************************\
    finding controls via rodent
\****************************************************************************/

integer proc MouseHitDialog()
    integer xm = Query(MouseX)
    integer ym = Query(MouseY)

    return (
        CurrChar(POS_X1) <= xm and xm <= CurrChar(POS_X2) and
        CurrChar(POS_Y1) <= ym and ym <= CurrChar(POS_Y2)
    )
end

integer proc MouseHit()
    integer xm = Query(MouseX) - Query(PopWinX1) + 1
    integer ym = Query(MouseY) - Query(PopWinY1) + 1

    return (
        CurrChar(POS_X1) <= xm and xm < CurrChar(POS_X2) and
        CurrChar(POS_Y1) <= ym and ym < CurrChar(POS_Y2)
    )
end

integer proc MouseHitFirstLine()
    integer xm = Query(MouseX) - Query(PopWinX1) + 1
    integer ym = Query(MouseY) - Query(PopWinY1) + 1

    return (
        CurrChar(POS_Y1) == ym and
        CurrChar(POS_X1) <= xm and xm < CurrChar(POS_X2)
    )
end

integer proc TestCurrCntrl()
    integer hit

    case CurrChar(POS_CNTRL)
        when CNTRL_DIALOG
            hit = FALSE
        when CNTRL_EDIT,CNTRL_COMBO
            hit = MouseHitFirstLine()
        otherwise
            hit = MouseHit()
    endcase
    return (hit)
end

integer proc ScanForCntrl( integer stop )
    while Down() and CurrLine() <= stop
        if TestCurrCntrl()
            return (TRUE)
        endif
    endwhile
    return (FALSE)
end

integer proc GotoLeftBtn()
    integer stop = CurrLine()

    if ScanForCntrl(NumLines())
        return (CT_CNTRL)
    endif
    BegFile()
    if ScanForCntrl(stop)
        return (CT_CNTRL)
    endif
    BegFile()
    if MouseHitDialog()
        return (CT_DIALOG)
    endif
    GotoLine(stop)
    return (CT_NONE)
end

integer proc GotoRightBtn()
    if TestCurrCntrl()
        return (CT_CNTRL)
    endif
    return (GotoLeftBtn())
end

/****************************************************************************\
    finding controls via keyboard
\****************************************************************************/

proc NextControl()
    integer wrapped = FALSE

    repeat
        if not Down()
            if wrapped
                return ()
            else
                BegFile()
                wrapped = TRUE
            endif
        endif
    until not (CurrChar(POS_CNTRL) in CNTRL_DIALOG,CNTRL_GROUP)
end

proc PrevControl()
    integer wrapped = FALSE

    repeat
        if not Up()
            if wrapped
                return ()
            else
                EndFile()
                BegLine()
                wrapped = TRUE
            endif
        endif
    until not (CurrChar(POS_CNTRL) in CNTRL_DIALOG,CNTRL_GROUP)
end

/****************************************************************************\
    moving and sizing controls via rodent
\****************************************************************************/

integer proc DragFrame( var integer x1, var integer y1, var integer xl, var integer yl )
    integer dx, dy, xm, ym
    integer x0 = Query(PopWinX1) - 2
    integer y0 = Query(PopWinY1) - 2
    string err[16] = "out of memory"

    if dragit
        xm = Query(ScreenCols) - xl
        ym = Query(ScreenRows) - yl
    else
        xm = Query(ScreenCols) - x1
        ym = Query(ScreenRows) - y1
    endif

    if not PopWinOpen(x1,y1,x1+xl,y1+yl,1,"",clr_frame)
        Warn(err)
        return (FALSE)
    endif
    Message("Pos (",x1-x0,"/",y1-y0,"), Size (",xl-1,"/",yl-1,")")
    while MouseKeyHeld()
        if KeyPressed() and (GetKey() in <Escape>,KEY_CANCEL)
            PopWinClose()
            return (FALSE)
        endif
        dx = Query(MouseX) - Query(LastMouseX)
        dy = Query(MouseY) - Query(LastMouseY)
        if dx or dy
            if dragit
                x1 = Min(Max(1,x1+dx),xm)
                y1 = Min(Max(1,y1+dy),ym)
            else
                xl = Min(Max(2,xl+dx),xm)
                yl = Min(Max(2,yl+dy),ym)
            endif
            Message("Pos (",x1-x0,"/",y1-y0,"), Size (",xl-1,"/",yl-1,")")
            PopWinClose()
            if not PopWinOpen(x1,y1,x1+xl,y1+yl,1,"",clr_frame)
                Warn(err)
                return (FALSE)
            endif
        endif
    endwhile
    PopWinClose()
    return (TRUE)
end

proc DragDialog()
    integer x1 = Query(PopWinX1) - 1
    integer y1 = Query(PopWinY1) - 1
    integer xl = Query(PopWinCols) + 1
    integer yl = Query(PopWinRows) + 1

    if DragFrame(x1,y1,xl,yl)
        MoveControl(x1,y1,x1+xl,y1+yl)
    endif
end

proc DragControl()
    integer x1 = CurrChar(POS_X1) - 2
    integer y1 = CurrChar(POS_Y1) - 2
    integer xl = CurrChar(POS_X2) - x1 - 1
    integer yl = CurrChar(POS_Y2) - y1 - 1

    x1 = x1 + Query(PopWinX1)
    y1 = y1 + Query(PopWinY1)
    if DragFrame(x1,y1,xl,yl)
        x1 = x1 - Query(PopWinX1) + 2
        y1 = y1 - Query(PopWinY1) + 2
        MoveControl(x1,y1,x1+xl-1,y1+yl-1)
    endif
end

proc MouseDrag( integer move_it )
    dragit = move_it
    if GotoLeftBtn()
        if CurrChar(POS_CNTRL) == CNTRL_DIALOG
            DragDialog()
        else
            DragControl()
        endif
    else
        BegFile()
    endif
end

/****************************************************************************\
    moving and sizing controls via keyboard
\****************************************************************************/

proc KeyDrag( integer DX1, integer DY1, integer DX2, integer DY2 )
    integer X1 = CurrChar(POS_X1) + DX1
    integer X2 = CurrChar(POS_X2) + DX2
    integer Y1 = CurrChar(POS_Y1) + DY1
    integer Y2 = CurrChar(POS_Y2) + DY2

    if  X2-2 < Query(ScreenCols)-Query(PopWinX1)
    and Y2-2 < Query(ScreenRows)-Query(PopWinY1)
        MoveControl(X1,Y1,X2,Y2)
    endif
end

/****************************************************************************\
    group editor
\****************************************************************************/

proc AddGroup()
    integer rc
    integer x1, y1, x2 = 1, y2 = 1

    // determine frame for group

    Message("Left click and drag frame. Esc or Right click to cancel.")
    loop
        case GetKey()
            when <LeftBtn>
                break
            when <Escape>,<RightBtn>
                Terminate(RC_CONT)
                return()
            otherwise
                Alarm()
        endcase
    endloop
    x1 = Query(MouseX)
    y1 = Query(MouseY)
    dragit = FALSE
    if not DragFrame(x1,y1,x2,y2)
        Terminate(RC_CONT)
        return()
    endif
    x1 = x1 - Query(PopWinX1) + 2
    y1 = y1 - Query(PopWinY1) + 2
    x2 = x1 + x2 - 1
    y2 = y1 + y2 - 1

    // search framed controls

    lFind(Chr(0),"g^")
    Down()
    repeat
        rc = x1 <= CurrChar(POS_X1) and CurrChar(POS_X1) <= x2
         and y1 <= CurrChar(POS_Y2) and CurrChar(POS_Y2) <= y2
    until rc or not Down()
    if rc
        SearchControl()
        PushPosition()
        GotoBufferId(dlgbuff)
        repeat
            rc = x1 <= CurrChar(POS_X1) and CurrChar(POS_X1) <= x2
             and y1 <= CurrChar(POS_Y2) and CurrChar(POS_Y2) <= y2
        until not rc or not Down()
        SearchControl()
        if rc
            AddLine("group")
        else
            InsertLine("group")
        endif
        PopPosition()
        InsertLine("group")
    endif

    // clean up and recompile

    Terminate(RC_SAVE)
end

/****************************************************************************\
    tab order editor
\****************************************************************************/

proc TabOrder()
    integer ilba
    integer count = 1
    integer event
    integer cntrl,other

    // warn user about his activities

    Alarm()
    Message("This will remove groups, blank lines and comments!")
    SetMenuTop()
    if YesNo("Continue?") <> 1
        UpdateDialog()
        return ()
    endif

    // remove comments and empty lines

    GotoBufferId(inpfile)
    while lFind("^ *//","gx")
        KillLine()
    endwhile
    while lFind("^$","gx")
        KillLine()
    endwhile

    // remove group statements

    GotoBufferId(inpfile)
    while lFind("group","gi^")
        KillLine()
    endwhile
    GotoBufferId(dlgbuff)
    while lFind(Chr(CNTRL_GROUP),"gi^")
        KillLine()
    endwhile

    // determine new order

    loop
        Message("Left click at control #",count,". Right click to quit.")
        event = GetKey()
        case event
            when <LeftBtn>
                if GotoLeftBtn() == CT_CNTRL
                    SearchControl()
                    cntrl = CurrLine()
                    GotoBufferId(tmpbuff)
                    if lFind(Str(cntrl),"g^")
                        Alarm()
                    else
                        count = count + 1
                        AddLine(Str(cntrl))
                    endif
                    GotoBufferId(dlgbuff)
                else
                    Alarm()
                endif
            when <RightBtn>
                break
            otherwise
                Alarm()
        endcase
    endloop

    // search insertion position

    GotoBufferId(inpfile)
    BegFile()
    repeat
        Down()
    until CurrChar(1) > 0 and CurrChar(PosFirstNonWhite()) <> Asc("#")

    // sort controls

    ilba = Set(InsertLineBlocksAbove,TRUE)
    GotoBufferId(tmpbuff)

    while NumLines()
        BegFile()
        cntrl = Val(GetText(1,CurrLineLen()))
        while Down()
            other = Val(GetText(1,CurrLineLen()))
            if other < cntrl
                BegLine()
                InsertText(Str(other+1),_OVERWRITE_)
            endif
        endwhile
        BegFile()
        KillLine()
        GotoBufferId(inpfile)
        if cntrl > CurrLine()
            MarkLine(cntrl,cntrl)
            MoveBlock()
            UnmarkBlock()
        endif
        Down()
        GotoBufferId(tmpbuff)
    endwhile

    Set(InsertLineBlocksAbove,ilba)

    // clean up and recompile

    Terminate(RC_SAVE)
end

/****************************************************************************\
    source editor helper
\****************************************************************************/

proc BackupData( integer bid )
    GotoBufferId(bid)
    MarkLine(1,NumLines())
    GotoBufferId(tmpbuff)
    CopyBlock()
    UnmarkBlock()
    GotoBufferId(bid)
    BegFile()
end

proc RestoreData( integer bid )
    GotoBufferId(tmpbuff)
    MarkLine(1,NumLines())
    GotoBufferId(bid)
    EmptyBuffer()
    CopyBlock()
    UnmarkBlock()
    BegFile()
end

proc Slide( integer totop )
    integer ilba, km

    km = Set(KillMax,1)
    ilba = Set(InsertLineBlocksAbove,TRUE)
    if totop
        DelLine()
        Up()
        UnDelete()
    else
        if Down()
            DelLine()
            Up()
            UnDelete()
            Down()
        endif
    endif
    Set(InsertLineBlocksAbove,ilba)
    Set(KillMax,km)
    dirty = TRUE
end

proc QuitSourceEdit()
    if dirty
        if Query(Key) in <LeftBtn>,<RightBtn>
            SetMenuMouse(1)
        endif
        case YesNo("Save Changes?")
            when 1  EndProcess(TRUE)
            when 2  EndProcess(FALSE)
        endcase
    else
        EndProcess(FALSE)
    endif
end

/****************************************************************************\
    source file editor
\****************************************************************************/

integer proc ChangeCntrl()
    integer rc = FALSE
    string cntrl[255] = GetText(1,CurrLineLen())

    rc = Ask("Enter/Edit control:",cntrl)
    if rc
        BegLine()
        KillToEol()
        InsertText(cntrl)
        dirty = TRUE
    endif
    EndProcess(-1)
    return (rc)
end

proc InsertCntrl()
    InsertLine()
    if not ChangeCntrl()
        KillLine()
    endif
end

proc DuplicateCntrl()
    DupLine()
    if not ChangeCntrl()
        KillLine()
    endif
end

proc InsertGroup()
    dirty = TRUE
    InsertLine("group")
    EndProcess(-1)
end

proc DeleteCntrl()
    dirty = TRUE
    KillLine()
    EndProcess(-1)
end

menu SourceMenu()
    "&New",             InsertCntrl(),      CloseAllAfter
    "&Edit",            ChangeCntrl(),      CloseAllAfter
    "D&uplicate",       DuplicateCntrl()
    "Add &Group",       InsertGroup()
    "",,        Divide
    "&Delete",          DeleteCntrl()
    "",,        Divide
    "&Help",            QuickHelp(SourceHelp)
    "E&xit",            QuitSourceEdit()
end

proc ShowSourceMenu( integer mouse )
    if mouse
        GotoMouseCursor()
        UpdateDisplay()
        SetMenuMouse(0)
    endif
    SourceMenu()
end

proc GotoAndEditCntrl()
    GotoMouseCursor()
    UpdateDisplay()
    ChangeCntrl()
end

keydef SourceEditKeys
    <F1>                QuickHelp(SourceHelp)
    <Escape>            QuitSourceEdit()
    <LeftBtn>           GotoAndEditCntrl()
    <RightBtn>          ShowSourceMenu(TRUE)
    <F10>               ShowSourceMenu(FALSE)
    <Ctrl CursorUp>     Slide(TRUE)
    <Ctrl CursorDown>   Slide(FALSE)
    <Ctrl Del>          DeleteCntrl()
    <Ins>               InsertCntrl()
    <Enter>             ChangeCntrl()
end

proc SourceEditHook()
    ListFooter(" {Ctrl-}-Up  {Ctrl-}-Down  {Enter}-Edit  {Ins}-New  {Del}-Delete ")
    Enable(SourceEditKeys)
    Unhook(SourceEditHook)
end

proc EditSource()
    integer rc
    integer old_dirt = dirty

    dirty = FALSE
    BackupData(inpfile)
    repeat
        Hook(_LIST_STARTUP_,SourceEditHook)
        rc = List("Dialog Source",80)
    until rc >= 0
    if rc == 0
        dirty = FALSE
        retcode = RC_CONT
        RestoreData(inpfile)
    endif
    EmptyBuffer(tmpbuff)
    dirty = dirty or old_dirt
end

/****************************************************************************\
    id list editor
\****************************************************************************/

integer proc AskIdent( integer set_pos )
    integer rc = FALSE
    integer vid
    string inc[255]
    string id[24] = "0"
    string ident[24] = "0"

    if set_pos
        SetMenuMouse(2)
    else
        ident = cntrl_id
    endif
    if Ask("Enter identifier:",ident) and Length(ident)
        rc = ident == "0" or Val(ident) <> 0
        if not rc
            GotoBufferId(incbuff)
            rc = lFind(ruleA+ident+ruleC,"gix")
            if not rc
                repeat
                    if set_pos
                        SetMenuMouse(2)
                    endif
                    rc = Ask("Enter id value:",id)
                    vid = Val(id)
                until 0 < vid and vid < 256
                if rc
                    inc = Format("constant ",ident," = ",id)
                    GotoBufferId(incfile)
                    EndFile()
                    AddLine(inc)
                    GotoBufferId(incbuff)
                    BegFile()
                    InsertLine(inc)
                    dirty = TRUE
                endif
            endif
            GotoBufferId(dlgbuff)
        endif
        if rc
            cntrl_id = ident
        endif
    endif
    return (rc)
end

integer proc SearchIdent()
    integer rc = FALSE
    string ident[24]

    lFind(ruleA+ruleB+ruleC,"cgix")
    MarkFoundText(1)
    ident = GetMarkedText()

    GotoBufferId(inpfile)
    PushPosition()
    BegFile()

    repeat
        lFind(rule1,"cgx")
        MarkToEol()
        if lFind(rule3,"lgx")
            MarkFoundText(1)
            rc = ident == GetMarkedText()
        endif
    until rc or not Down()

    PopPosition()
    UnmarkBlock()
    GotoBufferId(incfile)

    if rc
        Message("Identfier ",ident,
            " is used. Do you really want to delete or change it?")
        Alarm()
        SetMenuTop()
        rc = YesNo("") == 1
    else
        rc = TRUE
    endif

    return (rc)
end

proc InsertIdent()
    cntrl_id = "id_"
    AskIdent(FALSE)
    GotoBufferId(incfile)
    EndProcess(-1)
end

integer proc ChangeIdent( integer check )
    integer rc
    string id[24], ident[24], new_ident[24]

    lFind(ruleA+ruleB+ruleC,"cgix")
    MarkFoundText(1)
    ident = GetMarkedText()
    MarkFoundText(2)
    id = GetMarkedText()
    UnmarkBlock()
    new_ident = ident
    rc = Ask("Enter identifier:",new_ident) and Length(new_ident)
    if rc
        if check
            if new_ident <> ident
                if SearchIdent()
                    ident = new_ident
                else
                    rc = FALSE
                endif
            endif
        else
            ident = new_ident
        endif
        rc = rc
        and Ask("Enter id value:",id) and 0 < Val(id) and Val(id) < 256
        if rc
            BegLine()
            KillToEol()
            InsertText(Format("constant ",ident," = ",id))
            dirty = TRUE
        endif
    endif
    EndProcess(-1)
    return (rc)
end

proc DuplicateIdent()
    DupLine()
    if not ChangeIdent(FALSE)
        KillLine()
    endif
end

proc DeleteIdent()
    if SearchIdent()
        dirty = TRUE
        KillLine()
    endif
    EndProcess(-1)
end

menu IdentMenu()
    "&New",             InsertIdent(),          CloseAllAfter
    "&Edit",            ChangeIdent(TRUE),      CloseAllAfter
    "D&uplicate",       DuplicateIdent()
    "",,        Divide
    "&Delete",          DeleteIdent()
    "",,        Divide
    "&Help",            QuickHelp(IdentHelp)
    "E&xit",            QuitSourceEdit()
end

proc ShowIdentMenu( integer mouse )
    if mouse
        GotoMouseCursor()
        UpdateDisplay()
        SetMenuMouse(0)
    endif
    IdentMenu()
end

proc GotoAndEditIdent()
    GotoMouseCursor()
    UpdateDisplay()
    ChangeIdent(TRUE)
end

keydef IdentEditKeys
    <F1>                QuickHelp(IdentHelp)
    <Escape>            QuitSourceEdit()
    <LeftBtn>           GotoAndEditIdent()
    <RightBtn>          ShowIdentMenu(TRUE)
    <F10>               ShowIdentMenu(FALSE)
    <Ctrl CursorUp>     Slide(TRUE)
    <Ctrl CursorDown>   Slide(FALSE)
    <Ctrl Del>          DeleteIdent()
    <Ins>               InsertIdent()
    <Enter>             ChangeIdent(TRUE)
end

proc IdentEditHook()
    ListFooter(" {Ctrl-}-Up  {Ctrl-}-Down  {Enter}-Edit  {Ins}-New  {Del}-Delete ")
    Enable(IdentEditKeys)
    Unhook(IdentEditHook)
end

proc EditIdent()
    integer rc
    integer old_dirt = dirty

    dirty = FALSE
    BackupData(incfile)
    repeat
        Hook(_LIST_STARTUP_,IdentEditHook)
        rc = List("List of Identifiers",80)
    until rc >= 0
    if rc == 0
        dirty = FALSE
        retcode = RC_CONT
        RestoreData(incfile)
    endif
    EmptyBuffer(tmpbuff)
    dirty = dirty or old_dirt
end

/****************************************************************************\
    properties helper
\****************************************************************************/

string proc ShowBool( string bool )
    return (iif( bool == "1", "Yes", "No" ))
end

string proc ShowStr( string text )
    return (text)
end

string proc ShowPosStr()
    return (Format(cntrl_x1,",",cntrl_y1,",",cntrl_x2,",",cntrl_y2))
end

proc ToggleBool( var string bool )
    bool = Str(not Val(bool))
end

proc ReadInt( var string text )
    ReadNumeric(text)
end

integer proc AskTitle( integer set_pos )
    string title[255] = ""

    if set_pos
        SetMenuMouse(2)
    else
        title = cntrl_title
    endif
    if Ask("Enter title:",title)
        cntrl_title = title
        return (TRUE)
    endif
    return (FALSE)
end

integer proc AskHint()
    string hint[255] = cntrl_hint

    if Ask("Enter hint:",hint)
        cntrl_hint = hint
        return (TRUE)
    endif
    return (FALSE)
end

/****************************************************************************\
    properties menus
\****************************************************************************/

menu PosMenu()
    history
    width = 12

    "X1"        [ShowStr(cntrl_x1):3],  ReadInt(cntrl_x1),  DontClose
    "Y1"        [ShowStr(cntrl_y1):3],  ReadInt(cntrl_y1),  DontClose
    "X2"        [ShowStr(cntrl_x2):3],  ReadInt(cntrl_x2),  DontClose
    "Y2"        [ShowStr(cntrl_y2):3],  ReadInt(cntrl_y2),  DontClose
end

menu PropsMenu1()
    title = "Control Properties"
    width = 40

    "Control Type"      [ShowStr(cntrl_type):12],,  skip
    "",,        Divide
    "&Identifier"       [ShowStr(cntrl_id):12],,    skip
    "&Enabled"          [ShowBool(cntrl_en):12],,   skip
    "&Position"         [ShowPosStr():12],          PosMenu(),              DontClose
    "",,        Divide
    "&Title"            [ShowStr(cntrl_title):24],  AskTitle(FALSE),        DontClose
    "",,        Divide
    "&Cancel"
    "O&k"
end

menu PropsMenu2()
    title = "Control Properties"
    width = 40

    "Control Type"      [ShowStr(cntrl_type):12],,  skip
    "",,        Divide
    "&Identifier"       [ShowStr(cntrl_id):12],,    skip
    "&Enabled"          [ShowBool(cntrl_en):12],    ToggleBool(cntrl_en),   DontClose
    "&Position"         [ShowPosStr():12],          PosMenu(),              DontClose
    "",,        Divide
    "&Cancel"
    "O&k"
end

menu PropsMenu3()
    title = "Control Properties"
    width = 40

    "Control Type"      [ShowStr(cntrl_type):12],,  skip
    "",,        Divide
    "&Identifier"       [ShowStr(cntrl_id):12],     AskIdent(FALSE),        DontClose
    "&Enabled"          [ShowBool(cntrl_en):12],    ToggleBool(cntrl_en),   DontClose
    "&Position"         [ShowPosStr():12],          PosMenu(),              DontClose
    "",,        Divide
    "&Title"            [ShowStr(cntrl_title):24],  AskTitle(FALSE),        DontClose
    "",,        Divide
    "&Cancel"
    "O&k"
end

menu PropsMenu4()
    title = "Control Properties"
    width = 40

    "Control Type"      [ShowStr(cntrl_type):12],,  skip
    "",,        Divide
    "&Identifier"       [ShowStr(cntrl_id):12],     AskIdent(FALSE),        DontClose
    "&Enabled"          [ShowBool(cntrl_en):12],    ToggleBool(cntrl_en),   DontClose
    "&Position"         [ShowPosStr():12],          PosMenu(),              DontClose
    "",,        Divide
    "&Hint"             [ShowStr(cntrl_hint):24],   AskHint(),              DontClose
    "",,        Divide
    "&Cancel"
    "O&k"
end

menu PropsMenu5()
    title = "Control Properties"
    width = 40

    "Control Type"      [ShowStr(cntrl_type):12],,  skip
    "",,        Divide
    "&Identifier"       [ShowStr(cntrl_id):12],     AskIdent(FALSE),        DontClose
    "&Enabled"          [ShowBool(cntrl_en):12],    ToggleBool(cntrl_en),   DontClose
    "&Position"         [ShowPosStr():12],          PosMenu(),              DontClose
    "",,        Divide
    "&Title "           [ShowStr(cntrl_title):24],  AskTitle(FALSE),        DontClose
    "&Hint "            [ShowStr(cntrl_hint):24],   AskHint(),              DontClose
    "",,        Divide
    "&Cancel"
    "O&k"
end

proc Properties()
    integer test = 10

    SetMenuFrame()

    case CurrChar(POS_CNTRL)
        when CNTRL_DIALOG
            PropsMenu1()
        when CNTRL_OPEN,CNTRL_HSCROLL,CNTRL_VSCROLL,CNTRL_SCREDGE
            test = 8
            PropsMenu2()
        when CNTRL_FRAME,CNTRL_LTEXT,CNTRL_RTEXT,CNTRL_CTEXT
            PropsMenu3()
        when CNTRL_EDIT,CNTRL_COMBO,CNTRL_LIST
            PropsMenu4()
        otherwise
            test = 11
            PropsMenu5()
    endcase

    if MenuOption() == test
        CompileControl()
        UpdateDialog()
    endif
end

/****************************************************************************\
    insert control menu
\****************************************************************************/

proc InsertControl( integer XL, integer YL )
    cntrl_en = "1"
    cntrl_x1 = Str(ins_X1)
    cntrl_y1 = Str(ins_Y1)
    cntrl_x2 = Str(ins_X1 + XL)
    cntrl_y2 = Str(ins_Y1 + YL)
    cntrl_hint = ""
    GotoBufferId(inpfile)
    EndFile()
    AddLine()
    GotoBufferId(dlgbuff)
    EndFile()
    AddLine()
    CompileControl()
    UpdateDialog()
end

proc NewControl( string type )
    if AskTitle(TRUE) and AskIdent(TRUE)
        cntrl_type = type
        InsertControl(12,1)
    endif
end

proc NewCntrlBox( string type )
    if AskIdent(TRUE)
        cntrl_type = type
        cntrl_title = ""
        InsertControl(12,4)
    endif
end

proc NewOpenCntrl()
    cntrl_type = "open"
    cntrl_title = ""
    InsertControl(3,1)
end

proc NewScredgeCntrl()
    cntrl_type = "scredge"
    cntrl_title = ""
    InsertControl(1,1)
end

proc NewScrollBarCntrl( integer vert )
    cntrl_title = ""
    if vert
        cntrl_type = "vscroll"
        InsertControl(1,6)
    else
        cntrl_type = "hscroll"
        InsertControl(12,1)
    endif
end

menu InsTextMenu()
    "&Left Aligned Text",       NewControl("ltext")
    "&Right Aligned Text",      NewControl("rtext")
    "&Center Aligned Text",     NewControl("ctext")
end

menu InsScrollBarMenu()
    "&Vertical Scroll Bar",     NewScrollBarCntrl(TRUE)
    "&Horizontal Scroll Bar",   NewScrollBarCntrl(FALSE)
    "Scroll Bar &Connector",    NewScredgeCntrl()
end

menu InsertMenu()
    "&Button",                  NewControl("button")
    "&Default Button",          NewControl("defbtn")
    "&Check Box",               NewControl("check")
    "&Radio Button",            NewControl("radio")
    "",,        Divide
    "&Edit Control",            NewCntrlBox("edit")
    "&List Box",                NewCntrlBox("list")
    "C&ombo Box",               NewCntrlBox("combo")
    "",,        Divide
    "Drop Down &Arrow",         NewOpenCntrl()
    "&Frame",                   NewCntrlBox("frame")
    "&Text             ",      InsTextMenu(),              DontClose
    "&Scroll Bar       ",      InsScrollBarMenu(),         DontClose
    "",,        Divide
    "C&ustom Control",          NewCntrlBox("control")
end

/****************************************************************************\
    main menus
\****************************************************************************/

menu ObjMenu()
    "D&uplicate",       DuplicateControl()
    "",,        Divide
    "&Delete",          DeleteControl()
    "",,        Divide
    "&Properties",      Properties()
end

menu EditMenu()
    "&Tab Order",       TabOrder()
    "Add &Group",       AddGroup()
    "",,        Divide
    "&Identifiers",     Terminate(RC_IDENT)
    "&Edit Source",     Terminate(RC_SOURCE)
    "",,        Divide
    "Te&st Dialog",     Terminate(RC_TEST)
end

menu MainMenu()
    "&New Control  ",  InsertMenu(),       DontClose
    "",,        Divide
    "&Utilities    ",  EditMenu(),         DontClose
    "&Refresh",         UpdateDialog()
    "",,        Divide
    "&Properties",      Properties()
    "",,        Divide
    "&Help",            QuickHelp(MainHelp)
    "E&xit",            Terminate(RC_EXIT)
end

proc ShowMenu( integer mouse, integer cntrl )
    if cntrl <> CT_CNTRL
        BegFile()
    endif
    OpenFrame()
    if mouse
        SetMenuMouse(1)
        ins_X1 = Max(1,Query(MouseX)-Query(PopWinX1)+1)
        ins_Y1 = Max(1,Query(MouseY)-Query(PopWinY1)+1)
    else
        SetMenuFrame()
        ins_X1 = Query(PopWinX1)+1
        ins_Y1 = Query(PopWinY1)+1
    endif
    SplitControl()
    if framed
        ObjMenu()
    else
        MainMenu()
    endif
end

proc ShowProperties( integer global )
    if global
        BegFile()
    endif
    if not framed
        OpenFrame()
    endif
    SplitControl()
    Properties()
end

proc MainControl()
    BegLine()
    if not BegFile()
        ShowMenu(FALSE,CT_NONE)
    endif
end

/****************************************************************************\
    dialog response functions
\****************************************************************************/

integer proc GetEvent()
    repeat
        if GetClockTicks() > ticks
            ticks = GetClockTicks()
            MouseStatus()
            Message(
                "Pos (",Query(MouseX)-DlgX1+1,"/",Query(MouseY)-DlgY1+1,")")
        endif
    until KeyPressed()
    return(GetKey())
end

public proc DlgEdBtnDown()
    if testing and (CurrChar(POS_CNTRL) in CNTRL_BUTTON,CNTRL_DEFBTN)
        ExecMacro("DlgTerminate")
    endif
end

public proc DlgEdEvent()
    integer event
    integer level = Val(Query(MacroCmdLine))

    // if testing, do nothing

    if testing
        return ()
    endif

    // if inner loop, kill it

    if level
        Set(Key,KEY_BREAK)
        PushKey(KEY_NOTHING)
        return ()
    endif

    // set focus and wait for event

    GotoLine(dlged_focus)
    OpenFrame()
    event = GetEvent()
    CloseFrame()

    // handle event

    case event
        when <F1>                   QuickHelp(MainHelp)
        when <Escape>               MainControl()
        when <Tab>                  NextControl()
        when <Shift Tab>            PrevControl()
        when <CursorLeft>           KeyDrag(-1,0,-1,0)
        when <CursorRight>          KeyDrag(+1,0,+1,0)
        when <CursorUp>             KeyDrag(0,-1,0,-1)
        when <CursorDown>           KeyDrag(0,+1,0,+1)
        when <Ctrl CursorLeft>      KeyDrag(0,0,-1,0)
        when <Ctrl CursorRight>     KeyDrag(0,0,+1,0)
        when <Ctrl CursorUp>        KeyDrag(0,0,0,-1)
        when <Ctrl CursorDown>      KeyDrag(0,0,0,+1)
        when <Enter>                ShowProperties(FALSE)
        when <Ctrl Enter>           ShowProperties(TRUE)
        when <F10>                  ShowMenu(FALSE,CT_NONE)
        when <Alt F10>              ShowMenu(FALSE,CT_CNTRL)
        when <Ctrl Del>             DeleteControl()
        when <LeftBtn>              MouseDrag(TRUE)
        when <Ctrl LeftBtn>         MouseDrag(FALSE)
        when <RightBtn>             ShowMenu(TRUE,GotoRightBtn())
    endcase

    // save focus, clear dialog event and force immediate return

    dlged_focus = CurrLine()
    CloseFrame()
    Set(Key,KEY_NOTHING)
    PushKey(KEY_NOTHING)
end

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

public proc DlgEdPaintCntrl()
    PaintCntrl(Val(Query(MacroCmdLine)))
end

public proc DlgEdExecCntrl()
    PaintCntrl(STATE_ACTIVE)
end

public proc DlgEdGotoCntrl()
    integer move_focus = Val(Query(MacroCmdLine))

    Set(MacroCmdLine,Str(move_focus <> EVENT_GROUP))
end

/****************************************************************************\
    test dialog
\****************************************************************************/

proc TestDialog()
    testing = TRUE
    BackupData(dlgbuff)
    Message("Testing dialog, click any button to quit.")
    ExecMacro("dialog DlgEd")
    RestoreData(dlgbuff)
    EmptyBuffer(tmpbuff)
    testing = FALSE
    retcode = RC_CONT
end

/****************************************************************************\
    trap changes
\****************************************************************************/

integer proc QuitMenu()
    if dirty
        if MenuKey() in <LeftBtn>,<RightBtn>
            SetMenuMouse(1)
        else
            Set(X1,(Query(ScreenCols)-16)/2)
            Set(Y1,(Query(ScreenRows)- 5)/2)
        endif
        case YesNo("Save Changes?")
            when 0  retcode = RC_CONT
            when 2  return (TRUE)
        endcase
    else
        return (TRUE)
    endif
    return (FALSE)
end

/****************************************************************************\
    main event loop
\****************************************************************************/

proc Run()
    repeat

        // init return code

        dlged_focus = 1
        retcode = RC_SAVE

        // run dialog library (handle events via DlgEdEvent)

        ClearScreen()
        ExecMacro("dialog DlgEd")
        if Query(MacroCmdLine) == "-1"
            break
        endif

        // check return code

        case retcode
            when RC_EXIT
                if QuitMenu()
                    break
                endif
            when RC_IDENT
                EditIdent()
            when RC_SOURCE
                EditSource()
            when RC_TEST
                TestDialog()
        endcase

        // recompile source file

        if retcode <> RC_CONT and not CompileInput()
            break
        endif

    until retcode == RC_EXIT
end

/****************************************************************************\
    setup
\****************************************************************************/

integer proc InitFiles()
    integer rc, ml, hist
    string dlgname[255]
    string bakname[255]
    string msg[48] = "Enter name of project:"

    // save info

    PushPosition()
    usrfile = GetBufferId()
    inpname = UnQuotePath(Query(MacroCmdLine))

    // load run time library

    ml = Set(MsgLevel,_NONE_)
    rc = isMacroLoaded("dialog") or LoadMacro("dialog")
    Set(MsgLevel,ml)
    if not rc
        Warn("Cannot load dialog run time library.")
        return (FALSE)
    endif

    if CheckVersion("DE",2,3)
        return (FALSE)
    endif

    // determine input filename

    if Length(inpname) == 0
        hist = GetFreeHistory("DLG:txt")
        if CurrExt() == ".d"
            inpname = CurrFileName()
        elseif ExecDialog("DlgOpen -x -c")
            if Val(Query(MacroCmdLine)) == 2
                inpname = GetHistoryStr(hist,1)
            else
                return (FALSE)
            endif
        else
            if not (AskFilename(msg,inpname,0,hist) and Length(inpname))
                return (FALSE)
            endif
        endif
    endif

    if SplitPath(inpname,_EXT_) == ""
        inpname = inpname + ".d"
    endif
    dlgname = SplitPath(inpname,_DRIVE_|_PATH_|_NAME_)
    bakname = dlgname + ".d0"
    incname = dlgname + ".si"

    // allocate work space

    tmpbuff = CreateTempBuffer()
    incbuff = CreateTempBuffer()
    incfile = EditFile(QuotePath(incname))
    inpfile = EditFile(QuotePath(inpname))
    if not (tmpbuff and incbuff and incfile and inpfile)
        Warn("Cannot allocate work space.")
        return (FALSE)
    endif

    // load or prepare input file

    if NumLines() == 0
        if not InsertData(DialogTemplate)
            Warn("Cannot create new dialog template.")
            return (FALSE)
        endif
        lReplace("xxxxxx",SplitPath(dlgname,_NAME_),"gn")
    else
        lReplace(Chr(9)," ","gn")
    endif

    // backup and compile input file

    UnmarkBlock()
    SaveBlock(bakname,_OVERWRITE_)
    return (CompileInput())
end

/****************************************************************************\
    shutdown
\****************************************************************************/

proc DoneFiles()

    // clear work space

    AbandonFile(tmpbuff)
    AbandonFile(dlgbuff)
    AbandonFile(incbuff)
    AbandonFile(incfile)

    // handle compilation errors

    if invalid
        GotoBufferId(usrfile)
        KillPosition()
    else
        if usrfile <> inpfile
            AbandonFile(inpfile)
        endif
        PopPosition()
    endif

    // purge self

    PurgeMacro(CurrMacroFileName())
end

/****************************************************************************\
    screen setup
\****************************************************************************/

integer proc InitScreen()
    if not PopWinOpen(1,1,Query(ScreenCols),Query(ScreenRows),0,"",clr_bkgd)
        return (FALSE)
    endif
    ClearScreen()
    ticks = GetClockTicks()
    return (TRUE)
end

proc DoneScreen()
    GotoBufferId(inpfile)
    PopWinClose()
    UpdateDisplay()
    if invalid
        Warn("Compile error: ",Query(MacroCmdLine),".")
    endif
end

/****************************************************************************\
    clear event queue
\****************************************************************************/

proc DoneEvents()
    while KeyPressed()
        if GetKey() <> KEY_NOTHING
            PushKey(Query(Key))
            break
        endif
    endwhile
end

/****************************************************************************\
    main program
\****************************************************************************/

proc Main()
    if InitScreen()
        if InitFiles()
            Run()
            DoneEvents()
        endif
        DoneFiles()
        DoneScreen()
    endif
end

