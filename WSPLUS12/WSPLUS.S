#Include ["wsplus.cfg"]

//### common se.s include - for detailed comments, see the se.s file.

// See se.s for notes and comments on many of the macros included here.

// Global Variables - Assumes globals initialized to 0.

    integer
    cmode,              // used to invoke C-mode
    language,           // used to invoke language package
    sort_flags,
    pick_buffer,        // id of the pick-buffer
    Load_On_Split = 0,  // When Window Splits Prompt To Load A File
    Goto_Pos      = 1,  // Goto Last Saved Position When File Is Loaded
    ATT_MACRO     = 1   // Personal Macro For AT&T Compiler

string KeyWords[] = " If else elseIf while repeat loop for switch case when otherwise proc "

/*************************************************************************
 *************************************************************************/
string proc CurrExt()
    return (SplitPath(CurrFilename(), _EXT_))
end

/*************************************************************************
 *************************************************************************/
integer proc ListIt(string title, integer width)
    width = width + 4
    If width > Query(ScreenCols)
        width = Query(ScreenCols)
    Endif
    Return (List(title, width))
end

/*************************************************************************
  Return the word at the cursor as a string.
 *************************************************************************/
string proc GetWordAtCursor()
    string word[80] = ''

    PushBlock()                     // Save current block status
    If MarkWord()                   // Mark the word
        word = GetMarkedText()      // Get it
    Endif
    PopBlock()                      // Restore block status
    Return (word)                   // Thats all, folks!
end GetWordAtCursor

/*************************************************************************
   Return the first word on the line as string - '' If not there.
 *************************************************************************/
string proc GetFirstWord()
    string word[32] = ''

    PushPosition()                  // Save where we're at
    GotoPos(PosFirstNonWhite())     // Go to first non white
    word = GetWordAtCursor()        // Now get the word there
    PopPosition()                   // Restore saved position
    Lower(word)                     // Make it lower case
    Return (' ' + word + ' ')       // And Return the word
end

string proc GetTextUntil(string stopchar)
    integer start = CurrPos()

    while CurrChar() <> Asc(stopchar) and CurrChar() >= 0 and Right()
    endwhile

    Return (GetText(start, CurrPos() - start))
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
    Return (iIf(i, "On", "Off"))
end

/*************************************************************************
 *************************************************************************/
string proc ShowSortFlag()
    Return (iIf(sort_flags & 1, "Descending", "Ascending"))
end

proc ToggleSortFlag(integer which)
    If sort_flags & which
        sort_flags = sort_flags & ~ which
    else
        sort_flags = sort_flags | which
    Endif
end

/*************************************************************************
 *************************************************************************/
integer proc ReadNum(integer n)
    string s[5] = str(n)

    Return (iIf(Read(s), val(s), n))
end ReadNum

///////////////////// End Help Macros/Subroutines ///////////////////////

/*************************************************************************
  The match command.  Use this macro to match (){}{}<> chars.
 *************************************************************************/
string match_chars[] = "(){}[]<>"   // pairs of chars to match
integer proc mMatch()
    integer p, level
    integer mc, ch

    p = Pos(chr(CurrChar()), match_chars)
    // If we're not already on a match char, go forward to find one
    If p == 0 and lFind("[(){}[\]<>]", "x")
        Return (FALSE)
    Endif

    PushPosition()
    If p
        ch = asc(match_chars[p])             // Get the character we're matching
        mc = asc(match_chars[iIf(p & 1, p + 1, p - 1)])  // And its reverse
        level = 1                       // Start out at level 1

        while lFind("[\" + chr(ch) + "\" + chr(mc) + "]", iIf(p & 1, "x+", "xb"))
            case CurrChar()             // And check out the current character
                when ch
                    level = level + 1
                when mc
                    level = level - 1
                    If level == 0
                        KillPosition()          // Found a match, remove position
                        p = CurrPos()           // Fix up possible horizontal
                        BegLine()               // scrolling by saving position,
                        GotoPos(p)              // starting at beginning, and restoring
                        Return (TRUE)           // And Return success
                    Endif
            endcase
        endwhile
    Endif
    PopPosition()                       // Restore position
    Return (warn("Match not found"))    // Warn() Returns False
end mMatch

/*****************************************************************************
  List Files placed in the editor's internal ring of files.

  Notes:
    System buffers are _not_ intended for interactive editing.  Therefore,
    this command will exit If it is determined that the current buffer is a
    system buffer.
 *****************************************************************************/
proc mListOpenFiles()
    integer start_file, filelist, id, rc, maxl, total, n
    string fn[65]

    n = NumFiles() + (Query(BufferType) <> _NORMAL_)
    If n == 0
        Return ()
    Endif
    maxl = 0
    total = 0
    start_file = GetBufferid()                 // Save current
    filelist = CreateTempBuffer()
    If filelist == 0
        warn("Can't create filelist")
        Return ()
    Endif
    GotoBufferId(start_file)
    id = GetBufferid()
    while n
        fn = CurrFilename()
        If length(fn)
            If length(fn) > maxl
                maxl = length(fn)
            Endif
            rc = isChanged()
            GotoBufferId(filelist)
            AddLine(iIf(rc, '*', ' ') + fn)
            GotoBufferId(id)
        Endif
        NextFile(_DONT_LOAD_)
        id = GetBufferid()
        n = n - 1
    endwhile
    GotoBufferId(filelist)
    BegFile()
    If ListIt("Buffer List", maxl)
        EditFile(GetText(2, sizeof(fn)))    // Force loading from disk
    else
        GotoBufferId(start_file)
    Endif
    AbandonFile(filelist)
end mListOpenFiles

/************************************************************************
  Routine to center a line.
  If a block is marked, all the lines in the block are centered, using
    the left and right margins;
  If the block is a column block, only the text in the column block is
    centered, without disturbing surrounding text.
 ************************************************************************/
