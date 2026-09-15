/****************************************************************************\
 KeyFind.S - search loaded macro sources, then selected UI source.
 Package version 1.0.0.0.39/15.09.2026
 Based on v3.01/18.04.97 by DiK. Modified with OpenAI Codex.
\****************************************************************************/

integer loadedMacrosGI = 0
integer parsedMacrosGI = 0
integer sourceBufferGI = 0
integer searchBufferGI = 0
integer pathBufferGI = 0
integer showSearchPathsGB = FALSE
string macroSearchPathGS[255] = ""
string uiFileGS[_MAXPATH_] = ""

proc PROCListStartup()
 PushLocation()
 PushBlock()
 MarkLine(1, NumLines())
 GotoBufferId(loadedMacrosGI)
 CopyBlock()
 PopBlock()
 PopLocation()
end

string proc FNGetLoadedMacroName()
 integer lineLengthI = CurrLineLen()
 string lineTextS[255] = ""
 string macroNameS[255] = ""
 if lineLengthI > 255
  lineLengthI = 255
 endif
 if lineLengthI
  lineTextS = GetText(1, lineLengthI)
  macroNameS = GetToken(Trim(lineTextS), " ", 1)
 endif
 return(macroNameS)
end

proc PROCParseLoadedMacroNames()
 integer oldBufferI
 string macroNameS[255] = ""
 parsedMacrosGI = CreateTempBuffer()
 if parsedMacrosGI
  GotoBufferId(loadedMacrosGI)
  BegFile()
  repeat
   macroNameS = FNGetLoadedMacroName()
   if Length(macroNameS)
    oldBufferI = GotoBufferId(parsedMacrosGI)
    AddLine(macroNameS)
    GotoBufferId(oldBufferI)
   endif
  until not Down()
 endif
end

string proc FNFindMacroSource(string macroNameS)
 string macroBaseS[255] = ""
 string macroFileS[_MAXPATH_] = ""
 string sourceFileS[_MAXPATH_] = ""
 macroBaseS = SplitPath(macroNameS, _NAME_)
 if WhichOS() == _LINUX_
  macroBaseS = Lower(macroBaseS)
 endif
 sourceFileS = SearchPath(macroBaseS + ".s", ".")
 if Length(sourceFileS)
  return(sourceFileS)
 endif
 if Length(macroSearchPathGS)
  sourceFileS = SearchPath(macroBaseS + ".s", macroSearchPathGS)
  if Length(sourceFileS)
   return(sourceFileS)
  endif
  macroFileS = SearchPath(macroBaseS + ".mac", macroSearchPathGS)
  if Length(macroFileS)
   sourceFileS = SplitPath(macroFileS, _DRIVE_|_PATH_|_NAME_) + ".s"
   if FileExists(sourceFileS)
    return(sourceFileS)
   endif
  endif
 endif
 sourceFileS = SearchPath(macroBaseS + ".s", Query(TSEPath))
 if Length(sourceFileS)
  return(sourceFileS)
 endif
 macroFileS = SearchPath(macroBaseS + ".mac", Query(TSEPath))
 if Length(macroFileS)
  sourceFileS = SplitPath(macroFileS, _DRIVE_|_PATH_|_NAME_) + ".s"
  if FileExists(sourceFileS)
   return(sourceFileS)
  endif
 endif
 macroFileS = SearchPath(macroBaseS + ".mac", Query(TSEPath), "mac")
 if Length(macroFileS)
  sourceFileS = SplitPath(macroFileS, _DRIVE_|_PATH_|_NAME_) + ".s"
  if FileExists(sourceFileS)
   return(sourceFileS)
  endif
 endif
 sourceFileS = SearchPath(macroBaseS + ".s", Query(TSEPath), "mac")
 return(sourceFileS)
end

proc PROCAddSourcePath(string sourceFileS)
 integer oldBufferI = GotoBufferId(pathBufferGI)
 AddLine(ExpandPath(sourceFileS))
 GotoBufferId(oldBufferI)
end

integer proc FNInsertSearchSource(string sourceFileS)
 integer insertedB
 GotoBufferId(sourceBufferGI)
 EndFile()
 AddLine("// KEYFIND_SOURCE: " + ExpandPath(sourceFileS))
 AddLine("")
 BegLine()
 insertedB = InsertFile(sourceFileS, _DONT_PROMPT_)
 return(insertedB)
end

