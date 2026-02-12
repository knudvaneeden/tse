/****************************************************************************\

    Install.S

    Install windows shell extensions for TSE.

    Overview:

    This macro builds and installs various shell extensions which
    integrate TSE into the windows shell (NT and 95/98).

    Keys:   (none)

    Usage notes:

    This macro will be built and executed by install.bat. There is
    no reason to compile or execute it manually.

    !!! WARNING !!!

    Changing this macro requires some fundamental knowledge about
    the windows application programming interface and especially
    about inf files and the windows registry. Changing the macro
    without proper knowledge could disable the operating system,
    lead to data loss or could force you to re-install the system
    from scratch.

    Version         v2.00/19.04.99
    Copyright       (c) 1997-99 by DiK

    History
    v2.00/19.04.99  new for version 2.0

\****************************************************************************/

/****************************************************************************\
    global variables
\****************************************************************************/

string InfFileName[] = "TSESHEXT.INF" // ! do _not_ change INF extension !

string StateFileName[255] = "tsestate.dat"
string TextFileExts[255]
string EditorName[255]
string EditorPath[255]

string InstCmd[255]                     // inf install command
string UninstCmd[255]                   // inf un-install command

integer tmp_buff                        // buffer id, work space
integer inf_buff                        // ditto, inf file
integer ext_buff                        // ditto, text file extensions

integer terminated                      // close command invoked

integer inst_textext = TRUE             // flag, install text extensions
integer inst_unknown = TRUE             // ditto, hook unknow extension
integer inst_restore = TRUE             // ditto, load saved editor states
integer inst_salpack = TRUE             // ditto, sal macro package
integer inst_dialogs = FALSE            // ditto, dialogs (dik)
integer inst_prtpack = TRUE             // ditto, printer package

integer inf_installed                   // flag, inf package already installed
integer del_inf_file = TRUE             // flag, delete inf file when finished

integer state_name_changed              // flag, state-stub must be chagned

/****************************************************************************\
    help package
\****************************************************************************/

#include "ShowHelp.SI"

/****************************************************************************\
    windows registry api
\****************************************************************************/

#include "RegApi.SI"

string InfFilePath[] = "inffile\shell\install\command"
string InstPath[] = "Software\Microsoft\Windows\CurrentVersion\Uninstall\TseShExt"
string RegValue[] = "UninstallString"

proc ReplaceEnvVars(var string ExpandStr)
    string EnvStr[255]

    GotoBufferId(tmp_buff)
    EmptyBuffer()
    AddLine(ExpandStr)
    while lFind("\c{%{.+}%}","gx")
        MarkFoundText(2)
        EnvStr = GetEnvStr(GetMarkedText())
        MarkFoundText(1)
        KillBlock()
        InsertText(EnvStr)
    endwhile
    if lFind("\c%1","gx")
        KillToEol()
    endif
    ExpandStr = GetText(1,CurrLineLen())
end

proc QueryRegInfo()
    integer code, hKey, ValType, DataSize

    // get installation status and uninstall command

    code = RegOpenKeyExA(HKEY_LOCAL_MACHINE,InstPath,0,KEY_QUERY_VALUE,hKey)
    if code == ERROR_SUCCESS
        DataSize = 255
        code = RegQueryValueExA(hKey,RegValue,0,ValType,UninstCmd,DataSize)
        if code == ERROR_SUCCESS and ValType == REG_SZ
            PokeWord(Addr(UninstCmd),DataSize)
            inf_installed = TRUE
        endif
        RegCloseKey(hKey)
    endif

    // get install command

    code = RegOpenKeyExA(HKEY_CLASSES_ROOT,InfFilePath,0,KEY_QUERY_VALUE,hKey)
    if code == ERROR_SUCCESS
        DataSize = 255
        code = RegQueryValueExA(hKey,"",0,ValType,InstCmd,DataSize)
        if code == ERROR_SUCCESS and (ValType == REG_SZ or ValType == REG_EXPAND_SZ)
            PokeWord(Addr(InstCmd),DataSize)
            ReplaceEnvVars(InstCmd)
        endif
        RegCloseKey(hKey)
    endif
