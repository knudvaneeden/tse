/*
   Macro          SynCaseOld
   Author         Carlo Hogeveen
   Website        eCarlo.nl/tse
   Version        6   11 Jul 2017
   Compatibility  Windows TSE v4 upwards

   Short description
      Out of the box this macro sets the keywords of TSE's macro language
      to their default UPPER, lower, and CamelCase.

      Keywords are not cased when they occur in comments or quotes.

      Keywords are case for the current line as you type,
      and optionally for the whole file when you execute the macro.

      A nice addition to this macro version is, that the default for how
      keywords are cased is for about 75% determined either by how
      they are cased in the Help topics of your specific TSE version or
      by which keywords are defined as constants in the syntax hiliting
      configuration of your specific TSE version. And you can generate
      this default again if you ever change to another or even a future
      TSE version.

      Optionally you can reconfigure a lot of details,
      and you can configure other languages too.

   Detailed description
      Once installed, execute the macro and select Help.

   Quick install
      Put this file in TSE's "mac" folder, and open it with TSE.
      ( You don't need to rename it to SynCase.s, tho you can if you want to.
        SynCaseOld does not require auxiliary files. )
      Compile and execute it once using the Macro menu.
      "Do you want automatic upper/lower/camel case for TSE macros?"
      Select "Yes", "OK" the message, "Escape" the menu, and restart TSE.
      DONE!



   Major version change
      Version 6 is a major rewrite of the previous version.

      It is simplified and optimized by
      - doing TSE's own macro keyword casing out of the box,
      - adapting keyword casing to your specific TSE version,
        and even future ones,
      - no longer supporting TSE versions before 4.0,
      - no longer needing extra program files,
      - no longer using a syncase.dat file.

      About the latter: The new SynCase stores its high-level settings in TSE's
      standard profile file "tse.ini", and for the bulk of its settings it
      (re)uses TSE's syntax hiliting configuration.

      Therefore it and its files can coexist with the old macro if you rename
      either of them. It does not make sense to (auto)load both versions at
      the same time, but even that should theoretically be possible.



   Important internal design note:
      This macro and the called Semware macro SynCfg2 do NOT use any clipboard.
      Not having to save/restore a clipboard is a huge time saver.
*/



#ifdef WIN32
#else
   16-bit versions of TSE are not supported. You need at least TSE 4.0.
#endif

#ifdef EDITOR_VERSION
#else
   Editor Version is older than TSE 3.0. You need at least TSE 4.0.
#endif

#if EDITOR_VERSION < 4000h
   Editor Version is older than TSE 4.0. You need at least TSE 4.0.
#endif

#if EDITOR_VERSION < 4400h
   integer autoload_id = 0
   integer proc isAutoLoaded()
      integer org_id = GetBufferId()
      integer result = FALSE
      string old_wordset [32] = ''
      if not autoload_id
         autoload_id = CreateTempBuffer()
      endif
      if autoload_id
         GotoBufferId(autoload_id)
         LoadBuffer(LoadDir() + 'tseload.dat', -1)
         // Exclude unprintable and illegal filename characters.
         old_wordset = Set(WordSet, '~\d000-\d032\\/:\*\?"<>\|\d255')
         if lFind(SplitPath(CurrMacroFilename(), _NAME_), 'giw')
            result = TRUE
         endif
         Set(WordSet, old_wordset)
         GotoBufferId(org_id)
      endif
      return(result)
   end isAutoLoaded
#endif



integer hlp_id                                 = 0
string  init_ext                          [29] = 'non eksisting file eksension'
integer keywords_id                            = 0
string  macro_name              [MAXSTRINGLEN] = ''
integer main_clockticks                        = 0
string  mapping_name            [MAXSTRINGLEN] = 'non eksisting syntaks name'
integer max_syn_name_len                       = 0
string  menu_mapping_name       [MAXSTRINGLEN] = ''
integer restart_main_menu                      = FALSE
integer syncase_id                             = 0
integer variables_id                           = 0
integer whenloaded_clockticks                  = 0

string  syncase_ext                      [255] = ''
string  keyword_casing                     [4] = ''
string  non_keyword_casing                 [6] = ''
string  syncase_wordset                  [255] = ''
string  syncase_multilinedelimited1_from [255] = ''
string  syncase_multilinedelimited1_to   [255] = ''
string  syncase_multilinedelimited2_from [255] = ''
string  syncase_multilinedelimited2_to   [255] = ''
string  syncase_multilinedelimited3_from [255] = ''
string  syncase_multilinedelimited3_to   [255] = ''
string  syncase_tilleol1                 [255] = ''
string  syncase_tilleol2                 [255] = ''
string  syncase_tilleol3                 [255] = ''
string  syncase_tilleolstartcol1         [255] = ''
string  syncase_tilleolstartcol2         [255] = ''
string  syncase_tilleolstartcol3         [255] = ''
string  syncase_quote1                   [255] = ''
string  syncase_quote2                   [255] = ''
string  syncase_quote3                   [255] = ''
string  syncase_quoteescape1               [1] = ''
string  syncase_quoteescape2               [1] = ''
string  syncase_quoteescape3               [1] = ''

// State fields used when syntax casing the current line.
integer multiline_begin       = 0
integer multiline_end         = 0
integer outside_begin         = 0
integer outside_end           = 0
integer old_numlines          = 0
integer previous_line         = 0
integer previous_column       = 0
string  previous_word   [255] = ''
string  previouser_word [255] = ''



Datadef help_text
   ''
   '  Intro'
   ''
   '    Out of the box the keywords of the TSE macro language are set'
   '    to their default lower, UPPER and CamelCase.'
   ''
   '    That default is determined by how keywords are cased in the TSE Help'
   '    topics and by whether they occur in the Keywords5 section of the syntax'
   '    hiliting configuration. In practice that means, that for about three'
   '    quarters the default casing is determined by your specific TSE version!'
   ''
   '    Keywords are not cased when they occur in comments or quotes.'
   ''
   '    Casing happens for the current line as you type,'
   '    and optionally for the whole file when you execute the macro.'
   ''
   '    Optionally you can reconfigure this, and configure other languages too.'
   ''
   '    The standard TSE syntax hiliting configuration is (re)used as a basis,'
   '    and extended with a small syntax casing menu by executing this macro.'
   ''
   ''
   '  Quick install'
   ''
   '    Put this file in the TSE "mac" folder, and open the file with TSE.'
   ''
   '    Compile and execute it at least once using the Macro menu.'
   ''
   '    "Do you want automatic UPPER/lower/CamelCase for TSE macros?"'
   '    Select "Yes". "OK" the message. "Escape" the menu. Restart TSE.'
   ''
   '    DONE!'
   ''
   ''
   '  Example:'
   ''
   '    Open or create a file with file extension ".s", and (try to) type'
   '    the TSE keyword "editfile" in all lower case.'
   ''
   '    Unless commented or quoted, it should stubbornly remain "EditFile".'
   ''
   ''
   '  Uninstall:'
   ''
   '    Execute the macro, and set AutoLoad to "off".'
   ''
   '    After making a backup of the corresponding .syn files,'
   '    you may want to set the TSE syntax hiliting configuration option'
   '    "Ignore Case" back to "Off" for those mapping sets for which you'
   '    had syntax casing enabled. Especially "sal" and "synhi\sal.syn".'
   ''
   ''
   '  Configuration'
   ''
   '    Note that further configuration is optional.'
   ''
   '    That said, you might want to change the case of a specific keyword'
   '    to your own preference, or to configure casing for another language'
   '    than the Semware Application Language (SAL).'
   ''
   ''
   '    Syntax casing configuration'
   ''
   '      By executing this macro you can configure additional syntax casing'
   '      settings.'
   ''
   '      "Mapping set"           Select a mapping set for which you can set'
   '                              the next three configuration options.'
   ''
   '        "Keyword casing"      Should keywords be cased (on/off).'
   ''
   '        "Non-keyword casing"  Should non-keywords be cased (lower/upper/off).'
   '                              Can only be set to "on" with keyword casing.'
   '                              Should almost always be "off".'
   '                              Might be usefull for case-insensitive languages'
   '                              that do not use casing for word parts in names.'
   ''
   '        "Set to default case" (Re)sets all keywords to their default case.'
   '                              Can only be set for the mapping set "sal".'
   ''
   '      "AutoLoad"              This enables/disables (on/off) this macro'
   '                              the next time TSE is started.'
   ''
   ''
   '    Syntax hiliting configuration'
   ''
   '      The existing TSE syntax hiliting configuration is reused for'
   '      configuring syntax casing as well, so you can just use the'
   '      existing TSE syntax hilite configuration menu.'
   ''
   '      In the TSE menu'
   '        Full configuration'
   '          Display/Color options'
   '            Configure SyntaxHilite Mapping Sets'
   '      you can select a "mapping set" and configure syntax hiliting for it.'
   ''
   '      A mapping set is a group of file extensions that share the same syntax'
   '      hilite configuration, and when enabled the same syntax casing too.'
   '      "sal" is the mapping set for files with for instance the file'
   '      extensions .s (TSE macro sources) and .ui (TSE user interfaces).'
   ''
   '      This syntax casing macro uses and you can use the existing syntax'
   '      hiliting configuration menu to determine per mapping set:'
   '      - for which file extensions it applies,'
   '      - its wordset (what characters can make up a keyword),'
   '      - how comments can be recognized,'
   '      - how quotes can be recognized,'
   '      - what keywords make up the language,'
   '      - how those keywords should be cased!'
   ''
   '      The two most obvious settings for syntax casing are:'
   '      - Set "Ignore Case" to "OFF", so TSE allows upper case in keywords.'
   '      - Edit the keywords to give them newly cased letters.'
   ''
   '      WARNING! DANGER! CAVEAT! BEWARE!'
   '        For a syntax cased mapping set, the syntax hiliting option'
   '        "Ignore Case" must be set to OFF, and forever remain OFF!'
   '        If you ever set Ignore Case to ON, then all the keywords in the'
   '        syntax hiliting configuration for that mapping set are immediately'
   '        converted to lower case, so you lose your cased keyword definitions.'
   '        Only for SAL you can repair that by using the configuration menu'
   '        of this macro to set keywords back to their default case.'
   '        For other mapping sets you could restore the backup you made (?)'
   '        of the corresponding .syn file in the TSE "synhi" folder.'
   ''
   ''
   '  Claimer:'
   ''
   '    This macro contains known and unknown errors!'
   ''
   '    Because of the way use I this macro on MY program sources, these errors'
   '    either do not occur or are so minor that they do not bother me.'
   '    I have been a delighted user of this macro for many years,'
   '    and have found it to be very stable.'
   ''
   '    It probably will work just as well for you, but it might not.'
   ''
   ''
   '   Known errors:'
   ''
   '      Syntax casing will not work after multi-line comments that are not:'
   '        If a shash-asterisk is inside quotes.'
   '        If a slash-asterisk is on the same line as the asterisk-slash.'
   ''
   ''
   '      The following TSE syntax hiliting menu options / variables'
   '      are NOT supported:'
   ''
   '         TSE syntax hiliting menu item         TSE variable'
   '         -----------------------------         ----------------'
   '         To-EOL 1 -> Starting Column 1         TillEOLStartCol1'
   '         To-EOL 2 -> Starting Column 2         TillEOLStartCol2'
   '         To-EOL 3 -> Starting Column 3         TillEOLStartCol3'
   '         Quote 1 -> Escape 1                   QuoteEscape1'
   '         Quote 2 -> Escape 2                   QuoteEscape2'
   '         Quote 3 -> Escape 3                   QuoteEscape3'
   ''
