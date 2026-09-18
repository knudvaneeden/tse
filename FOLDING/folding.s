/*
  folding.s
  Simulated folding for The SemWare Editor (TSE) Pro.

  Version : 1.0.0.0.3
  Date    : 2026-09-18 13:16:41 UTC
  Author  : OpenAI GPT-5 Codex

  TSE SAL has no native command for hiding individual lines. This macro
  therefore moves a marked line block into a hidden buffer and inserts one
  placeholder line. A sidecar file preserves each fold between TSE sessions.

  IMPORTANT: Use FoldingSaveFile(), FoldingSaveAs(), or unfold all folds
  before using TSE's ordinary save commands.
*/

#define DEFAULT_CONFIRM_FOLD            TRUE
#define DEFAULT_CONFIRM_UNFOLD_ALL      TRUE
#define DEFAULT_UNFOLD_BEFORE_SAVE      TRUE

string  GSVersion[20] = "1.0.0.0.3"
string  GSSection[20] = "folding"
string  GSDefaultMarkerPrefix[80] = "// [FOLDING:"
string  GSDefaultSidecarMiddle[40] = ".folding."
string  GSIniFilename[255] = ""
string  GSMarkerPrefix[80] = "// [FOLDING:"
string  GSSidecarMiddle[40] = ".folding."
integer GBConfirmFold = DEFAULT_CONFIRM_FOLD
integer GBConfirmUnfoldAll = DEFAULT_CONFIRM_UNFOLD_ALL
integer GBUnfoldBeforeSave = DEFAULT_UNFOLD_BEFORE_SAVE
integer GIFoldNumber = 0

string proc FNBooleanText(integer valueI)
  if valueI
    return("yes")
  endif
  return("no")
end

integer proc FNIsYes(string valueS, integer defaultB)
  string compareS[255] = ""

  compareS = Lower(Trim(valueS))
  if compareS == "yes" or compareS == "true" or compareS == "1" or compareS == "on"
    return(TRUE)
  endif
  if compareS == "no" or compareS == "false" or compareS == "0" or compareS == "off"
    return(FALSE)
  endif
  return(defaultB)
end

proc PROCLoadConfiguration()
  string valueS[255] = ""

  GSIniFilename = SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_) + "folding.ini"

  GSMarkerPrefix = GetProfileStr(GSSection, "marker_prefix",
                                 GSDefaultMarkerPrefix, GSIniFilename)
  if GSMarkerPrefix == ""
    GSMarkerPrefix = GSDefaultMarkerPrefix
  endif

  GSSidecarMiddle = GetProfileStr(GSSection, "sidecar_middle",
                                  GSDefaultSidecarMiddle, GSIniFilename)
  if GSSidecarMiddle == ""
    GSSidecarMiddle = GSDefaultSidecarMiddle
  endif

  valueS = GetProfileStr(GSSection, "confirm_fold",
                         FNBooleanText(DEFAULT_CONFIRM_FOLD), GSIniFilename)
  GBConfirmFold = FNIsYes(valueS, DEFAULT_CONFIRM_FOLD)

  valueS = GetProfileStr(GSSection, "confirm_unfold_all",
                         FNBooleanText(DEFAULT_CONFIRM_UNFOLD_ALL), GSIniFilename)
  GBConfirmUnfoldAll = FNIsYes(valueS, DEFAULT_CONFIRM_UNFOLD_ALL)

  valueS = GetProfileStr(GSSection, "unfold_before_save",
                         FNBooleanText(DEFAULT_UNFOLD_BEFORE_SAVE), GSIniFilename)
  GBUnfoldBeforeSave = FNIsYes(valueS, DEFAULT_UNFOLD_BEFORE_SAVE)
end

string proc FNSidecarFilename(string sourceFilenameS, string foldNumberS)
  if Length(sourceFilenameS) + Length(GSSidecarMiddle) +
     Length(foldNumberS) + 4 > 255
    return("")
  endif
  return(sourceFilenameS + GSSidecarMiddle + foldNumberS + ".dat")
end

integer proc FNIsFoldMarker()
  return(GetText(1, Length(GSMarkerPrefix)) == GSMarkerPrefix)
end

string proc FNMarkerFoldNumber()
  string lineS[255] = ""
  string remainderS[255] = ""
  integer colonI = 0

  if not FNIsFoldMarker()
    return("")
  endif

  lineS = GetText(1, 255)
  remainderS = SubStr(lineS, Length(GSMarkerPrefix) + 1, 255)
  colonI = Pos(":", remainderS)
  if colonI < 2
    return("")
  endif
  return(SubStr(remainderS, 1, colonI - 1))
end

