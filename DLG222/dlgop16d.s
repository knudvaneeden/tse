/****************************************************************************\

    DlgOp16D.S

    Enhanced OpenFile command (DOS).

    Version         v2.21/26.01.00
    Copyright       (c) 1995-2003 by DiK

    Overview:

    This macro implements EditFile as a Windows 3.1 style dialog box.
    See on-line help for a more detailed description.

    Keys:       (none)

    Command Line Format:

    DlgOpDos [-s|-i|-b|-e|-l|-k|-v|-d|-r|-c|-y|-o|-j] [-t] [-x]

    where:

        none    EditFile
        -s      SaveFileAs
        -i      InsertBlock
        -b      SaveBlock
        -e      ExecMacro
        -l      LoadMacro
        -k      LoadKeyMacro
        -v      SaveKeyMacro
        -d      DeCompKeyMacro
        -r      ReCompKeyMacro
        -c      CompileDialog
        -y      DisplayResource
        -p      LoadProject
        -j      SaveProject
        -t      file must exist
        -x      do nothing, but return result

    History

    v2.21/19.11.03  adaption to TSE32 v4.2
                    + fixed load project switch
    v2.10/30.11.00  adaption to TSE32 v3.0
                    þ centered dialogs and help
                    þ added datatype for TSE session
    v2.00/24.10.96  adaption to TSE32
                    þ used to be DlgOpen
                    þ no substantial changes (was DlgOpen)
    v1.21/29.05.96  maintenance
                    þ fixed chdir (path and wildcard entered simultaneously)
    v1.20/25.03.96  maintenance
                    þ added CurrDir button
                    þ added KeyList support
                    þ added Resource support
                    þ added GotoMacDir
                    þ added GotoKbdDir
                    þ added hint lines
                    þ fixed ID_CHK_LDWILD init-bug
                    þ fixed version checking
                    þ some cleanup of source code
    v1.10/12.01.96  maintenance
                    þ some cleanup of source code
    v1.00/11.10.95  first version

\****************************************************************************/

/****************************************************************************\
    mode constants
\****************************************************************************/

constant MODE_OPEN      =  0
constant MODE_SAVEAS    =  1
constant MODE_INSERT    =  2
constant MODE_SAVEBLOCK =  3
constant MODE_EXECMACRO =  4
constant MODE_LOADMACRO =  5
constant MODE_LOADKEY   =  6
constant MODE_SAVEKEY   =  7
constant MODE_DECOMP    =  8
constant MODE_RECOMP    =  9
constant MODE_DIALOG    = 10
constant MODE_RESOURCE  = 11
constant MODE_LOADPROJ  = 12
constant MODE_SAVEPROJ  = 13

/****************************************************************************\
    global constants
\****************************************************************************/

#include "dialog.si"
#include "msgbox.si"
#include "dlgop16a.si"

/****************************************************************************\
    dialog resource
\****************************************************************************/

#include "dlgop16a.dlg"

/****************************************************************************\
    shared code
\****************************************************************************/

#include "scver.si"
#include "scrun.si"
#include "schelp.si"

/****************************************************************************\
    predefined file types
\****************************************************************************/

#include "scoptyp1.si"
#include "scoptyp2.si"

/****************************************************************************\
    global variables
\****************************************************************************/

integer resource                        // buffer id (dialog resource)
integer filebuff                        // ditto (name list)
integer dirsbuff                        // ditto (dir list)
integer typebuff                        // ditto (ext list)
integer drvsbuff                        // ditto (drive list)

integer must_exist                      // flag (file must exist)
integer dir_list                        // ditto (dir list is active)
integer mode = MODE_OPEN                // ditto (mode of operation)

integer hist = _EDIT_HISTORY_           // history used in name field

integer chk_bin                         // check (load binary)
integer chk_hex                         // ditto (display as hex list)
integer chk_chdir                       // ditto (change dir after load)
integer chk_wild                        // ditto (load wild from inside)

string dir[128]                         // saved directory
string file[128]                        // file name

