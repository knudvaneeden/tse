//#pragma chrisant
/****************************************************************************\

  TSEShell.S

  Use a TSE buffer to run a DOS-Shell within.

  Version         4.2, 02/04/04

  Copyright       (c) 2004 ported to Win32 by Chris Antos
                  (c) 1996 rewrite 0.99 Dr. S. Schicktanz
                  (c) 1995 Peter Birch and Dieter Kîssl
                  with additions by Dr. S. Schicktanz
                  original idea by Peter Birch
                  macro programming by Dieter Kîssl
                  features stolen from 4dos (c) 1988-94 JP Software
                  various features and Win32 support by Chris Antos

  History
    v4.2a, 07/25/04, by Chris Antos, chrisant@microsoft.com ----------------
                    - Added integration with the CUAMARK macro, so that if it
                      is loaded then after running a command, the command text
                      is marked with CUAMARK so that typing (without first
                      moving the cursor) will replace the command text (rather
                      than appending to it).

    v4.2, 02/04/04, by Chris Antos, chrisant@microsoft.com ----------------
                    - ported to Win32 (no longer supports TSE 2.5 for Dos).
                    - fixed various bugs, cleaned up code.
                    - added option to use separate buffering of stdout and
                      stderr, or share buffering.
                    - added option to hide the shell buffer, or leave it in
                      the ring of files so the next/prev file commands can
                      jump to it.

    v0.99a/08.05.96, by Chris Antos, chrisant@microsoft.com ---------------
                    - fixed miscellaneous bugs, including:
                        - settings could get messed up if you executed
                          TSEShell from within TSEShell.
                        - GotoDosBuffer wouldn't work if user quit the
                          TSEShell buffer because the buffer got deleted but
                          TSEShell kept trying to use the deleted buffer.
                    - rewrote window handling so it works with multiple
                      windows.
                    - added 4DOS-like filename completion using Tab,
                      ShiftTab, and CtrlTab keys (CtrlTab shows picklist of
                      matching filenames).
                    - NOTE: TSEShell can be purged while running, but if the
                      TSEShell buffer is the current buffer, it won't
                      actually purge the macro until you switch to a
                      different buffer (or window).
    -----------------------------------------------------------------------
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

        TSEShell allocates a special buffer for its use, which can be used
    almost like a normal editing buffer, except that every line where the
    "Enter" key is pressed at is interpreted as a Dos command to be executed.
    In addition, there are a couple of internally defined commands which are
    executed by macro code directly. Commands can be "batched" by marking an
    enclosing block and pressing "Enter" (the Execute key).  This will send
    them one by one to the ExecuteLine() function, which either executes them
    directly or calls the Dos() function to do so.
        Program output will end up in the command buffer, where it can be
    edited and reused.
        A help function is provided, which is an adoptation and adaptation of
    DiK's TseSHelp.S macro provided with the original implementation.

\****************************************************************************/



// Defines ----------------------------------------------------------------

// define _ENG to compile for English, define _GER to compile for German.
#define _ENG 1
//#define _GER 1


// when DEBUG is defined, extra debug code is compiled.
//#define DEBUG 1


// if no langauge defined, default to german.
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



DLL "<user32.dll>"
    integer proc SetForegroundWindow(integer hwnd)
end

DLL "<kernel32.dll>"
    integer proc AllocConsole()
    integer proc FreeConsole()

    integer proc GetConsoleWindow()

	integer proc GetStdHandle(integer nStdHandle)
	integer proc SetStdHandle(integer nStdHandle, integer handle)
	integer proc GetLastError()

    integer proc CreateFile(string stFile:cstrval,
                            integer dwDesiredAccess,
                            integer dwShareMode,
                            integer lpSecurity,
                            integer dwCreationDistribution,
                            integer dwFlagsAndAttributes,
                            integer hTemplateFile) : "CreateFileA"
    integer proc WriteFile(integer h, integer p, integer cb, integer pcbWritten, integer pOverlapped)
    integer proc CloseHandle(integer h)

    integer proc CreateProcess(string appexe:cstrval,
                               string cmdline:cstrval,
                               integer pProcessAttributes,
                               integer pThreadAttributes,
                               integer fInheritHandles,
                               integer dwCreationMode,
                               integer pEnvironment,
                               integer pDirectory,
                               integer pStartupInfo,
                               integer pProcessInfo) : "CreateProcessA"
    integer proc WaitForSingleObject(integer object, integer timeout)
end

// for CreateFile
#define GENERIC_READ                        0x80000000
#define GENERIC_WRITE                       0x40000000