end help_text



Datadef default_keyword_definitions
   'AbandonEditor'
   'AbandonFile'
   'About'
   'Abs'
   'AddAutoLoadMacro'
   'AddFFInfoToBuffer'
   'AddFileToRing'
   'AddHistoryStr'
   'AddLine'
   'Addr'
   'AddTrailingSlash'
   'AdjPtr'
   'Alarm'
   'Alt'
   'AltCtrl'
   'AltShift'
   'and'
   'Asc'
   'Ask'
   'AskFilename'
   'AskNumeric'
   'AskPopWin'
   'Attr'
   'AutoIndent'
   'BackSpace'
   'BackupExt'
   'BackupPath'
   'Beep'
   'BegFile'
   'BegLine'
   'BegLineTog'
   'BegWindow'
   'BegWord'
   'binary'
   'BinaryMode'
   'BlockAttr'
   'BlockBegCol'
   'BlockBegLine'
   'BlockEndCol'
   'BlockEndLine'
   'BlockId'
   'BorderFlags'
   'Break'
   'BreakHookChain'
   'BrowseDir'
   'BrowseMode'
   'BufferFlags'
   'BufferType'
   'BufferVideo'
   'BuildPickBufferEx'
   'BuildSynHiExtList'
   'by'
   'CapsLock'
   'case'
   'CenterBtn'
   'CenterCursor'
   'CenterFinds'
   'CfgInt'
   'CfgRange'
   'CfgStr'
   'ChainCmd'
   'ChangeCurrFilename'
   'ChangedFilesExist'
   'ChangeShellPrompt'
   'ChDir'
   'CheckBoxes'
   'CheckDefaultExt'
   'ChooseFont'
   'Chr'
   'ChrSet'
   'ClearBit'
   'ClearBufferDaTmAttr'
   'ClearEditWindows'
   'ClearPhysicalScreen'
   'ClearUndoRedoList'
   'ClipBoardId'
   'CloseAfter'
   'CloseAllAfter'
   'CloseAllBefore'
   'CloseBefore'
   'ClosePrint'
   'CloseWindow'
   'ClrEol'
   'ClrScr'
   'CmdMap'
   'CmpiStr'
   'CodePage'
   'Color'
   'command'
   'config'
   'ConFlags'
   'constant'
   'continue'
   'Copy'
   'CopyAppend'
   'CopyAppendToWinClip'
   'CopyBlock'
   'CopyFile'
   'CopyToWinClip'
   'CreateBuffer'
   'CreateTempBuffer'
   'CReturn'
   'Ctrl'
   'CtrlAlt'
   'CtrlAltShift'
   'CtrlShift'
   'CurrChar'
   'CurrCol'
   'CurrDir'
   'CurrExt'
   'CurrFilename'
   'CurrHistoryList'
   'CurrLine'
   'CurrLineLen'
   'CurrLinePtr'
   'CurrMacroFilename'
   'CurrPos'
   'CurrRow'
   'CurrVideoMode'
   'CurrWinBorderAttr'
   'CurrWinBorderType'
   'CurrXoffset'
   'Cursor'
   'CursorAttr'
   'CursorDown'
   'CursorInBlockAttr'
   'CursorLeft'
   'CursorRight'
   'CursorTabWidth'
   'CursorUp'
   'Cut'
   'CutAppend'
   'CutAppendToWinClip'
   'CutToWinClip'
   'Datadef'
   'DateFormat'
   'DateSeparator'
   'DefaultExt'
   'Del'
   'DelAllBookMarks'
   'DelAnyChar'
   'DelAnyCharOrBlock'
   'DelAutoLoadMacro'
   'Delay'
   'DelBlock'
   'DelBlockOrChar'
   'DelBlockOrChar2'
   'DelBookMark'
   'DelBufferVar'
   'DelChar'
   'DelCharOrBlock'
   'DelGlobalVar'
   'DelHistory'
   'DelHistoryStr'
   'DelLeftWord'
   'DelLine'
   'DelRightWord'
   'DelStr'
   'DelToEol'
   'DelWindow'
   'DetabOnLoad'
   'Directive1Attr'
   'Directive2Attr'
   'Directive3Attr'
   'Disable'
   'DisablePromptKeys'
   'DisplayBoxed'
   'DisplayMode'
   'DistanceToTab'
   'Divide'
   'dll'
   'do'
   'DontClose'
   'Dos'
   'DosCmdLine'
   'DosIOResult'
   'Down'
   'downto'
   'DrawBox'
   'DupLine'
   'EditAutoLoadList'
   'EditBuffer'
   'EditFile'
   'EditorType'
   'EDITOR_VERSION'
   'EditPopWin'
   'EditThisFile'
   'EffectiveWidth'
   'else'
   'elseif'
   'EmptyBuffer'
   'EmptyWinClip'
   'Enable'
   'EnablePromptKeys'
   'end'
   'endcase'
   'endconfig'
   'enddo'
   'EndFile'
   'endfor'
   'endif'
   'EndLine'
   'EndLineTog'
   'endloop'
   'EndProcess'
   'endwhile'
   'EndWindow'
   'EndWord'
   'EntabCurrLine'
   'EntabOnSave'
   'Enter'
   'EofMarkerAttr'
   'EOFType'
   'EOLType'
   'EquateEnhancedKbd'
   'EquiStr'
   'EraseDiskFile'
   'Escape'
   'ExecHook'
   'ExecLoadedMacro'
   'ExecMacro'
   'ExecScrapMacro'
   'ExistBufferVar'
   'ExistGlobalVar'
   'Exit'
   'ExpandPath'
   'ExpandTabs'
   'ExpandTabsToSpaces'
   'F1'
   'F10'
   'F11'
   'F12'
   'F2'
   'F3'
   'F4'
   'F5'
   'F6'
   'F7'
   'F8'
   'F9'
   'FALSE'
   'fClose'
   'fCreate'
   'fDup'
   'fDup2'
   'FFAttribute'
   'FFDate'
   'FFDateStr'
   'FFHighDateTime'
   'FFLowDateTime'
   'FFName'
   'FFSize'
   'FFTime'
   'FFTimeStr'
   'FileChanged'
   'FileExists'
   'FileLocking'
   'FillBlock'
   'Find'
   'FindFileClose'
   'FindFirstFile'
   'FindHistoryStr'
   'FindInfoPtr'
   'FindNextFile'
   'FindOptions'
   'FindThisFile'
   'FinishEditWindows'
   'FixAndFindPath'
   'Flip'
   'FlushProfile'
   'FontFlags'
   'FontName'
   'FontSize'
   'FooterLen'
   'fOpen'
   'for'
   'Format'
   'forward'
   'fRead'
   'fRead2'
   'fReadFile'
   'FreeWorkBuffer'
   'fSeek'
   'FullWindow'
   'fWrite'
   'fWriteFile'
   'GenerateIndex2'
   'GetBit'
   'GetBookMarkInfo'
   'GetBufferDaTmAttr'
   'GetBufferId'
   'GetBufferInt'
   'GetBufferStr'
   'GetCharWidthHeight'
   'GetClipBoardBlockType'
   'GetClockTicks'
   'GetColorTableValue'
   'GetConnectionType'
   'GetData'
   'GetDate'
   'GetDateStr'
   'GetDir'
   'GetDirSeparator'
   'GetDrive'
   'GetEnvStr'
   'GetFileName'
   'GetFileToken'
   'GetFont'
   'GetForcedCmd'
   'GetFoundText'
   'GetFreeHistory'
   'GetGlobalInt'
   'GetGlobalStr'
   'GetHistoryStr'
   'GetHookState'
   'GetKey'
   'GetKeyFlags'
   'GetMarkedText'
   'GetMaxRowsCols'
   'GetNextConnection'
   'GetNextProfileItem'
   'GetNextProfileSectionName'
   'GetPositionInfo'
   'GetProfileInt'
   'GetProfileStr'
   'GetRedoInfoBuffer'
   'GetRemoteName'
   'GetStr'
   'GetStrAttr'
   'GetStrAttrXY'
   'GetStrFromWinClip'
   'GetStrXY'
   'GetSynFilename'
   'GetSynLanguageType'
   'GetSynMultiLnDlmt'
   'GetSynToEOL'
   'GetSystemInfo'
   'GetText'
   'GetTime'
   'GetTimeStr'
   'GetToken'
   'GetUndoInfoBuffer'
   'GetVolumeInfo'
   'GetWheelScrollLines'
   'GetWindowHandleHack'
   'GetWindowInfo'
   'GetWindowTitle'
   'GetWinHandle'
   'GetWord'
   'GetWorkBuffer'
   'GlobalUnDelete'
   'goto'
   'GotoBlockBegin'
   'GotoBlockBeginCol'
   'GotoBlockEnd'
   'GotoBlockEndCol'
   'GotoBufferId'
   'GotoColumn'
   'GotoLine'
   'GotoMark'
   'GotoMouseCursor'
   'GotoNextNonWhite'
   'GotoNextWhite'
   'GotoPos'
   'GotoRow'
   'GotoWindow'
   'GotoXoffset'
   'GotoXY'
   'Grey*'
   'Grey+'
   'Grey-'
   'Grey/'
   'GreyCursorDown'
   'GreyCursorLeft'
   'GreyCursorRight'
   'GreyCursorUp'
   'GreyDel'
   'GreyEnd'
   'GreyEnter'
   'GreyHome'
   'GreyIns'
   'GreyPgDn'
   'GreyPgUp'
   'GUIStartupFlags'
   'halt'
   'HashStr'
   'Help'
   'HelpBoldAttr'
   'Helpdef'
   'HelperFunctionOffSet'
   'HelpFile'
   'HelpInfoAttr'
   'HelpItalicsAttr'
   'HelpLevel'
   'HelpLine'
   'HelpLineDelay'
   'HelpLinkAttr'
   'HelpReplaceAttr'
   'HelpSelectAttr'
   'HelpSubtopicAttr'
   'HelpTextAttr'
   'HelpTopicAttr'
   'HexEdit'
   'HiByte'
   'HideMouse'
   'HiFind'
   'HiliteAttr'
   'HiLiteFoundText'
   'history'
   'HiWord'
   'Home'
   'Hook'
   'HookDisplay'
   'HWindow'
   'IdleTime'
   'if'
   'iif'
   'in'
   'Include'
   'IncompleteQuoteAttr'
   'InitSynhiCurrFile'
   'Ins'
   'Insert'
   'InsertCursorSize'
   'InsertData'
   'InsertFile'
   'InsertFilenow'
   'InsertHelp'
   'InsertKeyAssignments'
   'InsertLine'
   'InsertLineBlocksAbove'
   'InsertText'
   'InsertTopic'
   'InsStr'
   'integer'
   'is32BitApp'
   'isAlpha'
   'isAlphaNum'
   'isAutoLoaded'
   'isBlockInCurrFile'
   'isBlockMarked'
   'isBookMarkSet'
   'isCharDevice'
   'isCurrLineInBlock'
   'isCursorInBlock'
   'isDigit'
   'IsDirSeparator'
   'isFullScreen'
   'isGUI'
   'isHexDigit'
   'isKeyAssigned'
   'isLower'
   'isMacroLoaded'
   'isScrapMacro'
   'isTrailingSlash'
   'isTypeableKey'
   'isUpper'
   'isWhite'
   'isWildPath'
   'isWinClipAvailable'
   'isWord'
   'isZoomed'
   'JoinLine'
   'KbdFlags'
   'KbdId'
   'KbdMacroBegin'
   'KbdMacroRecording'
   'KbdMacroRunning'
   'KbdPath'
   'KeepUndoBeyondSave'
   'KeepWinOnTop'
   'Key'
   'KeyCode'
   'Keydef'
   'KeyName'
   'KeyPressed'
   'Keywords1Attr'
   'Keywords2Attr'
   'Keywords3Attr'
   'Keywords4Attr'
   'Keywords5Attr'
   'Keywords6Attr'
   'Keywords7Attr'
   'Keywords8Attr'
   'Keywords9Attr'
   'KillBlock'
   'KillFile'
   'KillLine'
   'KillLocation'
   'KillMax'
   'KillPosition'
   'KillToEol'
   'LastKey'
   'LastMouseKey'
   'LastMouseX'
   'LastMouseY'
   'lDos'
   'Left'
   'LeftBtn'
   'LeftMargin'
   'LeftStr'
   'Length'
   'lFind'
   'LineDraw'
   'LineDrawChar'
   'LineDrawing'
   'LineDrawType'
   'LineNumbersAttr'
   'LineTypeMenu'
   'LinkSynFile'
   'List'
   'ListFooter'
   'ListHeader'
   'ListTitle'
   'Literal'
   'lLeftBtn'
   'lList'
   'LoadBuffer'
   'LoadDir'
   'LoadHistory'
   'LoadKeyMacro'
   'LoadMacro'
   'LoadProfileSection'
   'LoadProfileSectionNames'
   'LoadStartupMacros'
   'LoadSynhiAssoc'
   'LoadUserInterface'
   'LoadWildFromDOS'
   'LoadWildFromInside'
   'LoByte'
   'LocalHelp'
   'LoCase'
   'LockCurrentFile'
   'LogDrive'
   'LongestLineInBuffer'
   'loop'
   'Lower'
   'LoWord'
   'lProcess'
   'lRead'
   'lReadNumeric'
   'lRepeatFind'
   'lReplace'
   'lRightBtn'
   'lShowEntryScreen'
   'LTrim'
   'lVersion'
   'MacroCmdLine'
   'MacroStackAvail'
   'Main'
   'MakeBackups'
   'MakeEditWindow'
   'MakeTempName'
   'Mark'
   'MarkAll'
   'MarkBlockBegin'
   'MarkBlockEnd'
   'MarkChar'
   'MarkColumn'
   'MarkFoundText'
   'Marking'
   'MarkLine'
   'MarkStream'
   'MarkToEOL'
   'MarkWord'
   'MatchFilename'
   'Max'
   'MaxBufferId'
   'MaxHistoryPerList'
   'MaxHistorySize'
   'MAXINT'
   'MAXLINELEN'
   'MaxRecentFiles'
   'MAXSTRINGLEN'
   'menu'
   'menubar'
   'MenuBarY'
   'MenuBorderAttr'
   'MenuGrayAttr'
   'MenuKey'
   'MenuOption'
   'MenuSelectAttr'
   'MenuSelectGrayAttr'
   'MenuSelectLtrAttr'
   'MenuStr'
   'MenuTextAttr'
   'MenuTextLtrAttr'
   'Message'
   'Min'
   'MININT'
   'MkDir'
   'mod'
   'MouseBlockType'
   'MouseEnabled'
   'MouseHoldTime'
   'MouseHotSpot'
   'MouseKey'
   'MouseKeyHeld'
   'MouseMarking'
   'MouseRepeatDelay'
   'MouseStatus'
   'MouseWindowId'
   'MouseX'
   'MouseY'
   'Move'
   'MoveBlock'
   'MoveBufBack'
   'MoveBufForw'
   'MoveFile'
   'MovePopWin'
   'MsgAttr'
   'MsgBox'
   'MsgBoxBuff'
   'MsgBoxEx'
   'MsgLevel'
   'MultiLnDlmt1Attr'
   'MultiLnDlmt2Attr'
   'MultiLnDlmt3Attr'
   'NewFile'
   'NextChar'
   'NextDiskConnection'
   'NextFile'
   'NextWindow'
   'NoEscape'
   'NoKeys'
   'NoOp'
   'NoSound'
   'not'
   'NumberAttr'
   'NumFiles'
   'NumFileTokens'
   'NumHistoryItems'
   'NumLines'
   'NumLock'
   'NumTokens'
   'NumWindows'
   'OFF'
   'Ofs'
   'ON'
   'OneWindow'
   'or'
   'OtherWinBorderAttr'
   'OtherWinBorderType'
   'otherwise'
   'OverwriteCursorSize'
   'PageDown'
   'PageUp'
   'ParaEndStyle'
   'Paste'
   'PasteFromWinClip'
   'PasteReplace'
   'PasteReplaceFromWinClip'
   'PasteUnDelete'
   'PathToExe'
   'pause'
   'PBAttribute'
   'PBDate'
   'PBDateStr'
   'PBName'
   'PBSize'
   'PBTime'
   'PBTimeStr'
   'PeekByte'
   'PeekLong'
   'PeekWord'
   'PersistentHistory'
   'PersistentRecentFiles'
   'PgDn'
   'PgUp'
   'PickDrive'
   'PickFile'
   'PickFileChangesDir'
   'PickFileFlags'
   'PickFilePath'
   'PickFileSortOrder'
   'PlaceMark'
   'PokeByte'
   'PokeLong'
   'PokeWord'
   'PopBlock'
   'PopLocation'
   'PopPosition'
   'PopUndoMark'
   'PopWinClose'
   'PopWinCols'
   'PopWinOpen'
   'PopWinRows'
   'PopWinX1'
   'PopWinY1'
   'Pos'
   'PosFirstNonWhite'
   'PosLastNonWhite'
   'PressKey'
   'PrevChar'
   'PrevFile'
   'PrevHelp'
   'PrevPosition'
   'PrevUpdateDisplayFlags'
   'PrevWindow'
   'PrintBlock'
   'PrintBotMargin'
   'PrintChar'
   'PrintCopies'
   'PrinterFontFlags'
   'PrinterFontName'
   'PrinterFontSize'
   'PrintFile'
   'PrintFirstPage'
   'PrintFooter'
   'PrintHeader'
   'PrintLastPage'
   'PrintLeftMargin'
   'PrintLineNumbers'
   'PrintLineSpacing'
   'PrintLinesPerPage'
   'PrintPause'
   'PrintRightMargin'
   'PrintTopMargin'
   'PrintUseScreenFont'
   'PriorityFlags'
   'proc'
   'Process'
   'ProcessHotSpot'
   'ProcessInWindow'
   'PromptString'
   'protected'
   'ProtectedSaves'
   'PrtSc'
   'Ptr'
   'public'
   'PurgeKeyMacro'
   'PurgeMacro'
   'PurgeMacroAt'
   'PurgeSynhi'
   'PushBlock'
   'PushKey'
   'PushKeyStr'
   'PushLocation'
   'PushPosition'
   'PushUndoMark'
   'PutAttr'
   'PutAttrXY'
   'PutChar'
   'PutCharH'
   'PutCharHXY'
   'PutCharV'
   'PutCharXY'
   'PutCtrStr'
   'PutHelpLine'
   'PutLine'
   'PutLineXY'
   'PutNCharAttr'
   'PutOemChar'
   'PutOemCharH'
   'PutOemCharV'
   'PutOemLine'
   'PutOemStrXY'
   'PutStr'
   'PutStrAttr'
   'PutStrAttrXY'
   'PutStrEOL'
   'PutStrEOLXY'
   'PutStrXY'
   'Query'
   'QueryEditState'
   'QueryInt'
   'QueryStr'
   'QuickHelp'
   'QuitFile'
   'QuittingFile'
   'QuitToPrompt'
   'Quote1Attr'
   'Quote2Attr'
   'Quote3Attr'
   'QuotePath'
   'Read'
   'ReadCompressedLine'
   'ReadFile'
   'ReadFlags'
   'ReadInUse'
   'ReadNumeric'
   'RealToVirtualScreen'
   'RecordKeyMacro'
   'Redo'
   'RedoCount'
   'Redrawn'
   'register'
   'ReinitVideo'
   'RemoveProfileItem'
   'RemoveProfileSection'
   'RemoveTrailingSlash'
   'RemoveTrailingWhite'
   'RemoveUnloadedFiles'
   'RenameAndSaveFile'
   'RenameDiskFile'
   'repeat'
   'RepeatCmd'
   'RepeatFind'
   'Replace'
   'ReplaceFile'
   'ReplaceOptions'
   'ReplaceSynFile'
   'ResizeFont'
   'ResizeWindow'
   'RestoreCursorLine'
   'RestoreDirOnExit'
   'RestoreMsgLevel'
   'RestoreVideoWindow'
   'return'
   'ReturnEqNextLine'
   'Right'
   'RightBtn'
   'RightMargin'
   'RightStr'
   'RmDir'
   'RollDown'
   'RollLeft'
   'RollRight'
   'RollUp'
   'RootPath'
   'rPos'
   'RTrim'
   'SaveAllAndExit'
   'SaveAllFiles'
   'SaveAndQuitFile'
   'SaveAs'
   'SaveBlock'
   'SaveFile'
   'SaveHistory'
   'SaveKeyMacro'
   'SaveSettings'
   'SaveSettingsEnd'
   'SaveState'
   'SaveVideoWindow'
   'ScreenCols'
   'ScreenRows'
   'ScrollDown'
   'ScrollLeft'
   'ScrollLock'
   'ScrollRight'
   'ScrollToBottom'
   'ScrollToCenter'
   'ScrollToRow'
   'ScrollToTop'
   'ScrollUp'
   'SearchHelp'
   'SearchPath'
   'Seg'
   'SelfInsert'
   'Set'
   'SetBit'
   'SetBufferInt'
   'SetBufferStr'
   'SetColorTableValue'
   'SetCurrFilename'
   'SetCursorOff'
   'SetCursorOn'
   'SetDosIoResult'
   'SetFileAttr'
   'SetFont'
   'SetGlobalInt'
   'SetGlobalStr'
   'SetHookState'
   'SetInt'
   'SetLastFindUnknown'
   'SetMenuBar'
   'SetMsgLevel'
   'SetOpenFilenameCustomFilter'
   'SetOpenFilenameFilter'
   'SetPrinterFont'
   'SetPrintMode'
   'SetRefreshWorld'
   'SetStr'
   'SetSystemInfo'
   'SetSystemInfo'
   'SetUndoOff'
   'SetUndoOn'
   'SetupCompressedRead'
   'SetVideoRowsCols'
   'SetWindowHeight'
   'SetWindowTitle'
   'SetWindowWidth'
   'Shell'
   'Shift'
   'ShiftText'
   'shl'
   'ShowEntryScreen'
   'ShowEOFMarker'
   'ShowHelpLine'
   'ShowLineNumbers'
   'ShowMainMenu'
   'ShowMouse'
   'ShowStatusLine'
   'ShowSyntaxHilite'
   'shr'
   'SignOn'
   'SingleInstance'
   'SingleLnDlmt1Attr'
   'SingleLnDlmt2Attr'
   'SingleLnDlmt3Attr'
   'SizeOf'
   'Skip'
   'Sort'
   'Sound'
   'SpaceBar'
   'SpecialEffects'
   'SplitLine'
   'SplitPath'
   'SqueezePath'
   'StartedFromDosPrompt'
   'StartPgm'
   'StartupFlags'
   'StartupPath'
   'StartupVideoMode'
   'StatusLineAtTop'
   'StatusLineAttr'
   'StatusLineFillChar'
   'StatusLineRow'
   'StatusLineUpdating'
   'Str'
   'StrCount'
   'StrFind'
   'string'
   'StrReplace'
   'SubStr'
   'SwapLines'
   'SwapPosition'
   'System'
   'Tab'
   'TabLeft'
   'TabRight'
   'TabSet'
   'TabShiftsBlock'
   'TabType'
   'TabWidth'
   'TemplateExpansion'
   'TerminateEvent'
   'TextAttr'
   'ThousandsSeparator'
   'TimeFormat'
   'times'
   'TimeSeparator'
   'title'
   'to'
   'ToEol1Attr'
   'ToEol2Attr'
   'ToEol3Attr'
   'Toggle'
   'ToggleInsert'
   'ToggleInt'
   'TrackMouseCursor'
   'TranslateToLiteralCh'
   'Transparency'
   'Trim'
   'TRUE'
   'TSEPath'
   'TurnOnOkToEraseFlag'
   'UnBufferVideo'
   'UnDelete'
   'Undo'
   'UndoCount'
   'UndoMode'
   'UnHook'
   'UnhookDisplay'
   'UnloadAllBuffers'
   'UnloadBuffer'
   'UnLockCurrentFile'
   'UnMarkAfterPaste'
   'UnMarkBlock'
   'until'
   'Up'
   'UpCase'
   'UpdateBufferDaTmAttr'
   'UpdateDisplay'
   'UpdateDisplayFlags'
   'UpdateDisplayNoBlock'
   'Upper'
   'UseCommonDialogs'
   'UseCurrLineIfNoBlock'
   'UseMouse'
   'UserHiliteFoundText'
   'Val'
   'var'
   'VarTabs'
   'VerifyHelp'
   'Version'
   'VersionStr'
   'VGotoXY'
   'VGotoXYAbs'
   'VHomeCursor'
   'ViewFinds'
   'ViewFindsId'
   'VirtualToRealScreen'
   'VWhereX'
   'VWhereY'
   'VWindow'
   'WaitForKeyPressed'
   'WaitForMouseEvent'
   'Warn'
   'WheelDown'
   'WheelUp'
   'when'
   'WhenLoaded'
   'WhenPurged'
   'WhereX'
   'WhereXAbs'
   'WhereY'
   'WhereYAbs'
   'WhichOS'
   'while'
   'width'
   'WIN32'
   'WinClipFormat'
   'Window'
   'WindowCols'
   'WindowFooter'
   'WindowId'
   'WindowRows'
   'WindowX1'
   'WindowY1'
   'WinPosLeft'
   'WinPostop'
   'WordLeft'
   'WordRight'
   'WordSet'
   'WordWrap'
   'WorkLine'
   'WrapLine'
   'WrapPara'
   'Write'
   'WriteFile'
   'WriteLine'
   'WriteProfileInt'
   'WriteProfileStr'
   'x'
   'X1'
   'XlatHelp'
   'y'
   'Y1'
   'YesNo'
   'ZeroBasedTab'
   'ZoomWindow'
   '_25_LINES_'
   '_28_LINES_'
   '_30X90_'
   '_30X94_'
   '_30_LINES_'
   '_33_LINES_'
   '_34X90_'
   '_34X94_'
   '_36_LINES_'
   '_40X90_'
   '_40X94_'
   '_40_LINES_'
   '_43_LINES_'
   '_44_LINES_'
   '_50_LINES_'
   '_ADD_DIRS_'
   '_ADD_SLASH_'
   '_AFTER_COMMAND_'
   '_AFTER_FILE_SAVE_'
   '_AFTER_GETKEY_'
   '_AFTER_NONEDIT_COMMAND_'
   '_AFTER_UPDATE_DISPLAY_'
   '_AFTER_UPDATE_STATUSLINE_'
   '_ALLOW_DETACHMENT_'
   '_ALL_MESSAGES_'
   '_ALL_WINDOWS_REFRESH_'
   '_ALT_KEY_'
   '_ANCHOR_SEARCH_'
   '_APPEND_'
   '_ARCHIVE_'
   '_AT_EOL_'
   '_AUTO_'
   '_AUTO_DETECT_'
   '_BACKGROUND_'
   '_BACKWARD_'
   '_BEFORE_COMMAND_'
   '_BEFORE_GETKEY_'
   '_BEFORE_NONEDIT_COMMAND_'
   '_BEFORE_UPDATE_DISPLAY_'
   '_BEYOND_EOL_'
   '_BLACK_'
   '_BLOCK_SEARCH_'
   '_BLUE_'
   '_BOOST_ALWAYS_'
   '_BOOST_HIGHEST_'
   '_BOOST_NEVER_'
   '_BOOST_NOT_NT_'
   '_BREAK_FIND_'
   '_BREAK_LOADFILE_'
   '_BREAK_MACRO_'
   '_BREAK_SORT_'
   '_BROWN_'
   '_CANT_CREATE_'
   '_CANT_LOCK_'
   '_CANT_LOCK_FILE_'
   '_CANT_UNLOCK_FILE_'
   '_CAPSLOCK_DEPRESSED_'
   '_CENTER_POPUPS_'
   '_CLINE_REFRESH_'
   '_COLOR_'
   '_COLUMN_'
   '_CONSOLE_32BIT_'
   '_CON_FORCE_UPDATE_'
   '_CON_NEWCONSOLE_'
   '_CON_RESIZEFASTEST_'
   '_CON_RESIZEFAST_'
   '_CON_RESIZEMEDIUM_'
   '_CON_RESIZESLOWEST_'
   '_CON_RESIZESLOW_'
   '_COUNTRY_'
   '_CREATE_NEW_CONSOLE_'
   '_CTRL_KEY_'
   '_CYAN_'
   '_DARK_GRAY_'
   '_DEFAULT_'
   '_DESCENDING_'
   '_DIRECTORY_'
   '_DIRS_AT_TOP_'
   '_DISPLAY_FINDS_'
   '_DISPLAY_HELP_'
   '_DISPLAY_HEX_'
   '_DISPLAY_PICKFILE_'
   '_DISPLAY_TEXT_'
   '_DISPLAY_USER_'
   '_DONT_CHANGE_TITLE_'
   '_DONT_CHANGE_VIDEO_'
   '_DONT_CLEAR_'
   '_DONT_EXPAND_'
   '_DONT_GOTO_BUFFER_'
   '_DONT_LOAD_'
   '_DONT_PROMPT_'
   '_DONT_WAIT_'
   '_DOS_HISTORY_'
   '_DOWN_'
   '_DRAW_SHADOWS_'
   '_DRIVE_'
   '_DRIVE_CDROM_'
   '_DRIVE_DOES_NOT_EXIST_'
   '_DRIVE_FIXED_'
   '_DRIVE_RAMDISK_'
   '_DRIVE_REMOTE_'
   '_DRIVE_REMOVABLE_'
   '_DRIVE_UNKNOWN_'
   '_EDITFILE_'
   '_EDIT_HISTORY_'
   '_EMPTY_BUFFER_'
   '_ENABLE_HSCROLL_'
   '_ENABLE_SEARCH_'
   '_EQUATE_CTRLALT_TO_ALTGR_'
   '_EQUATE_ENHANCED_KBD_'
   '_EXCLUSIVE_'
   '_EXECMACRO_HISTORY_'
   '_EXT_'
   '_FILE_ALREADY_LOCKED_'
   '_FILE_NOT_LOCKED_'
   '_FILLBLOCK_HISTORY_'
   '_FIND_HISTORY_'
   '_FIND_OPTIONS_HISTORY_'
   '_FIXED_HEIGHT_'
   '_FIXED_WIDTH_'
   '_FIX_CAPSLOCK2_'
   '_FIX_CAPSLOCK_'
   '_FL_AUX_'
   '_FL_CARRY_'
   '_FL_DIRECTION_'
   '_FL_INTERRUPT_'
   '_FL_OVERFLOW_'
   '_FL_PARITY_'
   '_FL_SIGN_'
   '_FL_TRAP_'
   '_FL_ZERO_'
   '_FONT_BOLD_'
   '_FONT_OEM_'
   '_FORCE_NAME_'
   '_FOREGROUND_'
   '_FORWARD_'
   '_FROM_CMDLINE_'
   '_FULLPATH_'
   '_FULL_PATH_'
   '_GAINING_FOCUS_'
   '_GOTOCOLUMN_HISTORY_'
   '_GOTOLINE_HISTORY_'
   '_GREEN_'
   '_GUI_32BIT_'
   '_HANDLE_LOCKING_'
   '_HARD_'
   '_HELPLINE_REFRESH_'
   '_HELP_CLEANUP_'
   '_HELP_SEARCH_HISTORY_'
   '_HELP_STARTUP_'
   '_HIDDEN_'
   '_IDLE_'
   '_IGNORE_CASE_'
   '_INCLUDE_REMOVEABLE_DRIVES_'
   '_INCLUSIVE_'
   '_INSERT_'
   '_INSERT_DEPRESSED_'
   '_INSERT_PATH_'
   '_KBD_LONG_DECODE_'
   '_KEYMACRO_HISTORY_'
   '_KEY_ALTGR_'
   '_KEY_ALT_'
   '_KEY_CAPSLOCK_'
   '_KEY_CTRL_'
   '_KEY_ENHANCED_'
   '_KEY_KEYPAD_'
   '_KEY_NUMLOCK_'
   '_KEY_SCROLLLOCK_'
   '_KEY_SHIFT_'
   '_KEY_VIRTUAL_'
   '_LEFT_'
   '_LEFT_SHIFTKEY_'
   '_LIGHT_BLUE_'
   '_LIGHT_CYAN_'
   '_LIGHT_GRAY_'
   '_LIGHT_GREEN_'
   '_LIGHT_MAG_'
   '_LIGHT_RED_'
   '_LINE_'
   '_LIST_AFTER_COMMAND_'
   '_LIST_BEFORE_COMMAND_'
   '_LIST_CLEANUP_'
   '_LIST_STARTUP_'
   '_LIST_UNASSIGNED_KEY_'
   '_LOADED_'
   '_LOADMACRO_HISTORY_'
   '_LOAD_FROM_DISK_'
   '_LOAD_INDEX_'
   '_LOCAL_'
   '_LOSING_FOCUS_'
   '_LOWERCASE_KBD_'
   '_LOWER_CASE_KBD_'
   '_MAGENTA_'
   '_MAXIMIZED_'
   '_MAX_COLS_'
   '_MAX_LINES_'
   '_MAX_LINES_COLS_'
   '_MAX_PATH_'
   '_MF_CHECKED_'
   '_MF_CLOSE_AFTER_'
   '_MF_CLOSE_ALL_AFTER_'
   '_MF_CLOSE_ALL_BEFORE_'
   '_MF_CLOSE_BEFORE_'
   '_MF_DISABLED_'
   '_MF_DIVIDE_'
   '_MF_DONT_CLOSE_'
   '_MF_ENABLED_'
   '_MF_GRAYED_'
   '_MF_HILITE_'
   '_MF_SEPARATOR_'
   '_MF_SKIP_'
   '_MF_UNCHECKED_'
   '_MF_UNHILITE_'
   '_MONO_'
   '_MOUSE_CLOSE_'
   '_MOUSE_DOWN_'
   '_MOUSE_HELEVATOR_'
   '_MOUSE_HOLD_TIME_'
   '_MOUSE_HRESIZE_'
   '_MOUSE_HWINDOW_'
   '_MOUSE_LEFT_'
   '_MOUSE_MARKING_'
   '_MOUSE_MOVE_'
   '_MOUSE_PAGEDOWN_'
   '_MOUSE_PAGEUP_'
   '_MOUSE_RELEASE_'
   '_MOUSE_RIGHT_'
   '_MOUSE_TABLEFT_'
   '_MOUSE_TABRIGHT_'
   '_MOUSE_UP_'
   '_MOUSE_VELEVATOR_'
   '_MOUSE_VRESIZE_'
   '_MOUSE_VWINDOW_'
   '_MOUSE_ZOOM_'
   '_MUST_EXIST_'
   '_NAME_'
   '_NEWFILE_'
   '_NEWNAME_HISTORY_'
   '_NONEDIT_GAINING_FOCUS_'
   '_NONEDIT_IDLE_'
   '_NONEDIT_LOSING_FOCUS_'
   '_NONE_'
   '_NONINCLUSIVE_'
   '_NON_INCLUSIVE_'
   '_NORMAL_'
   '_NUMLOCK_DEPRESSED_'
   '_NUM_LOCK_DEPRESSED_'
   '_OFF_'
   '_OK_'
   '_ON_'
   '_ON_ABANDONEDITOR_'
   '_ON_ABANDON_EDITOR_'
   '_ON_CHANGING_FILES_'
   '_ON_CONTROL_BREAK_'
   '_ON_DELCHAR_'
   '_ON_EDITOR_STARTUP_'
   '_ON_EXIT_CALLED_'
   '_ON_FILE_LOAD_'
   '_ON_FILE_QUIT_'
   '_ON_FILE_SAVE_'
   '_ON_FIRST_EDIT_'
   '_ON_MESSAGE_'
   '_ON_NONEDIT_UNASSIGNED_KEY_'
   '_ON_SELFINSERT_'
   '_ON_UNASSIGNED_KEY_'
   '_ON_WARNING_'
   '_OPEN_COMPATIBILITY_'
   '_OPEN_DENYALL_'
   '_OPEN_DENYNONE_'
   '_OPEN_DENYREAD_'
   '_OPEN_DENYWRITE_'
   '_OPEN_DENY_NONE_'
   '_OPEN_NOINHERIT_'
   '_OPEN_READONLY_'
   '_OPEN_READWRITE_'
   '_OPEN_WRITEONLY_'
   '_OVERWRITE_'
   '_PARTIAL_FILE_'
   '_PATH_'
   '_PICKFILE_CLEANUP_'
   '_PICKFILE_STARTUP_'
   '_PICKFILE_UNASSIGNED_KEY_'
   '_PICK_SORT_'
   '_POST_UPDATE_ALL_WINDOWS_'
   '_PRESERVE_HELPLINE_'
   '_PRESERVE_SCREEN_'
   '_PREV_TOPIC_'
   '_PRE_UPDATE_ALL_WINDOWS_'
   '_PROCESS_ALTGR_'
   '_PROCESS_ALTSHIFT_'
   '_PROCESS_DEADKEYS_'
   '_PROMPT_AFTER_COMMAND_'
   '_PROMPT_BEFORE_COMMAND_'
   '_PROMPT_CLEANUP_'
   '_PROMPT_STARTUP_'
   '_PROMPT_UNASSIGNED_KEY_'
   '_QUERY_REMOVEABLE_DRIVES_'
   '_QUIET_'
   '_READ_ONLY_'
   '_READ_ONLY_LOCKING_'
   '_RECURSE_DIRS_'
   '_RED_'
   '_REFRESH_THIS_ONLY_'
   '_REPEATCMD_HISTORY_'
   '_REPLACE_HISTORY_'
   '_REPLACE_OPTIONS_HISTORY_'
   '_RETURN_CODE_'
   '_RETURN_PROCESS_HANDLE_'
   '_REVERSE_'
   '_RIGHT_'
   '_RIGHT_SHIFT_KEY_'
   '_RUN_DETACHED_'
   '_SC32_'
   '_SCROLLLOCK_DEPRESSED_'
   '_SEARCH_HELP_'
   '_SEARCH_INCLUSIVE_'
   '_SEARCH_SUBDIRS_'
   '_SEEK_BEGIN_'
   '_SEEK_CURRENT_'
   '_SEEK_END_'
   '_SHIFT_KEY_'
   '_SIZEOF_FINDINFO_'
   '_SIZEOF_VIDEO_'
   '_SMART_'
   '_SOFT_'
   '_STARTUP_FILEMGR_'
   '_STARTUP_MENU_'
   '_STARTUP_PICKLIST_'
   '_STARTUP_PROMPT_'
   '_STARTUP_RECENTFILES_'
   '_STARTUP_RESTORESTATE_'
   '_STARTUP_UNNAMED_'
   '_START_HIDDEN_'
   '_START_MAXIMIZED_'
   '_START_MINIMIZED_'
   '_STATE_EDITOR_PAUSED_'
   '_STATE_EDIT_MAIN_LOOP_'
   '_STATE_MENU_'
   '_STATE_POPWINDOW_'
   '_STATE_PROCESS_IN_WINDOW_'
   '_STATE_PROMPTED_'
   '_STATE_TWOKEY_'
   '_STATE_WARN_'
   '_STATUSLINE_REFRESH_'
   '_STDERR_'
   '_STDIN_'
   '_STDOUT_'
   '_STICKY_'
   '_SYSTEM_'
   '_TEE_OUTPUT_'
   '_THIS_CLINE_REFRESH_'
   '_TRANSLATE_ALTGR_'
   '_TRANSLATE_ALTSHIFT_'
   '_TYPEABLES_'
   '_UNEQUATE_ENHANCED_KBD_'
   '_UPPERCASE_KBD_'
   '_UP_'
   '_USE_3D_'
   '_USE_3D_BUTTONS_'
   '_USE_3D_CHARS_'
   '_USE_BLOCK_'
   '_USE_DEFAULT_WIN_POS_'
   '_USE_DEFAULT_WIN_SIZE_'
   '_USE_LAST_SAVED_FONT_'
   '_USE_LAST_SAVED_WIN_POS_'
   '_USE_LAST_SAVED_WIN_SIZE_'
   '_USE_LAST_SESSION_FONT_'
   '_USE_LAST_SESSION_WIN_POS_'
   '_USE_LAST_SESSION_WIN_SIZE_'
   '_VARIABLE_'
   '_VOLUME_'
   '_WAIT16_'
   '_WAIT1_'
   '_WAIT2_'
   '_WAIT32_'
   '_WAIT4_'
   '_WAIT8_'
   '_WARNINGS_ONLY_'
   '_WHITE_'
   '_WINDOWS_'
   '_WINDOWS_NT_'
   '_WINDOW_REFRESH_'
   '_WRITE_ACCESS_'
   '_WRITE_BINARY_HEADER_'
   '_YELLOW_'
   '_YES_NO_'
   '_YES_NO_CANCEL_'