string errmsg[] = "DlgOpen: Invalid command line. Using defaults."

/****************************************************************************\
    help screen
\****************************************************************************/

constant HLP_WIDTH = 80

helpdef DlgOpenHelp
    title = "Help on Open File Dialog"
    width = HLP_WIDTH
    height = 25
    y = 1

    ""
    "   This dialog is used to load and save files or macros."
    ""
    "   Summary of commands:"
    ""
    "   Ok          load or save the specified file"
    "   Cancel      close the dialog box"
    "   DriveLst    scan the available drives"
    "   Curr Dir    return to the current directory"
    ""
    "   Specifying file names:"
    "   "
    "   To quickly load a file enter its name and press <Enter>. Alternatively,"
    "   you can tab to the file list and select a file to be opened. If you"
    "   enter an incomplete filename (a name that contains * and ?), the file"
    "   list will be rescanned and will thereafter display only those entries"
    "   in the current directory which match your wildcard specification. You"
    "   can also use the Types drop down list to choose from some predefined"
    "   file types to narrow down your search. Names entered into the filename"
    "   field can include full or partial paths and a drive letter."
    "   "
    "   Changing directories and drives:"
    "   "
    "   On default the dialog displays the contents of the current directory."
    "   If you want to open a file in some other directory, enter its name and"
    "   press <Enter>. The dialog will then display the contents of the specified"
    "   directory. Alternatively, you can tab to the directory list and choose"
    "   one of the listed subdirectories. To change the current drive open the"
    "   Drives drop down list and select one of the available drives. Use the"
    "   CurrDir button, if you want to go back to the current directory after"
    "   searching a file somewhere else."
    "   "
    "   Option checks:"
    "   "
    "   Some or all of the additonal check boxes may be greyed. This means that"
    "   they are currently not available because those options are meaningless"
    "   within the current context."
    "   "
    "   Binary      load file in binary mode"
    "   HexEdit     switch to hex display after file is loaded"
    "   ChangeDir   make the directory which contains the file the current one"
    "   LoadWild    do not narrow down file list, but load all matching files"
    ""
end

/****************************************************************************\
    helper macros: changing directories
\****************************************************************************/

integer proc GotoDir( string dir )
    if ChDir(dir)
        if Length(dir) > 1 and dir[2] == ":"
            LogDrive(dir[1])
        endif
        return (TRUE)
    endif
    return (FALSE)
end

proc GotoMacDir( string ext )
    string name[128]

    name = SearchPath(ext,".")
    if Length(name) == 0
        name = SearchPath("*.mac",LoadDir()+"\mac;"+Query(TsePath))
        if Length(name)
            GotoDir(SplitPath(name,_DRIVE_|_PATH_))
        endif
    endif
end

proc GotoKbdDir( string ext )
    string name[128]

    name = SearchPath(ext,".")
    if Length(name) == 0
        name = SearchPath("*.kbd",Query(KbdPath))
        if Length(name)
            GotoDir(SplitPath(name,_DRIVE_|_PATH_))
        endif
    endif
end

/****************************************************************************\
    format directory name
\****************************************************************************/