integer proc FNMarkerLineCount()
  string lineS[255] = ""
  string remainderS[255] = ""
  integer colonI = 0
  integer spaceI = 0

  if not FNIsFoldMarker()
    return(0)
  endif

  lineS = GetText(1, 255)
  remainderS = SubStr(lineS, Length(GSMarkerPrefix) + 1, 255)
  colonI = Pos(":", remainderS)
  if colonI < 2
    return(0)
  endif
  remainderS = SubStr(remainderS, colonI + 1, 255)
  spaceI = Pos(" ", remainderS)
  if spaceI < 2
    return(0)
  endif
  return(Val(SubStr(remainderS, 1, spaceI - 1)))
end

string proc FNFoldHeader(string foldNumberS, integer lineCountI)
  return("FOLDING-DATA:1:" + foldNumberS + ":" + Str(lineCountI))
end

integer proc FNNextFoldNumber(string sourceFilenameS, var string foldNumberS)
  string storageFilenameS[255] = ""

  repeat
    GIFoldNumber = GIFoldNumber + 1
    if GIFoldNumber >= 2147483647
      GIFoldNumber = 1
    endif
    foldNumberS = Str(GIFoldNumber)
    storageFilenameS = FNSidecarFilename(sourceFilenameS, foldNumberS)
    if storageFilenameS == ""
      return(FALSE)
    endif
  until not GetBufferId(storageFilenameS) and not FileExists(storageFilenameS)

  return(TRUE)
end

proc PROCFoldBlock()
  integer blockTypeI = 0
  integer sourceBufferI = 0
  integer storageBufferI = 0
  integer firstLineI = 0
  integer lastLineI = 0
  integer lineCountI = 0
  integer oldInsertAboveI = 0
  string foldNumberS[20] = ""
  string sourceFilenameS[255] = ""
  string storageFilenameS[255] = ""
  string headerS[255] = ""
  string markerS[255] = ""

  blockTypeI = IsBlockInCurrFile()
  if not blockTypeI
    Warn("FOLDING: Please mark a block in the current file.")
    return()
  endif

  firstLineI = Query(BlockBegLine)
  lastLineI = Query(BlockEndLine)

  // Character, stream, and column blocks are deliberately expanded to
  // complete lines. MoveBlock() can then restore the original line layout.
  if blockTypeI <> _LINE_
    UnMarkBlock()
    MarkLine(firstLineI, lastLineI)
  endif

  if GBConfirmFold
    if YesNo("Fold the complete lines covered by the marked block?") <> 1
      return()
    endif
  endif

  sourceBufferI = GetBufferId()
  sourceFilenameS = CurrFilename()
  lineCountI = lastLineI - firstLineI + 1

  if lineCountI < 2
    Warn("FOLDING: At least two complete lines must be marked.")
    return()
  endif

  if sourceFilenameS == ""
    Warn("FOLDING: Save or name the source file before folding it.")
    return()
  endif

  if not FNNextFoldNumber(sourceFilenameS, foldNumberS)
    Warn("FOLDING: The sidecar filename would exceed 255 characters.")
    return()
  endif
  storageFilenameS = FNSidecarFilename(sourceFilenameS, foldNumberS)
  headerS = FNFoldHeader(foldNumberS, lineCountI)
  markerS = GSMarkerPrefix + foldNumberS + ":" + Str(lineCountI) + " lines]"

  storageBufferI = CreateBuffer(storageFilenameS, _HIDDEN_)
  if not storageBufferI
    Warn("FOLDING: Unable to create the hidden storage buffer.")
    return()
  endif

  MoveBlock()
  if NumLines() > lineCountI
    BegFile()
    DelLine()
  endif
  BegFile()
  InsertLine(headerS)
  if not SaveFile()
    DelLine()
    MarkLine(1, NumLines())
    GotoBufferId(sourceBufferI)
    GotoLine(firstLineI)
    oldInsertAboveI = Query(InsertLineBlocksAbove)
    Set(InsertLineBlocksAbove, ON)
    MoveBlock()
    Set(InsertLineBlocksAbove, oldInsertAboveI)
    UnMarkBlock()
    AbandonFile(storageBufferI)
    Warn("FOLDING: Unable to save the fold sidecar file. The text was restored.")
    return()
  endif
  GotoBufferId(sourceBufferI)
  UnMarkBlock()
  GotoLine(firstLineI)
  BegLine()
  InsertLine(markerS)
  GotoLine(firstLineI)
  Message("FOLDING: Folded ", lineCountI, " lines as fold ", foldNumberS, ".")
end

