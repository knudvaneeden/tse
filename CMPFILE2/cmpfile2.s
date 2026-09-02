/*************************************************************************
  CmpFiles    Compares the current file to a backup file

  Author:     Ian Campbell (Contributing User)

  Date:       Jun 16, 1993 (Original: Ian Campbell)
              Jul 15, 1994 (Revised: Ian Campbell)
              Nov 21, 1996 (Revised: Chris Antos)
                    Fix w32 problems including long filenames.

                    Add a shortcut so that if you just type in a path
                    instead of a filename, it will look in that path for the
                    same filename you already have loaded.

              Set 11, 1997 (Flavio Suarez)
                    NEW procedure mCompLines():  Compares the first 250 characters
                    of current lines.
                    From the procedure CompLines() in TSEComp macro.
                    Key:  <Ctrl Enter>
                    Help updated

              Fev 12, 1998 (Flavio Suarez)
                    NEW feature:  Left/Right scroll for each window.
                    Keys: <Ctrl CursorLeft/Right>
                    Help updated

                    Enhancement to mCompLines()
                    Now also compares the current lines starting at the first visible
                    characters of each line (try it after use the new Left/Right Scroll
                    feature).
                    Key:  <Ctrl Shift Enter>
                    Help updated

              Mar 03, 1999 (Flavio Suarez)
                    NEW option:  Ignore case.
                    Key: <I>
                    Help updated

              Jun 14, 2002 (Flavio Suarez - flaviosuarez@ieg.com.br)
                    Added some #ifdef WIN32 and use of the new video command PutOemStrXY()
                    for correct display in TSE Pro 4 Test Drive version.
                    Now, this macro works in TSE Pro v2.5e and v4 Test Drive versions.

                    The documentation was translated from brazilian
                    portuguese to english.

              Jun 18, 2002 (Flavio Suarez - flaviosuarez@ieg.com.br)
                    Due the key assignments of CUAMark macro, I've removed the following
                    navigation keys:
                    <Shift CursorUp>, <Shift CursorDn>, <Shift CursorLeft>, <Shift CursorRight>
                    <Shift PgUp>, <Shift PgDn>
                    These keys no more duplicates the following navigation keys:
                    <Ctrl CursorUp>, <Ctrl CursorDn>, <Ctrl CursorLeft>, <Ctrl CursorRight>
                    <Ctrl PgUp>, <Ctrl PgDn>

  Version:    1.04

  Overview:

  The user will be prompted for a backup filename.  This backup file
  may be inside an "ARC", "ARJ", "LZH", or "ZIP" file, or it may be a
  stand alone file.  If the file is inside an archive, then the
  filename must be the same as the current filename.  Note that there
  may be many different files inside the archive, but only the one
  that matches the current filename will be extracted.

  The two files will be split (either vertically or horizontally).
  Cursor movement keystrokes will be fed to both windows so that they
  move simultaneously, in sync with each other.

  Text may be scanned, and differences will be highlighted.

  The video mode may be changed from 25 to 36 to 44 to 50 lines to
  show more detail.

  F1 is available for help.

  Whitespace characters (spaces and tabs) are automatically converted
  to a single space character by default, in an effort to reduce false
  comparisons.  This option may be toggled by pressing the "W" key.

  Once a re-sync has been accomplished, both windows will update to
  the end of the difference text, with the re-synced lines adjacent to
  each other on line 12 of the screen.  Difference text will be marked
  in both windows, for easy comparison.  Press the grey- key to
  retreat to the BEGINNING of the difference text, then press the
  grey+ key to move back to the END of the difference text.  Hit the
  enter again to continue the search process, -- to find and highlight
  the next difference.

  Keys:       (none)

  Usage notes:

  This macro is designed to be run from PROJECTS or may be executed
  directly from Potpourri.  It is automatically purged when done.

  LIMITATIONS: -Line length must be under 250 characters.

               -although whitespace errors will NOT cause files that
                are already in sync to de-sync (unless the whitespace
                filter is turned off), TSE's basic search mechanism is
                used to re-sync, and whitespace cannot be filtered out
                here.  This is usually not too big of an issue unless
                you completely en-tab, or de-tab one of the two files.
                Then re-syncing will NOT take place.

               -Your file decompressor must be in the path, or a "File
                Not Found"  error message will result.

  The usual disclaimer -- Use these macros at your own risk! I will in
  NO WAY be responsible for ANY problems resulting in their use.

*************************************************************************/

#ifdef WIN32
DLL "<kernel32.dll>"
    integer proc GetShortPathName(string long_fn:cstrval,
            var string short_fn:strptr, integer n) : "GetShortPathNameA"
end
#endif


#ifdef WIN32
    constant MAXPATH = 255
#else
    constant MAXPATH = 80
#endif

constant SkipLines = 20         // walk through 20 lines at a time
constant SearchRange = 250      // scan 250 lines at a time
constant ShortRangeScan = 0     // signifies a tight, line by line scan
constant MediumRangeScan = 1    // signifies a somewhat relaxed scan
constant LongRangeScan = 2      // scan entire file, in blocks, for a match
constant NO_VIDEO_FLG = 0       // the video mode is not changing
constant VIDEO_FLG = 1          // the video mode is changing
constant BEGINNING = 0
constant ENDING = 1

// change to FALSE for HORIZONTAL default
constant WinDefaultVert = TRUE  // TRUE = VERTICAL windows default

integer  cmp2bkup_file_history
integer  Depth = 20             // number of consecutive lines that must
                                // match before text is found
integer CID1                    // original file ID
integer CID2                    // backup file ID
integer temp                    // buffer id's

integer EndLine1 = -1           // marking pointer for original file
integer EndLine2 = -1           // marking pointer for backup file
integer BeginLine1 = -1         // marking pointer for original file
integer BeginLine2 = -1         // marking pointer for backup file
integer WinID                   // original Window ID
integer FilterWhiteSpaceFlg = 1 // permission to filter whitespace chars
integer FilterIgnoreCaseFlg = 1 // permission to filter Ignore Case chars
integer MouseState              // 0 = no mouse activity
                                // 1 = first mouse clicked
                                // 2 = autorepeat mouse clicking
String  GS1[255] = ""           // general purpose string number-1
String  GS2[255] = ""           // general purpose string number-2
String  GS3[255] = ""           // general purpose string number-3
String  MyVersion[] = "1.00"

#ifdef WIN32
string proc GetShortFilename(string long_fn)
    string short_fn[MAXPATH] = Format("":sizeof(short_fn))

    GetShortPathName(long_fn, short_fn, sizeof(short_fn))
    return(SubStr(short_fn, 1, Pos(Chr(0), short_fn)-1))
end
#else
string proc GetShortFilename(string fn)
    return(fn)
end
#endif

#ifndef WIN32
string proc QuotePath(string fn)
    return(fn)
end
#endif

/*** mDirExists *********************************************************
 *                                                                      *
 * Check for the existence of a directory and return non zero if it     *
 * does exist.                                                          *
 *                                                                      *
 * Called by:   mGetValidFileName(), mLoadBackupFile()                  *
 *                                                                      *
 * Enter With:  the name of the directory                               *
 *                                                                      *
 * Returns:     non zero if the directory exists                        *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

integer proc mDirExists(string s)
    return(FileExists(s) & _DIRECTORY_)
end mDirExists

/*** FlashMessage *******************************************************
 *                                                                      *
 * Display a flashing message on the top line.  The message will flash  *
 * for the FlashDelay time period, and then stop flashing.              *
 *                                                                      *
 * Called by:   mReplaceBlock(), mCompareToBkup()                       *
 *                                                                      *
 * Enter With:  Message to display, whether or not to update display    *
 *              on exit, the time to flash the message in seconds.      *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc FlashMessage(string Msg, integer Update, integer FlashDelay)
    integer OldMsgAttr, BlinkDelay

    OldMsgAttr = Set(MsgAttr, Query(MsgAttr) | 0x80)
    Message(Msg)
    UpdateDisplay()
    Set(MsgAttr, OldMsgAttr)
    BlinkDelay = GetClockTicks()
    repeat
        ExecHook(_IDLE_)
    until ((GetClockTicks() > BlinkDelay + (FlashDelay * 18))
            or (GetClockTicks() < BlinkDelay)
            or (KeyPressed()))
    Message(Msg)
    if Update
        UpdateDisplay()
    endif
end FlashMessage

/*** mMessageBox ********************************************************
 *                                                                      *
 * Present a message centered on the screen in a box.  The message      *
 * is automatically wrapped to multiple lines if necessary.  The "`"    *
 * character may be used to force a new line if desired.                *
 *                                                                      *
 * Called by:   mChooseProject()                                        *
 *                                                                      *
 * Enter With:  The box tile, and the box contents.                     *
 *                                                                      *
 * Returns:     The keystroke that terminated it.                       *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

integer proc mMessageBox(string BoxTitle, string s, integer ImmediateReturn)
    integer MyID = GetBufferID()
    integer TempBuffer = CreateTempBuffer()
    integer PopX1, PopY1, PopX2, PopY2
    integer OldRightMargin = Set(RightMargin, 72)
    integer WinHeight
    integer OldCursor = Set(Cursor, OFF)
    integer ReturnCode, SizeLongestLine = 0
    integer OldAttr = Set(Attr, Color(BRIGHT WHITE ON BLACK))

    HideMouse()
    InsertText(s)
    BegFile()
    while lFind("`", "")
        DelChar()
        if CurrCol() <> 1
            SplitLine()
        endif
        SplitLine()
    endwhile
    BegFile()
    while WrapPara()
        if CurrLineLen() == 0
            KillLine()
        endif
    endwhile
    Begfile()
    repeat
        if CurrLineLen() > SizeLongestLine
            SizeLongestLine = CurrLineLen()
        endif
    until not Down()
    BegFile()
    if Length(BoxTitle) + 2 > SizeLongestLine
        SizeLongestLine = Length(BoxTitle) + 2
    endif
    BegFile()
    WinHeight = NumLines()
    PopX1 = (((Query(ScreenCols) - (SizeLongestLine)) / 2) - 1)
    PopX2 = PopX1 + SizeLongestLine + 3
    PopY1 = ((Query(ScreenRows) - (WinHeight + 2)) / 2) + 1
    PopY2 = PopY1 + WinHeight + 1
    PopWinOpen(PopX1, PopY1, PopX2, PopY2, 1, BoxTitle, Query(MenuTextLtrAttr))
    ClrScr()
    While CurrLine() < WinHeight
        WriteLine(" " + GetText(1, SizeLongestLine))
        Down()
    endwhile
    Write(" " + GetText(1, SizeLongestLine))
    GotoBufferID(MyID)
    AbandonFile(TempBuffer)
    Set(RightMargin, OldRightMargin)
    Set(Attr, OldAttr)
    ShowMouse()
    if ImmediateReturn
        return(OldCursor)
    endif
    ReturnCode = GetKey()
    PopWinClose()
    Set(Cursor, OldCursor)
    return(ReturnCode)
end mMessageBox

/*** mMinimizeWhiteSpace ************************************************
 *                                                                      *
 * Used to reduce multiple consecutive whitespace characters (tabs and  *
 * spaces) to a single space character in order to eliminate false      *
 * alarms when comparing lines of text.                                 *
 *                                                                      *
 * Called by: mGS1EqualsGS2()                                           *
 * Returns:   Nothing directly, but updates Var string GS               *
 * Notes:     Uses string GS3 as a temporary scratch string.            *
 *                                                                      *
 ************************************************************************/

proc mMinimizeWhiteSpace(Var string GS)
    integer i = 1, j, WhiteFlg = 0
    constant space = 0x20, tab = 0x09

    j = Length(GS)
    GS3 = ""
    while i <= j
        // look for a whitespace character
        if GS[i] == chr(space) or GS[i] == chr(tab)     // whitespace?
            WhiteFlg = 1                // flag it for later space insertion
        else                            // a non whitespace character
            if WhiteFlg
                WhiteFlg = 0
                GS3 = GS3 + chr(space)  // copy previous whitespace as a space
            endif
            GS3 = GS3 + GS[i]           // copy the character
        endif
        i = i + 1
    endwhile
    GS = GS3                            // return the string
end mMinimizeWhiteSpace