end default_keyword_definitions

Keydef help_copy_key
   <Grey+> Copy()
end help_copy_key

string proc unformat(string bracketed)
   string result[255] = bracketed
   while SubStr(result, 1, 1)              in '(', ')', '.', ',', ':', ';'
      result = SubStr(result, 2, Length(result))
   endwhile
   while SubStr(result, Length(result), 1) in '(', ')', '.', ',', ':', ';'
      result = SubStr(result, 1, Length(result) - 1)
   endwhile
   return(result)
end unformat

proc SynCaseSal()
   integer def_id                      = 0
   string  def_word     [MAXSTRINGLEN] = ''
   integer hlp_tmp_id                  = 0
   string  hlp_word     [MAXSTRINGLEN] = ''
   integer ok                          = TRUE
   string  old_wordset  [32]           = Set(WordSet, ChrSet('-0-9A-Z_a-z'))
   integer org_id                      = GetBufferId()
   string  sal_syn_file [MAXSTRINGLEN] = LoadDir() + 'SynHi\sal.syn'
   integer sal_syn_id                  = 0
   integer sal_syn2_id                 = 0
   string  sal_txt_file [MAXSTRINGLEN] = LoadDir() + 'SynHi\sal.txt'
   integer sal_txt_id                  = 0
   string  sal_txt_word [MAXSTRINGLEN] = ''
   PushBlock()
   if not FileExists(sal_syn_file)
      ok = FALSE
      Warn(macro_name, ' error: Cannot find file: ', sal_syn_file)
   endif
   if ok and GetBufferId(sal_syn_file)
      AbandonFile(GetBufferId(sal_syn_file))
   endif
   if ok and GetBufferId(SplitPath(sal_syn_file, _NAME_|_EXT_))
      AbandonFile(GetBufferId(SplitPath(sal_syn_file, _NAME_|_EXT_)))
   endif
   if ok and GetBufferId(sal_txt_file)
      AbandonFile(GetBufferId(sal_txt_file))
   endif
   if ok and GetBufferId(SplitPath(sal_txt_file, _NAME_|_EXT_))
      AbandonFile(GetBufferId(SplitPath(sal_txt_file, _NAME_|_EXT_)))
   endif
   if ok
      sal_syn_id = EditBuffer(sal_syn_file, _SYSTEM_, -2)
      if sal_syn_id
         ChangeCurrFilename('sal.syn', _DONT_EXPAND_|_OVERWRITE_)
      else
         ok = FALSE
         Warn(macro_name, ' error: Cannot open file (in binary mode): ', sal_syn_file)
      endif
   endif
   if ok
      if Lower(SplitPath(CurrFilename(), _NAME_|_EXT_)) <> 'sal.syn'
      or BinaryMode() <> -2
         ok = FALSE
         Warn(macro_name, ' error: Loaded file wrong: ', sal_syn_file,
              ', BinaryMode=', BinaryMode(), ', CurrFileName=', CurrFilename(), '.')
      endif
   endif
   if ok
      ExecMacro('SynCfg2')
      if Lower(CurrFilename()) == 'sal.txt'
         sal_txt_id = GetBufferId()
      else
         ok = FALSE
         Warn(macro_name, ' error: Cannot convert sal.syn to sal.txt.')
      endif
   endif
   /*
    Set the syntaxhiliting variable "IgnoreCaseOfKeyWords" to FALSE.
   */
   if ok
      if lFind('IgnoreCaseOfKeyWords=', '^gi')
         if lFind('IgnoreCaseOfKeyWords=TRUE', 'cgi')
            lFind('TRUE', 'i')
            DelChar()
            DelChar()
            DelChar()
            InsertText('FALS', _INSERT_)
         endif
      else
         ok = FALSE
         Warn(macro_name, ' error: Cannot Find IgnoreCaseOfKeyWords in sal.syn.')
      endif
   endif
   /*
    Set keywords known to this macro to a fixed predefined casing.

    This gives us a solid basis.
    Firstly this reasonably ensures, that the about a quarter of all keywords,
    that are NOT defined as either a Help topic or a constant, are cased too.
    Secondly, while I currently do not know of any problem, past experience
    makes me consider the retrieving of keywords from Help topics a weak point.
    If that ever should fail, then this basis remains.
   */
   if ok
      def_id = CreateTempBuffer()
      InsertData(default_keyword_definitions)
      BegFile()
      repeat
         def_word = GetWord()
         if Length(def_word) > 0
            GotoBufferId(sal_txt_id)
            if lFind('[Keywords', 'gi')
               while lFind(def_word, 'iw')
                  if GetWord() == Lower(def_word)
                     InsertText(def_word, _OVERWRITE_)
                  else
                     Right(Max(1, Length(GetWord())))
                  endif
               endwhile
            endif
            GotoBufferId(def_id)
         endif
      until not WordRight()
      GotoBufferId(sal_txt_id)
   endif
   /*
    Case keywords that are defined as a Help topic to their there defined case.

    This (re)cases keywords as defined in your specific (future?) TSE version.
   */
   if ok
      if lFind('\[KeyWords[0-9]+\]', 'gix')
         hlp_tmp_id = CreateTempBuffer()
         GotoBufferId(sal_txt_id)
         Enable(help_copy_key)
         BufferVideo()
         repeat
            sal_txt_word = GetWord()
            if  Length(sal_txt_word) > 0
            and Upper(sal_txt_word) <> Lower(sal_txt_word)
            and (      (Lower(SubStr(sal_txt_word, 1, 1)) in 'a' .. 'z')
                or (          SubStr(sal_txt_word, 1, 1) == '#'
                   and (Lower(SubStr(sal_txt_word, 2, 1)) in 'a' .. 'z')))
               PushKey(<Escape>)
               PushKey(<Grey+>)
               Help(sal_txt_word)
               GotoBufferId(hlp_tmp_id)
               EmptyBuffer()
               Paste()
               UnMarkBlock()
               if not lFind("Topic '" + sal_txt_word + "' not found", "gi")
                  lFind("[~ \d009]", "gx")
                  hlp_word = unformat(GetWord())
                  GotoBufferId(sal_txt_id)
                  if  Lower(sal_txt_word) == Lower(hlp_word)
                  and       sal_txt_word  <>       hlp_word
                     MarkWord()
                     KillBlock()
                     InsertText(hlp_word, _INSERT_)
                  endif
               else
                  GotoBufferId(sal_txt_id)
               endif
            endif
         until not WordRight()
         UnBufferVideo()
         Disable(help_copy_key)
         AbandonFile(hlp_tmp_id)
      else
         ok = FALSE
         Warn(macro_name, ' error: Cannot Find KeyWords[0-9] in sal.syn.')
      endif
   endif
   /*
    Case keywords in the [Keywords5] section to uppercase.

    The "Keywords5" section as used by Semware only contains constant names.
    This too will (re)case keywords to your specific (future?) TSE version.
   */
   if ok
      if lFind('[KeyWords5]', 'gi')
         WordRight(3)
         repeat
            sal_txt_word = GetWord()
            if  Length(sal_txt_word) > 0
            and Upper(sal_txt_word) <> Lower(sal_txt_word)
            and (      (Lower(SubStr(sal_txt_word, 1, 1)) in 'a' .. 'z')
                or (          SubStr(sal_txt_word, 1, 1) == '_'
                   and (Lower(SubStr(sal_txt_word, 2, 1)) in '0' .. '9', 'a' .. 'z')))
               MarkWord()
               Upper()
               UnMarkBlock()
            endif
         until not WordRight()
            or Lower(GetText(CurrPos() - 1, 9)) == '[keywords'
      else
         ok = FALSE
         Warn(macro_name, ' error: Cannot find KeyWords5 in sal.syn.')
      endif
   endif
   /*
    Define "break" as lower case.

    SAL contains both the "Break()" function and the "break" statement.
    Syntax hiliting and casing can support only one hiliting and casing
    for both meanings.
    Only the Break() function has a Help topic with the same name,
    so "break" would always become camel cased to "Break".
    However, research shows that the break statement is used way more
    than the Break() function, so here we overrule the casing for this
    exceptional keyword to lower case.
   */
   if ok
      if lFind('break', 'giw')
         InsertText('break', _OVERWRITE_)
      endif
   endif
   if ok
      // sal_txt_id is still the current file.
      AbandonFile(sal_syn_id)
      // Add a dummy line to negate an erroneous Undo() by SynCfg2 after the
      // conversion. The conversion goes OK, but afterwords undoing the last
      // change in the text is confusing when debugging.
      EndFile()
      AddLine()
      BegFile()
      ExecMacro('SynCfg2')
      if Lower(CurrFilename()) == 'sal.syn'
         sal_syn2_id = GetBufferId()
      else
         ok = FALSE
         Warn(macro_name, ' error: Cannot convert sal.txt to sal.syn.')
      endif
   endif
   if ok
      if not SaveAs(sal_syn_file, _OVERWRITE_|_DONT_PROMPT_)
         ok = FALSE
         Warn(macro_name, ' error: Cannot save: ', sal_syn_file)
      endif
   endif
   if ok
      GotoBufferId(org_id)
      AbandonFile(sal_txt_id)
      AbandonFile(sal_syn2_id)
      Warn('DONE',
           Chr(13), Chr(13),
           'The syntax hiliting keywords of the Semware Application Language (SAL) have been set to their default UPPER, lower, and CamelCase.',
           Chr(13), Chr(13),
           'You might have to restart TSE for the new settings to take effect.')
   endif
   Set(WordSet, old_wordset)
   PopBlock()
   UpdateDisplay()
