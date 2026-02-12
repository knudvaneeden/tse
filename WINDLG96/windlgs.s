/****************************************************************************\

    WinDlgs.S

    Windows dialog boxes for SAL.

    Version         v0.96/12.05.05
    Copyright       (c) 2003-2005 by DiK

    Overview:

    This macro is a run time library which implements Windows style dialog
    boxes for TSE Pro. It is not meant to be directly run by the user.
    The file WindDlgs.dll is an integral part of this package. The dll is
    written using Borland's Delphi and implements the actual dialogs.

    To implement the FindAndDo command WinDlgs uses a slightly adapted
    version of SemWare's find&do macro. find&do1 is for the most part
    identical to the original macro, but adds a few lines of code which
    allow us to bypass the internal user interface.

    The following commands have been implemented so far. Most commands are
    run by calling the global procedures defined at the end of the file. Two
    notable exception exist: grep and todo. These are external macros which
    utilize WinDlgs as their input device. Some of the commands also use
    command line switches to determine the way they work (e.g. DlgOpen).

    Library version number (windlgver)
        Displays the version number of the windows dialogs (WinDlgs).

    Opening and saving files (dlgopen)
        Also used to save blocks and insert files, used to load and
        execute SAL macros and used to load and save key macros.
        Uses command line switches to specify what to do.

            none    open a file for editing (Open...)
            -s      save file using a new name (Save As...)
            -i      insert a file at the cursor
            -b      save a block into a separate file
            -e      execute a SAL macro
            -l      load a SAL macro
            -k      load key macros
            -v      save key macros

        The open command (no switch) allows you to select multiple files.
        Use the Ctrl and Shift keys to select separate files and block of
        files. If you check "Open As Binary" the file(s) is (are) loaded
        in binary mode (-b64) and Hex View is activated.

    The buffer list command (dlgbuff)
        A list of the currently loaded files. The Del key is a shortcut for
        the Remove button.

    The recent file buffer (dlgrcnt)
        A list of recently edited files. Doesn't need the buffer id of the
        recent files list anymore. Thus works fine stand alone.

    Changing the current folder (dlgbrows)
        Use command line switches to select what the dialog does.

            none    do nothing, only return name of chosen folder
            -c      preselect folder containing current file
            -g      go to chosen folder, when OK is pressed

    Filling blocks with text (dlgfill)
        A simply input device, to ask for the text.

    Finding and replacing text (dlgfind, dlgrplc, dlgfnddo)
        These work exactly as advertised ;-).

    Finding text across multiple files and on disk (dlggrep)
        Uses the grep macro. Well, actually it's the other way round,
        the grep macro uses dlggrep to get the user's input, e.g. use
        grep to start the command. Also uses viewgrep to display the
        result. (viewgrep with kudos to Chris Antos.)

    Numerically positioning the cursor (dlggoto)
        The GotoLine and GotoColumn commands wrapped into one package.

    Displaying bookmarks (dlgbookmarks)
        This displays a list of the currently defined bookmarks. The
        list includes the bookmark's ID and its location (filename,
        line and column).

    The macro control center (dlgmcc)
        Everything needed to search, load, execute and purge SAL macros.

    ASCII chart (dlgascii)
        Launches window's character map. If the latter isn't installed
        on your computer, you'll get an error message instead.

    Executing OS commands (dlgdos)
        A simply input device, to ask for the command. Use the "-c" switch,
        if you want to capture the output of the command.

    Options dialog (dlgopts)
        This dialog allows you to set some of the more often used configuration
        parameters. It is not meant as a replacement for the full configuration
        utility.

    History list maintenance (dlghist)
        This macro allows you to view and maintain the history lists of TSE.

    To-Do item manager (dlgtodolist, dlgaddtodo, dlgtodosetup)
        These macros are visual interfaces for the todo manager. They are
        called by the todo macro and do not work when called directly by
        the user.

    A note on return codes
        The results of the API functions of WinDlgs generally correspond to
        the values defined for the windows API. These can be and in the
        current version of WinDlgs are translated to the values defined for
        the older character based dialogs via the SetMCL function. SetMCL
        also sets the macro command line to the corresponding value. This
        is done for the sole purpose of backwards compatibility, so that
        WindDlgs can transparently be substituted for Dialogs.

    A note on the recent files buffer
        The recent files dialog is now able to find the recent files buffer
        on its own. This is possible, because the recent files buffer is a
        named buffer in the more recent versions of TSEPro-32. So keep in
        mind, if you should change the name of recent files buffer in the
        UI, you also have to change the contents of the RFLBID global
        variable.

    History
    v0.96/12.05.05  release candidate one
    v0.92/29.01.04  third beta
    v0.91/19.08.03  second beta
    v0.90/08.05.03  first beta
    v0.70/21.03.03  alpha version (c.f. windlgs.dpr)

\****************************************************************************/

/****************************************************************************\
    constants
\****************************************************************************/

// TSE specific

string TsePro[] = "TSE Pro"
string RFLBID[] = "*Recent Files List*" // documented only in-code in the UI files

// macro communication

string DlgMsgText[] = "DlgMsgText"      // session global variable used by Dialogs

// string list return codes

constant    SL_OK           = 0
constant    SL_INV_ID       = -1        // id of string list invalid
constant    SL_INV_INDEX    = -2        // index into string list invalid
constant    SL_INV_LENGTH   = -3        // string to short for result
constant    SL_EXCEPTION    = -99       // an unhandled exception occurred

// return codes of old character based dialogs

constant    DLG_ID_CANCEL   = 1
constant    DLG_ID_OK       = 2
constant    DLG_ID_YES      = 3
constant    DLG_ID_NO       = 4
constant    DLG_ID_HELP     = 5

// win-api return codes

constant    ID_OK           = 1
constant    ID_CANCEL       = 2
constant    ID_ABORT        = 3
constant    ID_RETRY        = 4
constant    ID_IGNORE       = 5
constant    ID_YES          = 6
constant    ID_NO           = 7
constant    ID_CLOSE        = 8
constant    ID_HELP         = 9

// user defined return codes

constant    ID_USER         = 65536
constant    ID_HELPEX       = ID_USER + 1
constant    ID_LIST         = ID_USER + 2
constant    ID_OPEN         = ID_USER + 3
constant    ID_LOAD         = ID_USER + 4
constant    ID_SAVE         = ID_USER + 5
constant    ID_REMOVE       = ID_USER + 6
constant    ID_REMOVE_ALL   = ID_USER + 7
constant    ID_NEXT         = ID_USER + 8
constant    ID_PREV         = ID_USER + 9

// action codes for opening/saving files (dlgopen)

constant    OM_OPEN         = 0
constant    OM_SAVEAS       = 1
constant    OM_INSERT       = 2
constant    OM_SAVEBLOCK    = 3
constant    OM_EXECMACRO    = 4
constant    OM_LOADMACRO    = 5
constant    OM_LOADKEY      = 6
constant    OM_SAVEKEY      = 7
//constant    OM_DECOMP       = 8
//constant    OM_RECOMP       = 9
//constant    OM_DIALOG       = 10
//constant    OM_RESOURCE     = 11
constant    OM_LOADPROJ     = 12
constant    OM_SAVEPROJ     = 13

// file types for open/save dialogs

string  OF_ANY[]        = "Any File (*.*)|*.*"
string  OF_TXT[]        = "Text Files (*.txt)|*.txt"
string  OF_INP[]        = "Data Files (*.inp;*.out)|*.inp;*.out"
string  OF_DOC[]        = "Document Files (*.doc)|*.doc"
string  OF_PAS[]        = "Pascal Files (*.dpr;*.pas;*.inc)|*.dpr;*.pas;*.inc"
string  OF_C[]          = "C Files (*.c;*.h;*.cpp;*.hpp)|*.c;*.h;*.cpp;*.hpp"
string  OF_ASM[]        = "Assembler Files (*.asm)|*.asm"
string  OF_FOR[]        = "Fortran Files (*.f;*.f95;*.for)|*.f;*.f95;*.for"
string  OF_BAT[]        = "Batch Files (*.bat;*.btm)|*.bat;*.btm"

string  OF_TPR[]        = "TSE Project - Editor State (*.tpr)|*.tpr"
string  OF_SAL[]        = "SAL Files (*.s;*.si;*.ui)|*.s;*.si;*.ui"
string  OF_MAC[]        = "SAL Macros (*.mac)|*.mac"
string  OF_KBD[]        = "TSE Key Macros (*.kbd)|*.kbd"

//string  OF_K[]          = "TSE Key Listings (*.k)|*.k"

/****************************************************************************\
    globale variables
\****************************************************************************/