string proc DirName()
    integer beg
    string drv[16]
    string dir[128] = CurrDir()

    if Length(dir) > 3
        dir = dir[1..Length(dir)-1]
    endif
    if Length(dir) > 24
        drv = dir[1..3]
        dir = dir[4..Length(dir)]
        repeat
            beg = Pos("\",dir)
            dir = dir[beg+1..Length(dir)]
        until Length(dir) <= 17
        dir = drv + "...\" + dir
    endif
    return (dir)
end

/****************************************************************************\
    build list of available drives
\****************************************************************************/

integer proc GetDrives( integer full )
    integer bid

    if full
        ExecDialog("DriveLst")
        drvsbuff = Val(Query(MacroCmdLine))
    else
        ExecMacro("ScanDrives")
    endif
    if drvsbuff
        bid = GotoBufferId(drvsbuff)
        lFind(GetDrive(),"gi^")
        GotoBufferId(bid)
        return (TRUE)
    endif
    return (FALSE)
end

/****************************************************************************\
    build file and directory listings
\****************************************************************************/

proc ReadDir()
    integer id, pf
    string so[6]
    string line[54], name[12], ext[3]

    so = Set(PickFileSortOrder,"f")
    pf = Set(PickFileFlags,_ADD_DIRS_)

    EmptyBuffer(filebuff)
    EmptyBuffer(dirsbuff)

    id = GotoBufferId(filebuff)

    BuildPickBuffer(file,_READ_ONLY_|_DIRECTORY_)
    Sort(_PICKSORT_)
    UnmarkBlock()

    EndFile()
    repeat
        line = DecodePickBuffer(GetText(1,23))
        line = RTrim(line[2:13])
        name = GetToken(line," ",1)
        ext  = GetToken(line," ",2)
        if Length(ext)
            name = name + "." + ext
        endif
        if CurrChar(2) & _DIRECTORY_
            KillLine()
            InsertLine(name,dirsbuff)
        else
            BegLine()
            KillToEol()
            InsertText(name)
        endif
    until not Up()

    GotoBufferId(id)

    Set(PickFileFlags,pf)
    Set(PickFileSortOrder,so)

    ExecMacro(Format("DlgPaintCntrl ",ID_LST_FILES))
    ExecMacro(Format("DlgPaintCntrl ",ID_LST_DIRS))
end

/****************************************************************************\
    initialize dialog data
\****************************************************************************/

public proc Op16DDataInit()
    string fn[128] = file

    if CheckVersion("DlgOpen",2,0)
        ExecMacro("DlgTerminate")
        return ()
    endif

    if not GetDrives(TRUE)
        ExecMacro("DlgTerminate")
        return()
    endif

    if mode in MODE_EXECMACRO,MODE_LOADMACRO
        GotoMacDir("*.mac")
    elseif mode in MODE_DIALOG
        GotoMacDir("*.d")
    elseif mode in MODE_RESOURCE
        GotoMacDir("*.dlg")
    elseif mode in MODE_LOADKEY,MODE_SAVEKEY,MODE_DECOMP
        GotoKbdDir("*.kbd")
    elseif mode in MODE_RECOMP
        GotoKbdDir("*.k")
    elseif mode in MODE_LOADPROJ,MODE_SAVEPROJ
        file = "*.tpr"
    else
        file = "*.*"
    endif
    ReadDir()
    if file == "*.*"
        file = fn
    endif

    ExecMacro(Format("DlgSetTitle ",ID_EDT_NAME," ",file))
    ExecMacro(Format("DlgSetTitle ",ID_TXT_CURR," ",DirName()))
    ExecMacro(Format("DlgSetData ",ID_EDT_NAME," ",hist))
    ExecMacro(Format("DlgSetData ",ID_LST_FILES," ",filebuff))
    ExecMacro(Format("DlgSetData ",ID_LST_DIRS," ",dirsbuff))
    ExecMacro(Format("DlgSetData ",ID_CMB_TYPES," ",typebuff))
    ExecMacro(Format("DlgSetData ",ID_CMB_DRIVES," ",drvsbuff))
    ExecMacro(Format("DlgSetData ",ID_CHK_CHDIR," ",Query(PickFileChangesDir)))
    ExecMacro(Format("DlgSetData ",ID_CHK_LDWILD," ",Query(LoadWildFromInside)))

    if mode <> MODE_OPEN

        ExecMacro(Format("DlgSetEnable ",ID_CHK_BIN," ",0))
        ExecMacro(Format("DlgSetEnable ",ID_CHK_HEX," ",0))
        ExecMacro(Format("DlgSetEnable ",ID_CHK_LDWILD," ",0))

        if mode in MODE_SAVEAS,MODE_DIALOG,MODE_RESOURCE

            case mode
                when MODE_SAVEAS
                    ExecMacro("DlgSetTitle 0 Save File As")
                when MODE_DIALOG
                    ExecMacro("DlgSetTitle 0 Compile Dialog Resource")
                when MODE_RESOURCE
                    ExecMacro("DlgSetTitle 0 Display Dialog Resource")
            endcase
        else

            ExecMacro(Format("DlgSetEnable ",ID_CHK_CHDIR," ",0))

            case mode
                when MODE_INSERT
                    ExecMacro("DlgSetTitle 0 Insert File As Block")
                when MODE_SAVEBLOCK
                    ExecMacro("DlgSetTitle 0 Save Block To File")
                when MODE_EXECMACRO
                    ExecMacro("DlgSetTitle 0 Execute Macro")
                when MODE_LOADMACRO
                    ExecMacro("DlgSetTitle 0 Load Macro")
                when MODE_LOADKEY
                    ExecMacro("DlgSetTitle 0 Load Keyboard Macros")
                when MODE_SAVEKEY
                    ExecMacro("DlgSetTitle 0 Save Keyboard Macros")
                when MODE_DECOMP
                    ExecMacro("DlgSetTitle 0 Decompile Keyboard Macros")
                when MODE_RECOMP
                    ExecMacro("DlgSetTitle 0 Recompile Key Listings")
                when MODE_LOADPROJ
                    ExecMacro("DlgSetTitle 0 Load Project")
                when MODE_SAVEPROJ
                    ExecMacro("DlgSetTitle 0 Save Project")
            endcase

        endif
    endif
end

/****************************************************************************\
    retrieve dialog data
\****************************************************************************/

integer proc GetCheck( integer id )
    ExecMacro(Format("DlgGetData ",id))
    return (Val(Query(MacroCmdLine)))
end

public proc Op16DDataDone()
    chk_bin   = GetCheck(ID_CHK_BIN)
    chk_hex   = GetCheck(ID_CHK_HEX)
    chk_chdir = GetCheck(ID_CHK_CHDIR)
        and (mode in MODE_OPEN,MODE_SAVEAS,MODE_DIALOG,MODE_RESOURCE)

    ExecMacro(Format("DlgGetTitle ",ID_EDT_NAME))
    if dir <> CurrDir()
        file = ExpandPath(Query(MacroCmdLine))
    endif
end

/****************************************************************************\
    control response functions
    þ   IdCmbTypes      set wildcard according to file type
    þ   IdCmbDrives     change current drive and list files
    þ   IdLstFiles      update edit control with current filename
    þ   IdLstDirs       change current directory and list files
    þ   IdBtnDrives     rebuild list of available drives
\****************************************************************************/

proc IdCmbTypes()
    integer bid

    bid = GotoBufferId(typebuff)
    file = "*." + RTrim(GetText(1,3))
    GotoBufferId(bid)
    ExecMacro(Format("DlgSetTitle ",ID_EDT_NAME," ",file))
    ReadDir()
end

proc IdCmbDrives()
    integer rc, bid
    string drive[1]

    bid = GotoBufferId(drvsbuff)
    drive = GetText(1,1)
    rc = ChDir(drive+":.")
    if rc
        LogDrive(drive)
    elseif drive in "a","b"
        Alarm()
        ExecDialog(Format(
            "MsgBox ",
            Chr(MB_OK),
            Chr(MB_ERROR),
            Chr(CNTRL_CTEXT),"Drive is empty! Insert floppy disk!"
        ))
        lFind(GetDrive(),"gi^")
    else
        Alarm()
        ExecDialog(Format(
            "MsgBox ",
            Chr(MB_OK),
            Chr(MB_ERROR),
            Chr(CNTRL_CTEXT),"Drive does not exist! Rescan drives!"
        ))
    endif
    GotoBufferId(bid)
    if rc
        ExecMacro(Format("DlgSetTitle ",ID_TXT_CURR," ",DirName()))
        IdCmbTypes()
    endif
end

proc IdLstFiles()
    integer bid

    bid = GotoBufferId(filebuff)
    file = GetText(1,CurrLineLen())
    GotoBufferId(bid)
    ExecMacro(Format("DlgSetTitle ",ID_EDT_NAME," ",file))
end

proc IdLstDirs()
    integer bid

    bid = GotoBufferId(dirsbuff)
    ChDir(GetText(1,CurrLineLen()))
    GotoBufferId(bid)
    ExecMacro(Format("DlgSetTitle ",ID_TXT_CURR," ",DirName()))
    IdCmbTypes()
end

proc IdBtnDrives()
    GetDrives(FALSE)
    ExecMacro(Format("DlgPaintCntrl ",ID_CMB_DRIVES))
    IdCmbDrives()
end

proc IdBtnCurrDir()
    integer bid

    if GotoDir(dir)
        bid = GotoBufferId(drvsbuff)
        lFind(dir[1],"gi^")
        GotoBufferId(bid)
        ExecMacro(Format("DlgPaintCntrl ",ID_CMB_DRIVES))
        ExecMacro(Format("DlgSetTitle ",ID_TXT_CURR," ",DirName()))
        IdCmbTypes()
    else
        ExecDialog(Format(
            "MsgBox ",
            Chr(MB_OK),
            Chr(MB_ERROR),
            Chr(CNTRL_CTEXT),"Startup directory does not exists!"
        ))
    endif
end

/****************************************************************************\
    handle Ok button
\****************************************************************************/

proc IdOk()
    integer tokens
    string dir[254], name[254]

    // first check for an ok within the directory list (ChDir)

    if dir_list
        IdLstDirs()
        ExecMacro(Format("DlgExecCntrl ",ID_LST_DIRS))
        return ()
    endif

    // else, get the specified file name

    ExecMacro(Format("DlgGetTitle ",ID_EDT_NAME))
    file = Trim(Query(MacroCmdLine))

    // check for an empty line

    if Length(file) == 0
        ExecMacro(Format("DlgExecCntrl ",ID_EDT_NAME))
        Alarm()
        return ()
    endif

    // check for wildcards and narrow down file list

    if Pos("*",file) or Pos("?",file)
        if Pos(":",file) or Pos("\",file)
            tokens = NumTokens(file,"\")
            if tokens > 1
                name = GetToken(file,"\",tokens)
                dir = SubStr(file,1,Pos(name,file)-1)
            else
                name = GetToken(file,":",2)
                dir = GetToken(file,":",1) + ":"
            endif
            file = name
            if GotoDir(dir)
                file = name
                ExecMacro(Format("DlgSetTitle ",ID_EDT_NAME," ",file))
            else
                Alarm()
                ExecDialog(Format(
                    "MsgBox ",
                    Chr(MB_OK),
                    Chr(MB_ERROR),
                    Chr(CNTRL_CTEXT),"Directory does not exist!"
                ))
                ExecMacro(Format("DlgExecCntrl ",ID_EDT_NAME))
                return()
            endif
        endif
        chk_wild  = GetCheck(ID_CHK_LDWILD) and mode == MODE_OPEN
        if chk_wild
            ExecMacro(Format("DlgTerminate ",ID_OK))
        else
            ReadDir()
            ExecMacro(Format("DlgExecCntrl ",ID_EDT_NAME))
        endif
        return ()
    endif

    // if the file name is a directory, let's go there

    if Length(file) == 2 and file[2] == ":"
        file = file + "."
    endif

    if FileExists(file) & _DIRECTORY_
        GotoDir(file)
        IdCmbTypes()
        ExecMacro(Format("DlgExecCntrl ",ID_EDT_NAME))
        ExecMacro(Format("DlgSetTitle ",ID_TXT_CURR," ",DirName()))
        return ()
    endif

    // must the file exist ?

    if must_exist and FileExists(file) == 0
        ExecDialog(Format(
            "MsgBox ",
            Chr(MB_OK),
            Chr(MB_ERROR),
            Chr(CNTRL_CTEXT),"The file does not exists!"
        ))
        return ()
    endif

    // otherwise, say bye and go home

    ExecMacro(Format("DlgTerminate ",ID_OK))
end

/****************************************************************************\
    message response functions
    þ   AnchorList      anchor search in type and drive lists
    þ   DropDown        change size of name history list
    þ   SetFocus        ok in dir list and open type drive lists
    þ   KillFocus       handle ok's in directory listing
    þ   CloseUp         move focus to list boxes
    þ   SelChanged      handle selection changes in file list
    þ   DblClick        double clicks within list boxes
    þ   BtnDown         push button actions
\****************************************************************************/

public proc Op16DAnchorList()
    if CurrChar(POS_ID) in ID_CMB_TYPES,ID_CMB_DRIVES
        Set(MacroCmdLine,"1")
    endif
end

public proc Op16DDropDown()
    integer top, len, lft, wdt
    string cmd[64] = Query(MacroCmdLine)

    if CurrChar(POS_ID) == ID_EDT_NAME
        lft = Val(GetToken(cmd," ",1)) - 14
        top = Val(GetToken(cmd," ",2))
        wdt = Val(GetToken(cmd," ",3)) + 15
        len = Val(GetToken(cmd," ",4))
        Set(MacroCmdLine,Format(lft," ",top," ",wdt," ",len))
    endif
end

public proc Op16DSetFocus()
    if CurrChar(POS_ID) <> ID_OK
        dir_list = FALSE
    endif
    if CurrChar(POS_ID) == ID_LST_FILES
        IdLstFiles()
    endif
end

public proc Op16DKillFocus()
    dir_list = CurrChar(POS_ID) == ID_LST_DIRS
end

public proc Op16DSelChanged()
    case CurrChar(POS_ID)
        when ID_LST_FILES   IdLstFiles()
        when ID_CMB_TYPES   IdCmbTypes()
        when ID_CMB_DRIVES  IdCmbDrives()
    endcase
end

public proc Op16DDblClick()
    case CurrChar(POS_ID)
        when ID_LST_FILES   IdOk()
        when ID_LST_DIRS    IdLstDirs()
    endcase
end

public proc Op16DBtnDown()
    case CurrChar(POS_ID)
        when ID_OK          IdOk()
        when ID_BTN_DRIVES  IdBtnDrives()
        when ID_BTN_CURRDIR IdBtnCurrDir()
        when ID_HELP        InitHelp(HLP_WIDTH) QuickHelp(DlgOpenHelp)
    endcase
end

/****************************************************************************\
    main program (helper)
\****************************************************************************/

integer proc Test( integer new_mode, integer new_hist, string ext )
    if mode
        mode = MODE_OPEN
        hist = _EDIT_HISTORY_
        file = SplitPath(CurrFilename(),_NAME_|_EXT_)
        Warn(errmsg)
        return (FALSE)
    endif
    mode = new_mode
    hist = new_hist
    if Length(ext)
        file = ext
    endif
    return (TRUE)
end

proc SaveFileAs()
    if ChangeCurrFilename(file)
        SaveFile()
    endif
end

proc SaveKbdMacro()
    PushKey(<Enter>)
    PushKeyStr(file)
    SaveKeyMacro()
end

proc LoadFileFromDisk()
    integer lwfi

    lwfi = Set(LoadWildFromInside,chk_wild)
    if chk_bin
        file = Format("-b",iif(chk_hex,16,64)," ",file)
    endif
    if EditFile(file,_DONT_PROMPT_)
        if chk_hex
            DisplayMode(_DISPLAY_HEX_)
        endif
    else
        Alarm()
        ExecDialog(Format(
            "MsgBox ",
            Chr(MB_OK),
            Chr(MB_ERROR),
            Chr(CNTRL_CTEXT),"Open error: ",file
        ))
    endif
    Set(LoadWildFromInside,lwfi)
end

/****************************************************************************\
    main program
\****************************************************************************/

proc main()
    integer i, rc
    integer run = TRUE
    integer userbuff = GetBufferId()
    string cmd[16] = Query(MacroCmdLine)

    // init global vars

    PushBlock()

    dir = CurrDir()
    file = SplitPath(CurrFilename(),_NAME_|_EXT_)

    // check command line

    for i = 1 to NumTokens(cmd," ")
        case GetToken(cmd," ",i)
            when "-x"   run = FALSE
            when "-t"   must_exist = TRUE
            when "-s"   Test(MODE_SAVEAS,_EDIT_HISTORY_,"")
            when "-i"   Test(MODE_INSERT,_EDIT_HISTORY_,"")
            when "-b"   Test(MODE_SAVEBLOCK,_EDIT_HISTORY_,"")
            when "-e"   Test(MODE_EXECMACRO,_EXECMACRO_HISTORY_,"*.mac")
            when "-l"   Test(MODE_LOADMACRO,_LOADMACRO_HISTORY_,"*.mac")
            when "-k"   Test(MODE_LOADKEY,_KEYMACRO_HISTORY_,"*.kbd")
            when "-v"   Test(MODE_SAVEKEY,_KEYMACRO_HISTORY_,"*.kbd")
            when "-d"   Test(MODE_DECOMP,_KEYMACRO_HISTORY_,"*.kbd")
            when "-r"   Test(MODE_RECOMP,GetFreeHistory("ReComp:files"),"*.k")
            when "-c"   Test(MODE_DIALOG,GetFreeHistory("DLG:txt"),"*.d")
            when "-y"   Test(MODE_RESOURCE,GetFreeHistory("DLG:bin"),"*.dlg")
            when "-p"   Test(MODE_LOADPROJ,GetFreeHistory("UI:Sessions"),"*.tpr")
            when "-j"   Test(MODE_SAVEPROJ,GetFreeHistory("UI:Sessions"),"*.tpr")
            otherwise   Warn(errmsg) break
        endcase
    endfor

    // allocate work space and exec dialog

    filebuff = CreateTempBuffer()
    dirsbuff = CreateTempBuffer()
    typebuff = CreateTempBuffer()

    if filebuff and dirsbuff and typebuff
        if mode in MODE_EXECMACRO, MODE_LOADMACRO
            rc = InsertData(MacroTypes)
        elseif mode in MODE_LOADKEY, MODE_SAVEKEY
            rc = InsertData(KeyTypes)
        elseif mode == MODE_RECOMP
            rc = InsertData(ListTypes)
        elseif mode == MODE_DIALOG
            rc = InsertData(DialogTypes)
        elseif mode == MODE_RESOURCE
            rc = InsertData(ResourceTypes)
        elseif mode in MODE_LOADPROJ, MODE_SAVEPROJ
            rc = InsertData(SessionTypes)
        else
            rc = InsertData(FileTypes)
        endif
        if rc
            resource = CreateTempBuffer()
            rc = resource and InsertData(dlgop16a) and ExecDialog("dialog op16d")
        endif
    endif

    AbandonFile(resource)
    AbandonFile(typebuff)
    AbandonFile(dirsbuff)
    AbandonFile(filebuff)

    GotoBufferId(userbuff)
    PopBlock()

    // check return code and open/save file

    if rc
        rc = Val(Query(MacroCmdLine)) == ID_OK
        if not (rc and chk_chdir)
            GotoDir(dir)
        endif
    else
        Warn("DlgOpen: Error executing open dialog")
    endif

    if rc
        AddHistoryStr(file,hist)
        if run
            case mode
                when MODE_OPEN          LoadFileFromDisk()
                when MODE_SAVEAS        SaveFileAs()
                when MODE_INSERT        InsertFile(file)
                when MODE_SAVEBLOCK     SaveBlock(file)
                when MODE_EXECMACRO     ExecMacro(file)
                when MODE_LOADMACRO     LoadMacro(file)
                when MODE_LOADKEY       LoadKeyMacro(file)
                when MODE_SAVEKEY       SaveKbdMacro()
                // otherwise
                // let parent handle event (same as -x switch)
            endcase
        endif
    endif

    // purge self

    PurgeMacro(CurrMacroFilename())
    UpdateDisplay(_HELPLINE_REFRESH_)
end

