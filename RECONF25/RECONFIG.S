/*************************************************************************

  RECONFIG.S  Editor start up macro for use of different configurations.
              Editor-Start-Makro zum Benutzen verschiedener Konfigurationen.

  Author:     Dr. Sieghard Schicktanz, Kreidestr. 12, 8196 Achmuehle

  Date:       Feb 19, 1995 - initial version
              Mar 22, 1996 - included writing of config file,
                             support of TSE Pro 2.5
              Mar 30, 1996 - full support of TSE Pro 2.5

  Overview:

  This macro loads a specific configuration from a file in a specific
  directory which can be specified by means of an environment variable
  named "HOMEDIR", possibly qualified by a subdirectory appended to it.
  The new version also supports writing such a file, which has nearly the
  same format as the file created by TSE's "iconfig" macro.

(German comments added on request:)
  Dieses Makro lÑdt eine sezifische Konfigurations aus einer Datei in einem
  speziellen Verzeichnis, das mit einer Environmentvariablen namens "HOMEDIR"
  definiert werden kann, eventuell durch ein Unterverzeichnis noch weiter
  spezifiziert.
  Die neue Version unterstÅtzt jetzt auch das Schreiben einer solchen Datei,
  die fast dasselbe Format wie das von TSEs "iconfig"-Makro erzeugte besitzt.

  Keys:       (none)

  Usage notes:

  This macro does not have any key assignments.
  There are a couple of limitations:
  - It can only process one set of color settings appropriate to the
    screen mode at load time.
  - "WordSet" and "TabSet" are supported now.
  - It can take a macro command line to elicit one of the following
    actions:
      nothing or
      "LOAD"  alone      loads the configuration in the standard file
      "LOAD <filename>"  loads the configuration in the specified file
      "SAVE"  alone      tries to write the current configuration to
                         the standard file; if this exists, it asks for
                         confirmation, allowing input of a new filename,
                         and writes the configuration to the given file
      "SAVE <filename>"  writes the configuration to the specified file.

  Das Makro benutzt keine Tastenzuweisungen.
  Es hat ein paar EinschrÑnkungen:
  - Es kann nur einen Satz Farbeinstellungen benutzen, der dem Bildschirm-
    Modus beim Laden entspricht.
  - "WordSet" und "TabSet" werden jetzt unterstÅtzt.
  - Es kann eine Makro-Befehlszeile verarbeiten, um eine der folgenden Aktionen
    zu erzielen:
      nichts oder
      "LOAD"  allein     lÑdt die Konfiguration aus der Standard-Datei
      "LOAD <filename>"  lÑdt die Konfiguration aus der angegebenen Datei
      "SAVE"  allein     versucht die aktuelle Konfiguration in die
                         Standard-Datei zu schreiben; wenn diese existiert,
                         fragt es nach einer BestÑtigung oder erlaubt die
                         Eingabe eines neuen Dateinamens, und schreibt die
                         Konfiguration in die angegebene Datei
      "SAVE <filename>"  schreibt die Konfiguration in die angegebene Datei.

*************************************************************************/

constant StringSize = 255           // TSE string variable size
constant NameSize = 20              // arbitrary maximum length

string CfgDir  [5]  = "\TSE\"       // subdirectory for CFG files
string UserCfg [12] = "tse_user.cfg" // name of configuration file
string HomeDir [64] = "HOMEDIR"     // name of environment variable

string ColorNames [] = 'Black  Blue   Green  Cyan   Red    MagentaYellow White  Bright Blink'

integer FarbEinstellung             // buffer for actual color setting


integer proc FlagVal (string Value)
    return (Lower (Value) == "on")
end


string proc FuncString (string Value)
    integer ON
    string  Result [255] = ""

    ON= Pos ('(', Value)            // "<function name>(" in front?
    if ON                           // to be deleted!
        Result= Value [ON+ 1..Length (Value)]

        if (Result [1] == '"') or (Result [1] == "'")
            Result= Result [2..Length (Result)- 2]
        endif
    endif

    return (Result)
end


string proc CharString (string rawSet)
    integer i, c = 0, run = -1
    string CharSet [32] = ''

    for i= 1 to 32
        CharSet= CharSet+ chr (0)
    endfor

    if (rawSet [1] == '-') or (rawSet [Length (rawSet)] == '-')
        CharSet [Asc ('-')/8+ 1]= chr (1 shl (Asc ('-') mod 8))
    endif

    i= iif (rawSet [1] <> '-', 1, 2)

    while i <= Length (rawSet)
        case rawSet [i]
            when '\'
                case rawSet [i+1]
                    when 'd'
                        c= Val (rawSet [i+2..i+4])
                        i= i+ 4
                    when 'x'
                        c= Val (rawSet [i+2..i+3], 16)
                        i= i+ 3
                    otherwise
                        c= Asc (rawSet [i+ 1])
                        i= i+ 1
                endcase
                CharSet [c/8+ 1]= chr (Asc (CharSet [c/8+ 1]) | (1 shl (c mod 8)))
            when '-'
                run= Asc (rawSet [i- 1])
            otherwise
                c= Asc (rawSet [i])
                if run == -1
                    CharSet [c/8+ 1]= chr (Asc (CharSet [c/8+ 1]) | (1 shl (c mod 8)))
                else
                    for c= run to Asc (rawSet [i])
                        CharSet [c/8+ 1]= chr (Asc (CharSet [c/8+ 1]) | (1 shl (c mod 8)))
                    endfor
                endif
                run= -1
        endcase
        i= i+ 1
    endwhile

    return (CharSet)
