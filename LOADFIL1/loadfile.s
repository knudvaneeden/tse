/****************************************************************************\

  LoadFile.S

  Win32 package  1.0.0.0.5/16.09.2026
                 Clean custom footers; English is now the default

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
    _ENG (default) will produce English prompts, and
    _GER will produce German prompts. Other languages may be added...
    (For the optional German language, call SC with a command line definition,
     like
         SC LOADFILE D_GER
    .)

\****************************************************************************/
// Defines
/****************************************************************************/

#ifdef _GER
// german version
#else
#ifdef _ENG
// english version
#else
// no version? Use English!
#define _ENG    1
#endif
#endif

/****************************************************************************/
// Declarations
/****************************************************************************/

dll "loadfil1.dll"
    integer proc LFResetDriveScan ()
    integer proc LFNextDrive ()
    integer proc LFNextLabelChar ()
end

constant
    SpecialKey =    <F2>,
    SelectKey =     <F10>,
    ChangeDirKey =  <Shift F10>,
    LoadFileKey =   <Alt E>,
    InsertFileKey = <Alt R>,
    FooterKey =     <CtrlAltShift F12>


integer SetDirSelectHook = 0, ResetDirSelectHook = 0,
        LoadCleanupHook = 0, LeavePickfileHook = 0,
        RepaintStatusHook = 0, mChangeDirHook = 0,
        mLoadFileHook = 0


integer Top

integer Changed =     FALSE
integer Installed =   FALSE
string  NewDir [128] =   ''

#ifdef _GER
string  AskHelp [] =    " Enter-Annehmen  Up/Down-Verlauf  Esc-Abbruch "
string  PickHelp [] =   " Enter-Laden  Up/Down-Verlauf  F2-Auswahl  Esc-Abbruch "
string  SelectHelp [] = " Enter-Datei  F10-Datei+Verz  ShF10-Verz  "+
                        "F2-Laufwerke  Esc-Abbruch "
#else
string  AskHelp [] =    " Enter-Accept  Up/Down-History  Esc-Cancel "
string  PickHelp [] =   " Enter-Load  Up/Down-History  F2-Pick  Esc-Cancel "
string  SelectHelp [] = " Enter-File  F10-File+Dir  ShF10-Dir  "+
                        "F2-Drives  Esc-Cancel "
#endif
string  Drives [255] = ""


proc GetDriveLetters ()
    integer DriveNumber,
            Character
    string  Label [255]

    Drives= ''
    LFResetDriveScan ()
    DriveNumber= LFNextDrive ()

    while DriveNumber
        Label= ''
        Character= LFNextLabelChar ()

        while Character
            Label= Label+ Chr (Character)
            Character= LFNextLabelChar ()
        endwhile

        Drives= Drives+ Chr (DriveNumber+ Asc ('@'))+ ': '+
                Format (Label [1: 11]: -11)
        DriveNumber= LFNextDrive ()
    endwhile
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

proc ClearFooter ()
    integer FooterWidth = Query (PopWinCols)- 2

    if FooterWidth > 255
        FooterWidth= 255
    endif

    if FooterWidth > 0
        WindowFooter (Format ('': FooterWidth))
    endif
end

proc ShowPickFooter ()
    ClearFooter ()
    WindowFooter (SelectHelp)
end

KeyDef DirSelect

    <FooterKey>         ShowPickFooter ()
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
    PushKey (<FooterKey>)
end


proc ResetDirSelect ()

    FullWindow ()
    Set (Y1, 2)
    WindowFooter (SelectHelp)
    UnHook (SetDirSelect)
    Hook (_PICKFILE_CLEANUP_, SetDirSelect)
    Enable (DirSelect)
    PushKey (<FooterKey>)
end

proc SetDirSelect ()

    Disable (DirSelect)
    UnHook (LeavePickfile)
    LeavePickfileHook= LeavePickfileHook- 1
    Hook (_PICKFILE_CLEANUP_, ResetDirSelect)
    ResetDirSelectHook= ResetDirSelectHook+ 1
    Set (Y1, 3)
    UpdateDisplay (_WINDOW_REFRESH_)
    PushKey (<FooterKey>)
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

proc ShowPromptFooter ()
    ClearFooter ()
    WindowFooter (PickHelp)
end

KeyDef ForceSelect

    <FooterKey>         ShowPromptFooter ()
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
        PushKey (<FooterKey>)
        UnHook (mLoadFile)
        mLoadFileHook= mLoadFileHook- 1
        Hook (_PROMPT_CLEANUP_, LoadCleanup)
        LoadCleanupHook= LoadCleanupHook+ 1

        WindowFooter (PickHelp)
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
    if not Installed
        GetDriveLetters ()
        Hook (_PICKFILE_STARTUP_, mChangeDir)
        mChangeDirHook= mChangeDirHook+ 1
        Hook (_PROMPT_STARTUP_, mLoadFile)
        mLoadFileHook= mLoadFileHook+ 1
        Installed= TRUE
    endif
end


proc HookStatus ()
    Warn ('SetDirSelect: ', SetDirSelectHook, ' - ResetDirSelect: ', SetDirSelectHook)
    Warn ('LoadCleanup: ',  LoadCleanupHook,  ' - LeavePickfileHook: ', LeavePickfileHook)
    Warn ('RepaintStatus: ', RepaintStatusHook, ' - ChangeDir: ', mChangeDirHook, ' - LoadFile: ', mLoadFileHook)
end

<CtrlAlt F8>   HookStatus ()


proc main ()
    WhenLoaded ()
end