end

/****************************************************************************\
    inf data

    Configurable sections use their first column as a tag. It
    indicates the package type. A second implicit tag is used
    to determine, whether a line pertains to shell-print command.
    Each configurable sections _must_ end with a terminator tag.

    The following tags are currently used

    T == basic text file editing
    U == unknown file type
    S == state file loading
    M == sal macro package
    D == dik dialogs
    P == printer package (basic files)
    ! == required line, must not be deleted
    # == terminator tag (or any other unused character)

    The implicit print tag is: \Shell\Print\command

    Sections 02, 04 and 06 are configurable.
    The implicit print tag is only present in section 06.

    The remaining configuration is done in-code in routine Build.
\****************************************************************************/

datadef Section_01
    ';==========================================================='
    '; Windows 95/98/NT Shell Extensions for TSE32'
    ';'
    '; Version v2.00/14.04.99 added installation program'
    '; Version v1.03/01.09.98 added unknown extensions'
    '; Version v1.02/26.08.98 fixed some bugs <sigh>'
    '; Version v1.01/20.08.98 finishing touches'
    '; Version v1.00/18.12.97 initial version'
    ';'
    '; see end of file for user definable sections'
    ';==========================================================='
    ''
    ';==========================================================='
    '; general install and un-install info'
    ';==========================================================='
    ''
    '[version]'
    'signature="$CHICAGO$"'
    ''
    '[DefaultInstall]'
    'CopyFiles = TseShExt.Files'
    'AddReg    = TseShExt.Reg, TseShExt.RegUser, TseShExt.Uninstall'
    ''
    '[DefaultUnInstall]'
    'DelFiles  = TseShExt.Files'
    'DelReg    = TseShExt.UnReg, TseShExt.UnRegUser, TseShExt.Uninstall'
    ''
    '[DefaultInstall.ntx86]'
    'CopyFiles = TseShExt.Files'
    'AddReg    = TseShExt.Reg, TseShExt.RegUser, TseShExt.UninstallNt'
    ''
    '[DefaultUnInstall.ntx86]'
    'DelFiles  = TseShExt.Files'
    'DelReg    = TseShExt.UnReg, TseShExt.UnRegUser, TseShExt.UninstallNt'
    ''
    '[DestinationDirs]'
    'TseShExt.Files = 11,"%ExtPath%"'
    ''
    '[SourceDisksNames]'
    '1 = "%ExtName%",,'
    ''
end

datadef Section_02
    '!TseShExt.Inf'
    '!Tse32.Ico'
    'STse32P.Ico'
    'MTse32S.Ico'
    'MTse32M.Ico'
    'DTse32D.Ico'
    'PShPrint.Mac'
    'SShState.Mac'
    'MShCmpile.Mac'
    'MShDebug.Mac'
    'MTemplate.S'
    '!'
    '#'
end

datadef Section_03
    ''
    ';==========================================================='
    '; uninstall settings'
    ';==========================================================='
    ''
    '[TseShExt.Uninstall]'
    ''
    'HKLM,%TseUndo%'
    'HKLM,%TseUndo%,DisplayName,,"%ExtName%"'
    'HKLM,%TseUndo%,UninstallString,,"%10%\rundll.exe setupx.dll,InstallHinfSection DefaultUninstall 132 %11%\%ExtPath%\TseShExt.Inf"'
    ''
    '[TseShExt.UninstallNt]'
    ''
    'HKLM,%TseUndo%'
    'HKLM,%TseUndo%,DisplayName,,"%ExtName%"'
    'HKLM,%TseUndo%,UninstallString,,"rundll32.exe syssetup.dll,SetupInfObjectInstallAction DefaultUninstall 132 %11%\%ExtPath%\TseShExt.Inf"'
    ''
    ';==========================================================='
    '; registry updates, un-installing'
    ';==========================================================='
    ''
    '[TseShExt.UnReg]'
    ''