end SynCaseSal



/*
   The two procs below are copied and rewritten from Seware's iConfig macro.
   The rewrite did not involve functional changes.
*/

constant DQUOTE   = 34, DASH = 45, BACKSLASH = 92
string   code[13] = '......abtnvfr'

string proc get_formatted_chr(integer i)
   string formatted_char [5] = ''
   case i
      when 0..6, 14..31, 255            // Ctrl formatted_char.
         formatted_char = Format('\d', i:3:'0')
      when 7..13                        // Bell, backspace, tab, lf, vtab, ff, cr.
         formatted_char = '\' + code[i]
      when DQUOTE, DASH, BACKSLASH      // ", -, \
         formatted_char = '\' + Chr(i)
      otherwise
         formatted_char = Chr(i)
   endcase
   return(formatted_char)
end get_formatted_chr

string proc get_chrset(string bitset)
   integer chr_index               = 0
   integer chr_range_index         = 0
   string  word_set [MAXSTRINGLEN] = ''
   while chr_index < 256
      if GetBit(bitset, chr_index)
         word_set = word_set + get_formatted_chr(chr_index)
         chr_range_index = chr_index + 1
         while chr_range_index < 256
         and   GetBit(bitset, chr_range_index)
            chr_range_index = chr_range_index + 1
         endwhile
         chr_range_index = chr_range_index - 1
         if chr_range_index - chr_index > 1
            word_set = word_set + '-' + get_formatted_chr(chr_range_index)
            chr_index = chr_range_index
         endif
      endif
      chr_index = chr_index + 1
   endwhile
   if SubStr(word_set, 1, 2) == '\-'
      word_set = SubStr(word_set, 2, 255)
   endif
   return (word_set)
