// Version: 1.0.0.0.53
// Created: 2026-10-31 18:43:55
// Derived from SemWare TSE 4.50.rc24 iconfig.si supplied by the user.
// Export helpers retained; numeric configuration APIs replaced by named Query.
INTEGER exportEntabOnSave

INTEGER PROC ReadIntegerSetting(INTEGER item)
 CASE item
  WHEN 34 RETURN(Query(StartUpFlags))
  WHEN 35 RETURN(Query(GUIStartupFlags))
  WHEN 36 RETURN(Query(SingleInstance))
  WHEN 38 RETURN(Query(FileLocking))
  WHEN 39 RETURN(Query(LoadWildFromDos))
  WHEN 40 RETURN(Query(LoadWildFromInside))
  WHEN 41 RETURN(Query(PickFileChangesDir))
  WHEN 42 RETURN(Query(PickFileFlags))
  WHEN 44 RETURN(Query(SearchCurrentDirectory))
  WHEN 45 RETURN(Query(EOLType))
  WHEN 46 RETURN(Query(EOFType))
  WHEN 47 RETURN(Query(MakeBackups))
  WHEN 48 RETURN(Query(ProtectedSaves))
  WHEN 51 RETURN(Query(SaveState))
  WHEN 52 RETURN(Query(UseCommonDialogs))
  WHEN 53 RETURN(Query(EquateEnhancedKBD))
  WHEN 54 RETURN(Query(MouseHoldTime))
  WHEN 55 RETURN(Query(MouseRepeatDelay))
  WHEN 56 RETURN(Query(MaxHistoryPerList))
  WHEN 57 RETURN(Query(MaxHistorySize))
  WHEN 58 RETURN(Query(PersistentHistory))
  WHEN 59 RETURN(Query(MaxRecentFiles))
  WHEN 60 RETURN(Query(PersistentRecentFiles))
  WHEN 64 RETURN(Query(CenterFinds))
  WHEN 65 RETURN(Query(Beep))
  WHEN 66 RETURN(Query(ChangeShellPrompt))
  WHEN 67 RETURN(Query(QuitToPrompt))
  WHEN 68 RETURN(Query(KeepUndoBeyondSave))
  WHEN 69 RETURN(Query(DateFormat))
  WHEN 70 RETURN(Query(DateSeparator))
  WHEN 71 RETURN(Query(TimeFormat))
  WHEN 72 RETURN(Query(TimeSeparator))
  WHEN 73 RETURN(Query(Insert))
  WHEN 74 RETURN(Query(AutoIndent))
  WHEN 75 RETURN(Query(WordWrap))
  WHEN 76 RETURN(Query(TemplateExpansion))
  WHEN 77 RETURN(Query(ParaEndStyle))
  WHEN 78 RETURN(Query(ReturnEqNextLine))
  WHEN 79 RETURN(Query(RemoveTrailingWhite))
  WHEN 80 RETURN(Query(LineDrawType))
  WHEN 81 RETURN(Query(LineDrawChar))
  WHEN 82 RETURN(Query(InsertLineBlocksAbove))
  WHEN 83 RETURN(Query(UseCurrLineIfNoBlock))
  WHEN 84 RETURN(Query(UnMarkAfterPaste))
  WHEN 85 RETURN(Query(TabShiftsBlock))
  WHEN 86 RETURN(Query(TabType))
  WHEN 87 RETURN(Query(TabWidth))
  WHEN 88 RETURN(Query(CursorTabWidth))
  WHEN 89 RETURN(Query(ZeroBasedTab))
  WHEN 91 RETURN(Query(ExpandTabs))
  WHEN 92 RETURN(Query(DetabOnLoad))
  WHEN 93 RETURN(exportEntabOnSave)
  WHEN 94 RETURN(Query(LeftMargin))
  WHEN 95 RETURN(Query(RightMargin))
  WHEN 96 RETURN(Query(StatusLineAtTop))
  WHEN 97 RETURN(Query(StatusLineFillChar))
  WHEN 98 RETURN(Query(ShowMainMenu))
  WHEN 99 RETURN(Query(ShowHelpLine))
  WHEN 100 RETURN(Query(HelpLineDelay))
  WHEN 101 RETURN(Query(CurrWinBorderType))
  WHEN 102 RETURN(Query(OtherWinBorderType))
  WHEN 103 RETURN(Query(DisplayBoxed))
  WHEN 104 RETURN(Query(SpecialEffects))
  WHEN 105 RETURN(Query(Transparency))
  WHEN 106 RETURN(Query(KeepWinOnTop))
  WHEN 107 RETURN(Query(InsertCursorSize))
  WHEN 108 RETURN(Query(OverwriteCursorSize))
  WHEN 109 RETURN(Query(ShowEOFMarker))
  WHEN 110 RETURN(Query(ShowLineNumbers))
  WHEN 111 RETURN(Query(StartupVideoMode))
  WHEN 112 RETURN(Query(WinPosLeft))
  WHEN 113 RETURN(Query(WinPosTop))
  WHEN 114 RETURN(Query(ShowSyntaxHilite))
  WHEN 115 RETURN(Query(SynHiInBlocks))
  WHEN 116 RETURN(Query(StartupAnsiColor))
  WHEN 118 RETURN(Query(FontSize))
  WHEN 119 RETURN(Query(FontFlags))
  WHEN 120 RETURN(Query(CurrWinBorderAttr))
  WHEN 121 RETURN(Query(OtherWinBorderAttr))
  WHEN 122 RETURN(Query(MenuTextAttr))
  WHEN 123 RETURN(Query(MenuTextLtrAttr))
  WHEN 124 RETURN(Query(MenuGrayAttr))
  WHEN 125 RETURN(Query(MenuSelectGrayAttr))
  WHEN 126 RETURN(Query(MenuBorderAttr))
  WHEN 127 RETURN(Query(MenuSelectAttr))
  WHEN 128 RETURN(Query(MenuSelectLtrAttr))
  WHEN 129 RETURN(Query(BlockAttr))
  WHEN 130 RETURN(Query(CursorInBlockAttr))
  WHEN 131 RETURN(Query(CursorAttr))
  WHEN 132 RETURN(Query(HiLiteAttr))
  WHEN 133 RETURN(Query(TextAttr))
  WHEN 134 RETURN(Query(EOFMarkerAttr))
  WHEN 135 RETURN(Query(MsgAttr))
  WHEN 136 RETURN(Query(StatusLineAttr))
  WHEN 137 RETURN(Query(LineNumbersAttr))
  WHEN 138 RETURN(Query(HelpInfoAttr))
  WHEN 139 RETURN(Query(HelpLinkAttr))
  WHEN 140 RETURN(Query(HelpSelectAttr))
  WHEN 141 RETURN(Query(HelpBoldAttr))
  WHEN 142 RETURN(Query(HelpItalicsAttr))
  WHEN 143 RETURN(Query(HelpTextAttr))
  WHEN 144 RETURN(Query(IncompleteQuoteAttr))
  WHEN 145 RETURN(Query(NumberAttr))
  WHEN 146 RETURN(Query(Directive1Attr))
  WHEN 147 RETURN(Query(Directive2Attr))
  WHEN 148 RETURN(Query(Directive3Attr))
  WHEN 149 RETURN(Query(MultiLnDlmt1Attr))
  WHEN 150 RETURN(Query(MultiLnDlmt2Attr))
  WHEN 151 RETURN(Query(MultiLnDlmt3Attr))
  WHEN 152 RETURN(Query(SingleLnDlmt1Attr))
  WHEN 153 RETURN(Query(SingleLnDlmt2Attr))
  WHEN 154 RETURN(Query(SingleLnDlmt3Attr))
  WHEN 155 RETURN(Query(Quote1Attr))
  WHEN 156 RETURN(Query(Quote2Attr))
  WHEN 157 RETURN(Query(Quote3Attr))
  WHEN 158 RETURN(Query(ToEOL1Attr))
  WHEN 159 RETURN(Query(ToEOL2Attr))
  WHEN 160 RETURN(Query(ToEOL3Attr))
  WHEN 161 RETURN(Query(KeyWords1Attr))
  WHEN 162 RETURN(Query(KeyWords2Attr))
  WHEN 163 RETURN(Query(KeyWords3Attr))
  WHEN 164 RETURN(Query(KeyWords4Attr))
  WHEN 165 RETURN(Query(KeyWords5Attr))
  WHEN 166 RETURN(Query(KeyWords6Attr))
  WHEN 167 RETURN(Query(KeyWords7Attr))
  WHEN 168 RETURN(Query(KeyWords8Attr))
  WHEN 169 RETURN(Query(KeyWords9Attr))
  WHEN 170 RETURN(Query(PrintLeftMargin))
  WHEN 171 RETURN(Query(PrintRightMargin))
  WHEN 172 RETURN(Query(PrintLinesPerPage))
  WHEN 173 RETURN(Query(PrintTopMargin))
  WHEN 174 RETURN(Query(PrintBotMargin))
  WHEN 175 RETURN(Query(PrintLineSpacing))
  WHEN 176 RETURN(Query(PrintLineNumbers))
  WHEN 179 RETURN(Query(PrintFirstPage))
  WHEN 180 RETURN(Query(PrintLastPage))
  WHEN 181 RETURN(Query(PrintCopies))
  WHEN 182 RETURN(Query(PrintPause))
  WHEN 183 RETURN(Query(PrintUseScreenFont))
  WHEN 185 RETURN(Query(PrinterFontSize))
  WHEN 186 RETURN(Query(PrinterFontFlags))
 ENDCASE
 RETURN(0)