proc PROCLoadMacroSources()
 integer insertedB
 string macroNameS[255] = ""
 string sourceFileS[_MAXPATH_] = ""
 GotoBufferId(parsedMacrosGI)
 BegFile()
 repeat
  macroNameS = FNGetLoadedMacroName()
  if Length(macroNameS)
   sourceFileS = FNFindMacroSource(macroNameS)
   if Length(sourceFileS)
    PROCAddSourcePath(sourceFileS)
    insertedB = FNInsertSearchSource(sourceFileS)
    GotoBufferId(parsedMacrosGI)
   endif
  endif
 until not Down()
end

proc PROCSortList(integer leftI, integer rightI)
 MarkColumn(1, leftI, NumLines(), rightI)
 Sort(_IGNORE_CASE_)
end

keydef BrowseKeys
 <Alt K> PROCSortList(1, 28)
 <Alt C> PROCSortList(29, 64)
end

proc PROCBrowseHook()
 ListFooter("  {Alt-K} Sort by Key  {Alt-C} Sort by Command  {Enter} Search  ")
 Enable(BrowseKeys)
 UnHook(PROCBrowseHook)
end

integer proc FNBrowse()
 integer linesI = iif(NumLines() < Query(ScreenRows),
                      NumLines(), Query(ScreenRows))
 Hook(_LIST_STARTUP_, PROCBrowseHook)
 return(lList("Matching Key Assignments", Query(ScreenCols) - 1, linesI,
              _ENABLE_SEARCH_|_ENABLE_HSCROLL_))
end

proc PROCCompress(string findS)
 repeat
  UnmarkBlock()
  MarkLine()
  BegLine()
  if not lFind(findS, "lix")
   if lFind(findS, "ix")
    Up()
    KillBlock()
   else
    EndFile()
    KillBlock()
    break
   endif
  endif
 until not Down()
 UnmarkBlock()
 BegFile()
end

proc PROCAnnotateMatches(string findS)
 integer columnI
 string sourceFileS[_MAXPATH_] = ""

 BegFile()
 repeat
  BegLine()
  if lFind("^// KEYFIND_SOURCE: {.*}$", "cgix")
   sourceFileS = GetFoundText(1)
  else
   BegLine()
   if lFind(findS, "cgix")
    while CurrLineLen() < 64
     EndLine()
     InsertText(" ")
    endwhile
    BegLine()
    for columnI = 1 to 64
     Right()
    endfor
    InsertText("  File: " + sourceFileS + "  ", _INSERT_)
   endif
  endif
 until not Down()
 BegFile()
end

proc PROCMakeFindString(var string findS, integer regexB)
 integer oldSettingI = Set(RemoveTrailingWhite, OFF)
 if Lower(findS) == "all"
  InsertText("^<")
 else
  if not regexB
   InsertText(findS)
   BegLine()
   lReplace("{[\\\[\]{}?.*+#@~|^$]}", "\\\1", "gnx")
   findS = GetText(1, CurrLineLen())
   EmptyBuffer()
  endif
  InsertText("{" + findS + "}")
  lReplace(",#", "}|{", "gnx")
  BegLine()
  if findS[1] == "<"
   InsertText("^", _INSERT_)
  else
   InsertText("^<.*", _INSERT_)
  endif
 endif
 findS = GetText(1, CurrLineLen())
 Set(RemoveTrailingWhite, oldSettingI)
end

proc PROCCopySourcesToSearchBuffer()
 PushLocation()
 PushBlock()
 GotoBufferId(sourceBufferGI)
 MarkLine(1, NumLines())
 GotoBufferId(searchBufferGI)
 CopyBlock()
 PopBlock()
 PopLocation()
end

proc PROCCleanup()
 if searchBufferGI
  AbandonFile(searchBufferGI)
  searchBufferGI = 0
 endif
 if sourceBufferGI
  AbandonFile(sourceBufferGI)
  sourceBufferGI = 0
 endif
 if pathBufferGI
  AbandonFile(pathBufferGI)
  pathBufferGI = 0
 endif
 if parsedMacrosGI
  AbandonFile(parsedMacrosGI)
  parsedMacrosGI = 0
 endif
 if loadedMacrosGI
  AbandonFile(loadedMacrosGI)
  loadedMacrosGI = 0
 endif
end

