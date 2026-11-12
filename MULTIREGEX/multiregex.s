// MULTIREGEX.S
// Version: 1.0.0.0.31
// Date: 2026-11-10
// TSE SAL only. Prototype chunked search, global/local (inclusive, noninclusive, line block), repeat-forward.
// Experimental SAL-only implementation: compile and test before large files.

// BEGIN embedded clipstack.inc version 1.0.0.0.7
/*
   File       : clipstack.inc
   Purpose    : Standalone clipboard stack library for TSE SAL.
   Version    : 1.0.0.0.7
   Date       : 2026-09-02
   LLM        : OpenAI Codex

   No other include files are required by this library.

   Public actions:

      PROCPushClipboard()
      PROCPopClipboard()
      PROCPushClipboardWin()
      PROCPopClipboardWin()

   Example:

      PROCPushClipboard()
      // Code that changes the TSE clipboard.
      PROCPopClipboard()
*/

#ifdef CLIPSTACK_INCLUDED
#else
   #define CLIPSTACK_INCLUDED TRUE

   integer clipStackTopI = 0
   integer clipStackWinTopI = 0
   string clipStackPrefixS[40] = "_codex_clipstack_"

   string proc FNClipStackDataName(integer levelI)
      return(clipStackPrefixS + "data_" + Str(levelI))
   end

   string proc FNClipStackInfoName(integer levelI)
      return(clipStackPrefixS + "info_" + Str(levelI))
   end

   string proc FNClipStackWinDataName(integer levelI)
      return(clipStackPrefixS + "win_data_" + Str(levelI))
   end

   integer proc FNClipStackOpen(string bufferNameS)
      integer bufferIdI = 0

      bufferIdI = GetBufferId(bufferNameS)
      if (bufferIdI == 0)
         bufferIdI = CreateBuffer(bufferNameS, _SYSTEM_)
      endif

      if (bufferIdI <> 0)
         if GotoBufferId(bufferIdI)
         or (GetBufferId() == bufferIdI)
            return(bufferIdI)
         endif
      endif

      return(0)
   end

   integer proc PROCPushClipboard()
      integer originalBufferIdI = GetBufferId()
      integer oldUnmarkAfterPasteI = 0
      integer dataBufferIdI = 0
      integer infoBufferIdI = 0
      integer blockTypeI = 0
      integer columnWidthI = 0
      integer resultI = FALSE

      PushBlock()
      oldUnmarkAfterPasteI = Set(UnMarkAfterPaste, OFF)
      clipStackTopI = clipStackTopI + 1

      dataBufferIdI = FNClipStackOpen(FNClipStackDataName(clipStackTopI))
      if (dataBufferIdI <> 0)
         UnMarkBlock()
         EmptyBuffer()

         if Paste()
         or ((NumLines() == 0) and (CurrLineLen() == 0))
            blockTypeI = IsBlockMarked()
            columnWidthI = CurrLineLen()

            infoBufferIdI = FNClipStackOpen(
               FNClipStackInfoName(clipStackTopI))
            if (infoBufferIdI <> 0)
               EmptyBuffer()
               AddLine(Str(blockTypeI) + " " + Str(columnWidthI))
               resultI = TRUE
            endif
         endif
      endif

      if (resultI == FALSE)
         clipStackTopI = clipStackTopI - 1
      endif

      Set(UnMarkAfterPaste, oldUnmarkAfterPasteI)
      GotoBufferId(originalBufferIdI)
      PopBlock()

      if (resultI == FALSE)
         Warn("PROCPushClipboard: unable to save the TSE clipboard")
      endif

      return(resultI)
   end

   integer proc PROCPopClipboard()
      integer originalBufferIdI = GetBufferId()
      integer dataBufferIdI = 0
      integer infoBufferIdI = 0
      integer blockTypeI = 0
      integer columnWidthI = 0
      integer resultI = FALSE
      string infoLineS[80] = ""

      if (clipStackTopI <= 0)
         Warn("PROCPopClipboard: the clipboard stack is empty")
         return(FALSE)
      endif

      PushBlock()

      infoBufferIdI = FNClipStackOpen(FNClipStackInfoName(clipStackTopI))
      if (infoBufferIdI <> 0)
         BegFile()
         infoLineS = GetText(1, CurrLineLen())
         blockTypeI = Val(GetToken(infoLineS, " ", 1))
         columnWidthI = Val(GetToken(infoLineS, " ", 2))

         dataBufferIdI = FNClipStackOpen(FNClipStackDataName(clipStackTopI))
         if (dataBufferIdI <> 0)
            UnMarkBlock()

            if (blockTypeI == 0)
               if GotoBufferId(Query(ClipBoardId))
               or (GetBufferId() == Query(ClipBoardId))
                  EmptyBuffer()
                  resultI = TRUE
               endif
            else
               case blockTypeI
                  when _LINE_
                     MarkLine(1, NumLines())
                  when _COLUMN_
                     MarkColumn(1, 1, NumLines(), columnWidthI)
                  when _INCLUSIVE_, _NONINCLUSIVE_
                     BegFile()
                     MarkChar()
                     EndFile()
                  otherwise
                     blockTypeI = 0
               endcase

               if (blockTypeI <> 0)
                  if Copy()
                     resultI = TRUE
                  endif
               endif
            endif

            if GotoBufferId(dataBufferIdI)
            or (GetBufferId() == dataBufferIdI)
               UnMarkBlock()
               EmptyBuffer()
            endif

            if GotoBufferId(infoBufferIdI)
            or (GetBufferId() == infoBufferIdI)
               EmptyBuffer()
            endif
         endif
      endif

      if (resultI)
         clipStackTopI = clipStackTopI - 1
      endif

      GotoBufferId(originalBufferIdI)
      PopBlock()

      if (resultI == FALSE)
         Warn("PROCPopClipboard: unable to restore the TSE clipboard")
      endif

      return(resultI)
   end

   integer proc PROCPushClipboardWin()
      integer originalBufferIdI = GetBufferId()
      integer oldUnmarkAfterPasteI = 0
      integer dataBufferIdI = 0
      integer resultI = FALSE

      PushBlock()
      oldUnmarkAfterPasteI = Set(UnMarkAfterPaste, OFF)
      clipStackWinTopI = clipStackWinTopI + 1

      dataBufferIdI = FNClipStackOpen(
         FNClipStackWinDataName(clipStackWinTopI))
      if (dataBufferIdI <> 0)
         UnMarkBlock()
         EmptyBuffer()

         if PasteFromWinClip()
         or ((NumLines() == 0) and (CurrLineLen() == 0))
            resultI = TRUE
         endif
      endif

      if (resultI == FALSE)
         clipStackWinTopI = clipStackWinTopI - 1
      endif

      Set(UnMarkAfterPaste, oldUnmarkAfterPasteI)
      GotoBufferId(originalBufferIdI)
      PopBlock()

      if (resultI == FALSE)
         Warn("PROCPushClipboardWin: unable to save the Windows clipboard")
      endif

      return(resultI)
   end

   integer proc PROCPopClipboardWin()
      integer originalBufferIdI = GetBufferId()
      integer dataBufferIdI = 0
      integer resultI = FALSE

      if (clipStackWinTopI <= 0)
         Warn("PROCPopClipboardWin: the Windows clipboard stack is empty")
         return(FALSE)
      endif

      PushBlock()

      dataBufferIdI = FNClipStackOpen(
         FNClipStackWinDataName(clipStackWinTopI))
      if (dataBufferIdI <> 0)
         UnMarkBlock()
         BegFile()
         MarkChar()
         EndFile()

         if CopyToWinClip()
            resultI = TRUE
         endif

         if (resultI)
            UnMarkBlock()
            EmptyBuffer()
            clipStackWinTopI = clipStackWinTopI - 1
         endif
      endif

      GotoBufferId(originalBufferIdI)
      PopBlock()

      if (resultI == FALSE)
         Warn("PROCPopClipboardWin: unable to restore the Windows clipboard")
      endif

      return(resultI)
   end