/*** mGS1EqualsGS2 ******************************************************
 *                                                                      *
 * Compares two global strings -- GS1 and GS2.  If they are equal,      *
 * return TRUE, if not, strip off superfluous whitespace, and repeat    *
 * the comparison.                                                      *
 *                                                                      *
 * Called by: mCheckMultiLine(), mFindTextLine(),                       *
 *            mFindFirstLineMatch(), mSearchTwoFiles()                  *
 *                                                                      *
 * Returns:   TRUE if the two strings compare, FALSE otherwise.         *
 * Notes:     None                                                      *
 *                                                                      *
 ************************************************************************/

integer proc mGS1EqualsGS2()

    if FilterIgnoreCaseFlg
        if (Upper(GS1) == Upper(GS2))
            return(TRUE)
        endif
    else
        if (GS1 == GS2)
            return(TRUE)
        endif
    endif

    if FilterWhiteSpaceFlg
        mMinimizeWhiteSpace(GS1)        // remove dup whitespace from GS1
        mMinimizeWhiteSpace(GS2)        // remove dup whitespace from GS2
    endif

    if FilterIgnoreCaseFlg                            // try the compare again!
        if (Upper(GS1) == Upper(GS2))
            return(TRUE)
        endif
    endif

    return (GS1 == GS2)                 // try the compare again!

end mGS1EqualsGS2

/*** mCheckMultiLine ****************************************************
 *                                                                      *
 * If a single line comparison between the two files is TRUE, then      *
 * mCheckMultiLine() will be called to see if more than one line        *
 * matches.  mCheckMultiLine() checks up to "Depth" (a global) lines    *
 * and all must match before TRUE will be returned.  The first mismatch *
 * causes FALSE to be returned.                                         *
 *                                                                      *
 * Called by: mFindTextLine(), mFindFirstLineMatch()                    *
 *                                                                      *
 * Returns:   TRUE if all lines match, FALSE otherwise.                 *
 * Notes:     None                                                      *
 *                                                                      *
 ************************************************************************/

integer proc mCheckMultiLine()
    integer i, ReturnCode = TRUE, IDComingIn = GetBufferID()

    GotoBufferID(CID1)
    PushPosition()
    GotoBufferID(CID2)
    PushPosition()
    i = 1
    while i <= Depth            // match all lines
        GotoBufferID(CID1)      // go to first window
        Down()
        GS1 = GetText(1, 255)   // read text one line down
        GotoBufferID(CID2)      // go back to second window
        Down()
        GS2 = GetText(1, 255)
        if not mGS1EqualsGS2()
            ReturnCode = FALSE  // cancel the first line match
            break
        endif
        i = i + 1               // next line to match
    endwhile
    PopPosition()
    GotoBufferID(CID1)
    PopPosition()
    GotoBufferID(IDComingIn)
    Return(ReturnCode)
end mCheckMultiLine

/*** mFindTextLine ******************************************************
 *                                                                      *
 * Get a line of text from window ID "CIDRef1".  Search through         *
 * "MaxLines" of text in Window ID "CIDRef2" for the line.  If the      *
 * line is found, do a CheckMultiLine check to make sure it's the right *
 * one.  Return the line number if it is found and confirmed, -1 if not *
 * found, and -2 if the end of the file is reached.                     *
 *                                                                      *
 * Called by: mSearchForText()                                          *
 *                                                                      *
 * Enter With:  Window ID to get the text from.                         *
 *              Window ID block to scan for the text.                   *
 *              The number of lines to scan for text in the second      *
 *              window.                                                 *
 * Returns:     The line number if line found.                          *
 *              -1 if line not found.                                   *
 *              -2 if end of file reached.                              *
 * Notes:       None                                                    *
 *                                                                      *
 ************************************************************************/

integer proc mFindTextLine(integer CIDRef1, integer CIDRef2,
    integer MaxLines)
    integer Line = -1, MyCID = GetBufferID()

    GotoBufferID(CIDRef1)
    BegLine()
    GS1 = GetText(1, 255)               // read text line from first file
    GotoBufferID(CIDRef2)
    BegLine()
    PushPosition()
    UnMarkBlock()                       // unmark any existing mark
    MarkChar()
    GotoLine(CurrLine() + MaxLines)     // mark a block of MaxLines
    MarkChar()
    PopPosition()
    PushPosition()
    If IsBlockInCurrFile()
        Line = iif (lFind(GS1,"WL"), CurrLine(), -1) // search the block
    else
        //End of file reached, CANNOT synchronize files
        Line = -2
    endif
    if Line > 0
        GS2 = GetText(1, 255)           // do a full line check
        if mGS1EqualsGS2()              // do a full line check
            if not mCheckMultiLine()
                Line = -1
            endif
        else
            Line = -1
        endif
    endif
    PopPosition()
    GotoBufferID(MyCID)
    return(Line)
end mFindTextLine

/*** mPositionText ******************************************************
 *                                                                      *
 * Goto the line just past the difference text for both files.          *
 *                                                                      *
 * Called by: mSearchForText()                                          *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       None                                                    *
 *                                                                      *
 ************************************************************************/

proc mPositionText()
    GotoBufferID(CID1)
    if EndLine1 > 0
        GotoLine(EndLine1)  // position just past the marked text
    endif
    GotoBufferID(CID2)
    if EndLine2 > 0
        GotoLine(EndLine2)  // position just past the marked text
    endif
end mPositionText

/*** mIsEscKeyPressed ***************************************************
 *                                                                      *
 * Provides a mechanism for escaping from a looping macro by pressing   *
 * the escape key.  All keystrokes are emptied from the editors buffer. *
 *                                                                      *
 * Called by: mSearchForText(), mSearchTwoFiles                         *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     TRUE if escape pressed, otherwise FALSE                 *
 *                                                                      *
 * Notes:       As well as detecting whether or not escape has been     *
 *              pressed, this macro also "eats" ALL outstanding         *
 *              keystrokes, whether they're escapes or not!             *
 *                                                                      *
 ************************************************************************/

integer proc mIsEscKeyPressed()
    integer PressedKey = 0

    if KeyPressed()
        while KeyPressed()
            PressedKey = GetKey()
        endwhile
        if PressedKey == <Escape>
            return(TRUE)
        endif
    endif
    return(FALSE)
end mIsEscKeyPressed

/*** mSearchForText *****************************************************
 *                                                                      *
 * Does either a short range, medium range, or a long range search for  *
 * text.  Basically, take a line from the first file, search MaxLines   *
 * through the second file for an exact match, then repeat the process  *
 * by taking a line from the second file, and searching the first file  *
 * for an exact match.  Continue searching until either the text is     *
 * found, the end of a file is reached, or until the while loop         *
 * expires (does not expire for long range scan).  Continue to advance  *
 * through each file as failures occur, either by one line or           *
 * "SkipLines" until a match is found (on either side).  Once a match   *
 * is found, move the cursor back through each file by "SearchRange".   *
 * This allows for a smaller depth value to be used, and also helps     *
 * to ensure that only the first match will be found (by subroutine     *
 * "mFindFirstLineMatch()").  Do NOT go back further than the beginning *
 * point.                                                               *
 *                                                                      *
 * Called by:   mSyncFirstLines()                                       *
 *                                                                      *
 * Enter With:  two integers                                            *
 *                                                                      *
 * Returns:     1 if a match occurs.                                    *
 *              0 if no match found.                                    *
 *             -1 if end of file reached or escape key pressed.         *
 *                                                                      *
 * Notes:       If the files CANNOT be resynced, then the cursor will   *
 *              be placed at the beginning of the differences, and      *
 *              NO difference text will be marked.                      *
 *                                                                      *
 ************************************************************************/

string SyncMessage1[24]
string SyncMessage2[24]
integer proc mSearchForText(integer RangeFlg)
    integer MyLine1, MyLine2, MaxLines1, MaxLines2
    integer UpLines, i = SkipLines, DownLines = SkipLines, DecLoopValue = 1

    EndLine1 = -1                   // invalidate pointer
    EndLine2 = -1                   // invalidate pointer

    GotoBufferID(CID1)              // go to the original file
    GotoLine(BeginLine1)            // start point for file-1
    MaxLines1 = NumLines()          // assume all lines scanned (long range)
    MyLine1 = BeginLine1            // displays line numbers on the message line

    GotoBufferID(CID2)              // go to the backup file
    GotoLine(BeginLine2)            // start point for file-2
    MaxLines2 = NumLines()          // assume all lines scanned (long range)
    MyLine2 = BeginLine2            // displays line numbers on the message line

    case RangeFlg
        when ShortRangeScan
            SyncMessage1 = " <Synchronizing Files>  "
            SyncMessage2 = " >Synchronizing Files<  "
            MaxLines1 = SkipLines
            MaxLines2 = MaxLines1
            DownLines = 1                   // scan every line per miss

        when MediumRangeScan    // if a medium scan, restrict the lines
            SyncMessage1 = "<<Synchronizing Files>> "
            SyncMessage2 = ">>Synchronizing Files<< "
            MaxLines1 = SearchRange
            MaxLines2 = MaxLines1

        when LongRangeScan
            SyncMessage1 = "**Synchronizing Files** "
            SyncMessage2 = "++Synchronizing Files++ "
            DecLoopValue = 0                // never fall out of while loop
    endcase

    while i > 0                             // begin the search
        Message(SyncMessage1, MyLine1)      // show user what and where

        // search through "MaxLines2" lines in the backup file for
        // the current line in the original file
        EndLine2 = mFindTextLine(CID1, CID2, MaxLines2)
        // if a match is not found yet, then compare files the other way...
        if EndLine2 <= 0
            if EndLine2 == -2               // end of file?
                return(-1)
            endif
            Message(SyncMessage2, MyLine2)  // show user what and where

            // search through "MaxLines1" lines in the original file for
            // the current line in the backup file
            EndLine1 = mFindTextLine(CID2, CID1, MaxLines1)
            if EndLine1 == -2               // end of file?
                return(-1)
            endif
        endif
        if EndLine1 > 0 or EndLine2 > 0 // a match on either side?
            mPositionText()             // place cursor where text the same
            GotoBufferID(CID1)          // go to original file

            // set UpLines to either SearchRange + 50, or the distance to
            // where the compare started, whichever is smaller.
            UpLines = Min(CurrLine() - BeginLine1, SearchRange + 50)
            GotoBufferID(CID2)          // go to backup file

            // set UpLines to the distance to where the compare
            // started, if it is smaller than the current UpLines
            UpLines = Min(CurrLine() - BeginLine2, UpLines)
            GotoBufferID(CID1)          // go back to original file
            if UpLines > 0
                Up(UpLines)             // back up for mFindFirstLineMatch()
            endif
            GotoBufferID(CID2)          // go back to backup file
            if UpLines > 0
                Up(UpLines)             // back up for mFindFirstLineMatch()
            endif
            return(1)                   // indicate success
        endif
        GotoBufferID(CID1)              // failure, go to original file
        if not Down(DownLines)          // move down "DownLines" in original
            return(-1)
        endif
        MyLine1 = CurrLine()            // note current line for message line
        GotoBufferID(CID2)              // failure, go to backup file
        if not Down(DownLines)          // move down "DownLines" in backup
            return(-1)
        endif
        MyLine2 = CurrLine()            // note current line for message line
        if mIsEscKeyPressed()           // press escape to abort this search
            return(-1)
        endif
        // short and medium range scans have a limited loop life
        i = i - DecLoopValue
    endwhile
    return(0)                           // fallen out of while loop -- failure
end mSearchForText

/*** mFindFirstLineMatch ************************************************
 *                                                                      *
 * Compare the two files, line by line, until a match is found.  Use    *
 * mCheckMultiLine() to confirm the match to a preset depth.  If a      *
 * match is found, then set EndLine1 and EndLine2 to their respective   *
 * current lines.  Global strings GS1 and GS2 are used to hold the      *
 * text.                                                                *
 *                                                                      *
 * Called by: mSyncFirstLines().                                        *
 *                                                                      *
 * Enter With:  nothing.                                                *
 *                                                                      *
 * Returns:     TRUE if successful, FALSE if not (should ALWAYS be      *
 *              TRUE).                                                  *
 *                                                                      *
 * Notes:       None.                                                   *
 *                                                                      *
 ************************************************************************/

