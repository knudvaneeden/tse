   /*********************** Start Comment Area *******************************
 TSE Macro                                                        TSE Macro
 File: copypart.s                 Saturday -  June 12, 1993

                    Copies Block to second Window
                    Initiate with ExecMacro("CopyPart")

 Macro was originally called 'cpyparts'.  Changed to 'copypart'
 The macro was originally in a three part message and has been combined
 ===========================================================================
 Original Date: 06-06-93  From: BOB CAMPBELL   Subj: TSE - Copy Parts

  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
  ³ At the request of Bob Campbell the author of 'copypart.s' the three ³
  ³part message that originally contained this messege is being combined³
  ³and a header inserted so the file may be uploaded to the SemWare BBS.³
  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

 ÷÷  Editor and combiner:  Tom Klein  ÷
 ÷÷  TAKnet Information Service  Fort Wayne, Indiana  ÷÷

 I often grab text from one file and paste it into a second file.  I
 would make a temporary <Ctrl Return> macro to paste the current block
 into the next file.

 I did do this enough that I decided to write a macro and assign it to a
 key. At first I only intended to write a simple 10 line macro but as
 usual I started to have fun and it got a little out of hand.

 The macro below and the next two messages contain the code for copypart.s.
 If you wish to use it, it should be compiled and called by a key
 assignment:

 <keyname>  ExecMacro("CopyParts")

 'copypart' uses code copied from mListOpenFiles to select a Target file if
 the next file is not the file you wish to use as a target file.

 If there is only one file open you will be prompted for a target file name

//*************************************************************************

                CopyPart.s by Bob Campbell 6/6/93

                Copies Block to second Window
                Initiate with ExecMacro("CopyPart")

//*************************************************************************

ASSUMPTIONS: none

PARAMETERS:  none

RETURNS:     nothing

GLOBAL VARS: string file[15], TargetName[40]

             integer n, Abort, windows, isSource, border

LOCAL VARS:  string title, fn[65],  ok[1]

             integer width, start_file, filelist, id, rc, maxl,
                     total, n, save, hline

  *************************************************************************/
//********************** END of Comment Area ******************************

integer n=0, Abort=1, windows=1, isSource=0, border
string file[15]="_Not_Exist_", TargetName[40]=""

/************************************************************************
 *                               Code for                               *
 *                 ListIt, ListTargetFiles and mDelChar                 *
 *                    was borrowed from TSE.S                           *
 ************************************************************************/

//***********************************************************************

integer proc ListIt(string title, integer width)
  width=  (iif(width<17,17,width+4))
    if width > Query(ScreenCols)
        width = Query(ScreenCols)
    endif
    return (List(title, width))
end

//***********************************************************************
proc ListTargetFiles()
    integer start_file, filelist, id, rc, maxl, total, n
    string fn[65]

    n = NumFiles() + (Query(BufferType) <> _NORMAL_)
    if n == 0
        return ()
    endif
    maxl = 0
    total = 0
    start_file = GetBufferid()                 // Save current
    filelist = CreateTempBuffer()
    if filelist == 0
        warn("Can't create filelist")
        return ()
    endif
    GotoBufferId(start_file)
    id = GetBufferid()
    while n
        fn = CurrFilename()
        if length(fn)
            if length(fn) > maxl
                maxl = length(fn)
            endif
            rc = isChanged()
            GotoBufferId(filelist)
            AddLine(iif(rc, '*', ' ') + fn)
            GotoBufferId(id)
        endif
        NextFile(_DONT_LOAD_)
        id = GetBufferid()
        n = n - 1
    endwhile
    GotoBufferId(filelist)
    BegFile()
    if ListIt("Target List", maxl)
        EditFile(GetText(2, sizeof(fn)))    // Force loading from disk
    else
        GotoBufferId(start_file)
    endif
    AbandonFile(filelist)
end ListTargetFiles

integer proc mDelChar()   // Augment delchar by joining lines
    return(iif(CurrChar() >= 0, DelChar(), JoinLine()))
end

// END of borrowed code from TSE.S

//*************************************************************************

proc ToggleVWindows()
    If Windows == 2      // keeps tract how how many windows we have
        Windows = 1
        GotoWindow(1)
        ZoomWindow()     // displays one window
    else
        Windows = 2
        ZoomWindow()     // displays two windows
        GotoWindow(1)
    endif
end

proc goWindow(integer win)
    if win == 1        isSource = 1
        GotoWindow(1)
    endif
    if win == 2
        isSource = 0
        GotoWindow(2)
    endif
end

// 'copypart.s'  Copy Parts 2/3
// ---------------------------------------------------------------------

//***********************************************************************
proc MindChange()
    Abort=0
    EndProcess()
    GotoBlockBegin()
    Warn("Blocking ABORTED... CopyParts Remains Activated ")
end

keydef EndBlockKey

<HelpLine>        "<F2>-Find  <F8>-EndBlock   <F9>-ToggleVWindows <Escape>-Abort "
<Alt HelpLine>    "                   "
<Shift HelpLine>  "                   "
<Ctrl HelpLine>   "                   "

    <Escape>        MindChange()
    <F8>            EndProcess()
    <F9>            ToggleVWindows()
    <CursorUp>      Up()
    <CursorDown>    Down()
    <CursorRight>   Right()
    <CursorLeft>    Left()
    <BackSpace>     BackSpace()
    <Home>          BegLine()
    <End>           EndLine()
    <PgUp>          PageUp()
    <PgDn>          PageDown()
    <Ctrl Home>     BegWindow()
    <Ctrl End>      EndWindow()
    <Ctrl PgUp>     BegFile()
    <Ctrl PgDn>     EndFile()
    <Ctrl f>        Find()
    <F2>            Find()
    <F3>            RepeatFind()
