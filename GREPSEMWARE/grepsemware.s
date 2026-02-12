/*************************************************************************
  Grep        Search disk files for a specified string

  Author:     SemWare

  Date:       Summer, 1997 - Initial version

              Dec 2000 - KSW/SEM Fix problems that occur when grep fails
                    (e.g., *.foobar, no matching files)

              Jan 11, 2001 - Didn't handle temporary paths with spaces
                in the name.  Thanks to Bruce Riggins for reporting this.

              28 Feb 2009 SEM - Fix problem of not finding tee32.exe and
                grep.exe in certain cases where TSELOADDIR was used. Reported
                (along with a suggested fix) by Ross Barnes.
              15 Dec 2010 SEM - Fix problem in making the filename ViewFinds
                compatible.

  Date:       30 November 2022 - Add the name and path to your different
              grep.exe in your grepsemware.ini file.
              by Knud van Eeden

  Overview:

  This macro allows one to search a list of files for a specified
  string. Regular expressions are supported, as is searching in nested
  subdirectories.

  Usage notes:

  Upon running this macro, the user is given a menu from which to
  select the supported actions.

  Copyright 1992-1999 SemWare Corporation.  All Rights Reserved Worldwide.

  Use, modification, and distribution of this SAL macro is encouraged by
  SemWare provided that this statement, including the above copyright notice,
  is not removed; and provided that no fee or other remuneration is received
  for distribution.  You may add your own copyright notice to cover new matter
  you add to the macro, but SemWare Corporation will neither support nor
  assume legal responsibility for any material added or any changes made to
  the macro.

*************************************************************************/

STRING iniFileNameGS[255] = ".\grepsemware.ini"
STRING grepGS[255] = ""
STRING nameGrepGS[255] = ""
STRING macroGrepGS[255] = ""
STRING executableGrepGS[255] = ""
STRING optionGrepGS[255] = ""

string grep[_MAX_PATH_]
string tee32[_MAX_PATH_]

helpdef FileHelp
"                                         "
""
"  Enter a list of files to be searched."
"  The filenames can contain wild-cards."
""
"  Examples:"
""
"  *.c *.h *.s"
""
"  foo.bar test.it"
""
"  c:\win98\*.dll"
""
"  abc.abc c:\*.* d:\here\*.c"
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
""
end

helpdef OptionsHelp
"                                                         "
""
"  -0  display file names only"
"  -1  display first matching line only"
"  -b  blank before fn line"
"  -c- do not display copyright message"
"  -f  display filename on each line"
"  -f- do not display any filenames"
"  -i  ignore case"
"  -m  display only non-matching lines"
"  -n  display line numbers"
"  -s  search subdirectories (-d accepted too)"
"  -v  verbose"
"  -w  words only"
"  -x  use regular expressions (same syntax as TSE Pro)"
""
""
""
""
""
""
""
""
""
""
""
""
""
end

helpdef UnknownHelp
end

constant MAXPATH = 255

constant FN_POS = 7, OCCUR_LEN = 19
#define  VIEW_FINDS_CHAR    0x46        // 'F' in German version

integer proc PopWin(string title, integer width, integer height)
    integer x
    integer y = WhereY()

    x = max((Query(ScreenCols) - width) / 2, 1)

    // try to put on line above
    if y > height + 1
        y = y - height - 1
    else
        y = y + 1
    endif
    if y + height > Query(ScreenRows)
        y = Query(WindowRows) - height
    endif
    ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
    if PopWinOpen(x,y,x + width - 1,y + height - 1,1,title,Query(MenuBorderAttr))
        return (TRUE)
    endif
    return (FALSE)
end PopWin

#define pSET_STATE      -3
#define pPREV_FIELD     -2
#define pNEXT_FIELD     -1
#define pABORT           0
#define pACCEPT          1

#define sSEARCH         0
#define sFILES          1
#define sOPTIONS        2
#define nSTATES         3

integer next_state, state

proc GetHelp()
    Set(X1, wherex())
    Set(Y1, wherey())
    case state
        when sSEARCH  Help("Regular Expression Operators")
        when sFILES   QuickHelp(FileHelp)
        when sOPTIONS QuickHelp(OptionsHelp)
        otherwise     QuickHelp(UnknownHelp)
    endcase
end

KeyDef GrepKeys
    <Shift Tab> EndProcess(pPREV_FIELD)
    <Tab>       EndProcess(pNEXT_FIELD)
    <Enter>     EndProcess(pACCEPT)
    <Escape>    EndProcess(pABORT)
    <Alt S>     next_state = sSEARCH     EndProcess(pSET_STATE)
    <Alt F>     next_state = sFILES      EndProcess(pSET_STATE)
    <Alt O>     next_state = sOPTIONS    EndProcess(pSET_STATE)
    <F1>        GetHelp()
end

proc EnableTheseKeys()
    if not Enable(GrepKeys)
        EndProcess(pABORT)
    endif
    BreakHookChain()
end

proc DisplayPromptInfo(integer x, integer y, string prompt, string s)
    VGotoXY(x,y)
    PutHelpLine(prompt)
    PutStrXY(x + 9,y,s,Query(MenuTextAttr))