end get_chrset



string proc regify(string text)
   // Makes a non regular expression string fit for use in a regular expression.
   string result [255] = ''
   integer index = 0
   for index = 1 to Length(text)
      if Pos(text[index], ".^$|?[]-~*+@#{}\'" + '"')
         result = result + "\"
      endif
      result = result + text[index]
   endfor
   return(result)
end regify



/*
   Assumption that should logically always be TRUE:
      For a given syntax the variables buffer and keywords buffer
      exist either both or neither.
   So we never have to do syncfg2 separately for variables and keywords.
*/
proc set_current_syntax()
   integer org_id                            = GetBufferId()
   string  curr_ext           [MAXSTRINGLEN] = CurrExt()
   string  keyword            [MAXSTRINGLEN] = ''
   string  line               [MAXSTRINGLEN] = ''
   string  variable           [MAXSTRINGLEN] = ''
   string  value              [MAXSTRINGLEN] = ''
   string  synfile_fqn        [MAXSTRINGLEN] = ''
   string  needed_mapping_name [MAXSTRINGLEN] = ''
   integer synfile_id                        = 0
   integer synfile_txt_id                    = 0
   if syncase_ext <> curr_ext
      syncase_ext         = curr_ext
      synfile_fqn         = GetSynFilename()
      needed_mapping_name  = SplitPath(synfile_fqn, _NAME_)
      if mapping_name <> needed_mapping_name
         mapping_name  = needed_mapping_name
         variables_id = GetBufferId(macro_name + ':variables:' + mapping_name)
         keywords_id  = GetBufferId(macro_name + ':keywords:'  + mapping_name)
         if not variables_id
            variables_id = CreateBuffer(macro_name + ':variables:' + mapping_name, _SYSTEM_)
            keywords_id  = CreateBuffer(macro_name + ':keywords:'  + mapping_name, _SYSTEM_)
            if synfile_fqn <> ''
               synfile_id = EditFile('-b-2 ' + QuotePath(synfile_fqn), _DONT_PROMPT_)
               if synfile_id
                  PushBlock() // Redundant?
                  ExecMacro("syncfg2")
                  PopBlock()
                  synfile_txt_id = GetBufferId()
                  if synfile_txt_id <> synfile_id
                     // Fill the variables buffer for the current mapping Set.
                     BegFile()
                     repeat
                        line = GetText(1, MAXSTRINGLEN)
                        GotoBufferId(variables_id)
                        AddLine(line)
                        GotoBufferId(synfile_txt_id)
                     until not Down()
                        or Lower(GetText(1, 9)) == '[keywords'
                     // Fill the keywordss buffer for the current mapping Set.
                     while WordRight()
                        keyword = GetWord()
                        if  keyword                   <> ''
                        and GetText(CurrPos() - 1, 1) <> '['
                           GotoBufferId(keywords_id)
                           AddLine(keyword)
                           GotoBufferId(synfile_txt_id)
                        endif
                     endwhile
                     AbandonFile(synfile_txt_id)
                  endif
                  AbandonFile(synfile_id)
               endif
            endif
            GotoBufferId(org_id)
         endif
         if variables_id
            // Set default variable values
            keyword_casing                   = 'off'
            non_keyword_casing               = 'none'
            syncase_wordset                  = get_chrset(Query(WordSet))
            syncase_multilinedelimited1_from = ''
            syncase_multilinedelimited1_to   = ''
            syncase_multilinedelimited2_from = ''
            syncase_multilinedelimited2_to   = ''
            syncase_multilinedelimited3_from = ''
            syncase_multilinedelimited3_to   = ''
            syncase_tilleol1                 = ''
            syncase_tilleol2                 = ''
            syncase_tilleol3                 = ''
            syncase_tilleolstartcol1         = ''
            syncase_tilleolstartcol2         = ''
            syncase_tilleolstartcol3         = ''
            syncase_quote1                   = ''
            syncase_quote2                   = ''
            syncase_quote3                   = ''
            syncase_quoteescape1             = ''
            syncase_quoteescape2             = ''
            syncase_quoteescape3             = ''
            // Get variable values from syntax hiliting definitions.
            GotoBufferId(variables_id)
            BegFile()
            repeat
               line     = GetText(1, MAXSTRINGLEN)
               variable = GetToken(line, '=', 1)
               value    = GetToken(line, '=', 2)
               case Lower(variable)
                  when 'wordset'             syncase_wordset                  = value
                  when 'multilinedelimited1' syncase_multilinedelimited1_from = GetToken(value, ' ', 1)
                                             syncase_multilinedelimited1_to   = GetToken(value, ' ', 2)
                  when 'multilinedelimited2' syncase_multilinedelimited2_from = GetToken(value, ' ', 1)
                                             syncase_multilinedelimited2_to   = GetToken(value, ' ', 2)
                  when 'multilinedelimited3' syncase_multilinedelimited3_from = GetToken(value, ' ', 1)
                                             syncase_multilinedelimited3_to   = GetToken(value, ' ', 2)
                  when 'tilleol1'            syncase_tilleol1                 = value
                  when 'tilleol2'            syncase_tilleol2                 = value
                  when 'tilleol3'            syncase_tilleol3                 = value
                  when 'tilleolstartcol1'    syncase_tilleolstartcol1         = value
                  when 'tilleolstartcol2'    syncase_tilleolstartcol2         = value
                  when 'tilleolstartcol3'    syncase_tilleolstartcol3         = value
                  when 'quote1'              syncase_quote1                   = value
                  when 'quote2'              syncase_quote2                   = value
                  when 'quote3'              syncase_quote3                   = value
                  when 'quoteescape1'        syncase_quoteescape1             = value
                  when 'quoteescape2'        syncase_quoteescape2             = value
                  when 'quoteescape3'        syncase_quoteescape3             = value
               endcase
            until not Down()
            // Extend and overrule variable values from profile definitions.
            LoadProfileSection(macro_name + ':' + mapping_name)
            while GetNextProfileItem(variable, value)
               case Lower(variable)
                  when 'keyword_casing'      keyword_casing                   = lower(value)
                  when 'non_keyword_casing'  non_keyword_casing               = lower(value)
                  when 'wordset'             syncase_wordset                  = value
                  when 'multilinedelimited1' syncase_multilinedelimited1_from = GetToken(value, ' ', 1)
                                             syncase_multilinedelimited1_to   = GetToken(value, ' ', 2)
                  when 'multilinedelimited2' syncase_multilinedelimited2_from = GetToken(value, ' ', 1)
                                             syncase_multilinedelimited2_to   = GetToken(value, ' ', 2)
                  when 'multilinedelimited3' syncase_multilinedelimited3_from = GetToken(value, ' ', 1)
                                             syncase_multilinedelimited3_to   = GetToken(value, ' ', 2)
                  when 'tilleol1'            syncase_tilleol1                 = value
                  when 'tilleol2'            syncase_tilleol2                 = value
                  when 'tilleol3'            syncase_tilleol3                 = value
                  when 'tilleolstartcol1'    syncase_tilleolstartcol1         = value
                  when 'tilleolstartcol2'    syncase_tilleolstartcol2         = value
                  when 'tilleolstartcol3'    syncase_tilleolstartcol3         = value
                  when 'quote1'              syncase_quote1                   = value
                  when 'quote2'              syncase_quote2                   = value
                  when 'quote3'              syncase_quote3                   = value
                  when 'quoteescape1'        syncase_quoteescape1             = value
                  when 'quoteescape2'        syncase_quoteescape2             = value
                  when 'quoteescape3'        syncase_quoteescape3             = value
               endcase
            endwhile
            GotoBufferId(org_id)
         endif
      endif
   endif