integer OptionsPageIndex = 0    // options dialog: index of active page

integer TodoListX = 0           // todo list: x position
integer TodoListY = 0           // dito: y position
integer TodoListSortCol = 0     // dito: index of sort column

/****************************************************************************\
    dll interfaces
\****************************************************************************/

#define SC_MINIMIZE     0xF020
#define SC_MAXIMIZE     0xF030
#define SC_RESTORE      0xF120

#define WM_SYSCOMMAND                   0x0112

dll "<user32.dll>"

    integer proc isMinimized(integer hWnd) : "IsIconic"
    integer proc IsMaximized(integer hWnd) : "IsZoomed"

    integer proc SendMessage(integer hWnd,
        integer Msg, integer wParam, integer lParam) : "SendMessageA"

end

/****************************************************************************/

#define SW_SHOW             5

dll "<shell32.dll>"

    integer proc ShellExecute(integer HWND, string lpOperation: cstrval,
        string lpFile: cstrval, string lpParameters: cstrval,
        string lpDirectory: cstrval, integer nShowCmd): "ShellExecuteA"

end

/****************************************************************************/

dll "WinDlgs.dll"

    // string lists

    integer proc AllocStrList()
    proc FreeStrList(integer ID)
    integer proc IsStrListValid(integer ID)
    integer proc GetStrListSize(integer ID)
    proc  ClearStrList(integer ID)
    integer proc AddToStrList(integer ID, string S)
    integer proc InsertIntoStrList(integer ID, string S, integer Index)
    integer proc GetFromStrList(integer ID, var string S, integer Index)

    // initialize dll

    proc WinDlgInit(integer WinHandle)
    integer proc WinDlgVersion()

    // dialogs

    integer proc WinDlgMsgBox(string TitleText, string MsgText)
    integer proc WinDlgYesNoBox(string TitleText, string MsgText)
    integer proc WinDlgInpBox(string TitleText, string MsgText, integer HistID)
    integer proc WinDlgInpBoxEx(string TitleText, string MsgText, integer HistID)

    integer proc WinDlgOpen(integer FilesID, integer TypesID, string Caption)
    integer proc WinDlgOpenEx(integer FilesID, integer TypesID, string Caption, var integer AsBinary)
    integer proc WinDlgSaveAs(integer FilesID, integer TypesID, string Caption)

    integer proc WinDlgBuffers(integer ID, var string Picked)
    integer proc WinDlgRecent(integer ID, var string Picked)

    integer proc WinDlgPickFolder(var string Folder, integer FolderHist)

    integer proc WinDlgFind(integer FindHist, integer FindOptsHist)
    integer proc WinDlgReplace(integer FindHist, integer ReplaceHist, integer ReplaceOptsHist)
    integer proc WinDlgGrep(integer FindHist, integer FileHist, integer ExclHist, integer PathHist, integer FindOptsHist, integer GrepDisk)
    integer proc WinDlgFindAndDo(integer FindHist, integer FindOptsHist, integer FindMacsHist, var integer Action)
    integer proc WinDlgGoto(integer LineHist, integer ColHist)
    integer proc WinDlgBookmarks(integer BookmarkList, var string Selected, var integer SortCol)

    integer proc WinDlgMCC(integer MacroList, integer MacroHist)

    integer proc WinDlgOpts(integer OptsList, integer DikOpts, var integer PageIndex)
    integer proc WinDlgComp(integer FileID1, integer FileID2)

    integer proc WinDlgHistories(integer HistList, var integer Selected)
    integer proc WinDlgHistStrings(integer HistList, string Title, var integer Selected)
    integer proc WinDlgHistUser(integer HistList, var integer Selected)

    integer proc WinDlgAddTodo(integer DataID, var string Args)
    integer proc WinDlgTodoList(integer DataID, var integer Selected, var integer X, var integer Y, var integer SortCol)
    integer proc WinDlgTodoSetup(var string Args)

    integer proc WinDlgStrList(integer ListID)
end

/****************************************************************************\
    forward
\****************************************************************************/

forward proc sWinDlgOpen()
forward proc sWinDlgRecent()

/****************************************************************************\
    translating return codes
    used to transparently substitute WinDlgs for Dialogs
\****************************************************************************/

integer proc SetMCL(integer rc)
    integer dlg_rc

    case rc
        when ID_OK          dlg_rc = DLG_ID_OK
        when ID_CANCEL      dlg_rc = DLG_ID_CANCEL
        when ID_YES         dlg_rc = DLG_ID_YES
        when ID_NO          dlg_rc = DLG_ID_NO
        when ID_HELP        dlg_rc = DLG_ID_HELP
    endcase
    Set(MacroCmdLine, Str(dlg_rc))
    return(rc)
end

/****************************************************************************\
    helper routines
\****************************************************************************/

//  allocate and check working buffer

integer proc CreateWorkingBuffer(var integer bid)
    integer cid = GetBufferId()

    bid = CreateTempBuffer()
    if bid
        GotoBufferId(cid)
    else
        Warn("WinDlgs: buffer allocation failed")
    endif
    return(bid)
end

//  allocate a StrList or clear the current one and
//  copy specified history list into the new StrList

integer proc CopyHistoryToList(integer ListID, integer HistID)
    integer I

    if ListID == SL_INV_ID
        ListID = AllocStrList()
    else
        ClearStrList(ListID)
    endif
    for I = 1 to NumHistoryItems(HistID)
        AddToStrList(ListID, GetHistoryStr(HistID, I))
    endfor
    return(ListID)
end

//  get current word or block and
//  copy the string into the specified list

proc CopyWordToList(integer HistID)
    string s[255]

    if isBlockInCurrFile()
        s = GetMarkedText()
    else
        s = GetWord()
    endif
    if s <> ""
        InsertIntoStrList(HistID, s, 0)
    endif
end

//  retrieve the topmost string from a StrList and
//  additionally copy the string into the specified history list

proc GetTopHistoryString(var string HistStr, integer ListID, integer HistID)
    GetFromStrList(ListID, HistStr, 0)
    AddHistoryStr(HistStr, HistID)
end

//  allocate a StrList or clear an existing one and
//  copy contents of specified or current buffer into StrList

integer proc CopyBufferToList(integer ListID, integer BuffID)
    integer bid

    if ListID == SL_INV_ID
        ListID = AllocStrList()
    else
        ClearStrList(ListID)
    endif
    if BuffID <> 0
        bid = GotoBufferId(BuffID)
    endif
    if NumLines()
        BegFile()
        repeat
            AddToStrList(ListID, GetText(1, CurrLineLen()))
        until not Down()
    endif
    if BuffID <> 0
        GotoBufferId(bid)
    endif
    return(ListID)
end

//  empty the current or the specified buffer and
//  copy contents of StrList into the buffer

proc CopyListToBuffer(integer ListID, integer BuffID)
    integer I, N
    integer bid
    string line[255] = ""

    if BuffID <> 0
        bid = GotoBufferId(BuffID)
    endif
    EmptyBuffer()
    N = GetStrListSize(ListID)
    for I = 0 to N-1
        GetFromStrList(ListID, line, I)
        AddLine(line)
    endfor
    if BuffID <> 0
        GotoBufferId(bid)
    endif
end

/****************************************************************************\
    display library version
\****************************************************************************/

proc sWinDlgVer()
    integer ver
    string vs[64]

    ver = WinDlgVersion()
    vs = "Windows Dialogs " +
            Str((ver & 0xFF00) shr 16) + "." + Str(ver & 0x00FF) +
            Chr(13) + "Copyright (c) 2003-2005 by DiK"

    WinDlgMsgBox(TsePro, vs)
end

/****************************************************************************\
    display message boxes
\****************************************************************************/

proc sWinMsgBox()
    string CmdLine[255] = Query(MacroCmdLine)

    SetMCL(WinDlgMsgBox(GetToken(CmdLine, Chr(9), 1), GetToken(CmdLine, Chr(9), 2)))
end

proc sWinYesNoBox()
    string CmdLine[255] = Query(MacroCmdLine)

    SetMCL(WinDlgYesNoBox(GetToken(CmdLine, Chr(9), 1), GetToken(CmdLine, Chr(9), 2)))
end

/****************************************************************************\
    opening and saving files
\****************************************************************************/

/* TODO 1 -odik -cfeature : what about ignored dialog options?
-d/-r decomp / recomp
-c/-y dialogs / dialog resource
 */

/* TODO 1 -odik -cfeature : what about advanced options? do we need these anymore?
-n  names only (list vs. details)
-f  files only (no folders)
-o  sort order
 */