integer proc mFindFirstLineMatch()
    integer i = SearchRange + 51

    EndLine1 = -1
    EndLine2 = -1
    GotoBufferID(CID1)
    Message("Synchronizing Files ")
    while i
        GS1 = GetText(1, 255)           // get text in window-1's file
        GotoBufferID(CID2)
        GS2 = GetText(1, 255)           // get text in window-2's file
        if mGS1EqualsGS2()
            if mCheckMultiLine()
                GotoBufferID(CID1)
                EndLine1 = CurrLine()
                GotoBufferID(CID2)
                EndLine2 = CurrLine()
                return(TRUE)               // success
            endif
        endif
        Down()
        GotoBufferID(CID1)
        Down()
        i = i - 1
    endwhile
    warn ("*** ALGORITHM FAILURE ***  Sorry, but I can't track this part...")
    return(FALSE)                           // failure
end mFindFirstLineMatch

/*** mUpdateWindowOne ***************************************************
 *                                                                      *
 * Updates the new position of the original file into Window-1          *
 *                                                                      *
 * Called by: mSyncFirstLines(), mSearchTwoFiles()                      *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       None                                                    *
 *                                                                      *
 ************************************************************************/

proc mUpdateWindowOne()
    GotoWindow(2)               // make sure in "working window"
    GotoBufferID(CID1)          // go to the original file
    PushPosition()              // keep track of where we are
    GotoWindow(1)               // switch to window where original file goes
    PopPosition()               // Update Window-1 with new file position
    GotoWindow(2)               // back to working window
    GotoBufferID(CID2)          // Put the backup file back in window-2
end mUpdateWindowOne

/*** mSyncFirstLines ****************************************************
 *                                                                      *
 * Window-2 is assumed on entry.  Search both files, mark any           *
 * difference text, and advance to the line just past the difference    *
 * text (right where the two files are resynced).                       *
 *                                                                      *
 * Called by:   mSearchTwoFiles()                                       *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       None                                                    *
 *                                                                      *
 ************************************************************************/

integer proc mSyncFirstLines()
    integer ReturnCode, WarnFlg = 0
    constant MinDepth = 3, MediumDepth = 8, DeepDepth = 25

    GotoBufferID(CID1)              // access the original file
    BeginLine1 = CurrLine()         // mark the beginning line of the compare
    GotoBufferID(CID2)              // access the backup file
    BeginLine2 = CurrLine()         // mark the beginning line of the compare
    Depth = MinDepth                // MinDepth lines must match
    ReturnCode = mSearchForText(ShortRangeScan)
    if ReturnCode <> 1              // not found in short range scan?
        Depth = MediumDepth         // MediumDepth lines must match
        ReturnCode = mSearchForText(MediumRangeScan)
        if ReturnCode <> 1          // not found in medium range scan?
            Depth = DeepDepth       // DeepDepth lines must match
            ReturnCode = mSearchForText(LongRangeScan)
            if ReturnCode <> 1
                WarnFlg = 1
            endif
        endif
    endif
    if ReturnCode == 1              // text found in one of the scans?
        Depth = MinDepth            // MinDepth lines must match

        // home in exactly on a line by line match (note the low depth)
        ReturnCode = mFindFirstLineMatch()
    endif
    if ReturnCode <> -1
        GotoWindow(WinID)
    else
        GotoBufferID(CID1)
        GotoLine(BeginLine1)        // position to first mismatched line
        GotoBufferID(CID2)
        GotoLine(BeginLine2)        // position to first mismatched line
        EndLine1 = -1               // end of file, cancel any marking
        EndLine2 = -1               // end of file, cancel any marking
        UnMarkBlock()               // unmark any block on a failure
    endif
    return(not WarnFlg)
end mSyncFirstLines

/*** mCenterBothWindows *************************************************
 *                                                                      *
 * Center both windows vertically, restore any horizontal Xoffset,      *
 * and update the display.                                              *
 *                                                                      *
 * Called by:   mSearchTwoFiles(), mToggleWindowTypes()                 *
 *                                                                      *
 * Enter With:  the Xoffset requirements for both windows               *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       None                                                    *
 *                                                                      *
 ************************************************************************/

proc mCenterBothWindows(integer MyXoffset1, integer MyXoffset2)
    GotoWindow(1)
    if CurrCol() < MyXoffset1 + 1
        GotoColumn(MyXoffset1 + 1)
    endif
    GotoXoffset(MyXoffset1)             // move whole screen horizontally
    ScrollToRow(Query(WindowRows) / 2)  // center the cursor line vertically

    GotoWindow(2)
    if CurrCol() < MyXoffset2 + 1
        GotoColumn(MyXoffset2 + 1)
    endif
    GotoXoffset(MyXoffset2)             // move whole screen horizontally
    ScrollToRow(Query(WindowRows) / 2)  // center the cursor line vertically
end mCenterBothWindows

/*** PopWinCentered *****************************************************
 *                                                                      *
 * This macro opens up a Popup Window, and centers it on the screen.    *
 * The co-ordinates of the window are stored globally in PopX1, PopX2,  *
 * PopY1, and PopY2.                                                    *
 *                                                                      *
 * Called by:   mShowClipboardHelp()                                    *
 *                                                                      *
 * Enter With:  Width, height, box type, and window message.            *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       PopX1, PopX2, PopY1, and PopY2 are globally made        *
 *              available for other routines who want to know the       *
 *              popup window's dimensions.                              *
 *                                                                      *
 ************************************************************************/

integer PopX1, PopY1, PopX2, PopY2
proc mPopWinCentered(integer WinWidth, integer WinHeight, integer BoxType,
    string BoxMessage, integer WindowColor)

    PopX1 = ((Query(ScreenCols) - WinWidth) / 2) + 1
    PopX2 = PopX1 + WinWidth - 1
    PopY1 = ((Query(ScreenRows) - WinHeight) / 2) + 1
    if PopY1 == 1
        PopY1 = 2
    endif
    PopY2 = PopY1 + WinHeight - 1
    PopWinOpen(PopX1, PopY1, PopX2, PopY2, BoxType, BoxMessage, WindowColor)
end mPopWinCentered

/*** mScanningFilesMsg **************************************************
 *                                                                      *
 * This macro opens a box on the screen while actively comparing the    *
 * two files.                                                           *
 *                                                                      *
 * Called by:   mSearchTwoFiles()                                       *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mScanningFilesMsg()
    Set(Attr, Query(TextAttr))
    mPopWinCentered(43, 6, 4, "MESSAGE",        // open up a centered box
        Query(CurrWinBorderAttr))
    ClrScr()
    WriteLine(" Comparing original file to backup file.")
        Write(" Line Differences will be ")
        Set(Attr, Query(BlockAttr))
        Write("HILITED")
        Set(Attr, Query(TextAttr))
    WriteLine(".")
    WriteLine("")
    Write(' Please wait...')
end mScanningFilesMsg

/*** mSearchTwoFiles ****************************************************
 *                                                                      *
 * Do a line by line compare of the two files, hilite blocks of         *
 * difference text in each file, and resync the two files.              *
 *                                                                      *
 * Called by:   mProcessKeystrokes                                      *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       None                                                    *
 *                                                                      *
 ************************************************************************/

integer proc mSearchTwoFiles()
    integer MyXoffset1, MyXoffset2, i = 0, EscapeKeyIsPressed = FALSE
    integer OldCursor, n, m, ReturnCode = 1

    OldCursor = Set(Cursor, OFF)
    WinID = WindowID()              // save the current window ID
    GotoWindow(1)
    n = NumLines()
    MyXoffset1 = CurrXoffset()      // save the Xoffset
    GotoWindow(2)                   // switch to the first window
    m = NumLines()
    if (m < n)
        n = m
    endif
    MyXoffset2 = CurrXoffset()      // save the Xoffset
    GotoBufferID(CID2)              // make sure backup file in window-2
    mScanningFilesMsg()             // tell the user what we're up to
    loop                            // permanent loop
        i = i + 1
        GS1 = GetText(1, 255)       // get text, current line, backup file
        GotoBufferID(CID1)          // switch to original file

        if ( FilterIgnoreCaseFlg and Upper(GS1) <> Upper( GetText(1, 255))) or
           GS1 <> GetText(1, 255)

            GS2 = GetText(1, 255)   // get text, current line, original file
            if not mGS1EqualsGS2()  // check with whitespace
                mUpdateWindowOne()  // update window one's position
                GotoWindow(WinID)   // restore the original window
                ReturnCode = mSyncFirstLines()  // mark difference and resync
                mUpdateWindowOne()  // update window one's position
                GotoWindow(WinID)   // restore the original window
                break               // exit
            endif
        endif
        if i >= 153             // avoid updates on every line (skip 75)
            if WinID == 1
                i = 0
                Message(CurrLine(), " of ", n, "...")
                if mIsEscKeyPressed()
                    EscapeKeyIsPressed = TRUE
                endif
            endif
        endif
        if not down()
            mUpdateWindowOne()  // exiting, update Window-1's Position
            break               // at end of file, exit loop
        endif
        GotoBufferID(CID2)      // switch back to the backup file
        if i >= 153             // avoid updates on every line (skip 75)
            if WinID == 2
                i = 0
                Message(CurrLine(), " of ", n, "...")
                if mIsEscKeyPressed()
                    EscapeKeyIsPressed = TRUE
                endif
            endif
        endif
        if not down()
            GotoBufferID(CID1)
            Up()                // files different legnths -- correct down!
            GotoBufferID(CID2)
            mUpdateWindowOne()  // exiting, update Window-1's Position
            break               // at end of file, exit compare
        endif
        if EscapeKeyIsPressed       // the escape key exits the loop
            mUpdateWindowOne()      // update window one's position
            break                   // exit
        endif
    endloop
    PopWinClose()
    mCenterBothWindows(MyXoffset1, MyXoffset2)
    Set(Cursor, OldCursor)
    UpdateDisplay()
    GotoWindow(WinID)               // restore the current window ID
    return(ReturnCode)
end mSearchTwoFiles

/*** mMarkDifference ****************************************************
 *                                                                      *
 * Mark difference text in MyWindow, file CID, from MyBeginLine         *
 * to MyEndLine.                                                        *
 *                                                                      *
 * Called by:   mMarkDifferenceText()                                   *
 *                                                                      *
 * Enter With:  the Window to mark, the file ID to mark, line to begin  *
 *              marking on, and the line to end marking on.             *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       None                                                    *
 *                                                                      *
 ************************************************************************/

proc mMarkDifference(integer MyWindow, integer CID, integer MyBeginLine,
    integer MyEndLine)

    if MyBeginLine <> -1 and MyEndLine <> -1
        GotoWindow(MyWindow)
        GotoBufferID(CID)
        PushPosition()
        GotoLine(MyBeginLine)
        BegLine()
        UnmarkBlock()
        MarkChar()
        GotoLine(MyEndLine)
        MarkChar()
        PopPosition()
    endif
end mMarkDifference

/*** mHiliteDiffWin *****************************************************
 *                                                                      *
 * Mark difference text in MyWindow, file CID, from MyBeginLine         *
 * to MyEndLine.                                                        *
 *                                                                      *
 * Called by:   mMarkDifferenceText()                                   *
 *                                                                      *
 * Enter With:  the Window to hilite, the file ID to hilite, line to    *
 *              begin hiliting on, and the line to end hiliting on.     *
 *                                                                      *
 * Returns:     Nothing                                                 *
 *                                                                      *
 * Notes:       TSE only allows one window to be marked at one time.    *
 *              Since I wanted two separate marks, I had to simulate    *
 *              one of them.  This is the routine that does the         *
 *              simulation.                                             *
 *                                                                      *
 ************************************************************************/

proc mHiliteDiffWin(integer MyWindow, integer CID, integer MyBeginLine,
    integer MyEndLine)
    integer i = 1, j = Query(WindowRows)
    integer BlockColor = Query(BlockAttr)
    integer CursorInBlockAttr = Query(CursorInBlockAttr)
    integer WindowColumns
    integer CurrentCursorRow = CurrRow()

    GotoWindow(MyWindow)
    GotoBufferID(CID)
    WindowColumns = Query(WindowCols)
    UpdateDisplay()                     // must update BEFORE coloring text!
    if MyBeginLine <> -1 and MyEndLine <> -1
        PushPosition()
        // make video window dimensions parallel the editing window dimensions
        Window(Query(WindowX1),Query(WindowY1),
            Query(WindowX1) + Query(WindowCols),
            Query(WindowY1) + Query(WindowRows))
        GotoRow(1)                      // start at upper left corner of screen
        BegLine()
        // scan all window rows, and hilite any lines that need it.
        while i <= j
            if CurrLine() >= MyBeginLine and CurrLine() < MyEndLine
                // set the virtual screen cursor
                VGotoXY(CurrCol(), CurrRow())
                if CurrentCursorRow == i
                    // color the text now with the BlockAttr.
                    PutAttr(CursorInBlockAttr, WindowColumns)
                else
                    PutAttr(BlockColor, WindowColumns)
                endif
            endif
            down()
            i = i + 1
        endwhile
        // disconnect video window diminsions from editing window diminsions
        FullWindow()
        PopPosition()
    endif
