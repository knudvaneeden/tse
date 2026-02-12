//
//  03/07/94 12:22 pm H. Johnson
//  Add COMPILE and MAKE configuration to system...
//
//  The following are added to the RECONFIGURE menu:
//
//      "&COMPILE Setup Strings  ",  COMPILESetupMenu(),   DontClose
//      "&MAKE Setup Strings  "   ,  MAKESetupMenu()   ,   DontClose
//
//   This is changed on the MACRO menu:
//
//      "&Compile"                      ,   mCompileCurrentFile(TRUE)
//
/*****************************************************************************

            The SemWare Editor V1.0 - Default User Interface

Copyright 1991-1993 SemWare Corporation.  All Rights Reserved Worldwide.

-----------------------------------------------------------------------------

 This program gives The SemWare Editor its default user interface, including
 user preferences, certain built-in commands, menus, help, and
 key-assignments.

 This file (tse.s) is the main program file.  It also includes the following
 files:

 tse.hlp     - help for keys not on the menus or the help-bar
 tse.key     - key assignments

 Additionally, if you want to use a config file rather than ICONFIG for user
 preferences, include the following file:

 tse.cfg     - user preferences file
  *****************************************************************************/

#include ["tse_x.cfg"]      // config-endconfig definitions
#include ["tse_x.hlp"]      // help text
#include ["compiler.s"]      // various compiler program subroutines..
/*****************************************************************
  Some definitions / notes

  Macros used as commands (that are assigned to keys or menus sequences)
  are prefixed with lower case "m" to distinguish them from built-in
  commands, e.g., mDelChar() is a macro in this file, DelChar() is a
  builtin command.

  Current character - The character at the cursor position in the
  currently edited file.  Where the next typed character will be
  inserted or replaced.

 *****************************************************************/

/*----------------------------------------------------------------
  A simple language indenting package, providing the following:

  When AutoIndent is on,

  BackSpace, when the cursor is on a blank line or the first
  non-blank character of a line, issues  TabLeft(), in
  effect doing an outdent.

  Return, causes an extra indent when the first word of the line
  is one of the following:

  if else elseif while repeat loop for switch case when

  Additionally, special handling of {} is provided for C
  programmers.

  To make this package work:

  Assign mBackSpace() to <backspace>
  Assign mCReturn() to <Enter>          // special handling for C
  Assign  TabLeft() to <shift tab>
  Assign CloseBrace() to <shift ]>      // For C files

  The _ON_CHANGING_FILES_ hook sets this mode (language) for files with
  extensions of s, c, and h.
  cmode is also set for files with extensions of c and h.

  ----------------------------------------------------------------*/

// Global variables - assumes globals initialized to 0.

integer
    cmode,              // used to invoke C-mode
    language,           // used to invoke language package
    sort_flags,
    pick_buffer         // id of the pick-buffer

string KeyWords[] = " if else elseif while repeat loop for switch case when otherwise proc "
/*************************************************************************
  Helper macros/Subroutines

  These routines are:

   not intended for use as commands by themselves
   not intended to be assigned to keys or menus
   intended to be called from other macros

 *************************************************************************/

string proc CurrExt()
    return (SplitPath(CurrFilename(), _EXT_))
end

integer proc ListIt(string title, integer width)
    width = width + 4
    if width > Query(ScreenCols)
        width = Query(ScreenCols)
    endif
    return (List(title, width))
end

/*************************************************************************
  Return the word at the cursor as a string.
 *************************************************************************/
string proc GetWordAtCursor()
    string word[80] = ''

    PushBlock()                     // Save current block status
    if MarkWord()                   // Mark the word
        word = GetMarkedText()      // Get it
    endif
    PopBlock()                      // Restore block status
    return (word)                   // Thats all, folks!
end GetWordAtCursor

/*************************************************************************
   Return the first word on the line as string - '' if not there.
 *************************************************************************/
string proc GetFirstWord()
    string word[32] = ''

    PushPosition()                  // Save where we're at
    GotoPos(PosFirstNonWhite())     // Go to first non white
    word = GetWordAtCursor()        // Now get the word there
    PopPosition()                   // Restore saved position
    Lower(word)                     // Make it lower case
    return (' ' + word + ' ')       // And return the word
end

string proc GetTextUntil(string stopchar)
    integer start = CurrPos()

    while CurrChar() <> Asc(stopchar) and CurrChar() >= 0 and Right()
    endwhile

    return (GetText(start, CurrPos() - start))
end

/*************************************************************************
 *************************************************************************/
menu ExecLoadPurge()
    Title = "Macro function"
    Width = 16

    "&Execute..."
    "&Load..."
    "&Purge..."
end

/*************************************************************************
 *************************************************************************/
menu LoadExec()
    "&Load macro"
    "&Execute macro"
end

/*************************************************************************
 *************************************************************************/
string proc OnOffStr(integer i)
    return (iif(i, "On", "Off"))
end

/*************************************************************************
 *************************************************************************/
string proc ShowSortFlag()
    return (iif(sort_flags & 1, "Descending", "Ascending"))
end

proc ToggleSortFlag(integer which)
    if sort_flags & which
        sort_flags = sort_flags & ~ which
    else
        sort_flags = sort_flags | which
    endif
end

/*************************************************************************
 *************************************************************************/
integer proc ReadNum(integer n)
    string s[5] = str(n)

    return (iif(Read(s), val(s), n))
end ReadNum

///////////////////// End Help Macros/Subroutines ///////////////////////

/*************************************************************************
  Macros that follow can:

   be assigned to keys and menus as commands
   therefore, can be directly executed by the user

  Commands implemented in the macro langauge:

     mCopyCharAbove
     mMatch
     mListOpenFiles
     mCenterLine
     mScratchBuffer
     mShift [ShiftBlock]
     mIncrementalSearch
     mFindWordAtCursor
     mclosebrace
     mCompressView
     mAsciiChart
     mListRecentFiles
     mMacMenu
     mSwapLines
     mCount
     mSendFormFeed
     GetPrintDevice
     GetHeader
     GetFooter
     GetInitString
     SendInit
     mDateTimeStamp

  Commands augmented via macros:

     mBackSpace()
     mDelChar()
     mCReturn()
     mUpper()
     mLower()
     mFlip()
     mWrapPara
 *************************************************************************/