/* TODO 1 -odik -cfeature : what about -t switch "file must exist"?
currently hard coded into dll!
 */

proc sWinDlgOpen()
    integer RC, AsBinary
    integer I, N
    integer FilesID, TypesID
    integer hist = _EDIT_HISTORY_
    integer mode = OM_OPEN
    integer exec = TRUE
    string fn[255] = ""
    string dir[255] = ""
    string cmd[64] = Query(MacroCmdLine)

    // compute command line

    for I = 1 to NumTokens(cmd," ")
        case GetToken(cmd," ",i)
            when "-s"   mode = OM_SAVEAS
            when "-i"   mode = OM_INSERT
            when "-b"   mode = OM_SAVEBLOCK
            when "-e"   mode = OM_EXECMACRO     hist = _EXECMACRO_HISTORY_
            when "-l"   mode = OM_LOADMACRO     hist = _LOADMACRO_HISTORY_
            when "-k"   mode = OM_LOADKEY       hist = _KEYMACRO_HISTORY_
            when "-v"   mode = OM_SAVEKEY       hist = _KEYMACRO_HISTORY_
//            when "-d"   mode = OM_DECOMP        hist = _KEYMACRO_HISTORY_
//            when "-r"   mode = OM_RECOMP        hist = GetFreeHistory("ReComp:files")
//            when "-c"   mode = OM_DIALOG        hist = GetFreeHistory("DLG:txt")
//            when "-y"   mode = OM_RESOURCE      hist = GetFreeHistory("DLG:bin")
            when "-p"   mode = OM_LOADPROJ      hist = GetFreeHistory("UI:Sessions")
            when "-j"   mode = OM_SAVEPROJ      hist = GetFreeHistory("UI:Sessions")
            when "-x"   exec = FALSE
        endcase
    endfor

    // allocate dll buffers

    FilesID = AllocStrList()
    TypesID = AllocStrList()

    // set file types (and initial filename)

    case mode
        when OM_EXECMACRO, OM_LOADMACRO
            AddToStrList(TypesID, OF_MAC)
            AddToStrList(TypesID, OF_ANY)
        when OM_LOADKEY, OM_SAVEKEY
            AddToStrList(TypesID, OF_KBD)
            AddToStrList(TypesID, OF_ANY)
        when OM_LOADPROJ, OM_SAVEPROJ
            AddToStrList(TypesID, OF_TPR)
            AddToStrList(TypesID, OF_ANY)
        otherwise
            AddToStrList(FilesID, CurrFilename())
            AddToStrList(TypesID, OF_ANY)
            AddToStrList(TypesID, OF_TXT)
            AddToStrList(TypesID, OF_INP)
            AddToStrList(TypesID, OF_DOC)
            AddToStrList(TypesID, OF_SAL)
            AddToStrList(TypesID, OF_PAS)
            AddToStrList(TypesID, OF_C)
            AddToStrList(TypesID, OF_ASM)
            AddToStrList(TypesID, OF_FOR)
            AddToStrList(TypesID, OF_BAT)
    endcase

    // determine caption

    case mode
        when OM_OPEN        fn = "Open File"
        when OM_SAVEAS      fn = "Save File As"
        when OM_INSERT      fn = "Insert File"
        when OM_SAVEBLOCK   fn = "Save Block As File"
        when OM_EXECMACRO   fn = "Execute Macro"
        when OM_LOADMACRO   fn = "Load Macro"
        when OM_LOADKEY     fn = "Load Key Macros"
        when OM_SAVEKEY     fn = "Save Key Macros"
        when OM_LOADPROJ    fn = "Load Project"
        when OM_SAVEPROJ    fn = "Save Project"
    endcase

    // set directory

    dir = CurrDir()
    case mode
        when OM_EXECMACRO, OM_LOADMACRO
            if not FindThisFile("*.mac")
                ChDir(LoadDir() + "\mac")
            endif
        when OM_LOADKEY, OM_SAVEKEY
            if not FindThisFile("*.kbd")
                ChDir(LoadDir() + "\kbd")
            endif
    endcase

    // display dialog

    case mode
        when OM_OPEN
            RC = SetMCL(WinDlgOpenEx(FilesID, TypesID, fn, AsBinary))
        when OM_SAVEAS, OM_SAVEBLOCK, OM_SAVEKEY, OM_SAVEPROJ
            RC = SetMCL(WinDlgSaveAs(FilesID, TypesID, fn))
        otherwise
            RC = SetMCL(WinDlgOpen(FilesID, TypesID, fn))
    endcase

    // handle user input

    case RC
        when ID_OK
            N = GetStrListSize(FilesID)
            if N > 0
                GetFromStrList(FilesID, fn, 0)
                fn = QuotePath(fn)
                AddHistoryStr(fn, hist)

                if exec
                    case mode
                        when OM_OPEN
                            for I = 0 to N-1
                                GetFromStrList(FilesID, fn, I)
                                fn = QuotePath(fn)
                                AddHistoryStr(fn, _EDIT_HISTORY_)
                                if AsBinary
                                    EditFile("-b16 " + fn)
                                    DisplayMode(_DISPLAY_HEX_)
                                else
                                    EditFile(fn)
                                endif
                            endfor
                        when OM_SAVEAS
                            if ChangeCurrFilename(fn, _OVERWRITE_|_DONT_PROMPT_)
                                SaveFile()
                            endif
                        when OM_INSERT      InsertFile(fn)
                        when OM_SAVEBLOCK   SaveBlock(fn)
                        when OM_EXECMACRO   ExecMacro(fn)
                        when OM_LOADMACRO   LoadMacro(fn)
                        when OM_LOADKEY     LoadKeyMacro(fn)
                        when OM_SAVEKEY     SaveKeyMacro(fn)
                    endcase
                endif
            endif
        when ID_CANCEL
            // cancelled
        when ID_HELP
/* TODO 1 -odik -cfeature : include help button? various open modes? */
        otherwise
            Warn("error running WinDlg: RC = ", RC)
    endcase

    // cleanup

    if ChDir(dir)
        LogDrive(dir[1])
    endif
    FreeStrList(FilesID)
    FreeStrList(TypesID)
end

/****************************************************************************\
    buffer list
\****************************************************************************/

proc sWinDlgBuffers()
    integer curr, blst
    integer RC, ID
    string file[255] = ""

    // setup working buffer

    curr = GetBufferId()
    if not CreateWorkingBuffer(blst)
        return()
    endif
    ID = SL_INV_ID

    // scan loaded files and setup strlist

rescan:
    EmptyBuffer(blst)
    do NumFiles() + (BufferType() <> _NORMAL_) times
        AddLine(Format(iif(FileChanged(), "* ", "  "), CurrFilename()), blst)
        NextFile(_DONT_LOAD_)
    enddo
    ID = CopyBufferToList(ID, blst)

    // display dialog

redisplay:
    RC = SetMCL(WinDlgBuffers(ID, file))
    file = QuotePath(DelStr(file,1,2))

    // handle user input

    case RC
        when ID_OK
            if file <> ""
                EditFile(file)
            endif
        when ID_CANCEL
            // cancelled
        when ID_LIST
            sWinDlgRecent()
        when ID_OPEN
            sWinDlgOpen()
        when ID_SAVE
            EditFile(file)
            SaveFile()
            GotoBufferId(curr)
            UpdateDisplay()
            goto rescan
        when ID_REMOVE
            EditFile(file)
            QuitFile()
            GotoBufferId(curr)
            UpdateDisplay()
            goto rescan
        when ID_HELP
            Help("Moving Between Files in the Ring")
            goto redisplay
        otherwise
            Warn("error running WinDlg: RC = ", RC)
    endcase

    // cleanup

    AbandonFile(blst)
    FreeStrList(ID)
end

/****************************************************************************\
    recent files list
\****************************************************************************/


proc sWinDlgRecent()
    integer curr, rcnt
    integer RC, ID
    string file[255] = ""

    // the following code determines the id of the recent files buffer
    // this is easy once the buffer exists, because we know its name
    // otherwise we trick the editor by loading and cleaning up a temp file

    rcnt = GetBufferId(RFLBID)
    if rcnt == 0 and EditFile("...!@!@!@!@!...")
        UpdateDisplay()
        AbandonFile()
        SetWindowTitle(TSEPro)
        lShowEntryScreen()
        SignOn()
        rcnt = GetBufferId(RFLBID)
        if rcnt
            curr = GotoBufferId(rcnt)
            BegFile()
            KillLine()
            GotoBufferId(curr)
        endif
    endif

    // setup list of recent files

    if rcnt
        ID = CopyBufferToList(SL_INV_ID, rcnt)
    else
        WinDlgMsgBox(TsePro, "List of recent files not found")
        return()
    endif

    // display dialog and retrieve changed list of recent files