proc mCenterLine()
    integer right_margin = Query(RightMargin),
        left_margin = Query(LeftMargin),
        first_line, last_line, type, p, center, cid, tid

    PushPosition()
    If left_margin == 0 or left_margin >= right_margin
        left_margin = 1
    Endif
    first_line = CurrLine()
    last_line = first_line
    type = isCursorInBlock()
    If type
        Set(Marking, off)
        first_line = Query(BlockBegLine)
        last_line = Query(BlockEndLine)
        If type == _COLUMN_
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
        Endif
    Endif
    If right_margin > left_margin
        GotoLine(first_line)
        repeat
            p = PosFirstNonWhite()
            center = ((p + PosLastNonWhite()) / 2) - ((left_margin + right_margin) / 2)
            ShiftText(iIf(center > 0,
                - (iIf(center < p, center, p - 1)), Abs(center)))
        until (not RollDown()) or CurrLine() > last_line
        If type == _COLUMN_
            GotoBufferId(cid)
            CopyBlock(_OVERWRITE_)
            AbandonFile(tid)
        Endif
    Endif
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

    If operation > GETTING and (NOT isBlockInCurrFile())
        Return (FALSE)
    Endif
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
    If ask(msg, BufferName) and Length(BufferName)   // get scratch name
        BufferName = "+++" + BufferName         // Fudge for scratch
        id = GetBufferId(BufferName)             // See If already there
        If operation <> GETTING and id == 0
            cid = GetBufferId()
            id = CreateBuffer(BufferName, _SYSTEM_)    // create a buffer
            GotoBufferId(cid)
        Endif
        If id <> 0                              // If it worked
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
        Endif
    Endif
    Return (result)                               // Return result
end

constant ShiftLEFT = -1, ShiftRIGHT = 1

integer proc mShiftBlock(integer direction)
    integer goal_line = CurrLine(),
            btype     = isCursorInBlock(),
            save_marking   = Query(Marking)

    PushPosition()
    If btype
        goal_line = Query(BlockEndLine)
        GotoBlockBegin()
    Endif
    repeat until not ShiftText(direction)
            or   not RollDown()
            or   CurrLine() > goal_line
    PopPosition()
    Set(Marking, save_marking)
    Return (TRUE)
end

proc mShift()
    integer k = Set(EquateEnhancedKbd, ON)

    loop
        Message("<Left>,<Right> or <Tab>,<Shift Tab> to Shift text; <Enter> when done")
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
                If isCursorInBlock()
                    UnMarkBlock()
                    break
                Endif
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
        If Length(s) and global_or_reverse
            option = substr(option, 1, length(option) - 1)
            global_or_reverse = FALSE
        Endif
        next = FALSE
        message("I-Search (^N=Next ^P=Prev ^B=Beginning):", s)

        retry:
        ch = getkey()
        case ch
            when <BackSpace>                // go back to start
                PopPosition()
                PushPosition()
                s = iIf(length(s) <= 1, "", substr(s, 1, length(s) - 1))
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
                If Length(s)
                    AddHistoryStr(s, _FINDHISTORY_)
                Endif
                break
            otherwise
                If (ch & 0xff) == 0         // Function key?
                    goto retry              // Yes, try again.
                Endif
                s = s + chr(ch & 0xff)      // mask off the scan code
        endcase
        If Length(s) and NOT find(s, option) and NOT global_or_reverse and NOT next
            s = substr(s, 1, length(s) - 1)
        Endif
    endloop
    KillPosition()
    UpdateDisplay()
end

integer proc mFindWordAtCursor(string option)
    If Length(GetWordAtCursor())
        AddHistoryStr(GetWordAtCursor(), _FINDHISTORY_)
        Return (Find(GetWordAtCursor(), Query(FindOptions) + option))
    Endif
    Return (Find())
end mFindWordAtCursor

string lineone[] = "      şşş Select this line to edit COMPRESS file şşş"
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

    If compress_hist == 0   // This must be first time through - do initialization.
        compress_hist = GetFreeHistory()
        compress_options_history = GetFreeHistory()
        AddHistoryStr(Query(FindOptions), compress_options_history)
    Endif

    start_line_no = CurrLine()
    If NumLines() == 0
        Return ()
    Endif

    line_no = 0
    list_no = 0
    goto_line_no = 1
    width = Length(Str(NumLines()))

    // compress_types are [0..1]
    If compress_type == 0
        If not ask("String to list all occurrences of:", expr, compress_hist)
            Return ()
        Endif
        If Length(expr) == 0
            opts = "x"
            expr = "^[a-zA-Z_]"
        elseIf not ask("Search options [IWX] (Ignore-case Words reg-eXp):", opts, compress_options_history)
            Return ()
        Endif
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
                Return ()
        endcase
    Endif

    compress_id = CreateBuffer(compress_buffer_name)
    If compress_id == 0
        compress_id = GetBufferId(compress_buffer_name)
    Endif
    If compress_id == current_id
        warn("Can't use this buffer")
        Return ()
    Endif
    If compress_id == 0 or not GotoBufferId(compress_id)
        Return ()
    Endif

    // At this point, we are in the compress buffer
    EmptyBuffer()
    InsertText(lineone)
    GotoBufferId(current_id)
    PushPosition()
    BegFile()
    If lFind(expr, opts)
        repeat
            line = GetText(1, sizeof(line))
            line_no = CurrLine()
            If Length(line) > maxlen
                maxlen = Length(line)
            Endif
            GotoBufferId(compress_id)
            If not AddLine(Format(line_no:width, ': ', line))
                break
            Endif
            If goto_line_no == 1 and line_no > start_line_no
                goto_line_no = CurrLine() - 1
            Endif
            GotoBufferId(current_id)
            EndLine()
        until not lRepeatFind()
    Endif
    GotoBufferId(compress_id)
    GotoLine(goto_line_no)
    If ListIt(iIf(compress_type == 0, expr, "Function List"), maxlen + width)
        If CurrLine() == 1
            PopPosition()
            GotoBufferId(compress_id)
            mk = Set(KillMax, 0)
            DelLine()
            Set(KillMax, mk)
            ForceChanged(FALSE)
            Return ()
        Endif
        list_no = val(GetText(1, width))
    Endif
    AbandonFile()
    PopPosition()
    If list_no
        GotoLine(list_no)
        ScrollToRow(Query(WindowRows)/2)
    Endif
end mCompressView

integer chartid
proc mAsciiChart()
    integer
        i,
        ok,
        c = CurrChar(),
        et = Set(ExpandTabs, off)

    PushPosition()
    If chartid == 0
        chartid = CreateTempBuffer()
        i = 0
        while AddLine(format(i:6, str(i, 16):6, chr(i):6)) and i <> 255
            i = i + 1
        endwhile
    Endif
    GotoBufferId(chartid)
    BegFile()
    If c > 0
        GotoLine(c + 1)
    Endif
    ok = ListIt(" DEC   HEX   Char", 18)
    i = CurrLine() - 1
    PopPosition()
    If ok
        InsertText(chr(i))
    Endif
    Set(ExpandTabs, et)
end mAsciiChart