#endif

// END embedded clipstack.inc

string mrPattern[255] = ""
string mrOptions[255] = "ix"
integer mrWindow = 4000
integer mrAdaptiveWindow = 30000
// Maximum displayed source-match text; result filename/coordinates stay intact.
integer mrResultPreviewLength = 240
integer mrFastScan = TRUE
// FALSE (default): keep source text offscreen during the search.
// TRUE: retain the previous live source-file display behavior.
integer mrShowSourceDuringSearch = FALSE
// 1: exact two-byte cached line lengths; 0: original v19 planner (default).
integer mrFastPlan = TRUE
// Optional phase profiling; turn off for uninstrumented A/B benchmarks.
integer mrProfileEnabled = TRUE
// Combined ring results retain their source buffer ids in a hidden map.
integer mrAllMode = FALSE
integer mrAllResults = 0
integer mrAllMap = 0
integer mrAllHits = 0
integer mrAllFiles = 0
integer mrAllLines = 0
integer mrAllSkipped = 0
integer mrFirstResultRow = 13
integer mrPlanTicks = 0
integer mrBuildTicks = 0
integer mrRegexTicks = 0
integer mrMapTicks = 0
integer mrResultTicks = 0
integer mrOtherTicks = 0
integer mrChunkCount = 0
integer mrAdaptiveCount = 0
integer mrRegexCalls = 0
integer mrOverlap = 2000
// Increase only the physical-line cap for small ring files; never change
// the character window/overlap or the large-file search path.
integer mrRingMaxChunkLines = 4096
integer mrSource = 0
integer mrNextLine = 1
integer mrNextColumn = 1
integer mrValid = FALSE
integer mrResults = 0
integer mrResultsSource = 0
integer mrResultsRow = 13
integer mrViewActive = FALSE
integer mrSearchKeysActive = FALSE
integer mrLocal = FALSE
integer mrBlockFirst = 0
integer mrBlockLast = 0
integer mrBlockKind = 0
integer mrBlockStartCol = 1
integer mrBlockEndCol = 1
string mrIniPath[255] = ""

// Profile calls require a full path; an unqualified filename would use WINDIR.
string proc MR_IniFilename()
    string macroName[255] = CurrMacroFilename()
    integer j = Length(macroName)
    while j > 0
        if SubStr(macroName, j, 1) == "\" or SubStr(macroName, j, 1) == "/"
            return(SubStr(macroName, 1, j) + "multiregex.ini")
        endif
        j = j - 1
    endwhile
    return(CurrDir() + "multiregex.ini")
end

// Reject unsupported letters and duplicates; always display g,i,l,v,x order.
string proc MR_NormalizeOptions(string rawOptions)
    string ordered[255] = "agilvx"
    string normalized[255] = ""
    string lowered[255] = Lower(rawOptions)
    string letter[2] = ""
    integer j = 1
    integer k = 1
    while j <= Length(lowered)
        letter = SubStr(lowered, j, 1)
        if Pos(letter, ordered) == 0
            return("")
        endif
        if Pos(letter, SubStr(lowered, j + 1, 255)) > 0
            return("")
        endif
        j = j + 1
    endwhile
    while k <= Length(ordered)
        letter = SubStr(ordered, k, 1)
        if Pos(letter, lowered) > 0
            normalized = normalized + letter
        endif
        k = k + 1
    endwhile
    return(normalized)
end

// Native TSE SAL GetTime() returns hundredths of a second since midnight.
// This timer is intentionally independent of DLLs and external programs.
string proc MR_TwoDigits(integer valueI)
    if valueI < 10
        return("0" + Str(valueI))
    endif
    return(Str(valueI))
end

string proc MR_ElapsedText(integer centisecondsI)
    integer hoursI = 0
    integer minutesI = 0
    integer secondsI = 0
    integer fractionI = 0
    hoursI = centisecondsI / 360000
    minutesI = (centisecondsI / 6000) mod 60
    secondsI = (centisecondsI / 100) mod 60
    fractionI = centisecondsI mod 100
    return(Format(MR_TwoDigits(hoursI), ":", MR_TwoDigits(minutesI),
                  ":", MR_TwoDigits(secondsI), ".", MR_TwoDigits(fractionI)))
end

// Preview the ACTUAL native LFind() match (not the search pattern).
// GetFoundText() supplies at most one SAL string (255 characters). Keep
// filename and source coordinates intact by fitting the preview into the
// space remaining on each result line. No extra result rows are introduced.
string proc MR_MatchPreview(string foundTextS)
    string previewS[255] = ""
    integer indexI = 1
    integer charValueI = 0
    integer limitI = Length(foundTextS)
    if limitI > mrResultPreviewLength
        limitI = mrResultPreviewLength
    endif
    for indexI = 1 to limitI
        charValueI = Asc(SubStr(foundTextS, indexI, 1))
        if charValueI < 32 or charValueI == 127
            previewS = previewS + " "
        else
            previewS = previewS + SubStr(foundTextS, indexI, 1)
        endif
    endfor
    if Length(foundTextS) > limitI and limitI <= 252
        previewS = previewS + "..."
    endif
    return(previewS)
end

// TSE SAL Format()/string values cannot exceed 255 characters. Preserve the
// entire coordinate prefix and use as much of the preview as will fit.
string proc MR_ResultText(string prefixS, string previewS)
    integer remainingI = 255 - Length(prefixS)
    if remainingI <= 0
        return(prefixS)
    endif
    if Length(previewS) > remainingI
        if remainingI > 3
            return(prefixS + SubStr(previewS, 1, remainingI - 3) + "...")
        endif
        return(prefixS + SubStr(previewS, 1, remainingI))
    endif
    return(prefixS + previewS)