end set_current_syntax

string proc findstr2(string findstr, var integer empty)
   string result [255] = ''
   if findstr <> ''
      result = "{" + regify(findstr) + "}"
      if empty
         empty = FALSE
      else
         result = "|" + result
      endif
   endif
   return(result)
end findstr2

string proc findstr(string find1, string find2, string find3,
           string find4, string find5, string find6)
   string result[255] = ''
   integer empty = TRUE
   result = findstr2(find1, empty) + findstr2(find2, empty) + findstr2(find3, empty)
          + findstr2(find4, empty) + findstr2(find5, empty) + findstr2(find6, empty)
   /* An empty search string is always found, which is not what we want,
      so we replace such by what is an unfindable string in non-binary mode,
      and an extremely unlikely to be found string otherwise.
   */
   if result == ''
      result = "\n\n\t\t\f\f\t\n\n"
   endif
   return(result)
end findstr

proc reestablish_multiline_boundaries()
   PushPosition()
   BegLine()
   if lFind(findstr(syncase_multilinedelimited1_from,
                    syncase_multilinedelimited1_to  ,
                    syncase_multilinedelimited2_from,
                    syncase_multilinedelimited2_to  ,
                    syncase_multilinedelimited3_from,
                    syncase_multilinedelimited3_to  ), "bix")
      if lFind(findstr(syncase_multilinedelimited1_from,
                       syncase_multilinedelimited2_from,
                       syncase_multilinedelimited3_from,
                       '', '', ''                      ), "bgcix")
         multiline_begin = CurrLine()
         outside_begin   = FALSE
         outside_end     = FALSE
         if lFind(findstr(syncase_multilinedelimited1_to,
                          syncase_multilinedelimited2_to,
                          syncase_multilinedelimited3_to,
                          '', '', ''                    ), "ix+")
            multiline_end = CurrLine()
         else
            multiline_end = MAXINT
         endif
      else
         Down()
         multiline_begin = MAXINT
         multiline_end   = MAXINT
         outside_begin   = CurrLine()
         if lFind(findstr(syncase_multilinedelimited1_from,
                          syncase_multilinedelimited2_from,
                          syncase_multilinedelimited3_from,
                          '', '', ''                      ), "ix+")
            Up()
            outside_end = CurrLine()
         else
            outside_end = MAXINT
         endif
      endif
   else
      EndLine()
      if lFind(findstr(syncase_multilinedelimited1_from,
                       syncase_multilinedelimited1_to  ,
                       syncase_multilinedelimited2_from,
                       syncase_multilinedelimited2_to  ,
                       syncase_multilinedelimited3_from,
                       syncase_multilinedelimited3_to  ), "ix")
         if lFind(findstr(syncase_multilinedelimited1_from,
                          syncase_multilinedelimited2_from,
                          syncase_multilinedelimited3_from,
                          '', '', ''                      ), "cgix")
            Up()
            multiline_begin = FALSE
            multiline_end   = FALSE
            outside_begin   = MININT
            outside_end     = CurrLine()
         else
            multiline_end   = CurrLine()
            outside_begin   = FALSE
            outside_end     = FALSE
            if lFind(findstr(syncase_multilinedelimited1_from,
                             syncase_multilinedelimited2_from,
                             syncase_multilinedelimited3_from,
                             '', '', ''                      ), "bix")
               multiline_begin = CurrLine()
            else
               multiline_begin = MININT
            endif
         endif
      else
         multiline_begin = 0
         multiline_end   = 0
         outside_begin   = MININT
         outside_end     = MAXINT
      endif
   endif
   PopPosition()
