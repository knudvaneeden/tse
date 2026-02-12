/****************************************************************************\

  TseShell.S

  Use a TSE buffer to run a DOS-Shell within.

  Version         0.99/15.04.96

  Copyright       (c) 1996 rewrite 0.99 Dr. S. Schicktanz
                  (c) 1995 Peter Birch and Dieter Kîssl
                  with additions by Dr. S. Schicktanz
                  original idea by Peter Birch
                  macro programming by Dieter Kîssl
                  features stolen from 4dos (c) 1988-94 JP Software

  History
    v0.99/15.04.96  complete rewrite of "user interface",
                    providing for full editing functions
                    within the "Dos command buffer" in
                    addition to the capabilities for calling
                    Dos programs and capturing their output
                    for further use.
                    Also adds direct execution from editing buffer
                    and "internal batching" of marked commands.
    v0.92/25.08.95  restructuring of I/O redirection,
                    separate buffering of stderr & stdout,
                    save & restore insert state,
                    a couple of definitions added   // SchS \\
    v0.91/15.08.95  error correction
    v0.90/09.08.95  first beta version

  Usage notes:

    TseShell 0.99 allocates a special (SYSTEM) buffer for it's use,
    which can be used almost like a normal editing buffer, except
    that every line where the "Enter" key is pressed at is interpreted
    as a Dos command to be executed. In addition, there are a couple of
    internally defined commands which are executed by macro code directly.
    Commands can be "batched" by marking an enclosing block and pressing
    "Enter" (the Execute key). This will send them one by one to the
    ExecuteLine () function, which either executes them directly or
    calls the Dos () function to do so.
    Program output will end up in the command buffer, where it can be
    edited and reused.
    A help function is provided, which is an adoptation and adaptation
    of DiK's TseSHelp.S macro provided with the original implementation.

\****************************************************************************/
// Defines
/****************************************************************************/

#ifdef _GER
// german version
#else
#ifdef _ENG
// english version
#else
// no version? Use german!
#define _GER    1
#endif
#endif


/****************************************************************************\
    global variables
\****************************************************************************/

constant HISTORY_IMMEDIATE = 1,         // history selection for command line
         HISTORY_FLOATING =  2,
         HISTORY_PROMPTED =  3

integer InsertMode =   OFF,             // use insert mode
        cmd_history =  HISTORY_IMMEDIATE,
        MaxTermLines = 1000             // maximum lines of screen buffer

integer insst, rmvtw, seofm, shelp
string  wset [32] = ''

string DirBrackets [] = "[]",           // directory display bracketing chars
       ProgName [] = "TseShell",        // name of macro file
       BuffName [] = "[_tseshell_]",    // name of screen buffer
       RamLabel [] = "MS-RAMDR.IVE",    // label of MS RamDrive
       PrevDir  [80] = '',              // name of previously active directory
       TempPath [68],                   // name of temporary file path
       TempFile [68],                   // name of redirection file
       ErrFile  [68]                    // name of redirection file

integer byStep =    false,  // stepwise command execution
        new_setup = false,  // settings changed
        Settings =  0,      // history number to save settings
        dir_list =  0,      // buffer: dir listing for filename completion
        terminal =  0,      // buffer: output screen
        from =      0       // buffer: previous id

integer prompt_pos =     0, // position of cursor at command line
        mode_line_pos =  1, // line position of shell mode indicator
        show_help_line = 1  // help line display state in shell mode

constant ConfigKey =    <F9>,
         DosKey =       <F10>,
         ExitKey =      <Alt X>,
         ExecuteKey =   <Enter>,
         BypassKey =    <Escape>,
         NewLineKey =   <Ctrl Enter>

constant GotoDosKey =   <F9>,
         EditExecKey =  <Alt Enter>

/****************************************************************************\
    output redirection
\****************************************************************************/

constant FAILURE = -1,      // invalid handle number                // SchS \\
         stdout =   1,      // default handle of standard output
         stderr =   2,      // default handle of standard error
         needDos =  9       // flag for external command request

integer oldout              // duplicated handle of standard output
integer olderr              // duplicated handle of standard error

#ifdef _GER
string err_msg [] = "Ausgabeumleitung nich mîglich: Sichern Sie Ihre Arbeit und beenden Sie TSE"
#else
string err_msg [] = "Cannot redirect output: Save work and exit TSE"
#endif