end

// Prepend, rather than append, the summary so it is visible immediately.
// Existing match lines are preserved and their source coordinates unchanged.
// GetTime() wraps at midnight; each sampled phase must handle the wrap.
integer proc MR_TickDelta(integer fromTickI, integer toTickI)
    integer differenceI = toTickI - fromTickI
    if differenceI < 0
        differenceI = differenceI + 8640000
    endif
    return(differenceI)
end

proc MR_PrependSummary(integer bufferId, integer lineCount,
                        integer hits, integer centisecondsI,
                        integer skippedLines, integer linesPerSecond)
    GotoBufferId(bufferId)
    BegFile()
    InsertLine("----------------------------------------------------------")
    if mrProfileEnabled
        // Exact elapsed phase totals with hundredth-second resolution.
        // The unaccounted portion includes navigation and timer overhead.
        InsertLine(Format("Other / overhead : ",
                   MR_ElapsedText(mrOtherTicks)))
        InsertLine(Format("Results writing  : ",
                   MR_ElapsedText(mrResultTicks)))
        InsertLine(Format("Position mapping : ",
                   MR_ElapsedText(mrMapTicks)))
        InsertLine(Format("Regex LFind      : ",
                   MR_ElapsedText(mrRegexTicks)))
        InsertLine(Format("Copy / flatten   : ",
                   MR_ElapsedText(mrBuildTicks)))
        InsertLine(Format("Chunk planning   : ",
                   MR_ElapsedText(mrPlanTicks)))
        InsertLine("Phase timing (HH:MM:SS.cc):")
        InsertLine(Format("Regex calls      : ", mrRegexCalls))
        InsertLine(Format("Adaptive chunks  : ", mrAdaptiveCount))
        InsertLine(Format("Chunks built     : ", mrChunkCount))
    endif
    InsertLine(Format("Search speed     : ", linesPerSecond, " lines/second"))
    InsertLine(Format("Elapsed time     : ", MR_ElapsedText(centisecondsI)))
    InsertLine(Format("Matches found    : ", hits))
    InsertLine(Format("Lines scanned    : ", lineCount))
    if mrAllMode
        InsertLine(Format("Files searched   : ", mrAllFiles))
    endif
    InsertLine(Format("Search options   : ", mrOptions))
    InsertLine(Format("Expression       : ", mrPattern))
    InsertLine("----------------------------------------------------------")
    InsertLine("MULTIREGEX 1.0.0.0.31 - Search results")
    if skippedLines > 0
        // Preserve the first match at row 13 by appending the warning at end.
        EndFile()
        AddLine(Format("WARNING: skipped overlong lines: ", skippedLines,
                       " (not exhaustively searched)"))
    endif
end

// Convert monotonically increasing match offsets to original coordinates.
// Each source line is visited at most once per chunk during mapping, rather
// than rescanning from the first line for every match.
integer proc MR_MapOffset(integer sourceId, integer firstLine,
                          integer lastLine, integer offset,
                          var integer nextMapLine,
                          var integer mappedChars,
                          var integer destLine, var integer destCol)
    integer lineLengthI = 0
    integer fromColI = 1
    integer thruColI = 0
    if offset <= mappedChars
        nextMapLine = firstLine
        mappedChars = 0
    endif
    GotoBufferId(sourceId)
    while nextMapLine <= lastLine
        GotoLine(nextMapLine)
        fromColI = 1
        thruColI = CurrLineLen()
        if mrLocal and mrBlockKind <> _LINE_
            if nextMapLine == mrBlockFirst
                fromColI = mrBlockStartCol
            endif
            if nextMapLine == mrBlockLast and mrBlockEndCol < thruColI
                thruColI = mrBlockEndCol
            endif
        endif
        lineLengthI = thruColI - fromColI + 1
        if lineLengthI < 0
            lineLengthI = 0
        endif
        if offset <= mappedChars + lineLengthI and lineLengthI > 0
            destLine = nextMapLine
            destCol = fromColI + offset - mappedChars - 1
            return(TRUE)
        endif
        mappedChars = mappedChars + lineLengthI
        nextMapLine = nextMapLine + 1
    endwhile
    return(FALSE)
end

// Clip a copied chunk, never the original source buffer.
// The last-line suffix is removed before the first-line prefix.
integer proc MR_TrimTemp(integer workId, integer firstLine,
                         integer lastLine)
    integer n = 0
    integer colI = 1
    GotoBufferId(workId)
    if not mrLocal or mrBlockKind == _LINE_
        return(TRUE)
    endif
    if lastLine == mrBlockLast
        n = lastLine - firstLine + 1
        GotoLine(n)
        if mrBlockEndCol < CurrLineLen()
            BegLine()
            Right(mrBlockEndCol)
            while CurrCol() <= CurrLineLen()
                DelChar()
            endwhile
        endif
    endif
    if firstLine == mrBlockFirst and mrBlockStartCol > 1
        BegFile()
        colI = 1
        while colI < mrBlockStartCol and CurrLineLen() > 0
            DelChar()
            colI = colI + 1
        endwhile
    endif
    return(TRUE)
end


// Interactive results navigator.  A Process() session allows the normal
// cursor movement keys and TSE scrolling to remain available.  These
// keydefs are enabled only while this particular results view is active.
// The source buffer and result list remain open throughout the session.
// Forward declarations required because the keydefs refer to handlers
// whose implementations follow below.
forward proc MR_OpenResult()
forward proc MR_ResultEnter()
forward proc MR_MouseOpenResult()
forward proc MR_ExitResults()
forward proc MR_ReturnResults()
forward proc MR_RepeatForward()
forward proc MR_ExitSearchSession()

keydef MRResultsKeys
    <Enter> MR_ResultEnter()
    <LeftBtn> MR_MouseOpenResult()
    <Escape> MR_ExitResults()
    <CtrlAltShift X> MR_ExitResults()
end

keydef MRSourceKeys
    <CtrlAlt G> MR_ReturnResults()
    <Escape> MR_ExitResults()
    <CtrlAltShift X> MR_ExitResults()
end

// Active only while using the normal (non-view) MULTIREGEX search.
keydef MRRepeatKeys
    <Ctrl L> MR_RepeatForward()
    <Escape> MR_ExitSearchSession()
    <CtrlAltShift X> MR_ExitSearchSession()
end


// Enter does not navigate or alter the generated results buffer.
proc MR_ResultEnter()
    MR_OpenResult()
end