/*********************************************************************
  The GetPrev() command.
 *********************************************************************/
integer proc mCopyCharAbove()
    integer c, sv = Set(RemoveTrailingWhite, OFF)

    PushPosition()                  // save position
    c = iif(up(), CurrChar(), -1)   // Try for char on line above
    PopPosition()                   // back to where we were
    Set(RemoveTrailingWhite, sv)
    return (c >= 0 and InsertText(Chr(c)))
end mCopyCharAbove

proc mCopyCharAboveToEol()
    repeat
    until not mCopyCharAbove()
end

/*************************************************************************
  The match command.  Use this macro to match (){}{}<> chars.
 *************************************************************************/
string match_chars[] = "(){}[]<>"   // pairs of chars to match
integer proc mMatch()
    integer p, level
    integer mc, ch

    p = Pos(chr(CurrChar()), match_chars)
    // If we're not already on a match char, go forward to find one
    if p == 0 and lFind("[(){}[\]<>]", "x")
        return (FALSE)
    endif

    PushPosition()
    if p
        ch = asc(match_chars[p])             // Get the character we're matching
        mc = asc(match_chars[iif(p & 1, p + 1, p - 1)])  // And its reverse
        level = 1                       // Start out at level 1

        while lFind("[\" + chr(ch) + "\" + chr(mc) + "]", iif(p & 1, "x+", "xb"))
            case CurrChar()             // And check out the current character
                when ch
                    level = level + 1
                when mc
                    level = level - 1
                    if level == 0
                        KillPosition()          // Found a match, remove position
                        p = CurrPos()           // Fix up possible horizontal
                        BegLine()               // scrolling by saving position,
                        GotoPos(p)              // starting at beginning, and restoring
                        return (TRUE)           // And return success
                    endif
            endcase
        endwhile
    endif
    PopPosition()                       // Restore position
    return (warn("Match not found"))    // Warn() returns False
end mMatch

/*****************************************************************************
  List Files placed in the editor's internal ring of files.

  Notes:
    System buffers are _not_ intended for interactive editing.  Therefore,
    this command will exit if it is determined that the current buffer is a
    system buffer.
 *****************************************************************************/
proc mListOpenFiles()
    integer start_file, filelist, id, rc, maxl, total, n
    string fn[65]

    n = NumFiles() + (Query(BufferType) <> _NORMAL_)
    if n == 0
        return ()
    endif
    maxl = 0
    total = 0
    start_file = GetBufferid()                 // Save current
    filelist = CreateTempBuffer()
    if filelist == 0
        warn("Can't create filelist")
        return ()
    endif
    GotoBufferId(start_file)
    id = GetBufferid()
    while n
        fn = CurrFilename()
        if length(fn)
            if length(fn) > maxl
                maxl = length(fn)
            endif
            rc = isChanged()
            GotoBufferId(filelist)
            AddLine(iif(rc, '*', ' ') + fn)
            GotoBufferId(id)
        endif
        NextFile(_DONT_LOAD_)
        id = GetBufferid()
        n = n - 1
    endwhile
    GotoBufferId(filelist)
    BegFile()
    if ListIt("Buffer List", maxl)
        EditFile(GetText(2, sizeof(fn)))    // Force loading from disk
    else
        GotoBufferId(start_file)
    endif
    AbandonFile(filelist)
end mListOpenFiles

/************************************************************************
  Routine to center a line.
  If a block is marked, all the lines in the block are centered, using
    the left and right margins;
  if the block is a column block, only the text in the column block is
    centered, without disturbing surrounding text.
 ************************************************************************/
proc mCenterLine()
    integer right_margin = Query(RightMargin),
        left_margin = Query(LeftMargin),
        first_line, last_line, type, p, center, cid, tid

    PushPosition()
    if left_margin == 0 or left_margin >= right_margin
        left_margin = 1
    endif
    first_line = CurrLine()
    last_line = first_line
    type = isCursorInBlock()
    if type
        Set(Marking, off)
        first_line = Query(BlockBegLine)
        last_line = Query(BlockEndLine)
        if type == _COLUMN_
            GotoBlockBegin()
            cid = GetBufferId()
            tid = CreateTempBuffer()
            CopyBlock()

            /*
              Need to make sure we overlay everything with spaces
             */
            PushBlock()
            GotoBufferId(cid)
            CopyBlock(_OVERWRITE_)
            FillBlock(' ')
            GotoBufferid(tid)
            PopBlock()

            last_line = last_line - first_line + 1
            first_line = 1
            left_margin = 1
            right_margin = Query(BlockEndCol) - Query(BlockBegCol) + 1
        endif
    endif
    if right_margin > left_margin
        GotoLine(first_line)
        repeat
            p = PosFirstNonWhite()
            center = ((p + PosLastNonWhite()) / 2) - ((left_margin + right_margin) / 2)
            ShiftText(iif(center > 0,
                - (iif(center < p, center, p - 1)), Abs(center)))
        until (not RollDown()) or CurrLine() > last_line
        if type == _COLUMN_
            GotoBufferId(cid)
            CopyBlock(_OVERWRITE_)
            AbandonFile(tid)
        endif
    endif
    PopPosition()
end mCenterLine

// TSE Jr. 2.15 style scratch buffer package

constant
    GETOVERLAY =    0,
    GETTING =       1,  // code depends on this order

    STORING =       2,
    APPENDING =     3,
    CUTTING =       4,
    CUTAPPEND =     5