redisplay:
    RC = SetMCL(WinDlgRecent(ID, file))
    CopyListToBuffer(ID, rcnt)

    // handle user input

    case RC
        when ID_OK
            if file <> ""
                EditFile(QuotePath(file))
            endif
        when ID_CANCEL
            // cancelled
        when ID_LIST
            sWinDlgBuffers()
        when ID_OPEN
            sWinDlgOpen()
        when ID_HELP
            Help("Moving Between Files in the Ring")
            goto redisplay
        otherwise
            Warn("error running WinDlg: RC = ", RC)
    endcase

    // cleanup

    FreeStrList(ID)
end

/****************************************************************************\
    picking a folder
\****************************************************************************/

helpdef DlgPickFolderHelp
    title = "Help on Browse Folder Dialog"
    width = 58
    height = 17
    x = 2
    y = 3

    ""
    " This dialog is used to browse for a folder."
    ""
    " Summary of commands:"
    ""
    " Ok          go to the selected folder"
    " Cancel      abort the dialog box"
    " Startup     return to the initially selected folder"
    " Current     go to the current folder"
    " Recent      display a list of recently used folders"
    ""
    " Right clicking the folders treeview pops up the"
    " shell's context menu for folders."
    ""
    " The initially selected folder is the folder which"
    " contains the currently edited file."
    ""
end

/****************************************************************************/

integer proc RecentFoldersList(integer recent)
    integer I, ID
    integer curr, buffer
    string name[255]

    // setup working buffer

    curr = GetBufferId()
    if not CreateWorkingBuffer(buffer)
        return(SL_INV_ID)
    endif
    PushBlock()

    // get list of recent files

    if recent
        GotoBufferId(recent)
        MarkLine(1,NumLines())
        GotoBufferId(buffer)
        CopyBlock()
        UnmarkBlock()
        EndFile()
    endif

    // add editfile history

    for I=1 to NumHistoryItems(_EDIT_HISTORY_)
        AddLine(GetHistoryStr(_EDIT_HISTORY_, I))
    endfor

    // remove filenames and invalid entries

    BegFile()
    loop
        name = GetText(1,CurrLineLen())
        name = SplitPath(name,_DRIVE_|_PATH_)
        if Length(name) and FileExists(name)
            BegLine()
            KillToEol()
            InsertText(name)
            if not Down()
                break
            endif
        else
            KillLine()
            if CurrLine() > NumLines()
                break
            endif
        endif
    endloop

    // sort list and remove duplicate entries

    MarkColumn(1, 1, NumLines(), 80)
    Sort(_IGNORE_CASE_)
    UnmarkBlock()
    BegFile()
    loop
        name = Lower(GetText(1,CurrLineLen()))
        if not Down()
            break
        endif
        while name == Lower(GetText(1,CurrLineLen()))
            KillLine()
        endwhile
    endloop

    // copy list into strlist

    ID = CopyBufferToList(SL_INV_ID, 0)

    // cleanup (dispose working buffer)

    AbandonFile(buffer)
    GotoBufferId(curr)
    PopBlock()
    return(ID)
end

/****************************************************************************/

proc sWinDlgPickFolder()
    integer RC, I
    integer HistID
    integer recent = 0
    integer change = FALSE
    string folder[255] = ""
    string arg[64], cmd[64] = Query(MacroCmdLine)

    // compute macro command line

    for I = 1 to NumTokens(cmd, " ")
        arg = GetToken(cmd, " ", I)
        case arg
            when "-c"   folder = SplitPath(CurrFilename(), _DRIVE_|_PATH_)
            when "-g"   change = TRUE
        endcase
    endfor

    // setup list of recent folder and initialize startup folder

    recent = GetBufferId(RFLBID)
    if recent
        HistId = RecentFoldersList(recent)
    else
        HistId = SL_INV_ID
    endif
    if not FileExists(folder)
        folder = CurrDir()
    endif

    // display dialog

redisplay:
    UpdateDisplay()
    RC = SetMCL(WinDlgPickFolder(folder, HistID))

    // handle user input

    case RC
        when ID_OK
            if change
                if ChDir(folder)
                    LogDrive(folder[1])
                endif
            endif
            SetGlobalStr(DlgMsgText, folder)
        when ID_CANCEL
            // cancelled
        when ID_HELP
            QuickHelp(DlgPickFolderHelp)
            goto redisplay
        otherwise
            Warn("error running WinDlg: RC = ", RC)
    endcase

    // cleanup

    FreeStrList(HistID)
end

/****************************************************************************\
    fill block
\****************************************************************************/

proc sWinDlgFill()
    integer RC
    integer FillID
    string FillStr[255] = "Fill block with:"

    FillID = CopyHistoryToList(SL_INV_ID, _FILLBLOCK_HISTORY_)

redisplay:
    RC = SetMCL(WinDlgInpBoxEx(TsePro, FillStr, FillID))
    case RC
        when ID_OK
            GetTopHistoryString(FillStr, FillID, _FILLBLOCK_HISTORY_)
            FillBlock(FillStr)
        when ID_CANCEL
            // cancelled
        when ID_HELP
            Help('Marking and Manipulating a Block of Text;FillBlock')
            goto redisplay
        otherwise
            Warn("error running WinDlg: RC = ", RC)
    endcase

    FreeStrList(FillID)
end

/****************************************************************************\
    find
\****************************************************************************/

proc sWinDlgFind()
    integer RC
    integer FindID, OptsID
    string FindStr[255] = "", OptsStr[255] = ""

    if Query(MacroCmdLine) == '-v'
        OptsStr = GetHistoryStr(_FIND_OPTIONS_HISTORY_, 1)
        if Pos("v", Lower(OptsStr)) == 0
            OptsStr = OptsStr + "v"
        endif
        AddHistoryStr(OptsStr, _FIND_OPTIONS_HISTORY_)
    endif

    FindID = CopyHistoryToList(SL_INV_ID, _FIND_HISTORY_)
    OptsID = CopyHistoryToList(SL_INV_ID, _FIND_OPTIONS_HISTORY_)
    CopyWordToList(FindID)

redisplay:
    RC = SetMCL(WinDlgFind(FindID, OptsID))
    case RC
        when ID_OK
            GetTopHistoryString(FindStr, FindID, _FIND_HISTORY_)
            GetTopHistoryString(OptsStr, OptsID, _FIND_OPTIONS_HISTORY_)
            Find(FindStr, OptsStr)
        when ID_CANCEL
            // cancelled
        when ID_HELP
            Help("prompt->Search for:")
            goto redisplay
        otherwise
            Warn("error running WinDlg: RC = ", RC)
    endcase

    FreeStrList(FindID)
    FreeStrList(OptsID)
end

/****************************************************************************\
    replace
\****************************************************************************/

proc sWinDlgReplace()
    integer RC
    integer FindID, RplcID, OptsID
    string FindStr[255] = "", RplcStr[255] = "", OptsStr[255] = ""

    FindID = CopyHistoryToList(SL_INV_ID, _FIND_HISTORY_)
    RplcID = CopyHistoryToList(SL_INV_ID, _REPLACE_HISTORY_)
    OptsID = CopyHistoryToList(SL_INV_ID, _REPLACE_OPTIONS_HISTORY_)
    CopyWordToList(FindID)

redisplay:
    RC = SetMCL(WinDlgReplace(FindID, RplcID, OptsID))
    case RC
        when ID_OK
            GetTopHistoryString(FindStr, FindID, _FIND_HISTORY_)
            GetTopHistoryString(RplcStr, RplcID, _REPLACE_HISTORY_)
            GetTopHistoryString(OptsStr, OptsID, _REPLACE_OPTIONS_HISTORY_)
            Replace(FindStr, RplcStr, OptsStr)
        when ID_CANCEL
            // cancelled
        when ID_HELP
            Help("prompt->Replace with:")
            goto redisplay
        otherwise
            Warn("error running WinDlg: RC = ", RC)
    endcase

    FreeStrList(FindID)
    FreeStrList(RplcID)
    FreeStrList(OptsID)
end

/****************************************************************************\
    find&do

    this is not a standalone command
    this is only a data input device for the find&do macro

    action codes are defined in find&do macro
\****************************************************************************/

proc sWinDlgFindAndDo()
    integer RC, Action = 4
    integer FindID, OptsID, MacsID
    string FindStr[255] = "", OptsStr[255] = ""

    FindID = CopyHistoryToList(SL_INV_ID, _FIND_HISTORY_)
    OptsID = CopyHistoryToList(SL_INV_ID, _FIND_OPTIONS_HISTORY_)
    MacsID = CopyHistoryToList(SL_INV_ID, _EXECMACRO_HISTORY_)
    CopyWordToList(FindID)