proc MR_OpenResult()
    string rowText[255] = ""
    string leftPart[255] = ""
    integer commaAt = 0
    integer colonAt = 0
    integer hitLine = 0
    integer hitCol = 0
    if not mrViewActive or GetBufferId() <> mrResults
        return()
    endif
    rowText = GetText(1, CurrLineLen())
    commaAt = Pos(",", rowText)
    colonAt = Pos(":", rowText)
    if not mrAllMode
        if commaAt <= 1 or colonAt <= commaAt
            Message("MULTIREGEX: select a numbered result")
            return()
        endif
        leftPart = SubStr(rowText, 1, commaAt - 1)
        hitLine = Val(leftPart)
        hitCol = Val(SubStr(rowText, commaAt + 1, colonAt - commaAt - 1))
        if hitLine < 1 or hitCol < 1
            Message("MULTIREGEX: select a numbered result")
            return()
        endif
    endif
    mrResultsRow = CurrLine()
    if mrAllMode
        // The display filename is descriptive; the hidden map is authoritative.
        if mrResultsRow < mrFirstResultRow or
           mrResultsRow >= mrFirstResultRow + mrAllHits
            Message("MULTIREGEX: select a numbered result")
            return()
        endif
        if not GotoBufferId(mrAllMap)
            Warn("MULTIREGEX: result mapping is unavailable")
            return()
        endif
        GotoLine(mrResultsRow - mrFirstResultRow + 1)
        rowText = GetText(1, CurrLineLen())
        commaAt = Pos(",", rowText)
        colonAt = Pos(":", rowText)
        if commaAt < 2 or colonAt <= commaAt
            GotoBufferId(mrResults)
            Warn("MULTIREGEX: invalid result mapping")
            return()
        endif
        mrResultsSource = Val(SubStr(rowText, 1, commaAt - 1))
        hitLine = Val(SubStr(rowText, commaAt + 1,
                             colonAt - commaAt - 1))
        hitCol = Val(SubStr(rowText, colonAt + 1, 32))
    endif
    if not GotoBufferId(mrResultsSource)
        Warn("MULTIREGEX: source buffer is no longer available")
        return()
    endif
    GotoLine(hitLine)
    BegLine()
    if hitCol > 1
        Right(hitCol - 1)
    endif
    Disable(MRResultsKeys)
    Enable(MRSourceKeys)
    Message(Format("MULTIREGEX: source match at ", hitLine, ":", hitCol,
                   "  - CtrlAlt G returns to results"))
end

proc MR_MouseOpenResult()
    // MouseMarking moves the cursor to the clicked text row in this buffer.
    // Only the results buffer is affected, not the marked source block.
    if mrViewActive and GetBufferId() == mrResults
        MouseMarking(_INCLUSIVE_)
        MR_OpenResult()
    endif
end

proc MR_ReturnResults()
    if not mrViewActive
        return()
    endif
    if not GotoBufferId(mrResults)
        Warn("MULTIREGEX: results buffer is no longer available")
        return()
    endif
    if mrResultsRow >= 1
        GotoLine(mrResultsRow)
    endif
    Disable(MRSourceKeys)
    Enable(MRResultsKeys)
    Message("MULTIREGEX: left-click/Enter to visit; Escape to close view")
end

proc MR_ExitResults()
    // If a result was opened, switch back before unwinding the nested session.
    // EndProcess() must be called while the results viewer's Process() is active.
    if mrViewActive
        EndProcess()
    endif
end

proc MR_ViewResults(integer resultsId, integer sourceId)
    // Never leave the previous non-view Ctrl+L override stacked underneath.
    if mrSearchKeysActive
        Disable(MRRepeatKeys)
        mrSearchKeysActive = FALSE
    endif
    mrResults = resultsId
    mrResultsSource = sourceId
    mrResultsRow = mrFirstResultRow
    mrViewActive = TRUE
    GotoBufferId(resultsId)
    if NumLines() >= mrFirstResultRow
        GotoLine(mrFirstResultRow)
    else
        BegFile()
    endif
    Enable(MRResultsKeys)
    // A source can be edited normally while the viewer's Process() is open.
    // Escape (including from the source) calls EndProcess().
    Process()
    // Process() has returned: do not abandon buffers before this point.
    Disable(MRResultsKeys)
    Disable(MRSourceKeys)
    mrViewActive = FALSE

    // Only clean up OUR hidden result-to-source mapping.
    if mrAllMap > 0
        if GotoBufferId(mrAllMap)
            AbandonFile()
        endif
    endif
    mrAllMap = 0
    mrAllMode = FALSE
    mrAllHits = 0

    // The results buffer is created by CreateTempBuffer().  It is volatile
    // and must not remain in the ring after the viewer has been closed.
    // Never abandon a user-owned source buffer or an unrelated * buffer.
    if resultsId > 0 and resultsId <> sourceId
        if GotoBufferId(resultsId)
            AbandonFile()
        endif
    endif
    mrResults = 0
    mrAllResults = 0
    mrResultsSource = 0
    mrResultsRow = 0
    // Return control to the file that was active before opening the viewer.
    GotoBufferId(sourceId)
    Message("MULTIREGEX: results viewer closed; temporary buffers released")
end