integer proc mScratchBuffer(integer operation)
    integer cid, id, result, SaveClipBoardId
    string BufferName[40], msg[30]

    if operation > GETTING and (NOT isBlockInCurrFile())
        return (FALSE)
    endif
    BufferName = ""
    result = TRUE                               // assume success
    SaveClipBoardId = GetClipBoardId()          // save id
    case operation
        when STORING    msg = "Copy to ClipBoard:"
        when APPENDING  msg = "Copy Append to ClipBoard:"
        when GETTING    msg = "Paste from ClipBoard:"
        when GETOVERLAY msg = "Paste Over from ClipBoard:"
        when CUTTING    msg = "Cut to ClipBoard:"
        when CUTAPPEND  msg = "Cut Append to ClipBoard:"
    endcase
    if ask(msg, BufferName) and Length(BufferName)   // get scratch name
        BufferName = "+++" + BufferName         // Fudge for scratch
        id = GetBufferId(BufferName)             // See if already there
        if operation <> GETTING and id == 0
            cid = GetBufferId()
            id = CreateBuffer(BufferName, _SYSTEM_)    // create a buffer
            GotoBufferId(cid)
        endif
        if id <> 0                              // if it worked
            SetClipBoardId(id)                  // new ClipBoard
            case operation
                when STORING	result = Copy()
                when APPENDING	result = Copy(_APPEND_)
                when GETTING	result = Paste()
                when GETOVERLAY result = Paste(_OVERWRITE_)
                when CUTTING    result = Cut()
                when CUTAPPEND  result = Cut(_APPEND_)
            endcase
            SetClipBoardId(SaveClipBoardId)     // restore ClipBoard
        else
            warn("Could not create/find buffer")
        endif
    endif
    return (result)                               // return result
end

constant SHIFTLEFT = -1, SHIFTRIGHT = 1

integer proc mShiftBlock(integer direction)
    integer goal_line = CurrLine(),
            btype     = isCursorInBlock(),
            save_marking   = Query(Marking)

    PushPosition()
    if btype
        goal_line = Query(BlockEndLine)
        GotoBlockBegin()
    endif
    repeat until not ShiftText(direction)
            or   not RollDown()
            or   CurrLine() > goal_line
    PopPosition()
    Set(Marking, save_marking)
    return (TRUE)
end

proc mShift()
    integer k = Set(EquateEnhancedKbd, ON)

    loop
        Message("<Left>,<Right> or <Tab>,<Shift Tab> to shift text; <Enter> when done")
        case GetKey()
            when <CursorLeft>
                mShiftBlock(-1)
            when <CursorRight>
                mShiftBlock(1)
            when <Tab>
                mShiftBlock(Query(TabWidth))
            when <Shift Tab>
                mShiftBlock(-Query(TabWidth))
            when <Escape>, <Enter>
                break
            when <Alt U>
                if isCursorInBlock()
                    UnMarkBlock()
                    break
                endif
        endcase
        UpdateDisplay(_REFRESH_THIS_ONLY_ | _WINDOW_REFRESH_)
    endloop
    Set(EquateEnhancedKbd, k)
    UpdateDisplay()
end

/***************************************************************************
  An Incremental search.  I rarely use regular search, since implementing
  this...
 ***************************************************************************/
proc mIncrementalSearch()
    string s[40]="", option[8] = "i"
    integer ch, global_or_reverse, next

    global_or_reverse = FALSE

    PushPosition()
    loop
        if Length(s) and global_or_reverse
            option = substr(option, 1, length(option) - 1)
            global_or_reverse = FALSE
        endif
        next = FALSE
        message("I-Search (^N=Next ^P=Prev ^B=Beginning):", s)

        retry:
        ch = getkey()
        case ch
            when <BackSpace>                // go back to start
                PopPosition()
                PushPosition()
                s = iif(length(s) <= 1, "", substr(s, 1, length(s) - 1))
            when <Ctrl L>, <Ctrl N>         // just search again
                NextChar()
                next = TRUE
            when <Ctrl R>, <Ctrl P>         // go to previous occurrence
                option = option + 'b'
                global_or_reverse = TRUE
            when <Ctrl G>, <Ctrl B>         // beginning of file
                option = option + 'g'
                global_or_reverse = TRUE
            when <Enter>, <Escape>
                if Length(s)
                    AddHistoryStr(s, _FINDHISTORY_)
                endif
                break
            otherwise
                if (ch & 0xff) == 0         // Function key?
                    goto retry              // Yes, try again.
                endif
                s = s + chr(ch & 0xff)      // mask off the scan code
        endcase
        if Length(s) and NOT find(s, option) and NOT global_or_reverse and NOT next
            s = substr(s, 1, length(s) - 1)
        endif
    endloop
    KillPosition()
    UpdateDisplay()
end

integer proc mFindWordAtCursor(string option)
    if Length(GetWordAtCursor())
        AddHistoryStr(GetWordAtCursor(), _FINDHISTORY_)
        return (Find(GetWordAtCursor(), Query(FindOptions) + option))
    endif
    return (Find())
end mFindWordAtCursor

// Special handling of } for C programmers
integer proc mCloseBrace()
    if cmode and PosFirstNonWhite() == 0
        TabLeft()
    endif
    return (InsertText("}"))
end

string lineone[] = "      þþþ Select this line to edit COMPRESS file þþþ"
integer compress_hist, compress_options_history
string compress_buffer_name[] = "[<compress>]"