end mHiliteDiffWin

/*** mMarkDifferenceText ************************************************
 *                                                                      *
 * Mark difference text in the "other Window", and hilite the           *
 * difference text in this window.                                      *
 *                                                                      *
 * Called by:   mSyncTwoScreenKeys(), mProcessKeystrokes()              *
 *              mCompareToBkup()                                        *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       Only one of the windows is marked, the other is         *
 *              hilited to simulate a mark.                             *
 *                                                                      *
 ************************************************************************/

proc mMarkDifferenceText(integer ForceMark)
    integer CurrentWinID = WindowID()

    if CurrentWinID == 1
        if ForceMark
            mMarkDifference(2, CID2, BeginLine2, EndLine2)
        endif
        mHiliteDiffWin(1, CID1, BeginLine1, EndLine1)
    else
        if ForceMark
            mMarkDifference(1, CID1, BeginLine1, EndLine1)
        endif
        mHiliteDiffWin(2, CID2, BeginLine2, EndLine2)
    endif
end mMarkDifferenceText

/*** mRollLeft **********************************************************
 *                                                                      *
 * TSE seems to have problems handling hard tabs.  Basically, RollLeft  *
 * seems to get stuck when the cursor hits column 1 while on a tab.     *
 * This macro prevents this.                                            *
 *                                                                      *
 * Called by:   mSyncTwoScreenKeys()                                    *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mRollLeft()
    if CurrCol() == 1 and CurrXoffset() == 0
        return()
    endif
    if CurrCol() == 1
        Right()
    endif
    RollLeft()
end mRollLeft

/*** mRollRight *********************************************************
 *                                                                      *
 * TSE seems to have problems handling hard tabs.  Basically, RollRight *
 * seems to get stuck when the cursor hits column 1 while on a tab.     *
 * This macro prevents this.  It also tries to keep the cursor as far   *
 * left as possible.                                                    *
 *                                                                      *
 * Called by:   mSyncTwoScreenKeys()                                    *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mRollRight()
    // get the next xoffset position
    integer NewXoffset = CurrXoffset() + 1

    GotoXoffset(NewXoffset)             // try to scroll over one
    if CurrXoffset() == NewXoffset      // did this work?
        Left()                          // might be able to move cursor left
        if CurrXoffset() <> NewXoffset  // did this cause xoffset to fail?
            Right()                     // put cursor back
            GotoXoffset(NewXoffset)     // put new xoffset back
        endif
    else                                // failure to scroll over by one
        Right()                         // move cursor right to allow xoffset
        GotoXoffset(NewXoffset)         // try again to scroll over one
        Left()                          // put cursor back
        if CurrXoffset() <> NewXoffset  // did this not work?
            Right()                     // move cursor right a 2nd time
            GotoXoffset(NewXoffset)     // this time scroll over must be ok
        endif
    endif
end mRollRight

/*** mPositionAtMark ****************************************************
 *                                                                      *
 * This macro resyncs text to either the beginning of the marked        *
 * difference text, or to the next line following the marked            *
 * difference text for both files.  Use this macro to visually keep     *
 * things in sync.                                                      *
 *                                                                      *
 * Called by:   mSyncTwoScreenKeys()                                    *
 *                                                                      *
 * Enter With:  the window to position, and either the beginning or     *
 *              end of the marked area.                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mPositionAtMark(integer MyWindow, integer MyPosition)
    if MyPosition == BEGINNING
        if MyWindow == 1
            if BeginLine1 <> -1 and EndLine1 <> -1
                GotoLine(BeginLine1)
            endif
        else
            if BeginLine2 <> -1 and EndLine2 <> -1
                GotoLine(BeginLine2)
            endif
        endif
    else
        if MyWindow == 1
            if BeginLine1 <> -1 and EndLine1 <> -1
                GotoLine(EndLine1)
            endif
        else
            if BeginLine2 <> -1 and EndLine2 <> -1
                GotoLine(EndLine2)
            endif
        endif
    endif
end mPositionAtMark

/*** mHandleWhiteSpace **************************************************
 *                                                                      *
 * This macro switches between filtering out all whitespace sequences   *
 * to a single space (for line by line comparisons), or not doing this. *
 * The default is to ignore multiple whitespace differences.            *
 *                                                                      *
 * Called by:   mCompareToBkup()                                        *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mHandleWhiteSpace()
    integer OldCursor

    OldCursor = Set(Cursor, OFF)
    FilterWhiteSpaceFlg = iif(FilterWhiteSpaceFlg == 1, 0, 1)
    Set(Attr, Query(TextAttr))
    mPopWinCentered(47, 6, 4, "MESSAGE",    // open a centered popup window
        Query(CurrWinBorderAttr))
    // clear the new window / position the cursor to upper left
    ClrScr()
    WriteLine(' WhiteSpace characters ("Tabs" and "Spaces")')
    WriteLine(iif(FilterWhiteSpaceFlg == 1, " are now FILTERED (default).",
        " are now UNFILTERED."))
    WriteLine("")                           // blank line
    Write(' Press any key...')
    GetKey()                                // wait for any keypress
    PopWinClose()                           // close the popup window
    Set(Cursor, OldCursor)
end mHandleWhiteSpace

proc mHandleIgnoreCase()
    integer OldCursor

    OldCursor = Set(Cursor, OFF)
    FilterIgnoreCaseFlg = iif(FilterIgnoreCaseFlg == 1, 0, 1)
    Set(Attr, Query(TextAttr))
    mPopWinCentered(47, 6, 4, "MESSAGE",    // open a centered popup window
        Query(CurrWinBorderAttr))
    // clear the new window / position the cursor to upper left
    ClrScr()
    WriteLine(' Now Ignore Case ' + iif(FilterIgnoreCaseFlg == 1,
                                    " is ON (default).", " is OFF."))
    WriteLine("")                           // blank line
    Write(' Press any key...')
    GetKey()                                // wait for any keypress
    PopWinClose()                           // close the popup window
    Set(Cursor, OldCursor)

end mHandleIgnoreCase

/*** mDisplayHelpScreen *************************************************
 *                                                                      *
 * This macro displays Help information for keystrokes / mouseclicks.   *
 *                                                                      *
 * Called by:   mProcessKeystrokes                                      *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mDisplayHelpScreen()
    integer OldCursor
#ifdef WIN32
    integer TitleColor, TextColor
#endif

    OldCursor = Set(Cursor, OFF)

#ifdef WIN32
    TitleColor = Color(Bright White on Blue)
    TextColor  = Color(White on Blue)
    mPopWinCentered(78, 28, 2, "CMPFILES HELP SCREEN, Press F10 For Menu System", TitleColor)

    PutOemStrXY(1, 1, "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ SPECIAL FUNCTIONS ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿", TitleColor,_USE3D_)
    PutOemStrXY(1, 2, "³  ÚÄÄÄÄÄÄÄ FUNCTION ÄÄÄÄÄÄÄÄ¿  ÚÄÄ KEYBOARD ÄÄ¿  ÚÄÄÄÄÄÄÄ MOUSE ÄÄÄÄÄÄÄ¿  ³", TitleColor,_USE3D_)
    PutOemStrXY(1, 3, "³  Activate CMPFILES Menus      F10               Click On Status Line     ³", TextColor, _USE3D_)
    PutOemStrXY(1, 4, "³  Change Video Mode            V                 Mouse Menu Item          ³", TextColor, _USE3D_)
    PutOemStrXY(1, 5, "³  Roll current window up/down  Ctrl CursorUp/Dn  None                     ³", TextColor, _USE3D_)
    PutOemStrXY(1, 6, "³  Roll curr. wind. left/right  Ctrl CursorLt/Rt  None                     ³", TextColor, _USE3D_)
    PutOemStrXY(1, 7, "³  Page current window up/down  Ctrl PgUp/Dn      None                     ³", TextColor, _USE3D_)
    PutOemStrXY(1, 8, "³  Begin/Continue Comparison    Enter             Window Zoom Button  []  ³", TextColor, _USE3D_)
    PutOemStrXY(1, 9, "³  Exit Macro                   Escape            Window Close Button [þ]  ³", TextColor, _USE3D_)
    PutOemStrXY(1,10, "³  Horizontal/Vertical Windows  Spacebar          Mouse Menu Item          ³", TextColor, _USE3D_)
    PutOemStrXY(1,11, "³  Replace Block<-Other Window  R                 Mouse Menu Item          ³", TextColor, _USE3D_)
    PutOemStrXY(1,12, "³  Switch Windows               Tab               Point At Window & Click  ³", TextColor, _USE3D_)
    PutOemStrXY(1,13, "³  Toggle Whitespace Filter     W                 None                     ³", TextColor, _USE3D_)
    PutOemStrXY(1,14, "³  Toggle Ignore Case Filter    I                 None                     ³", TextColor, _USE3D_)
    PutOemStrXY(1,15, "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ", TextColor, _USE3D_)

    PutOemStrXY(1,16, "ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ DUAL WINDOW FUNCTIONS ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿", TitleColor,_USE3D_)
    PutOemStrXY(1,17, "³  ÚÄÄÄÄÄÄÄÄÄÄ FUNCTION ÄÄÄÄÄÄÄÄÄÄÄ¿   ÚÄÄ KEYBOARD ÄÄ¿   ÚÄÄÄ MOUSE ÄÄÄ¿  ³", TitleColor,_USE3D_)
    PutOemStrXY(1,18, "³  End Of Both Windows                 Ctrl End           Mouse Menu Item  ³", TextColor, _USE3D_)
    PutOemStrXY(1,19, "³  Beginning Of Both Windows           Ctrl Home          Mouse Menu Item  ³", TextColor, _USE3D_)
    PutOemStrXY(1,20, "³  Jump To Line                        J                  Mouse Menu Item  ³", TextColor, _USE3D_)
    PutOemStrXY(1,21, "³  Find                                Ctrl F             Mouse Menu Item  ³", TextColor, _USE3D_)
    PutOemStrXY(1,22, "³  Repeat Find                         Ctrl L             Mouse Menu Item  ³", TextColor, _USE3D_)
    PutOemStrXY(1,23, "³  Begin/End Of Difference Text        F11/F12            Mouse Menu Item  ³", TextColor, _USE3D_)
    PutOemStrXY(1,24, "³  Compares curr.lines at column 1     Ctrl Enter         None             ³", TextColor, _USE3D_)
    PutOemStrXY(1,25, "³  Compares curr.lines at curr.cols.   Ctrl Shift Enter   None             ³", TextColor, _USE3D_)
    PutOemStrXY(1,26, "ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ", TextColor, _USE3D_)

#else
    mPopWinCentered(78, 28, 2, "CMPFILES HELP SCREEN, Press F10 For Menu System",
        Query(OtherWinBorderAttr))
    Set(Attr, Query(CurrWinBorderAttr))
    ClrScr()
    Set(Attr, Query(TextAttr))
    Write("ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ")
    Set(Attr, Query(CurrWinBorderAttr))
    Write("SPECIAL FUNCTIONS")
    Set(Attr, Query(TextAttr))
    WriteLine(" ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿")
    WriteLine("³ ÚÄÄÄÄÄÄ FUNCTION ÄÄÄÄÄÄÄÄÄ¿  ÚÄÄÄ KEYBOARD ÄÄ¿  ÚÄÄÄÄÄÄÄ MOUSE ÄÄÄÄÄÄÄÄ¿ ³")
    WriteLine("³ Activate CMPFILES Menus      F10                Click On Status Line     ³")
    WriteLine("³ Change Video Mode            V                  Mouse Menu Item          ³")
    WriteLine("³ Roll current window up/down  Ctrl CursorUp/Dn   None                     ³")
    WriteLine("³ Roll curr. wind. left/right  Ctrl CursorLt/Rt   None                     ³")
    WriteLine("³ Page current window up/down  Ctrl PgUp/Dn       None                     ³")
    WriteLine("³ Begin/Continue Comparison    Enter              Window Zoom Button  []  ³")
    WriteLine("³ Exit Macro                   Escape             Window Close Button [þ]  ³")
    WriteLine("³ Horizontal/Vertical Windows  Spacebar           Mouse Menu Item          ³")
    WriteLine("³ Replace Block<-Other Window  R                  Mouse Menu Item          ³")
    WriteLine("³ Switch Windows               Tab                Point At Window & Click  ³")
    WriteLine("³ Toggle Whitespace Filter     W                  None                     ³")
    WriteLine("³ Toggle Ignore Case Filter    I                  None                     ³")
    WriteLine("ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ")

    Write("ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ")
    Set(Attr, Query(CurrWinBorderAttr))
    Write("DUAL WINDOW FUNCTIONS")
    Set(Attr, Query(TextAttr))
    WriteLine(" ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿")
    WriteLine("³  ÚÄÄÄÄÄÄÄ FUNCTION ÄÄÄÄÄÄÄÄÄÄÄÄÄ¿  ÚÄÄÄÄ KEYBOARD ÄÄÄÄ¿  ÚÄÄÄ MOUSE ÄÄÄ¿ ³")
    WriteLine("³  End Of Both Windows               Ctrl End              Mouse Menu Item ³")
    WriteLine("³  Beginning Of Both Windows         Ctrl Home             Mouse Menu Item ³")
    WriteLine("³  Jump To Line                      J                     Mouse Menu Item ³")
    WriteLine("³  Find                              Ctrl F                Mouse Menu Item ³")
    WriteLine("³  Repeat Find                       Ctrl L                Mouse Menu Item ³")
    WriteLine("³  Begin/End Of Difference Text      F11/F12               Mouse Menu Item ³")
    WriteLine("³  Compares curr.lines at column 1   Ctrl Enter            None            ³")
    WriteLine("³  Compares curr.lines at curr.cols. Ctrl Shift Enter      None            ³")
        Write("ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ")
#endif
    if GetKey() == <F10>                // menu requested?
        PushKey(<F10>)
    endif
    PopWinClose()
    Set(Cursor, OldCursor)
end mDisplayHelpScreen

/*** mToggleWindowTypes *************************************************
 *                                                                      *
 * This macro adjusts the windows when either a video change occurs, or *
 * a a Vertical / Horizontal change occurs.                             *
 *                                                                      *
 * Called by:   mProcessKeystrokes                                      *
 *                                                                      *
 * Enter With:  The current window ID, and VideoFlg set to a 1 if       *
 *              a video mode change is to occur.                        *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mToggleWindowTypes(integer CurrentWinID, integer VideoFlg, integer Size)
integer MyXoffset1, MyXoffset2
    string BkupFileName[MAXPATH]

    GotoWindow(2)
    MyXoffset2 = CurrXoffset()
    BkupFileName = CurrFilename()
    GotoWindow(1)
    MyXoffset1 = CurrXoffset()
    OneWindow()
    if GetGlobalInt("VWindowFlg")
        if VideoFlg             // if video mode change, keep same window type
            Set(CurrVideoMode, size)
            VWindow()
            SetGlobalInt("VWindowFlg", TRUE)       // vertical windows
        else                    // toggle window types
            HWindow()
            SetGlobalInt("VWindowFlg", FALSE)       // vertical windows
        endif
    else
        if VideoFlg             // if video mode change, keep same window type
            Set(CurrVideoMode, size)
            HWindow()
            SetGlobalInt("VWindowFlg", FALSE)       // vertical windows
        else                    // toggle window types
            VWindow()
            SetGlobalInt("VWindowFlg", TRUE)       // vertical windows
        endif
    endif
    EditFile(BkupFileName)
    mCenterBothWindows(MyXoffset1, MyXoffset2)
    GotoWindow(CurrentWinID)
end mToggleWindowTypes

/*** mYesNoCancel *******************************************************
 *                                                                      *
 * Open up a centered menu, place a "yes" on one line, a "no" on the    *
 * other line, and an escape on a third line.  Hilite the "yes" item.   *
 * Determine whether a "Y" , "N", or "Esc" were selected, and return    *
 * a "1" for "yes", a "0" for "no", and a -1 for "Esc".                 *
 *                                                                      *
 * Called by:   mEscapeProcess()                                        *
 *                                                                      *
 * Enter With:  the line to hilite (1 to 3), the string to display.     *
 *                                                                      *
 * Returns:     Return a 1 if yes clicked, or "Y" pressed, a 0 if no    *
 *              clicked or "N" pressed, or  a -1 if "Esc" pressed or    *
 *              clicked.                                                *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/
integer proc mYesNoCancel(string s)
    Set(X1, (Query(ScreenCols) - Length(s)) / 2)
    Set(Y1, ((Query(ScreenRows) - 5) / 2))
    case YesNo(s)
        when 1      return (1)
        when 2      return (0)
    endcase
    return (-1)
end

/*** mEscapeProcess *****************************************************
 *                                                                      *
 * This macro prepares for a macro exit.  It marks the difference text, *
 * and stores the information in a global area which stays after the    *
 * macro shuts down.  It switches to one window, either the original,   *
 * or the backup window (whichever one the cursor is in), and leaves    *
 * any text marked in this window.                                      *
 *                                                                      *
 * Called by:   mProcessKeystrokes                                      *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

integer proc mEscapeProcess()
    integer MyWindow = WindowID(), MainFileID, ReturnCode, YesNoReturn

    GotoWindow(iif(WindowID() == 1, 2, 1))  // toggle to other window
    mMarkDifferenceText(TRUE)               // hilite difference info
    GotoWindow(iif(WindowID() == 1, 2, 1))  // toggle to first window

    GotoWindow(1)
    MainFileID = GetBufferID()
    GotoWindow(2)
    // get the backup filename
    GS2 = SplitPath(CurrFilename(), _NAME_ | _EXT_)
    Set(Attr, Query(TextAttr))
    YesNoReturn = mYesNoCancel(" Unload 'Compare to' File?")
    case YesNoReturn
        when 1                              // yes
            QuitFile()
            GoToBufferID(MainFileID)
            OneWindow()
            ReturnCode = TRUE               // continue with macro exit
        when 0                              // no
            GotoWindow(MyWindow)            // back to original window
            ReturnCode = TRUE               // continue with macro exit
        when -1                             // escape
            GotoWindow(MyWindow)            // back to original window
            ReturnCode = FALSE
        endcase
    if ReturnCode                           // really exiting the macro?
        // preserve these integers in case Cmp2BkUp restarts
        SetGlobalInt("BeginLine1Save", BeginLine1)
        SetGlobalInt("BeginLine2Save", BeginLine2)
        SetGlobalInt("EndLine1Save", EndLine1)
        SetGlobalInt("EndLine2Save", EndLine2)
    endif
    return (ReturnCode)
end mEscapeProcess

/*** mGotoLines *********************************************************
 *                                                                      *
 * This macro changes the current window to the entered line number,    *
 * while the other window is changed by a common differential.          *
 *                                                                      *
 * Called by:   mProcessKeystrokes                                      *
 *                                                                      *
 * Enter With:  The current window ID.                                  *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mGotoLines(integer CurrentWinID)
integer LineDiff
String  LastGotoLine[11] = ""

    if Ask("Go to line:", LastGotoLine, _GOTOLINE_HISTORY_)
        LineDiff = val(LastGotoLine) - CurrLine()
        GotoLine(val(LastGotoLine))
        GotoWindow(iif(CurrentWinID == 1, 2, 1))
        GotoLine(CurrLine() + LineDiff)
        GotoWindow(CurrentWinID)
    endif
end mGotoLines

proc terminate()
     BreakHookChain()
end

/*** mProcessMouse ******************************************************
 *                                                                      *
 * This macro handles all of the supported mouse functions.             *
 *                                                                      *
 * Called by:   mProcessKeystrokes                                      *
 *                                                                      *
 * Enter With:  The mouse button pressed                                *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       All mouse functions, except _MOUSE_VRESIZE_ and         *
 *              _MOUSE_HRESIZE_, are simulated via pushed keystrokes.   *
 *                                                                      *
 ************************************************************************/