proc mListRecentFiles()
    integer maxl = 0, cid = GetBufferId()

    If GotoBufferId(pick_buffer)
        BegFile()
        repeat
            If CurrLineLen() > maxl
                maxl = CurrLineLen()
            Endif
        until not down()
        GotoLine(2)
        If ListIt("Recent Files", maxl)
            EditFile(GetText(1, CurrLineLen()))
        else
            GotoBufferId(cid)
        Endif
    Endif
end mListRecentFiles

/************************************************************************
  This version assumes the compiler program is either in the current
  directory or available via the path.
 ************************************************************************/
proc mCompile()
    string fn[65] = CurrFilename(),
        err_fn[12] = "$errors$.tmp"
    integer line, col

    If CurrExt() <> ".s"
        Warn("Extension not supported")
        Return ()
    Endif
    OneWindow()         // Force a single window
    If isChanged()
        SaveFile()
    Endif
    // Remove the error file If we're already editing it
    AbandonFile(GetBufferId(ExpandPath(err_fn)))
    PurgeMacro(fn)
    EraseDiskFile(err_fn)
    Dos("sc " + fn + ">" + err_fn, _DONT_CLEAR_)
    EditFile(err_fn)
    EraseDiskFile(err_fn)
    //
    // 3 cases -
    //      1 - SC didn't run, probably not found. IdentIfy by empty err_fn
    //      2 - Error/Warning msg found in err_fn - position to error
    //      3 - No Errors/Warnings!  Load/Exec the new macro.
    //
    If lFind("^{Error}|{Warning} #[0-9]# #\c","ix")
        PrevFile()
        HWindow()
        If CurrChar() == Asc('(')
            Right()
            line = Val(GetTextUntil(','))
            Right()                             // skip the comma
            col  = Val(GetTextUntil(')'))
            PrevWindow()
            GotoLine(line)
            ScrollToRow(Query(WindowRows) / 2)
            GotoColumn(col)
        Endif
        UpdateDisplay()
    else
        // At this point, no error/warning messages found, in the error file
        AbandonFile()
        If NumLines() == 0                      // If empty, we failed
            Warn("Error running SC.EXE")
        else
            UpdateDisplay()                     // Force a statusline refresh
            fn = SplitPath(fn, _DRIVE_ | _NAME_)
            case LoadExec("Compile successful")
                when 1
                    LoadMacro(fn)
                when 2
                    ExecMacro(fn)
            endcase
        Endif
    Endif
end

integer proc mMacMenu(integer n)
    string s[8] = ''

    If n == 0
        n = ExecLoadPurge()
    Endif
    case n
        when 1
            Return (ExecMacro())
        when 2
            Return (LoadMacro())
        when 3
            If ask("Purge macro:", s) and Length(s) and PurgeMacro(s)
                Message(s, " purged.")
                Return (TRUE)
            Endif
    endcase
    Return (FALSE)
end

proc mSwapLines()
    integer km

    If Down()
        km = Set(KillMax, 1)
        DelLine()
        Up()
        UnDelete()
        Set(KillMax, km)
    Endif
end

proc mCount()
    integer count = 0
    string s[60] = '', opts[12] = Query(FindOptions)

    If Ask("String to count occurrences of:", s) and Length(s) and
        Ask("Options [GLIWX] (Global Local Ignore-case Words reg-eXp):", opts)
        PushPosition()
        If lFind(s, opts)
            repeat
                count = count + 1
            until not lRepeatFind()
        Endif
        PopPosition()
        Message("Found ", count, " occurrence(s)")
    Endif
end

proc mSendFormFeed()
    If not PrintChar(chr(12))
        warn("Error sending formfeed")
    Endif
end

proc GetPrintDevice()
    string s[48] = Query(PrintDevice)

    If ask("Print Device:", s)
        Set(PrintDevice, s)
    Endif
end

proc GetHeader()
    string s[4] = Query(PrintHeader)

    If ask("Print Header [FDTP] (Filename Date Time Page):", s)
        Set(PrintHeader, s)
    Endif
end

proc GetFooter()
    string s[4] = Query(PrintFooter)

    If ask("Print Footer [FDTP] (Filename Date Time Page):", s)
        Set(PrintFooter, s)
    Endif
end

proc GetInitString()
    string s[60] = Query(PrintInit)

    If ask("Init String:", s)
        Set(PrintInit, s)
    Endif
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

proc mFlipRight()
    Flip()
    Right()

end

proc mUpLetter()
    Upper()
    Right()
end

proc mDownLetter()
    Lower()
    Right()
end


proc mLockPageUp()
     PageUp()
     NextWindow()
     PageUp()
     PrevWindow()
end

proc mLockPageDown()
     PageDown()
     NextWindow()
     PageDown()
     PrevWindow()
end

proc mDelWordThenDown()
     DelRightWord()
     Down()
end

proc mHWindow()

     If Load_On_Split == 1
        EditFile()
     Endif

     HWindow()
end

proc mVWindow()

     If Load_On_Split == 1
        EditFile()
     Endif

     VWindow()
end

proc mWriteLastPosition()
     string   s1[40], s2[40], s3[40]
     integer  i1, i2, i3

     i1 = CurrLine()
     i2 = CurrPos()
     s1 = CurrFilename()
     s2 = SplitPath( s1, _NAME_ | _EXT_ )
     s3 = "SEMEDIT.$E$"

     if ( SplitPath( s1, _EXT_ ) <> ".$e$" )

         EditFile( S3 )

         i3 = lFind( S2, "gi" )

         if i3 > 0
            DelLine()
            DelLine()
            DelLine()
         endif

         InsertLine( str(i2) )
         InsertLine( str(i1) )
         InsertLine( S2 )

         SaveAndQuitFile()

    endif


end

proc mGetAndGotoLastPosition()
     string   s1[40], s2[40], s3[40]
     integer  i1=1, i2=1, i3=1

     s1 = CurrFilename()
     s2 = SplitPath( s1, _NAME_ | _EXT_ )

     if FileExists( "GREPGOTO.$E$" )
        s3 = "GREPGOTO.$E$"
     else
        s3 = "SEMEDIT.$E$"
     endif

     if FileExists( S3 ) and Goto_Pos and CurrExt() <> ".$e$"

         EditFile( S3 )

         i3 = lFind( s2, "gi" )

         if ( i3 > 0 )
             Down()
             BegLine()
             s1 = GetText( 1, 10 )
             i1 = Val( s1 )
             Down()
             BegLine()
             s1 = GetText( 1, 10 )
             i2 = Val( s1 )
         endif

         QuitFile()

         GotoLine( i1 )
         GotoPos( i2 )
         ScrollToRow(Query(WindowRows)/2)

     endif

end


/*************************************************************************
  Commands augmented by macros:
 *************************************************************************/