redisplay:
    RC = SetMCL(WinDlgFindAndDo(FindID, OptsID, MacsID, Action))
    case RC
        when ID_OK
            GetTopHistoryString(FindStr, FindID, _FIND_HISTORY_)
            GetTopHistoryString(OptsStr, OptsID, _FIND_OPTIONS_HISTORY_)

            ExecMacro("find&do1 " + Str(Action))
            RC = Val(Query(MacroCmdLine))
            UpdateDisplay()
            WinDlgMsgBox("Find And Do", Str(RC) + " occurrence(s) found")
        when ID_CANCEL
            // cancelled
        when ID_HELP
            Help("Other Special-Purpose Search Features")
            goto redisplay
        when ID_OPEN
            ExecMacro("DlgOpen -e -x")
            CopyHistoryToList(MacsID, _EXECMACRO_HISTORY_)
            goto redisplay
        otherwise
            Warn("error running WinDlg: RC = ", RC)
    endcase

    FreeStrList(FindID)
    FreeStrList(OptsID)
    FreeStrList(MacsID)
end

/****************************************************************************\
    grep

    this is not a standalone grep-command
    this is only a data input device for the grep macro
\****************************************************************************/

proc sWinDlgGrep()
    integer RC, OnDisk
    integer ExprID, FileID, ExclID, PathID, OptsID
    integer ExprHS, FileHS, ExclHS, PathHS, OptsHS
    string Expr[255] = ""

    ExprHS = GetFreeHistory("DlgGrep:Expression")
    FileHS = GetFreeHistory("DlgGrep:Filename")
    ExclHS = GetFreeHistory("DlgGrep:Exclude")
    PathHS = GetFreeHistory("DlgGrep:Pathname")
    OptsHS = GetFreeHistory("DlgGrep:Options")

    ExprID = CopyHistoryToList(SL_INV_ID, ExprHS)
    FileID = CopyHistoryToList(SL_INV_ID, FileHS)
    ExclID = CopyHistoryToList(SL_INV_ID, ExclHS)
    PathID = CopyHistoryToList(SL_INV_ID, PathHS)
    OptsID = CopyHistoryToList(SL_INV_ID, OptsHS)

    CopyWordToList(ExprID)
    OnDisk = Lower(Query(MacroCmdLine)) == "disk"

redisplay:
    RC = SetMCL(WinDlgGrep(ExprID, FileID, ExclID, PathID, OptsID, OnDisk))
    case RC
        when ID_OK
            GetTopHistoryString(Expr, ExprID, ExprHS)
            GetTopHistoryString(Expr, FileID, FileHS)
            GetTopHistoryString(Expr, ExclID, ExclHS)
            GetTopHistoryString(Expr, PathID, PathHS)
            GetTopHistoryString(Expr, OptsID, OptsHS)
        when ID_CANCEL
            // cancelled
        when ID_HELPEX
            Help("Summary List of Regular Expression Operators")
            goto redisplay
        when ID_HELP
            Help("Executing Supplemental Macros from the Potpourri;Grep")
            goto redisplay
        otherwise
            Warn("error running WinDlg: RC = ", RC)
    endcase

    FreeStrList(ExprID)
    FreeStrList(FileID)
    FreeStrList(ExclID)
    FreeStrList(PathID)
    FreeStrList(OptsID)
end

/****************************************************************************\
    goto
\****************************************************************************/

/* TODO 1 -odik -cfeature : cannot use +/- offset notation */

proc sWinDlgGoto()
    integer RC
    integer LineID, ColID
    string LineStr[255] = "", ColStr[255] = ""

    LineID = CopyHistoryToList(SL_INV_ID, _GOTOLINE_HISTORY_)
    ColID = CopyHistoryToList(SL_INV_ID, _GOTOCOLUMN_HISTORY_)

    InsertIntoStrList(LineID, Str(CurrLine()), 0)
    InsertIntoStrList(ColID, Str(CurrCol()), 0)

redisplay:
    RC = SetMCL(WinDlgGoto(LineID, ColID))
    case RC
        when ID_OK
            GetTopHistoryString(LineStr, LineID, _GOTOLINE_HISTORY_)
            GetTopHistoryString(ColStr, ColID, _GOTOCOLUMN_HISTORY_)
            GotoLine(Val(LineStr))
            GotoColumn(Val(ColStr))
        when ID_CANCEL
            // cancelled
        when ID_HELP
            Help("prompt->Go to column:")
            goto redisplay
        otherwise
            Warn("error running WinDlg: RC = ", RC)
    endcase

    FreeStrList(LineID)
    FreeStrList(ColID)
end

/****************************************************************************\
    bookmark list
\****************************************************************************/

integer proc EnumerateBookMarks(integer blst)
    string tab[1] = Chr(9)
    integer i, cid
    integer id, line, xpos, xoffset, row
    string buff_name[255], curr_line[255]

    cid = GotoBufferId(blst)
    EmptyBuffer()
    for i = Asc("a") to Asc("z")
        if GetBookMarkInfo(Chr(i), id, line, xpos, xoffset, row)
            AddLine(Chr(i))
            EndLine()
            InsertText(tab)
            InsertText(Str(line))
            InsertText(tab)
            InsertText(Str(xpos))
            InsertText(tab)
            if GotoBufferId(id)
                PushPosition()
                GotoLine(line)
                GotoPos(1)
                buff_name = SplitPath(CurrFilename(), _NAME_|_EXT_)
                curr_line = GetText(1,255)
                PopPosition()
            else
                buff_name = ""
                curr_line = ""
            endif
            GotoBufferId(blst)
            InsertText(SplitPath(buff_name, _NAME_|_EXT_))
            InsertText(tab)
            InsertText(curr_line)
        endif
    endfor
    i = NumLines()
    GotoBufferId(cid)
    return(i)
end

/****************************************************************************/

proc sWinDlgBookmark()
    integer BookmarkSortCol = 0
    integer I, RC, ID, blst
    string Selected[64] = ""

    if not CreateWorkingBuffer(blst)
        return()
    endif
    ID = SL_INV_ID

redisplay:
    if EnumerateBookMarks(blst) == 0
        WinDlgMsgBox("Error", "No bookmarks found!")
        goto finally
    endif
    ID = CopyBufferToList(ID, blst)

    RC = SetMCL(WinDlgBookmarks(ID, Selected, BookmarkSortCol))
    case RC
        when ID_OK
            GotoMark(Selected[1])
        when ID_REMOVE
            for I = 1 to Length(Selected)
                DelBookmark(Selected[I])
            endfor
            goto redisplay
        when ID_REMOVE_ALL
            DelAllBookmarks()
        when ID_CANCEL
            // cancelled
        when ID_HELP
            Help("Bookmarks")
            goto redisplay
        otherwise
            Warn("error running WinDlg: RC = ", RC)
    endcase

finally:
    FreeStrList(ID)
    AbandonFile(blst)
end

/****************************************************************************\
    macro control center

    This macro uses internal, undocumented data structures of TSE.
    E.g., it works with versions 4.x of TSE, but
    there is absolutely no guarantee that it will also work with
    any future version of the editor.
\****************************************************************************/

helpdef DlgMCCHelp
    title = "Help on Macro Control Center"
    width = 70
    x = 2
    y = 3

    ""
    "   This dialog allows you to execute all SAL macro related tasks"
    "   from one central place."
    ""
    "   Summary of commands:"
    ""
    "   Exec        execute the specified macro"
    "   Cancel      close the dialog"
    "   Search      search and execute a macro"
    "   Load        load a macro (<ins>)"
    "   Purge       purge the specified macro (<del>)"
    ""
    "   Executing macros:"
    ""
    "   To immediately execute a macro after the dialog has popped up,"
    "   just enter its name and press <Enter>. Alternatively, you can "
    "   tab to the list of loaded macros and select one of them to be"
    "   executed. Finally, you can push the Search button to pop up the"
    "   Execute Macro dialog and search your disk for macros to be"
    "   executed."
    ""
    "   Loading and purging macros:"
    ""
    "   To load a macro without immediately executing it push the Load"
    "   button. This will pop up the Load Macro dialog, which allows"
    "   you to search your disk for macros to be loaded. To purge a"
    "   macro you do not need any longer, mark it within the list of"
    "   loaded macros and push the Purge button."
    ""
end

/****************************************************************************/