#define FILE_SHARE_READ                     0x00000001
#define FILE_SHARE_WRITE                    0x00000002
#define FILE_SHARE_DELETE                   0x00000004
#define FILE_ATTRIBUTE_READONLY             0x00000001
#define FILE_ATTRIBUTE_HIDDEN               0x00000002
#define FILE_ATTRIBUTE_SYSTEM               0x00000004
#define FILE_ATTRIBUTE_DIRECTORY            0x00000010
#define FILE_ATTRIBUTE_ARCHIVE              0x00000020
#define FILE_ATTRIBUTE_ENCRYPTED            0x00000040
#define FILE_ATTRIBUTE_NORMAL               0x00000080
#define FILE_ATTRIBUTE_TEMPORARY            0x00000100
#define FILE_ATTRIBUTE_SPARSE_FILE          0x00000200
#define FILE_ATTRIBUTE_REPARSE_POINT        0x00000400
#define FILE_ATTRIBUTE_COMPRESSED           0x00000800
#define FILE_ATTRIBUTE_OFFLINE              0x00001000
#define FILE_ATTRIBUTE_NOT_CONTENT_INDEXED  0x00002000

#define CREATE_NEW                          1
#define CREATE_ALWAYS                       2
#define OPEN_EXISTING                       3
#define OPEN_ALWAYS                         4
#define TRUNCATE_EXISTING                   5


// for CreateProcess
#define DEBUG_PROCESS                       0x00000001
#define DEBUG_ONLY_THIS_PROCESS             0x00000002

#define CREATE_SUSPENDED                    0x00000004

#define DETACHED_PROCESS                    0x00000008

#define CREATE_NEW_CONSOLE                  0x00000010

#define NORMAL_PRIORITY_CLASS               0x00000020
#define IDLE_PRIORITY_CLASS                 0x00000040
#define HIGH_PRIORITY_CLASS                 0x00000080
#define REALTIME_PRIORITY_CLASS             0x00000100

#define CREATE_NEW_PROCESS_GROUP            0x00000200
#define CREATE_UNICODE_ENVIRONMENT          0x00000400

#define CREATE_SEPARATE_WOW_VDM             0x00000800
#define CREATE_SHARED_WOW_VDM               0x00001000
#define CREATE_FORCEDOS                     0x00002000

#define BELOW_NORMAL_PRIORITY_CLASS         0x00004000
#define ABOVE_NORMAL_PRIORITY_CLASS         0x00008000

#define CREATE_DEFAULT_ERROR_MODE           0x04000000
#define CREATE_NO_WINDOW                    0x08000000

#define PROFILE_USER                        0x10000000
#define PROFILE_KERNEL                      0x20000000
#define PROFILE_SERVER                      0x40000000

#define STARTF_USESHOWWINDOW                0x00000001
#define STARTF_USESIZE                      0x00000002
#define STARTF_USEPOSITION                  0x00000004
#define STARTF_USECOUNTCHARS                0x00000008
#define STARTF_USEFILLATTRIBUTE             0x00000010
#define STARTF_RUNFULLSCREEN                0x00000020  // ignored for non-x86 platforms
#define STARTF_FORCEONFEEDBACK              0x00000040
#define STARTF_FORCEOFFFEEDBACK             0x00000080
#define STARTF_USESTDHANDLES                0x00000100
#define STARTF_USEHOTKEY                    0x00000200


// for WaitForSingleObject
#define INFINITE                            0xFFFFFFFF  // Infinite timeout


DLL "tseshell.dll"
    integer proc InitPipe(var integer hPipe,
                          string pszRedirect:cstrval,
                          integer fAppend)
    proc ReleasePipe(integer iPipe) : "ReleasePipeInfo"
end


#define MAXPATH                             255         // _MAXPATH_



/****************************************************************************\
    global variables
\****************************************************************************/

constant HISTORY_IMMEDIATE = 1,         // history selection for command line
         HISTORY_FLOATING =  2,
         HISTORY_PROMPTED =  3

integer InsertMode =   OFF,             // use insert mode
        g_fHiddenBuffer = TRUE,         // separate buffering of stdout and stderr
        g_fSeparateBuffering = FALSE,   // separate buffering of stdout and stderr
        cmd_history =  HISTORY_IMMEDIATE,
        MaxTermLines = 1000             // maximum lines of screen buffer

integer insst, rmvtw, seofm, shelp, tabt, tabw, aind
string  wset [32] = ''

string DirBrackets [] = "[]",           // directory display bracketing chars
       BuffName [] = "[_tseshell_]",    // name of screen buffer
       RamLabel [] = "MS-RAMDR.IVE",    // label of MS RamDrive
       PrevDir  [MAXPATH] = '',         // name of previously active directory
       TempPath [MAXPATH],              // name of temporary file path
       TempFile [MAXPATH],              // name of redirection file
       ErrFile  [MAXPATH]               // name of redirection file

string TempInfo [MAXPATH],
       ErrInfo  [MAXPATH]

integer byStep =    false,  // stepwise command execution
        new_setup = false,  // settings changed
        dir_list =  0,      // buffer: dir listing for filename completion
        terminal =  0,      // buffer: output screen
        from =      0       // buffer: previous id

integer g_fProcessing = FALSE           // flag says if we're in terminal buffer

integer prompt_pos =     0, // position of cursor at command line
        show_help_line = 1  // help line display state in shell mode

