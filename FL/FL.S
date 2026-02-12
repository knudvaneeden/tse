/***************************************************************************

  Author:     Richard Blackburn

  Date:        Description:
  ------------ ---------------------------------------------------------------
  Mar     1993 Original release with TSE v1
  Sep     1994 Clean up for TSE v2
  Oct 18, 1994 Bug fix - If main prompt was exited, all settings were not
               being restored.  Thanks to James Coffer for the fix.

  Oct 24, 1994 Dave Gwillim
               1. Added ViewZIP command (uses "pkunzip -vb"). Assumes
                  PKUNZIP.EXE is on the DOS path. Uses TEMP environment
                  variable to place temporary file for ZIP contents, so it
                  will works on Read-Only devices like CD ROMs.
               2. Added code to return to start directory if an explicit
                  directory change (via Enter on file list) was not made.
                  Before if you specified a target directory at the "Dir:"
                  prompt, when you exited FL it would leave you in that
                  directory.
               3. Added code to reset the filelist cursor after a list sort.
                  It used to end up on the last item in the list, now it
                  returns to whatever file name the cursor was on before the
                  sort took place.

  Oct 25, 1994 Bug fix - deleting files with readonly attributes did not work.
               Thanks to James Coffer for the fix.

  Nov  9, 1994 Colsolidate fixes/changes from various authors

  Overview:

  A simple WordPerfect 5.2 -like filemanager.

***************************************************************************/

string ZIP[] = "unzip"

/***********************************************************************
  The following commands are included via this set of DOS calls:

  FindFirst --  Find the first matching file

                integer proc FindFirst(string path, var string ffblk, integer attribs)

  FindNext  --  Find the next matching file

                integer proc FindNext(var string ffblk)

  SetAttrib --  Set the attributes of the file passed

                integer proc SetAttrib(string file, integer attrib)

 ***********************************************************************/
binary ['wp.bin']
    integer proc _ff(string path, var string ffblk, integer attribs) : 0
    integer proc _fn(var string ffblk) : 3
    integer proc _SetAttrib(string file, integer attrib) : 6
end

constant    ffNORMAL    = 0x00,
            ffRDONLY    = 0x01,
            ffHIDDEN    = 0x02,
            ffSYSTEM    = 0x04,
            ffVOLUME    = 0x08,
            ffSUBDIR    = 0x10,
            ffARCH      = 0x20,
            ffALL       = 0x3f,
            ffALLNV     = 0x37       // All except ffVOLUMNE

string ffblk[43]
integer dirchanged=0      // DAG::941024  Flag for deliberate Dir change

integer proc SetAttrib(string file, integer attrib)
    return(_SetAttrib(file + Chr(0), attrib))
end

string proc ffName(string ffblk)
    integer p = Pos(Chr(0),SubStr(ffblk,31,13))
    return (SubStr(ffblk,31,iif(p,p-1,13)))
end

integer proc ffAttr(string ffblk)
    return (Asc(ffblk[22]))
end

string proc ffAttrStr(string ffblk)
    string  s[5] = ''
    integer a = ffAttr(ffblk)

    s = iif(a & ffRDONLY, 'R', '_')
    s = s + iif(a & ffHIDDEN, 'H', '_')
    s = s + iif(a & ffSYSTEM, 'S', '_')
    s = s + iif(a & ffARCH,   'A', '_')
    s = s + iif(a & ffSUBDIR, 'D', '_')
    return (s)
end ffAttrStr

string proc ffTime(string ffblk)
    integer t = (Asc(ffblk[24]) shl 8) | Asc(ffblk[23])
    string  s[8] = ''

    s = Format(((t & 0xF800) shr 11):2:'0', ':',
               ((t & 0x07E0) shr  5):2:'0', ':',
               ((t & 0x001F) shl  1):2:'0')
    return (s)
end ffTime

string proc ffDate(string ffblk)
    integer d = (Asc(ffblk[26]) shl 8) | Asc(ffblk[25])
    string  s[8] = ''

    s = Format(((d & 0x01E0) shr 5):2:'0', '-',
               (d & 0x001F):2:'0', '-',
               ((((d & 0xFE00) shr 9)+ 80) mod 100):2:'0')
    return (s)
end ffDate

integer proc ffSize(string ffblk)
    return ((Asc(ffblk[30]) shl 24) | (Asc(ffblk[29]) shl 16) |
            (Asc(ffblk[28]) shl  8) | (Asc(ffblk[27])))
end ffSize

integer proc FindFirst(string path, var string ffblk, integer attribs)
    return(_ff(path+Chr(0), ffblk, attribs))
end FindFirst

