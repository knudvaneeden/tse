/*****************************************************************************
*                                                                            *
*  Filename      : QKEYS.S                                                   *
*                                                                            *
*  Created       : Originally by Ian Campbell                                *
*                                                                            *
*  Modified by   : Ross Boyd <Ross_Boyd@tnt.com.au>                          *
*                                                                            *
*  Compatibility : TSE 2.6/2.8 only.                                         *
*                                                                            *
*  Version       : 2.00                                                      *
*                                                                            *
*  Comments and bug reports to Ross_Boyd@tnt.com.au.                         *
*                                                                            *
* Description                                                                *
* 컴컴컴컴컴�                                                                *
* This macro accelerates the rate of cursor movement and hence scroll speed. *
* Essentially, the macro detects when the Cursor navigation keys are being   *
* pressed and repeats the commands associated with them eg. Up(),Down() etc  *
*                                                                            *
* The original version attempted to smooth the scrolling and provide support *
* for Ian Campbell's Syntax Hilite macro (colors.s). This is not required for*
* TSE 2.6/TSE 2.8. Also, the original changed the BIOS settings for KeyRepeat*
* and KeyDelay. I suggest simply setting these in Windows Control Panel to   *
* their fastest rates.                                                       *
*                                                                            *
* Installing                                                                 *
* 컴컴컴컴컴�                                                                *
* Simply copy QKEYS.MAC and QKEYS.S to your \TSE\MAC directory. Add 'qkeys'  *
* (without the quotes) to your AutoLoad list in TSE's Macro menu. Quit and   *
* Restart TSE.                                                               *
*                                                                            *
* Press <CtrlShift CursorUp> to invoke the configuration menu.               *
*                                                                            *
* A user-configuration menu has been added to allow experimentation with the *
* horizontal/vertical repeat rates and the repeat delay.                     *
*                                                                            *
* Once you're happy with your configuration use the Save Settings option to  *
* make your settings permanent.                                              *
*                                                                            *
* Any feedback/bug reports will be gladly received. Enjoy!                   *
*                                                                            *
* Caveats                                                                    *
* 컴컴컴컴컴�                                                                *
* The key acceleration settings are a bit crude. In fact the slowest         *
* acceleration is _very_ fast. Sorry about that. In a future version I will  *
* try to incorporate some high resolution timers to smooth/slowdown the      *
* acceleration a little. If anyone knows how to access millisecond timers,   *
* please let me know.                                                        *
*                                                                            *
* Disclaimer                                                                 *
* 컴컴컴컴컴�                                                                *
* USE THIS MACRO AT YOUR OWN RISK. THE AUTHOR TAKES NO LIABILITY FOR DAMAGES *
* INCURRED RESULTING FROM ITS USE.                                           *
*****************************************************************************/

/*****************************************************************************
* Global Constants                                                           *
*****************************************************************************/
// Hotkey for Configuration Menu
constant CONFIG_MENU_HOTKEY = <CtrlShift CursorUp>

/*****************************************************************************
* Forwarded Declarations                                                     *
*****************************************************************************/
forward menu mConfig()

/*****************************************************************************
* Global Variables                                                           *
*****************************************************************************/

// the number of keys that must be pressed before speedup occurs
integer  KeystrokeCountBeforeSpeedup

// the number of additional Left's() or Right's() that are
// inserted between actual <CursorLeft>, <CursorRight> keyboard keystrokes.
integer  AdditionalHorizontalKeys

// the number of additional Up's() or Down's() that are
// inserted between actual <CursorUP>, <CursorDown> keyboard keystrokes.
integer  AdditionalVerticalKeys

integer  CursorKeyPressed = 0
integer  StoredClockTicks = 0
integer  OldCursorType    = 0
integer  StreamingState   = FALSE   // protects against keyboard-macro confusion

string EyeCatcher[] = "QKeys macro settings... Do not edit"