// Search successive independent chunks with a bounded overlap.
// No flattening operation is applied to the user's source buffer.
integer proc MR_Search(integer mode)
    integer showAll = FALSE
    integer sourceId = 0
    integer workId = 0
    integer resultId = 0
    integer total = 0
    integer localFirst = 1
    integer localLast = 0
    integer blockKind = 0
    integer selectStartCol = 1
    integer selectEndCol = 1
    integer first = 0
    integer last = 0
    integer nextFirst = 0
    integer used = 0
    integer lineLengthI = 0
    integer n = 0
    integer targetLine = 0
    integer targetCol = 0
    integer matchCol = 0
    string matchPreviewS[255] = ""
    integer accepted = FALSE
    integer complete = TRUE
    integer count = 0
    integer scanned = 0
    integer startLine = 0
    integer startColumn = 0
    integer seenFirst = FALSE
    integer linesInChunk = 0
    integer maxChunkLines = 256
    integer chunkLimitI = 0
    integer mapLineI = 0
    integer mappedCharsI = 0
    integer timeStartedI = 0
    integer timeFinishedI = 0
    integer timeElapsedI = 0
    integer scannedLinesI = 0
    integer skippedLinesI = 0
    integer speedI = 0
    integer tickBeginI = 0
    integer regexFoundI = FALSE
    integer knownPhaseTicksI = 0
    string options[255] = ""
    string sourceFileS[255] = ""
    // Exact lengths, no 125-character truncation. Base-180 digits are
    // stored in TWO strings. Each digit is encoded +1 to avoid Chr(0).
    // 255 lengths fit; if a chunk reaches 256 lines, use legacy planning.
    string chunkLenHiS[255] = ""
    string chunkLenLoS[255] = ""
    integer lengthIndexI = 0
    integer cachedLengthI = 0

    // Modes: 0=new, 1=repeat, 2=view current file, 3=append ring file.
    showAll = (mode == 2 or mode == 3)
    sourceId = GetBufferId()
    sourceFileS = CurrFilename()
    total = NumLines()
    // A 256-line cap can make a 4000-character chunk contain only a few
    // hundred characters in files with many short/empty lines.  Since the
    // 2000-character overlap then consumes the entire chunk, the legacy
    // planner may advance just ONE line, recopying almost the same chunk
    // thousands of times.  Permit more physical lines for small ring files,
    // retaining EXACTLY the same byte-window limit and overlap calculation.
    // Large files and non-ring searches keep the verified 256-line cap.
    if mode == 3 and total <= 10000
        maxChunkLines = mrRingMaxChunkLines
    endif
    localLast = total
    if mrLocal
        blockKind = IsBlockInCurrFile()
        if blockKind == 0
            Warn("MULTIREGEX: local search requires a marked block in this file")
            return(FALSE)
        endif
        if blockKind == _COLUMN_
            Warn("MULTIREGEX: COLUMN blocks are not yet supported")
            return(FALSE)
        endif
        if blockKind <> _LINE_ and blockKind <> _INCLUSIVE_ and
           blockKind <> _NONINCLUSIVE_
            Warn("MULTIREGEX: unknown block type")
            return(FALSE)
        endif
        localFirst = Query(BlockBegLine)
        localLast = Query(BlockEndLine)
        if blockKind <> _LINE_
            selectStartCol = Query(BlockBegCol)
            selectEndCol = Query(BlockEndCol)
            if blockKind == _NONINCLUSIVE_
                selectEndCol = selectEndCol - 1
            endif
            if selectStartCol < 1
                selectStartCol = 1
            endif
            if selectEndCol < 0
                selectEndCol = 0
            endif
        endif
        if mode == 1 and (localFirst <> mrBlockFirst or
                          localLast <> mrBlockLast or
                          blockKind <> mrBlockKind or
                          selectStartCol <> mrBlockStartCol or
                          selectEndCol <> mrBlockEndCol)
            Warn("MULTIREGEX: marked block changed; start a new search")
            return(FALSE)
        endif
    endif
    if mode == 3
        startLine = 1
        startColumn = 1
    elseif mode == 1 and mrValid and sourceId == mrSource
        startLine = mrNextLine
        startColumn = mrNextColumn
    elseif Pos("g", mrOptions) > 0
        startLine = localFirst
        startColumn = 1
        if mrLocal and blockKind <> _LINE_
            startColumn = selectStartCol
        endif
    else
        startLine = CurrLine()
        startColumn = CurrCol()
    endif
    if mrLocal and (startLine < localFirst or startLine > localLast or
        (blockKind <> _LINE_ and
         ((startLine == localFirst and startColumn < selectStartCol) or
          (startLine == localLast and startColumn > selectEndCol))))
        Warn("MULTIREGEX: cursor is outside the marked block")
        return(FALSE)
    endif
    // Prevent accidental searching beyond the selected line block.
    total = localLast
    if startLine < 1
        startLine = 1
    endif
    if startLine > total
        Message("MULTIREGEX: end of file")
        return(FALSE)
    endif
    options = mrOptions
    // g, l and v belong to MULTIREGEX and are not sent to LFind().
    options = ""
    if Pos("i", mrOptions) > 0
        options = options + "i"
    endif
    if Pos("x", mrOptions) > 0
        options = options + "x"
    endif
    PushPosition()
    PushBlock()
    if not PROCPushClipboard()
        PopBlock()
        PopPosition()
        Warn("MULTIREGEX: clipboard backup failed")
        return(FALSE)
    endif
    workId = CreateTempBuffer()
    if not workId
        GotoBufferId(sourceId)
        PROCPopClipboard()
        PopBlock()
        PopPosition()
        Warn("MULTIREGEX: temp buffer failed")
        return(FALSE)
    endif
    if mode == 3
        resultId = mrAllResults
    elseif showAll
        resultId = CreateTempBuffer()
        if resultId
            AddLine("Left-click/Enter: visit. CtrlAlt G: return. Escape: close.")
            AddLine("line,column: matched text (preview)")
            AddLine("----------------------------------------------------------")
        endif
    endif
    // In a ring search, MR_SearchRing owns one outer BufferVideo() pair.
    // For a single-file search, suppress costly visible scrolling here.
    if mode <> 3 and not mrShowSourceDuringSearch
        BufferVideo()
    endif
    GotoBufferId(sourceId)
    first = startLine
    mrPlanTicks = 0
    mrBuildTicks = 0
    mrRegexTicks = 0
    mrMapTicks = 0
    mrResultTicks = 0
    mrOtherTicks = 0
    mrChunkCount = 0
    mrAdaptiveCount = 0
    mrRegexCalls = 0
    timeStartedI = GetTime()
    while first <= total and complete
        if mrProfileEnabled
            tickBeginI = GetTime()
        endif
        // Build a chunk, never attempting to flatten the entire file.
        last = first - 1
        used = 0
        linesInChunk = 0
        chunkLenHiS = ""
        chunkLenLoS = ""
        n = first
        chunkLimitI = mrWindow
        // Only an unusually long first line can enlarge this window.
        // A 30000 character safety cap stays below TSE's physical line limit.
        GotoLine(first)
        lineLengthI = CurrLineLen()
        if lineLengthI > mrWindow and lineLengthI <= mrAdaptiveWindow
            chunkLimitI = lineLengthI
            mrAdaptiveCount = mrAdaptiveCount + 1
        endif
        while n <= total and used < chunkLimitI and linesInChunk < maxChunkLines
            if not mrFastScan
                GotoLine(n)
            endif
            lineLengthI = CurrLineLen()
            if lineLengthI > chunkLimitI or used + lineLengthI > chunkLimitI
                break
            endif
            used = used + lineLengthI
            linesInChunk = linesInChunk + 1
            if mrFastPlan and linesInChunk <= 255
                // Exact length, 0..32399 (TSE physical line maximum ~32000).
                // Base-180 encoding avoids zero bytes and length truncation.
                chunkLenHiS = chunkLenHiS + Chr(lineLengthI / 180 + 1)
                chunkLenLoS = chunkLenLoS + Chr(lineLengthI mod 180 + 1)
            endif
            last = n
            n = n + 1
            if mrFastScan and n <= total
                Down()
            endif
        endwhile
        if last < first
            if mrProfileEnabled
                mrPlanTicks = mrPlanTicks + MR_TickDelta(tickBeginI, GetTime())
            endif
            // The line cannot fit in our bounded search buffer.
            // Do not silently loop forever on this input.
            GotoLine(first)
            Message(Format("MULTIREGEX: skipping line over adaptive cap ", first))
            skippedLinesI = skippedLinesI + 1
            scannedLinesI = scannedLinesI + 1
            first = first + 1
        else
            // Advance by roughly half the chunk, retaining overlap.
            nextFirst = last + 1
            if last < total
                scanned = 0
                if mrFastPlan and linesInChunk <= 255
                    // Exact overlap using cached physical line lengths.
                    // This duplicates the legacy scan's ownership boundary.
                    lengthIndexI = linesInChunk
                    while lengthIndexI > 1 and scanned < mrOverlap
                        cachedLengthI = (Asc(SubStr(chunkLenHiS, lengthIndexI, 1)) - 1) * 180 + (Asc(SubStr(chunkLenLoS, lengthIndexI, 1)) - 1)
                        scanned = scanned + cachedLengthI
                        lengthIndexI = lengthIndexI - 1
                    endwhile
                    nextFirst = first + lengthIndexI
                else
                    // Historical v19 planner retained for an A/B benchmark.
                    n = last
                    GotoLine(last)
                    while n > first and scanned < mrOverlap
                        if not mrFastScan
                            GotoLine(n)
                        endif
                        scanned = scanned + CurrLineLen()
                        n = n - 1
                        if mrFastScan and n > first
                            Up()
                        endif
                    endwhile
                    nextFirst = n + 1
                endif
                if nextFirst <= first
                    nextFirst = first + 1
                endif
            endif
            if mrProfileEnabled
                mrPlanTicks = mrPlanTicks + MR_TickDelta(tickBeginI, GetTime())
                tickBeginI = GetTime()
            endif
            mrChunkCount = mrChunkCount + 1
            GotoLine(first)
            MarkLine(first, last)
            Copy()
            GotoBufferId(workId)
            EmptyBuffer()
            BegFile()
            Paste()
            BegFile()
            MR_TrimTemp(workId, first, last)
            BegFile()
            while NumLines() > 1
                EndLine()
                // Do not Right() here: that can pad an extra space at
                // each joining boundary and corrupt match coordinates.
                if not JoinLine()
                    complete = FALSE
                    break
                endif
                BegFile()
            endwhile
            if mrProfileEnabled
                mrBuildTicks = mrBuildTicks + MR_TickDelta(tickBeginI, GetTime())
            endif
            if complete
                BegFile()
                seenFirst = FALSE
                mapLineI = first
                mappedCharsI = 0
                while not seenFirst
                    if mrProfileEnabled
                        tickBeginI = GetTime()
                    endif
                    regexFoundI = LFind(mrPattern, options)
                    mrRegexCalls = mrRegexCalls + 1
                    if mrProfileEnabled
                        mrRegexTicks = mrRegexTicks + MR_TickDelta(tickBeginI, GetTime())
                    endif
                    if not regexFoundI
                        break
                    endif
                    // Capture the real LFind match while its work buffer is
                    // still current (mapping switches to the source buffer).
                    if showAll and resultId
                        matchPreviewS = MR_MatchPreview(GetFoundText())
                    endif
                    matchCol = CurrCol()
                    if mrProfileEnabled
                        tickBeginI = GetTime()
                    endif
                    if not MR_MapOffset(sourceId, first, last,
                                        matchCol, mapLineI, mappedCharsI,
                                        targetLine, targetCol)
                        if mrProfileEnabled
                            mrMapTicks = mrMapTicks + MR_TickDelta(tickBeginI, GetTime())
                        endif
                        complete = FALSE
                        break
                    endif
                    if mrProfileEnabled
                        mrMapTicks = mrMapTicks + MR_TickDelta(tickBeginI, GetTime())
                    endif
                    // Only report matches from the owned, non-overlap
                    // region, except the final chunk which owns its tail.
                    if targetLine >= first and (targetLine < nextFirst or last == total)
                        if targetLine > startLine or
                           (targetLine == startLine and targetCol >= startColumn)
                            count = count + 1
                            if not accepted
                                accepted = TRUE
                                if not showAll
                                    mrNextLine = targetLine
                                    mrNextColumn = targetCol + 1
                                    mrSource = sourceId
                                    mrValid = TRUE
                                endif
                            endif
                            if showAll and resultId
                                if mrProfileEnabled
                                    tickBeginI = GetTime()
                                endif
                                GotoBufferId(sourceId)
                                GotoLine(targetLine)
                                GotoBufferId(resultId)
                                if mode == 3
                                    AddLine(MR_ResultText(Format(sourceFileS, "(", targetLine,
                                                   ",", targetCol, "): "), matchPreviewS))
                                    GotoBufferId(mrAllMap)
                                    AddLine(Format(sourceId, ",", targetLine,
                                                   ":", targetCol))
                                    mrAllHits = mrAllHits + 1
                                else
                                    AddLine(MR_ResultText(Format(targetLine, ",", targetCol,
                                                   ": "), matchPreviewS))
                                endif
                                if mrProfileEnabled
                                    mrResultTicks = mrResultTicks + MR_TickDelta(tickBeginI, GetTime())
                                endif
                            else
                                seenFirst = TRUE
                            endif
                        endif
                    endif
                    GotoBufferId(workId)
                    BegLine()
                    if matchCol >= CurrLineLen()
                        seenFirst = TRUE
                    else
                        Right(matchCol)
                    endif
                endwhile
            endif
            GotoBufferId(sourceId)
            if accepted and not showAll
                break
            endif
            scannedLinesI = scannedLinesI + nextFirst - first
            first = nextFirst
        endif
    endwhile
    timeFinishedI = GetTime()
    timeElapsedI = MR_TickDelta(timeStartedI, timeFinishedI)
    knownPhaseTicksI = mrPlanTicks + mrBuildTicks + mrRegexTicks +
                       mrMapTicks + mrResultTicks
    mrOtherTicks = timeElapsedI - knownPhaseTicksI
    if mrOtherTicks < 0
        mrOtherTicks = 0
    endif
    // Avoid multiply overflow for multi-million-line files and short scans.
    if timeElapsedI > 0
        // Split quotient and remainder to avoid 32-bit multiplication overflow.
        speedI = (scannedLinesI / timeElapsedI) * 100 +
                 ((scannedLinesI mod timeElapsedI) * 100) / timeElapsedI
    endif
    GotoBufferId(sourceId)
    if not PROCPopClipboard()
        Warn("MULTIREGEX: clipboard restore failed")
    endif
    PopBlock()
    PopPosition()
    GotoBufferId(workId)
    AbandonFile()
    GotoBufferId(sourceId)
    // Always balance BufferVideo before returning or entering a viewer.
    if mode <> 3 and not mrShowSourceDuringSearch
        UnBufferVideo()
    endif
    if mode == 3
        // The ring driver owns the shared result buffer and its summary.
        mrAllLines = mrAllLines + scannedLinesI
        mrAllSkipped = mrAllSkipped + skippedLinesI
        return(accepted)
    endif
    if showAll and resultId
        GotoBufferId(resultId)
        AddLine(Format("Matches found: ", count))
        mrFirstResultRow = 13
        if mrProfileEnabled
            mrFirstResultRow = mrFirstResultRow + 10
        endif
        MR_PrependSummary(resultId, scannedLinesI, count,
                          timeElapsedI, skippedLinesI, speedI)
        BegFile()
        MR_ViewResults(resultId, sourceId)
        return(accepted)
    endif
    if accepted
        GotoLine(mrNextLine)
        BegLine()
        if mrNextColumn > 2
            Right(mrNextColumn - 2)
        endif
        Message(Format("MULTIREGEX: match at ", mrNextLine,
                       ":", mrNextColumn - 1,
                       "  elapsed ", MR_ElapsedText(timeElapsedI)))
        return(TRUE)
    endif
    Message(Format("MULTIREGEX: no more matches in scan range; elapsed ",
                   MR_ElapsedText(timeElapsedI)))
    return(FALSE)
