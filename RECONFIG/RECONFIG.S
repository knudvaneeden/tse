/*************************************************************************

  RECONFIG.S  Editor start up macro for use of different configurations.
              Editor-Start-Makro zum Benutzen verschiedener Konfigurationen.

  Author:     Dr. Sieghard Schicktanz, Kreidestr. 12, 8196 Achmuehle

  Date:       Feb 19, 1995 - initial version

  Overview:

  This macro loads a specific configuration from a file in a specific
  directory which can be specified by means of an environment variable
  named "HOMEDIR", possibly qualified by a subdirectory appended to it.

(German comments added on request:)
  Dieses Makro lÑdt eine sezifische Konfigurations aus einer Datei in einem
  speziellen Verzeichnis, das mit einer Environmentvariablen namens "HOMEDIR"
  definiert werden kann, eventuell durch ein Unterverzeichnis noch weiter
  spezifiziert.

  Keys:       (none)

  Usage notes:

  This macro does not have any key assignments.
  There are a couple of limitations:
  - It can only process one set of color settings appropriate to the
    screen mode at load time.
  - It cannot (as yet?) evaluate the settings for the variables "WordSet"
    and "TabSet".

  Das Makro benutzt keine Tastenzuweisungen.
  Es hat ein paar EinschrÑnkungen:
  - Es kann nur einen Satz Farbeinstellungen benutzen, der dem Bildschirm-
    Modus beim Laden entspricht.
  - Es kann (noch?) nicht die Einstellungen fÅr die Variablen "WordSet"
    und "TabSet" auswerten.

*************************************************************************/

constant StringSize = 255           // TSE string variable size
constant NameSize = 20              // arbitrary maximum length

string CfgDir  [5]  = "\TSE\"       // subdirectory for CFG files
string UserCfg [12] = "tse_user.cfg" // name of configuration file
string HomeDir [64] = "HOMEDIR"     // name of environment variable

integer FarbEinstellung             // buffer for actual color setting


integer proc Flag (string Value)
    return (Lower (Value) == "on")
end


integer proc ASCII (string Value)
    integer ON

    ON= Pos ('(', Value)            // "Asc(" in front?
    if ON                           // to be deleted!
        return (Asc (Value [ON+ 2]))
    endif

    return (Val (Value))            // else specify numerically
end


integer proc EnumVal (string Value)
    case Upper (Value)
        when "ON"
            return (TRUE)
        when "OFF"
            return (FALSE)
        when "_STICKY_"
            return (_STICKY_)
        when "_25_LINES_"
            return (_25_LINES_)
        when "_28_LINES_"
            return (_28_LINES_)
        when "_43_LINES_"
            return (_43_LINES_)
        when "_50_LINES_"
            return (_50_LINES_)
        when "_AUTO_DETECT_"
            return (_AUTO_DETECT_)
        when "_COLOR_"
            return (_COLOR_)
        when "_MONO_"
            return (_MONO_)
        when "_HARD_"
            return (_HARD_)
        when "_SOFT_"
            return (_SOFT_)
        when "_SMART_"
            return (_SMART_)
        when "_VARIABLE_"
            return (_VARIABLE_)
    endcase

    return (0)
end


integer proc Attribute (string Colour)
    if Pos ('BRIGHT', Colour)
        return (8)
    endif
    if Pos ('BLINK', Colour)
        return (128)
    endif
    if Pos ('WHITE', Colour)
        return (7)
    endif
    if Pos ('YELLOW', Colour)
        return (6)
    endif
    if Pos ('MAGENTA', Colour)
        return (5)
    endif
    if Pos ('RED', Colour)
        return (4)
    endif
    if Pos ('CYAN', Colour)
        return (3)
    endif
    if Pos ('GREEN', Colour)
        return (2)
    endif
    if Pos ('BLUE', Colour)
        return (1)
    endif
    return (0)
end


integer proc Colour (string Value)
    integer ON, Farbe = 0
    string Definition [StringSize]= Upper (Value)

    ON= Pos ('(', Definition)       // "Color(" in front?
    if ON                           // to be deleted!
        Definition= SubStr (Definition, ON+ 1, Pos (')', Definition)- ON- 1)
    endif
    ON= Pos ('ON', Definition)

    if ON
        Farbe= Attribute (SubStr (Definition, ON+ 3, StringSize)) shl 4
        Definition= SubStr (Definition, 1, ON- 2)
    endif

    repeat
        ON= Pos (' ', Definition)
        if ON
            Farbe= Farbe+ Attribute (SubStr (Definition, 1, ON- 1))
            Definition= SubStr (Definition, ON+ 1, StringSize)
        else
            if Definition <> ''
                Farbe= Farbe+ Attribute (Definition)
            endif
        endif
    until not ON

    return (Farbe)
end


proc InterpretConfig (string VarName, string Value)