integer proc FindNext(var string ffblk)
    return(_fn(ffblk))
end FindNext


/****************** end of binary helper routines ********************/

constant    MARKCOL     = 60,
            DIRCOL      = 51,
            ATTRCOL     = 47

integer marked, num_files, total_size, error_level, prev_dir_id, list_id

forward integer proc mAsk(string prompt, var string reply)

 /***********************************************************************
  Mark/UnMark the current file.
 ***********************************************************************/
proc MarkIt()
    GotoColumn(MARKCOL)
    If CurrChar() == ASC('*')
        marked = marked - 1
        InsertText(' ', _OVERWRITE_)
    else
        marked = marked + 1
        InsertText('*', _OVERWRITE_)
    endif
end

 /***********************************************************************
  Display a help string on the status line
 ***********************************************************************/
proc PutOnStatusLine(string outstring)
    if Query(StatusLineAtTop)
        VGotoXY(1,1)
    else
        VGotoXy(1,Query(ScreenRows))
    endif
    PutHelpLine(outstring)
end

 /***********************************************************************
  Format and return the file name and extention.
 ***********************************************************************/
string proc mffName(string ffblk)
    string n[20] = ffName(ffblk)
    if n == '..'
        return ('..')
    endif
    return (Format(SplitPath(n,_NAME_):-9,SplitPath(n,_EXT_):-8))
end mffName

 /***********************************************************************
  Return the file size, or a nul string if it is a SubDir.
 ***********************************************************************/
string proc mffSize(string ffblk)
    if ffAttr(ffblk) & ffSUBDIR
        return ('')
    endif
    return (Str(ffSize(ffblk)))
end mffSize

 /***********************************************************************
  This will generate the pick buffer that the users sees.
 ***********************************************************************/
integer proc mGeneratePickBuffer(string path)
    num_files = 0
    total_size = 0
    if FindFirst(path, ffblk, ffALL ^ ffVOLUME)
        repeat
            num_files = num_files + 1
            total_size = total_size + ffSize(ffblk)
            if ffName(ffblk) <> '.'
                AddLine(
                            Format( mffName(ffblk):-17,
                                    mffsize(ffblk):8,
                                    ffdate(ffblk):10,
                                    SubStr(ffTime(ffblk),1,5):10,
                                    ' ', ffAttrStr(ffblk)
                            )
                )
            endif
        until not FindNext(ffblk)
        return(TRUE)
    endif
    return(FALSE)
end

 /***********************************************************************
  This will setup the pick buffer and variables and display the info
  on the status line.
 ***********************************************************************/
integer proc SetUpPickList(string s)
    string path[80]
    integer save_line, line = 1

    PutOnStatusLine('Working')

    PushPosition()
    path = ExpandPath(".")
    save_line = CurrLine()
    GotoBufferId(prev_dir_id)
    BegFile()
    if lFind(ExpandPath(s), "g$")
        line = Val(Trim(GetText(1, 5)))
    endif
    if lFind(path, "g$")
        DelLine()
    endif
    BegFile()
    InsertLine(Format(save_line:5, path))
    PopPosition()

    path = ExpandPath(s)
    if Length(path) == 0
        return (FALSE)
    endif
    LogDrive(SplitPath(path, _DRIVE_))
    ChDir(SplitPath(path, _PATH_))
    EmptyBuffer()
    if NOT mGeneratePickBuffer(path)
        return(FALSE)
    endif
    GotoLine(line)
    BegLine()
    PutOnStatusLine(
        Format('{F1} -- help  {F}iles: ' + Str(num_files)
            + ' {T}otal size: ' + Str(total_size):-50,
            path:36
        )
    )
    return(TRUE)
end

 /***********************************************************************
  This returns the file name without spaces.
 ***********************************************************************/
string proc FileName()
    return (Format(Trim(GetText(1, 9)), Trim(GetText(10, 5))))
end

integer proc isDir()
    GotoColumn(DIRCOL)
    return (CurrChar() == Asc('D'))
end

 /***********************************************************************
  Either list the file selected, or move to the SubDir selected.
 ***********************************************************************/
proc ViewIt()
    string file[13] = FileName()

    if isDir()
        dirchanged=1    // DAG::941024  set flag for deliberate dir change
        SetUpPickList(file)
    else
        PushPosition()
        if CreateTempBuffer()
            if InsertFile(file)
                UnMarkBlock()
                List(file, Query(ScreenCols))
            endif
            AbandonFile()
        endif
        PopPosition()
    endif
end