end

// Maintain temporary Ctrl+L repeat behavior only within this session.
// Escape ends the session and restores TSE's original key assignments.
proc MR_RepeatForward()
    if mrValid
        MR_Search(1)
    else
        Message("MULTIREGEX: no previous match to repeat")
    endif
end

proc MR_ExitSearchSession()
    // Normal searches do not start a nested Process().  Just remove our
    // temporary keydef and restore the user's normal TSE shortcuts.
    if mrSearchKeysActive
        Disable(MRRepeatKeys)
        mrSearchKeysActive = FALSE
    endif
    Message("MULTIREGEX: repeat mode ended; normal TSE keys restored")
end

proc MR_StartSearchSession()
    // Enable only our Ctrl+L / Escape / emergency-exit bindings; DO NOT
    // invoke Process().  The editor stays in its original process level.
    if mrSearchKeysActive
        Disable(MRRepeatKeys)
        mrSearchKeysActive = FALSE
    endif
    if Enable(MRRepeatKeys)
        mrSearchKeysActive = TRUE
        Message("MULTIREGEX: Ctrl L = repeat; Escape or CtrlAltShift X = exit")
    else
        Warn("MULTIREGEX: could not enable repeat keys")
    endif
end

// Search a stable snapshot of the normal TSE buffers.  Hidden and system
// buffers, including MULTIREGEX's own work/results, are never searched.
proc MR_SearchRing()
    integer startingId = GetBufferId()
    integer currentId = startingId
    integer nextId = 0
    integer ringListId = 0
    integer resultId = 0
    integer mapId = 0
    integer fileIndex = 1
    integer fileId = 0
    integer startTicks = 0
    integer elapsedTicks = 0
    integer speedI = 0
    integer plannedI = 0
    integer plannedTotalI = 0
    integer buildTotalI = 0
    integer regexTotalI = 0
    integer mapTotalI = 0
    integer resultTotalI = 0
    integer chunksTotalI = 0
    integer adaptiveTotalI = 0
    integer callsTotalI = 0

    ringListId = CreateTempBuffer()
    if not ringListId
        Warn("MULTIREGEX: could not create ring snapshot")
        return()
    endif
    GotoBufferId(startingId)
    // NextFile() walks only normal, visible buffers in the editing ring.
    // We collect ids first so later temporary buffers cannot join the scan.
    repeat
        currentId = GetBufferId()
        if BufferType() == _NORMAL_
            GotoBufferId(ringListId)
            AddLine(Str(currentId))
            GotoBufferId(currentId)
        endif
        plannedI = plannedI + 1
        if plannedI > 10000
            Warn("MULTIREGEX: ring enumeration safety limit reached")
            break
        endif
        if not NextFile()
            break
        endif
        nextId = GetBufferId()
    until nextId == startingId
    GotoBufferId(startingId)
    plannedI = 0

    mrAllResults = CreateTempBuffer()
    if not mrAllResults
        GotoBufferId(ringListId)
        AbandonFile()
        GotoBufferId(startingId)
        Warn("MULTIREGEX: could not create results buffer")
        return()
    endif
    resultId = mrAllResults
    AddLine("Left-click/Enter: edit source. CtrlAlt G: return. Escape: close.")
    AddLine("filename(line,column): matched text (preview)")
    AddLine("----------------------------------------------------------")
    mrAllMap = CreateTempBuffer()
    if not mrAllMap
        GotoBufferId(resultId)
        AbandonFile()
        GotoBufferId(ringListId)
        AbandonFile()
        GotoBufferId(startingId)
        Warn("MULTIREGEX: could not create result mapping")
        return()
    endif
    mapId = mrAllMap
    mrAllMode = TRUE
    mrAllHits = 0
    mrAllFiles = 0
    mrAllLines = 0
    mrAllSkipped = 0
    startTicks = GetTime()
    // Keep the displayed results buffer steady, rather than redrawing each
    // large source file on every GotoLine()/GotoBufferId() during the scan.
    // Only one BufferVideo/UnBufferVideo pair is used for the whole ring.
    if not mrShowSourceDuringSearch
        GotoBufferId(resultId)
        UpdateDisplay()
        BufferVideo()
    endif
    GotoBufferId(ringListId)
    plannedTotalI = NumLines()
    for fileIndex = 1 to plannedTotalI
        GotoBufferId(ringListId)
        GotoLine(fileIndex)
        fileId = Val(GetText(1, CurrLineLen()))
        if fileId > 0 and GotoBufferId(fileId)
            mrAllFiles = mrAllFiles + 1
            // Refresh only the message bar.  Do NOT call UpdateDisplay()
            // here: it redraws the newly selected source file despite the
            // outer BufferVideo() and can slow a many-file ring search.
            // TSE's Message() reports progress without a forced screen repaint.
            Message(Format("MULTIREGEX: searching ring file ", mrAllFiles,
                           "/", plannedTotalI, ": ", CurrFilename()))
            MR_Search(3)
            plannedI = plannedI + mrPlanTicks
            buildTotalI = buildTotalI + mrBuildTicks
            regexTotalI = regexTotalI + mrRegexTicks
            mapTotalI = mapTotalI + mrMapTicks
            resultTotalI = resultTotalI + mrResultTicks
            chunksTotalI = chunksTotalI + mrChunkCount
            adaptiveTotalI = adaptiveTotalI + mrAdaptiveCount
            callsTotalI = callsTotalI + mrRegexCalls
        endif
    endfor
    elapsedTicks = MR_TickDelta(startTicks, GetTime())
    mrPlanTicks = plannedI
    mrBuildTicks = buildTotalI
    mrRegexTicks = regexTotalI
    mrMapTicks = mapTotalI
    mrResultTicks = resultTotalI
    mrChunkCount = chunksTotalI
    mrAdaptiveCount = adaptiveTotalI
    mrRegexCalls = callsTotalI
    mrOtherTicks = elapsedTicks - plannedI - buildTotalI - regexTotalI -
                   mapTotalI - resultTotalI
    if mrOtherTicks < 0
        mrOtherTicks = 0
    endif
    if elapsedTicks > 0
        speedI = (mrAllLines / elapsedTicks) * 100 +
                 ((mrAllLines mod elapsedTicks) * 100) / elapsedTicks
    endif
    GotoBufferId(ringListId)
    AbandonFile()
    GotoBufferId(startingId)
    GotoBufferId(resultId)
    AddLine(Format("Matches found: ", mrAllHits))
    mrFirstResultRow = 13
    if mrProfileEnabled
        mrFirstResultRow = mrFirstResultRow + 10
    endif
    // One additional "Files searched" row in the ring-mode header.
    mrFirstResultRow = mrFirstResultRow + 1
    MR_PrependSummary(resultId, mrAllLines, mrAllHits,
                      elapsedTicks, mrAllSkipped, speedI)
    // Display is restored before interactive navigation starts.
    if not mrShowSourceDuringSearch
        UnBufferVideo()
    endif
    BegFile()
    mrResultsRow = mrFirstResultRow
    MR_ViewResults(resultId, startingId)
    GotoBufferId(startingId)