//    Warn (VarName+ ' = '+ Value)      // debugging message

    case Lower (VarName)
        when "maxxms"
            Set (MaxXMS, Val (Value))
        when "maxems"
            Set (MaxEMS, Val (Value))
        when "swappath"
            Set (SwapPath, Value)
        when "tsepath"
            Set (TSEPath, Value)
        when "kbdpath"
            Set (KbdPath, Value)
        when "defaultext"
            Set (DefaultExt, Value)
        when "loadwildfromdos"
            Set (LoadWildFromDos, Flag (Value))
        when "pickfilechangesdir"
            Set (PickFileChangesDir, Flag (Value))
        when "restoredironexit"
            Set (RestoreDirOnExit, Flag (Value))
        when "eoltype"
            Set (EOLType, Val (Value))
        when "eoftype"
            Set (EOFType, Val (Value))
        when "makebackups"
            Set (MakeBackups, Flag (Value))
        when "protectedsaves"
            Set (ProtectedSaves, Flag (Value))
        when "backupext"
            Set (BackupExt, Value)

            // keyboard/mouse options

        when "useenhancedkbd"
            Set (UseEnhancedKbd, Flag (Value))
        when "equateenhancedkbd"
            Set (EquateEnhancedKBD, Flag (Value))
        when "useextendedkbddriver"
            Set (UseExtendedKbdDriver, Flag (Value))
        when "usemouse"
            Set (UseMouse, Flag (Value))
        when "mouseholdtime"
            Set (MouseHoldTime, Val (Value))
        when "mouserepeatdelay"
            Set (MouseRepeatDelay, Val (Value))
        when "lefthandedmouse"
            Set (LeftHandedMouse, Flag (Value))

            // command and format optio

        when "maxhistorysize"
            Set (MaxHistorySize, Val (Value))
        when "wordset"
//            Set (WordSet, ChrSet (Value))     not available easily
        when "findoptions"
            Set (FindOptions, Value)
        when "replaceoptions"
            Set (ReplaceOptions, Value)
        when "centerfinds"
            Set (CenterFinds, Flag (Value))
        when "beep"
            Set (Beep, Flag (Value))
        when "changeshellprompt"
            Set (ChangeShellPrompt, Flag (Value))
        when "quittoprompt"
            Set (QuitToPrompt, Flag (Value))
        when "dateformat"
            Set (DateFormat, Val (Value))
        when "dateseparator"
            Set (DateSeparator, ASCII (Value))
        when "timeformat"
            Set (TimeFormat, Val (Value))
        when "timeseparator"
            Set (TimeSeparator, ASCII (Value))

            // text entry and block options

        when "insert"
            Set (Insert, Flag (Value))
        when "autoindent"
            Set (AutoIndent, EnumVal (Value))
        when "wordwrap"
            Set (WordWrap, Flag (Value))
        when "paraendstyle"
            Set (ParaEndStyle, Flag (Value))
        when "returneqnextline"
            Set (ReturnEqNextLine, Flag (Value))
        when "removetrailingwhite"
            Set (RemoveTrailingWhite, Flag (Value))
        when "linedrawtype"
            Set (LineDrawType, Val (Value))
        when "linedrawchar"
            Set (LineDrawChar, ASCII (Value))
        when "insertlineblocksabove"
            Set (InsertLineBlocksAbove, Flag (Value))
        when "usecurrlineifnoblock"
            Set (UseCurrLineIfNoBlock, Flag (Value))
        when "unmarkafterpaste"
            Set (UnMarkAfterPaste, Flag (Value))

            // tab and border options

        when "tabtype"
            Set (TabType, EnumVal (Value))
        when "tabwidth"
            Set (TabWidth, Val (Value))
        when "vartabs"