proc mProcessMouse(integer Button)
    GotoWindow(MouseWindowID())
    case MouseHotSpot()
        when _NONE_
            if Button == <RightBtn>
                PushKey(<Grey+>)
            else
                PushKey(<Grey->)
            endif
        when _MOUSE_CLOSE_
            PushKey(<Escape>)               // terminate the macro
        when _MOUSE_ZOOM_
            PushKey(<Enter>)                // begin the scan
        when _MOUSE_UP_
            PushKey(<CursorUp>)
        when _MOUSE_DOWN_
            PushKey(<CursorDown>)
        when _MOUSE_PAGEUP_
            PushKey(<PgUp>)
        when _MOUSE_PAGEDOWN_
            PushKey(<PgDn>)
        when _MOUSE_LEFT_
            PushKey(<CursorLeft>)
        when _MOUSE_RIGHT_
            PushKey(<CursorRight>)
        when _MOUSE_TABLEFT_
            PushKey(<CursorLeft>)
        when _MOUSE_TABRIGHT_
            PushKey(<CursorRight>)
        when _MOUSE_VRESIZE_
            ProcessHotSpot()
        when _MOUSE_HRESIZE_
            ProcessHotSpot()
        when _MOUSE_VWINDOW_
            PushKey(<Spacebar>)
        when _MOUSE_HWINDOW_
            PushKey(<Spacebar>)
    endcase
    return()
end mProcessMouse

/****************************************************************************\
  ú display differences in current lines
\****************************************************************************/

#ifdef WIN32
string ruler[250] = "....|...10....|...20....|...30....|...40....|...50....|...60....|...70....|...80....|...90....|..100....|..110....|..120....|..130....|..140....|..150....|..160....|..170....|..180....|..190....|..200....|..210....|..220....|..230....|..240....|..250"
#else
string ruler[250] = ".......10.......20.......30.......40.......50.......60.......70.......80.......90......100......110......120......130......140......150......160......170......180......190......200......210......220......230......240......250"
#endif

keydef ListKeys
    <CursorUp>      if not Up(6) Down(5) endif
    <CursorDown>    if not Down(6) Up() endif
    <Escape>        EndProcess(FALSE)
end

proc ListHook()
    Enable(ListKeys,_EXCLUSIVE_)
    ListFooter(" {Escape}-Return ")
end

integer proc mCurrX()
    return ( CurrCol() - CurrXoffset())
end

proc mLeftEdge()
    GotoColumn( CurrCol() - mCurrX() + 1)
end

//  proc mRightEdge()
//      GotoColumn( CurrCol() + Query(WindowCols)- mCurrX())
//  end

proc mCompLines(integer lCurrCols)
    constant WIDTH = 50
    integer c, r, oldWindow
    integer lBeginPos, rBeginPos
    integer ln, rn, oldLeftCol, oldRightCol
    string lt[250]
    string rt[250]
    string Arrow[1]
    string Fill[1]

#ifdef WIN32
    Arrow = "^"
#else
    Arrow = ""
#endif

#ifdef WIN32
    Fill = "~"
#else
    Fill = "±"