end

datadef Section_04
    'UHKCR,unknown\Shell\Open'
    'UHKCR,unknown\Shell\Open As Binary'
    'THKCR,TseTextFile'
    'SHKCR,TseProject'
    'MHKCR,TseCompiledMacro'
    'MHKCR,TseMacro'
    'MHKCR,TseMacroInclude'
    'MHKCR,TseUserInterface'
    'DHKCR,TseDialogScript'
    'DHKCR,TseDialogResource'
    '!'
    'SHKCR,.TSESTATE_EXTENSION'
    'MHKCR,.mac'
    'MHKCR,.s'
    'MHKCR,.si'
    'MHKCR,.ui'
    'DHKCR,.d'
    'DHKCR,.dlg'
    '!'
    '#'
end

datadef Section_05
    ''
    ';==========================================================='
    '; registry updates, installing (DO NOT CHANGE)'
    ';'
    '; pre-defined file types and associations'
    ';==========================================================='
    ''
    '[TseShExt.Reg]'
    ''
end

datadef Section_06
    'UHKCR,unknown\Shell\Open\command,,,"%TsePath%%TseName% ""%1"""'
    'UHKCR,unknown\Shell\Open As Binary\command,,,"%TsePath%%TseName% -h -b16 ""%1"""'
    'U'
    'THKCR,TseTextFile,,,"TSE Text File"'
    'THKCR,TseTextFile\DefaultIcon,,,"%11%\%ExtPath%\tse32.ico,0"'
    'THKCR,TseTextFile\Shell\Open\command,,,"%TsePath%%TseName% ""%1"""'
    'THKCR,TseTextFile\Shell\Print\command,,,"%TsePath%%TseName% -e%11%\%ExtPath%\ShPrint ""%1"""'
    'T'
    'SHKCR,TseProject,,,"TSE Project"'
    'SHKCR,TseProject\DefaultIcon,,,"%11%\%ExtPath%\tse32p.ico,0"'
    'SHKCR,TseProject\Shell\Open\command,,,"%TsePath%%TseName% -e%11%\%ExtPath%\ShState ""%1"""'
    'S'
    'MHKCR,TseCompiledMacro,,,"TSE Compiled Macro"'
    'MHKCR,TseCompiledMacro\DefaultIcon,,,"%11%\%ExtPath%\tse32m.ico,0"'
    'MHKCR,TseCompiledMacro\Shell\Open\command,,,"%TsePath%%TseName% -e""%1"""'
    'M'
    'MHKCR,TseMacro,,,"TSE Macro"'
    'MHKCR,TseMacro\DefaultIcon,,,"%11%\%ExtPath%\tse32s.ico,0"'
    'MHKCR,TseMacro\Shell\Open\command,,,"%TsePath%%TseName% ""%1"""'
    'MHKCR,TseMacro\Shell\Print\command,,,"%TsePath%%TseName% -e%11%\%ExtPath%\ShPrint ""%1"""'
    'MHKCR,TseMacro\Shell\Debug\command,,,"%TsePath%%TseName% -e%11%\%ExtPath%\ShDebug ""%1"""'
    'MHKCR,TseMacro\Shell\Compile\command,,,"%TsePath%%TseName% -e%11%\%ExtPath%\ShCmpile ""%1"""'
    'M'
    'MHKCR,TseMacroInclude,,,"TSE Macro Include File"'
    'MHKCR,TseMacroInclude\DefaultIcon,,,"%11%\%ExtPath%\tse32s.ico,0"'
    'MHKCR,TseMacroInclude\Shell\Open\command,,,"%TsePath%%TseName% ""%1"""'
    'MHKCR,TseMacroInclude\Shell\Print\command,,,"%TsePath%%TseName% -e%11%\%ExtPath%\ShPrint ""%1"""'
    'M'
    'MHKCR,TseUserInterface,,,"TSE User Interface"'
    'MHKCR,TseUserInterface\DefaultIcon,,,"%11%\%ExtPath%\tse32s.ico,0"'
    'MHKCR,TseUserInterface\Shell\Open\command,,,"%TsePath%%TseName% ""%1"""'
    'MHKCR,TseUserInterface\Shell\Print\command,,,"%TsePath%%TseName% -e%11%\%ExtPath%\ShPrint ""%1"""'
    'MHKCR,TseUserInterface\Shell\BurnIn,,,"&Burn In"'
    'MHKCR,TseUserInterface\Shell\BurnIn\command,,,"%TsePath%sc32.exe -b%TsePath%%TseName% ""%1"""'
    'M'
    'DHKCR,TseDialogScript,,,"TSE Dialog Script"'
    'DHKCR,TseDialogScript\DefaultIcon,,,"%11%\%ExtPath%\tse32d.ico,0"'
    'DHKCR,TseDialogScript\Shell\Open\command,,,"%TsePath%%TseName% -ede ""%1"""'
    'DHKCR,TseDialogScript\Shell\Print\command,,,"%TsePath%%TseName% -e%11%\%ExtPath%\ShPrint ""%1"""'
    'DHKCR,TseDialogScript\Shell\Compile\command,,,"%TsePath%%TseName% -edc ""%1"""'
    'D'
    'DHKCR,TseDialogResource,,,"TSE Dialog Resource"'
    'DHKCR,TseDialogResource\DefaultIcon,,,"%11%\%ExtPath%\tse32d.ico,0"'
    'DHKCR,TseDialogResource\Shell\View\command,,,"%TsePath%%TseName% -edd ""%1"""'
    'D'
    'SHKCR,.TSESTATE_EXTENSION,,,"TseProject"'
    'MHKCR,.mac,,,"TseCompiledMacro"'
    'MHKCR,.s,,,"TseMacro"'
    'MHKCR,.si,,,"TseMacroInclude"'
    'MHKCR,.ui,,,"TseUserInterface"'
    'DHKCR,.d,,,"TseDialogScript"'
    'DHKCR,.dlg,,,"TseDialogResource"'
    'M'
    'MHKCR,.s\ShellNew,"FileName",,"%11%\%ExtPath%\TEMPLATE.S"'
    'M'
    '#'
