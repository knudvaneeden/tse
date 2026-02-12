/****************************************************************************\

  LoadFile.S

  TSE file entry extensions.

  Version         0.8/01.07.96  hook balance corrected
                                (pointed out by G.D.B./SemWare)
                  0.7/01.05.96  no backslash required for
                                directory recognition
                  0.6/18.04.96  corrected directory handling
                  0.5/15.04.96  original version

  Copyright       (c) Dr. S. Schicktanz

  Overview:

    This modifies all file entry dialog boxes, providing
    - a footer line showing command key assignments
    - a pick file box featuring a change directory and
      select-and-change directory function, also with
      an appropriate footer line
    - still another pick box presenting the available drives
      along with their respective volume labels for immediate
      drive access (even handles network drives!)

  Keys:

    See constant definitions and keydefs below

  Usage notes:

    No special preparations to the user interface are neccessary
    because all functions hook themselves into the appropriate
    events, making the macro's workings fully transparent.
    The additional features will be available automatically upon
    installation.
    The pick file list will always start up in the directory where
    the current file resides, or the current directory for the
    drive, if no file is given.
    Compilation may specify an optional language for prompts, where
    _GER (default) will produce german prompts, and
    _ENG will produce english ones. Other languages may be added...
    (For a specific language, call SC with a command line definition, like
         SC LOADFILE D_ENG
     for the english language version.)

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

/****************************************************************************/
// Declarations
/****************************************************************************/

constant
    SpecialKey =    <F2>,
    SelectKey =     <F10>,
    ChangeDirKey =  <Shift F10>,
    LoadFileKey =   <Alt E>,
    InsertFileKey = <Alt R>


integer SetDirSelectHook = 0, ResetDirSelectHook = 0,
        LoadCleanupHook = 0, LeavePickfileHook = 0,
        RepaintStatusHook = 0, mChangeDirHook = 0,
        mLoadFileHook = 0


integer Top

integer Changed =     FALSE
string  NewDir [128] =   ''

#ifdef _GER
string  AskHelp [] =    " {Enter}-akzeptieren  {}/{}-letzte Eingaben "+
                        " {Esc}-Abbruch "
string  PickHelp [] =   " {Enter}-laden  {}/{}-letzte Eingaben "+
                        " {F2}-Auswahlliste  {Esc}-Abbruch "
string  SelectHelp [] = "{Enter}-Datei {F10}-Datei & Dir {Sh F10}-Dir "+
                        "{Esc}-Abbruch"
#else
string  AskHelp [] =    " {Enter}-accept  {}/{}-previous entries "+
                        " {Esc}-abort "
string  PickHelp [] =   " {Enter}-load  {}/{}-previous entries "+
                        " {F2}-pick list  {Esc}-abort "
string  SelectHelp [] = "{Enter}-file {F10}-file & dir {Sh F10}-dir "+
                        "{Esc}-abort"
#endif
string  Drives [255] = ""


proc GetDriveLetters ()     // converted from Turbo Pascal
    integer i, n
    register R
    string DTA [43] = '',
           Label [44]

    Drives= ''
    setDTA (DTA)


    for i= 1 to 26
        R.ax= 440Eh
        R.bx= i
        intr (21h, R)

        if ((R.flags & _flCARRY_) == 0) or ((R.ax & 0FFh) <> 15)
            Drives= Drives+ chr (i+ Asc ('@'))+ ': '

            if i > 2
                if FindFirst (chr (i+ Asc ('@'))+ ':\*.*', _VOLUME_)
                    EndLine ()
                    Label= DTA [31:11]
                    Label= Label [1: 8]+ Label [10: 3]
                    n= Pos (chr (0), Label)
                    if n == 0
                        n= Length (Label)
                    endif
                    Drives= Drives+ Format (Label [1: n]: -11)
                else
                    Drives= Drives+ Format ('': 11)
                endif
            else
                Drives= Drives+ Format ('': 11)
            endif
        endif
    endfor
end GetDriveLetters


proc ChangeDrive ()
    integer i, Top,
            current = GetBufferId (),
            DriveList = CreateTempBuffer ()
    string  NewDrive [1],
            actDrive [1] = GetDrive ()

    if DriveList
        Top= Set (Y1, 3)

        for i= 1 to Length (Drives)/ 14
            AddLine ('    '+ Drives [14* i- 13: 14])
        endfor

        GotoLine (Asc (actDrive)- Asc ('`'))

        if List ('Laufwerke:', 20)
            NewDrive= Drives [14* CurrLine ()- 13]
            if NewDrive <> actDrive
                LogDrive (NewDrive)
                NewDir= GetDir (NewDrive)
                Changed= TRUE
                PushKey (<SpecialKey>)
                PushKey (<Escape>)
            endif
        endif

        Set (Y1, Top)
        GotoBufferId (current)
        AbandonFile (DriveList)
    endif
end