proc mCompressView(integer compress_type)
    string expr[65] = '', opts[12] = '',
           line[132]
    integer
        line_no,        // saved CurrLine() for compressed view
        list_no,        // line we exited on
        start_line_no,   // line number we were on
        goto_line_no,
        width,
        mk,
        compress_id,
        current_id = GetBufferId(), maxlen = Length(lineone)

    if compress_hist == 0   // This must be first time through - do initialization.
        compress_hist = GetFreeHistory()
        compress_options_history = GetFreeHistory()
        AddHistoryStr(Query(FindOptions), compress_options_history)
    endif

    start_line_no = CurrLine()
    if NumLines() == 0
        return ()
    endif

    line_no = 0
    list_no = 0
    goto_line_no = 1
    width = Length(Str(NumLines()))

    // compress_types are [0..1]
    if compress_type == 0
        if not ask("String to list all occurrences of:", expr, compress_hist)
            return ()
        endif
        if Length(expr) == 0
            opts = "x"
            expr = "^[a-zA-Z_]"
        elseif not ask("Search options [IWX] (Ignore-case Words reg-eXp):", opts, compress_options_history)
            return ()
        endif
    else
        opts = "ix"
        case CurrExt()
            when ".c",".cpp"
                expr = "^[a-zA-Z_].*\(.*[~;]$"
            when ".s"
                expr = "^{public #}?{{integer #}|{string #}}@proc +[a-zA-Z_]"
            when ".pas"
                expr = "{procedure}|{function} +[a-zA-Z_]"
            when ".prg",".spr",".mpr",".qpr",".fmt",".frg",".lbg",".ch"
                expr = "^{procedure}|{function} +[a-zA-Z_]"
            otherwise
                warn("Extension not supported")
                return ()
        endcase
    endif

    compress_id = CreateBuffer(compress_buffer_name)
    if compress_id == 0
        compress_id = GetBufferId(compress_buffer_name)
    endif
    if compress_id == current_id
        warn("Can't use this buffer")
        return ()
    endif
    if compress_id == 0 or not GotoBufferId(compress_id)
        return ()
    endif

    // At this point, we are in the compress buffer
    EmptyBuffer()
    InsertText(lineone)
    GotoBufferId(current_id)
    PushPosition()
    BegFile()
    if lFind(expr, opts)
        repeat
            line = GetText(1, sizeof(line))
            line_no = CurrLine()
            if Length(line) > maxlen
                maxlen = Length(line)
            endif
            GotoBufferId(compress_id)
            if not AddLine(Format(line_no:width, ': ', line))
                break
            endif
            if goto_line_no == 1 and line_no > start_line_no
                goto_line_no = CurrLine() - 1
            endif
            GotoBufferId(current_id)
            EndLine()
        until not lRepeatFind()
    endif
    GotoBufferId(compress_id)
    GotoLine(goto_line_no)
    if ListIt(iif(compress_type == 0, expr, "Function List"), maxlen + width)
        if CurrLine() == 1
            PopPosition()
            GotoBufferId(compress_id)
            mk = Set(KillMax, 0)
            DelLine()
            Set(KillMax, mk)
            ForceChanged(FALSE)
            return ()
        endif
        list_no = val(GetText(1, width))
    endif
    AbandonFile()
    PopPosition()
    if list_no
        GotoLine(list_no)
        ScrollToRow(Query(WindowRows)/2)
    endif
end mCompressView

integer chartid
proc mAsciiChart()
    integer
        i,
        ok,
        c = CurrChar(),
        et = Set(ExpandTabs, off)

    PushPosition()
    if chartid == 0
        chartid = CreateTempBuffer()
        i = 0
        while AddLine(format(i:4, str(i, 16):4, chr(i):4)) and i <> 255
            i = i + 1
        endwhile
    endif
    GotoBufferId(chartid)
    BegFile()
    if c > 0
        GotoLine(c + 1)
    endif
    ok = ListIt("DEC HEX Char", 12)
    i = CurrLine() - 1
    PopPosition()
    if ok
        InsertText(chr(i))
    endif
    Set(ExpandTabs, et)
end mAsciiChart

proc mListRecentFiles()
    integer maxl = 0, cid = GetBufferId()

    if GotoBufferId(pick_buffer)
        BegFile()
        repeat
            if CurrLineLen() > maxl
                maxl = CurrLineLen()
            endif
        until not down()
        GotoLine(2)
        if ListIt("Recent Files", maxl)
            EditFile(GetText(1, CurrLineLen()))
        else
            GotoBufferId(cid)
        endif
    endif
end mListRecentFiles


///************************************************************************
//  This version assumes the compiler program is either in the current
//  directory or available via the path.
// ************************************************************************/
//proc mCompile()
//    string fn[65] = CurrFilename(),
//        err_fn[12] = "$errors$.tmp"
//    integer line, col
//
//    if CurrExt() <> ".s"
//        Warn("Extension not supported")
//        return ()
//    endif
//    OneWindow()         // Force a single window
//    if isChanged()
//        SaveFile()
//    endif
//    // Remove the error file if we're already editing it
//    AbandonFile(GetBufferId(ExpandPath(err_fn)))
//    PurgeMacro(fn)
//    EraseDiskFile(err_fn)
//    Dos("sc " + fn + ">" + err_fn, _DONT_CLEAR_)
//    EditFile(err_fn)
//    EraseDiskFile(err_fn)
//    //
//    // 3 cases -
//    //      1 - SC didn't run, probably not found. Identify by empty err_fn
//    //      2 - Error/Warning msg found in err_fn - position to error
//    //      3 - No Errors/Warnings!  Load/Exec the new macro.
//    //
//    if lFind("^{Error}|{Warning} #[0-9]# #\c","ix")
//        PrevFile()
//        HWindow()
//        if CurrChar() == Asc('(')
//            Right()
//            line = Val(GetTextUntil(','))
//            Right()                             // skip the comma
//            col  = Val(GetTextUntil(')'))
//            PrevWindow()
//            GotoLine(line)
//            ScrollToRow(Query(WindowRows) / 2)
//            GotoColumn(col)
//        endif
//        UpdateDisplay()
//    else
//        // At this point, no error/warning messages found, in the error file
//        AbandonFile()
//        if NumLines() == 0                      // If empty, we failed
//            Warn("Error running SC.EXE")
//        else
//            UpdateDisplay()                     // Force a statusline refresh
//            fn = SplitPath(fn, _DRIVE_ | _NAME_)
//            case LoadExec("Compile successful")
//                when 1
//                    LoadMacro(fn)
//                when 2
//                    ExecMacro(fn)
//            endcase
//        endif
//    endif
//end