proc RemoveEntryFromList(string mac)
    if lFind(mac, "gi^$")
        MarkLine()
        if lFind("^[~ ]","x+")
            Up()
        else
            EndFile()
        endif
        KillBlock()
    endif
end

/****************************************************************************/

proc MakeMacroList(integer MacroList)
    constant TSEMacroList = 4
    constant SIZE_POS     = 12
    constant START_COL    = 13
    integer bid

    // fetch TSE's internal list of loaded macros

    PushBlock()

    bid = GotoBufferId(TSEMacroList)
    MarkLine(1, NumLines())
    GotoBufferId(MacroList)
    EmptyBuffer()
    CopyBlock()
    UnmarkBlock()

    // format macro list

    BegFile()
    repeat
        if CurrChar(3)
            GotoPos(START_COL+CurrChar(SIZE_POS))
            KillToEol()
        else
            GotoPos(START_COL)
            InsertText("    ",_INSERT_)
        endif
    until not Down()
    MarkColumn(1,1,NumLines(),START_COL-1)
    KillBlock()

    // remove some macros

    RemoveEntryFromList(".ui")
    RemoveEntryFromList("dialog")
    RemoveEntryFromList("dialogp")
    RemoveEntryFromList("windlgs")
    BegFile()

    // clean up (return to user file)

    GotoBufferId(bid)
    PopBlock()
end

/****************************************************************************/

proc sWinDlgMCC()
    string MacName[255] = ""
    integer RC
    integer MacroList
    integer ListID, HistID

    if not CreateWorkingBuffer(MacroList)
        return()
    endif
    ListID = AllocStrList()
    HistID = CopyHistoryToList(SL_INV_ID, _EXECMACRO_HISTORY_)

rescan:
    MakeMacroList(MacroList)
    CopyBufferToList(ListID, MacroList)

    RC = SetMCL(WinDlgMCC(ListID, HistID))
    GetTopHistoryString(MacName, HistID, _EXECMACRO_HISTORY_)
    case RC
        when ID_OK
            ExecMacro(MacName)
        when ID_CANCEL
            // cancelled
        when ID_OPEN
            ExecMacro("DlgOpen -e")
        when ID_LOAD
            ExecMacro("DlgOpen -l")
            goto rescan
        when ID_REMOVE
            PurgeMacro(MacName)
            goto rescan
        when ID_HELP
            QuickHelp(DlgMCCHelp)
            goto rescan
        otherwise
            Warn("error running WinDlg: RC = ", RC)
    endcase

    AbandonFile(MacroList)
    FreeStrList(ListID)
    FreeStrList(HistID)
end

/****************************************************************************\
    ascii chart
\****************************************************************************/

proc sWinDlgAsciiChart()
    integer handle

    handle = ShellExecute(GetWinHandle(), "open", "charmap", "", "", SW_SHOW)
    if handle <= 32
        MsgBox("", "Character-Map not found", 0)
    endif
end

/****************************************************************************\
    OS commands
\****************************************************************************/

proc Capture(string cmd)
    integer msglevel
    string fn[_MAXPATH_]

    fn = QuotePath(MakeTempName("", ".tmp"))
    Dos(Format(cmd, ">", fn), _DONT_PROMPT_|_TEE_OUTPUT_)
    if EditFile(fn)
        msglevel = Set(MsgLevel, _WARNINGS_ONLY_)
        KillFile()
        Set(MsgLevel, msglevel)
        FileChanged(FALSE)
    endif
end


/****************************************************************************/

proc sWinDlgDos()
    integer RC, cap
    integer CmdID
    string CmdStr[255]

    CmdID = CopyHistoryToList(SL_INV_ID, _DOS_HISTORY_)

    cap = Lower(Query(MacroCmdLine)) == "-c"
    if cap
        CmdStr = "Capture OS command:"
    else
        CmdStr = "OS command:"
    endif

redisplay:
    RC = SetMCL(WinDlgInpBox(TsePro, CmdStr, CmdID))
    case RC
        when ID_OK
            GetTopHistoryString(CmdStr, CmdID, _DOS_HISTORY_)
            if cap
                Capture(CmdStr)
            else
                Dos(CmdStr)
            endif
        when ID_CANCEL
            // cancelled
        when ID_HELP
            Help("Executing External Commands from Within the Editor")
            goto redisplay
        otherwise
            Warn("error running WinDlg: RC = ", RC)
    endcase

    FreeStrList(CmdID)
end

/****************************************************************************\
    options dialog

    the sequence of the options put into the string list must not be changed
\****************************************************************************/

integer proc Succ(var integer I)
    I = I + 1
    return (I)
end

//#include "dikopts.si"

proc mQueryTemplate()
    string TEMPLATE[16] = "template"

    if Query(TemplateExpansion)
        if not isMacroLoaded(TEMPLATE)
            LoadMacro(TEMPLATE)
        endif
    else
        if isMacroLoaded(TEMPLATE)
            PurgeMacro(TEMPLATE)
        endif
    endif
end

/****************************************************************************/

proc sWinDlgOpts()
    integer DikOpts = 0
    integer RC, I
    integer OptsID
    string buffer[255] = "0"

    OptsID = AllocStrList()

    AddToStrList(OptsID, Str(Query(ExpandTabs)))
    AddToStrList(OptsID, Str(Query(TabWidth)))
    AddToStrList(OptsID, Str(Query(TabType)))
    AddToStrList(OptsID, Query(VarTabs))
    AddToStrList(OptsID, Str(Query(EOLType)))
    AddToStrList(OptsID, Str(Query(EOFType)))
#ifdef DEFDIKOPTS
    DikOpts = 1
    AddDikOptions(OptsID)
#else
    AddToStrList(OptsID, "0")
    AddToStrList(OptsID, "0")
    AddToStrList(OptsID, "0")
#endif
    AddToStrList(OptsID, Str(Query(AutoIndent)))
    AddToStrList(OptsID, Str(Query(TemplateExpansion)))
    AddToStrList(OptsID, Str(Query(WordWrap)))
    AddToStrList(OptsID, Str(Query(LeftMargin)))
    AddToStrList(OptsID, Str(Query(RightMargin)))

redisplay:
    RC = SetMCL(WinDlgOpts(OptsID, DikOpts, OptionsPageIndex))
    case RC
        when ID_OK
            I = -1
            GetFromStrList(OptsID, buffer, Succ(I))  Set(ExpandTabs, Val(buffer))
            GetFromStrList(OptsID, buffer, Succ(I))  Set(TabWidth, Val(buffer))
            GetFromStrList(OptsID, buffer, Succ(I))  Set(TabType, Val(buffer))
            GetFromStrList(OptsID, buffer, Succ(I))  Set(VarTabs, buffer)
            GetFromStrList(OptsID, buffer, Succ(I))  Set(EOLType, Val(buffer))
            GetFromStrList(OptsID, buffer, Succ(I))  Set(EOFType, Val(buffer))
#ifdef DEFDIKOPTS
            GetDikOptions(OptsID, I)
#endif
            GetFromStrList(OptsID, buffer, Succ(I))  Set(AutoIndent, Val(buffer))
            GetFromStrList(OptsID, buffer, Succ(I))  Set(TemplateExpansion, Val(buffer))
            GetFromStrList(OptsID, buffer, Succ(I))  Set(WordWrap, Val(buffer))
            GetFromStrList(OptsID, buffer, Succ(I))  Set(LeftMargin, Val(buffer))
            GetFromStrList(OptsID, buffer, Succ(I))  Set(RightMargin, Val(buffer))
            mQueryTemplate()
        when ID_CANCEL
            // cancelled
        when ID_HELP
            Help("Configuration Options Available Interactively")
            goto redisplay
        otherwise
            Warn("error running WinDlg: RC = ", RC)
    endcase

    FreeStrList(OptsID)
end

/****************************************************************************\
    history list maintenance

    This macro uses internal, undocumented data structures of TSE.
    E.g., it works with versions 4.x of TSE, but
    there is absolutely no guarantee that it will also work with
    any future version of the editor.
\****************************************************************************/

/* TODO 5 -odik -cstructure : this section is much longer than most of the other dialog handlers!
should we exptract it and make an external macro? */

constant HISTORY = 6
string orphan[] = "[*** orphaned history id ***]"
string magic_header[] = "®TSE History¯"

/****************************************************************************/