/*****************************************************************************
ÚÄÄÄÄÄÄÄÄÄ¿
³ ViewZIP ³
ÀÄÄÄÄÄÄÄÄÄÙ
  Added by Dave Gwillim  24 Oct 1994
*/
proc ViewZIP(string zipviewcmd)
  string file[13] = FileName()
  string tmpfile[80]=GetEnvStr("TEMP")+"\\"+"$ZIPDIR$.$$$"

  PushPosition()
  if CreateTempBuffer()
    Dos(zipviewcmd+" "+file+" >"+tmpfile,_DONT_PROMPT_ | _DONT_CLEAR_)
    if InsertFile(tmpfile)
      UnMarkBlock()
      List(tmpfile, Query(ScreenCols))
    endif
    AbandonFile()
  endif
  PopPosition()
  EraseDiskFile(tmpfile)
end

 /***********************************************************************
  How do you want to sort the list?
 ***********************************************************************/
menu SortMenu()
    Title = 'Sort by'
    "&Name"
    "&Extention"
    "&Size"
    "&Date"
    "&Time"
end

 /***********************************************************************
  This will sort the file listing, by prompting for how to sort.
 ***********************************************************************/
proc SortIt()
    integer scol, ecol, date = FALSE
    string fname[13]=Format(Trim(GetText(1,13)))  // DAG:941024

    case SortMenu()
        when 1     scol = 1     ecol = 8
        when 2     scol = 10    ecol = 14
        when 3     scol = 17    ecol = 25
        when 4     scol = 28    ecol = 33   date = TRUE
        when 5     scol = 38    ecol = 45
        otherwise return()
    endcase
    PushBlock()
    loop
        UnMarkBlock()
        BegFile()
        GotoColumn(scol)
        MarkColumn()
        GotoColumn(ecol)
        EndFile()
        MarkColumn()
        Sort()
        if NOT date
            break
        endif
        scol = 34
        ecol = 35
        date = FALSE
    endloop
    PopBlock()
    BegFile()           // DAG:941024
    LFind(fname,"fi")   // DAG:941024
    UpdateDisplay()
end

 /***********************************************************************
  Delete the file at the cursor line.
 ***********************************************************************/
proc DelFile()
    string file[13] = FileName()

    // Must remove readonly attr if it exists
    SetAttrib(FileName(), ffARCH)
    if EraseDiskFile(file)
        DelLine()
        if NumLines() == CurrLine() AND NOT CurrLineLen()
            Up()
            BegLine()
            JoinLine()
        endif
    endif
end

 /***********************************************************************
  Delete either the current file, or all marked files.
 ***********************************************************************/
proc DelIt()
    if NOT marked
        if YesNo('Delete ' + FileName()) == 1
            DelFile()
        endif
    else
        if YesNo('Delete All marked files') == 1
            if YesNo("Are you sure") == 1
                PushPosition()
                PushBlock()
                UnMarkBlock()
                EndFile()
                GotoColumn(MARKCOL)
                MarkColumn()
                BegFile()
                MarkColumn()
                if LFind('*', 'gl')
                    repeat
                        marked = marked - 1
                        DelFile()
                        GotoBlockBegin()
                    until NOT LRepeatFind()
                endif
                PopPosition()
                PopBlock()
            endif
        endif
    endif
end

string proc UniqueName()
    integer temp = 1

    while FileExists(str(temp))
        temp = temp + 1
    endwhile
    return(str(temp))
end

 /***********************************************************************
  This will check the errorlevel returned from dos and
 ***********************************************************************/
integer proc ChkError()
    if LFind('1 file(s) copied', '')
        return(FALSE)
    endif
    return(TRUE)
end

 /***********************************************************************
  This procedure will copy one file.
 ***********************************************************************/
integer proc CopyFile(string copyto)
    string  fn[8] = UniqueName()

    Dos('Copy ' + FileName() + ' ' + copyto + '>' + fn, 2)
    Set(Cursor,Off)
    if marked
        MarkIt()
    endif
    PushPosition()
    EditFile(fn)
    error_level = ChkError()
    EraseDiskFile(fn)
    PopPosition()
    Set(Cursor,On)
    return(NOT error_level)
end

 /***********************************************************************
  Copy a single file, or multiple files using copy file.
 ***********************************************************************/
proc CopyIt()
    string copyto[80] = ''

    if NOT marked
        if mAsk("Copy to:", copyto)
            if NOT CopyFile(copyto)
                Warn('Error in copying... error level = ', error_level)
            endif
        endif
    else
        if YesNo('Copy All marked files') == 1
            if mAsk("Copy files to:", copyto)
                PushPosition()
                PushBlock()
                UnMarkBlock()
                EndFile()
                GotoColumn(MARKCOL)
                MarkColumn()
                BegFile()
                MarkColumn()
                if LFind('*', 'gl')
                    repeat
                        marked = marked - 1
                        if NOT CopyFile(copyto)
                            Warn('Error in copying... error level = ', error_level)
                        endif
                        GotoBlockBegin()
                    until NOT LRepeatFind()
                endif
                PopPosition()
                PopBlock()
            endif
        endif
    endif