end

datadef Section_07
    ''
    ';==========================================================='
    '; additional user definable file associations'
    ';==========================================================='
    ''
end

datadef Section_08
    ''
    ';==========================================================='
    '; string data'
    ';==========================================================='
    ''
    '[Strings]'
    ''
    ';-----------------------------------------------------------'
    '; location of editor and name of editor executable'
    ';-----------------------------------------------------------'
    ''
end

datadef Section_09
    ''
    ';-----------------------------------------------------------'
    '; package names'
    ';-----------------------------------------------------------'
    ''
    'ExtPath = "TseShExt"'
    'ExtName = "Tse Shell Extensions"'
    'TseUndo = "Software\Microsoft\Windows\CurrentVersion\Uninstall\TseShExt"'
    ''
    ';==========================================================='
    '; end-of-file'
    ';==========================================================='
end

/****************************************************************************\
    build inf file
\****************************************************************************/

//  assume: BufferId == tmp_buff

proc RemoveOptions()
    integer keep_this_line

    BegFile()
    loop
        case CurrChar()
            when Asc("T")   keep_this_line = inst_textext
            when Asc("P")   keep_this_line = inst_prtpack
            when Asc("U")   keep_this_line = inst_unknown
            when Asc("S")   keep_this_line = inst_restore
            when Asc("M")   keep_this_line = inst_salpack
            when Asc("D")   keep_this_line = inst_dialogs
            when Asc("!")   keep_this_line = TRUE
            otherwise
                KillLine()
                break
        endcase
        if keep_this_line
            DelChar()
            Down()
        else
            KillLine()
        endif
    endloop