helpdef DlgHistHelp
    title = "Help on History Maintenance"
    width = 70
    height = 21
    x = 2
    y = 3

    ""
    "   This dialog displays all history lists, which are not empty."
    "   The leftmost column shows the name of the history list. User"
    "   defined items are enclosed in brackets. The id and item count"
    "   columns display the numerical identifier of the history list"
    "   and the number of items each list contains, respectively."
    ""
    "   User items are defined by SAL macros. They usually are in the"
    '   form "macro_name:history_name".'
    ""
    '   If the list includes "orphaned history id" entries, press the'
    "   User History button to repair the history list. These entries"
    "   are not harmful in any way, but waste memory."
    ""
    "   Summary of commands:"
    ""
    "   List            list contents of current history"
    "   Close           close the dialog box"
    "   Delete          empty current history (<Del>)"
    "   User History    maintain user history lists"
    ""
end

helpdef DlgHistItemHelp
    title = "Help on Contents of History List"
    width = 70
    height = 9
    x = 2
    y = 3

    ""
    "   This dialog displays the items within the current history list."
    ""
    "   Summary of commands:"
    ""
    "   Close           close dialog box"
    "   Delete          delete current history entry (<Del>)"
    "   Delete All      delete all history entries"
    ""
end

helpdef DlgListUserHelp
    title = "Help on User History Maintenance"
    width = 70
    height = 16
    x = 2
    y = 3

    ""
    "   This dialog displays the available user histories as stored"
    "   within the internal history list. This includes empty and"
    "   orphaned history lists. Orphaned history id's are generated"
    "   when you remove entire history lists using DlgHist, since TSE"
    "   does not re-use freed history id's. You can use the compress"
    "   command to clear all orphaned lists and consecutively renumber"
    "   the remaining lists."
    ""
    "   Summary of commands:"
    ""
    "   Save        save changes (terminates the dialog)"
    "   Cancel      abort all changes"
    "   Delete      remove entire history list (<Del>)"
    "   Compress    remove orphaned history id's and renumber"
    ""
end

/****************************************************************************/

proc FormatAndAddHistItem(string name, integer id, integer add_empty)
    string tab[1] = Chr(9)
    integer count

    count = NumHistoryItems(id)
    if add_empty or (count > 0)
        InsertLine(name)
        EndLine()
        InsertText(tab)
        InsertText(Str(id))
        InsertText(tab)
        if count == 0
            InsertText("-")
        else
            InsertText(Str(count))
        endif
    endif
end

/****************************************************************************/

string proc GetHistIdName(integer id)
    integer bid
    integer user_count
    string hist[128]

    case id
        when _EDIT_HISTORY_             return("Edit")
        when _NEWNAME_HISTORY_          return("NewName")
        when _EXECMACRO_HISTORY_        return("ExecMacro")
        when _LOADMACRO_HISTORY_        return("LoadMacro")
        when _KEYMACRO_HISTORY_         return("KeyMacro")
        when _GOTOLINE_HISTORY_         return("GotoLine")
        when _GOTOCOLUMN_HISTORY_       return("GotoColumn")
        when _REPEATCMD_HISTORY_        return("RepeatCmd")
        when _DOS_HISTORY_              return("Dos")
        when _FINDOPTIONS_HISTORY_      return("FindOptions")
        when _REPLACEOPTIONS_HISTORY_   return("ReplaceOptions")
        when _FIND_HISTORY_             return("Find")
        when _REPLACE_HISTORY_          return("Replace")
        when _FILLBLOCK_HISTORY_        return("FillBlock")
        when 184                        return("[HelpSearch]")
    endcase

    hist = Format("#",id,"#")

    bid = GotoBufferId(HISTORY)
    PushPosition()
    GotoLine(2)
    user_count = CurrChar(1) + 1
    if lFind(Chr(id),"g^")
        if CurrLine() <= user_count
            hist = "[" + GetText(2,CurrLineLen()-1) + "]"
        elseif id < 128
            hist = orphan
        endif
    endif
    PopPosition()
    GotoBufferId(bid)

    return (hist)
end

proc ScanHistData(integer buff)
    integer bid, ID

    bid = GotoBufferId(buff)
    EmptyBuffer()
    for ID = 255 downto 1
        FormatAndAddHistItem(GetHistIdName(ID), ID, FALSE)
    endfor
    GotoBufferId(bid)
end

proc RemoveHistData(integer ID)
    integer I

    for I = NumHistoryItems(ID) downto 1
        DelHistoryStr(ID ,I)
    endfor
end

/****************************************************************************/

integer proc CopyUserList()
    integer bid

    GotoBufferId(HISTORY)
    MarkLine(1,NumLines())
    if CreateWorkingBuffer(bid)
        GotoBufferId(bid)
        CopyBlock()
        UnmarkBlock()
    endif
    return (bid)
end

proc MakeUserList(integer buff)
    string name[127]
    integer bid, temp
    integer ID, user_count

    // prepare working buffers
    bid = GotoBufferId(buff)
    EmptyBuffer(buff)
    temp = CopyUserList()
    if temp == 0
        goto finally
    endif
    GotoLine(2)
    user_count = CurrChar(1)

    // scan unnamed user entries
    for ID = 127 downto user_count +1
        FormatAndAddHistItem(orphan, ID, FALSE)
    endfor

    // scan named user entries
    for ID = user_count downto 1
        GotoBufferId(temp)
        if ID == CurrChar(1) and lFind(":","gc")
            name = GetText(2,CurrLineLen()-1)
            Down()
        else
            name = orphan
        endif
        GotoBufferId(buff)
        FormatAndAddHistItem(name, ID, TRUE)
    endfor

finally:
    AbandonFile(temp)
    GotoBufferId(bid)
end

proc CompressHistory(integer ID)
    string S[8] = ""
    integer I, N
    integer bid, temp
    integer NewHist, OldHist, Count

    // get history list from editor
    N = GetStrListSize(ID) - 1
    bid = GetBufferId()
    temp = CopyUserList()
    if temp == 0
        goto finally
    endif

    // remove deleted entries
    for I = 0 to N
        GetFromStrList(ID, S, I)
        if S == ""
            OldHist = I + 1
            while lFind(Chr(OldHist),"g^")
                KillLine()
            endwhile
        endif
    endfor

    // re-index remaining entries
    Count = 0
    MarkColumn(1,1,NumLines(),1)
    for I = 0 to N
        GetFromStrList(ID, S, I)
        if S <> ""
            Count = Count + 1
            OldHist = I + 1
            NewHist = Val(S)
            lReplace(Chr(OldHist),Chr(NewHist),"lgn")
        endif
    endfor

    // save and re-load new history list
    BegFile()
    InsertText(Chr(Count) + magic_header)
    BinaryMode(-2)
    SaveAs(LoadDir()+"tsehist.dat", _OVERWRITE_|_DONT_PROMPT_)
    LoadHistory()

finally:
    AbandonFile(temp)
    GotoBufferId(bid)
end

/****************************************************************************/

proc ListUserHistories()
    integer HistList
    integer HistID
    integer RC, Selected

    if not CreateWorkingBuffer(HistList)
        return()
    endif
    HistID = SL_INV_ID

redisplay:
    MakeUserList(HistList)
    HistID = CopyBufferToList(HistID, HistList)

    RC = SetMCL(WinDlgHistUser(HistID, Selected))
    case RC
        when ID_OK
            CompressHistory(HistID)
        when ID_CANCEL
            // cancelled
        when ID_HELP
            QuickHelp(DlgListUserHelp)
            goto redisplay
        otherwise
            Warn("error running WinDlg: RC = ", RC)
    endcase

    FreeStrList(HistID)
    AbandonFile(HistList)
end

/****************************************************************************/

proc ListHistory(integer ID)
    integer HistList
    integer HistID
    integer I, bid
    integer RC, Selected

    if not CreateWorkingBuffer(HistList)
        return()
    endif
    HistID = SL_INV_ID

redisplay:
    bid = GotoBufferId(HistList)
    EmptyBuffer()
    for I = 1 to NumHistoryItems(ID)
        AddLine(GetHistoryStr(ID, I))
    endfor
    GotoBufferId(bid)
    HistID = CopyBufferToList(HistID, HistList)

    RC = SetMCL(WinDlgHistStrings(HistID, GetHistIdName(ID), Selected))
    case RC
        when ID_CANCEL
            // cancelled (no ID_OK)
        when ID_REMOVE
            DelHistoryStr(ID, Selected)
            goto redisplay
        when ID_REMOVE_ALL
            RemoveHistData(ID)
        when ID_HELP
            QuickHelp(DlgHistItemHelp)
            goto redisplay
        otherwise
            Warn("error running WinDlg: RC = ", RC)
    endcase

    FreeStrList(HistID)
    AbandonFile(HistList)
end

/****************************************************************************/

proc sWinDlgHistories()
    integer HistList
    integer HistID
    integer RC, Selected

    if not CreateWorkingBuffer(HistList)
        return()
    endif
    HistID = SL_INV_ID