//            Set (VarTabs, TabSet (Value))     not available easily
        when "expandtabs"
            Set (ExpandTabs, Flag (Value))
        when "leftmargin"
            Set (LeftMargin, Val (Value))
        when "rightmargin"
            Set (RightMargin, Val (Value))

            // screen and color options

        when "statuslineattop"
            Set (StatusLineAtTop, Flag (Value))
        when "statuslinefillchar"
            Set (StatusLineFillChar, ASCII (Value))
        when "showhelpline"
            Set (ShowHelpLine, Flag (Value))
        when "currwinbordertype"
            Set (CurrWinBorderType, Val (Value))
        when "otherwinbordertype"
            Set (OtherWinBorderType, Val (Value))
        when "displayboxed"
            Set (DisplayBoxed, Val (Value))
        when "insertcursorsize"
            Set (InsertCursorSize, Val (Value))
        when "overwritecursorsize"
            Set (OverwriteCursorSize, Val (Value))
        when "showeofmarker"
            Set (ShowEOFMarker, Flag (Value))
        when "startupvideomode"
            Set (CurrVideoMode, EnumVal (Value))
        when "eliminatesnow"
            Set (EliminateSnow, Flag (Value))
        when "startupattrset"
            case EnumVal (Value)
                when _MONO_
                    FarbEinstellung= _MONO_
                when _COLOR_
                    FarbEinstellung= _COLOR_
            endcase

            // color attributes

        when "currwinborderattr"
            if FarbEinstellung == _COLOR_
                Set (CurrWinBorderAttr, Colour (Value))
            endif
        when "otherwinborderattr"
            if FarbEinstellung == _COLOR_
                Set (OtherWinBorderAttr, Colour (Value))
            endif
        when "menutextattr"
            if FarbEinstellung == _COLOR_
                Set (MenuTextAttr, Colour (Value))
            endif
        when "menutextltrattr"
            if FarbEinstellung == _COLOR_
                Set (MenuTextLtrAttr, Colour (Value))
            endif
        when "menuborderattr"
            if FarbEinstellung == _COLOR_
                Set (MenuBorderAttr, Colour (Value))
            endif
        when "menuselectattr"
            if FarbEinstellung == _COLOR_
                Set (MenuSelectAttr, Colour (Value))
            endif
        when "menuselectltrattr"
            if FarbEinstellung == _COLOR_
                Set (MenuSelectLtrAttr, Colour (Value))
            endif
        when "blockattr"
            if FarbEinstellung == _COLOR_
                Set (BlockAttr, Colour (Value))
            endif
        when "cursorinblockattr"
            if FarbEinstellung == _COLOR_
                Set (CursorInBlockAttr, Colour (Value))
            endif
        when "cursorattr"
            if FarbEinstellung == _COLOR_
                Set (CursorAttr, Colour (Value))
            endif
        when "hiliteattr"
            if FarbEinstellung == _COLOR_
                Set (HiLiteAttr, Colour (Value))
            endif
        when "textattr"
            if FarbEinstellung == _COLOR_
                Set (TextAttr, Colour (Value))
            endif
        when "eofmarkerattr"
            if FarbEinstellung == _COLOR_
                Set (EOFMarkerAttr, Colour (Value))
            endif
        when "msgattr"
            if FarbEinstellung == _COLOR_
                Set (MsgAttr, Colour (Value))
            endif
        when "statuslineattr"
            if FarbEinstellung == _COLOR_
                Set (StatusLineAttr, Colour (Value))
            endif

            // help attributes

        when "helpinfoattr"
            if FarbEinstellung == _COLOR_
                Set (HelpInfoAttr, Colour (Value))
            endif
        when "helplinkattr"
            if FarbEinstellung == _COLOR_
                Set (HelpLinkAttr, Colour (Value))
            endif
        when "helpselectattr"
            if FarbEinstellung == _COLOR_
                Set (HelpSelectAttr, Colour (Value))
            endif
        when "helpboldattr"
            if FarbEinstellung == _COLOR_
                Set (HelpBoldAttr, Colour (Value))
            endif
        when "helptextattr"
            if FarbEinstellung == _COLOR_
                Set (HelpTextAttr, Colour (Value))
            endif

            // alternative attributes

        when "altcurrwinborderattr"
            if FarbEinstellung == _MONO_
                Set (CurrWinBorderAttr, Colour (Value))
            endif
        when "altotherwinborderattr"
            if FarbEinstellung == _MONO_
                Set (OtherWinBorderAttr, Colour (Value))
            endif
        when "altmenutextattr"
            if FarbEinstellung == _MONO_
                Set (MenuTextAttr, Colour (Value))
            endif
        when "altmenutextltrattr"
            if FarbEinstellung == _MONO_
                Set (MenuTextLtrAttr, Colour (Value))
            endif
        when "altmenuborderattr"
            if FarbEinstellung == _MONO_
                Set (MenuBorderAttr, Colour (Value))
            endif
        when "altmenuselectattr"
            if FarbEinstellung == _MONO_
                Set (MenuSelectAttr, Colour (Value))
            endif
        when "altmenuselectltrattr"
            if FarbEinstellung == _MONO_
                Set (MenuSelectLtrAttr, Colour (Value))
            endif
        when "altblockattr"
            if FarbEinstellung == _MONO_
                Set (BlockAttr, Colour (Value))
            endif
        when "altcursorinblockattr"
            if FarbEinstellung == _MONO_
                Set (CursorInBlockAttr, Colour (Value))
            endif
        when "altcursorattr"
            if FarbEinstellung == _MONO_
                Set (CursorAttr, Colour (Value))
            endif
        when "althiliteattr"
            if FarbEinstellung == _MONO_
                Set (HiLiteAttr, Colour (Value))
            endif
        when "alttextattr"
            if FarbEinstellung == _MONO_
                Set (TextAttr, Colour (Value))
            endif
        when "alteofmarkerattr"
            if FarbEinstellung == _MONO_
                Set (EofMarkerAttr, Colour (Value))
            endif
        when "altmsgattr"
            if FarbEinstellung == _MONO_
                Set (MsgAttr, Colour (Value))
            endif
        when "altstatuslineattr"
            if FarbEinstellung == _MONO_
                Set (StatusLineAttr, Colour (Value))
            endif

            // alternative help attributes

        when "althelpinfoattr"
            if FarbEinstellung == _MONO_
                Set (HelpInfoAttr, Colour (Value))
            endif
        when "althelplinkattr"
            if FarbEinstellung == _MONO_
                Set (HelpLinkAttr, Colour (Value))
            endif
        when "althelpselectattr"
            if FarbEinstellung == _MONO_
                Set (HelpSelectAttr, Colour (Value))
            endif
        when "althelpboldattr"
            if FarbEinstellung == _MONO_
                Set (HelpBoldAttr, Colour (Value))
            endif
        when "althelptextattr"
            if FarbEinstellung == _MONO_
                Set (HelpTextAttr, Colour (Value))
            endif

            // printing options

        when "printleftmargin"
            Set (PrintLeftMargin, Val (Value))
        when "printrightmargin"
            Set (PrintRightMargin, Val (Value))
        when "printlinesperpage"
            Set (PrintLinesPerPage, Val (Value))
        when "printtopmargin"
            Set (PrintTopMargin, Val (Value))
        when "printbotmargin"
            Set (PrintBotMargin, Val (Value))
        when "printlinespacing"
            Set (PrintLineSpacing, Val (Value))
        when "printlinenumbers"
            Set (PrintLineNumbers, Flag (Value))
        when "printheader"
            Set (PrintHeader, Value)
        when "printfooter"
            Set (PrintFooter, Value)
        when "printfirstpage"
            Set (PrintFirstPage, Val (Value))
        when "printlastpage"
            Set (PrintLastPage, Val (Value))
        when "printcopies"
            Set (PrintCopies, Val (Value))
        when "printdevice"
            Set (PrintDevice, Value)
        when "printinit"
            Set (PrintInit, Value)
        when "printpause"
            Set (PrintPause, Flag (Value))
        when "printaddff"
            Set (PrintAddFF, Flag (Value))
        when "printuseff"
            Set (PrintUseFF, Flag (Value))
    endcase