end

//  assume: BufferId == tmp_buff

proc RemovePrinterPack()
    if not inst_prtpack
        while lFind("\Shell\Print\command","gi")
            KillLine()
        endwhile
    endif
end

//  assume: BufferId == tmp_buff or BufferId == ext_buff

proc GetTempBuffer()
    MarkLine(1,NumLines())
    GotoBufferId(inf_buff)
    CopyBlock()
    EndFile()
end

//  assume: nothing

proc Build()
    GotoBufferId(inf_buff)
    EmptyBuffer()
    InsertData(Section_01)
    EndFile()
    BegLine()

    AddLine("[TseShExt.Files]")
    GotoBufferId(tmp_buff)
    EmptyBuffer()
    InsertData(Section_02)
    RemoveOptions()
    GetTempBuffer()

    AddLine("[SourceDisksFiles]")
    GotoBufferId(tmp_buff)
    lReplace("^{.#}$","\1 = 1","gnx")
    GetTempBuffer()

    GotoBufferId(inf_buff)
    InsertData(Section_03)
    EndFile()
    BegLine()

    GotoBufferId(tmp_buff)
    EmptyBuffer()
    InsertData(Section_04)
    RemoveOptions()
    GetTempBuffer()

    GotoBufferId(inf_buff)
    InsertData(Section_05)
    EndFile()
    BegLine()

    GotoBufferId(tmp_buff)
    EmptyBuffer()
    InsertData(Section_06)
    RemoveOptions()
    RemovePrinterPack()
    GetTempBuffer()

    GotoBufferId(inf_buff)
    InsertData(Section_07)
    EndFile()
    BegLine()

    if inst_textext
        AddLine("[TseShExt.UnRegUser]")
        GotoBufferId(ext_buff)
        lReplace("^","HKCR,","gnx")
        GetTempBuffer()
        AddLine()
        AddLine("[TseShExt.RegUser]")
        GotoBufferId(ext_buff)
        lReplace("$",',,,"TseTextFile"',"gnx")
        GetTempBuffer()
        AddLine()
    endif

    GotoBufferId(inf_buff)
    InsertData(Section_08)
    EndFile()
    BegLine()

    AddLine('TseName = "' + EditorName + '"')
    AddLine('TsePath = "' + EditorPath + '"')
    AddLine()

    GotoBufferId(inf_buff)
    InsertData(Section_09)
    EndFile()
    BegLine()

    if inst_restore
        lReplace(".TSESTATE_EXTENSION",SplitPath(StateFileName,_EXT_),"gn")
    endif

    MarkLine(1,NumLines())
    SaveBlock(InfFileName,_OVERWRITE_)
end

/****************************************************************************\
    build only
\****************************************************************************/

proc BuildOnly()
    del_inf_file = FALSE
    Build()
    MsgBox("Information","INF file created",0)
end

/****************************************************************************\
    install
\****************************************************************************/

proc EditStateStub()
    string tag[128] = 'string state_filename[] = "'

    if EditFile("SHSTATE.S",_DONT_PROMPT_)
        if lFind(tag,"gi")
            BegLine()
            KillToEol()
            InsertText(tag)
            InsertText(StateFileName)
            InsertText('"')
            SaveFile()
        endif
        QuitFile()
    endif
end

proc Install()
    string Cmd[255]

    Cmd = CurrDir() + InfFileName

    if Pos(" ",Cmd)
        MsgBox("Error","Path to inf file must not include spaces",0)
        return()
    endif

    Cmd = InstCmd + Cmd

    Build()
    if inst_restore and state_name_changed
        EditStateStub()
    endif
    Dos("sc32 SH*.S",_DONT_PROMPT_)
    Dos(Cmd,_DONT_CLEAR_)
    Dos("del SH*.MAC",_DONT_PROMPT_)
    QueryRegInfo()
end