end

 /***********************************************************************
  The following menus and proc's are to allow you to change the file
  attributes.
 ***********************************************************************/
integer newattr = 0

proc mSet(integer i)
    newattr = newattr ^ i
end

string proc CheckAttr(integer i)
    return (iif(newattr & i, "û", ""))
end

menu AttrMenu()
    '&Read Only' [CheckAttr(ffRDONLY):2]  ,mset(ffRDONLY), DontClose
    '&Archive'   [CheckAttr(ffARCH):2]    ,mset(ffARCH  ), DontClose
    '&System'    [CheckAttr(ffSYSTEM):2]  ,mset(ffSYSTEM), DontClose
    '&Hidden'    [CheckAttr(ffHIDDEN):2]  ,mset(ffHIDDEN), DontClose
    'S&et them'
end

string proc mffAttrStr(integer a)
    string s[5] = ''
    s =     iif(a & ffRDONLY, 'R', '_')
    s = s + iif(a & ffHIDDEN, 'H', '_')
    s = s + iif(a & ffSYSTEM, 'S', '_')
    s = s + iif(a & ffARCH,   'A', '_')
    s = s + iif(a & ffSUBDIR, 'D', '_')
    return (s)
end

integer proc CurrAttr()
    integer attrib = 0
    string temp[5] = GetText(ATTRCOL, 5)
    attrib =            iif(Pos('R', temp), ffRDONLY, 0)
    attrib = attrib +   iif(Pos('H', temp), ffHIDDEN, 0)
    attrib = attrib +   iif(Pos('S', temp), ffSYSTEM, 0)
    attrib = attrib +   iif(Pos('A', temp), ffARCH,   0)
    attrib = attrib +   iif(Pos('D', temp), ffSUBDIR, 0)
    return(attrib)
end

 /***********************************************************************
  Set attributes of the current file.
 ***********************************************************************/
proc ChangeAttr()
    newattr = CurrAttr()
    if AttrMenu()
        SetAttrib(FileName(), newattr)
        GotoColumn(ATTRCOL)
        InsertText(mffAttrStr(newattr), _OVERWRITE_)
        BegLine()
    endif
end

 /***********************************************************************
  Rename the current file.
 ***********************************************************************/
proc Rename()
    string nfn[13] = ''

    if mAsk('New filename:', nfn)
        nfn = Upper(nfn)
        RenameDiskFile(FileName(), nfn)
        BegLine()
        InsertText(Format(SplitPath(nfn, _NAME_):-9, SplitPath(nfn, _EXT_):-8), _OVERWRITE_)
    endif
end

proc PrintIt()
    PushPosition()
    EditFile(FileName())
    PrintFile()
    AbandonFile()
    PopPosition()
end

integer proc Loadit()
    if isDir()
        ViewIt()
        return (FALSE)
    endif

    EditFile(FileName())
    return (TRUE)
end

proc ChangeDir()
    string path[80] = ExpandPath(".")
    integer restore_original = FALSE

    while mAsk("Dir:", path)
        if SetUpPickList(path)
            return ()
        else
            Warn("Cannot change to ", path)
            restore_original = TRUE
        endif
    endwhile
    if restore_original
        SetUpPickList(ExpandPath("."))
    endif
end

 /***********************************************************************
  The help screen.
 ***********************************************************************/
helpdef FListHelp
    x = 2
    y = 5
    width = 76
    height = 15
    title = "F-List Help"

    "R      Load file"
    "L      View the File or move to SubDir"
    "Enter  View the File or move to SubDir"
    "D      Delete File"
    "M      Move/Rename File"
    "P      Print File"
    "O      Change dirs"
    "C      Copy File"
    "Space  Mark/UnMark"
    "A      Change Attr"
    "S      Sort"
end

 /***********************************************************************
  Active keys during the macros execution.
1 Retrieve; 2 Delete; 3 Move/Rename; 4 Print; 5 Short/Long Display;
6 Look; 7 Other Directory; 8 Copy; 9 Find; N Name Search: 6
 ***********************************************************************/