// Augment delchar by joining lines If at or passed eol
integer proc mDelChar()
    Return(iIf(CurrChar() >= 0, DelChar(), JoinLine()))
end

// Fancy CarriageReturn command.  Works If language mode is on.
integer proc mCReturn()
    integer found = FALSE

    If language and CurrPos() > PosFirstNonWhite()
        If pos(GetFirstWord(), KeyWords)
            found = TRUE
        elseIf cmode
            PushPosition()
            repeat
                If CurrChar() == asc('{')
                    found = TRUE
                    break
                Endif
            until not left()
            PopPosition()
        Endif
    Endif
    If not CReturn()
        Return (FALSE)
    Endif
    Return (iIf(found
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
    If type <> BLOCKCASE
        UnMarkBlock()
        If type == LINECASE
            MarkLine()
        elseIf not MarkWord()
            goto done
        Endif
    elseIf not isCursorInBlock()
        goto done
    Endif
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

    "&Word at Cursor"   // If the order of these options is changed,
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

proc mCompileTPC()
     SaveFile()
     Dos( "Call SetBCC", _DONT_CLEAR_ )
     Dos( "Call TPC " + CurrFileName() )
end

proc mRunFile()

     Dos( SplitPath( CurrFileName(), _NAME_ ) )
end


proc mDelToBol()
    PushBlock()
    UnMarkBlock()
    MarkChar()
    BegLine()
    MarkChar()
    DelBlock()
    PopBlock()
end

proc mUpWord()
    casetype=UPPER_CASE
    PushBlock()
    UnMarkBlock()
    MarkWord()
    ChangeCase( BLOCKCASE )
    PopBlock()
    WordRight()
end

proc mDownWord()
    casetype=LOWER_CASE
    PushBlock()
    UnMarkBlock()
    MarkWord()
    ChangeCase( BLOCKCASE )
    PopBlock()
    WordRight()
end

proc mCapWord()
    casetype=LOWER_CASE
    PushBlock()
    UnMarkBlock()
    MarkWord()
    ChangeCase( BLOCKCASE )
    PopBlock()
    BegWord()
    Flip()
    WordRight()
end

proc mEndLetter()
    EndWord()
    Left()
end

integer proc mQuitFile()
    If ischanged()
       If yesno("Lose Changes? ") == 1
           forcechanged(FALSE)
           quitfile()
       else
           forcechanged(FALSE)
       Endif
    else
        quitfile()
    Endif
    Return(TRUE)
end

proc mGPQuit()
     integer qtp=set(QuitToPrompt,OFF)

     while mquitfile()
           updatedisplay()
     endwhile
     set(QuitToPrompt,qtp)
end

integer proc mSaveSettings()
    If YesNo("Overwrite existing config?") == 1
        Return (iIf(SaveSettings(), TRUE, Warn("Error updating executable")))
    Endif
    Return (FALSE)
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

    If blocktype == 0
        WrapPara()
    else
        Set(Marking, off)               // Stop marking
        If blocktype <> _COLUMN_        // Wrap entire block If not column
            GotoBlockEnd()
            AddLine()
            GotoBlockBegin()
            repeat
            until (not WrapPara()) or (not isCursorInBlock())
            If CurrLineLen() == 0
                DelLine()
            Endif
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
        Endif
    Endif
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

    If Query(BufferType) == _NORMAL_ and GotoBufferId(pick_buffer)
        mk = Set(KillMax, 0)
        If lFind(fn, "^$g")
            DelLine()
        elseIf NumLines() > 20
            EndFile()
            DelLine()
        Endif
        BegFile()
        InsertLine(fn)
        GotoBufferId(cid)
        Set(KillMax, mk)
    Endif

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

proc mChangeCurrFilename()
     ChangeCurrFilename()
     SaveFile()
end

proc mSaveAllPositions()
     string s1[40], s2[40], s3[40]
     integer i = 0

     s1 = CurrFilename()
     s3 = CurrExt()
     if s3 == ".$e$"
         NextFile()
         s1 = CurrFilename()
     endif

     Repeat

          NextFile()
          s2 = CurrFilename()
          s3 = CurrExt()
          if s3 == ".$e$"
              NextFile()
              s2 = CurrFilename()
              i = i + 1
          endif
          if Goto_Pos
              mWriteLastPosition()
          endif

     Until s1 == s2 or i == 2

end

proc mSaveFile()
     if Goto_Pos
         mWriteLastPosition()
     endif
     SaveFile()
end

proc mSaveAndQuitFile()
     if Goto_Pos
         mWriteLastPosition()
     endif
     SaveAndQuitFile()
end

proc mSaveAllFiles()

     mSaveAllPositions()
     SaveAllFiles()

end

proc mSaveAllAndExit()

     mSaveAllPositions()
     SaveAllAndExit()

end

proc mExit()

     mSaveAllPositions()
     Exit()

end

proc mModifyListing()
     integer i3 = 1

     if ATT_MACRO <> 0

         PushBlock()

         if CurrExt() <> ".i"
            Warn( "Wrong File For This Function" )
            Return()
         endif

         BegFile()
         lReplace( "r22e = -", "r22e = ", "in" )
         BegFile()

         i3 = lFind( "global main", "i" )
         Up()
         DelLine()
         BegLine()
         InsertFile( "..\template.asm" )

         i3 = lFind( "rpint", "i" )
         down()
         i3 = lFind( "rpint", "i" )

         BegLine()
         Down()
         Undelete()
         Down()
         Down()

         UnMarkBlock()
         MarkChar()
         i3 = lFind( " r7e = ", "i" )
         BegLine()
         DelBlock()

         i3 = lFind( "ireturn", "i" )
         down()
         down()

         i3 = 15

         while i3
             DelLine()
             i3 = i3 -1
         endwhile

         PopBlock()

         Message( "File Modifications Complete" )

   endif

end

/**************************************************************************
  This macro is called The firsttime a file is loaded into the editor.
 **************************************************************************/
proc OnFirstEdit()
     string s1[40] = CurrExt()

     if s1 <> ".$e$"
         mGetAndGotoLastPosition()
     endif
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

//  ÉÍÍÍÍÍÍÍÍÍÍÍ»
//  º The Menus º
//  ÈÍÍÍÍÍÍÍÍÍÍÍ¼

Menu FileMenu()
    history

    "[File Menu]"                   ,                       ,   Divide
    ""                              ,                       ,   Divide
    "&Open..."                      ,   EditFile()
    "&Load File"                    ,   EditFile()
    "&Insert..."                    ,   InsertFile()
    ""                              ,                       ,   Divide
    "&Next"                         ,   NextFile()
    "&Previous"                     ,   PrevFile()
    "Load File  "                  ,   EditFile()
    "List Open &Files "            ,   mListOpenFiles()
    "List &Recent  "               ,   mListRecentFiles()
    "Current File"                  ,                       ,   Divide
    "&Save"                         ,  mSaveFile()
    "Save &As..."                   ,  mChangeCurrFilename()
    "Save && Qui&t"                 ,  mSaveAndQuitFile()
    "&Quit"                         ,   QuitFile()
    "&Change Name..."               ,   ChangeCurrFilename()
    "All Files"                     ,                       ,   Divide
    "Sa&ve All"                     ,  mSaveAllFiles()
    "Save All && &Exit"             ,  mSaveAllAndExit()
    "E&xit"                         ,   Exit()
end

Menu NamedClipBoardMenu()
    history

    "[Named Clipboard Menu]"        ,                       ,   Divide
    ""                              ,                       ,   Divide
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

    "[Clipboard Menu]"        ,                       ,   Divide
    ""                              ,                       ,   Divide
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

    "[Window Menu]"                 ,                       ,   Divide
    ""                              ,                       ,   Divide
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

    "[Block Menu]"              ,                       ,   Divide
    ""                          ,                       ,   Divide
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

    "[Search Menu]"             ,                       ,   Divide
    ""                          ,                       ,   Divide
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
            "SpecIfies what to print at top of each page"
    "&Footer"                   [Query(PrintFooter):4],
            GetFooter(),
            DontClose,
            "SpecIfies what to print at bottom of each page"
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

    "[Print Menu]"              ,                       ,   Divide
    ""                          ,                       ,   Divide
    "&All"                  ,   PrintFile()
    "&Block"                ,   PrintBlock()
    "Send &Formfeed"        ,   mSendFormFeed()
    "Send &Init String"     ,   mSendInitString(),  DontClose
    "Set &Options  "       ,   PrintConfig(),      DontClose
end PrintMenu

Menu MacroMenu()
    Title = "Keyboard Macros"
    history


    "[Macro Menu]"              ,                       ,   Divide
    ""                          ,                       ,   Divide
    "&Record"                       ,   RecordKeyMacro()
    "&Save..."                      ,   SaveKeyMacro()
    "Loa&d..."                      ,   LoadKeyMacro()
    "Run Scrap &Macro"              ,   ExecScrapMacro()
    "Pur&ge"                        ,   PurgeKeyMacro()
    "Compiled Macros"               ,                   ,   Divide
    "&Execute..."                   ,   mMacMenu(1)
    "&Load..."                      ,   mMacMenu(2)
    "&Purge..."                     ,   mMacMenu(3)
    "&Compile"                      ,   mCompile()
end

Menu TextMenu()
    history


    "[Text Menu]"              ,                       ,   Divide
    ""                          ,                       ,   Divide
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

    "[Utility Menu]"              ,                       ,   Divide
    ""                          ,                       ,   Divide
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

    "[Options Menu]"        ,                       ,   Divide
    ""                              ,                       ,   Divide
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
    "&Full Configuration  ",          ExecMacro("iconfig"),DontClose
    "&Save Current Settings",       mSaveSettings()
end

MenuBar MainMenu()
    history

    "&File"      ,    FileMenu()
    "&Block"     ,    BlockMenu()
    "&Text"      ,    TextMenu()
    "&Search"    ,    SearchMenu()
    "&Window"    ,    WindowMenu()
    "&ClipBoard" ,    ClipboardMenu()
    "&Macro"     ,    MacroMenu()
    "&Print"     ,    PrintMenu()
    "&Utility"   ,    UtilMenu()
    "&Options"   ,    ReconfigMenu()
end

// Mouse functions:

proc mLeftBtn()
    If not ProcessHotSpot()
       MainMenu()
    Endif
end

proc mTrackMouseCursor()
    If GotoMouseCursor()
        TrackMouseCursor()
    Endif
end

proc mChangeVideoMode()
     case Query(CurrVideoMode)
          when _25_LINES_
               Set(CurrVideoMode, _28_LINES_ )
               Message( "Screen Set To 28 Line Display" )

          when _28_LINES_
               Set(CurrVideoMode, _43_LINES_ )
               Message( "Screen Set To 43 Line Display" )

          when _43_LINES_
               Set(CurrVideoMode, _50_LINES_ )
               Message( "Screen Set To 50 Line Display" )

          when _50_LINES_
               Set(CurrVideoMode, _25_LINES_ )
               Message( "Screen Set To 25 Line Display" )
     endcase
end


help helptext

"  ÕÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¸  "
"  ³         Semware Editor With Word-Star/Borland IDE Like Commands        ³  "
"  ÆÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍµ  "
"  ³ <Escape>          ³ MainMenu       ³ <BackSpace>       ³ BackSpace     ³  "
"  ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´ <Ctrl BackSpace>  ³ DelLeftWord   ³  "
"  ³ <Ctrl CursorRight>³ WordRight      ³ <Alt BackSpace>   ³ mDelToBol     ³  "
"  ³ <Ctrl CursorLeft> ³ WordLeft       ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´  "
"  ³ <Ctrl CursorUp>   ³ ScrollUp       ³ <Del>             ³ DelChar       ³  "
"  ³ <Ctrl CursorDown> ³ ScrollDown     ³ <Shift Del>       ³ Cut           ³  "
"  ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´ <Ctrl Del>        ³ DelToEol      ³  "
"  ³ <Ctrl 1>          ³ Shift Line LeftÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´  "
"  ³ <Ctrl 2>          ³ Shift Line Rght³ <Ins>             ³ ToggleInsert  ³  "
"  ³ <Ctrl 3>          ³ Upper Case Let.³ <Shift Ins>       ³ Paste         ³  "
"  ³ <Ctrl 4>          ³ Lower Case Let.³ <Ctrl Ins>        ³ Copy          ³  "
"  ³ <Ctrl 5>          ³ Upper Word     ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´  "
"  ³ <Ctrl 6>          ³ Lower Word     ³ <Tab>             ³ TabRight      ³  "
"  ³ <Ctrl 7>          ³ Beg Of Word    ³ <Shift Tab>       ³ TabLeft       ³  "
"  ³ <Ctrl 8>          ³ Lst Ltr of Word³ <Ctrl Tab>        ³ PrevFile      ³  "
"  ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´ <Alt Tab>         ³ NextFile      ³  "
"  ³ <Ctrl Home>       ³ BegWindow      ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´  "
"  ³ <Ctrl End>        ³ EndWindow      ³ <enter>           ³ CReturn       ³  "
"  ³ <Ctrl PgUp>       ³ BegFile        ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´  "
"  ³ <Ctrl PgDn>       ³ EndFile        ³ <Alt [>           ³ Scroll Left   ³  "
"  ³ <Center Cursor>   ³ Make Center    ³ <Alt ]>           ³ Scroll Right  ³  "
"  ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´  "
"  ³ <Ctrl [>          ³ LockedPageUp   ³ <Grey*>           ³ Paste         ³  "
"  ³ <Ctrl ]>          ³ LockedPageDown ³ <Grey+>           ³ Copy          ³  "
"  ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´ <Grey->           ³ Cut           ³  "
"  ³ <Ctrl a>          ³ Ascii Chart    ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´  "
"  ³ <Ctrl b>          ³ Word Wrap Para ³ <Ctrl k><b>       ³ Mark Block    ³  "
"  ³ <Ctrl c>          ³ Center Line    ³ <Ctrl k><c>       ³ Copy Block    ³  "
"  ³ <Ctrl d>          ³ Date Stamp     ³ <Ctrl k><d>       ³ Save And Exit ³  "
"  ³ <Ctrl g><0>-<9>   ³ Goto Mark 0-9  ³ <Ctrl k><e>       ³ EditFile      ³  "
"  ³ <Ctrl i>          ³ Tab Right      ³ <Ctrl k><f>       ³ Dos           ³  "
"  ³ <Ctrl u>          ³ Undelete       ³ <Ctrl k><i>       ³ Shift         ³  "
"  ³ <Ctrl j>          ³ Goto Line No.  ³ <Ctrl k><k>       ³ Mark Block    ³  "
"  ³ <Ctrl l>          ³ Repeat Find    ³ <Ctrl k><l>       ³ Mark Line     ³  "
"  ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´ <Ctrl k><r>       ³ Insert File   ³  "
"  ³ <Ctrl o><c>       ³ Center Line    ³ <Ctrl k><t>       ³ Mark Word     ³  "
"  ³ <Ctrl o><g>       ³ Resize Window  ³ <Ctrl k><h>       ³ Unmark Block  ³  "
"  ³ <Ctrl o><h>       ³ Horiz. Window  ³ <Ctrl k><n>       ³ Toggle Column ³  "
"  ³ <Ctrl o><i>       ³ AutoIndent Mode³ <Ctrl k><p>       ³ Print Block   ³  "
"  ³ <Ctrl o><n>       ³ Next Window    ³ <Ctrl k><q>       ³ Quit File     ³  "
"  ³ <Ctrl o><o>       ³ One Window     ³ <Ctrl k><s>       ³ Save File     ³  "
"  ³ <Ctrl o><p>       ³ Previous Window³ <Ctrl k><v>       ³ Move Block    ³  "
"  ³ <Ctrl o><v>       ³ Vert. Window   ³ <Ctrl k><w>       ³ Save Block    ³  "
"  ³ <Ctrl o><w>       ³ WordWrap Mode  ³ <Ctrl k><x>       ³ Save And Exit ³  "
"  ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´ <Ctrl k><y>       ³ Delete Block  ³  "
"  ³ <Ctrl q><a>       ³ Replace        ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´  "
"  ³ <Ctrl q><b>       ³ Goto Block Beg.³ <Ctrl p>          ³ Literal       ³  "
"  ³ <Ctrl q><c>       ³ End File       ³ <Ctrl m>          ³ Compile TPC   ³  "
"  ³ <Ctrl q><d>       ³ End Line       ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´  "
"  ³ <Ctrl q><f>       ³ Find           ³ <Ctrl s><0>-<9>   ³ Set Mark 0-9  ³  "
"  ³ <Ctrl q><g>       ³ Find Char (T)  ³ <Ctrl t>          ³ Del Right Word³  "
"  ³ <Ctrl q><h>       ³ Find Char (F)  ³ <Ctrl u>          ³ Undelete      ³  "
"  ³ <Ctrl q><k>       ³ Goto Block End ³ <Ctrl v>          ³ 50 Line Dsplay³  "
"  ³ <Ctrl q><l>       ³ Restore Line   ³ <Ctrl y>          ³ Delete Line   ³  "
"  ³ <Ctrl q><o>       ³ Date Time StampÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´  "
"  ³ <Ctrl q><p>       ³ Prev Position  ³ <Alt a>           ³ Mark Stream   ³  "
"  ³ <Ctrl q><q>       ³ Repeat Command ³ <Alt c>           ³ Copy Block    ³  "
"  ³ <Ctrl q><r>       ³ Beg File       ³ <Alt e>           ³ Edit File     ³  "
"  ³ <Ctrl q><s>       ³ End File       ³ <Alt f>           ³ File Menu     ³  "
"  ³ <Ctrl q><y>       ³ Del To Eol     ³ <Alt g>           ³ Delete Block  ³  "
"  ³ <Ctrl q><del>     ³ Del To Bol     ³ <Alt h>           ³ Show Help     ³  "
"  ³ <Ctrl q><Ctrl [>  ³ Match          ³ <Alt k>           ³ Mark Column   ³  "
"  ³ <Ctrl q><Ctrl ]>  ³ Match          ³ <Alt m>           ³ Move Block    ³  "
"  ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´ <Alt n>           ³ Next File     ³  "
"  ³ <Alt 0>           ³ mListOpenFiles ³ <Alt o>           ³ Change File   ³  "
"  ³ <Alt 1>           ³ GotoWindow(1)  ³ <Alt p>           ³ Print Menu    ³  "
"  ³ <Alt 2>           ³ GotoWindow(2)  ³ <Alt q>           ³ Global Quit   ³  "
"  ³ <Alt 3>           ³ GotoWindow(3)  ³ <Alt r>           ³ Insert File   ³  "
"  ³ <Alt 4>           ³ GotoWindow(4)  ³ <Alt s>           ³ Save And Exit ³  "
"  ³ <Alt 5>           ³ GotoWindow(5)  ³ <Alt u>           ³ User Screen   ³  "
"  ³ <Alt 6>           ³ GotoWindow(6)  ³ <Alt w>           ³ Save Block    ³  "
"  ³ <Alt 7>           ³ GotoWindow(7)  ³ <Alt x>           ³ Exit          ³  "
"  ³ <Alt 8>           ³ GotoWindow(8)  ³ <Alt z>           ³ Copy OverBlock³  "
"  ³ <Alt 9>           ³ GotoWindow(9)  ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´  "
"  ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´ <Ctrl f2>         ³ LineTypeMenu  ³  "
"  ³ <f1>              ³ Show Help      ³ <Ctrl f9>         ³ Shell         ³  "
"  ³ <f2>              ³ Flip Right     ³ <Ctrl f10>        ³ Dos           ³  "
"  ³ <f3>              ³ Cap Word Right ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´  "
"  ³ <f4>              ³ Del Word Go Dwn³ <Shift f1>        ³ Chng Vid Mode ³  "
"  ³ <f6>              ³ Dup. Line      ³ <Shift f2>        ³ Line Draw Mode³  "
"  ³ <f7>              ³ Prev File      ³ <Shift f3>        ³ RecordKeyMacro³  "
"  ³ <f8>              ³ Next File      ³ <Shift f5>        ³ ScrollToRow(Qu³  "
"  ³ <f9>              ³ Mark Mode On   ³ <Shift f6>        ³ ScrollToRow(1)³  "
"  ³ <f10>             ³ Unmark Block   ³ <Shift f7>        ³ mShiftBlock(0)³  "
"  ³ <f11>             ³ Change Video   ³ <Shift f8>        ³ mShiftBlock(1)³  "
"  ³ <f12>             ³ Toggle LineDraw³ <Shift f9>        ³ DelBlock      ³  "
"  ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´  "
"  ³ <LeftBtn>         ³ Mark Left Btn  ³ <Alt f2>          ³ InsertLine    ³  "
"  ³ <Ctrl LeftBtn>    ³ Mouse Marking  ³ <Alt f3>          ³ EditFile      ³  "
"  ³ <Alt LeftBtn>     ³ Mouse Marking  ³ <Alt f4>          ³ mMatch        ³  "
"  ³ <Shift LeftBtn>   ³ Track Mouse Crs³ <Alt f5>          ³ RollLeft      ³  "
"  ³ <RightBtn>        ³ ClipBoardMenu  ³ <Alt f6>          ³ RollRight     ³  "
"  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  "



end

integer column_mode

proc mMarkBlock()

    if Query(BlockID) == 0
       Message("Block Start Defined")
    Elseif Query(Marking) > 0
       Message( "Block End Defined" )
    Elseif isCursorInBlock() > 0
       Message( "Starting New Block Definition")
    Else Message( "Redefining Block End")
    Endif

    If column_mode
        MarkColumn()
    else
        MarkChar()
    Endif
end

proc mUnMarkBlock()
    If Query(BlockID)
       Message( "Block Unmarked" )
    Endif
    UnMarkBlock()
end


proc mToggleColumnMode()
    column_mode = column_mode ^ 1
    Message("Column marking turned ", iIf(column_mode, "on", "off"))
end

proc mFindChar(integer dir)
    string c[1] = ''

    Message(iIf(dir, "", ""), " Find what character:")
    VGotoxy(Wherex(), Wherey())
    If Read(c)
        If not lFind(c, iIf(dir, "i", "ib"))
            Message("not found")
            Alarm()
        Endif
    Endif
end


proc mLeft()
    If CurrCol() == 1
       Up()
       EndLine()
    else
       left()
    Endif
end

proc mBackspace()

    integer C_Col, E_Col, C_Off

    C_Off = CurrXOffset()
    C_Col = CurrCol()
    EndLine()
    E_Col = CurrCol()
    GotoColumn(C_Col)

    mLeft()
    if C_Col <= E_Col
        mDelChar()
    Endif

    If Query(Insert) == 0 and C_Col > 1
       ToggleInsert()
       InsertText(" ")
       mLeft()
       ToggleInsert()
    Endif
    GotoXoffset(C_Off)

end

proc mTabRight()
   if isCursorInBlock() and Query( Insert ) 
       mShiftBlock( 4 )
   else
       TabRight()
   endif
end

proc mTabLeft()
   if isCursorInBlock() and Query( Insert )
       mShiftBlock( -4 )
   else
       TabLeft()
   endif
end

<HelpLine>       "{F1}-Help {F2}-ChgCase {F3}-CapWord {F4}-DelToCsr {F6}-DupLn {F7/F8}-NextFile {F9/F10}-Block"
<Alt HelpLine>   "{F2}-InsLine {F3}-EditFile {F4}-Match {F5}-RollLeft {F5}-RollRight"
<Ctrl HelpLine>  "{F1}-Sort {F2}-LineMenu {F9}-Shell {F10}-MS-DOS"
<Shift HelpLine> "{F1}-VidMode {F2}-LineMode {F3}-MacroRec {F5}-VCenter {F6}-VTop {F7/F8}-ShftBlk {F9}-DelBlk"

<escape>                MainMenu()

<CursorLeft>            mLeft()
<CursorRight>           Right()
<CursorUp>              Up()
<CursorDown>            Down()

<Ctrl CursorRight>      WordRight()
<Ctrl CursorLeft>       WordLeft()
<Ctrl CursorUp>         ScrollUp()
<Ctrl CursorDown>       ScrollDown()

<Ctrl 1>               mShiftBlock(-1)
<Ctrl 2>               mShiftBlock(1)
<Ctrl 3>               mUpLetter()
<Ctrl 4>               mDownLetter()
<Ctrl 5>               mUpWord()
<Ctrl 6>               mDownWord()
<Ctrl 7>                BegWord()
<Ctrl 8>               mEndLetter()

<CenterCursor>          ScrollToRow(Query(WindowRows)/2)

<home>                  BegLine()
<end>                   EndLine()
<PgUp>                  PageUp()
<PgDn>                  PageDown()

<Ctrl home>             BegWindow()
<Ctrl end>              EndWindow()
<Ctrl PgUp>             BegFile()
<Ctrl PgDn>             EndFile()

<BackSpace>            mBackSpace()
<Ctrl BackSpace>        DelLeftWord()
<Alt BackSpace>        mDelToBol()

<Del>                  mDelChar()
<Ctrl Del>              DelToEol()

<Ins>                   ToggleInsert()
<Ctrl Ins>              Copy()

<Tab>                  mTabRight()
<Shift Tab>            mTabLeft()
<Ctrl Tab>              PrevFile()
<Alt Tab>               NextFile()

<enter>                mCReturn()

<Grey*>                 Paste()
<Grey+>                 Copy()
<Grey->                 Cut()

<Ctrl [>               mLockPageUp()
<Ctrl ]>               mLockPageDown()

<Alt [>                 ScrollLeft()
<Alt ]>                 ScrollRight()

<Ctrl a>               mAsciiChart()
<Ctrl b>               mWrapPara()
<Ctrl c>               mCenterLine()
<Ctrl d>               mDateTimeStamp()

<Ctrl g><0>             GotoMark("q")
<Ctrl g><1>             GotoMark("r")
<Ctrl g><2>             GotoMark("s")
<Ctrl g><3>             GotoMark("t")
<Ctrl g><4>             GotoMark("u")
<Ctrl g><5>             GotoMark("v")
<Ctrl g><6>             GotoMark("w")
<Ctrl g><7>             GotoMark("x")
<Ctrl g><8>             GotoMark("y")
<Ctrl g><9>             GotoMark("z")

<Ctrl i>                TabRight()
<Ctrl u>                UnDelete()
<Ctrl j>                GotoLine()

<Ctrl k><b>            mMarkBlock()
<Ctrl k><c>             CopyBlock()
<Ctrl k><d>             SaveAndQuitFile()
<Ctrl k><e>             EditFile()
<Ctrl k><f>             Dos()
<Ctrl k><i>            mShift()
<Ctrl k><k>            mMarkBlock()
<Ctrl k><l>             MarkLine()
<Ctrl k><r>             InsertFile()
<Ctrl k><t>             MarkWord()
<Ctrl k><h>             UnmarkBlock()
<Ctrl k><n>            mToggleColumnMode()
<Ctrl k><p>             PrintBlock()
<Ctrl k><q>             QuitFile()
<Ctrl k><s>             SaveFile()
<Ctrl k><v>             MoveBlock()
<Ctrl k><w>             SaveBlock()
<Ctrl k><x>             SaveAndQuitFile()
<Ctrl k><y>             DelBlock()

<Ctrl l>                RepeatFind()
<Ctrl m>               mCompileTPC()

<Ctrl o><c>            mCenterLine()
<Ctrl o><g>             ResizeWindow()
<Ctrl o><h>            mHWindow()
<Ctrl o><i>             Set(AutoIndent, iIf(Query(AutoIndent), 0, 1))
<Ctrl o><n>             NextWindow()
<Ctrl o><o>             OneWindow()
<Ctrl o><p>             PrevWindow()
<Ctrl o><v>            mVWindow()
<Ctrl o><w>             Toggle(WordWrap)

<Ctrl p>                Literal()

<Ctrl q><a>             Replace()
<Ctrl q><b>             GotoBlockBegin()
<Ctrl q><c>             EndFile()
<Ctrl q><d>             EndLine()
<Ctrl q><f>             Find()
<Ctrl q><g>            mFindChar(TRUE)
<Ctrl q><h>            mFindChar(FALSE)
<Ctrl q><k>             GotoBlockEnd()
<Ctrl q><l>             RestoreCursorLine()
<Ctrl q><o>            mDateTimeStamp()
<Ctrl q><p>             PrevPosition()
<Ctrl q><q>             RepeatCmd()
<Ctrl q><r>             BegFile()
<Ctrl q><s>             EndFile()

<Ctrl q><y>             DelToEol()
<Ctrl q><del>          mDelToBol()
<Ctrl q><Ctrl [>       mMatch()
<Ctrl q><Ctrl ]>       mMatch()

<Ctrl r>               mRunFile()

<Ctrl s><0>             PlaceMark("q")
<Ctrl s><1>             PlaceMark("r")
<Ctrl s><2>             PlaceMark("s")
<Ctrl s><3>             PlaceMark("t")
<Ctrl s><4>             PlaceMark("u")
<Ctrl s><5>             PlaceMark("v")
<Ctrl s><6>             PlaceMark("w")
<Ctrl s><7>             PlaceMark("x")
<Ctrl s><8>             PlaceMark("y")
<Ctrl s><9>             PlaceMark("z")

<Ctrl t>                DelRightWord()
<Ctrl u>                UnDelete()
<Ctrl v>                Set(CurrVideoMode, _50_LINES_ )
<Ctrl y>                DelLine()

<Alt a>                 MarkStream()
<Alt c>                 CopyBlock()
<Alt e>                 EditFile()
<Alt f>                 FileMenu()
<Alt g>                 DelBlock()
<Alt h>                 ShowHelp(HelpText)
<Alt k>                 MarkColumn()

<Alt l>                mModifyListing()

<Alt m>                 MoveBlock()
<Alt n>                 NextFile()
<Alt o>                mChangeCurrFilename()
<Alt p>                 PrintMenu()
<Alt q>                mGPQuit()
<Alt r>                 InsertFile()
<Alt s>                mSaveAllAndExit()
<Alt u>                 ShowEntryScreen()
<Alt w>                 SaveBlock()
<Alt x>                mExit()
<Alt z>                 CopyBlock(_OVERWRITE_)

<Alt 0>                mListOpenFiles()
<Alt 1>                 GotoWindow(1)
<Alt 2>                 GotoWindow(2)
<Alt 3>                 GotoWindow(3)
<Alt 4>                 GotoWindow(4)
<Alt 5>                 GotoWindow(5)
<Alt 6>                 GotoWindow(6)
<Alt 7>                 GotoWindow(7)
<Alt 8>                 GotoWindow(8)
<Alt 9>                 GotoWindow(9)


<f1>                    ShowHelp(HelpText)
<f2>                   mFlipRight()
<f3>                   mCapWord()
<f4>                   mDelWordThenDown()
<f6>                    DupLine()
<f7>                    PrevFile()
<f8>                    NextFile()
<f9>                   mMarkBlock()
<f10>                  mUnMarkBlock()
<f11>                  mChangeVideoMode()
<f12>                   Toggle(LineDraw)

<Ctrl f1>               Sort( _IGNORE_CASE_ )
<Ctrl f2>               LineTypeMenu()
<Ctrl f9>               Shell()
<Ctrl f10>              Dos()

<Shift f1>             mChangeVideoMode()
<Shift f2>              Toggle(LineDraw)
<Shift f3>              RecordKeyMacro()
<Shift f5>              ScrollToRow(Query(WindowRows)/2)
<Shift f6>              ScrollToRow(1)
<Shift f7>             mShiftBlock(-1)
<Shift f8>             mShiftBlock(1)
<Shift f9>              DelBlock()

<Alt f2>                InsertLine()
<Alt f3>                EditFile()
<Alt f4>               mMatch()
<Alt f5>                RollLeft()
<Alt f6>                RollRight()


// Mouse keys:

<LeftBtn>               mLeftBtn()
<Ctrl LeftBtn>          MouseMarking(_COLUMN_)
<Alt LeftBtn>           MouseMarking(_LINE_)
<Shift LeftBtn>         mTrackMouseCursor()
<RightBtn>              ClipBoardMenu()