end reestablish_multiline_boundaries

proc syntax_case_the_current_line()
   integer org_id               = GetBufferId()
   string  old_wordset     [32] = ''
   string  word           [255] = ''
   string  formatted_word [255] = ''
   string  quote          [255] = ''
   integer current_line = CurrLine()
   if keyword_casing == 'on'
      PushPosition()
      old_wordset     = Set(WordSet, chrset(syncase_wordset))
      previouser_word = previous_word
      previous_word   = GetWord(TRUE)
      // if current line inside known multiline comment or outside known
      // multiline comments.
      if NumLines() == old_numlines
      and (  (current_line in multiline_begin .. multiline_end)
          or (current_line in outside_begin   .. outside_end  ))
         // do nothing. case
      else
         old_numlines = NumLines()
         reestablish_multiline_boundaries()
      endif
      if current_line in outside_begin .. outside_end
         // From here on we only worry about the current line.
         BegLine()
         while CurrChar() <> _AT_EOL_
         and   CurrChar() <> _BEYOND_EOL_
         and   CurrPos()  <> MAXLINELEN
            word = GetWord(FALSE)
            formatted_word = word
            if  CurrLine()                      == previous_line
            and CurrCol() + Length(word)        == previous_column + 1
            and Lower(Word[1:Length(word) - 1]) == Lower(previouser_word)
            and       Word[1:Length(word) - 1]  <>       previouser_word
               formatted_word = previouser_word + word[Length(word)]
               previous_word  = ''
            endif
            if word == ''
               if quote == ''
                  if     syncase_tilleol1 <> ''
                  and    GetText(CurrPos(), Length(syncase_tilleol1)) == syncase_tilleol1
                     quote = syncase_tilleol1
                     Right(Length(syncase_tilleol1))
                  elseif syncase_tilleol2 <> ''
                  and    GetText(CurrPos(), Length(syncase_tilleol2)) == syncase_tilleol2
                     quote = syncase_tilleol2
                     Right(Length(syncase_tilleol2))
                  elseif syncase_tilleol3 <> ''
                  and    GetText(CurrPos(), Length(syncase_tilleol3)) == syncase_tilleol3
                     quote = syncase_tilleol3
                     Right(Length(syncase_tilleol3))
                  elseif syncase_quote1 <> ''
                  and    GetText(CurrPos(), Length(syncase_quote1)) == syncase_quote1
                     quote = syncase_quote1
                     Right(Length(syncase_quote1))
                  elseif syncase_quote2 <> ''
                  and    GetText(CurrPos(), Length(syncase_quote2)) == syncase_quote2
                     quote = syncase_quote2
                     Right(Length(syncase_quote2))
                  elseif syncase_quote3 <> ''
                  and    GetText(CurrPos(), Length(syncase_quote3)) == syncase_quote3
                     quote = syncase_quote3
                     Right(Length(syncase_quote3))
                  else
                     Right()
                  endif
               else
                  if     quote == GetText(CurrPos(), Length(syncase_tilleol1))
                     quote = ''
                     Right(Length(syncase_tilleol1))
                  elseif quote == GetText(CurrPos(), Length(syncase_tilleol1))
                     quote = ''
                     Right(Length(syncase_tilleol2))
                  elseif quote == GetText(CurrPos(), Length(syncase_tilleol2))
                     quote = ''
                     Right(Length(syncase_tilleol3))
                  elseif quote == GetText(CurrPos(), Length(syncase_tilleol3))
                     quote = ''
                     Right(Length(syncase_quote1))
                  elseif quote == GetText(CurrPos(), Length(syncase_quote1))
                     quote = ''
                     Right(Length(syncase_quote1))
                  elseif quote == GetText(CurrPos(), Length(syncase_quote2))
                     quote = ''
                     Right(Length(syncase_quote1))
                  elseif quote == GetText(CurrPos(), Length(syncase_quote3))
                     quote = ''
                     Right(Length(syncase_quote1))
                  else
                     Right()
                  endif
               endif
            else
               if quote == ''
                  GotoBufferId(keywords_id)
                  if lFind(word, "giw")
                     formatted_word = GetWord(FALSE)
                  else
                     case non_keyword_casing
                        when "upper"
                           formatted_word = Upper(word)
                        when "lower"
                           formatted_word = Lower(word)
                     endcase
                  endif
                  GotoBufferId(org_id)
                  if word <> formatted_word
                     InsertText(formatted_word, _OVERWRITE_)
                     WordLeft()
                  endif
               endif
               Right(Length(word))
            endif
         endwhile
      endif
      Set(WordSet, old_wordset)
      PopPosition()
      previous_line   = CurrLine()
      previous_column = CurrCol()
   endif
end syntax_case_the_current_line

proc syntax_case_current_file()
   if keyword_casing == 'on'
      Message("Syntax casing the current file ...")
      PushPosition()
      BegFile()
      repeat
         syntax_case_the_current_line()
      until not Down()
      PopPosition()
      Message("The current file is syntax cased.")
   else
      Message("Cannot Syntax Case a file with this extension")
   endif
end syntax_case_current_file

string proc menu_get_mapping_name()
   menu_mapping_name = iif(menu_mapping_name == '', mapping_name, menu_mapping_name)
   return(menu_mapping_name)
end menu_get_mapping_name

string proc menu_get_keyword_casing()
   string value [4] = ''
   menu_mapping_name = iif(menu_mapping_name == '', mapping_name, menu_mapping_name)
   value = Lower(GetProfileStr(macro_name + ':' + menu_mapping_name, 'keyword_casing', ''))
   if value <> 'on'
      value = 'off'
   endif
   return(value)
end menu_get_keyword_casing

integer proc get_menu_non_keyword_casing_flag()
   return(iif(menu_get_keyword_casing() == 'on', _MF_ENABLED_, _MF_GRAYED_|_MF_SKIP_))
end get_menu_non_keyword_casing_flag