keydef file_keys
    <HelpLine>          '1 {R}etrieve 2 {D}elete 3 {M}ove/Rename 4 {P}rint 6 {L}ook 7 {O}ther dir 8 {C}opy'
    <1>                 if Loadit() EndProcess(2) endif // in WP
    <R>                 if Loadit() EndProcess(2) endif // in WP
    <Shift R>           if Loadit() EndProcess(2) endif // in WP

    <3>                 Rename()      // in WP
    <M>                 Rename()      // in WP
    <Shift M>           Rename()

    <2>                 DelIt()        // in WP
    <D>                 DelIt()        // in WP
    <Shift D>           DelIt()

    <8>                 CopyIt()       // in WP
    <C>                 CopyIt()       // in WP
    <Shift C>           CopyIt()

    <Enter>             ViewIt()       // in WP
    <6>                 ViewIt()
    <V>                 ViewIt()
    <Shift V>           ViewIt()
    <L>                 ViewIt()
    <Shift L>           ViewIt()

    <Z>                 ViewZip(ZIP + " -vb")  // DAG::941024
    <Shift Z>           ViewZip(ZIP + " -vb")  // DAG::941024

    <F1>                QuickHelp(FListHelp)
    <F3>                QuickHelp(FListHelp)

    <CursorDown>        Down()
    <CursorUp>          Up()
    <PgUp>              PageUp()
    <PgDn>              PageDown()

    <7>                 ChangeDir()   // in WP
    <O>                 ChangeDir()   // in WP
    <Shift O>           ChangeDir()

    <4>                 PrintIt()
    <P>                 PrintIt()
    <Shift P>           PrintIt()

    <Grey*>             MarkIt()
    <SpaceBar>          MarkIt()

    <F7>                EndProcess()
    <Escape>            EndProcess()

//  Enhancements

    <A>                 ChangeAttr()
    <Shift A>           ChangeAttr()

    <S>                 SortIt()
    <Shift S>           SortIt()

    <.>                 SetUpPickList("..")
end

// Ask for a string.  Return FALSE if blank or empty reply, or <escape> pressed
integer proc mAsk(string prompt, var string reply)
    integer result

    Disable(file_keys)
    result = Ask(prompt, reply)
    Enable(file_keys, _EXCLUSIVE_)
    return (result and Length(Trim(reply)))
end

 /***********************************************************************
  The main driver for the FList macro.
 ***********************************************************************/
proc mListFiles()
 /***********************************************************************
  12-11-92  03:13p            Directory F:\SE\*.*
Document size:      338   Free:  7,884,800 Used:    248,789     Files:      10

 .    Current    <Dir>                  ³ ..   Parent     <Dir>
 MACROS  .       <Dir>  12-11-92 02:15p ³ CONFIG  .S     52,966  12-11-92 02:15p
 DEFAULTS.S      3,749  12-11-92 02:15p ³ E       .EXE   95,484  12-11-92 02:16p
 HELP    .S        776  12-11-92 02:16p ³ ICONFIG .MAC   16,388  12-11-92 02:16p
 ICONFIG2.MAC    7,300  12-11-92 02:16p ³ KEYS    .S      6,753  12-11-92 02:16p
 READ    .ME     2,445  12-11-92 02:16p ³ SC      .EXE   59,602  12-11-92 02:16p
 SHOWKEY .EXE    3,326  12-11-92 02:16p
 ***********************************************************************/
    string path[80]
    string startpath[80]
    integer ssl     = Set(StatusLineUpdating, Off),
            hl      = Set(ShowHelpLine, ON),
            msgl    = Set(MsgLevel, _WARNINGS_ONLY_),
            scattr  = Set(CursorAttr, iif(Query(AttrSet) == _COLOR_, Color(White on Red), Color(Black on White))),
            seof    = Set(ShowEofMarker, OFF),
            i

    path = ExpandPath(".")
    startpath=path
    if Ask("Dir:", path)
        PushPosition()
        prev_dir_id = CreateTempBuffer()
        list_id = CreateTempBuffer()
        if SetUpPickList(path)
            Enable(file_keys, _EXCLUSIVE_)
            Set(Cursor,Off)
            i = Process()
            Set(Cursor,On)
            Disable(file_keys)
        endif
        AbandonFile(list_id)
        AbandonFile(prev_dir_id)
    endif
    if i == 2
        KillPosition()
    else
        PopPosition()
    endif
    Set(ShowHelpLine, hl)
    Set(StatusLineUpdating, ssl)
    Set(MsgLevel, msgl)
    Set(CursorAttr, scattr)
    Set(ShowEofMarker, seof)
    UpdateDisplay(_ALL_WINDOWS_REFRESH_)
    if (not dirchanged)
      LogDrive(startpath)
      ChDir(startpath)
    endif
end

proc main()
    mListFiles()
end

