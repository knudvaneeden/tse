/*-----------------------------------------------------------------
   mSelectAndSwap - Truls Thirud, March 12, 1994

   Macro for swapping lines from a "compressed view" with lines in any
   open buffer.

   I sometimes would like to select some lines from a file, edit them in
   a buffer and then put them back into the file. This last operation is
   accomplished by the macro mSelectAndSwap(). It assumes

   - at least one line in the current buffer has a valid line number
     (otherwise you will get an error message)
   - a valid line number is defined by: one or more blanks followed by
     one or more digits followed by a colon and a blank. But this is
     configurable, and this definition conforms with the CompressView
     macro of TSE.
   - When run the macro swaps the lines in the current buffer with the
     corresponding lines in the file. By doing the process twice,
     you undo your changes.

   This macro is in the public domain.


   Version history

   1.0  March 12. 1994  initial version
 -----------------------------------------------------------------*/

CONSTANT
  cMarkRangeErrors = 1 ,    // 1 means mark lines out of range with "?"
  cReportCount     = 1      // 1 means report number of changes when done

STRING
  sLineNumberRegEx[] = " *[0-9]+: "   // format for line number field

proc mLineSwap(integer EditBufID)
// Swaps the lines in the current buffer with the corresponding lines
// in EditBufID
// Each line in the current buffer is prefixed by the line number
// of the line it corresponds to in EditBufID
// Returns with contents of current buffer swapped with contents of
// affected lines in the EditBufID buffer, and with EditBufID
// as current buffer

  integer clipID = Query(ClipBoardID) // Original clipboard id
  integer buffID  = GetBufferID()
  integer tmpid = CreateTempBuffer() // Temporary clipboard id
  integer width, line_no
  integer OldKillMAX                // Original value for KillMax
  integer MaxLines                  // Number of lines in master file
  integer RangeErrors = 0           // Number of line numbers out of range
  integer Changes = 0               // Number of changes made

  Set(ClipBoardID,tmpid)             // switch to temporary clipboard

  GotoBufferID(EditBufID)
  width = Length(Str(NumLines()))   // for new contents of buffid
  MaxLines = NumLines()

  GotoBufferID(buffid)
  OldKillMax = Set(KillMax,1)       // Don't interfere with Kill-buffer

  BegFIle()                         // Kludge to make lrepeatfind work:
  InsertLine()                      // lRepeatFind starts at next char...
  lFind(sLineNumberRegEx,"^xg")     // Find first line with line number

  repeat
    MarkFoundText()
    line_no = Val(GetMarkedText())
    Message(line_no)
    if line_no > 0 and line_no <= MaxLines
      Set(KillMax,0)
      DelBlock()                    // Remove line number
      Set(KillMax,1)
      Changes = Changes +1

      DelLine()                     // Store in delete buffer
      GotoBufferID(EditBufID)
      GotoLine(line_no)
      GotoPos(1)
      InsertText(Format(line_no:width, ": "),_INSERT_)
      MarkLine()
      Cut(_APPEND_)
      GlobalUnDelete()              // Get from delete buffer
      GotoBufferID(buffid)
    else
      RangeErrors = RangeErrors + 1
      if cMarkRangeErrors
        GotoPos(1)
        InsertText("?")             // Add "?" for funny line number
      endif
      MarkLine()
      Cut(_APPEND_)
    endif
    Up()                            // Cursor probably on new line number
  until not lRepeatFind()

  EmptyBuffer()
  Paste()                           // restore with changed contents
  UnmarkBlock()
  GotoBufferID(EditBufID)

  // Tidy up

  AbandonFile(tmpID)
  Set(ClipboardID,clipID)
  Set(KillMax,OldKillMax)
  if RangeErrors
    Warn(Format(Changes," line(s) changed. ",RangeErrors," range error(s)."))
  elseif cReportCount
    Message(Format(Changes," line(s) changed."))
  else
    UpdateDisplay(_STATUSLINE_REFRESH_) // clear statusline
  endif
end

integer proc mSelectBufID()   // Stolen and modified from tse.s
// Present a list of buffers to select, excepting the current buffer.
// Return buffer id or zero if error or no selection made

    integer start_file, filelist, maxl, total, n
    string fn[65]
    integer chosenbuffid

    n = NumFiles() + (BufferType() <> _NORMAL_) - 1
    if n <= 0
        return (0)
    endif
    maxl = 0
    total = 0
    start_file = GetBufferid()      // Save current
    filelist = CreateTempBuffer()
    if filelist == 0
        warn("Can't create filelist")
        return (0)
    endif
    GotoBufferId(start_file)
    NextFile(_DONT_LOAD_)           // Don't swap file with itself!!
    while n
        fn = CurrFilename()
        if length(fn)
            if length(fn) > maxl
                maxl = length(fn)
            endif
            AddLine(iif(FileChanged(), '*', ' ') + fn, filelist)
        endif
        NextFile(_DONT_LOAD_)
        n = n - 1
    endwhile
    GotoBufferId(filelist)
    BegFile()

    maxl = maxl + 4
    if maxl > Query(ScreenCols)
        maxl = Query(ScreenCols)
    endif
    if List("Swap with", maxl)
        chosenbuffid = GetBufferID(GetText(2, sizeof(fn)))
    else
        chosenbuffid = 0
    endif
    AbandonFile(filelist)
    GotoBufferID(start_file)
    return(chosenbuffid)
end

proc mSelectAndSwap()
/*
 * Presents a picklist of open buffers and if any is selected
 * swaps (changed) lines in current buffer with corresponding
 * lines in selected buffer
 */

integer EditBufID

  if not lFind(sLineNumberRegEx,"^gx")
    Warn("Invalid line format: Line numbers missing")
    return()
  endif

  // Make user select buffer for swapping lines with

  EditBufID = mSelectBufId()
  if EditBufID
    mLineSwap(EditBufID)
  endif
end

proc main()
  mSelectAndSwap()
end