#endif

    // get current lines and switch to work buffer

    oldWindow = WindowId()

    GotoWindow(1)
    oldLeftCol = CurrCol()
    ln = CurrLine()

    IF lCurrCols
        // Go to first visible column
        mLeftEdge()
        lBeginPos = CurrPos()
    ELSE
        lBeginPos = 1
    ENDIF
    lt = GetText(lBeginPos,CurrLineLen())

    GotoWindow(2)
    oldRightCol = CurrCol()
    rn = CurrLine()

    IF lCurrCols
        // Go to first visible column
        mLeftEdge()
        rBeginPos = CurrPos()
    ELSE
        rBeginPos = 1
    ENDIF
    rt = GetText(rBeginPos,CurrLineLen())

    GotoWindow(1)
    GotoBufferId(temp)

    // format lines and display work buffer

    r = 0
    while Length(lt) or Length(rt)

        // add ruler

        AddLine()
        IF lCurrCols
            IF lBeginPos <> rBeginPos
                AddLine( " 1  " + ruler[WIDTH*r+lBeginPos:WIDTH] )
                AddLine( " 2  " + ruler[WIDTH*r+rBeginPos:WIDTH] )
            ELSE
                AddLine()
                AddLine( "    " + ruler[WIDTH*r+lBeginPos:WIDTH] )
            ENDIF
            r = r + 1
        ELSE

            AddLine()
            AddLine( "    " + ruler[WIDTH*r+lBeginPos:WIDTH])
            r = r + 1
        ENDIF

        // add formatted lines
        AddLine(Format(" 1  ",lt[1:WIDTH]:-WIDTH:Fill))
        AddLine(Format(" 2  ",rt[1:WIDTH]:-WIDTH:Fill))

        // add markers showing differences

        AddLine()
        GotoColumn(5)
        c = 0
        while c < WIDTH and ( c < Length(lt) or c < Length(rt) )
            c = c + 1
            if c > Length(lt) or c > Length(rt) or lt[c] <> rt[c]
                InsertText(Arrow)
            else
                Right()
            endif
        endwhile

        // skip displayed parts of strings

        lt = lt[WIDTH+1:250]
        rt = rt[WIDTH+1:250]
    endwhile

    // show formatted lines in scrolling list

    AddLine()

    if not lFind(Arrow,"g")
        GotoLine(6)
    else
        loop
            if CurrLine() mod 6
                if not lRepeatFind(_FORWARD_)
                    GotoLine(6)
                    break
                endif
            else
                break
            endif
        endloop
    endif

    Hook(_LIST_STARTUP_, ListHook)
    List("Differences in lines "+Str(ln)+" and "+Str(rn),WIDTH+6)
    Unhook(ListHook)

    // flush work buffer and return

    EmptyBuffer()
    GotoBufferId(CID1)
    GotoWindow(1)
    GotoColumn(oldLeftCol)
    GotoWindow(2)
    GotoColumn(oldRightCol)
    GotoWindow(oldWindow)
end

/*** mCopyBlock *********************************************************
 *                                                                      *
 * Copy the current highlighted block to the clipboard.                 *
 *                                                                      *
 * Called by:   the EditMenu()                                          *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mCopyBlock()
    integer MyBeginLine, MyEndline

    if WindowID() == 1
        MyBeginLine = BeginLine1
        MyEndline = EndLine1
    else
        MyBeginLine = BeginLine2
        MyEndline = EndLine2
    endif
    if MyBeginLine <> -1 and MyEndLine <> -1
        PushBlock()
        GotoLine(MyBeginLine)
        BegLine()
        UnmarkBlock()
        MarkChar()
        GotoLine(MyEndLine)
        MarkChar()
        if IsBlockMarked()
            Copy()
        endif
        PopBlock()
    endif
end mCopyBlock

/*** mReplaceBlock ******************************************************
 *                                                                      *
 * When text is compared and differences are encountered, both files    *
 * will have the difference text highlighted.  This macro will replace  *
 * the highlighted block in the current file with the highlighted block *
 * in the other file.                                                   *
 *                                                                      *
 * Called by:   mProcessKeystrokes()                                    *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mReplaceBlock()
    integer MyBeginLine, MyEndline, key_code
    string fn[MAXPATH]

    if WindowID() == 1
        MyBeginLine = BeginLine1
        MyEndline = EndLine1
    else
        MyBeginLine = BeginLine2
        MyEndline = EndLine2
    endif
    GotoWindow(iif(WindowID() == 1, 2, 1))
    fn = CurrFilename()
    GotoWindow(iif(WindowID() == 1, 2, 1))

    if MyBeginLine <> -1 and MyEndLine <> -1
        if CurrLine() < MyBeginLine or CurrLine() > MyEndLine
            FlashMessage("Cursor NOT positioned correctly -- nothing done!",
                FALSE, 1)
            return()
        endif
        key_code = mMessageBox("CMPFILES Query",
            'Transfer marked text from:'
            + '``"' + Upper(fn) + '"'
            + '``to replace marked text in:'
            + '``"' + Upper(CurrFilename()) + '"'
            + '```(y/N)?',
                FALSE)
        if Lower(Chr(key_code & 0xff)) <> 'y'
                return()
        endif
        PushPosition()
        PushBlock()
        GotoLine(MyBeginLine)
        BegLine()
        UnmarkBlock()
        MarkChar()
        GotoLine(MyEndLine)
        MarkChar()
        if IsBlockMarked()
            KillBlock()
        endif
        PopBlock()
        PushBlock()
        if IsBlockMarked()
            CopyBlock()
            GotoBlockBegin()
            MyBeginLine = CurrLine()
            GotoBlockEnd()
            MyEndLine = CurrLine()
        else
            MyBeginLine = CurrLine()
            MyEndLine = CurrLine()
        endif
        if WindowID() == 1
            BeginLine1 = MyBeginLine
            EndLine1 = MyEndline
        else
            BeginLine2 = MyBeginLine
            EndLine2 = MyEndline
        endif
        PushKey(<F11>)              // resync both differences
        PopBlock()
        PopPosition()
    else
        FlashMessage("NO difference text found yet!", FALSE, 1)
    endif
end mReplaceBlock

/*** mPaste *************************************************************
 *                                                                      *
 * Paste the main clipboard contents into the current file.             *
 *                                                                      *
 * Called by:   The EditMenu()                                          *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mPaste()
    integer key_code
    key_code = mMessageBox("CMPFILES Query",
                'Paste clipboard text into:``' + '"' + Upper(CurrFilename())
                    + '"``(y/N)?', FALSE)
    if Lower(Chr(key_code & 0xff)) <> 'y'
        return()
    endif
    Paste()
end mPaste

/*** mDoubleFind ********************************************************
 *                                                                      *
 * Find the same text in both windows.                                  *
 *                                                                      *
 * Called by:   mProcessKeystrokes()                                    *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mDoubleFind()
    GotoWindow(iif(WindowID() == 1, 2, 1))
    PushPosition()
    Right()
    if Find()
        KillPosition()
    else
        PopPosition()
    endif
    GotoWindow(iif(WindowID() == 1, 2, 1))
    if Query(key) <> <escape>
        RepeatFind()
    endif
end mDoubleFind

/*** mDoubleRepeatFind **************************************************
 *                                                                      *
 * Do a repeat find for the same word in both windows.                  *
 *                                                                      *
 * Called by:   mProcessKeystrokes()                                    *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mDoubleRepeatFind()
    GotoWindow(iif(WindowID() == 1, 2, 1))
    RepeatFind()
    GotoWindow(iif(WindowID() == 1, 2, 1))
    if Query(key) <> <escape>           // escape character?
        RepeatFind()
    endif
end mDoubleRepeatFind

/*** mDoubleFindWordAtCursor ********************************************
 *                                                                      *
 * Find the word pointed to by the cursor in both windows.              *
 *                                                                      *
 * Called by:   mProcessKeystrokes()                                    *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mDoubleFindWordAtCursor()
    string s[80]

    s = GetWord(TRUE)
    GotoWindow(iif(WindowID() == 1, 2, 1))
    if Length(s)
        Find(s, Query(FindOptions) + '+')
    endif
    GotoWindow(iif(WindowID() == 1, 2, 1))
    if Length(s)
        if Query(key) <> <escape>           // escape character?
            RepeatFind()
        endif
    endif
end mDoubleFindWordAtCursor

/*** CPBMENUS --- PULLDOWN MENUS FOR CMP2BKUP ***************************
 *                                                                      *
 * SOFTWARE:    CMP2BKUP                                                *
 * VERSION:     1.00                                                    *
 * DATE:        May 8, 1994                                             *
 * REV. DATE:   July 15th, 1994                                         *
 * AUTHOR:      Ian Campbell                                            *
 * TYPE:        Include file for CMP2BKUP                               *
 *                                                                      *
 ************************************************************************/

/*** mAbout *************************************************************
 *                                                                      *
 * Provides an "About Box" for CMP2BKUP.                                *
 *                                                                      *
 * Called by:   menu item Help/About                                    *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mAbout()
    mMessageBox("About CmpFiles",
        "`CMPFILES, Version " + MyVersion
        + "``Split the screen and compare"
        + "`two text files.  Find and mark"
        + "`the next difference block in"
        + "`each file.  Resync both files"
        + "`to the end of these difference"
        + "`blocks."
        + "``Written by Ian Campbell"
        + "``July 15th, 1994"
        + "```Press any key...",
            FALSE)
end mAbout

Menu FileMenu()
    history

    "&Save"                         ,   SaveFile()
    "Save &As..."                   ,   SaveAs()
    ""                              ,                       , Divide
    "E&xit CMPFILES   <Escape>"    ,   PushKey(<escape>)
end

Menu EditMenu()
    history

    "&Copy"                     ,   mCopyBlock()
    "&Paste..."                 ,   mPaste()
    ""                          ,                       , Divide
    "&Replace...       <R>"     ,   PushKey(<r>)
    "&Block to File... <Alt W>" ,   PushKey(<Alt W>)
end

Menu ViewMenu()
    history

    "&Vert/Horiz Window <SpaceBar>" ,   PushKey(<spacebar>)
    "&Resize..."                    ,   ResizeWindow()
    "Other &Window           <Tab>" ,   GotoWindow(iif(WindowID() == 1, 2, 1))
    ""                              ,                       , Divide
    "&25-Line                  <V>" ,   mToggleWindowTypes(WindowID(),
                                            VIDEO_FLG, _25_LINES_)
    "3&6-Line                  <V>"  ,   mToggleWindowTypes(WindowID(),
                                            VIDEO_FLG, _36_LINES_)
    "&44-Line                  <V>"  ,   mToggleWindowTypes(WindowID(),
                                            VIDEO_FLG, _44_LINES_)
    "&50-Line                  <V>"  ,   mToggleWindowTypes(WindowID(),
                                            VIDEO_FLG, _50_LINES_)
end

Menu SearchMenu()
    history

    "Begin/Continue &Comparison <Enter>"   ,   PushKey(<enter>)
    "Difference Blocks &Begin     <F11>"   ,   PushKey(<F11>)
    "Difference Blocks &End       <F12>"   ,   PushKey(<F12>)
    ""                                     ,                       , Divide
    "&Find...                  <Ctrl F>"   ,   PushKey(<Ctrl F>)
    "Find &Again               <Ctrl L>"   ,   PushKey(<Ctrl L>)
    "Find &Word at Cursor       <Alt =>"   ,   PushKey(<Alt =>)
    ""                                  ,                          , Divide
    "Be&ginning of Files    <Ctrl PgUp>"   ,   PushKey(<Ctrl PgUp>)
    "En&d of Files          <Ctrl PgDn>"   ,   PushKey(<Ctrl PgDn>)
    "Go to &Lines...           <Ctrl J>"   ,   PushKey(<Ctrl J>)
    ""                                     ,                       , Divide
    "&Toggle WhiteSpace            <W>"   ,   PushKey(<w>)
    "Toggle &Ignore Case           <I>"   ,   PushKey(<i>)
end

Menu HelpMenu()
    "&Help Screen  "                   ,   mDisplayHelpScreen()
    "&About  "                         ,   mAbout()
end

MenuBar MainMenu()
    history

    "&File"    ,    FileMenu()
    "&Edit"    ,    EditMenu()
    "&View"    ,    ViewMenu()
    "&Search"  ,    SearchMenu()
    "&Help"    ,    HelpMenu()
end

/*** CMP2BKUP.KEY -- KEY FILE FOR CMP2BKUP ******************************
 *                                                                      *
 * SOFTWARE:    CMP2BKUP                                                *
 * VERSION:     1.00                                                    *
 * DATE:        May 8, 1993                                             *
 * REV. DATE:   July 15th, 1994                                         *
 * AUTHOR:      Ian Campbell                                            *
 * TYPE:        Include file for CMP2BKUP                               *
 *                                                                      *
 ************************************************************************
 *                                                                      *
 * This file does not handle keystrokes in the conventional sense,      *
 * rather, it sets up a GetKey() loop and handles the keyboard          *
 * directly, rather than implicitely, or via a keydef file.             *
 *                                                                      *
 ************************************************************************/