integer proc get_syntax_case_current_file_flag()
   integer result = _MF_GRAYED_|_MF_SKIP_
   if  mapping_name <> ''
   and Lower(SplitPath(GetSynFilename(), _NAME_)) == mapping_name
      result = _MF_CLOSE_ALL_BEFORE_
   endif
   return(result)
end get_syntax_case_current_file_flag

integer proc get_keyword_casing_flag()
   menu_mapping_name = iif(menu_mapping_name == '', mapping_name, menu_mapping_name)
   return(iif(menu_mapping_name == '', _MF_GRAYED_|_MF_SKIP_, _MF_CLOSE_ALL_BEFORE_))
end get_keyword_casing_flag

integer proc get_menu_sal_flag()
   menu_mapping_name = iif(menu_mapping_name == '', mapping_name, menu_mapping_name)
   return(iif(menu_mapping_name == 'sal', _MF_CLOSE_ALL_BEFORE_, _MF_GRAYED_|_MF_SKIP_))
end get_menu_sal_flag

integer proc get_mappings_with_exts_list()
   integer bin_id                        = 0
   string  formatted_line [MAXSTRINGLEN] = ''
   integer i                             = 0
   integer num_syns                      = 0
   string  num_syns_string           [2] = ''
   string  synhi_extlist_signature  [18] = '®TSE SynhiExtList¯'
   string  syn_ext        [MAXSTRINGLEN] = ''
   string  syn_name       [MAXSTRINGLEN] = ''
   integer syn_pos                       = 0
   integer txt_id                        = CreateTempBuffer()
   max_syn_name_len = 0
   bin_id = EditBuffer(LoadDir() + 'tsesynhi.dat', _SYSTEM_, -2)
   if  bin_id
   and NumLines() >= 3
   and GetText(1, Length(synhi_extlist_signature)) == synhi_extlist_signature
   and CurrLineLen() == Length(synhi_extlist_signature) + 2
      num_syns_string = GetText(Length(synhi_extlist_signature) + 1, 2)
      num_syns = Asc(num_syns_string[2]) * 256 + Asc(num_syns_string[1])
      if num_syns > 0
         syn_pos = 1
         for i = 1 to num_syns
            GotoBufferId(bin_id)
            GotoLine(2)
            GotoPos(syn_pos)
            syn_name         = GetText(CurrPos() + 1, CurrChar())
            max_syn_name_len = Max(max_syn_name_len, Length(syn_name))
            syn_pos          = syn_pos + 1 + CurrChar()
            AddLine(syn_name + ':' , txt_id)
            GotoLine(i + 2)
            BegLine()
            while CurrChar() > 0
               syn_ext = GetText(CurrPos() + 1, CurrChar())
               GotoPos(CurrPos() + 1 + CurrChar())
               GotoBufferId(txt_id)
               EndLine()
               InsertText(' ' + QuotePath(syn_ext))
               GotoBufferId(bin_id)
            endwhile
         endfor
         GotoBufferId(txt_id)
         BegFile()
         repeat
            syn_name = GetToken(GetText(1, MAXSTRINGLEN), ':', 1)
            if Length(syn_name) > 0
               formatted_line = Format('   ',
                                       syn_name:-(max_syn_name_len),
                                       '   (',
                                       GetText(Pos(':',
                                                   GetText(1, MAXSTRINGLEN))
                                               + 2,
                                               MAXSTRINGLEN),
                                       ')')
               BegLine()
               KillToEol()
               InsertText(formatted_line)
            endif
         until not Down()
         FileChanged(FALSE)
         BegFile()
      endif
   endif
   GotoBufferId(txt_id)
   AbandonFile(bin_id)
   return(txt_id)
end get_mappings_with_exts_list

proc menu_set_mapping_name()
   integer org_id = GetBufferId()
   integer lst_id = get_mappings_with_exts_list()
   menu_mapping_name = iif(menu_mapping_name == '', mapping_name, menu_mapping_name)
   lFind('   ' + menu_mapping_name + '   ', 'g^')
   ScrollToCenter()
   if List('Select a mapping set   (with its associated file extensions)', LongestLineInBuffer())
      menu_mapping_name = Trim(GetText(4, max_syn_name_len))
   endif
   GotoBufferId(org_id)
   AbandonFile(lst_id)
   restart_main_menu = TRUE
   PushKey(<CursorDown>)
   if get_syntax_case_current_file_flag() == _MF_CLOSE_ALL_BEFORE_
      PushKey(<CursorDown>)
   endif
end menu_set_mapping_name

proc menu_set_keyword_casing()
   string new_value [4] = menu_get_keyword_casing()
   menu_mapping_name = iif(menu_mapping_name == '', mapping_name, menu_mapping_name)
   if new_value == 'off'
      new_value = 'on'
   else
      new_value = 'off'
   endif
   WriteProfileStr(macro_name + ':' + menu_mapping_name, 'keyword_casing', new_value)
   if new_value == 'off'
      WriteProfileStr(macro_name + ':' + menu_mapping_name, 'non_keyword_casing', 'off')
   endif
   restart_main_menu = TRUE
   if get_syntax_case_current_file_flag() == _MF_CLOSE_ALL_BEFORE_
      PushKey(<CursorDown>)
   endif
   PushKey(<CursorDown>)
   PushKey(<CursorDown>)
end menu_set_keyword_casing

string proc menu_get_non_keyword_casing()
   string value [6] = ''
   menu_mapping_name = iif(menu_mapping_name == '', mapping_name, menu_mapping_name)
   value = Lower(GetProfileStr(macro_name + ':' + menu_mapping_name, 'non_keyword_casing', ''))
   if not (value in 'lower', 'upper')
      value = 'off'
   endif
   return(value)
end menu_get_non_keyword_casing

proc set_non_keyword_casing()
   string new_value [6] = 'off'
   case MenuOption()
      when 2
         new_value = 'lower'
      when 3
         new_value = 'upper'
   endcase
   WriteProfileStr(macro_name + ':' + menu_mapping_name, 'non_keyword_casing', new_value)
end set_non_keyword_casing

integer proc get_non_keyword_casing_history()
   integer result    = 1
   string  value [6] = menu_get_non_keyword_casing()
   case value
      when 'lower'
         result = 2
      when 'upper'
         result = 3
   endcase
   return(result)
end get_non_keyword_casing_history


menu menu_set_non_keyword_casing()
   history = get_non_keyword_casing_history()
   command = set_non_keyword_casing()

   '&Off', , _MF_CLOSE_AFTER_,
   'Do nothing with words that are not predefined keywords'

   '&Lower', , _MF_CLOSE_AFTER_,
   'Set all words that are not predefined keywords in lower case'

   '&Upper', , _MF_CLOSE_AFTER_,
   'Set all words that are not predefined keywords in upper case'

   '', , _MF_DIVIDE_

   '&Cancel', NoOp(), _MF_CLOSE_AFTER_,
   'Exit this menu'
end menu_set_non_keyword_casing

string proc menu_get_autoload_status()
   string result[4] = 'no'
   if isAutoLoaded()
      result = 'yes'
   endif
   return(result)
end menu_get_autoload_status

proc menu_set_autoload_status()
   if isAutoLoaded()
      DelAutoLoadMacro(macro_name)
   else
      AddAutoLoadMacro(macro_name)
   endif
end menu_set_autoload_status

proc get_menu_help()
   integer org_id = GetBufferId()
   if hlp_id
      GotoBufferId(hlp_id)
   else
      hlp_id = CreateTempBuffer()
      InsertData(help_text)
      BegFile()
   endif
   List('SynCase Help', 80)
   GotoBufferId(org_id)
end get_menu_help

menu main_menu()
   title       = 'Syntax Case'
   x           = 5
   y           = 5

   'Actions:',, _MF_SKIP_

   '   &File   Case the whole current file',
   syntax_case_current_file(), get_syntax_case_current_file_flag(),
   'Set all known words in the whole current file in their predefined case'

   '   &Help',
   get_menu_help(), _MF_CLOSE_ALL_BEFORE_,
   'The detailed documentation'

   '',, _MF_DIVIDE_

   'Settings:',, _MF_SKIP_

   '   &Mapping set ' [menu_get_mapping_name():10],
   menu_set_mapping_name(), _MF_CLOSE_ALL_BEFORE_,
   'Use this mapping set, or select another one ...'

   '      &Keyword casing' [menu_get_keyword_casing():10],
   menu_set_keyword_casing(), get_keyword_casing_flag(),
   'Toggle the casing of keywords for this mapping set to ON or OFF'

   '      &Non-keyword casing' [menu_get_non_keyword_casing():10],
   menu_set_non_keyword_casing(), get_menu_non_keyword_casing_flag(),
   'For this mapping set: set the casing of non-keywords to LOWER, UPPER or OFF'

   '      &Set to default case',
   SynCaseSal(), get_menu_sal_flag(),
   "Set SAL's synhi keywords in their default lower, UPPER and CamelCase ..."

   '   &AutoLoad' [menu_get_autoload_status():10],
   menu_set_autoload_status(), _MF_DONT_CLOSE_,
   'Toggle whether this macro should be AutoLoaded when TSE starts up'

   '',, _MF_DIVIDE_

   '&Escape', NoOp(), _MF_CLOSE_ALL_BEFORE_, 'Exit this menu'
end main_menu

proc do_main_menu()
   menu_mapping_name = ''
   repeat
      restart_main_menu = FALSE
      main_menu()
   until not restart_main_menu
end do_main_menu

proc after_command()
   if not BrowseMode()
      set_current_syntax()
      syntax_case_the_current_line()
   endif
end after_command

proc check_out_of_box_installation()
   integer answer = 0
   if GetProfileStr(macro_name, 'out_of_the_box_installation', '') == ''
      Set(X1, 5)
      Set(Y1, 5)
      answer = YesNo('Do you want automatic upper/lower/camel case for TSE macros?')
      if answer
         WriteProfileStr(macro_name, 'out_of_the_box_installation',
                         iif(answer == 1, 'yes', 'no'))
         if answer == 1
            if not isAutoLoaded()
               AddAutoLoadMacro(macro_name)
            endif
            WriteProfileStr(macro_name + ':sal', 'keyword_casing', 'on')
            WriteProfileStr(macro_name + ':sal', 'non_keyword_casing', 'off')
            SynCaseSal()
         endif
      endif
   endif
end check_out_of_box_installation

proc WhenLoaded()
   macro_name            = SplitPath(CurrMacroFilename(), _NAME_)
   syncase_ext           = init_ext
   whenloaded_clockticks = GetClockTicks()
   check_out_of_box_installation()
   Hook(_AFTER_COMMAND_, after_command)
end WhenLoaded

proc WhenPurged()
   AbandonFile(syncase_id)
   AbandonFile(variables_id)
   AbandonFile(keywords_id)
   UnHook(after_command)
end WhenPurged

proc Main()
   main_clockticks = GetClockTicks()

   // Avoid compiler warning for unused variables and functions:
   if FALSE
      syncase_tilleolstartcol1 = syncase_tilleolstartcol1
      syncase_tilleolstartcol2 = syncase_tilleolstartcol2
      syncase_tilleolstartcol3 = syncase_tilleolstartcol3
      syncase_quoteescape1     = syncase_quoteescape1
      syncase_quoteescape2     = syncase_quoteescape2
      syncase_quoteescape3     = syncase_quoteescape3
      SynCaseSal()
   endif

   set_current_syntax()
   do_main_menu()

   // If macro loaded and executed at the same time, then it has just been
   // loaded to be executed once, so in that case purge the macro.
   // Note: This is never true when debugging the macro.
   if main_clockticks - whenloaded_clockticks < 9
      PurgeMacro(macro_name)
   endif
end Main