constant ConfigKey =    <F9>,
         DosKey =       <F10>,
         ExitKey =      <Alt X>,
         ExecuteKey =   <Enter>,
         BypassKey =    <Escape>,
         NewLineKey =   <Ctrl Enter>


#ifdef chrisant
// my personal version uses these settings
constant GotoDosKey =   0,
         EditExecKey =  0
#else
// everybody else uses these settings
constant GotoDosKey =   <F9>,
         EditExecKey =  <Alt Enter>
#endif


string c_stSection[] = "TSEShell"
string c_stInsertMode[] = "InsertMode"
string c_stCmdHistory[] = "CmdHistory"
string c_stShowHelpLine[] = "ShowHelpLine"
string c_stPromptPos[] = "PromptPos"
string c_stMaxLines[] = "MaxLines"
string c_stHiddenBuffer[] = "HideShellBuffer"
string c_stSeparateBuffering[] = "SeparateBuffering"


forward proc Init()
forward proc ProcessShellWindow()



/*
 * Open/close pipes by invoking exported functions from TSESHELL.DLL.
 */

constant INVALID_HANDLE_VALUE = -1,     // invalid handle number
         STD_INPUT_HANDLE = -10,        // default handle of standard output
         STD_OUTPUT_HANDLE = -11,       // default handle of standard output
         STD_ERROR_HANDLE = -12,        // default handle of standard error
         needDos =  9                   // flag for external command request

integer iPipeOut = -1
integer iPipeErr = -1
integer hNewOut = INVALID_HANDLE_VALUE
integer hNewErr = INVALID_HANDLE_VALUE

proc OpenPipes(string cmd)
    string chHoriz[1]
    string stHorizFour[4]
    string stFont[32]
    integer nPointSize
    integer flags

    hNewOut = INVALID_HANDLE_VALUE
    hNewErr = INVALID_HANDLE_VALUE

    GetFont(stFont, nPointSize, flags)
    stFont = ""                                 // (suppress compiler warning)

    chHoriz = iif(flags & _FONT_OEM_, "ƒ", "-")
    stHorizFour = Format("":4:chHoriz)

    TempInfo = stHorizFour + " " + cmd + " " + stHorizFour
    TempInfo = Format(TempInfo:-(Query(ScreenCols) - Length(CurrDir()) - 4):chHoriz)
    TempInfo = Format(TempInfo; CurrDir(); stHorizFour; GetDateStr(); GetTimeStr())
    ErrInfo  = stHorizFour + " stderr " + stHorizFour

    // Create stdout pipe.

    TempFile = MakeTempName(TempPath)
    iPipeOut = InitPipe(hNewOut, TempFile, FALSE)
    #ifdef DEBUG
    if iPipeOut == INVALID_HANDLE_VALUE
        warn("InitPipe(_STDOUT_) failed")
    endif
    #endif

    // Create stderr pipe (or point it at the stdout pipe).

    if g_fSeparateBuffering
        ErrFile = MakeTempName(TempPath)
        iPipeErr = InitPipe(hNewErr, ErrFile, FALSE)
        #ifdef DEBUG
        if iPipeErr == INVALID_HANDLE_VALUE
            warn("InitPipe(_STDERR_) failed")
        endif
        #endif
    else
        iPipeErr = -1
        hNewErr = hNewOut
    endif
end

proc ClosePipes()
    ReleasePipe(iPipeOut)
    if iPipeErr <> -1
        ReleasePipe(iPipeErr)
    endif

    hNewOut = INVALID_HANDLE_VALUE
    hNewErr = INVALID_HANDLE_VALUE
end

proc OpenConsoleRedirection(var integer h1, var integer h2, string cmd)
    // Create the pipes.

    OpenPipes(cmd)

    // Redirect the console standard handles.

    h1 = GetStdHandle(STD_OUTPUT_HANDLE)
    SetStdHandle(STD_OUTPUT_HANDLE, hNewOut)

    h2 = GetStdHandle(STD_ERROR_HANDLE)
    SetStdHandle(STD_ERROR_HANDLE, hNewErr)
end

proc CloseConsoleRedirection(integer h1, integer h2)
    // Restore the console standard handles.

    SetStdHandle(STD_OUTPUT_HANDLE, h1)
    SetStdHandle(STD_ERROR_HANDLE, h2)

    // Close the pipes.

    ClosePipes()
end



/*
 * Helper routines.
 */

integer proc mMoveBlock()
    integer ilba = Set(InsertLineBlocksAbove, TRUE)
    integer n = MoveBlock()
    Set(InsertLineBlocksAbove, ilba)
    return(n)
end

integer proc mCopyBlock()
    integer ilba = Set(InsertLineBlocksAbove, TRUE)
    integer n = CopyBlock()
    Set(InsertLineBlocksAbove, ilba)
    return(n)
end

proc ReadDone()
    PushKey(Query(Key))
end