integer proc mMacMenu(integer n)
    string s[8] = ''

    if n == 0
        n = ExecLoadPurge()
    endif
    case n
        when 1
            return (ExecMacro())
        when 2
            return (LoadMacro())
        when 3
            if ask("Purge macro:", s) and Length(s) and PurgeMacro(s)
                Message(s, " purged.")
                return (TRUE)
            endif
    endcase
    return (FALSE)
end

proc mSwapLines()
    integer km

    if Down()
        km = Set(KillMax, 1)
        DelLine()
        Up()
        UnDelete()
        Set(KillMax, km)
    endif
end

proc mCount()
    integer count = 0
    string s[60] = '', opts[12] = Query(FindOptions)

    if Ask("String to count occurrences of:", s) and Length(s) and
        Ask("Options [GLIWX] (Global Local Ignore-case Words reg-eXp):", opts)
        PushPosition()
        if lFind(s, opts)
            repeat
                count = count + 1
            until not lRepeatFind()
        endif
        PopPosition()
        Message("Found ", count, " occurrence(s)")
    endif
end

proc mSendFormFeed()
    if not PrintChar(chr(12))
        warn("Error sending formfeed")
    endif
end

proc GetPrintDevice()
    string s[48] = Query(PrintDevice)

    if ask("Print Device:", s)
        Set(PrintDevice, s)
    endif
end

proc GetHeader()
    string s[4] = Query(PrintHeader)

    if ask("Print Header [FDTP] (Filename Date Time Page):", s)
        Set(PrintHeader, s)
    endif
end

proc GetFooter()
    string s[4] = Query(PrintFooter)

    if ask("Print Footer [FDTP] (Filename Date Time Page):", s)
        Set(PrintFooter, s)
    endif
end

proc GetInitString()
    string s[60] = Query(PrintInit)

    if ask("Init String:", s)
        Set(PrintInit, s)
    endif
end

proc mSendInitString()
    string s[60] = Query(PrintInit)
    integer i = 1

    while i <= Length(s) and PrintChar(s[i])
        i = i + 1
    endwhile
end

proc mDateTimeStamp()
    InsertText(GetDateStr(), _INSERT_)
    InsertText(" ", _INSERT_)
    InsertText(GetTimeStr(), _INSERT_)
end

/*************************************************************************
  Commands augmented by macros:
 *************************************************************************/

/*********************************************************************
  Fancy backspace() command.
  Sort of like Borlands environment.  In language mode, backspace
  does a "outdent" when there is only white space before the cursor.

  Also does special handling for overwrite mode.  In overwrite mode,
  does a "rubout" instead of a backspace.
 *********************************************************************/
proc mBackSpace()
    if CurrPos() == 1       // at beg-of-line, just join to previous
        if PrevChar()
            JoinLine()
        endif
        return ()
    endif

    // if from here to prev-tabstop is 'white', then TabLeft()

    if Query(AutoIndent) and language
        if CurrPos() <= PosFirstNonWhite()
            TabLeft()
            return ()
        endif
        PushPosition()
        GotoColumn(CurrCol() - DistanceToTab())
        if CurrPos() > PosLastNonWhite()
            PopPosition()
            TabLeft()
            return ()
        endif
        PopPosition()
    endif

    // Finally, do either rubout or backspace based on InsertMode

    Left()
    if CurrChar() >= 0
        if Query(Insert)
            DelChar()
        else
            InsertText(" ", _OVERWRITE_)
            Left()
        endif
    endif
end

// Augment delchar by joining lines if at or passed eol
integer proc mDelChar()
    return(iif(CurrChar() >= 0, DelChar(), JoinLine()))
end

// Fancy CarriageReturn command.  Works if language mode is on.
integer proc mCReturn()
    integer found = FALSE

    if language and CurrPos() > PosFirstNonWhite()
        if pos(GetFirstWord(), KeyWords)
            found = TRUE
        elseif cmode
            PushPosition()
            repeat
                if CurrChar() == asc('{')
                    found = TRUE
                    break
                endif
            until not left()
            PopPosition()
        endif
    endif
    if not CReturn()
        return (FALSE)
    endif
    return (iif(found
                and ((Query(Insert) and Query(ReturnEqNextLine) == FALSE)
                or PosFirstNonWhite() == 0),
                TabRight(), TRUE))
end

constant WORDCASE  = 1,
         LINECASE  = 2,
         BLOCKCASE = 3

constant UPPER_CASE = 0,
         LOWER_CASE = 1,
         FLIP_CASE  = 2

integer casetype

// Assume type is always one of WORDCASE, LINECASE or BLOCKCASE.
proc ChangeCase(integer type)
    PushBlock()
    if type <> BLOCKCASE
        UnMarkBlock()
        if type == LINECASE
            MarkLine()
        elseif not MarkWord()
            goto done
        endif
    elseif not isCursorInBlock()
        goto done
    endif
    case casetype
        when UPPER_CASE
            Upper()
        when LOWER_CASE
            Lower()
        otherwise
            Flip()
    endcase
    done:

    PopBlock()
end

menu CaseMenu()
    Command = ChangeCase(MenuOption())

    "&Word at Cursor"   // if the order of these options is changed,
    "Current &Line"     // Change to order of the constants
    "&Block"            // WORDCASE, LINECASE, and BLOCKCASE
end

proc mUpper()
    casetype = UPPER_CASE
    CaseMenu("Upper Case")
end

proc mLower()
    casetype = LOWER_CASE
    CaseMenu("Lower Case")
end

proc mFlip()
    casetype = FLIP_CASE
    CaseMenu("Flip Case")
end

integer proc mSaveSettings()
    if YesNo("Overwrite existing config?") == 1
        return (iif(SaveSettings(), TRUE, Warn("Error updating executable")))
    endif
    return (FALSE)
end

/************************************************************************
  Macro to wrap text in a column block, without distrubing the surrounding
  text.

  If a column isn't marked, the normal WrapPara() is called.
 ************************************************************************/