end

// string search [128] = ""
string search [128] = '" <your search>"'

// string files  [128] = "*.c *.h *.s"
string files  [128] = ""

// string options[128] = "-i -x"
string options[128] = "-is"

integer grep_id
forward proc ViewGrepResults(integer here_before)

string proc TempPath()
    string dir[MAXPATH]

    dir = GetEnvStr("TEMP")
    if dir == ""
        dir = GetEnvStr("TMP")
        if dir == ""
            dir = CurrDir()
        endif
    endif
    return (QuotePath(MakeTempName(dir)))
end

proc Main()
    integer n, exec, id, ok
    string grep_fn[MAXPATH]
    integer search_hist  = GetFreeHistory("grep:search")
    integer files_hist   = GetFreeHistory("grep:files")
    integer options_hist = GetFreeHistory("grep:options")
    //
    STRING s1[255] = ""
    INTEGER bufferI = 0
    //
    STRING grep01S[255] = GetProfileStr( "grepsemware", "grep01S", "", iniFileNameGS )
    STRING grep02S[255] = GetProfileStr( "grepsemware", "grep02S", "", iniFileNameGS )
    STRING grep03S[255] = GetProfileStr( "grepsemware", "grep03S", "", iniFileNameGS )
    STRING grep04S[255] = GetProfileStr( "grepsemware", "grep04S", "", iniFileNameGS )
    STRING grep05S[255] = GetProfileStr( "grepsemware", "grep05S", "", iniFileNameGS )
    STRING grep06S[255] = GetProfileStr( "grepsemware", "grep06S", "", iniFileNameGS )
    STRING grep07S[255] = GetProfileStr( "grepsemware", "grep07S", "", iniFileNameGS )
    STRING grep08S[255] = GetProfileStr( "grepsemware", "grep08S", "", iniFileNameGS )
    STRING grep09S[255] = GetProfileStr( "grepsemware", "grep09S", "", iniFileNameGS )
    //
    PushPosition()
    bufferI = CreateTempBuffer()
    PopPosition()
    //
    PushPosition()
    PushBlock()
    GotoBufferId( bufferI )
    //
    AddLine( grep01S )
    AddLine( grep02S )
    AddLine( grep03S )
    AddLine( grep04S )
    AddLine( grep05S )
    AddLine( grep06S )
    AddLine( grep07S )
    AddLine( grep08S )
    AddLine( grep09S )
    //
    GotoLine( 1 )
    ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
    IF List( "Choose the name of a grep", 80 )
     s1 = Trim( GetText( 1, 255 ) )
    ELSE
     AbandonFile( bufferI )
     RETURN()
    ENDIF
    AbandonFile( bufferI )
    PopBlock()
    PopPosition()
    //
    // do something with s1
    //
    grepGS = s1
    //
    nameGrepGS = GetToken( grepGS, ",", 1 )
    macroGrepGS = GetToken( grepGS, ",", 2 )
    optionGrepGS = GetToken( grepGS, ",", 3 )
    executableGrepGS = GetToken( grepGS, ",", 4 )
    //
    search  = GetHistoryStr(search_hist, 1)
    files   = GetHistoryStr(files_hist, 1)
    options = GetHistoryStr(options_hist, 1)

    grep_fn = TempPath()
    exec = FALSE
    Set(Attr, Query(MenuTextAttr))
    if PopWin("Grep" + " " + nameGrepGS + " "+ "["+CurrDir()+"]", iif(Query(ScreenCols) > 68, 68, Query(ScreenCols)), 5)
        ClrScr()
        //
        ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
        Warn( "<CtrlAltShift K> ViewGrepResults" )
        WindowFooter("{Enter}-Execute  {Escape}-Abort  {Tab}-Next field")
        //
        ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
        Ask( "{S}earch:", search, _FIND_HISTORY_ ) // new [kn, ri, su, 19-03-2006 01:04:35]
        AddHistoryStr( search, _FIND_HISTORY_) // new [kn, ri, su, 19-03-2006 01:04:49]
        //
        ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
        Ask( "{F}iles:", files, _EDIT_HISTORY_ ) // new [kn, ri, sa, 20-11-2010 20:54:14]
        AddHistoryStr( files, _EDIT_HISTORY_) // new [kn, ri, su, 19-03-2006 01:04:49]
        //
        ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
        Ask( "{O}ptions:", options, _FINDOPTIONS_HISTORY_ ) // new [kn, ri, su, 19-03-2006 01:04:35]
        AddHistoryStr( options, _EDIT_HISTORY_) // new [kn, ri, su, 19-03-2006 01:04:49]
        //
        DisplayPromptInfo(1,1,"{S}earch:" ,search)
        DisplayPromptInfo(1,2,"{F}iles:"  ,files)
        DisplayPromptInfo(1,3,"{O}ptions:",options)
        state = sSEARCH
        if Hook(_PROMPT_STARTUP_, EnableTheseKeys)
            loop
                VGotoXY(10,1 + state)
                case state
                    when sSEARCH
                        n = Read(search, search_hist)
                    when sFILES
                        n = Read(files, files_hist)
                    when sOPTIONS
                        n = Read(options, options_hist)
                endcase
                VGotoXY(8,1 + state)
                PutAttr(Query(MenuTextAttr),Query(PopWinCols) - 7)
                case n
                    when pPREV_FIELD
                        state = ((state - 1) + nSTATES) mod nSTATES
                    when pNEXT_FIELD
                        state = (state + 1) mod nSTATES
                    when pABORT
                        break
                    when pACCEPT
                        Exec = TRUE
                        break
                    when pSET_STATE
                        state = next_state
                endcase
            endloop
            UnHook(EnableTheseKeys)
        endif
        PopWinClose()
        if exec