proc ShowList()
    UpdateDisplay(_ALL_WINDOWS_REFRESH_)
end


proc GetFromHistoryPrompted ()
    string Command[200] = GetText(1, CurrLineLen())

#ifdef _GER
    if Ask('DOS-Befehl:', Command, _DOS_HISTORY_)
#else
    if Ask('DOS command:', Command, _DOS_HISTORY_)
#endif
        BegLine()
        KillToEol()
        InsertText(Command, _INSERT_)
    endif
end

proc GetFromHistoryFloating()
    integer msAttr = Set(MsgAttr, Query(TextAttr))
    string Command[255] = GetText(1, CurrLineLen())

    Window(WhereX(), WhereY(), WhereX(), WhereY())
    GotoXY(1, 1)
    PushKey(<CursorUp>)
    Hook(_LIST_CLEANUP_, ReadDone)
    Hook(_LIST_STARTUP_, ShowList)

    if lRead(Command, 200, _DOS_HISTORY_)
        BegLine()
        KillToEol()
        InsertText(Command, _INSERT_)
    endif

    UnHook(ShowList)
    UnHook(ReadDone)
    FullWindow()
    Set(MsgAttr, msAttr)
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
                when <Ctrl CursorUp>, <Ctrl GreyCursorUp>
                    n= iif (n == 1, hmax, n-1)
                when <Ctrl CursorDown>, <Ctrl GreyCursorDown>
                    n= iif (n == hmax, 1, n+1)
                when <Enter>, <GreyEnter>
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



/*
 * Insert from list of available files.
 */

proc InsertFileName ()
    integer eol = CurrChar () == _AT_EOL_
    string  wildcard [MAXPATH] = PickFile (GetWord (true))
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

    UpdateDisplay ()
end



/*
 * History lists (commands and filenames).
 */

proc FilenameHistory ()
    integer msAttr = Set (MsgAttr, Query (TextAttr))
    string  Filename [MAXPATH] = ''

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
    UpdateDisplay ()
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

    UpdateDisplay ()
end



/*
 * Search ram drive.
 */

proc FindTempDrive ()
    integer drv
    integer handle

    // if it's already set, don't reset it
    if TempPath <> ""
        return()
    endif

    // check some common environment variables
    if GetEnvStr("TMP") <> ""
        TempPath = GetEnvStr("TMP")
        return()
    endif
    if GetEnvStr("TEMP") <> ""
        TempPath = GetEnvStr("TEMP")
        return()
    endif

    // check for RAM disk
    for drv = Asc ("c") to Asc ("z")
        handle = FindFirstFile(Chr (drv)+":\*.*", _VOLUME_)
        if handle <> -1
            repeat
                if (FFAttribute() & _VOLUME_) and (FFName() == RamLabel)
                    TempPath = Chr (drv)+":\"       // SchS \\
                    return ()
                endif
            until not FindNextFile(handle, _VOLUME_)
            FindFileClose(handle)
        endif
    endfor

    // if all else fails, use TSE LoadDir
    TempPath= SplitPath(LoadDir(), _DRIVE_|_PATH_)
end



/*
 * Startup and shutdown.
 */

proc LoadSetup()
	InsertMode = GetProfileInt(c_stSection, c_stInsertMode, OFF)
	cmd_history = GetProfileInt(c_stSection, c_stCmdHistory, HISTORY_IMMEDIATE)
	show_help_line = GetProfileInt(c_stSection, c_stShowHelpLine, TRUE)
	prompt_pos = GetProfileInt(c_stSection, c_stPromptPos, 0)
	MaxTermLines = GetProfileInt(c_stSection, c_stMaxLines, 1000)
	g_fHiddenBuffer = GetProfileInt(c_stSection, c_stHiddenBuffer, TRUE)
	g_fSeparateBuffering = GetProfileInt(c_stSection, c_stSeparateBuffering, FALSE)
end


proc SaveSetup ()
    if new_setup
		WriteProfileInt(c_stSection, c_stInsertMode, InsertMode)
		WriteProfileInt(c_stSection, c_stCmdHistory, cmd_history)
		WriteProfileInt(c_stSection, c_stShowHelpLine, show_help_line)
		WriteProfileInt(c_stSection, c_stPromptPos, prompt_pos)
		WriteProfileInt(c_stSection, c_stMaxLines, MaxTermLines)
		WriteProfileInt(c_stSection, c_stHiddenBuffer, g_fHiddenBuffer)
		WriteProfileInt(c_stSection, c_stSeparateBuffering, g_fSeparateBuffering)
    endif
end



/*
 * Status line indicator.
 */

proc ShowDir ()
    string dir [MAXPATH] = CurrDir ()

    if Query (ShowStatusLine)
        if prompt_pos
            VGotoXYAbs (prompt_pos, Query(StatusLineRow))
        else
            VGotoXYAbs (Query(ScreenCols) - Length (dir), Query(StatusLineRow))
        endif
        Set (Attr, Query (StatusLineAttr))
        PutHelpLine (DirBrackets [1]+ "{"+ dir [1..Length (dir)-1]+ "}"+ DirBrackets [2])
    endif