end


string proc ValueString (string rawSet)
    integer i, bit
    string ValueSet [32] = Format ('': 32: chr (0))

    for i= 1 to NumTokens (rawSet, ' ')
        bit= Val (GetToken (rawSet, ' ', i))
        ValueSet [bit/8+ 1]= chr (Asc (ValueSet [bit/8+ 1]) | (1 shl (bit mod 8)))
    endfor

    return (ValueSet)
end


integer proc ASCII (string Value)
    integer ON

    ON= Pos ('(', Value)            // "Asc(" in front?
    if ON                           // to be deleted!
        return (Asc (Value [ON+ 2]))
    endif
    return (Val (Value))            // else specify numerically
end


integer proc Enumerated (string Value)
    integer i = 0
    string Enum [24] = Value

    repeat
        i= Pos (' ', Enum)
        if i == 0
            i= Pos ('_', Enum)
        endif
        if i
            Enum= DelStr (Enum, i, 1)
        endif
    until i == 0

    case Enum
        when "autodetect"
            return (_AUTO_DETECT_)
        when "color"
            return (_COLOR_)
        when "mono"
            return (_MONO_)
        when "25lines"
            return (_25_LINES_)
        when "28lines"
            return (_28_LINES_)
        when "30lines"
            return (_30_LINES_)
        when "33lines"
            return (_33_LINES_)
        when "36lines"
            return (_36_LINES_)
        when "40lines"
            return (_40_LINES_)
        when "44lines"
            return (_44_LINES_)
        when "50lines"
            return (_50_LINES_)
        when "sticky"
            return (_STICKY_)
        when "hard"
            return (_HARD_)
        when "soft"
            return (_SOFT_)
        when "smart"
            return (_SMART_)
        when "variable"
            return (_VARIABLE_)
        when "none"
            return (_NONE_)
        when "startupfilemgr"
            return (_STARTUP_FILEMGR_)
        when "startuprecentfiles"
            return (_STARTUP_RECENTFILES_)
        when "startuppicklist"
            return (_STARTUP_PICKLIST_)
        when "startupunnamed"
            return (_STARTUP_UNNAMED_)
        when "startuprestorestate"
            return (_STARTUPRESTORESTATE_)
        when "startupnomac"
            return (_STARTUPNOMAC_)
        when "startupnoedit"
            return (_STARTUPNOEDIT_)
        when "adddirs"
            return (_ADD_DIRS_)
        when "addslash"
            return (_ADD_SLASH_)
        when "dirsattop"
            return (_DIRS_AT_TOP_)
    endcase

    return (0)
end


integer proc EnumVal (string Value)
    integer i, Enum = 0

    case Lower (Value)
        when "on"
            return (TRUE)
        when "off"
            return (FALSE)
    endcase

    if Pos ('_', Value)
        for i= 1 to NumTokens (Value, '|')
            Enum= Enum | Enumerated (Lower (GetToken (Value, '|', i)))
        endfor
    else
        Enum= Val (Value)
    endif

    return (Enum)
end


integer proc Attribute (string Colour)
    integer i
    string Col [8] = Lower (Colour)

    Col [1]= Upper (Col [1])
    i= Pos (Col, ColorNames)/ 7

    return (iif (i < 9, i, 128))    // Blink
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


integer proc SetColorAttr (string VarName, string Value)
    integer alt = Pos ('attr', VarName)
    string  AttrName [30] = VarName

    if (alt+ 3 == Length (VarName)) and alt             // must be color

        alt= AttrName [1:3] == 'alt'

        if alt
            AttrName= VarName [4: 255]                  // mono attributes
        endif

        if ((FarbEinstellung == _COLOR_) and not alt)   // color attributes
        or ((FarbEinstellung == _MONO_) and alt )       // alternative attributes

            case AttrName
                when "currwinborderattr"
                    Set (CurrWinBorderAttr, Colour (Value))
                when "otherwinborderattr"
                    Set (OtherWinBorderAttr, Colour (Value))
                when "menutextattr"
                    Set (MenuTextAttr, Colour (Value))
                when "menutextltrattr"
                    Set (MenuTextLtrAttr, Colour (Value))
                when "menuborderattr"
                    Set (MenuBorderAttr, Colour (Value))
                when "menuselectattr"
                    Set (MenuSelectAttr, Colour (Value))
                when "menuselectltrattr"
                    Set (MenuSelectLtrAttr, Colour (Value))
                when "blockattr"
                    Set (BlockAttr, Colour (Value))
                when "cursorinblockattr"
                    Set (CursorInBlockAttr, Colour (Value))
                when "cursorattr"
                    Set (CursorAttr, Colour (Value))
                when "hiliteattr"
                    Set (HiLiteAttr, Colour (Value))
                when "textattr"
                    Set (TextAttr, Colour (Value))
                when "eofmarkerattr"
                    Set (EOFMarkerAttr, Colour (Value))
                when "msgattr"
                    Set (MsgAttr, Colour (Value))
                when "statuslineattr"
                    Set (StatusLineAttr, Colour (Value))

                    // help attributes

                when "helpinfoattr"
                    Set (HelpInfoAttr, Colour (Value))
                when "helplinkattr"
                    Set (HelpLinkAttr, Colour (Value))
                when "helpselectattr"
                    Set (HelpSelectAttr, Colour (Value))
                when "helpboldattr"
                    Set (HelpBoldAttr, Colour (Value))
                when "helptextattr"
                    Set (HelpTextAttr, Colour (Value))
            endcase
        endif

        return (TRUE)
    endif

    return (FALSE)