/*** mSyncTwoScreenKeys *************************************************
 *                                                                      *
 * This macro is called twice, once for one window, and again           *
 * for the other window.  Keystrokes which are to be reflected          *
 * simultaneously into both windows are handled here.                   *
 * If you don't like the dual screen keystroke choices, then here is    *
 * the place to change them!                                            *
 *                                                                      *
 * Called by:   mProcessKeystrokes()                                    *
 *                                                                      *
 * Enter With:  the keystroke to handle, and the window to do it in.    *
 *                                                                      *
 * Returns:     TRUE is the keystroke was recognized, otherwise FALSE.  *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

integer proc mSyncTwoScreenKeys(integer keystroke, integer win)
    integer CurrentWinID = WindowID(), ReturnCode = TRUE

    GotoWindow(win)                     // switch to the requested window
    case keystroke
        when <CursorUp>, <GreyCursorUp>, <Shift CursorUp>, <Shift GreyCursorUp>
            if CurrLine() > (Query(WindowRows) / 2)
                RollUp()
            else
                Up()
            endif
        when <CursorDown>, <GreyCursorDown>, <Shift CursorDown>, <Shift GreyCursorDown>
            if CurrLine() > (Query(WindowRows) / 2)
                RollDown()
            else
                Down()
            endif
        when <Grey->, <F11>
            mPositionAtMark(win, BEGINNING)
        when <Grey+>, <F12>
            mPositionAtMark(win, ENDING)
        when <Ctrl Home>, <Ctrl GreyHome>
            BegFile()
        when <Ctrl End>, <Ctrl GreyEnd>
            EndFile()
            BegLine()
        when <CursorRight>, <GreyCursorRight>, <Shift CursorRight>, <Shift GreyCursorRight>
            mRollRight()
        when <CursorLeft>, <GreyCursorLeft>, <Shift CursorLeft>, <Shift GreyCursorLeft>
            mRollLeft()
        when <PgUp>, <GreyPgUp>, <Shift PgUp>, <Shift GreyPgUp>
            PageUp()
        when <PgDn>, <GreyPgDn>, <Shift PgDn>, <Shift GreyPgDn>
            PageDown()
        when <Home>, <GreyHome>
            BegLine()
        when <End>, <GreyEnd>
            EndLine()
        otherwise
            ReturnCode = FALSE
    endcase
    ScrollToRow(Query(WindowRows) / 2)      // try to center the cursor line
    GotoWindow(CurrentWinID)
    return(ReturnCode)
end mSyncTwoScreenKeys

/*** mProcessKeystrokes *************************************************
 *                                                                      *
 * This macro processes and handles all keystrokes, including ones that *
 * must be passed simultaneously through to both windows.               *
 * If you don't like the single screen keystroke choices, here is       *
 * the place to change them!                                            *
 *                                                                      *
 * Called by:   mCompareToBkup()                                        *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       The main macro loop exists here.  All macro processing  *
 *              is suspended via the call to GetKey() (until a key is   *
 *              actually pressed).                                      *
 *                                                                      *
 ************************************************************************/

proc mProcessKeystrokes()
    integer keystroke, CurrentWinID, MustMark = 0, CurrentTime

    loop                            // loop until break
        CurrentWinID = WindowID()
        keystroke = GetKey()        // wait for a key to be pressed
        case keystroke
            when <F10>, <Alt M>, <CtrlAlt M>, <Ctrl K>
                PushKey(<Enter>)
                MainMenu()
            when <r>, <Alt R>, <Shift R>
                mReplaceBlock()
            when <Alt W>
                SaveBlock()
            when <Ctrl L>, <l>, <Shift L>
                mDoubleRepeatFind()
            when <Alt =>
                mDoubleFindWordAtCursor()
            when <Ctrl F>, <Alt S>
                mDoubleFind()
            when <Alt CursorDown>, <Alt GreyCursorDown>
                PushKey(<CursorDown>)
                ResizeWindow()
            when <Alt CursorLeft>, <Alt GreyCursorLeft>
                PushKey(<CursorLeft>)
                ResizeWindow()
            when <Alt CursorRight>, <Alt GreyCursorRight>
                PushKey(<CursorRight>)
                ResizeWindow()
            when <Alt CursorUp>, <Alt GreyCursorUp>
                PushKey(<CursorUp>)
                ResizeWindow()
            when <Ctrl PgUp>
                PageUp()
            when <Ctrl CursorUp>, <Ctrl GreyCursorUp>
                RollUp()
            when <Ctrl PgDn>
                PageDown()
            when <Ctrl CursorDown>, <Ctrl GreyCursorDown>
                RollDown()
            when <Ctrl CursorLeft>, <Ctrl GreyCursorLeft>
                mRollLeft()
            when <Ctrl CursorRight>, <Ctrl GreyCursorRight>
                mRollRight()
            when <c>, <Shift C>, <v>, <Shift V>
                mToggleWindowTypes(CurrentWinID, VIDEO_FLG, 0)
            when <Enter>, <GreyEnter>
                if not mSearchTwoFiles()
                    FlashMessage("Cannot resync files past this point...",
                        FALSE, 1)
                endif
                MustMark = 1
            when <Ctrl Enter>, <Ctrl GreyEnter>
                mCompLines(0)
            when <CtrlShift Enter>
                mCompLines(TRUE)    // Compare current lines at current position
            when <Escape>, <Alt Q>
                if mEscapeProcess()
                    return()
                endif
                MustMark = 1
            when <F1>, <h>, <Shift H>, <Alt H>
                mDisplayHelpScreen()
            when <g>, <Shift G>, <Alt G>, <j>, <Ctrl J>, <Shift J>, <Alt J>
                mGotoLines(CurrentWinID)
            when <Spacebar>
                // vertical / horizontal toggle
                mToggleWindowTypes(CurrentWinID, NO_VIDEO_FLG, 0)
            when <LeftBtn>, <RightBtn>
                if MouseHotSpot() == _NONE_
                    while MouseKeyHeld()    // wait for the mouse to be released
                    endwhile
                    PushKey(<enter>)
                    MainMenu()
                endif
                if MouseState == 1
                    CurrentTime = GetClockTicks()
                    while MouseKeyHeld()
                        if GetClockTicks() > CurrentTime + Query(MouseHoldTime)
                            break
                        endif
                    endwhile
                    MouseState = 2          // full speed ahead state
                endif
                if MouseKeyHeld()
                    PushKey(keystroke)
                    mProcessMouse(keystroke)
                    if MouseState == 0      // entry state
                        MouseState = 1      // pause state
                    endif
                else
                    MouseState = 0          // reset to the entry state
                endif
                MustMark = 1
            when <Tab>, <Shift Tab>
                GotoWindow(iif(WindowID() == 1, 2, 1))
                ScrollToRow(Query(WindowRows) / 2)  // try to center the cursor line
                MustMark = 1
            when <w>, <Shift W>
                mHandleWhiteSpace()

            when <i>, <Shift I>
                mHandleIgnoreCase()

            otherwise
                if mSyncTwoScreenKeys(keystroke, 1)     // window one
                    mSyncTwoScreenKeys(keystroke, 2)    // window two
                else
#ifdef WIN32
                    FlashMessage('Invalid Key! <' + KeyName(keystroke) + '>  <Enter> = Compare, <F1> = Help, <F10> = Menu', FALSE, 2)
#else
                    FlashMessage('Invalid Key!  <Enter> = Compare, <F1> = Help, <F10> = Menu', FALSE, 2)
#endif
                endif
        endcase
        mMarkDifferenceText(MustMark)       // mark differences on screen now
        MustMark = 0
    endloop
end mProcessKeystrokes

/*** mListIt ************************************************************
 *                                                                      *
 * Display files in the editor's ring.  Allow cursor movement,          *
 * and when mListIt exits, place the cursor on the line that was        *
 * selected, allowing a primative picklist selection.                   *
 *                                                                      *
 * Called by:   mListOpenFiles()                                        *
 *                                                                      *
 * Enter With:  The title of the window, and the window width           *
 *                                                                      *
 * Returns:     Non zero if exited with ENTER, 0 if exited with ESCAPE. *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

integer proc mListIt(string title, integer width)
    width = width + 4
    if width > Query(ScreenCols)
        width = Query(ScreenCols)
    endif
    return (List(title, width))
end mListIt

/*** mGetNameFromRing ***************************************************
 *                                                                      *
 * See if a name (drive, path, and extention stripped off) is in the    *
 * ring.  If it is, then edit that file, and return a 1 to say that     *
 * we've done it.  If not, then just return a 0.                        *
 *                                                                      *
 * Called by:   mCompareToBkup()                                        *
 *                                                                      *
 * Enter With:  the filename string to check for.                       *
 *                                                                      *
 * Returns:     TRUE if filename found, FALSE if not found.             *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mGetNameFromRing(string filename)
    integer start_file, filelist, id, maxl, total, n
    string fn[MAXPATH] = "", fn2[MAXPATH] = ""

    n = NumFiles() + (BufferType() <> _NORMAL_)
    if n == 0
        return ()
    endif
    maxl = 0
    total = 0
    start_file = GetBufferId()                 // Save current buffer
    filelist = CreateTempBuffer()
    if filelist == 0
        warn("Can't create filelist")
        return ()
    endif
    GotoBufferID(start_file)
    id = GetBufferid()
    while n
        fn = CurrFilename()
        if Lower(filename) == Lower(SplitPath(fn, _NAME_)) and CurrExt() <> ".cbk"
            fn2 = fn
            total = total + 1
            if length(fn) > maxl
                maxl = length(fn)
            endif
            GotoBufferID(filelist)
            AddLine(fn)
            GotoBufferID(id)
        endif
        NextFile(_DONT_LOAD_)
        id = GetBufferid()
        n = n - 1
    endwhile
    GotoBufferID(filelist)
    BegFile()
    PushBlock()
    UnMarkBlock()
    MarkStream()
    EndFile()
    MarkStream()
    Sort()
    PopBlock()
    BegFile()
    if total > 1
        while not mListIt("Select Original File", maxl)
        endwhile
        fn2 = GetText(1, sizeof(fn2))
    endif
    AbandonFile(filelist)
    if Length(fn2)
        EditFile(fn2)
    else
        GotoBufferID(start_file)
    endif
end mGetNameFromRing

string stCurrFilename[MAXPATH] = ""
proc GuessFilename()
	if FileExists(GetText(1, CurrLineLen())) & _DIRECTORY_
		PushPosition()
		EndLine()
		if Left()
			if not (Chr(CurrChar()) in "\", "/")
				EndLine()
				InsertText("\", _INSERT_)
			endif
			if FileExists(GetText(1,
					CurrLineLen())+SplitPath(stCurrFilename, _NAME_|_EXT_))
				EndLine()
				InsertText(SplitPath(stCurrFilename, _NAME_|_EXT_), _INSERT_)
			endif
		endif
		PopPosition()
	endif
end

keydef FilenamePromptKeys
<Enter>			GuessFilename() EndProcess(TRUE)
<GreyEnter>		GuessFilename() EndProcess(TRUE)
end

proc FilenamePromptStartup()
	Enable(FilenamePromptKeys)
end

proc FilenamePromptCleanup()
	Disable(FilenamePromptKeys)
end

/*** mGetValidFileName **************************************************
 *                                                                      *
 * This routine will only allow a legit filename.   Picklists are       *
 * provided to resolve it.  Both the current directory, and then the    *
 * current filename's directory are sequentially checked.               *
 *                                                                      *
 * Called by:   mLoadBackupFile()                                       *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     FALSE if user exits "Ask" with escape, TRUE if filename *
 *              resolved.                                               *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

integer proc mGetValidFileName()
    integer FileThere, PathQualified, i, NameLength
    string name[MAXPATH] = ""
    string s1[MAXPATH] = ""

    loop
        PathQualified = FALSE
        UpdateDisplay()
        stCurrFilename = CurrFilename()
        Hook(_PROMPT_STARTUP_, FilenamePromptStartup)
        Hook(_PROMPT_CLEANUP_, FilenamePromptCleanup)
        FileThere = AskFilename('Compare "'
            + Upper(SplitPath(CurrFilename(), _NAME_ | _EXT_)) +
                '" to:  ["ARC", "ARJ", "LZH", and "ZIP" files are also OK]',
            GS3, _MUST_EXIST_, cmp2bkup_file_history)
        UnHook(FilenamePromptStartup)
        UnHook(FilenamePromptCleanup)
        if not FileThere
            return(FALSE)
        endif
        if Length(GS3)
            if GS3 == ".*"
                GS3 = "*.*"
            endif
            if Length(SplitPath(GS3, _DRIVE_ | _PATH_))
                if SplitPath(GS3, _DRIVE_ | _PATH_) <> "."
                    PathQualified = TRUE
                endif
            endif
            if GS3[Length(GS3)] <> "\"
                if mDirExists(GS3)
                    GS3 = GS3 + "\"
                endif
            endif
        endif
        GS3 = ExpandPath(GS3)
        if not Length(SplitPath(GS3, _EXT_))    // no extention?
            if not FileExists(GS3)
                GS3 = GS3 + ".*"
            endif
        endif
        i = 1
        name = Splitpath(GS3, _NAME_ | _EXT_)
        NameLength = Length(name)
        while i <= NameLength
            // any wildcard in name or extention?
            if name[i] == '*' or name[i] == '?'
                // wildcard in name but no extention?
                if not Length(SplitPath(GS3, _EXT_))
                    // make sure that all extentions are checked
                    GS3 = GS3 + ".*"
                endif
                s1 = ""
                if FileExists(GS3)
                    FileThere = TRUE
                    s1 = PickFile(GS3)
                endif
                if not Length(s1)
                    if not PathQualified        // path not specified?
                        //paths different?
                        if Lower(SplitPath(GS3, _DRIVE_ | _PATH_)) <>
                            Lower(SplitPath(CurrFilename(), _DRIVE_ | _PATH_))
                            // try the current directory
                            if FileExists(SplitPath(CurrFilename(),
                                _DRIVE_ | _PATH_) + SplitPath(GS3,
                                _NAME_ | _EXT_))
                                FileThere = TRUE
                                s1 = PickFile(SplitPath(CurrFilename(),
                                    _DRIVE_ | _PATH_) + SplitPath(GS3,
                                    _NAME_ | _EXT_))
                            endif
                        endif
                    endif
                endif
                GS3 = s1
                break           // exit while loop
            endif
            i = i + 1
        endwhile
        if Length(GS3)          // got something in GS3?
            if not FileExists(GS3) and not PathQualified
               // try the current directory
                GS3 = SplitPath(CurrFilename(), _DRIVE_ | _PATH_)
                    + SplitPath(GS3, _NAME_ | _EXT_)
            endif
        endif
        if Length(GS3)
            if FileExists(GS3)
                break               // then exit loop
            endif
        endif
        if not FileThere
            // force an error message
            PickFile(">")
        endif
        GS3 = ""
    endloop
    return(TRUE)
end mGetValidFileName

/*** mLoadBackupFile ****************************************************
 *                                                                      *
 * Prompt the user for the file to compare.  This may be any filename   *
 * in any subdirectory.  Alternatively, this file may exist inside an   *
 * archived backup ("ARC", "ARJ", "LZH", AND "ZIP" archives are         *
 * currently supported).  Wildcards are also supported, and are         *
 * resolved through picklists.                                          *
 *                                                                      *
 * Once a backup file has been chosen, the screen is split vertically,  *
 * and the backup file is placed into the second window.                *
 *                                                                      *
 * For archived files, the file must first be extracted to a            *
 * temporary subdirectory before it can be used.  The environment is    *
 * first checked to see if a "TEMP=subdirectory" entry exists.  If it   *
 * does exist, then the backup file will be extracted to this           *
 * subdirectory.  If this entry does not exist, then a "TSETEMP"        *
 * subdirectory is created.  The backup file is then extracted into     *
 * this subdirectory, and loaded into Window-2 of TSE.  It is then      *
 * renamed to the same pathname as the original, but with an extention  *
 * of "CBK" (Compare BacKup).  The backup file, and the "TSETEMP"       *
 * subdirectory (if created) are then erased from the disk.             *
 *                                                                      *
 * Called by:   mCompareToBkup()                                        *
 *                                                                      *
 * Enter With:  GS1 is preset to the current filename.                  *
 *              GS2 is preset to the drive:path\ for the current        *
 *              filename.                                               *
 *                                                                      *
 * Returns:     TRUE if successful, otherwise FALSE                     *
 *                                                                      *
 * Notes:       If the "CBK" file already exists in TSE's ring of       *
 *              files, then use that file instead subtracting it again  *
 *              from the disk.  (The CBK file must be deleted before a  *
 *              another one can be extracted from the disk).            *
 *                                                                      *
 ************************************************************************/