end



/****************************************************************************/

proc ClearCmdLine()
    BegLine()
    KillToEol()
    UpdateDisplay()
end


proc LimitScreenBuffer ()
    // limit screen buffer line count
    if NumLines() > MaxTermLines
        MarkLine(1, NumLines() - MaxTermLines)
        KillBlock()
        UpdateDisplay(_WINDOW_REFRESH_)
    endif
end


proc DosCommand_Gui(string Command)
    string stSecurity[12] = ""
    string startupinfo[17*4] = ""
    string processinfo[4*4] = ""
    integer hProcess
    integer hThread
    integer fSuccess
    integer dwLastError

#if 0
    // This simpler alternative approach doesn't seem to handle external
    // commands properly, so we call CreateProcess() directly.
    AllocConsole()
    SetForegroundWindow(GetConsoleWindow())
    DosCommand_Console(Command)
    FreeConsole()
#endif

    AllocConsole()
    SetForegroundWindow(GetConsoleWindow())
    OpenPipes(Command)

    PokeLong(AdjPtr(Addr(stSecurity), 2+0), 12)
    PokeLong(AdjPtr(Addr(stSecurity), 2+4), 0)
    PokeLong(AdjPtr(Addr(stSecurity), 2+8), TRUE)

    PokeLong(AdjPtr(Addr(startupinfo), 2+0), 17*4)
    PokeLong(AdjPtr(Addr(startupinfo), 2+4), 0)
    PokeLong(AdjPtr(Addr(startupinfo), 2+8), 0)
    PokeLong(AdjPtr(Addr(startupinfo), 2+12), 0)
    PokeLong(AdjPtr(Addr(startupinfo), 2+16), 0)
    PokeLong(AdjPtr(Addr(startupinfo), 2+20), 0)
    PokeLong(AdjPtr(Addr(startupinfo), 2+24), 0)
    PokeLong(AdjPtr(Addr(startupinfo), 2+28), 0)
    PokeLong(AdjPtr(Addr(startupinfo), 2+32), 0)
    PokeLong(AdjPtr(Addr(startupinfo), 2+36), 0)
    PokeLong(AdjPtr(Addr(startupinfo), 2+40), 0)
    PokeLong(AdjPtr(Addr(startupinfo), 2+44), STARTF_USESTDHANDLES)    // flags
    PokeWord(AdjPtr(Addr(startupinfo), 2+48), 0)
    PokeWord(AdjPtr(Addr(startupinfo), 2+50), 0)
    PokeLong(AdjPtr(Addr(startupinfo), 2+52), 0)
    PokeLong(AdjPtr(Addr(startupinfo), 2+56), GetStdHandle(STD_INPUT_HANDLE))
    PokeLong(AdjPtr(Addr(startupinfo), 2+60), hNewOut)
    PokeLong(AdjPtr(Addr(startupinfo), 2+64), hNewErr)

    fSuccess = CreateProcess(GetEnvStr("COMSPEC"), "/c "+Command,
                             AdjPtr(Addr(stSecurity), 2),
                             AdjPtr(Addr(stSecurity), 2),
                             TRUE,
                             NORMAL_PRIORITY_CLASS,
                             0, 0,
                             AdjPtr(Addr(startupinfo), 2),
                             AdjPtr(Addr(processinfo), 2))

    if fSuccess
        hProcess = PeekLong(AdjPtr(Addr(processinfo), 2+0))
        hThread = PeekLong(AdjPtr(Addr(processinfo), 2+4))
        WaitForSingleObject(hProcess, INFINITE)
        CloseHandle(hThread)
        CloseHandle(hProcess)
    else
        dwLastError = GetLastError()
    endif

    FreeConsole()
    ClosePipes()

    if not fSuccess
        Warn("CreateProcess failed:"; dwLastError; "(",Command,")")
    endif
end


proc DosCommand_Console(string Command)
    integer h1, h2

    OpenConsoleRedirection(h1, h2, Command)

    Set(Attr, Query(TextAttr))
    ClrScr()
    GotoXY(1, WhereY())

    Dos(Command, _DONT_PROMPT_|_DONT_CLEAR_|_DONT_CHANGE_VIDEO_)

    CloseConsoleRedirection(h1, h2)
end


proc DosCommand(string Command)
    if isGui()
        DosCommand_Gui(Command)
    else
        DosCommand_Console(Command)
    endif
end