end


proc InterpretConfig (string VarName, string Value)

//    Warn (VarName+ ' = '+ Value)      // debugging message

    if not SetColorAttr (Lower (VarName), Value)

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
            when "startupflags"
                Set (StartUpFlags, EnumVal (Value))
            when "defaultext"
                Set (DefaultExt, Value)
            when "loadwildfromdos"
                Set (LoadWildFromDos, FlagVal (Value))
            when "loadwildfrominside"
                Set (LoadWildFromInside, FlagVal (Value))
            when "pickfilechangesdir"
                Set (PickFileChangesDir, FlagVal (Value))
            when "pickfileflags"
                Set (PickFileFlags, EnumVal (Value))
            when "pickfilesortorder"
                Set (PickFileSortOrder, Value)
            when "restoredironexit"
                Set (RestoreDirOnExit, FlagVal (Value))
            when "eoltype"
                Set (EOLType, Val (Value))
            when "eoftype"
                Set (EOFType, Val (Value))
            when "makebackups"
                Set (MakeBackups, FlagVal (Value))
            when "protectedsaves"
                Set (ProtectedSaves, FlagVal (Value))
            when "backupext"
                Set (BackupExt, Value)
            when "savestate"
                Set (SaveState, FlagVal (Value))

                // keyboard/mouse options

            when "useenhancedkbd"
                Set (UseEnhancedKbd, FlagVal (Value))
            when "equateenhancedkbd"
                Set (EquateEnhancedKBD, FlagVal (Value))
            when "useextendedkbddriver"
                Set (UseExtendedKbdDriver, FlagVal (Value))
            when "usemouse"
                Set (UseMouse, FlagVal (Value))
            when "mouseholdtime"
                Set (MouseHoldTime, Val (Value))
            when "mouserepeatdelay"
                Set (MouseRepeatDelay, Val (Value))
            when "lefthandedmouse"
                Set (LeftHandedMouse, FlagVal (Value))

                // command and format optio

            when "maxhistoryperlist"
                Set (MaxHistoryPerList, Val (Value))
            when "maxhistorysize"
                Set (MaxHistorySize, Val (Value))
            when "persistenthistory"
                Set (PersistentHistory, FlagVal (Value))
            when "maxrecentfiles"
                Set (MaxRecentFiles, Val (Value))
            when "wordset"
                Set (WordSet, CharString (FuncString (Value)))     // not available easily
            when "findoptions"
                Set (FindOptions, Value)
            when "replaceoptions"
                Set (ReplaceOptions, Value)
            when "centerfinds"
                Set (CenterFinds, FlagVal (Value))
            when "beep"
                Set (Beep, FlagVal (Value))
            when "changeshellprompt"
                Set (ChangeShellPrompt, FlagVal (Value))
            when "quittoprompt"
                Set (QuitToPrompt, FlagVal (Value))
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
                Set (Insert, FlagVal (Value))
            when "autoindent"
                Set (AutoIndent, EnumVal (Value))
            when "wordwrap"
                Set (WordWrap, FlagVal (Value))
            when "paraendstyle"
                Set (ParaEndStyle, FlagVal (Value))
            when "returneqnextline"
                Set (ReturnEqNextLine, FlagVal (Value))
            when "removetrailingwhite"
                Set (RemoveTrailingWhite, FlagVal (Value))
            when "linedrawtype"
                Set (LineDrawType, Val (Value))
            when "linedrawchar"
                Set (LineDrawChar, ASCII (Value))
            when "insertlineblocksabove"
                Set (InsertLineBlocksAbove, FlagVal (Value))
            when "usecurrlineifnoblock"
                Set (UseCurrLineIfNoBlock, FlagVal (Value))
            when "unmarkafterpaste"
                Set (UnMarkAfterPaste, FlagVal (Value))

                // tab and border options

            when "tabtype"
                Set (TabType, EnumVal (Value))
            when "tabwidth"
                Set (TabWidth, Val (Value))
            when "vartabs"
                Set (VarTabs, ValueString (FuncString (Value)))     // not available easily
            when "expandtabs"
                Set (ExpandTabs, FlagVal (Value))
            when "leftmargin"
                Set (LeftMargin, Val (Value))
            when "rightmargin"
                Set (RightMargin, Val (Value))

                // screen and color options

            when "statuslineattop"
                Set (StatusLineAtTop, FlagVal (Value))
            when "statuslinefillchar"
                Set (StatusLineFillChar, ASCII (Value))
            when "showmainmenu"
                Set (ShowMainMenu, FlagVal (Value))
            when "showhelpline"
                Set (ShowHelpLine, FlagVal (Value))
            when "helplinedelay"
                Set (HelpLineDelay, Val (Value))
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
                Set (ShowEOFMarker, FlagVal (Value))
            when "startupvideomode"
                Set (CurrVideoMode, EnumVal (Value))
            when "eliminatesnow"
                Set (EliminateSnow, FlagVal (Value))
            when "startupattrset"
                case EnumVal (Value)
                    when _MONO_
                        FarbEinstellung= _MONO_
                    when _COLOR_
                        FarbEinstellung= _COLOR_
                    when _AUTO_DETECT_
                        FarbEinstellung= Query (AttrSet)
                    otherwise
                        FarbEinstellung= Val (Value)
                endcase

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
                Set (PrintLineNumbers, FlagVal (Value))
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
                Set (PrintPause, FlagVal (Value))
            when "printaddff"
                Set (PrintAddFF, FlagVal (Value))
            when "printuseff"
                Set (PrintUseFF, FlagVal (Value))
        endcase
    endif