proc mWrapPara()
    integer
        id,                         // work buffer id
        block_beg_col,
        save_leftmargin,
        save_rightmargin,
        save_autoindent,
        save_wrapend,
        curr_id = GetBufferId(),    // current file id
        blocktype = isCursorInBlock()

    if blocktype == 0
        WrapPara()
    else
        Set(Marking, off)               // Stop marking
        if blocktype <> _COLUMN_        // Wrap entire block if not column
            GotoBlockEnd()
            AddLine()
            GotoBlockBegin()
            repeat
            until (not WrapPara()) or (not isCursorInBlock())
            if CurrLineLen() == 0
                DelLine()
            endif
        else                            // Otherwise, wrap whats in col
            GotoBlockBegin()
            block_beg_col = CurrCol()
            id = CreateTempBuffer()
            CopyBlock()                 // Copy block to temp buffer

            /**************************************************************
              The number of lines in the column may become less than what
              it was - so we must fill the old block with spaces.
             **************************************************************/
            PushBlock()                 // Save block settings
            GotoBufferId(curr_id)       // Back to original file
            CopyBlock(_OVERWRITE_)      // And get the block back
            FillBlock(' ')              // Wipe it out
            GotoBufferid(id)            // Back to where we were
            PopBlock()                  // And get our block marked again

            /**************************************************************
              Prepare to wrap - we need to set the left/right margins to
              1 and the width of the column.  We also need to preserve the
              old settings.
             **************************************************************/
            save_leftmargin = Set(LeftMargin, 1)
            GotoBlockEnd()
            save_rightmargin = Set(RightMargin, CurrCol())
            save_autoindent = Set(AutoIndent, Off)
            save_wrapend = Set(ParaEndStyle, 0)
            BegFile()
            repeat
            until not WrapPara()
            UnmarkBlock()           // We need to re-mark the block
            BegFile()
            MarkColumn()
            EndFile()
            GotoColumn(Query(RightMargin))

            /*************************************************************
              And finally, go back to the original file, and copy the block
              in.
             *************************************************************/
            GotoBufferId(curr_id)
            CopyBlock(_OVERWRITE_)
            AbandonFile(id)
            GotoBlockEnd()
            Down()
            GotoColumn(block_beg_col)

            // Restore saved settings

            Set(LeftMargin, save_leftmargin)
            Set(RightMargin, save_rightmargin)
            Set(AutoIndent, save_autoindent)
            Set(ParaEndStyle, save_wrapend)
        endif
    endif
end mWrapPara

/*************************************************************************
  TSE called macros, including:

  WhenLoaded
  Main
  Hooked functions
 *************************************************************************/

/**************************************************************************
  This macro is called everytime EditFile() or Next/PrevFile() is called.
 **************************************************************************/
proc OnChangingFiles()
    string fn[65] = CurrFilename()
    integer mk, cid = GetBufferId()

    /* First, do 'RecentFiles' processing */

    if Query(BufferType) == _NORMAL_ and GotoBufferId(pick_buffer)
        mk = Set(KillMax, 0)
        if lFind(fn, "^$g")
            DelLine()
        elseif NumLines() > 20
            EndFile()
            DelLine()
        endif
        BegFile()
        InsertLine(fn)
        GotoBufferId(cid)
        Set(KillMax, mk)
    endif

    /* Ok, on with the rest of the show */

    language = FALSE
    cmode = FALSE
    case CurrExt()
        when ".s",".asm",".pas",".inc",".prg"
            language = TRUE
        when ".c",".h",".cpp",".hpp"
            language = TRUE
            cmode = TRUE
    endcase
end

/**************************************************************************
  This macro is called The firsttime a file is loaded into the editor.
 **************************************************************************/
proc OnFirstEdit()
end

/***************************************************************************
  This macro is called just after the editor starts, before the command line
  has been processed and any files are loaded.
 ***************************************************************************/
proc WhenLoaded()
    integer cid = GetBufferId()

    pick_buffer = CreateTempBuffer()
    GotoBufferId(cid)
    Hook(_ON_CHANGING_FILES_, OnChangingFiles)
    Hook(_ON_FIRST_EDIT_, OnFirstEdit)
end

/***************************************************************************
   This macro is called just after the first file is loaded, but before the
   user is given control, and before any hook functions are called.
 ***************************************************************************/
proc Main()
end

//  ษอออออออออออป
//  บ The Menus บ
//  ศอออออออออออผ

Menu FileMenu()
    history

    "&Open..."                      ,   EditFile()
    "&Insert..."                    ,   InsertFile()
    ""                              ,                       ,   Divide
    "&Next"                         ,   NextFile()
    "&Previous"                     ,   PrevFile()
    "&List Open  "                 ,   mListOpenFiles()
    "List &Recent  "               ,   mListRecentFiles()
    "Current File"                  ,                       ,   Divide
    "&Save"                         ,   SaveFile()
    "Save &As..."                   ,   SaveAs()
    "Save && Qui&t"                 ,   SaveAndQuitFile()
    "&Quit"                         ,   QuitFile()
    "&Change Name..."               ,   ChangeCurrFilename()
    "All Files"                     ,                       ,   Divide
    "Sa&ve All"                     ,   SaveAllFiles()
    "Save All && &Exit"             ,   SaveAllAndExit()
    "E&xit"                         ,   Exit()
end

Menu NamedClipBoardMenu()
    history

    "Cu&t..."           ,   mScratchBuffer(CUTTING)
    "C&ut Append..."    ,   mScratchBuffer(CUTAPPEND)
    "&Copy..."          ,   mScratchBuffer(STORING)
    "Cop&y Append..."   ,   mScratchBuffer(APPENDING)
    ""                  ,   ,                           Divide
    "&Paste..."         ,   mScratchBuffer(GETTING)
    "&Paste &Over..."   ,   mScratchBuffer(GETOVERLAY)
end