integer proc mInsertFile(string fn, string hdr, integer cbMin)
    integer cid = GetBufferId()
    integer tmp = CreateTempBuffer()

    if not tmp
        Warn("Unable to create temp buffer.")
        return(FALSE)
    endif

    if FindThisFile(fn) and cbMin <= FFSize()
        if not InsertFile(fn, _DONT_PROMPT_)
            GotoBufferId(cid)
            AbandonFile(tmp)
            return(FALSE)
        endif

        UnMarkBlock()
        BegFile()
        if Length(hdr)
            InsertLine(hdr)
        endif
        MarkLine()
        EndFile()
        MarkLine()
        GotoBufferId(cid)
        mMoveBlock()
    endif

    AbandonFile(tmp)
    return(TRUE)
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
        BegLine()

        // first do stderr, but it ends up following the stdout
        if g_fSeparateBuffering
            mInsertFile(ErrFile, ErrInfo, 1)
            if FileExists(ErrFile)
                EraseDiskFile(ErrFile)
            else
                Warn('File not found: ErrFile')
            endif
            UnmarkBlock()
        endif

        // then do stdout
        mInsertFile(TempFile, TempInfo, 0)
        if FileExists(TempFile)
            EraseDiskFile(TempFile)
        else
            Warn('File not found: TempFile')
        endif
        UnmarkBlock()
    else
        AddLine()
    endif

    UpdateDisplay(_ALL_WINDOWS_REFRESH_)
    FileChanged(FALSE)                  // not an editing buffer anyway
    EndFile()
    ScrollToRow(Query(WindowRows))      // active line as low as possible

    if isMacroLoaded("shift2") or isMacroLoaded("cuamark")
        // mark the text so typing replaces it (more convenient this way)
        PushKey(<Shift End>)
        PushKey(<Home>)
    endif
end


proc ExecuteCurrentLine ()
    string  Command [200] = GetText (1, CurrLineLen ())

    if Command <> ''
        KillLine ()
        ExecuteLine (Command)
    else
        Creturn ()
        UpdateDisplay ()
    endif
end


proc ExecuteBlock (integer destroy)
    integer Batch = CreateTempBuffer ()
    string  Command [200]

    if Batch
        GotoBufferId (Batch)
        if destroy
            mMoveBlock ()
        else
            mCopyBlock ()
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



/*
 * Configuration menu.
 */

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

    title = "TSEShell-Einstellungen"
    width = 54
    x =     22
    y =      4

    "&Hide Shell Buffer"
        [OnOffStr(g_fHiddenBuffer):3],
        OnOff(g_fHiddenBuffer),
        DontClose

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

    "Separate StdOut and StdErr"
        [OnOffStr(g_fSeparateBuffering):3],
        OnOff(g_fSeparateBuffering),
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

    title = "TSEShell Configuration"
    width = 44
    x =     30
    y =      4

    "&Hide Shell Buffer"
        [OnOffStr(g_fHiddenBuffer):3],
        OnOff(g_fHiddenBuffer),
        DontClose

    "&Command History Handling"
        [MenuStr (CommandMenu, cmd_history): 9],
        CommandMenu (),
        DontClose

    "&Insert Mode"
        [OnOffStr (InsertMode): 3],
        OnOff (InsertMode),
        DontClose

    "Step Through &Batches"
        [OnOffStr (byStep): 3],
        OnOff (byStep),
        DontClose

    "&Separate StdOut and StdErr"
        [OnOffStr(g_fSeparateBuffering):3],
        OnOff(g_fSeparateBuffering),
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


// provides 4DOS-like filename expansion!
proc SmartTab(integer flavor)
	integer fFnExp

	fFnExp = isMacroLoaded("fnexp")
	if not fFnExp
		Set(MsgLevel, _NONE_)
		fFnExp = LoadMacro("fnexp")
		Set(MsgLevel, _ALL_MESSAGES_)
	endif
	if not fFnExp
		ChainCmd()
	else
		case flavor
			when 1
				ExecMacro("fnexp -next")
			when 2
				ExecMacro("fnexp -prev")
			when 3
				ExecMacro("fnexp -pick")
		endcase
	endif
end



/*
 * Key bindings.
 */

#ifdef _GER
keydef DosCommandKeys

    <HelpLine>            "{F1}-Hilfe {F2}-Datei {F9}-Einstellung {F10}/{Enter}-Befehl {Esc}-Befehlszeile lîschen"
    <Alt HelpLine>        "{Alt:} {F7}-Editorverz.wechseln {Del}-Puffer lîschen {}/{}/{P}/{N}-Editor {X}-Ende"
    <Ctrl HelpLine>       "{Ctrl:} {F2}-Dateiauswahl {F7}-Zum Editorverz. {Enter}-Neue Zeile {}/{}-frÅhere Befehle"
    <Shift HelpLine>      "{Shift:} "
    <CtrlAlt HelpLine>    "{Ctrl Alt:} "
    <CtrlShift HelpLine>  "{Ctrl-Shift:} {}/{}-Befehlszeilenfenster"
    <AltShift HelpLine>   "{Alt-Shift:} "

    <ExitKey>               PurgeMacro(CurrMacroFilename()) QuitFile()
    <BypassKey>             ClearCmdLine()
    <DosKey>                ExecuteCommand()
    <ExecuteKey>            ExecuteCommand()
    <NewLineKey>            Creturn()
    <Ctrl GreyEnter>        Creturn()

    <Ctrl CursorUp>         GetFromHistory()
    <Ctrl CursorDown>       GetFromHistory()

    <CtrlShift CursorUp>    GetFromHistoryFloating()
    <CtrlShift CursorDown>  GetFromHistoryFloating()

    <Tab>                   SmartTab(1)
    <Shift Tab>             SmartTab(2)
    <Ctrl Tab>              SmartTab(3)

    //  miscellaneous

    <Backspace>             BackSpace()
    <Alt Del>               EmptyBuffer() UpdateDisplay(_WINDOW_REFRESH_)

    <F1>                    ExecMacro("TseSHilf")
    <Ctrl F2>               InsertFileName()
    <F2>                    FilenameHistory()
    <Ctrl F7>               LogDrive(PrevDir) ChDir(PrevDir)
    <Alt F7>                PrevDir = CurrDir()
    <ConfigKey>             Configure()
    <F11>                   PrevFile()