end


proc ProcessFile ()
    string VarName [NameSize], Value [StringSize]

    if lFind ('Config', 'Iw')
        FarbEinstellung= Query (AttrSet)
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


proc ReadUserConfig (string CfgFile)
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


datadef BeginConfig
    '//'
    '// Die Werte der Optionen wurden wie von der deutschen Version'
    '// des Editors so in diese Datei geschrieben, da· diese ohne'
    '// Probleme von der US Version eingelesen und verarbeitet'
    '// werden kann. Aus diesem Grund enthÑlt diese Datei nicht ins'
    '// Deutsche Åbertragene Elemente.'
    ''
    ''
    'Config'
    ''
    '// System- und Dateioptionen'
    ''
    ''
    'MaxXMS                  = '
    'MaxEMS                  = '
    'SwapPath                = '
    'TSEPath                 = '
    'KbdPath                 = '
    'StartUpFlags            = '
    'DefaultExt              = '
    'LoadWildFromDos         = '
    'LoadWildFromInside      = '
    'PickFileChangesDir      = '
    'PickFileFlags           = '
    'PickFileSortOrder       = '
    'RestoreDirOnExit        = '
    'EOLType                 = '
    'EOFType                 = '
    'MakeBackups             = '
    'ProtectedSaves          = '
    'BackupExt               = '
    'SaveState               = '
    ''
    '// Tastatur- und Mausoptionen'
    ''
    'UseEnhancedKbd          = '
    'EquateEnhancedKBD       = '
    'UseExtendedKbdDriver    = '
    'UseMouse                = '
    'MouseHoldTime           = '
    'MouseRepeatDelay        = '
    'LeftHandedMouse         = '
    ''
    '// Befehls- und Formatoptionen'
    ''
    'MaxHistoryPerList       = '
    'MaxHistorySize          = '
    'PersistentHistory       = '
    'MaxRecentFiles          = '
    'PersistentRecentFiles   = '
    'WordSet                 = '
    'FindOptions             = '
    'ReplaceOptions          = '
    'CenterFinds             = '
    'Beep                    = '
    'ChangeShellPrompt       = '
    'QuitToPrompt            = '
    'DateFormat              = '
    'DateSeparator           = '
    'TimeFormat              = '
    'TimeSeparator           = '
    ''
    '// Texteingabe- und Blockoptionen'
    ''
    'Insert                  = '
    'AutoIndent              = '
    'WordWrap                = '
    'ParaEndStyle            = '
    'ReturnEqNextLine        = '
    'RemoveTrailingWhite     = '
    'LineDrawType            = '
    'LineDrawChar            = '
    'InsertLineBlocksAbove   = '
    'UseCurrLineIfNoBlock    = '
    'UnMarkAfterPaste        = '
    ''
    '// Tabulator- und RÑnderoptionen'
    ''
    'TabType                 = '
    'TabWidth                = '
    'VarTabs                 = '
    'ExpandTabs              = '
    'LeftMargin              = '
    'RightMargin             = '
    ''
    '// Bildschirm- und Farboptionen'
    ''
    'StatusLineAtTop         = '
    'StatusLineFillChar      = '
    'ShowMainMenu            = '
    'ShowHelpLine            = '
    'HelpLineDelay           = '
    'CurrWinBorderType       = '
    'OtherWinBorderType      = '
    'DisplayBoxed            = '
    'InsertCursorSize        = '
    'OverwriteCursorSize     = '
    'ShowEOFMarker           = '
    'StartupVideoMode        = '
    'EliminateSnow           = '
    'StartupAttrSet          = '
    ''
    '// Farbattribute'
    ''
    'CurrWinBorderAttr       = '
    'OtherWinBorderAttr      = '
    'MenuTextAttr            = '
    'MenuTextLtrAttr         = '
    'MenuBorderAttr          = '
    'MenuSelectAttr          = '
    'MenuSelectLtrAttr       = '
    'BlockAttr               = '
    'CursorInBlockAttr       = '
    'CursorAttr              = '
    'HiLiteAttr              = '
    'TextAttr                = '
    'EOFMarkerAttr           = '
    'MsgAttr                 = '
    'StatusLineAttr          = '
    ''
    '// Hilfeattribute'
    ''
    'HelpInfoAttr            = '
    'HelpLinkAttr            = '
    'HelpSelectAttr          = '
    'HelpBoldAttr            = '
    'HelpTextAttr            = '
    ''
    '// Druckausgabeoptionen'
    ''
    'PrintLeftMargin         = '
    'PrintRightMargin        = '
    'PrintLinesPerPage       = '
    'PrintTopMargin          = '
    'PrintBotMargin          = '
    'PrintLineSpacing        = '
    'PrintLineNumbers        = '
    'PrintHeader             = '
    'PrintFooter             = '
    'PrintFirstPage          = '
    'PrintLastPage           = '
    'PrintCopies             = '
    'PrintDevice             = '
    'PrintInit               = '
    'PrintPause              = '
    'PrintAddFF              = '
    'PrintUseFF              = '
    ''
    'EndConfig'