Menu ClipboardMenu()
    history

    "Cu&t"              ,   Cut()
    "C&ut Append"       ,   Cut(_APPEND_)
    "&Copy"             ,   Copy()
    "Cop&y Append"      ,   Copy(_APPEND_)
    ""                  ,                       , Divide
    "&Paste"            ,   Paste()
    "Paste &Over"       ,   Paste(_OVERWRITE_)
    ""                  ,                       , Divide
    "&Named ClipBoards  ", NamedClipBoardMenu(), DontClose
end

Menu WindowMenu()
    history

    "&Horizontal"           ,   HWindow()
    "&Vertical"             ,   VWindow()
    "&Resize..."            ,   ResizeWindow()
    "&Go to..."             ,   GotoWindow()
    "&Zoom"                 ,   ZoomWindow()
    "&One"                  ,   OneWindow()
    "&Close..."             ,   CloseWindow()
end

Menu BlockMenu()
    history

    "Mark &Line"                ,   MarkLine()
    "Mark Ch&aracter"           ,   MarkStream()
    "Mar&k Column"              ,   MarkColumn()
    "&UnMark"                   ,   UnMarkBlock()
    ""                          ,                       , Divide
    "&Copy"                     ,   CopyBlock()
    "&Move"                     ,   MoveBlock()
    "&Shift..."                 ,   mShift()
    "&Write to File..."         ,   SaveBlock()
    "&Delete"                   ,   DelBlock()
    ""                          ,                       , Divide
    "U&pper  "                 ,   mUpper()            , DontClose
    "Lowe&r  "                 ,   mLower()            , DontClose
    "Fl&ip   "                 ,   mFlip()             , DontClose
    "&Fill..."                  ,   FillBlock()
end

Menu SearchMenu()
    history

    "&Find..."                      ,   find()
    "&Replace..."                   ,   replace()
    "&Again"                        ,   repeatfind()
    ""                              ,                       , Divide
    "Find &Word at Cursor"          ,   mFindWordAtCursor('+')
    "&Incremental Search..."        ,   mIncrementalSearch()
    "Compressed &View..."           ,   mCompressView(0)
    ""                              ,                       , Divide
    "F&unction List"                ,   mCompressView(1)
    "&Match"                        ,   mMatch()
    "Cou&nt..."                     ,   mCount()
    ""                              ,                       , Divide
    "&Place Bookmark..."            ,   placemark()
    "&Go to Bookmark..."            ,   gotomark()
    ""                              ,                       , Divide
    "Go to &Line..."                ,   GotoLine()
    "Go to &Column..."              ,   GotoColumn()
end

Menu PrintConfig()
    Title = 'Print Output Options'
    History

    "&Left Margin"              [Query(PrintLeftMargin):5],
            Set(PrintLeftMargin,ReadNum(Query(PrintLeftMargin))),
            DontClose
    "&Right Margin"             [Query(PrintRightMargin):5],
            Set(PrintRightMargin,ReadNum(Query(PrintRightMargin))),
            DontClose
    "&Top Margin"               [Query(PrintTopMargin):5],
            Set(PrintTopMargin,ReadNum(Query(PrintTopMargin))),
            DontClose
    "&Bottom Margin"            [Query(PrintBotMargin):5],
            Set(PrintBotMargin,ReadNum(Query(PrintBotMargin))),
            DontClose
    "Lines &Per Page"           [Query(PrintLinesPerPage):5],
            Set(PrintLinesPerPage,ReadNum(Query(PrintLinesPerPage))),
            DontClose,
            "Number of lines per page, 0 for continuous forms"
    "Line &Spacing"             [Query(PrintLineSpacing):5],
            Set(PrintLineSpacing,ReadNum(Query(PrintLineSpacing))),
            DontClose,
            "Type of spacing, 1=Single 2=Double 3=Triple etc..."
    ""      ,,
            Divide
    "&Header"                   [Query(PrintHeader):4],
            GetHeader(),
            DontClose,
            "Specifies what to print at top of each page"
    "&Footer"                   [Query(PrintFooter):4],
            GetFooter(),
            DontClose,
            "Specifies what to print at bottom of each page"
    "&Device"                   [Query(PrintDevice):15],
            GetPrintDevice(),
            DontClose,
            "Name of device to send print,  can be a filename"
    "&Init String"              [Query(PrintInit):10],
            GetInitString(),
            DontClose,
            "String to be sent to the printer before each print job"
    ""      ,,
            Divide
    "First P&age"               [Query(PrintFirstPage):5],
            Set(PrintFirstPage,ReadNum(Query(PrintFirstPage))),
            DontClose,
            "Page Number to start printing from"
    "Last Pa&ge"                [Query(PrintLastPage):5],
            Set(PrintLastPage,ReadNum(Query(PrintLastPage))),
            DontClose,
            "Page Number of last page to print"
    "Number of &Copies"         [Query(PrintCopies):5],
            Set(PrintCopies,ReadNum(Query(PrintCopies))),
            DontClose,
            "Number of copies to print"
    ""      ,,
            Divide
    "Print Line &Numbers"           [OnOffStr(Query(PrintLineNumbers)):3],
            Toggle(PrintLineNumbers),
            DontClose,
            "Line numbers will be printed at beginning of each line"
    "F&ormfeed After Printing"      [OnOffStr(Query(PrintAddFF)):3],
            Toggle(PrintAddFF),
            DontClose,
            "Sends a Form Feed to the printer after print job is complete"
    "Pa&use Between Pages"          [OnOffStr(Query(PrintPause)):3],
            Toggle(PrintPause),
            DontClose,
            "Pause between each printed page"
end PrintConfig

Menu PrintMenu()
    history

    "&All"                  ,   PrintFile()
    "&Block"                ,   PrintBlock()
    "Send &Formfeed"        ,   mSendFormFeed()
    "Send &Init String"     ,   mSendInitString(),  DontClose
    "Set &Options  "       ,   PrintConfig(),      DontClose
end PrintMenu