END

STRING PROC ReadStringSetting(INTEGER item)
 CASE item
  WHEN 32 RETURN(Query(TSEPath))
  WHEN 33 RETURN(Query(KbdPath))
  WHEN 37 RETURN(Query(DefaultExt))
  WHEN 43 RETURN(Query(PickFileSortOrder))
  WHEN 49 RETURN(Query(BackupExt))
  WHEN 50 RETURN(Query(BackupPath))
  WHEN 61 RETURN(Query(WordSet))
  WHEN 62 RETURN(Query(FindOptions))
  WHEN 63 RETURN(Query(ReplaceOptions))
  WHEN 90 RETURN(Query(VarTabs))
  WHEN 117 RETURN(Query(FontName))
  WHEN 177 RETURN(Query(PrintHeader))
  WHEN 178 RETURN(Query(PrintFooter))
  WHEN 184 RETURN(Query(PrinterFontName))
 ENDCASE
 RETURN("")
END

string  code[]   = "dxoxxxabtnvfr",
        base[]   = Chr(10)+Chr(16)+Chr(8),
        digits[] = Chr(3)+Chr(2)+Chr(3)

constant
    DQUOTE = 34,
    DASH = 45,
    BACKSLASH = 92

string proc mChr(integer i)
    case i
        when 0..6, 14..31, 255      // ctrl chars
            return (Format('\d',i:3:'0'))
        when 7..13                  // bell, backspace, tab, lf, vtab, ff, cr
            return ('\'+code[i])
        when DQUOTE, DASH, BACKSLASH    // ", -, \
            return ('\'+Chr(i))
    endcase
    return (Chr(i))
end

string proc rWordSet()
    string  s[32] = Query(WordSet),
            ws[255] = ''
    integer i = 0, n

    while i < 256
        if GetBit(s,i)
            ws = ws + mChr(i)
            n = i + 1
            while n < 256 and GetBit(s,n)
                n = n + 1
            endwhile
            n = n - 1
            if n - i > 1
                ws = ws + '-' + mChr(n)
                i = n
            endif
        endif
        i = i + 1
    endwhile
    if (SubStr(ws, 1, 2) == "\-")
        ws = SubStr(ws, 2, 255)
    endif
    return (ws)
end

string proc cName(integer c)
    string colorString[56] = 'Black  Blue   Green  Cyan   Red    MagentaYellow White  '
    return (Trim(SubStr(colorString, c * 7 + 1, 7)))
end

string proc sColor(integer c)
    return (iif(c & 0x80, 'Intense ', '')+
            iif(c & 0x08, 'Bright ', '')+
            cName(c & 0x07)+' on '+cName((c & 0x70) shr 4))
end

string proc rColor(integer c)
    return ('Color(' + sColor(c) + ')')
end

integer proc xGetItemAttr(integer item)
    return (ReadIntegerSetting(item))
end

string proc rOnOff(integer i)
    return (iif(i, 'On', 'Off'))
end

string proc rVarTabSet()
    string  s[32] = Query(VarTabs),
            vs[255] = ''
    integer i = 0

    while (i < 256)
        if GetBit(s,i)
            vs = vs + Str(i,10) + " "
        endif
        i = i + 1
    endwhile
    return (SubStr(vs,1,Length(vs)-1))
end

datadef SettingsData
    '////'
    '//// Options created by IConfig on'
    '////'
    ''
    '//Config'
    ''
    '//// System/File Options'
    ''
    'S' + Chr(32)              + 'TSEPath'
    'S' + Chr(33)              + 'KbdPath'
    'J' + Chr(34)         + 'StartUpFlags'
    '2' + Chr(35)      + 'GUIStartUpFlags'
    'B' + Chr(36)       + 'SingleInstance'
    'S' + Chr(37)           + 'DefaultExt'
    '0' + Chr(38)          + 'FileLocking'
    'B' + Chr(39)      + 'LoadWildFromDos'
    'B' + Chr(40)   + 'LoadWildFromInside'
    'B' + Chr(41)   + 'PickFileChangesDir'
    'K' + Chr(42)        + 'PickFileFlags'
    'S' + Chr(43)    + 'PickFileSortOrder'
    'B' + Chr(44) + 'SearchCurrentDirectory'
    'L' + Chr(45)              + 'EOLType'
    'F' + Chr(46)              + 'EOFType'
    'B' + Chr(47)          + 'MakeBackups'
    'B' + Chr(48)       + 'ProtectedSaves'
    'S' + Chr(49)            + 'BackupExt'
    'S' + Chr(50)           + 'BackupPath'
    'Q' + Chr(51)            + 'SaveState'
    'B' + Chr(52)     + 'UseCommonDialogs'
    ''
    '//// Keyboard/Mouse Options'
    ''
    'B' + Chr(53)    + 'EquateEnhancedKBD'
    'H' + Chr(54)        + 'MouseHoldTime'
    'I' + Chr(55)     + 'MouseRepeatDelay'
    '1' + ' '                               + 'MouseBlockType'
    ''
    '//// Command/Format Options'
    ''
    'I' + Chr(56)    + 'MaxHistoryPerList'
    'I' + Chr(57)       + 'MaxHistorySize'
    'B' + Chr(58)    + 'PersistentHistory'
    'I' + Chr(59)       + 'MaxRecentFiles'
    'B' + Chr(60)+ 'PersistentRecentFiles'


    'W' + Chr(61)              + 'WordSet'
    'S' + Chr(62)          + 'FindOptions'
    'S' + Chr(63)       + 'ReplaceOptions'
    'B' + Chr(64)          + 'CenterFinds'
    'B' + Chr(65)                 + 'Beep'
    'B' + Chr(66)    + 'ChangeShellPrompt'
    'B' + Chr(67)         + 'QuitToPrompt'
    'B' + Chr(68)   + 'KeepUndoBeyondSave'
    'D' + Chr(69)           + 'DateFormat'
    '"' + Chr(70)        + 'DateSeparator'
    'M' + Chr(71)           + 'TimeFormat'
    '"' + Chr(72)        + 'TimeSeparator'
    ''
    '//// Text Entry/Block Options'
    ''
    'B' + Chr(73)               + 'Insert'
    'U' + Chr(74)           + 'AutoIndent'
    'N' + Chr(75)             + 'WordWrap'
    'B' + Chr(76)    + 'TemplateExpansion'
    'I' + Chr(77)         + 'ParaEndStyle'
    'B' + Chr(78)     + 'ReturnEqNextLine'
    'B' + Chr(79)  + 'RemoveTrailingWhite'
    'X' + Chr(80)         + 'LineDrawType'
    'R' + Chr(81)         + 'LineDrawChar'
    'B' + Chr(82)+ 'InsertLineBlocksAbove'
    'B' + Chr(83) + 'UseCurrLineIfNoBlock'
    'B' + Chr(84)     + 'UnMarkAfterPaste'
    'B' + Chr(85)       + 'TabShiftsBlock'
    ''
    '//// Tab/Margin Options'
    ''
    'Y' + Chr(86)              + 'TabType'
    'Z' + Chr(87)             + 'TabWidth'
    'I' + Chr(88)       + 'CursorTabWidth'
    'B' + Chr(89)         + 'ZeroBasedTab'
    'T' + Chr(90)              + 'VarTabs'
    'B' + Chr(91)           + 'ExpandTabs'
    'B' + Chr(92)          + 'DetabOnLoad'
    'B' + Chr(93)          + 'EntabOnSave'
    'I' + Chr(94)           + 'LeftMargin'
    'I' + Chr(95)          + 'RightMargin'
    ''
    '//// Display/Color Options'
    ''
    'B' + Chr(96)      + 'StatusLineAtTop'
    '"' + Chr(97)   + 'StatusLineFillChar'
    'B' + Chr(98)         + 'ShowMainMenu'
    'B' + Chr(99)         + 'ShowHelpLine'
    'I' + Chr(100)        + 'HelpLineDelay'
    '6' + Chr(101)    + 'CurrWinBorderType'
    '6' + Chr(102)   + 'OtherWinBorderType'
    'E' + Chr(103)         + 'DisplayBoxed'
    '5' + Chr(104)       + 'SpecialEffects'
    'I' + Chr(105)         + 'Transparency'
    'B' + Chr(106)         + 'KeepWinOnTop'
    'G' + Chr(107)     + 'InsertCursorSize'
    'G' + Chr(108)  + 'OverwriteCursorSize'
    'B' + Chr(109)        + 'ShowEOFMarker'
    'B' + Chr(110)      + 'ShowLineNumbers'
    'V' + Chr(111)     + 'StartupVideoMode'
    'I' + Chr(112)           + 'WinPosLeft'              // ??? need side-effect for these when loading
    'I' + Chr(113)            + 'WinPosTop'               // ??? a tse.cfg macro
    'B' + Chr(114)     + 'ShowSyntaxHilite'
    'B' + Chr(115)        + 'SynHiInBlocks'
    'I' + Chr(116)     + 'StartupAnsiColor'

    'S' + Chr(117)             + 'FontName'
    '3' + Chr(118)             + 'FontSize'
    '4' + Chr(119)            + 'FontFlags'

    ''
    '//// Attributes'
    ''
    'C' + Chr(120)    + 'CurrWinBorder' + Chr(224)
    'C' + Chr(121)   + 'OtherWinBorder' + Chr(224)
    'C' + Chr(122)         + 'MenuText' + Chr(224)
    'C' + Chr(123)      + 'MenuTextLtr' + Chr(224)
    'C' + Chr(124)         + 'MenuGray' + Chr(224)
    'C' + Chr(125)   + 'MenuSelectGray' + Chr(224)
    'C' + Chr(126)       + 'MenuBorder' + Chr(224)
    'C' + Chr(127)       + 'MenuSelect' + Chr(224)
    'C' + Chr(128)    + 'MenuSelectLtr' + Chr(224)
    'C' + Chr(129)            + 'Block' + Chr(224)
    'C' + Chr(130)    + 'CursorInBlock' + Chr(224)
    'C' + Chr(131)           + 'Cursor' + Chr(224)
    'C' + Chr(132)           + 'HiLite' + Chr(224)
    'C' + Chr(133)             + 'Text' + Chr(224)
    'C' + Chr(134)        + 'EOFMarker' + Chr(224)
    'C' + Chr(135)              + 'Msg' + Chr(224)
    'C' + Chr(136)       + 'StatusLine' + Chr(224)
    'C' + Chr(137)      + 'LineNumbers' + Chr(224)
    ''
    '//// Help Attributes'
    ''
    'C' + Chr(138)         + 'HelpInfo' + Chr(224)
    'C' + Chr(139)         + 'HelpLink' + Chr(224)
    'C' + Chr(140)       + 'HelpSelect' + Chr(224)
    'C' + Chr(141)         + 'HelpBold' + Chr(224)
    'C' + Chr(142)      + 'HelpItalics' + Chr(224)
    'C' + Chr(143)         + 'HelpText' + Chr(224)
    ''
    '//// SyntaxHilite Attributes'
    ''
    'C' + Chr(144)    + 'IncompleteQuote' + Chr(224)
    'C' + Chr(145)    + 'Number' + Chr(224)
    'C' + Chr(146)    + 'Directive1' + Chr(224)
    'C' + Chr(147)    + 'Directive2' + Chr(224)
    'C' + Chr(148)    + 'Directive3' + Chr(224)
    'C' + Chr(149)    + 'MultiLnDlmt1' + Chr(224)
    'C' + Chr(150)    + 'MultiLnDlmt2' + Chr(224)
    'C' + Chr(151)    + 'MultiLnDlmt3' + Chr(224)
    'C' + Chr(152)    + 'SingleLnDlmt1' + Chr(224)
    'C' + Chr(153)    + 'SingleLnDlmt2' + Chr(224)
    'C' + Chr(154)    + 'SingleLnDlmt3' + Chr(224)
    'C' + Chr(155)    + 'Quote1' + Chr(224)
    'C' + Chr(156)    + 'Quote2' + Chr(224)
    'C' + Chr(157)    + 'Quote3' + Chr(224)
    'C' + Chr(158)    + 'ToEOL1' + Chr(224)
    'C' + Chr(159)    + 'ToEOL2' + Chr(224)
    'C' + Chr(160)    + 'ToEOL3' + Chr(224)
    'C' + Chr(161)    + 'KeyWords1' + Chr(224)
    'C' + Chr(162)    + 'KeyWords2' + Chr(224)
    'C' + Chr(163)    + 'KeyWords3' + Chr(224)
    'C' + Chr(164)    + 'KeyWords4' + Chr(224)
    'C' + Chr(165)    + 'KeyWords5' + Chr(224)
    'C' + Chr(166)    + 'KeyWords6' + Chr(224)
    'C' + Chr(167)    + 'KeyWords7' + Chr(224)
    'C' + Chr(168)    + 'KeyWords8' + Chr(224)
    'C' + Chr(169)    + 'KeyWords9' + Chr(224)
    ''
    '//// Print Output Options'
    ''
    'I' + Chr(170)      + Chr(227) + 'LeftMargin'
    'I' + Chr(171)     + Chr(227) + 'RightMargin'
    'I' + Chr(172)    + Chr(227) + 'LinesPerPage'
    'I' + Chr(173)       + Chr(227) + 'TopMargin'
    'I' + Chr(174)       + Chr(227) + 'BotMargin'
    'P' + Chr(175)     + Chr(227) + 'LineSpacing'
    'B' + Chr(176)     + Chr(227) + 'LineNumbers'
    'O' + Chr(177)          + Chr(227) + 'Header'
    'O' + Chr(178)          + Chr(227) + 'Footer'
    'I' + Chr(179)       + Chr(227) + 'FirstPage'
    'I' + Chr(180)        + Chr(227) + 'LastPage'
    'I' + Chr(181)          + Chr(227) + 'Copies'
    'B' + Chr(182)           + Chr(227) + 'Pause'
    'B' + Chr(183)   + Chr(227) + 'UseScreenFont'

    'S' + Chr(184)      + Chr(227) + 'erFontName'
    '3' + Chr(185)      + Chr(227) + 'erFontSize'
    '4' + Chr(186)     + Chr(227) + 'erFontFlags'

    ''
    '//EndConfig'
end

proc loWriteString(string s, integer quotech)
    GotoColumn(27)
    if quotech
        InsertText('= ' + Chr(quotech) + s + Chr(quotech))
    else
        InsertText('= ' + s)
    endif
end

proc WriteInteger()
    loWriteString(Str(ReadIntegerSetting(CurrChar())), 0)
end

proc WriteBoolean()
    loWriteString(rOnOff(ReadIntegerSetting(CurrChar())), 0)
end

string VMStr[] = '_AUTO_DETECT_ _25_LINES_ _28_LINES_ _43_LINES_ _50_LINES_ _30_LINES_ _33_LINES_ _36_LINES_ _40_LINES_ _44_LINES_ _30X90_ _30X94_ _34X90_ _34X94_ _40X90_ _40X94_ _MAX_LINES_ _MAX_COLS_ _MAX_LINES_COLS_ _MAXIMIZED_',
       TStr[]  = '_HARD_    _SOFT_    _SMART_   _VARIABLE_',
       UStr[]  = 'Off     On      _STICKY_',
       WWStr[] = 'Off     On      _AUTO_',
       SSStr[] = 'Off     On      _LOCAL_',
       filelocking[] = "_NONE_ _READONLY_LOCKING_ _HANDLE_LOCKING_"

proc WriteChr()
    integer ch = ReadIntegerSetting(CurrChar()),
            qch = iif(ch == Asc("'"), Asc('"'), Asc("'"))

    loWriteString('Asc(', 0)
    InsertText(Chr(qch)+Chr(ch)+Chr(qch)+')')
end

proc WriteWordSet()
    string ws[255]
    integer p

    loWriteString('ChrSet(', 0)
    ws = rWordSet()
    p = Pos('"', ws)
    if p == 0
        InsertText('"' + rWordSet())
    else
        if p > 2
            InsertText('"' + ws[1:p-2] + '"+')
        endif
        InsertText("'")                 // insert '
        InsertText('"')                 // insert "
        InsertText("'+")                // insert '+
        InsertText('"')                 // insert "
        InsertText(ws[p+1:Length(ws)])
    endif
    InsertText('")')
end

proc WriteTabSet()
    loWriteString('TabSet("', 0)
    InsertText(rVarTabSet())
    InsertText('")')
end

proc WriteStartUpFlags()
    string s[80] = ''

    case Query(StartUpFlags)
        when _STARTUP_FILEMGR_
            s = "_STARTUP_FILEMGR_"
        when _STARTUP_UNNAMED_
            s = "_STARTUP_UNNAMED_"
        when _STARTUP_RECENTFILES_
            s = "_STARTUP_RECENTFILES_"
        when _STARTUP_PICKLIST_
            s = "_STARTUP_PICKLIST_"
        when _STARTUP_RESTORESTATE_
            s = "_STARTUP_RESTORESTATE_"
        when _STARTUP_PROMPT_
            s = "_STARTUP_PROMPT_"
        when _STARTUP_MENU_             // KSW 021699 added
            s = "_STARTUP_MENU_"        // KSW 021699 added
        otherwise
            s = "_NONE_"
    endcase
    loWriteString(s, 0)
end

proc WritePickFileFlags()
    string s[80] = ''
    integer flags = Query(PIckFileFlags)

    if flags & _ADD_DIRS_
        s = s + "_ADD_DIRS_ | "
    endif
    if flags & _ADD_SLASH_
        s = s + "_ADD_SLASH_ | "
    endif
    if flags & _DIRS_AT_TOP_
        s = s + "_DIRS_AT_TOP_ | "
    endif
    if flags & _SHOW_LAST_DIR_
        s = s + "_SHOW_LAST_DIR_ | "
    endif
    if Length(s)
        s = s[1:Length(s) - 3]
    else
        s = "_NONE_"
    endif
    loWriteString(s, 0)
end

proc WriteComment(integer p, string cmt)
    EndLine()
    if p < CurrPos()
        Right()
    else
        GotoPos(p + 2)      // allow for comment column that we cut out
    endif
    InsertText(cmt)
end

proc UpdateString(var string s, string s2)
    if Length(s)
        s = s + "|" + s2
    else
        s = s2
    endif
end

proc WriteSpecialEffects()
    string s[255] = ""
    integer flags = ReadIntegerSetting(CurrChar())

    if flags & _USE_3D_CHARS_
        UpdateString(s, "_USE_3D_CHARS_")
    endif

    if flags & _DRAW_SHADOWS_
        UpdateString(s, "_DRAW_SHADOWS_")
    endif

    if flags & _USE_3D_BUTTONS_
        UpdateString(s, "_USE_3D_BUTTONS_")
    endif

    if flags & _CENTER_POPUPS_
        UpdateString(s, "_CENTER_POP_UPS_")
    endif

    if flags & _SHOW_OEM_CHARS_
        UpdateString(s, "_SHOW_OEM_CHARS_")
    endif

    if flags & _TOP_RT_POPUPS_
        UpdateString(s, "_TOP_RT_POPUPS_")
    endif

    if Length(s) == 0
        s = "_NONE_"
    endif

    loWriteString(s, 0)
end

proc WriteFontFlags()
    string s[255] = ""
    integer flags = ReadIntegerSetting(CurrChar())

    if flags & _FONT_OEM_
        UpdateString(s, "_FONT_OEM_")
    endif
    if flags & _FONT_BOLD_
        UpdateString(s, "_FONT_BOLD_")
    endif
    if Length(s) == 0
        s = "_NONE_"
    endif
    loWriteString(s, 0)
end

proc WriteGUIStartupFlags()
    string s[255] = ""
    integer flags = Query(GUIStartupFlags)

    if flags & _USE_DEFAULT_WIN_POS_
        UpdateString(s, "_USE_DEFAULT_WIN_POS_")
    elseif flags & _USE_LAST_SAVED_WIN_POS_
        UpdateString(s, "_USE_LAST_SAVED_WIN_POS_")
    elseif flags & _USE_LAST_SESSION_WIN_POS_
        UpdateString(s, "_USE_LAST_SESSION_WIN_POS_")
    endif

    if flags & _USE_LAST_SAVED_FONT_
        UpdateString(s, "_USE_LAST_SAVED_FONT_")
    elseif flags & _USE_LAST_SESSION_FONT_
        UpdateString(s, "_USE_LAST_SESSION_FONT_")
    endif

    if flags & _USE_DEFAULT_WIN_SIZE_
        UpdateString(s, "_USE_DEFAULT_WIN_SIZE_")
    elseif flags & _USE_LAST_SAVED_WIN_SIZE_
        UpdateString(s, "_USE_LAST_SAVED_WIN_SIZE_")
    elseif flags & _USE_LAST_SESSION_WIN_SIZE_
        UpdateString(s, "_USE_LAST_SESSION_WIN_SIZE_")
    endif

    if Length(s) == 0
        s = "_USE_DEFAULT_WIN_POS_|_USE_LAST_SAVED_FONT_|_USE_DEFAULT_WIN_SIZE_"
    endif
    loWriteString(s, 0)
end

proc WriteBlockType(integer block_type)
    case block_type
        when _inclusive_     loWriteString("_INCLUSIVE_", 0)
        when _non_inclusive_ loWriteString("_NON_INCLUSIVE_", 0)
        when _line_          loWriteString("_LINE_", 0)
        when _column_        loWriteString("_COLUMN_", 0)
    endcase
end

proc WriteFontSize(integer fontsize)

    if fontsize < 256
        WriteInteger()
        WriteComment(37, "// Point Size")
    else
        loWriteString(Format('0x', fontsize:-4:' ':16), 0)
        WriteComment(37, Format("// ", HiByte(fontsize), " width, ", LoByte(fontsize), " height"))
    endif
end


integer proc WriteCfg(string afn)
    integer saved = FALSE, opts_file, ch, TabWidth = Set(TabWidth, 1),
            opts_file_already_loaded, entab_on_save = Set(EntabOnSave, off)
    string opts_filename[_MAXPATH_]

    exportEntabOnSave = entab_on_save
    opts_filename = Trim(afn)
    if opts_filename == "" or FileExists(opts_filename) or GetBufferId(opts_filename)
        Set(TabWidth, TabWidth)
        Set(EntabOnSave, entab_on_save)
        return(FALSE)
    endif

    if opts_filename <> ""
        PushPosition()
        PushBlock()

        opts_file = GetBufferId(opts_filename)
        opts_file_already_loaded = opts_file <> 0
        if opts_file
            GotoBufferId(opts_file)
            EmptyBuffer()
        else
            opts_file = CreateBuffer(opts_filename)
        endif

        if opts_file and InsertData(SettingsData)
            lReplace(Chr(227),'Print','gn')
            lReplace(Chr(224),'Attr','gn')
            UnMarkBlock()

            GotoLine(2)
            GotoColumn(36)
            InsertText(GetDateStr() + ' at ' + GetTimeStr(), _OVERWRITE_)

            Down()
            repeat
                BegLine()
                ch = CurrChar()
                Right()
                case ch
                    when Asc('B')
                        WriteBoolean()
                    when Asc('6')
                        WriteInteger()
                        WriteComment(37, "// 1=" + Chr(218) + Chr(196) + Chr(191) + ", 2=" + Chr(213) + Chr(205) + Chr(184) + ", 3=" + Chr(214) + Chr(196) + Chr(183) + ", 4=" + Chr(201) + Chr(205) + Chr(187) + ", 5=" + Chr(222) + Chr(223) + Chr(221) + ", 6=" + Chr(219) + Chr(223) + Chr(219) + " 7=ASCII 8=3D")
                    when Asc('C')
                        loWriteString(rColor(xGetItemAttr(CurrChar())), 0)
                    when Asc('D')
                        WriteInteger()
                        WriteComment(37, "// 1=MM/DD/YY, 2=DD/MM/YY, 3=YY/MM/DD, 4=MM/DD/YYYY, 5=DD/MM/YYYY, 6=YYYY/MM/DD")
                    when Asc('E')
                        WriteInteger()
                        WriteComment(37, "// 0=Never, 1=Mouse, 2=Always")
                    when Asc('F')
                        WriteInteger()
                        WriteComment(37, "// 0=nothing, 1=^Z, 2=EOLType, 3=EOLType+^Z")
                    when Asc('G')
                        WriteInteger()
                        WriteComment(37, "// 0=no cursor, 1..8=cursor size, 9=vertical bar")
                    when Asc('H')
                        WriteInteger()
                        WriteComment(37, "// 18 approx 1 sec")
                    when Asc('I')
                        WriteInteger()
                    when Asc('J')
                        WriteStartUpFlags()
                    when Asc('K')
                        WritePickFileFlags()
                    when Asc('L')
                        WriteInteger()
                        WriteComment(37, "// 0=As Loaded, 1=^M (CR), 2=^J (LF), 3=^M^J (CR/LF)")
                    when Asc('M')
                        WriteInteger()
                        WriteComment(37, "// 1=24 hr (HH:MM:SS), 2=12 hr (HH:MM am/pm)")
                    when Asc('N')
                        loWriteString(SubStr(WWStr, Query(WordWrap) * 8 + 1, 8), 0)
                    when Asc('O')
                        loWriteString(ReadStringSetting(CurrChar()), Asc('"'))
                        WriteComment(37, "// F=FileName, D=Date, T=Time, P=Page")
                    when Asc('P')
                        WriteInteger()
                        WriteComment(37, "// 1=Single, 2=Double, 3=Triple, etc...")
                    when Asc('Q')
                        loWriteString(SubStr(SSStr, Query(SaveState) * 8 + 1, 8), 0)
                    when Asc('R')
                        WriteChr()
                        WriteComment(37, "// used when LineDrawType == 7")
                    when Asc('S')
                        loWriteString(ReadStringSetting(CurrChar()), Asc('"'))
                    when Asc('T')
                        WriteTabSet()
                    when Asc('U')
                        loWriteString(SubStr(UStr, Query(AutoIndent) * 8 + 1, 8), 0)
                    when Asc('V')
                        if Query(StartupVideoMode) <= _MAXIMIZED_
                            loWriteString(GetToken(VMStr, ' ', Query(StartupVideoMode) + 1), 0)
                        else
                            loWriteString(Format('0x', Query(StartupVideoMode):-4:' ':16), 0)
                            WriteComment(37, Format("// ", HiByte(Query(StartupVideoMode)), " columns, ", LoByte(Query(StartupVideoMode)), " rows"))
                        endif
                    when Asc('W')
                        WriteWordSet()
                    when Asc('X')
                        WriteInteger()
                        WriteComment(37, "// 1=" + Chr(218) + Chr(196) + Chr(191) + ", 2=" + Chr(213) + Chr(205) + Chr(184) + ", 3=" + Chr(214) + Chr(196) + Chr(183) + ", 4=" + Chr(201) + Chr(205) + Chr(187) + ", 5=ASCII, 6=Eraser, 7=User")
                    when Asc('Y')
                        loWriteString(SubStr(TStr, Query(TabType) * 10 + 1, 10), 0)
                    when Asc('Z')
                        loWriteString(Str(TabWidth,10), 0)
                    when Asc('"')
                        WriteChr()
                    when Asc('0')
                        loWriteString(GetToken(filelocking, ' ', Query(FileLocking) + 1), 0)
                    when Asc('1')
                        WriteBlockType(Query(MouseBlockType))
                    when ASC('2')
                        WriteGUIStartupFlags()
                    when ASC('3')
                        WriteFontSize(ReadIntegerSetting(CurrChar()))
                    when ASC('4')
                        WriteFontFlags()
                    when ASC('5')
                        WriteSpecialEffects()
                endcase
            until not Down()

            GotoColumn(2)
            MarkColumn()
            BegFile()
            BegLine()
            KillBlock()

            saved = SaveAs(opts_filename, _OVERWRITE_)
            if not opts_file_already_loaded
                AbandonFile()
            endif
        else
            Alarm()
            Warn("Not enough memory")
        endif

        PopBlock()
        PopPosition()
    endif
    Set(TabWidth,TabWidth)
    Set(EntabOnSave, entab_on_save)
    return(saved)
end


PROC Main()
 STRING iniFilenameS[255] = SplitPath(CurrMacroFilename(), _DRIVE_ | _PATH_) + "tseupgrade.ini"
 STRING outputFilenameS[255] = GetProfileStr("tseupgrade", "cfg_destination", "", iniFilenameS)
 WriteProfileStr("result", "saved", "false", iniFilenameS)
 IF outputFilenameS == ""
  Warn("Set cfg_destination in ", iniFilenameS)
  RETURN()
 ENDIF
 IF FileExists(outputFilenameS) OR GetBufferId(outputFilenameS)
  Warn("CFG destination already exists or is open: ", outputFilenameS)
  RETURN()
 ENDIF
 IF WriteCfg(outputFilenameS)
  WriteProfileStr("result", "saved", "true", iniFilenameS)
  Message("Exported current editor settings: ", outputFilenameS)
 ELSE
  Warn("CFG export failed: ", outputFilenameS)
 ENDIF
END