end
#else
keydef DosCommandKeys

    <HelpLine>            "{F1}-Help {F2}-Filename {F9}-Configure {F10}/{Enter}-Execute {Esc}-Clear Command Line"
    <Alt HelpLine>        "{Alt:} {F7}-Change Editor Dir {Del}-Clear Buffer {Left}/{Right}/{P}/{N}-Editor {X}-Exit"
    <Ctrl HelpLine>       "{Ctrl:} {F2}-Pick File {F7}-Goto Editor Dir {Enter}-New Line {}/{}-Command History"
    <Shift HelpLine>      "{Shift:} "
    <CtrlAlt HelpLine>    "{Ctrl Alt:} "
    <CtrlShift HelpLine>  "{Ctrl-Shift:} {}/{}-Command History Window"
    <AltShift HelpLine>   "{Alt-Shift:} "

    <ExitKey>               PurgeMacro(CurrMacroFilename()) AbandonFile()
    <BypassKey>             ClearCmdLine()
    <DosKey>                ExecuteCommand()
    <ExecuteKey>            ExecuteCommand()
    <NewLineKey>            Creturn()
    <Ctrl GreyEnter>        Creturn()

    <Ctrl CursorUp>         GetFromHistory()
    <Ctrl CursorDown>       GetFromHistory()

    <CtrlShift CursorUp>    GetFromHistoryFloating()
    <CtrlShift CursorDown>  GetFromHistoryFloating()

    <Tab>                   SmartTab(1)
    <Shift Tab>             SmartTab(2)
    <Ctrl Tab>              SmartTab(3)

    //  miscellaneous

    <Backspace>             BackSpace()
    <Alt Del>               EmptyBuffer() UpdateDisplay(_WINDOW_REFRESH_)

    <F1>                    ExecMacro("TseSHelp")
    <Ctrl F2>               InsertFileName()
    <F2>                    FilenameHistory()
    <Ctrl F7>               LogDrive(PrevDir) ChDir(PrevDir)
    <Alt F7>                PrevDir = CurrDir()
    <ConfigKey>             Configure()
    <F11>                   PrevFile()
end
#endif



/*
 * Save/restore editor configuration settings.
 */

proc SaveVars()
    insst = Set(Insert, InsertMode)
    aind =  Set(AutoIndent, OFF)
    tabt =  Set(TabType, _HARD_)
    tabw =  Set(TabWidth, 8)
    rmvtw = Set(RemoveTrailingWhite, ON)
    seofm = Set(ShowEOFMarker, OFF)
    shelp = Set(ShowHelpLine, show_help_line)
    //wset =  Set(WordSet, ChrSet("-!\x22#$%&'()0-9A-Z_a-z~:\\.*?"))
    wset =  Set(WordSet, ChrSet("-!\x22#$%&'()0-9A-Z_a-z~:.*?"))
    // modified wordset for (ambigous) file names
end


proc SaveState()
    string OldDir[MAXPATH] = CurrDir()

    SaveVars()

    if PrevDir <> ''
        LogDrive(PrevDir)
        ChDir(PrevDir)
    endif
    PrevDir = OldDir
end


proc RestoreVars()
    Set(Insert, insst)
    Set(AutoIndent, aind)
    Set(TabType, tabt)
    Set(TabWidth, tabw)
    Set(RemoveTrailingWhite, rmvtw)
    Set(ShowEofMarker, seofm)
    Set(ShowHelpLine, shelp)
    Set(WordSet, wset)
end


proc RestoreState()
    string OldDir[MAXPATH] = CurrDir()

    SaveSetup()
    RestoreVars()

    LogDrive(PrevDir)
    ChDir(PrevDir)
    PrevDir = OldDir
end



/*
 * Buffer control.
 */

proc GotoDosBuffer ()
    Init()

    //$ review: (chrisant) this seems very suspicious...
    while KeyPressed ()
        GetKey ()
    endwhile

    // our hook will then call ProcessShellWindow
    GotoBufferId(terminal)
    ExecHook(_ON_CHANGING_FILES_)