/*****************************************************************************
   Procedure:   mKeySpeedup()

   Notes:       This is the main macro.  It adds the extra cursor key
                functions, and it sorts out the smoothing mechanism for
                performing these functions at the appropriate time.

   Called by:   Assigned to the cursor keys by a direct key assignment
                at the bottom of this macro.

   Enter With:  The cursor keystroke

   Returns:     nothing
*****************************************************************************/
proc mKeySpeedup(integer CursorType)
    integer  KeyCount = AdditionalHorizontalKeys

    if CursorType <> OldCursorType
        CursorKeyPressed = 0
    endif

    OldCursorType = CursorType

    case CursorType
        when <CursorRight>, <CursorLeft>
            case CursorType
                when <CursorRight>
                    Right()
                when <CursorLeft>
                    Left()
            endcase
            if AdditionalHorizontalKeys == 0
                return()
            endif
            KeyCount = AdditionalHorizontalKeys
        when <CursorUp>, <CursorDown>
            case CursorType
                when <CursorUp>
                    Up()
                when <CursorDown>
                    Down()
            endcase
            if AdditionalVerticalKeys == 0
                return()
            endif
            KeyCount = AdditionalVerticalKeys
    endcase

    if (GetClockTicks() > StoredClockTicks + 2)
        StreamingState = FALSE
        CursorKeyPressed = 0
    endif

    if StreamingState and GetClockTicks() <= StoredClockTicks + 1
        and KeyCount and (CursorKeyPressed >= KeystrokeCountBeforeSpeedup)
        case CursorType
            when <CursorRight>
                Right(KeyCount)
            when <CursorLeft>
                Left(KeyCount)
            when <CursorUp>
                Up(KeyCount)
            when <CursorDown>
                Down(KeyCount)
        endcase
    endif

    StoredClockTicks = GetClockTicks()
    CursorKeyPressed = CursorKeyPressed + 1

end mKeySpeedup

/*****************************************************************************
   Procedure:   mCheckForCursorKeys()

   Notes:       Check to see if the previous command was a cursor key
                command, and if not, then clear some flags.

   Called by:   Hooked to _AFTER_COMMAND_ via WhenLoaded()

   Enter With:  nothing

   Returns:     nothing
******************************************************************************/
proc mCheckForCursorKeys()
    integer  MacroRecordState = Query(KbdMacroRecording)

    case Query(Key)
        when <CursorLeft>, <CursorRight>, <CursorUp>, <CursorDown>,
                     <GreyCursorLeft>, <GreyCursorRight>, <GreyCursorUp>,
                     <GreyCursorDown>
            if (CursorKeyPressed > 1) and (not MacroRecordState)
                StreamingState = TRUE
            endif
        otherwise
            StreamingState = FALSE
            CursorKeyPressed = 0
    endcase
end mCheckForCursorKeys

/****************************************************************************
   Procedure:   ReadNum()

   Notes:       Read command that returns the numeric value of the user input.
****************************************************************************/
integer proc ReadNum(integer n,integer width)
    string   s[3] = str(n)
    if lReadNumeric(s,width)
        return (val(s))
    endif
    return (n)
end ReadNum

/****************************************************************************
   Procedure:   SanityCheck()

   Notes:       Force Acceleration Settings to sane/valid values
****************************************************************************/
proc SanityCheck()
    AdditionalVerticalKeys      = Min(Max(AdditionalVerticalKeys,0),99)
    AdditionalHorizontalKeys    = Min(Max(AdditionalHorizontalKeys,0),99)
    KeyStrokeCountBeforeSpeedUp = Min(Max(KeyStrokeCountBeforeSpeedUp,0),999)
end


/****************************************************************************
   Procedure:   SetDefaultSettings()

   Notes:       Initialise Acceleration Settings to Default Values
****************************************************************************/
proc SetDefaultSettings()
    AdditionalVerticalKeys      = 2
    AdditionalHorizontalKeys    = 2
    KeyStrokeCountBeforeSpeedUp = 1
end

/****************************************************************************
   Procedure:   LoadQKSettings()

   Notes:       Load and Set Acceleration Settings from file.
****************************************************************************/
proc LoadQKSettings()
    string fn[_MAXPATH_]
    integer settings_id

    PushPosition()
    settings_id = CreateTempBuffer()

    if settings_id
        fn = Lower(LoadDir()+SplitPath(CurrMacroFileName(), _NAME_)) + ".dat"

        if FileExists(fn)
            LoadBuffer(fn)
            if GetText(1,sizeof(EyeCatcher)) <> EyeCatcher
                Warn("Invalid settings file '",fn,"'. Using defaults...")
                SetDefaultSettings()
            else
                if down()
                    AdditionalVerticalKeys      = Val(GetText(1,2))
                endif
                if down()
                    AdditionalHorizontalKeys    = Val(GetText(1,2))
                endif
                if down()
                    KeyStrokeCountBeforeSpeedUp = Val(GetText(1,3))
                endif
                SanityCheck()
            endif
        else
            SetDefaultSettings()
        endif
        AbandonFile(settings_id)
    else
        Warn("Out of buffer memory")
    endif
    PopPosition()