//            rows = Query(ScreenRows)
//            cols = Query(ScreenCols)
//            if cols <> 80 and not (rows in 25,43,50)
//                SetVideoRowsCols(25, 80)
//            endif
              //
            //
            options = Format( options, " ", optionGrepGS )
            //
            // replace always in all the filenames the backslash '\' by the '/' (because of many grep implementations expect that).
            //
            // IF EquiStr( nameGrepGS, "cygwin" )
             files = StrReplace( "\", files, "/", "" )
            // ENDIF
            //
            // ok = lDOS(tee32, format(grep;options;"-n";QuotePath(search);files;">";grep_fn),_DONT_PROMPT_|_TEE_OUTPUT_) // old [kn, ri, fr, 02-12-2022 03:53:21]
            ok = lDOS(tee32, format(executableGrepGS;options;"-n";QuotePath(search);files;">";grep_fn),_DONT_PROMPT_|_TEE_OUTPUT_) // new [kn, ri, fr, 02-12-2022 03:53:24]
//            SetVideoRowsCols(rows, cols)
            if ok
                PushPosition()
                id = EditFile(grep_fn, _DONT_LOAD_)
                if id and GotoBufferId(id)
                    grep_id = GetBufferId()
                    BufferType(_SYSTEM_)
                    ReplaceFile(grep_fn,_OVERWRITE_)
                    //
                    // Halt // debug
                    //
                    PushBlock()
                    PushPosition()
                    MarkLine( 1, NumLines() )
                    //
                    ExecMacro( Format( macroGrepGS, " ", options ) ) // call the macro, but also pass the options (e.g. in TSE check for '-f'
                    //
                    PopPosition()
                    PopBlock()
                    //
                    if lFind("File: ","^g")
                        repeat
                            GotoPos(FN_POS)
                            InsertText(QuotePath(GetText(FN_POS, _MAXPATH_)), _OVERWRITE_)
                        until not lRepeatFind()
                    endif
                    EndFile()
                    while PosFirstNonWhite() == 0 and KillLine()
                    endwhile
                    BegFile()
                endif
                PopPosition()
                EraseDiskFile(grep_fn)
                ViewGrepResults(FALSE)
            endif
        endif
    endif
end

//proc ViewFindsStartup()
//    BufferType(_NORMAL_)
//end

//proc ViewFindsCleanup()
//    BufferType(_SYSTEM_)
//end

proc ViewGrepResults(integer here_before)
    integer save_id, errors, buffer_type

    errors = TRUE
    PushPosition()
    if GotoBufferId(grep_id)
        if NumLines() == 0
            AddLine("No matches found")
        elseif here_before or lFind("File: ","g")
            errors = FALSE
        endif
    endif
    PopPosition()

    if errors
        Alarm()
        PushPosition()
        if GotoBufferId(grep_id)
            buffer_type = BufferType(_NORMAL_)
            // width hack: width of footer, less 6 braces
            List("Grep Results", max(LongestLineInBuffer(), 49 - 6))
            BufferType(buffer_type)
        else
            ExecMacro( "setwiyde" ) // operation: set: window: warn/yesno: position: x: y: default // new
            Warn("View buffer does not exist")
        endif
        PopPosition()
    else
        save_id = Set(ViewFindsId, grep_id)
//        Hook(_LIST_STARTUP_, ViewFindsStartup)
//        Hook(_LIST_CLEANUP_, ViewFindsCleanup)
        ViewFinds()
//        UnHook(ViewFindsStartup)
//        UnHook(ViewFindsCleanup)
        Set(ViewFindsId, save_id)
    endif
end

/**************************************************************************
  See if the specified pgm exists in the actual (LoadDir(1)) or the
  (possibly redirected) LoadDir().
 **************************************************************************/
proc find_editor_program(string fn, var string path)
    path = SplitPath(LoadDir(1), _DRIVE_|_PATH_) + fn
    if not FileExists(path)
        path = LoadDir() + fn
        if not FileExists(path)
            path = ""
        endif
    endif
    path = QuotePath(path)
end

proc WhenLoaded()
    // find_editor_program("grep.exe", grep) // old [kn, ri, fr, 02-12-2022 03:52:00]
    find_editor_program( executableGrepGS, grep) // new [kn, ri, sa, 03-12-2022 05:52:55]
    find_editor_program("tee32.exe", tee32)
end

//<Alt G>     Main()
// <CtrlAlt G> ViewGrepResults(TRUE)
<CtrlAltShift K> ViewGrepResults(TRUE)