/****************************************************************************\
  Redirection restructured // SchS \\
\****************************************************************************/

integer proc Redirect (integer StdHandle, integer OrgHandle, string TempFile)
    register r
    integer oldHandle = StdHandle, handle = OrgHandle

    if TempFile <> ''       // flags redirection begin
        // duplicate StdHandle

        r.ax = 0x4500
        r.bx = StdHandle
        Intr (0x21, r)
        if r.flags & _flCarry_
            Warn ('Dup failure!')
            return (FAILURE)
        endif
        oldHandle = r.ax

        // create output file

        handle = fCreate (TempFile, _NORMAL_)
        if handle == FAILURE
            Warn ('Create failure!')
            return (FAILURE)
        endif
    endif

    // redirect StdHandle to TempFile or OrgHandle

    r.ax = 0x4600
    r.bx = handle
    r.cx = StdHandle
    Intr (0x21, r)
    if r.flags & _flCarry_
        Warn ('Redirect failure!')
        return (FAILURE)
    endif

    // close TempFile

    if not fClose (handle)
        Warn ('Close failure!')
        return (FAILURE)
    endif

    return (oldHandle)
end


proc OpenRedirection ()

    TempFile = MakeTempName (TempPath)
    oldout= Redirect (stdout, 0, TempFile)

    // error handling

    if oldout == -1
        Alarm ()
        Warn (err_msg, ' StdOut')
    endif

    ErrFile = MakeTempName (TempPath)
    olderr= Redirect (stderr, 0, ErrFile)

    // error handling

    if olderr == -1
        Alarm ()
        Warn (err_msg, ' StdErr')
    endif
end


proc CloseRedirection ()

    // restore original stdout

    if not Redirect (stdout, oldout, '')
        Alarm ()
        Warn (err_msg, ' StdOut')
    endif

    // restore original stderr

    if not Redirect (stderr, olderr, '')
        Alarm ()
        Warn (err_msg, ' StdErr')
    endif
end

/****************************************************************************\
    helper routines
\****************************************************************************/

proc ReadDone ()
    PushKey (Query (Key))
end

proc ShowList ()
    UpdateDisplay (_ALL_WINDOWS_REFRESH_)
end


proc GetFromHistoryPrompted ()
    string Command [200] = GetText (1, CurrLineLen ())

#ifdef _GER
    if Ask ('DOS-Befehl:', Command, _DOS_HISTORY_)
#else
    if Ask ('DOS command:', Command, _DOS_HISTORY_)
#endif
        BegLine ()
        KillToEol ()
        InsertText (Command, _INSERT_)
    endif
end

proc GetFromHistoryFloating ()
    integer msAttr = Set (MsgAttr, Query (TextAttr))
    string  Command [200] = GetText (1, CurrLineLen ())

    Window (WhereX (), WhereY (), WhereX (), WhereY ())
    GotoXY (1, 1)
    PushKey (<CursorUp>)
    Hook (_LIST_CLEANUP_, ReadDone)
    Hook (_LIST_STARTUP_, ShowList)

    if lRead (Command, 200, _DOS_HISTORY_)
        BegLine ()
        KillToEol ()
        InsertText (Command, _INSERT_)
    endif

    UnHook (ShowList)
    UnHook (ReadDone)
    FullWindow ()
    Set (MsgAttr, msAttr)
end

proc GetFromHistoryImmediate ()
    integer n = 1,
            hmax = NumHistoryItems (_DOS_HISTORY_)
    string orgLine [200] = GetText (1, CurrLineLen ())

    if hmax
        loop
            BegLine ()
            KillToEol ()
            InsertText (GetHistoryStr (_DOS_HISTORY_, n), _INSERT_)
            UpdateDisplay (_ALL_WINDOWS_REFRESH_)   // _CLINE_REFRESH_)

            case GetKey ()
                when <Ctrl CursorUp>
                    n= iif (n == 1, hmax, n-1)
                when <Ctrl CursorDown>
                    n= iif (n == hmax, 1, n+1)
                when <Enter>
                    PushKey (<ExecuteKey>)  // sofort ausfuehren
                    break                   // passt
                when <Escape>
                    BegLine ()
                    KillToEol ()
                    InsertText (orgLine)
                    break
                otherwise
                    PushKey (Query (Key))   // Taste weiterreichen
                    break
            endcase
        endloop
    else