end

/****************************************************************************
   Procedure:   SaveQKSettings()

   Notes:       Save Acceleration Settings to file.
****************************************************************************/
proc SaveQKSettings()
    string fn[_MAXPATH_]
    integer settings_id

    PushPosition()
    settings_id = CreateTempBuffer()

    if settings_id
        fn = Lower(LoadDir()+SplitPath(CurrMacroFileName(), _NAME_)) + ".dat"

        AddLine(EyeCatcher)
        AddLine(str(AdditionalVerticalKeys))
        AddLine(str(AdditionalHorizontalKeys))
        AddLine(str(KeyStrokeCountBeforeSpeedUp))

        If SaveAs(fn,_OVERWRITE_)
            Message("Settings saved...")
        else
            Warn("Error: Settings not saved...")
        endif
        AbandonFile(settings_id)
    else
        Warn("Out of buffer memory")
    endif
    PopPosition()
end

/****************************************************************************
   Procedure:   mConfigProc()

   Notes:       Support function for mConfig() Menu
****************************************************************************/
proc mConfigProc(integer option)
    case option
        when 1
            AdditionalVerticalKeys = ReadNum(AdditionalVerticalKeys,2)
            SanityCheck()
        when 2
            AdditionalHorizontalKeys = ReadNum(AdditionalHorizontalKeys,2)
            SanityCheck()
        when 3
            KeyStrokeCountBeforeSpeedUp = ReadNum(KeyStrokeCountBeforeSpeedUp,3)
            SanityCheck()
        when 4
            SetDefaultSettings()
            mConfig()             // Redisplay Menu with new settings
    endcase
end

/****************************************************************************
   Procedure:   mConfig() Menu

   Notes:       Allows user to configure acceleration settings.
                Provides options to Save Settings, Load Defaults or Purge
                this macro.
****************************************************************************/
menu mConfig()

    Title = 'QKey Settings'
    History
    x     = 5
    y     = 4
    "&Vertical Speedup"          [AdditionalVerticalKeys:2],
             mConfigProc(1),
             DontClose,
             "Specify how many additional lines to scroll per keystroke (0-99)"
    "&Horizontal Speedup"        [AdditionalHorizontalKeys:2],
             mConfigProc(2),
             DontClose,
             "Specify how many additional columns to scroll per keystroke (0-99)"
    "&Keystrokes Before SpeedUp" [KeyStrokeCountBeforeSpeedUp:3],
             mConfigProc(3),
             DontClose,
             "Specify how many keystrokes to wait before applying acceleration (0-999)"
    "",,Divide
    "&Save Settings",           SaveQKSettings()
            ,,
             "Save the current settings to disk"
    "&Defaults",                mConfigProc(4),,
             "Reset settings to defaults"
    "&Purge macro",             PurgeMacro(CurrMacroFileName()),,
             "Quit and Unload this macro from memory"
end

/****************************************************************************
   Procedure:   WhenPurged()

   Notes:       Automatically called when macro is purged.
****************************************************************************/
proc WhenPurged()
    UnHook(mCheckForCursorKeys)
end

/****************************************************************************
   Procedure:   WhenLoaded()

   Notes:       Automatically called when macro is loaded.
                Loads Saved Settings.
****************************************************************************/
proc WhenLoaded()
    LoadQKSettings()
    Hook(_AFTER_COMMAND_, mCheckForCursorKeys)
end WhenLoaded


/****************************************************************************
  Cursor Key Definitions/Remapping
****************************************************************************/
<CursorRight>       mKeySpeedup(<CursorRight>)
<GreyCursorRight>   mKeySpeedup(<CursorRight>)
<CursorLeft>        mKeySpeedup(<CursorLeft>)
<GreyCursorLeft>    mKeySpeedup(<CursorLeft>)
<CursorUp>          mKeySpeedup(<CursorUp>)
<GreyCursorUp>      mKeySpeedup(<CursorUp>)
<CursorDown>        mKeySpeedup(<CursorDown>)
<GreyCursorDown>    mKeySpeedup(<CursorDown>)

/****************************************************************************
  HotKey for PopUp Configuration Menu
****************************************************************************/
<CONFIG_MENU_HOTKEY> mConfig()