redisplay:
    ScanHistData(HistList)
    HistID = CopyBufferToList(HistID, HistList)

    RC = SetMCL(WinDlgHistories(HistID, Selected))
    case RC
        when ID_OK
            ListHistory(Selected)
            goto redisplay
        when ID_CANCEL
            // cancelled
        when ID_REMOVE
            RemoveHistData(Selected)
            goto redisplay
        when ID_LIST
            ListUserHistories()
            goto redisplay
        when ID_HELP
            QuickHelp(DlgHistHelp)
            goto redisplay
        otherwise
            Warn("error running WinDlg: RC = ", RC)
    endcase

    FreeStrList(HistID)
    AbandonFile(HistList)
end

/****************************************************************************\
    add a new todo item

    this is not a standalone command
    this is only an input device for the todo macro
\****************************************************************************/

proc sWinDlgAddTodo()
    string args[64] = Query(MacroCmdLine)
    integer I, RC, ID, buff

    I = Pos(Chr(9), args)
    buff = Val(SubStr(args, 1, I-1))
    args = DelStr(args, 1, I)

    ID = CopyBufferToList(SL_INV_ID, buff)
    RC = WinDlgAddTodo(ID, args)
    case RC
        when ID_OK
            CopyListToBuffer(ID, buff)
            Set(MacroCmdLine, Format(2, Chr(9), args))
        when ID_CANCEL
            // cancelled
        otherwise
            Warn("error running WinDlg: RC = ", RC)
    endcase
end

/****************************************************************************\
    list and maintain todo items

    this is not a standalone command
    this is only a data interface for the todo macro
\****************************************************************************/

proc sWinDlgTodoList()
    integer RC, ID, Selected

    Selected = CurrLine()
    ID = CopyBufferToList(SL_INV_ID, GetBufferId())

    RC = WinDlgTodoList(ID, Selected, TodoListX, TodoListY, TodoListSortCol)
    if RC >= 0
        GotoLine(Selected)
        Set(MacroCmdLine, Str(RC))
    else
        Warn("error running WinDlg: RC = ", RC)
    endif
end

/****************************************************************************\
    setup todo defaults

    this is not a standalone command
    this is only an input device for the todo setup macro
\****************************************************************************/

proc sWinDlgTodoSetup()
    integer RC
    string args[128]

    args = Query(MacroCmdLine)
    RC = WinDlgTodoSetup(args)
    case RC
        when ID_OK
            Set(MacroCmdLine, args)
        when ID_CANCEL
            // cancelled
        otherwise
            Warn("error running WinDlg: RC = ", RC)
    endcase
end

/****************************************************************************\
    compare files dialog
\****************************************************************************/

helpdef DlgCompHelp
    title = "Help on Comparing Text Files"
    width = 70
    height = 12
    x = 2
    y = 3

    ""
    "   This dialog is used to enter the names of the files which"
    "   should be compared. Additional help is available, especially"
    "   on key assignments, while comparing the files."
    ""
    "   Summary of commands:"
    ""
    "   Compare     start comparing files"
    "   Cancel      abort file comparison"
    ""
    "   To search a file click the search buttons (the binoculars)."
    ""
end

/****************************************************************************/

proc sWinDlgComp()
    integer RC, batch, dialog, did_zoom
    integer HistID1, HistID2
    integer FileID1, FileID2
    string File[255] = ""

    HistID1 = GetFreeHistory("DlgComp:FileName1")
    HistID2 = GetFreeHistory("DlgComp:FileName2")

    batch = GetEnvStr("TSECOMPBATCHED") == "1"
    dialog = True

    if batch
        File = GetEnvStr("TSECOMPCMDARG1")
        if File <> "" and FileExists(File)
            AddHistoryStr(File, HistID1)
            File = GetEnvStr("TSECOMPCMDARG2")
            if File <> "" and FileExists(File)
                AddHistoryStr(File, HistID2)
                dialog = False
                RC = ID_OK
            endif
        endif
    else
        AddHistoryStr(CurrFilename(), HistID1)
        if NextFile(_DONT_LOAD_)
            AddHistoryStr(CurrFilename(), HistID2)
            PrevFile()
        endif
    endif

    FileID1 = CopyHistoryToList(SL_INV_ID, HistID1)
    FileID2 = CopyHistoryToList(SL_INV_ID, HistID2)

    if dialog
redisplay:
        RC = SetMCL(WinDlgComp(FileID1, FileID2))
        case RC
            when ID_OK
                GetTopHistoryString(File, FileID1, HistID1)
                GetTopHistoryString(File, FileID2, HistID2)
            when ID_CANCEL
                // cancelled
            when ID_HELP
                QuickHelp(DlgCompHelp)
                goto redisplay
            otherwise
                Warn("error running WinDlg: RC = ", RC)
        endcase
    endif

    if RC == ID_OK
        if isMaximized(GetWinHandle())
            did_zoom = FALSE
        else
            did_zoom = TRUE
            SendMessage(GetWinHandle(), WM_SYSCOMMAND, SC_MAXIMIZE, 0)
        endif
        ExecMacro("compx")
        if did_zoom
            SendMessage(GetWinHandle(), WM_SYSCOMMAND, SC_RESTORE, 0)
        endif
    endif

    if batch and NumFiles() == 1 and CurrFilename() == "<unnamed-1>"
        AbandonEditor()
    endif

    FreeStrList(FileID1)
    FreeStrList(FileID2)
end

/****************************************************************************\
    interface routines

    do _not_ call these directly
    they are input devices (empty shells) for external macros
\****************************************************************************/

public proc DlgGrep()
    sWinDlgGrep()
end

public proc DlgAddTodo()
    sWinDlgAddTodo()
end

public proc DlgTodoList()
    sWinDlgTodoList()
end

public proc DlgTodoSetup()
    sWinDlgTodoSetup()
end

/****************************************************************************\
    stub-routines for dialogs

    these are used to transparently substitute WinDlgs for Dialogs
    DlgRcnt is now able to find the recent files buffer on its own
\****************************************************************************/

public proc DlgOpen()
    sWinDlgOpen()
end

public proc DlgBuff()
    sWinDlgBuffers()
end

public proc DlgRcnt()
    sWinDlgRecent()
end

public proc DlgBrows()
    sWinDlgPickFolder()
end

public proc DlgFill()
    sWinDlgFill()
end

public proc DlgFind()
    sWinDlgFind()
end

public proc DlgRplc()
    sWinDlgReplace()
end

public proc DlgFndDo()
    sWinDlgFindAndDo()
end

public proc DlgGoto()
    sWinDlgGoto()
end

public proc DlgMCC()
    sWinDlgMCC()
end

public proc DlgAscii()
    sWinDlgAsciiChart()
end

public proc DlgDos()
    sWinDlgDos()
end

public proc DlgHist()
    sWinDlgHistories()
end

public proc DlgComp()
    sWinDlgComp()
end

/****************************************************************************\
    new dialogs (not part of the older package)
\****************************************************************************/

public proc DlgVersion()
    sWinDlgVer()
end

public proc DlgMsgBox()
    sWinMsgBox()
end

public proc DlgYesNoBox()
    sWinYesNoBox()
end

public proc DlgBookMark()
    sWinDlgBookmark()
end

public proc DlgOpts()
    sWinDlgOpts()
end

/****************************************************************************\
    initialization
\****************************************************************************/

proc WhenLoaded()
    WinDlgInit(GetWinHandle())
end

/****************************************************************************\
    some example key assignments

    remove the // at the beginning of the lines to use any of these
    ExecMacro isn't strictly necessary in all cases, but allows easy copying

    these keys aren't necessarily compatible with TSE's standard assignments
\****************************************************************************/

//<Ctrl o>            ExecMacro("dlgopen")
//<CtrlShift s>       ExecMacro("dlgopen -s")
//<Ctrl k><r>         ExecMacro("dlgopen -i")
//<Ctrl k><s>         ExecMacro("dlgopen -b")
//<CtrlShift o>       ExecMacro("dlgbrows -c -g")
//<Alt 0>             ExecMacro("dlgbuff")
//<Ctrl 0>            ExecMacro("dlgrcnt")
//<Ctrl f>            ExecMacro("dlgfind")
//<Ctrl g>            ExecMacro("grep")
//<Ctrl r>            ExecMacro("dlgrplc")
//<CtrlShift f>       ExecMacro("dlgfill")
//<CtrlShift j>       ExecMacro("dlggoto")
//<Ctrl F6>           ExecMacro("dlgbookmark")
//<Shift F2>          ExecMacro("todo")
//<Ctrl F2>           ExecMacro("todo -t")