string proc promptDir ()
    string NewDir [128] = GetText (1, 255)

    if FileExists (NewDir) & _DIRECTORY_
        return (NewDir+ '\')
    endif

    return (SplitPath (GetText (1, 255), _DRIVE_ | _PATH_))
end

proc ShowCurrDir ()
    #ifdef _GER
    Message ('Aktuelles Verzeichnis: ', NewDir)
    #else
    Message ('Current Directory: ', NewDir)
    #endif
end

proc GetPickedDir (integer ExitKey)

    NewDir= SplitPath (Query (PickFilePath), _DRIVE_ | _PATH_)
    LogDrive (NewDir)
    ChDir (SplitPath (NewDir, _PATH_))

    Changed= TRUE
    ShowCurrDir ()

    if ExitKey
        PushKey (ExitKey)
    endif
end

KeyDef DirSelect

    <SelectKey>         GetPickedDir (<Enter>)
    <ChangeDirKey>      GetPickedDir (0)
    <SpecialKey>        ChangeDrive ()
    <Ctrl F1>           ExecMacro ("ASCII")     // mAsciiChart()
end


forward proc SetDirSelect ()
forward proc mChangeDir ()

proc LeavePickfile ()

    Disable (DirSelect)
    if Changed
        ShowCurrDir ()
    endif

    UnHook (LeavePickfile)
    LeavePickfileHook= LeavePickfileHook- 1
    UnHook (SetDirSelect)
    SetDirSelectHook= SetDirSelectHook- 1
    Hook (_PICKFILE_STARTUP_, mChangeDir)
    mChangeDirHook= mChangeDirHook+ 1
end

proc mChangeDir ()

    UnHook (mChangeDir)
    mChangeDirHook= mChangeDirHook- 1
    Hook (_PICKFILE_STARTUP_, SetDirSelect)
    SetDirSelectHook= SetDirSelectHook+ 1
    Hook (_PICKFILE_CLEANUP_, LeavePickfile)
    LeavePickfileHook= LeavePickfileHook+ 1

    Changed= FALSE
    Set (Y1, 2)
    WindowFooter (SelectHelp)
    Enable (DirSelect)
end


proc ResetDirSelect ()

    FullWindow ()
    Set (Y1, 2)
    WindowFooter (SelectHelp)
    UnHook (SetDirSelect)
    Hook (_PICKFILE_CLEANUP_, SetDirSelect)
    Enable (DirSelect)
end

proc SetDirSelect ()

    Disable (DirSelect)
    UnHook (LeavePickfile)
    LeavePickfileHook= LeavePickfileHook- 1
    Hook (_PICKFILE_CLEANUP_, ResetDirSelect)
    ResetDirSelectHook= ResetDirSelectHook+ 1
    Set (Y1, 3)
    UpdateDisplay (_WINDOW_REFRESH_)
end


proc ForcePick ()
    string newSelection [128]

    if not Changed
//        NewDir= CurrDir ()          // alternatively
        NewDir= promptDir ()
    endif
    newSelection= PickFile (NewDir)

    if newSelection <> ''
        BegLine ()
        KillToEol ()
        InsertText (newSelection)
    endif
end

KeyDef ForceSelect

    <SpecialKey>        ForcePick ()
    <Ctrl F1>           ExecMacro ("ASCII")     // mAsciiChart()
    <Ctrl Backspace>    DelLeftWord ()
    <Ctrl F7>           InsertText (CurrFilename ())
end


forward proc LoadCleanup ()

proc mLoadFile ()

    if Query (CurrHistoryList) == _EDIT_HISTORY_
//        NewDir= CurrDir ()          // alternatively
        NewDir= promptDir ()
        Changed= FALSE
        Top= Set (Y1, 2)
        Enable (ForceSelect)
        UnHook (mLoadFile)
        mLoadFileHook= mLoadFileHook- 1
        Hook (_PROMPT_CLEANUP_, LoadCleanup)
        LoadCleanupHook= LoadCleanupHook+ 1

        if Query (PopWinCols) > Length (PickHelp)
            WindowFooter (PickHelp)
        endif
    elseif Query (CurrHistoryList) <> 0 // if history available, show hint
        if Query (PopWinCols) > Length (AskHelp)
            WindowFooter (AskHelp)
/*
    here, a problem with window footers shows up: on small windows,
    like those for the "repeat command" count entry box, the footer
    will not be centered correctly but hang over to the left, inde-
    pendent of window position.
    So, it is not possible to display a special short footer for
    those windows disclosing the availability of a history...
 */
        endif
    endif
end

// This function was required by another quirk in the video engine:
// an "UpdateDisplay ()" won't work at all from within the
// _PROMPT_CLEANUP_ hook! That's why this detour is in here...
//
proc RepaintStatus ()

    UnHook (RepaintStatus)
    RepaintStatusHook= RepaintStatusHook- 1
    UpdateDisplay (_STATUSLINE_REFRESH_)
end

proc LoadCleanup ()

    Set (Y1, Top)
    UnHook (LoadCleanup)
    LoadCleanupHook= LoadCleanupHook- 1
    Hook (_PROMPT_STARTUP_, mLoadFile)
    mLoadFileHook= mLoadFileHook+ 1
    Hook (_IDLE_, RepaintStatus)
    RepaintStatusHook= RepaintStatusHook+ 1
end


proc WhenLoaded ()
    GetDriveLetters ()
    Hook (_PICKFILE_STARTUP_, mChangeDir)
    mChangeDirHook= mChangeDirHook+ 1
    Hook (_PROMPT_STARTUP_, mLoadFile)
    mLoadFileHook= mLoadFileHook+ 1
end


proc HookStatus ()
    Warn ('SetDirSelect: ', SetDirSelectHook, ' - ResetDirSelect: ', SetDirSelectHook)
    Warn ('LoadCleanup: ',  LoadCleanupHook,  ' - LeavePickfileHook: ', LeavePickfileHook)
    Warn ('RepaintStatus: ', RepaintStatusHook, ' - ChangeDir: ', mChangeDirHook, ' - LoadFile: ', mLoadFileHook)
end

<CtrlAlt F8>   HookStatus ()


proc main ()
//    WhenLoaded ()
end