integer proc FNUnfoldAtCursor(integer showMessageB)
  integer sourceBufferI = 0
  integer sourceLineI = 0
  integer storageBufferI = 0
  integer oldInsertAboveI = 0
  integer restoredLinesI = 0
  integer expectedLinesI = 0
  string foldNumberS[20] = ""
  string sourceFilenameS[255] = ""
  string storageFilenameS[255] = ""
  string expectedHeaderS[255] = ""

  foldNumberS = FNMarkerFoldNumber()
  if foldNumberS == ""
    if showMessageB
      Warn("FOLDING: The cursor is not on a folding placeholder.")
    endif
    return(FALSE)
  endif

  sourceBufferI = GetBufferId()
  sourceLineI = CurrLine()
  sourceFilenameS = CurrFilename()
  expectedLinesI = FNMarkerLineCount()
  storageFilenameS = FNSidecarFilename(sourceFilenameS, foldNumberS)
  expectedHeaderS = FNFoldHeader(foldNumberS, expectedLinesI)

  if storageFilenameS == "" or expectedLinesI < 1
    Warn("FOLDING: The folding placeholder is invalid.")
    return(FALSE)
  endif

  storageBufferI = GetBufferId(storageFilenameS)

  if not storageBufferI and FileExists(storageFilenameS)
    storageBufferI = EditBuffer(storageFilenameS, _HIDDEN_)
  endif

  if not storageBufferI
    Warn("FOLDING: Stored text for fold " + foldNumberS + " is unavailable.")
    return(FALSE)
  endif

  GotoBufferId(storageBufferI)
  BegFile()
  if GetText(1, 255) <> expectedHeaderS or NumLines() - 1 <> expectedLinesI
    GotoBufferId(sourceBufferI)
    GotoLine(sourceLineI)
    Warn("FOLDING: Sidecar validation failed for fold " + foldNumberS + ".")
    return(FALSE)
  endif
  DelLine()
  restoredLinesI = NumLines()
  MarkLine(1, NumLines())

  GotoBufferId(sourceBufferI)
  GotoLine(sourceLineI)
  DelLine()
  oldInsertAboveI = Query(InsertLineBlocksAbove)
  Set(InsertLineBlocksAbove, ON)
  MoveBlock()
  Set(InsertLineBlocksAbove, oldInsertAboveI)
  UnMarkBlock()
  GotoLine(sourceLineI)
  AbandonFile(storageBufferI)

  if showMessageB
    Message("FOLDING: Restored fold ", foldNumberS, " (", restoredLinesI, " lines).")
  endif
  return(TRUE)
end

integer proc FNAllFoldDataAvailable()
  integer resultB = TRUE
  string foldNumberS[20] = ""
  string storageFilenameS[255] = ""
  string sourceFilenameS[255] = ""

  sourceFilenameS = CurrFilename()
  PushPosition()
  BegFile()
  repeat
    if FNIsFoldMarker()
      foldNumberS = FNMarkerFoldNumber()
      storageFilenameS = FNSidecarFilename(sourceFilenameS, foldNumberS)
      if foldNumberS == "" or storageFilenameS == "" or
         (not GetBufferId(storageFilenameS) and not FileExists(storageFilenameS))
        resultB = FALSE
      endif
    endif
  until not resultB or not Down()
  PopPosition()
  return(resultB)
end

proc PROCSaveFoldedFile()
  if not FNAllFoldDataAvailable()
    Warn("FOLDING: A placeholder has no matching sidecar file. Save cancelled.")
    return()
  endif
  if SaveFile()
    Message("FOLDING: Folded source and sidecar data saved.")
  endif
end

proc PROCUnfoldAtCursor()
  FNUnfoldAtCursor(TRUE)
end

integer proc PROCUnfoldAll(integer askFirstB, integer showMessageB)
  integer foldsI = 0

  if askFirstB and GBConfirmUnfoldAll
    if YesNo("Unfold all folds in the current file?") <> 1
      return(FALSE)
    endif
  endif

  PushPosition()
  BegFile()
  repeat
    if FNIsFoldMarker()
      if FNUnfoldAtCursor(FALSE)
        foldsI = foldsI + 1
      else
        PopPosition()
        return(FALSE)
      endif
    endif
  until not Down()
  PopPosition()

  if showMessageB
    Message("FOLDING: Restored ", foldsI, " fold(s).")
  endif
  return(TRUE)
end

proc PROCUnfoldAllCommand()
  PROCUnfoldAll(TRUE, TRUE)
end

integer proc FNFoldingSaveFile()
  if GBUnfoldBeforeSave
    if not PROCUnfoldAll(FALSE, FALSE)
      return(FALSE)
    endif
  endif
  return(SaveFile())
end

proc PROCFoldingSaveFile()
  if FNFoldingSaveFile()
    Message("FOLDING: File saved safely with all text restored.")
  endif
end

proc PROCFoldingSaveAs()
  if GBUnfoldBeforeSave
    if not PROCUnfoldAll(FALSE, FALSE)
      return()
    endif
  endif
  SaveAs()
end

proc Main()
  PROCLoadConfiguration()
  Message("FOLDING ", GSVersion,
          " loaded. F11 folds; Shift+F11 unfolds; Alt+Shift+F12 saves folded.")
end

<F11>             PROCFoldBlock()
<Shift F11>       PROCUnfoldAtCursor()
<Ctrl F11>        PROCUnfoldAllCommand()
<Shift F12>       PROCFoldingSaveFile()
<CtrlShift F12>   PROCFoldingSaveAs()
<AltShift F12>    PROCSaveFoldedFile()