/****************************************************************************\
    uninstall the package
\****************************************************************************/

proc UnInstall()
    inf_installed = FALSE
    Dos(UninstCmd,_DONT_CLEAR_)
end

/****************************************************************************\
    get text file extensions
\****************************************************************************/

integer proc BuildExtBuffer(string TxtExt)
    integer I, N
    string ext[255]

    GotoBufferId(ext_buff)
    EmptyBuffer()

    N = NumTokens(TxtExt,",")

    for I = 1 to N
        ext = GetToken(TxtExt,",",I)
        if Length(ext)
            if ext[1] <> "."
                ext = "." + ext
            endif
            AddLine(ext)
        endif
    endfor

    if NumLines() == 0
        MsgBox("Error","no valid extensions sepcified",0)
        return(FALSE)
    endif

    return(TRUE)
end

proc GetTxtExt()
    string new_ext[255] = TextFileExts

    while Ask("Extensions designating TSE text files (separate by commas)",new_ext)
        if BuildExtBuffer(new_ext)
            TextFileExts = new_ext
            break
        endif
    endwhile
end

/****************************************************************************\
    get advanced file options
\****************************************************************************/

proc GetState()
    integer code
    string path[255] = StateFileName

    code = MsgBox("Warning",
        "This requires changing STATE.S" + Chr(13) + "Continue?", _YES_NO_)
    if code <> 1
        return()
    endif
    Ask("Filename used to store editor states (default is TSESTATE.DAT)",path)
    if SplitPath(path,_EXT_) == ""
        Alarm()
        MsgBox("Error","State files must have an extension",0)
    else
        state_name_changed = TRUE
        StateFileName = Lower(path)
    endif
end

proc GetPath()
    integer attr
    string path[255] = EditorPath

    Ask("Name of folder where to find TSE (default is C:\TSE32\)",path)
    attr = FileExists(path)
    if attr == 0 or (attr & _DIRECTORY_) == 0
        Alarm()
        MsgBox("Error","Path does not exist",0)
    else
        if path[Length(path)] <> "\"
            path = path + "\"
        endif
        EditorPath = path
    endif
end

proc GetName()
    integer attr
    string path[255] = EditorName

    Ask("Name of editor executable (default is E32.EXE)",path)
    attr = FileExists(EditorPath + path)
    if attr == 0 or (attr & _DIRECTORY_) <> 0
        Alarm()
        MsgBox("Error","File not found",0)
    else
        EditorName = path
    endif
end

/****************************************************************************\
    menu helpers
\****************************************************************************/

proc FlipIt(var integer switch)
    switch = not switch
end

string proc OnOff(integer switch)
    return (iif(switch, "ON", "OFF"))
end

integer proc NeedExt1()
    return (iif(inst_textext, _MF_CLOSE_AFTER_, _MF_GRAYED_))
end

integer proc NeedExt2()
    return (iif(inst_textext, _MF_SKIP_, _MF_SKIP_|_MF_GRAYED_))
end

integer proc CanBuild()
    integer can_build

    can_build = inst_textext or inst_unknown
        or inst_restore or inst_salpack or inst_dialogs

    return (iif(can_build, _MF_CLOSE_ALL_BEFORE_, _MF_GRAYED_))
end

integer proc CanInstall()
    integer can_install

    can_install = not inf_installed and CanBuild() <> _MF_GRAYED_

    return (iif(can_install, _MF_CLOSE_ALL_BEFORE_, _MF_GRAYED_))
end

integer proc CanUnInstall()
    return (iif(inf_installed, _MF_CLOSE_ALL_BEFORE_, _MF_GRAYED_))
end

proc Terminate()
    terminated = TRUE
end

/****************************************************************************\
    menus
\****************************************************************************/