end

proc Main()
    string pattern[255] = ""
    string options[255] = "ix"
    string normalized[255] = ""
    integer oldBlockKind = 0
    integer historyPattern = GetFreeHistory("multiregex:pattern")
    integer historyOptions = GetFreeHistory("multiregex:options")

    // Replace earlier non-view repeat bindings; even cancel paths are clean.
    if mrSearchKeysActive
        Disable(MRRepeatKeys)
        mrSearchKeysActive = FALSE
    endif

    // Keep the running session's search settings in memory. The INI holds
    // defaults and MaximumWindow, but the window never opens another dialog.
    if mrIniPath == ""
        mrIniPath = MR_IniFilename()
        mrPattern = GetProfileStr("MultiRegex", "SearchExpression", mrPattern, mrIniPath)
        mrOptions = GetProfileStr("MultiRegex", "SearchOptions", mrOptions, mrIniPath)
    endif
    mrResultPreviewLength = GetProfileInt("MultiRegex", "ResultPreviewLength", 240, mrIniPath)
    if mrResultPreviewLength < 20 or mrResultPreviewLength > 240
        mrResultPreviewLength = 240
    endif
    mrWindow = GetProfileInt("MultiRegex", "MaximumWindow", 4000, mrIniPath)
    if mrWindow < 100 or mrWindow > 30000
        Warn("MULTIREGEX: invalid MaximumWindow in INI; using 4000")
        mrWindow = 4000
    endif
    mrOverlap = mrWindow / 2
    mrAdaptiveWindow = GetProfileInt("MultiRegex", "AdaptiveWindow", 30000, mrIniPath)
    if mrAdaptiveWindow < mrWindow or mrAdaptiveWindow > 30000
        Warn("MULTIREGEX: invalid AdaptiveWindow; using 30000")
        mrAdaptiveWindow = 30000
    endif
    mrProfileEnabled = GetProfileInt("MultiRegex", "ProfileEnabled", 1, mrIniPath)
    if mrProfileEnabled <> 0
        mrProfileEnabled = TRUE
    endif
    mrRingMaxChunkLines = GetProfileInt("MultiRegex", "RingMaxChunkLines", 4096, mrIniPath)
    if mrRingMaxChunkLines < 256 or mrRingMaxChunkLines > 4096
        mrRingMaxChunkLines = 4096
    endif
    mrFastPlan = GetProfileInt("MultiRegex", "FastPlan", 0, mrIniPath)
    if mrFastPlan <> 0
        mrFastPlan = TRUE
    endif
    mrShowSourceDuringSearch = GetProfileInt("MultiRegex",
        "ShowSourceDuringSearch", 0, mrIniPath)
    if mrShowSourceDuringSearch <> 0
        mrShowSourceDuringSearch = TRUE
    endif
    mrFastScan = GetProfileInt("MultiRegex", "FastScan", 1, mrIniPath)
    if mrFastScan <> 0
        mrFastScan = TRUE
    endif

    pattern = mrPattern
    if not Ask("MULTIREGEX 1.0.0.0.31 - multiline TSE regex:", pattern, historyPattern)
        return()
    endif
    if Length(pattern) == 0
        return()
    endif
    options = mrOptions
    if not Ask("Options (alphabetical: a,g,i,l,v,x; e.g. agivx):",
               options, historyOptions)
        return()
    endif
    normalized = MR_NormalizeOptions(options)
    if normalized == ""
        Warn("MULTIREGEX: invalid or repeated search options")
        return()
    endif
    options = normalized
    if Pos("a", options) > 0
        if Pos("l", options) > 0
            Warn("MULTIREGEX: a (ring) and l (block) cannot be combined")
            return()
        endif
        if Pos("g", options) == 0 or Pos("v", options) == 0
            Warn("MULTIREGEX: ring-wide mode currently requires agivx")
            return()
        endif
    endif
    if Pos("l", options) > 0
        oldBlockKind = IsBlockInCurrFile()
        if oldBlockKind == 0
            Warn("MULTIREGEX: mark a block first for option l")
            return()
        endif
        if oldBlockKind == _COLUMN_
            Warn("MULTIREGEX: COLUMN blocks are not yet supported")
            return()
        endif
        if oldBlockKind <> _INCLUSIVE_ and
           oldBlockKind <> _NONINCLUSIVE_ and oldBlockKind <> _LINE_
            Warn("MULTIREGEX: unknown marked block type")
            return()
        endif
    endif

    mrPattern = pattern
    mrOptions = options
    mrLocal = (Pos("l", options) > 0)
    if mrLocal
        mrBlockFirst = Query(BlockBegLine)
        mrBlockLast = Query(BlockEndLine)
        mrBlockKind = oldBlockKind
        mrBlockStartCol = 1
        mrBlockEndCol = 1
        if oldBlockKind <> _LINE_
            mrBlockStartCol = Query(BlockBegCol)
            mrBlockEndCol = Query(BlockEndCol)
            if oldBlockKind == _NONINCLUSIVE_
                mrBlockEndCol = mrBlockEndCol - 1
            endif
        endif
    endif
    mrValid = FALSE

    WriteProfileStr("MultiRegex", "SearchExpression", mrPattern, mrIniPath)
    WriteProfileStr("MultiRegex", "SearchOptions", mrOptions, mrIniPath)
    FlushProfile(mrIniPath)

    if Pos("a", options) > 0
        MR_SearchRing()
    elseif Pos("v", options) > 0
        MR_Search(2)
    else
        if MR_Search(0)
            MR_StartSearchSession()
        endif
    endif
end