integer proc mLoadBackupFile()
    integer TempDirIsMine = 0
    string Extention[5] = ""
    string TempDir[MAXPATH] = ""
    string TempFileName[MAXPATH] = CurrFilename()
    integer OldCursor

    OldCursor = Query(Cursor)
    GS3 = ""
    if not GetGlobalInt("BeginLine1Save")
        GS3 = "*.ZIP"
    endif
    if not mGetValidFileName()             // get a valid filename
        return(FALSE)
    endif

    SetGlobalInt("VWindowFlg", WinDefaultVert)
    OneWindow()
    if GetGlobalInt("VWindowFlg")
        VWindow()
    else
        HWindow()
    endif
    Extention = SplitPath(GS3, _EXT_)
    case Lower(Extention)
        when ".zip", ".lzh", ".arc", ".arj"
            if not FileExists(GS3)
                Warn("File does not exist!")
                return(FALSE)
            endif
            TempDir = GetEnvStr("TEMP")
            if not Length(TempDir)
                TempDir = GS2 + "TSETEMP"
                TempDirIsMine = TRUE
            else
                if TempDir[Length(TempDir)] == "\"
                    TempDir = SubStr(Tempdir, 1, Length(TempDir) - 1)
                endif
                // does the stated subdirectory exist?
                if not mDirExists (TempDir)
                    // no, then create my own!
                    TempDir = GS2 + "TSETEMP"
                    TempDirIsMine = TRUE
                endif
            endif
            if TempDirIsMine
                if not mDirExists(TempDir)
                    Dos ("mkdir " + TempDir, _DONT_CLEAR_|_DONT_PROMPT_)
                endif
            endif
            Set(Cursor, OFF)
            mPopWinCentered(29, 4, 4, "MESSAGE", Query(CurrWinBorderAttr))
            Set(Attr, Query(TextAttr))
            ClrScr()
            Write(" Decompressing backup file")
            GotoXY(1, 2)
            Write(" Please wait...")
            case Lower(Extention)
                when ".zip"
                    // Pkunzip must be in the path (or the same directory) for this to work
                    // or a rather BOGUS "FILE NOT FOUND" error message will result.
                    Dos ("PKUNZIP -o " + GetShortFilename(GS3) + " " + GetShortFilename(GS1) + " " + GetShortFilename(TempDir+"\") + ">NUL",
                        _DONT_CLEAR_ | _DONT_PROMPT_)
                when ".lzh"
                    Dos ("LHA e " + GetShortFilename(GS3) + " " + GetShortFilename(TempDir+"\") + " " + GetShortFilename(GS1) + ">NUL",
                        _DONT_CLEAR_ | _DONT_PROMPT_)
                when ".arj"
                    Dos ("ARJ e " + GetShortFilename(GS3) + " " + GetShortFilename(TempDir+"\") + " " + GetShortFilename(GS1) + ">NUL",
                        _DONT_CLEAR_ | _DONT_PROMPT_)
                when ".arc"
                    if FileExists(TempDir + "\" + GS1)
                        EraseDiskFile(TempDir + "\" + GS1)
                    endif
                    Dos ("PKXARC " + GetShortFilename(GS3) + " " + GetShortFilename(GS1) + " " + GetShortFilename(TempDir+"\") + ">NUL",
                        _DONT_CLEAR_ | _DONT_PROMPT_)
            endcase
            PopWinClose()
            Set(Cursor, OldCursor)
            if not FileExists(TempDir + "\" + GS1)
                Warn(GS1, " not found in ", GS3)
                return(FALSE)
            endif
            if EditFile(QuotePath(TempDir + "\" + GS1))
                // assume this CBK already exists in current dir, and say "YES"
                // to the overwrite query when changing the name to it.
                PushKey(<Y>)
                ChangeCurrFilename(GS2 + SplitPath(CurrFilename(), _NAME_)
                    + ".cbk")
                mIsEscKeyPressed()          // flush the <Y> key (if not needed)
                FileChanged(FALSE)          // say no change occurred in file
            endif
            EraseDiskFile(TempDir + "\" + GS1)
            if TempDirIsMine
                Dos ("rmdir " + QuotePath(TempDir), _DONT_CLEAR_ | _DONT_PROMPT_)
            endif
        otherwise
            if Lower(GS3) == Lower(TempFileName)
                Message("CANNOT COMPARE FILE TO ITSELF!")
                return(FALSE)
            endif
            if FileExists(GS3)
                EditFile(QuotePath(GS3))
            else
                return(FALSE)
            endif
    endcase
    return(TRUE)
end mLoadBackupFile

/*** mCompareToBkup *****************************************************
 *                                                                      *
 * Check and see if a "CBK" file is the current filename. If it is,     *
 * try to open the first file found in the ring that matches that       *
 * filename.  If the current filename is not a "CBK" file, then try     *
 * and find a "CBK" file in the editor's ring that matches the current  *
 * filename (minus the extention).  If found, then immediately load it  *
 * it in window-2, in preparation for synchronized comparisons.  If     *
 * not, then call mLoadBackupFile(), ask the user for a filename, and   *
 * load the requested backup.  This backup may exist inside of an       *
 * archive file ("ARC", "ARJ", "LZH", and "ZIP" formats are supported). *
 *                                                                      *
 * Called by:   main()                                                  *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mCompareToBkup()
    integer WasBackup = 0

    // current file is the CBK file?
    if CurrExt() == ".cbk"
        WasBackup = 1                       // flag backup file active

        // switch main window to original file (best guess!)
        mGetNameFromRing(Splitpath(CurrFilename(), _NAME_))

        // still editing the CBK file?
        if CurrExt() == ".cbk"
            Warn("Sorry, the original file is no longer loaded,")
            return()
        endif
    endif
    GS1 = Splitpath(CurrFilename(), _NAME_ | _EXT_)
    GS2 = Splitpath(CurrFilename(), _DRIVE_ | _PATH_)
    GS3 = GS2 + SplitPath(CurrFilename(), _NAME_) + ".cbk"
    BegLine()
    if GetBufferID(GS3)                 // is a CBK file already extracted?
        OneWindow()
        UnHook(terminate)               // temporarily re-enable event
        ExecHook(_ON_CHANGING_FILES_)   // tell COLORS macro about it!
        ExecHook(_IDLE_)                // give COLORS a background time slice
        Hook(_ON_CHANGING_FILES_, terminate)    // disable event again
        if GetGlobalInt("VWindowFlg")
            VWindow()
        else
            HWindow()
        endif
        GotoWindow(2)
        EditFile(GS3)                       // edit the CBK file now
        BegLine()
        GotoWindow(1)
        ScrollToRow(Query(WindowRows) / 2)
        GotoWindow(2)
        ScrollToRow(Query(WindowRows) / 2)

        // restore macro's previous values
        BeginLine1 = GetGlobalInt("BeginLine1Save")
        BeginLine2 = GetGlobalInt("BeginLine2Save")
        EndLine1 = GetGlobalInt("EndLine1Save")
        EndLine2 = GetGlobalInt("EndLine2Save")
    else
        if not mLoadBackupFile()
            GotoWindow(1)
            OneWindow()
            return()
        endif
    endif
    GotoWindow(2)
    CID2 = GetBufferID()            // get the backup file ID
    GotoWindow(1)
    CID1 = GetBufferID()            // get the original file ID
    if WasBackup
        GotoWindow(2)               // if started as backup, stay in backup
    endif
    UpdateDisplay()
    temp = CreateTempBuffer()
    mMarkDifferenceText(TRUE)
    ScrollToRow(Query(WindowRows) / 2)  // try to center the cursor line
    FlashMessage('CMPFILES Loaded -- press <F10> for the Menu System',
        TRUE, 1)
    mProcessKeystrokes()
    AbandonFile(temp)
end mCompareToBkup

/*** Main ***************************************************************
 *                                                                      *
 * This is the main entry point for Cmp2BkUp.  When the macro           *
 * completes, it will then be purged from memory.                       *
 *                                                                      *
 * Called by:   TSE as an external macro.                               *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       This is the entry point, and the purge point for this   *
 *              entire macro collection.                                *
 *                                                                      *
 ************************************************************************/

proc WhenLoaded()
    cmp2bkup_file_history = GetFreeHistory("Cmp2bkup:SecondaryFile")
end

proc Main()
    Hook(_ON_CHANGING_FILES_, terminate)    // disable event
    mCompareToBkup()            // start things rolling now
    PurgeMacro(CurrMacroFilename())      // purge the macro
    unhook(terminate)           // re-enable events
end Main