end

//***********************************************************************
integer proc Move2BlkEnd()
    Enable(EndBlockKey, _EXCLUSIVE_)
    Process()
    Disable(EndBlockKey)
    if Abort == 0
        Abort = 1
        return(FALSE)
    endif
    return(TRUE)
end

//***********************************************************************
integer proc count()
    n=0
    gotoblockbegin()
    while iscursorinblock() >= 1
        n = n + 1
        if not Down()
            return(n)
        endif
    endwhile
    return(n)
end

//***********************************************************************
string proc ApproveFile()
    string ok[1]="y"
    n=0
    if nextfile(_Dont_Load_)
        pushposition()
        begwindow()
        UpdateDisplay()

        message("*** Copy Parts ***              TARGET FILE ÍÍ ",currfilename())
        gotocolumn(32)
        ask("Is this the correct Target file?  [Y/n]",ok)
        popposition()
        if ok == "y" or ok == "Y"
            PrevFile()
        else
            File ="_Not_Approved_"
            prevfile()
            return(File)
        endif
     else
        File = "_Not_Exist_"
        return(File)
    endif
        File = "_Approved_"
        return(File)
end

// 'copypart.s'  Copy Parts 3/3
// ---------------------------------------------------------------------

//***********************************************************************
proc Copy2NextFile()
    integer save=windows
    if isSource == 0
        Warn("I can't do that Squire... You're in the Target Window! ")
        Return()
    endif
    UnMarkBlock()
    MarkLine()
    if Move2BlkEnd()
        count()
        Copy()

        If Windows == 1      // keeps tract how how many windows we have
            zoomwindow()
            UpdateDisplay()
        endif
            gotowindow(2)
            Paste()
            while n >= 1
                n=n-1
                down()
            endwhile
            UpdateDisplay()
            gotowindow(1)
            if save == 1
                zoomwindow()
            endif
    endif
    UnMarkBlock()
end

proc nothing()
end

keydef BeginBlockKey

<HelpLine>        "<F2>-Find   <F3>-RepeatFind   <F7>-StartBlock <F9>-ToggleVWindows  <F10>-Quit  "

<Alt HelpLine>    "ALT  -  <1>-Window[1]  <2>Window[2]"

<Shift HelpLine>  ""

<Ctrl HelpLine>   "CursorL-Win[1] CursorR-Win[2] Home-BegWin End-EndWin PgUp-BegFile PgDn-EndFile"

    <F7>            Copy2NextFile()
    <F10>           EndProcess()
    <F9>            ToggleVWindows()
    <Escape>        nothing()
    <Ins>           Toggleinsert()
    <Del>           mDelChar() //  mDelChar will delete LineFeed
    <Grey->         Cut()
    <Grey*>         Paste()
    <CursorUp>      Up()
    <CursorDown>    Down()
    <CursorRight>   Right()
    <CursorLeft>    Left()
    <BackSpace>     BackSpace()
    <Home>          BegLine()
    <End>           EndLine()
    <PgUp>          PageUp()
    <PgDn>          PageDown()
    <Ctrl Home>     BegWindow()
    <Ctrl End>      EndWindow()
    <Ctrl PgUp>     BegFile()
    <Ctrl PgDn>     EndFile()
    <Alt 1>         GoWindow(1)
    <Alt 2>         GoWindow(2)
    <Ctrl CursorLeft> GoWindow(1)
    <Ctrl CursorRight> GoWindow(2)
    <Ctrl f>        Find()
    <F2>            Find()
    <F3>            RepeatFind()
end

//***********************************************************************
proc Fling()
    Enable(BeginBlockKey, _TYPEABLES_ )
    GotoXY(1,0)

    Writeline("Press <F7> to Begin Block    <F9>-Toggle VWindows   <F10>-Quit            ")

    Process()
    Disable(BeginBlockKey)
    Disable(EndBlockKey)
    FullWindow()
end


//***********************************************************************
proc main()
    integer hline
    ApproveFile()
        onewindow()

    case  File
    when "_Not_Approved_"
        Vwindow()
        gotoWindow(2)
        updateDisplay()
        gotoxy(1,25)

        WriteLine("                    Choose a Target File from this list            ") // Operation Aborted at operator's request")
        ListTargetFiles()
        updateDisplay()
        gotoWindow(1)
        ZoomWindow()

    when "_Not_Exist_"
        Vwindow()
        gotoWindow(2)
        gotoxy(1,25)

        WriteLine("                                 Target File not loaded...                      ") // Operation Aborted at operator's request")
        ask("Enter Target File Name:  ",TargetName)
        EditFile(TargetName)
        gotoWindow(1)
        ZoomWindow()
    when "_Approved_"
        Vwindow()
        updateDisplay()
        gotoWindow(1)
        ZoomWindow()
    endcase
        border = set(DisplayBoxed,Off)
        isSource=1            // toggle var keeps tract of window
        windows = 1           // keeps tract how how many windows we have
        updateDisplay()
        Fling()
        Warn("Quiting CopyParts Routine  ")
        set(DisplayBoxed,border)
        UpdateDisplay(_ALL_WINDOWS_REFRESH_)
end

//  Debug key binding. Use it or bind the key of your choice
// 'Shift CenterCursor' is the '5' key on the keypad with NumLock ON

<Shift CenterCursor>       ExecMacro('copypart')

/**************************************************************************
 END TSE macro 'Copypart.s'                       Saturday -  June 12, 1993
 **************************************************************************/
// ************************* End of CopyPart.s ****************************