end
#if GotoDosKey
<GotoDosKey>        GotoDosBuffer ()
#endif


#if EditExecKey
proc ExecuteBufferCmd()
    string Command[255]

    if isBlockInCurrFile()
        GotoDosBuffer()
        ExecuteBlock(FALSE)             // as "batch"
    else
        Command = GetText(1, CurrLineLen())

        if Command <> ''
            GotoDosBuffer()
            EndFile()
            ExecuteLine(Command)
        else
            Alarm()
        endif
    endif

    LimitScreenBuffer()
end
<EditExecKey>       ExecuteBufferCmd()
#endif


proc AfterCommand()
    if not g_fProcessing and terminal and GetBufferId() == terminal
        ProcessShellWindow()
    elseif g_fProcessing
        if GetBufferId() <> terminal
            EndProcess()
        else
            // clear dirty bit for terminal buffer
            FileChanged(FALSE)
        endif
    endif
end


proc ProcessShellWindow()
    integer id

    #ifdef DEBUG
    if g_fProcessing
        Warn("GOING RECURSIVE")
        return()
    endif
    #endif

    if g_fHiddenBuffer
        from = GetBufferId()
    endif

    // set flag
    g_fProcessing = TRUE

    // enable special keys
    Enable(DosCommandKeys)

    // hook to show current directory
    Hook(_AFTER_UPDATE_STATUSLINE_, ShowDir)
    ShowDir()

    if g_fHiddenBuffer
        BufferType(_NORMAL_)
        ExecHook(_IDLE_)
    endif

    // use special settings (saving current settings)
    LoadSetup()
    SaveState()

    // process keys
    Process()

    id = GotoBufferId(terminal)
    if id
        if g_fHiddenBuffer
            BufferType(_HIDDEN_)
        else
            ExecHook(_ON_CHANGING_FILES_)
        endif

        // restore settings (for compatibility with macros such as FS and
        // FILEPAL, we can't RestoreState if terminal==0).
        RestoreState()

        GotoBufferId(id)
    endif

    UnHook(ShowDir)
    Disable(DosCommandKeys)

    // reset flag
    g_fProcessing = FALSE

    if g_fHiddenBuffer
        GotoBufferId(from)
        ExecHook(_ON_CHANGING_FILES_)
    endif

    // refresh display
    UpdateDisplay(_ALL_WINDOWS_REFRESH_)
end



/*
 * Main program.
 */

// Init() - initialize settings, temp path, terminal buffer, etc as necessary
// (function is a no-op when all are already initialized).
proc Init()
    integer from = GetBufferId()

    // determine name of temp file
    FindTempDrive()

    // goto or make shell buffer
    terminal = GetBufferId(BuffName)
    if terminal
        if g_fHiddenBuffer
            GotoBufferId(terminal)
            BufferType(_HIDDEN_)
        endif
    else
        if g_fHiddenBuffer
            terminal = CreateBuffer(BuffName, _HIDDEN_)
        else
            terminal = CreateBuffer(BuffName)
        endif
    endif

    if not dir_list
        dir_list = CreateTempBuffer ()
    endif

    // test buffer allocation
    if not (terminal and dir_list)
        Warn("Cannot allocate buffers")
        AbandonFile(terminal)
        PurgeMacro(CurrMacroFilename ())
        return ()
    endif

    // return to where we came from
    GotoBufferId(from)
end


// OnFileQuit() - get notified when terminal buffer gets destroyed by user.
proc OnFileQuit()
    if GetBufferId() == terminal
        // terminal buffer is going away, restore settings (important to do
        // b/c for compatibility with macros such as FS and FILEPAL, we can't
        // RestoreState in ProcessShellWindow if terminal==0).
        RestoreState()
        // force to recreate it next time we need it.
        terminal = 0
    endif
end


// WhenPurged() - unload TSEShell on user request.
proc WhenPurged()
    integer id

    if g_fHiddenBuffer
        if GetBufferId() <> terminal
            id = GotoBufferId(terminal)
            if id
                // if purged while running, leave the terminal buffer intact and
                // change it to a normal buffer.
                BufferType(_NORMAL_)
                GotoBufferId(id)
            endif
        endif

        GotoBufferId(from)              // always return to where we came from
    endif

    AbandonFile(dir_list)
end


proc WhenLoaded ()
    if WhichOS() == _WINDOWS_
        Warn("TSEShell only runs on Windows NT.")
        PurgeMacro(CurrMacroFilename())
        return()
    endif

    // must call Init here so the PurgeMacro call inside Init will work if
    // some kind of error was encountered.
    Init()

    // hook important stuff
    Hook(_AFTER_COMMAND_, AfterCommand)
    Hook(_ON_FILE_QUIT_, OnFileQuit)
    Hook(_ON_EXIT_CALLED_, OnFileQuit)
end


proc Main ()
    GotoDosBuffer()
end