Menu MacroMenu()
    Title = "Keyboard Macros"
    history

    "&Record"                       ,   RecordKeyMacro()
    "&Save..."                      ,   SaveKeyMacro()
    "Loa&d..."                      ,   LoadKeyMacro()
    "Run Scrap &Macro"              ,   ExecScrapMacro()
    "Pur&ge"                        ,   PurgeKeyMacro()
    "Compiled Macros"               ,                   ,   Divide
    "&Execute..."                   ,   mMacMenu(1)
    "&Load..."                      ,   mMacMenu(2)
    "&Purge..."                     ,   mMacMenu(3)
//
//  03/07/94 12:13 pm H. Johnson
//  Here is where we make our change. See COMPILE.S
//    "&Compile"                      ,   mCompile()
//
    "&Compile"                      ,   mCompileCurrentFile(TRUE)
end

Menu TextMenu()
    history

    "&Add Line (below)"         ,   AddLine()
    "&Insert Line (above)"      ,   InsertLine()
    "D&up Line"                 ,   DupLine()
    "&Join Line"                ,   JoinLine()
    "Spli&t Line"               ,   SplitLine()
    "&Swap Lines"               ,   mSwapLines()
    ""                          ,                   ,   Divide
    "&Delete Line"              ,   DelLine()
    "Delete to &End of Line"    ,   DelToEol()
    "Delete Right &Word"        ,   DelRightWord()
    ""                          ,                   ,   Divide
    "&Global UnDelete"          ,   GlobalUnDelete()
    "&Local UnDelete"           ,   UnDelete()
    "Paste U&nDelete"           ,   PasteUnDelete()
    "&Restore Cursor Line"      ,   RestoreCursorLine()
    ""                          ,                   ,   Divide
    "Wrap &Paragraph"           ,   mWrapPara()
    "&Center Line"              ,   mCenterLine()
end

Menu VideoModeMenu()
    history = Query(CurrVideoMode)
    command = Set(CurrVideoMode,MenuOption())

    "&25-Line"
    "2&8-Line"
    "&43-Line"
    "&50-Line"
end

Menu UtilMenu()
    history

    "&Line Draw" [OnOffStr(Query(LineDraw)):3], Toggle(LineDraw), DontClose
    "Line &Type  "         ,   LineTypeMenu()      ,   DontClose
    ""                          ,                   ,   Divide
    "&Sort"                 ,   Sort(sort_flags)
    "Sort &Order"   [ShowSortFlag() : 10], ToggleSortFlag(1), DontClose
    "&Case-Sensitive Sort" [OnOffStr((sort_flags & 2) == 0):3], ToggleSortFlag(2), DontClose
    ""                          ,                   ,   Divide
    "&ASCII Chart"          ,   mAsciiChart()
    "&Date/Time Stamp"      ,   mDateTimeStamp()
    "Change &Video Mode  " ,   VideoModeMenu()     ,   DontClose
    "DOS S&hell"            ,   Shell()
end

menu AutoIndentMenu()
    command = Set(AutoIndent, MenuOption() - 1)
    history = query(AutoIndent) + 1

    "O&ff"      ,, CloseBefore
    "O&n"       ,, CloseBefore
    "&Sticky"   ,, CloseBefore
end

Menu TabTypeMenu()
    history = query(tabtype) + 1
    command = Set(TabType,MenuOption()-1)

    "&Hard"     ,, CloseBefore
    "&Soft"     ,, CloseBefore
    "Smar&t"    ,, CloseBefore
    "&Variable" ,, CloseBefore
end

Menu ReconfigMenu()
    history

    "&AutoIndent"           [MenuStr(AutoIndentMenu,query(AutoIndent)+1) : 6],
                            AutoIndentMenu()            ,   DontClose
    "&WordWrap"             [OnOffStr(query(WordWrap))   : 3],
                            Toggle(WordWrap)            ,   DontClose
    "&Right Margin"         [query(RightMargin) : 5],
                            set(RightMargin, ReadNum(Query(RightMargin))),   DontClose
    "&Left Margin"          [query(LeftMargin) : 5],
                            set(LeftMargin, ReadNum(Query(LeftMargin))),   DontClose
    ""                          ,                   ,   Divide
    "Tab Ty&pe"             [MenuStr(TabTypeMenu,query(TabType)+1) : 8],
                            TabTypeMenu()               ,   DontClose
    "&Tab Width"            [query(TabWidth) : 5],
                            set(TabWidth, ReadNum(Query(TabWidth))),   DontClose
    ""                          ,                   ,   Divide
    "&Backups"              [OnOffStr(Query(MakeBackups)) : 3],
                            Toggle(MakeBackups)         ,   DontClose
    ""                          ,                   ,   Divide
    //
    //  03/07/94 12:22 pm H. Johnson
    //  Add COMPILE and MAKE configuration to system...
    //
    "&COMPILE Setup Strings  ",  COMPILESetupMenu(),   DontClose
    "&MAKE Setup Strings  "   ,  MAKESetupMenu()   ,   DontClose
    ""                          ,                   ,   Divide
    "&Full Configuration  ",          ExecMacro("iconfig"),DontClose
    "&Save Current Settings",       mSaveSettings()
end

MenuBar MainMenu()
    history

    "&File"    ,    FileMenu()
    "&Block"   ,    BlockMenu()
    "&Text"    ,    TextMenu()
    "&Search"  ,    SearchMenu()
    "&Window"  ,    WindowMenu()
    "&Clipboard",   ClipboardMenu()
    "&Macro"   ,    MacroMenu()
    "&Print"   ,    PrintMenu()
    "&Util"    ,    UtilMenu()
    "&Options" ,    ReconfigMenu()
end

proc mPullDownMenu(integer key)
  pushkey(key)
  mainmenu()
end

// Mouse functions:

proc mLeftBtn()
    if not ProcessHotSpot()
       MainMenu()
    endif
end

proc mTrackMouseCursor()
    if GotoMouseCursor()
        TrackMouseCursor()
    endif
end

#include ["tse_x.key"]   // key-assignments