proc Main()
 integer resultI = 0
 integer originalBufferI = GetBufferId()
 integer pathsToShowI = 0
 string findS[80] = ""
 string promptS[80] = "Enter text or TSE regex (comma=OR, 'all'=all keys)"
 string optionPromptS[80] = "Search options: i=ignore case, x=regular expression (i or ix)"
 string optionsS[8] = "ix"
 string additionalPromptS[80] = ""

 IF ( ( WhichOS() == _WINDOWS_ ) OR ( WhichOS() == _WINDOWS_NT_ ) )
  uiFileGS = "f:\bbc\taal\qedincke.ui"
 ELSEIF ( WhichOS() == _LINUX_ )
  uiFileGS = "/mnt/c/temp/tse_linux/tse45014working/ui/keyassignmentreplacementtseforlinuxbegin.ui"
 ENDIF
 if not Ask("Location of the .UI source file:", uiFileGS, _EDIT_HISTORY_)
  PurgeMacro(CurrMacroFileName())
  return()
 endif
 if not FileExists(uiFileGS)
  Warn("UI source file not found: ", uiFileGS)
  PurgeMacro(CurrMacroFileName())
  return()
 endif
 uiFileGS = ExpandPath(uiFileGS)

 loadedMacrosGI = NewFile()
 if not loadedMacrosGI
  Warn("Cannot allocate loaded-macro list")
  PurgeMacro(CurrMacroFileName())
  return()
 endif
 Hook(_LIST_STARTUP_, PROCListStartup)
 PushKey(<Escape>)
 PurgeMacro()
 UnHook(PROCListStartup)
 PROCParseLoadedMacroNames()
 if not parsedMacrosGI
  Warn("Cannot allocate parsed-macro list")
  PROCCleanup()
  PurgeMacro(CurrMacroFileName())
  return()
 endif

 if WhichOS() == _LINUX_
  additionalPromptS = "Additional macro directories (Linux path list):"
 else
  additionalPromptS = "Additional macro directories (; separated):"
 endif
 IF ( ( WhichOS() == _WINDOWS_ ) OR ( WhichOS() == _WINDOWS_NT_ ) )
  macroSearchPathGS = "c:\temp\"
 ELSEIF ( WhichOS() == _LINUX_ )
  macroSearchPathGS = "/mnt/c/temp/"
 ENDIF
 if not Ask(additionalPromptS, macroSearchPathGS, _EDIT_HISTORY_)
  PROCCleanup()
  GotoBufferId(originalBufferI)
  PurgeMacro(CurrMacroFileName())
  return()
 endif

 sourceBufferGI = CreateTempBuffer()
 searchBufferGI = CreateTempBuffer()
 pathBufferGI = CreateTempBuffer()
 if not sourceBufferGI or not searchBufferGI or not pathBufferGI
  Warn("Cannot allocate work space")
  PROCCleanup()
  GotoBufferId(originalBufferI)
  PurgeMacro(CurrMacroFileName())
  return()
 endif

 PROCLoadMacroSources()
 PROCAddSourcePath(uiFileGS)
 if not FNInsertSearchSource(uiFileGS)
  Warn("Cannot load UI file")
  PROCCleanup()
  GotoBufferId(originalBufferI)
  PurgeMacro(CurrMacroFileName())
  return()
 endif
 repeat
  GotoBufferId(searchBufferGI)
  EmptyBuffer()
  Set(X1, 1)
  Set(Y1, 1)
  findS = ""
  if not Ask(promptS, findS, _EDIT_HISTORY_)
   break
  endif
  optionsS = "ix"
  if not Ask(optionPromptS, optionsS, _EDIT_HISTORY_)
   break
  endif
  optionsS = Lower(Trim(optionsS))
  if optionsS == "i" or optionsS == "ix"
   PROCMakeFindString(findS, optionsS == "ix")
   EmptyBuffer()
   PROCCopySourcesToSearchBuffer()
   GotoBufferId(searchBufferGI)
   PROCAnnotateMatches(findS)
   PROCCompress(findS)
   if NumLines()
    resultI = FNBrowse()
   else
    Warn("No matching key assignments found")
   endif
  else
   Warn("Search options must be i or ix")
  endif
 until resultI == 0

 if showSearchPathsGB
  pathsToShowI = pathBufferGI
  pathBufferGI = 0
 endif
 PROCCleanup()
 if pathsToShowI
  GotoBufferId(pathsToShowI)
  BegFile()
 else
  GotoBufferId(originalBufferI)
 endif
 UpdateDisplay()
 PurgeMacro(CurrMacroFileName())
end