end BeginConfig


string proc FlagName (integer flg)
    return (iif (flg, 'On', 'Off'))
end


string proc ColorName (integer ColorVal)
    integer i = Pos (' ', ColorNames [(ColorVal* 7)+ 1: 7])

    return (ColorNames [(ColorVal* 7)+ 1: iif (i, i- 1, 7)])
end


string proc ColorDefinition (integer ColorVal)
    string Colour [30] = ''

    if ColorVal & 128   // Blink
        Colour= 'Blink '
    endif

    if ColorVal & 8     // Bright
        Colour= Colour+ 'Bright '
    endif

    return (Colour+ ColorName (ColorVal & 7)+ ' on '+ ColorName ((ColorVal shr 4) & 7))
end


string proc CharSet (string rawSet)
    integer i, prev= -1
    string SetOfChars [StringSize] = ''

    for i= 0 to 255
        if Asc (rawSet [i/8+ 1]) & (1 shl (i mod 8))
            if prev == -1
                case i
                    when 0..15
                        SetOfChars= SetOfChars+ '\x0'+ Str (i, 16)
                    when 16..31
                        SetOfChars= SetOfChars+ '\x'+ Str (i, 16)
                    when Asc ('-')
                        SetOfChars= chr (i)+ SetOfChars
                    when Asc ('\'), Asc ('"')
                        SetOfChars= SetOfChars+ '\'+ chr (i)
                    otherwise
                        SetOfChars= SetOfChars+ chr (i)
                endcase
            endif
            prev= i
        else
            if (prev <> -1) and (chr (prev) <> SetOfChars [Length (SetOfChars)])
                SetOfChars= SetOfChars+ iif (chr (prev- 1) == SetOfChars [Length (SetOfChars)], '', '-')+ chr (prev)
            endif
            prev= -1
        endif
    endfor

    return (SetOfChars)
end


string proc ValueSet (string rawSet)
    integer i
    string SetOfValues [StringSize] = ''

    for i= 0 to 255
        if Asc (rawSet [i/8+ 1]) & (1 shl (i mod 8))
            SetOfValues= SetOfValues+ iif (SetOfValues == '', '', ' ')+ Str (i)
        endif
    endfor

    return (SetOfValues)
end


string proc SaveUserSettings ()
    string UserPath [StringSize] = iif (ExistGlobalVar ("WriteCfgFileName"), GetGlobalStr ("WriteCfgFileName"), '')

    if UserPath == ''
        HomeDir= GetEnvStr (HomeDir)
        if HomeDir <> ""
            if HomeDir [Length (HomeDir)] <> "\"
                HomeDir= HomeDir+ CfgDir
                UserPath= HomeDir+ UserCfg
            endif
        else
            UserPath= UserCfg       // aktuelle Directory...
        endif
    endif

    if FileExists (UserPath)
        if YesNo ("Aktuelle Konfiguration Åberschreiben?") == 1
            return (UserPath)
        else
            UserPath= ExpandPath (UserPath)
            if Ask ('Dateiname fÅr die Einstellungen: ['+ UserPath+ ']', UserPath)
                return (UserPath)
            endif
        endif
    endif

    return ('')
end


string proc CleanTSEPath ()
    integer pp = 0
    string cleanPath [StringSize] = Query (TSEPath)

    HomeDir= GetEnvStr (HomeDir)
    if HomeDir <> ""        // TSE-Pfad bereinigen
        pp= Pos (HomeDir, cleanPath)
        if pp
            cleanPath= cleanPath [1: pp- 1]+ cleanPath [pp+ Length (HomeDir)+ 1: Length (cleanPath)]
        endif
    endif

    return (cleanPath)
end


proc AddValue (string VarName, string Value)
    if lFind (VarName, 'gw')
        EndLine ()
        InsertText (Value)
    endif
end


proc WriteUserConfig (string SaveCfg)
    integer CfgText = CreateBuffer (SaveCfg, _SYSTEM_)

    if CfgText
        CfgText= GotoBufferId (CfgText)     // alte Stelle merken
        PushBlock ()

        AddLine ('//')
        AddLine ('// Optionen erstellt von ReConfig '+ GetDateStr ()+ ' um '+ GetTimeStr ())
        AddLine ()
        InsertData (BeginConfig)
        EndFile ()
        AddValue ('MaxXMS',                Str (Query (MaxXMS)))
        AddValue ('MaxEMS',                Str (Query (MaxEMS)))
        AddValue ('SwapPath',              "'"+ Query (SwapPath)+ '"')
        AddValue ('TSEPath',               "'"+ CleanTSEPath ()+ '"')
        AddValue ('KbdPath',               "'"+ Query (KbdPath)+ '"')
        AddValue ('StartUpFlags',          Str (Query (StartUpFlags)))
        AddValue ('DefaultExt',            "'"+ Query (DefaultExt)+ '"')
        AddValue ('LoadWildFromDos',       FlagName (Query (LoadWildFromDos)))
        AddValue ('LoadWildFromInside',    FlagName (Query (LoadWildFromInside)))
        AddValue ('PickFileChangesDir',    FlagName (Query (PickFileChangesDir)))
        AddValue ('PickFileFlags',         Str (Query (PickFileFlags)))
        AddValue ('PickFileSortOrder',     "'"+ Query (PickFileSortOrder)+ '"')
        AddValue ('RestoreDirOnExit',      FlagName (Query (RestoreDirOnExit)))
        AddValue ('EOLType',               Str (Query (EOLType))+ '     // 1=^M (CR), 2=^J (LF), 3=^M^J (CR/LF)')
        AddValue ('EOFType',               Str (Query (EOFType))+ '     // 0=Nichts, 1=^Z, 2=Zeilenendezeichen, 3=Zeilenendezeichen+^Z')
        AddValue ('MakeBackups',           FlagName (Query (MakeBackups)))
        AddValue ('ProtectedSaves',        FlagName (Query (ProtectedSaves)))
        AddValue ('BackupExt',             "'"+ Query (BackupExt)+ '"')
        AddValue ('SaveState',             FlagName (Query (SaveState)))

        AddValue ('UseEnhancedKbd',        FlagName (Query (UseEnhancedKbd)))
        AddValue ('EquateEnhancedKBD',     FlagName (Query (EquateEnhancedKBD)))
        AddValue ('UseExtendedKbdDriver',  FlagName (Query (UseExtendedKbdDriver)))
        AddValue ('UseMouse',              FlagName (Query (UseMouse)))
        AddValue ('MouseHoldTime',         Str (Query (MouseHoldTime))+ '     // 18 entspricht etwa 1 Sekunde')
        AddValue ('MouseRepeatDelay',      Str (Query (MouseRepeatDelay)))
        AddValue ('LeftHandedMouse',       FlagName (Query (LeftHandedMouse)))

        AddValue ('MaxHistoryPerList',     Str (Query (MaxHistoryPerList)))
        AddValue ('MaxHistorySize',        Str (Query (MaxHistorySize)))
        AddValue ('PersistentHistory',     FlagName (Query (PersistentHistory)))
        AddValue ('MaxRecentFiles',        Str (Query (MaxRecentFiles)))
        AddValue ('PersistentRecentFiles', FlagName (Query (PersistentRecentFiles)))
        AddValue ('WordSet',               'ChrSet("'+ CharSet (Query (WordSet))+ '")')           // faked !!
        AddValue ('FindOptions',           "'"+ Query (FindOptions)+ '"')
        AddValue ('ReplaceOptions',        "'"+ Query (ReplaceOptions)+ '"')
        AddValue ('CenterFinds',           FlagName (Query (CenterFinds)))
        AddValue ('Beep',                  FlagName (Query (Beep)))
        AddValue ('ChangeShellPrompt',     FlagName (Query (ChangeShellPrompt)))
        AddValue ('QuitToPrompt',          FlagName (Query (QuitToPrompt)))
        AddValue ('DateFormat',            Str (Query (DateFormat))+ '     // 1=MM.TT.JJ, 2=TT.MM.JJ, 3=JJ.MM.TT')
        AddValue ('DateSeparator',         "= Asc('"+ chr (Query (DateSeparator))+ "')")
        AddValue ('TimeFormat',            Str (Query (TimeFormat))+ '     // 1=24 Std. (HH:MM:SS), 2=12 Std. (HH:MM am/pm)')
        AddValue ('TimeSeparator',         "= Asc('"+ chr (Query (TimeSeparator))+ "')")

        AddValue ('Insert',                FlagName (Query (Insert)))
        AddValue ('AutoIndent',            Str (Query (AutoIndent)))
        AddValue ('WordWrap',              FlagName (Query (WordWrap)))
        AddValue ('ParaEndStyle',          FlagName (Query (ParaEndStyle)))
        AddValue ('ReturnEqNextLine',      FlagName (Query (ReturnEqNextLine)))
        AddValue ('RemoveTrailingWhite',   FlagName (Query (RemoveTrailingWhite)))
        AddValue ('LineDrawType',          Str (Query (LineDrawType))+ '         // 1=⁄ƒø, 2=’Õ∏, 3=÷ƒ∑, 4=…Õª, 5=ASCII, 6=Lîschen, 7=Anwender')
        AddValue ('LineDrawChar',          "= Asc('"+ chr (Query (LineDrawChar))+ "')  // wird verwendet, wenn LineDrawType == 7")
        AddValue ('InsertLineBlocksAbove', FlagName (Query (InsertLineBlocksAbove)))
        AddValue ('UseCurrLineIfNoBlock',  FlagName (Query (UseCurrLineIfNoBlock)))
        AddValue ('UnMarkAfterPaste',      FlagName (Query (UnMarkAfterPaste)))

        AddValue ('TabType',               Str (Query (TabType)))
        AddValue ('TabWidth',              Str (Query (TabWidth)))
        AddValue ('VarTabs',               '= TabSet("'+ ValueSet (Query (VarTabs))+ '")')                // faked !!
        AddValue ('ExpandTabs',            FlagName (Query (ExpandTabs)))
        AddValue ('LeftMargin',            Str (Query (LeftMargin)))
        AddValue ('RightMargin',           Str (Query (RightMargin)))

        AddValue ('StatusLineAtTop',       FlagName (Query (StatusLineAtTop)))
        AddValue ('StatusLineFillChar',    "= Asc('"+ chr (Query (StatusLineFillChar))+ "')")
        AddValue ('ShowMainMenu',          FlagName (Query (ShowMainMenu)))
        AddValue ('ShowHelpLine',          FlagName (Query (ShowHelpLine)))
        AddValue ('HelpLineDelay',         Str (Query (HelpLineDelay)))
        AddValue ('CurrWinBorderType',     Str (Query (CurrWinBorderType))+ '     // 1=⁄ƒø, 2=’Õ∏, 3=÷ƒ∑, 4=…Õª, 5=ﬁﬂ›, 6=€ﬂ€')
        AddValue ('OtherWinBorderType',    Str (Query (OtherWinBorderType))+ '     // 1=⁄ƒø, 2=’Õ∏, 3=÷ƒ∑, 4=…Õª, 5=ﬁﬂ›, 6=€ﬂ€')
        AddValue ('DisplayBoxed',          Str (Query (DisplayBoxed))+ '     // 0=Niemals, 1=Maus, 2=Immer')
        AddValue ('InsertCursorSize',      Str (Query (InsertCursorSize))+ '     // 0=Kein Cursor, 1..8=Cursorgrî·e')
        AddValue ('OverwriteCursorSize',   Str (Query (OverwriteCursorSize))+ '     // 0=Kein Cursor, 1..8=Cursorgrî·e')
        AddValue ('ShowEOFMarker',         FlagName (Query (ShowEOFMarker)))
        AddValue ('StartupVideoMode',      Str (Query (StartupVideoMode)))
        AddValue ('EliminateSnow',         FlagName (Query (EliminateSnow)))
        AddValue ('StartupAttrSet',        Str (Query (StartupAttrSet)))

        AddValue ('CurrWinBorderAttr',     'Color('+ ColorDefinition (Query (CurrWinBorderAttr))+ ')')
        AddValue ('OtherWinBorderAttr',    'Color('+ ColorDefinition (Query (OtherWinBorderAttr))+ ')')
        AddValue ('MenuTextAttr',          'Color('+ ColorDefinition (Query (MenuTextAttr))+ ')')
        AddValue ('MenuTextLtrAttr',       'Color('+ ColorDefinition (Query (MenuTextLtrAttr))+ ')')
        AddValue ('MenuBorderAttr',        'Color('+ ColorDefinition (Query (MenuBorderAttr))+ ')')
        AddValue ('MenuSelectAttr',        'Color('+ ColorDefinition (Query (MenuSelectAttr))+ ')')
        AddValue ('MenuSelectLtrAttr',     'Color('+ ColorDefinition (Query (MenuSelectLtrAttr))+ ')')
        AddValue ('BlockAttr',             'Color('+ ColorDefinition (Query (BlockAttr))+ ')')
        AddValue ('CursorInBlockAttr',     'Color('+ ColorDefinition (Query (CursorInBlockAttr))+ ')')
        AddValue ('CursorAttr',            'Color('+ ColorDefinition (Query (CursorAttr))+ ')')
        AddValue ('HiLiteAttr',            'Color('+ ColorDefinition (Query (HiLiteAttr))+ ')')
        AddValue ('TextAttr',              'Color('+ ColorDefinition (Query (TextAttr))+ ')')
        AddValue ('EOFMarkerAttr',         'Color('+ ColorDefinition (Query (EOFMarkerAttr))+ ')')
        AddValue ('MsgAttr',               'Color('+ ColorDefinition (Query (MsgAttr))+ ')')
        AddValue ('StatusLineAttr',        'Color('+ ColorDefinition (Query (StatusLineAttr))+ ')')

        AddValue ('HelpInfoAttr',          'Color('+ ColorDefinition (Query (HelpInfoAttr))+ ')')
        AddValue ('HelpLinkAttr',          'Color('+ ColorDefinition (Query (HelpLinkAttr))+ ')')
        AddValue ('HelpSelectAttr',        'Color('+ ColorDefinition (Query (HelpSelectAttr))+ ')')
        AddValue ('HelpBoldAttr',          'Color('+ ColorDefinition (Query (HelpBoldAttr))+ ')')
        AddValue ('HelpTextAttr',          'Color('+ ColorDefinition (Query (HelpTextAttr))+ ')')

        AddValue ('PrintLeftMargin',       Str (Query (PrintLeftMargin)))
        AddValue ('PrintRightMargin',      Str (Query (PrintRightMargin)))
        AddValue ('PrintLinesPerPage',     Str (Query (PrintLinesPerPage)))
        AddValue ('PrintTopMargin',        Str (Query (PrintTopMargin)))
        AddValue ('PrintBotMargin',        Str (Query (PrintBotMargin)))
        AddValue ('PrintLineSpacing',      Str (Query (PrintLineSpacing))+ '         // 1=Einfach, 2=Doppelt, 3=Dreifach, usw...')
        AddValue ('PrintLineNumbers',      FlagName (Query (PrintLineNumbers)))
        AddValue ('PrintHeader',           "'"+ Query (PrintHeader)+ '"        // F=Dateiname, D=Datum, T=Zeit, P=Seite')
        AddValue ('PrintFooter',           "'"+ Query (PrintFooter)+ '"        // F=Dateiname, D=Datum, T=Zeit, P=Seite')
        AddValue ('PrintFirstPage',        Str (Query (PrintFirstPage)))
        AddValue ('PrintLastPage',         Str (Query (PrintLastPage)))
        AddValue ('PrintCopies',           Str (Query (PrintCopies)))
        AddValue ('PrintDevice',           "'"+ Query (PrintDevice)+ '"')
        AddValue ('PrintInit',             "'"+ Query (PrintInit)+ '"')
        AddValue ('PrintPause',            FlagName (Query (PrintPause)))
        AddValue ('PrintAddFF',            FlagName (Query (PrintAddFF)))
        AddValue ('PrintUseFF',            FlagName (Query (PrintUseFF)))

        if not SaveFile ()
            Warn ('Konfiguration konnte nicht gespeichert werden!')
        endif

        AbandonFile ()
        PopBlock ()
        GotoBufferId (CfgText)          // an alte Stelle zurueck
    else
        Warn ('Konfiguration konnte nicht gespeichert werden!')
    endif
end


proc WhenLoaded ()
    integer pp = 0
    string SaveCfg [80] = Upper (Query (MacroCmdLine))

    HomeDir= GetEnvStr (HomeDir)
    if HomeDir <> ""
        if HomeDir [Length (HomeDir)] <> "\"
            HomeDir= HomeDir+ CfgDir
            SetGlobalStr ("WriteCfgFileName", HomeDir+ UserCfg)
        endif
    endif

    case GetToken (SaveCfg, ' ', 1)
        when 'SAVE'
            pp= Pos (' ', SaveCfg)
            SaveCfg= iif (pp, SaveCfg [pp+ 1: Length (SaveCfg)], '')

            if SaveCfg == ''
                SaveCfg= SaveUserSettings ()

                if SaveCfg == ''
                    Message ('Konfiguration nicht abgespeichert!')
                    return ()
                endif
            endif

            if SaveCfg <> ''
                WriteUserConfig (SaveCfg)
            endif

        when 'LOAD'
            SaveCfg= SaveCfg [Pos (' ', SaveCfg)+ 1:Length (SaveCfg)]

            if SaveCfg <> ''
                ReadUserConfig (SaveCfg)
                UpdateDisplay (_ALL_WINDOWS_REFRESH_)
            endif

        otherwise
            ReadUserConfig (HomeDir+ UserCfg)
//            Warn ("User_TSEstart geladen")
            UpdateDisplay (_ALL_WINDOWS_REFRESH_)

            if HomeDir <> ""        // TSE-Pfad erweitern fuer private Konfig-Dateien
            // extend TSEpath for special config files (may also contain macros)
                Set (TSEpath, HomeDir+ ";"+ Query (TSEpath))
            endif
    endcase

    PurgeMacro (CurrMacroFilename ())
end


proc main ()
    WhenLoaded ()
end