#ifdef _GER
        Warn ('Keine Dos-Befehle vorhanden!')
#else
        Warn ('Dos command history empty!')
#endif
    endif
end

/****************************************************************************\
    insert from list of available files
\****************************************************************************/

proc InsertFileName ()
    integer eol = CurrChar () == _AT_EOL_
    string  wildcard [80] = PickFile (GetWord (true))
    // get wild card and make dir list

    if wildcard <> ''
        if CurrChar () <> _BEYOND_EOL_
            PushBlock ()
            PushPosition ()
            if MarkWord () or (Left () and MarkWord ())
                KillBlock ()
            endif
            PopPosition ()
            PopBlock ()
        endif

        if Pos (CurrDir (), SplitPath (wildcard, _DRIVE_ | _PATH_)) == 1
            wildcard= wildcard [Length (CurrDir ())+ 1: 255]
            // keep different part only
        elseif SplitPath (wildcard, _DRIVE_) == SplitPath (CurrDir (), _DRIVE_)
            wildcard= SplitPath (wildcard, _PATH_ | _NAME_ | _EXT_)
        endif

        InsertText (iif (eol, wildcard+ ' ', wildcard), _INSERT_)
        AddHistoryStr (wildcard, _EDIT_HISTORY_)
    endif

    UpdateDisplay (_CLINE_REFRESH_)
end

/****************************************************************************\
    history lists (commands and filenames)
\****************************************************************************/

proc FilenameHistory ()
    integer msAttr = Set (MsgAttr, Query (TextAttr))
    string  Filename [80] = ''

    Window (WhereX (), WhereY (), WhereX (), WhereY ())
    GotoXY (1, 1)
    PushKey (<CursorUp>)
    Hook (_LIST_CLEANUP_, ReadDone)
    Hook (_LIST_STARTUP_, ShowList)

    if lRead (Filename, 80, _EDIT_HISTORY_)
        InsertText (Filename, _INSERT_)
    endif

    UnHook (ShowList)
    UnHook (ReadDone)
    FullWindow ()
    Set (MsgAttr, msAttr)
    UpdateDisplay (_CLINE_REFRESH_)
end


proc GetFromHistory ()

    case cmd_history
        when HISTORY_PROMPTED
            GetFromHistoryPrompted ()
        when HISTORY_FLOATING
            GetFromHistoryFloating ()
        when HISTORY_IMMEDIATE
            GetFromHistoryImmediate ()
    endcase

    UpdateDisplay (_CLINE_REFRESH_)
end

/****************************************************************************\
    search ram drive
\****************************************************************************/

proc FindTempDrive ()
    integer drv
    string DTA [80] = ""

    SetDTA (DTA)
    for drv = Asc ("c") to Asc ("z")
        if FindFirst (Chr (drv)+":\*.*", _VOLUME_)
            repeat
                if (Asc (DTA [22]) & _VOLUME_) and (DTA [31:12] == RamLabel)
                    TempPath= Chr (drv)+":\"        // SchS \\
                    return ()
                endif
            until not FindNext ()
        endif
    endfor
    TempPath= Query (SwapPath)                      // SchS \\
end

/****************************************************************************\
    startup and shutdown
\****************************************************************************/

proc LoadSetup (integer history)
    string SetupStr [10] = ''

    Settings= history
    if Settings
        SetupStr = GetHistoryStr (Settings, 1)      // one entry only!

        if SetupStr <> ''
            InsertMode =     Val (SetupStr [1])     // use insert mode
            cmd_history =    Val (SetupStr [2])
            show_help_line = Val (SetupStr [3])     // help line display
            prompt_pos =     Asc (SetupStr [4])     // position of dir display
            MaxTermLines =   Val (SetupStr [5..10]) // buffer capacity
        endif
    endif
end


proc SaveSetup ()
    string SetupStr [10] = '0000'

    if new_setup and Settings
                        //  30h == Asc ('0')
        SetupStr [1] = Chr (30h+ InsertMode)        // use insert mode
        SetupStr [2] = Chr (30h+ cmd_history)
        SetupStr [3] = Chr (30h+ show_help_line)    // help line display
        SetupStr [4] = Chr (prompt_pos)             // position of cursor
        SetupStr= SetupStr+ Str (MaxTermLines)      // buffer capacity

        while DelHistoryStr (Settings, 1)           // clear all
        endwhile
        AddHistoryStr (SetupStr, Settings)          // add new settings
    endif