end


proc ProcessFile ()
    string VarName [NameSize], Value [StringSize]

    if lFind ('Config', 'Iw')
        FarbEinstellung= Query (AttrSet)
//        if FarbEinstellung == _COLOR_         // debugging aid
//            Warn ('Color screen!')
//            Warn ('Farbbildschirm!')
//        else
//            Warn ('Monochrome screen!')
//            Warn ('Monochrombildschirm!')
//        endif

        Down ()

        while lFind ('^[A-Za-z]*[ \t]*=', 'x')
            BegLine ()
            MarkWord ()
            VarName= GetMarkedText ()
            UnMarkBlock ()

            if lFind ('=', '')
                Right ()
                while isWhite ()
                    Right ()
                endwhile

                MarkChar ()
                EndLine ()

                Value= GetMarkedText ()
                UnMarkBlock ()

                if (Value [1] == '"') or (Value [1] == "'")
                    Value= SubStr (Value, 2, Length (Value)- 2)
                endif
            else
                Value= ''
            endif

            InterpretConfig (VarName, Value)
            EndLine ()
        endwhile
    endif
end


proc ReadConfig (string CfgFile)
    integer WorkBuffer = EditFile (CfgFile)      // config-endconfig Definitionen

    if WorkBuffer
        GotoBufferId (WorkBuffer)
        BufferType (_SYSTEM_)   /* don't show the file contents */
        ProcessFile ()          /* as the display is built indirectly */
        AbandonFile (WorkBuffer)
    else
//        Warn ('"'+ CfgFile+ '" nicht gefunden!')
        Warn ('"'+ CfgFile+ '" not found!')
    endif
end


proc  main ()

    HomeDir= GetEnvStr (HomeDir)
    if HomeDir <> ""
        if HomeDir [Length (HomeDir)] <> "\"
            HomeDir= HomeDir+ CfgDir
            SetGlobalStr ("WriteCfgFileName", HomeDir+ UserCfg)
        endif
    endif

    ReadConfig (HomeDir+ UserCfg)
//    Warn ("User_TSEstart geladen")
    PurgeMacro (CurrMacroFilename ())
    UpdateDisplay (_ALL_WINDOWS_REFRESH_)

    if HomeDir <> ""        // TSE-Pfad erweitern fuer private Konfig-Dateien
    // extend TSEpath for special config files (may also contain macros)
        Set (TSEpath, HomeDir+ ";"+ Query (TSEpath))
    endif
end