menu MainMenu()
    title = "TSE Shell Extensions"
    width = 40
    x = 20
    y = 2
    History
    NoEscape
    NoKeys

    "&Create TSE Text File Type"        [OnOff(inst_textext): 3], FlipIt(inst_textext)
    "&Open Unknown Files with TSE"      [OnOff(inst_unknown): 3], FlipIt(inst_unknown)
    "&Restore State from Explorer"      [OnOff(inst_restore): 3], FlipIt(inst_restore)
    "&Macro Language Package"           [OnOff(inst_salpack): 3], FlipIt(inst_salpack)
    "&Dialogs Library Package"          [OnOff(inst_dialogs): 3], FlipIt(inst_dialogs)
    "",,                                _MF_DIVIDE_
    "&Print TSE Files from Explorer"    [OnOff(inst_prtpack): 3], FlipIt(inst_prtpack)
    "",,                                _MF_DIVIDE_
    "&Extensions for TSE Text Files",   GetTxtExt(), NeedExt1()
    ""                                  [TextFileExts:38],, NeedExt2()
    "",,                                _MF_DIVIDE_
    "Name of &State File...",           GetState(), _MF_DONT_CLOSE_
    "TSE Path (&LoadDir)...",           GetPath(), _MF_DONT_CLOSE_
    "TSE &Name (Program Name)...",      GetName(), _MF_DONT_CLOSE_
    "",,                                _MF_DIVIDE_
    "&Build INF File Only",             BuildOnly(), CanBuild()
    "&Install Shell Extensions",        Install(), CanInstall()
    "&Uninstall Shell Extensions",      UnInstall(), CanUnInstall()
    "",,                                _MF_DIVIDE_
    "&Help",                            ShowDocFile("TSESHEXT.DOC")
    "E&xit",                            Terminate()
end

/****************************************************************************\
    initialization
\****************************************************************************/

integer proc GetDefaultExt()
    integer rc = FALSE

    if LoadBuffer("INSTALL.DAT",0)
        TextFileExts = Trim(GetText(1,CurrLineLen()))
        rc = Length(TextFileExts) > 0
    endif
    return(rc)
end

/****************************************************************************\
    main program
\****************************************************************************/

proc Main()
    integer ilba
    integer buff_id

/****************************************************************************\
//  debugging code

    Set(Break,ON)
    buff_id = GetBufferId(ExpandPath(InfFileName))
    if buff_id
        AbandonFile(buff_id)
    endif
\****************************************************************************/

    // initialization

    buff_id = GetBufferId()
    PushBlock()

    // editor configuration

    ilba = Set(InsertLineBlocksAbove,OFF)

    // allocate buffers

    tmp_buff = CreateTempBuffer()
    inf_buff = CreateTempBuffer()
    ext_buff = CreateTempBuffer()

    // init global variables

    QueryRegInfo()
    if GetDefaultExt()
        inst_textext = BuildExtBuffer(TextFileExts)
    else
        inst_textext = FALSE
    endif
    EditorPath = LoadDir(TRUE)
    EditorName = SplitPath(EditorPath,_NAME_|_EXT_)
    EditorPath = SplitPath(EditorPath,_DRIVE_|_PATH_)

    // run configuration menu

    if inf_buff and ext_buff and tmp_buff
        repeat
            Set(Attr,0)
            ClrScr()
            MainMenu()
        until terminated
    else
        MsgBox("Error","Cannot allocate buffers",0)
    endif

    // clean up

    AbandonFile(tmp_buff)
    AbandonFile(inf_buff)
    AbandonFile(ext_buff)
    Set(InsertLineBlocksAbove,ilba)
    GotoBufferId(buff_id)
    PopBlock()

/****************************************************************************\
//  debugging code

    EditFile(InfFileName)
    return()
\****************************************************************************/

    if del_inf_file
        EraseDiskFile(InfFileName)
    endif
    if GetEnvStr("CalledFromBatch") == "YES"
        EraseDiskFile(CurrMacroFilename())
        AbandonEditor()
    else
        UpdateDisplay(_ALL_WINDOWS_REFRESH_)
    endif
end