end


/****************************************************************************\
    status line indicator
\****************************************************************************/

proc ShowDir ()
    string dir [80] = CurrDir ()

    if Query (ShowStatusLine)
        if prompt_pos
            VGotoXYAbs (prompt_pos, mode_line_pos)
        else
            VGotoXYAbs (80- Length (dir), mode_line_pos)
        endif
        Set (Attr, Query (StatusLineAttr))
        PutHelpLine (DirBrackets [1]+ "{"+ dir [1..Length (dir)-1]+ "}"+ DirBrackets [2])
    endif
end

/****************************************************************************/

proc ClearCmdLine ()

    BegLine ()
    KillToEol ()
    UpdateDisplay (_CLINE_REFRESH_)
end


proc LimitScreenBuffer ()               // limit screen buffer line count

    if NumLines () > MaxTermLines
        MarkLine (1, NumLines ()- MaxTermLines)
        KillBlock ()
        UpdateDisplay (_WINDOW_REFRESH_)
    endif
end


proc DosCommand (string Command)

    OpenRedirection ()
    Set (Attr, Query (TextAttr))
    ClrScr ()
    GotoXY (1, WhereY ())
    Dos (Command, _DONT_PROMPT_|_TEE_OUTPUT_|_DONT_CLEAR_)
    CloseRedirection ()
end


proc ExecuteLine (string CommandLine)
    integer i
    string  Command [200] = CommandLine,
            Cmd [8] = iif (Pos (' ', Command), DelStr (Command, Pos (' ', Command), 255), Command)

    if (Pos (' ', Command) == 0) and (Command [Length (Command)] in '\', '.')
    // must be directory specification

        if Command [2] == ':'
            LogDrive (Command)              // direct change drive
            Command= DelStr (Command, 1, 2) // remove drive
        endif
        // now try to change directory
        i= 0
        while (i < Length (Command)) and (Command [i+1] == '.')
            i= i+1
        endwhile
        if i
            Command= DelStr (Command, 1, i) // remove dots from command line
            if Command [1] == '\'           // remove, as it would take us
                Command= DelStr (Command, 1, 1)     // to the root dir
            endif
            while i > 1                     // 4DOS-like step up
                ChDir ('..')
                i= i-1
            endwhile
        endif
        if Command <> ''                    // if something left
            ChDir (Command)                 // go there...
        endif
    elseif (Command [2] == ':') and (Length (Command) == 2)
        LogDrive (Command)                  // direct change drive
        Command= DelStr (Command, 1, 2)     // remove drive
    else
        case lower (Cmd)
            when "cd"
                ChDir (Command [4: 255])
            when "cde"
                LogDrive (PrevDir)
                ChDir (PrevDir)             // go to current editing dir
            when "cdd"
                LogDrive (Command [4])
                ChDir (Command [4: 255])
            when "cls"
                EmptyBuffer ()
                UpdateDisplay (_WINDOW_REFRESH_)
                return ()
            otherwise
                DosCommand (Command)
                Cmd= '' // flag Dos command
        endcase
    endif

    EndFile ()
    if CurrLineLen ()
        AddLine (CommandLine)
    else
        InsertText (CommandLine)
    endif
    AddHistoryStr (CommandLine, _DOS_HISTORY_)

    if Cmd == ''        // Dos command
        BegLine ()
        InsertFile (ErrFile)
        if FileExists (ErrFile)
            EraseDiskFile (ErrFile)
        else
            Warn ('File not found: ErrFile')
        endif
        UnmarkBlock ()

        InsertFile (TempFile)
        if FileExists (TempFile)
            EraseDiskFile (TempFile)
        else
            Warn ('File not found: TempFile')
        endif
        UnmarkBlock ()
    else
        AddLine ()
    endif

    UpdateDisplay (_ALL_WINDOWS_REFRESH_)
    FileChanged (false)                 // not an editing buffer anyway
    EndFile ()
    ScrollToRow (Query (WindowRows))    // active line as low as possible
end


proc ExecuteCurrentLine ()
    string  Command [200] = GetText (1, CurrLineLen ())

    if Command <> ''
        KillLine ()
        ExecuteLine (Command)
    else
        Creturn ()
        UpdateDisplay (_CLINE_REFRESH_)
    endif
end


proc ExecuteBlock (integer destroy)
    integer Batch = CreateTempBuffer ()
    string  Command [200]

    if Batch
        GotoBufferId (Batch)
        if destroy
            MoveBlock ()
        else
            CopyBlock ()
        endif
        BegFile ()

        while NumLines ()
            Command= GetText (1, CurrLineLen ())
            KillLine ()
            GotoBufferId (terminal)
            ExecuteLine (Command)
            GotoBufferId (Batch)

            if byStep
#ifdef _GER
                Message ('NÑchster Befehl? [J/N]')
#else
                Message ('Next command? [Y/N]')
#endif

                loop
                    case GetKey ()
                        when <N>, <n>, <Escape>
                            EmptyBuffer ()
#ifdef _GER
                            Warn ('Bearbeitung abgebrochen!')
#else
                            Warn ('Execution aborted!')
#endif
                            break       // Abbruch!
                        when <J>, <j>, <Y>, <y>, <Enter>, <GreyEnter>
                            break       // go ahead
                        otherwise
                            Alarm ()    // else yell
                    endcase
                endloop
            endif
        endwhile

        GotoBufferId (terminal)
        AbandonFile (Batch)
    else
        Alarm ()
#ifdef _GER
        Warn ('Kein Speicher fÅr Befehlsblock!')
#else
        Warn ('Not enough memory for commands!')
#endif
    endif
end


proc ExecuteCommand ()

    if isBlockInCurrFile ()
        ExecuteBlock (true)     // as "batch"
    else
        ExecuteCurrentLine ()
    endif

    LimitScreenBuffer ()
end

/****************************************************************************\
    configuration menu
\****************************************************************************/

proc OnOff (var integer bool)
    bool = not bool
end

string proc OnOffStr (integer bool)

#ifdef _GER
    return (iif (bool, "Ein", "Aus"))
#else
    return (iif (bool, "On", "Off"))
#endif
end

proc SetNum (var integer num, integer nmin, integer nmax)
    integer nnum
    string snum [5]

    snum = Str (num)
    ReadNumeric (snum)
    nnum = Val (snum)
    if nmin <= nnum and nnum <= nmax
        num = nnum
    else
        Alarm ()
#ifdef _GER
        Message ("UngÅltige Zahl")
#else
        Message ("Invalid number")
#endif
    endif
end

proc SetTempPath ()
    string NewPath [48] = TempPath

    if Read (NewPath)
        NewPath = SplitPath (ExpandPath (NewPath), _DRIVE_ | _PATH_)
        if Length (NewPath)
            TempPath= NewPath               // SchS \\
        else
            Alarm ()
#ifdef _GER
            Message ("UngÅltiger Pfad")
#else
            Message ("Invalid path")
#endif
        endif
    endif
end


proc SetCmdHistory (integer new)
    cmd_history= new
end


#ifdef _GER
menu CommandMenu ()
    command = SetCmdHistory (MenuOption ())
    history = cmd_history

    "&direkt",,     CloseBefore
    "&schwebend",,  CloseBefore
    "&von Prompt",, CloseBefore
end

menu ConfigMenu ()

    title = "TseShell-Einstellungen"
    width = 54
    x =     22
    y =      4

    "Behandlung alter &Befehle"
        [MenuStr (CommandMenu, cmd_history): 9],
        CommandMenu (),
        DontClose

    "&EinfÅgemodus"
        [OnOffStr (InsertMode): 3],
        OnOff (InsertMode),
        DontClose

    "&Schrittweise Blockbearbeitung"
        [OnOffStr (byStep): 3],
        OnOff (byStep),
        DontClose
    "",,    divide

    "&Verzeichnisposition"
        [prompt_pos: 3],
        SetNum (prompt_pos, 0, 80),
        DontClose

    "Befehlspuffer&grî·e"
        [Str (MaxTermLines): 5],
        SetNum (MaxTermLines, 99, 99999),
        DontClose

    "Pfad fÅr &Zwischendateien"
        [Format (TempPath: -25): -25],
        SetTempPath (),
        DontClose
end
#else
menu CommandMenu ()
    command = SetCmdHistory (MenuOption ())
    history = cmd_history

    "&immediate",, CloseBefore
    "&floating",,  CloseBefore
    "&prompted",,  CloseBefore
end

menu ConfigMenu ()

    title = "TseShell Configuration"
    width = 44
    x =     30
    y =      4

    "&Command History Handling"
        [MenuStr (CommandMenu, cmd_history): 9],
        CommandMenu (),
        DontClose

    "&Insert Mode"
        [OnOffStr (InsertMode): 3],
        OnOff (InsertMode),
        DontClose

    "Step through &batches"
        [OnOffStr (byStep): 3],
        OnOff (byStep),
        DontClose
    "",,    divide

    "&Directory Position"
        [prompt_pos: 3],
        SetNum (prompt_pos, 0, 80),
        DontClose

    "&Command Buffer Size"
        [Str (MaxTermLines): 5],
        SetNum (MaxTermLines, 99, 99999),
        DontClose

    "&Temporary Path"
        [Format (TempPath: -25): -25],
        SetTempPath (),
        DontClose
end
#endif

proc Configure ()

    ConfigMenu ()
    new_setup= true     // maybe, anyway
end

/****************************************************************************\
    key bindings
\****************************************************************************/

#ifdef _GER
keydef DosCommandKeys

    <HelpLine>            " {F1}-Hilfe {F2}-Datei {F9}-Einstellung {F10}/{Enter}-Befehl {Esc}-Befehlszeile lîschen"
    <Alt HelpLine>        " {Alt:} {F7}-Editorverz.wechseln {Del}-Puffer lîschen {}/{}/{P}/{N}-Editor {X}-Ende"
    <Ctrl HelpLine>       " {Ctrl:} {F2}-Dateiauswahl {F7}-Zum Editorverz. {Enter}-Neue Zeile {}/{}-frÅhere Befehle"
    <Shift HelpLine>      " {Shift:} "
    <CtrlAlt HelpLine>    " {Ctrl Alt:} "
    <CtrlShift HelpLine>  " {Ctrl-Shift:} {}/{}-Befehlszeilenfenster"

    <ExitKey>               PurgeMacro (CurrMacroFilename ())
    <BypassKey>             ClearCmdLine ()
    <DosKey>                ExecuteCommand ()
    <ExecuteKey>            ExecuteCommand ()
    <NewLineKey>            Creturn ()
    <Ctrl GreyEnter>        Creturn ()

    <Ctrl CursorUp>         GetFromHistory ()
    <Ctrl CursorDown>       GetFromHistory ()

    <CtrlShift CursorUp>    GetFromHistoryFloating ()
    <CtrlShift CursorDown>  GetFromHistoryFloating ()

    //  miscellaneous

    <Alt Del>               EmptyBuffer () UpdateDisplay (_WINDOW_REFRESH_)

    <F1>                    ExecMacro ("TseSHilf")
    <Ctrl F2>               InsertFileName ()
    <F2>                    FilenameHistory ()
    <Ctrl F7>               LogDrive (PrevDir) ChDir (PrevDir)
    <Alt F7>                PrevDir= CurrDir ()
    <ConfigKey>             Configure ()
    <F11>                   PrevFile ()
end
#else
keydef DosCommandKeys

    <HelpLine>            " {F1}-Help {F2}-Filename {F9}-Configure {F10}/{Enter}-Execute {Esc}-Clear Command Line"
    <Alt HelpLine>        " {Alt:} {F7}-Change Editor Dir {Del}-Clear Buffer {Left}/{Right}/{P}/{N}-Editor {X}-Exit"
    <Ctrl HelpLine>       " {Ctrl:} {F2}-Pick File {F7}-Goto Editor Dir {Enter}-New Line {Up}/{Down}-Command History"
    <Shift HelpLine>      " {Shift:} "
    <CtrlAlt HelpLine>    " {Ctrl Alt:} "
    <CtrlShift HelpLine>  " {Ctrl-Shift:} {Up}/{Down}-Command History Window"

    <ExitKey>               PurgeMacro (CurrMacroFilename ())
    <BypassKey>             ClearCmdLine ()
    <DosKey>                ExecuteCommand ()
    <ExecuteKey>            ExecuteCommand ()
    <NewLineKey>            Creturn ()
    <Ctrl GreyEnter>        Creturn ()

    <Ctrl CursorUp>         GetFromHistory ()
    <Ctrl CursorDown>       GetFromHistory ()

    <CtrlShift CursorUp>    GetFromHistoryFloating ()
    <CtrlShift CursorDown>  GetFromHistoryFloating ()

    //  miscellaneous

    <Alt Del>               EmptyBuffer () UpdateDisplay (_WINDOW_REFRESH_)

    <F1>                    ExecMacro ("TseSHelp")
    <Ctrl F2>               InsertFileName ()
    <F2>                    FilenameHistory ()
    <Ctrl F7>               LogDrive (PrevDir) ChDir (PrevDir)
    <Alt F7>                PrevDir= CurrDir ()
    <ConfigKey>             Configure ()
    <F11>                   PrevFile ()
end
#endif

/****************************************************************************/

proc SaveState ()
    string OldDir [80] = CurrDir ()

    insst= Set (Insert, InsertMode)
    rmvtw= Set (RemoveTrailingWhite, ON)
    seofm= Set (ShowEOFMarker, OFF)
    shelp= Set (ShowHelpLine, show_help_line)
    wset=  Set (WordSet, ChrSet ("-!\x22#$%&'()0-9A-Z_a-z~:\\.*?"))
    // modified wordset for (ambigous) file names

    if PrevDir <> ''
        LogDrive (PrevDir)
        ChDir (PrevDir)
    endif
    PrevDir= OldDir
end


proc RestoreState ()
    string OldDir [80] = CurrDir ()

    SaveSetup ()
    Set (Insert, insst)
    Set (RemoveTrailingWhite, rmvtw)
    Set (ShowEofMarker, seofm)
    Set (ShowHelpLine, shelp)
    Set (WordSet, wset)

    LogDrive (PrevDir)
    ChDir (PrevDir)
    PrevDir= OldDir
end


proc LeaveDosBuffer ()

    Disable (DosCommandKeys)
    UnHook (LeaveDosBuffer)
    UnHook (ShowDir)
    RestoreState ()
    GotoBufferId (from)     // always return to where we came from
    UpdateDisplay (_ALL_WINDOWS_REFRESH_)
end


proc GotoDosBuffer ()

    while KeyPressed ()
        GetKey ()
    endwhile
    from= GotoBufferId (terminal)
    SaveState ()
    Enable (DosCommandKeys)
    Hook (_ON_CHANGING_FILES_, LeaveDosBuffer)
    Hook (_AFTER_UPDATE_STATUSLINE_, ShowDir)
    ShowDir ()
end

/****************************************************************************/

proc ExecuteBufferCmd ()
    string  Command [200]

    if isBlockInCurrFile ()
        GotoDosBuffer ()
        ExecuteBlock (false)    // as "batch"
    else
        Command= GetText (1, CurrLineLen ())

        if Command <> ''
            GotoDosBuffer ()
            EndFile ()
            ExecuteLine (Command)
        else
            Alarm ()
        endif
    endif

    LimitScreenBuffer ()
end


<GotoDosKey>        GotoDosBuffer ()
<EditExecKey >      ExecuteBufferCmd ()

/****************************************************************************\
    main program
\****************************************************************************/

proc WhenPurged ()          // unload TseShell on user request

    RestoreState ()

    if GetBufferId () <> terminal
        GotoBufferId (terminal)
    endif

    BufferType (_NORMAL_)   // must be in there to work as intended...
    GotoBufferId (from)     // always return to where we came from
    AbandonFile (dir_list)
end


proc WhenLoaded ()
    integer from = GetBufferId ()

    SaveState ()
    LoadSetup (GetFreeHistory (ProgName+ ":Settings"))

    // miscellaneous preparations

    if not Query (StatusLineAtTop)
        mode_line_pos = Query (ScreenRows)
    endif

    // determine name of temp file

    FindTempDrive ()

    // goto or make shell buffer

    terminal= GetBufferId (BuffName)
    if terminal
        GotoBufferId (terminal)
        BufferType (_HIDDEN_)
    else
        terminal= CreateBuffer (BuffName, _HIDDEN_)
    endif

    if not dir_list
        dir_list= CreateTempBuffer ()
    endif

    // test buffer allocation

    if not (terminal and dir_list)
        Warn ("Cannot allocate buffers")
        AbandonFile (terminal)
        PurgeMacro (CurrMacroFilename ())
        return ()
    endif

    RestoreState ()
    GotoBufferId (from)     // return to where we came from
end

proc main ()
    WhenLoaded ()
    PushKey (<GotoDosKey>)
end