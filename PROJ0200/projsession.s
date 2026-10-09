// PROJ0200 1.0.0.0.168 session integration; OpenAI Codex (GPT-6).
// Adapted from Ian Campbell PROJECTS, supplied with TSE Potpourri.
/*************************************************************************
  Projects    Project management macro for saving and restoring files

  Author:     Ian Campbell (Contributing User)

  Date:       Jun 16, 1993 (Original: Ian Campbell)
              Jul 15, 1994 (Revised: Ian Campbell)
              Sep  8, 1997 Add support for filenames with embedded spaces,
                            first pass.
              Feb  8, 2002 JHB - Allow for non OEM fonts or 3DChars in
                           Project Listbox title.
              June    2003 SEM - on empty cmdline check, also
                            check for piped input.

  Version:    1.00

  Overview:

  Project management macro for TSE.  This macro will save currently
  loaded files and several pre-defined editing variables as a named
  project.  The macro may then be run to reload the previously saved
  files for a given project.

  Keys:
        <Ctrl K><M>         ShowMainMenu()
        <Ctrl K><P>         SaveProjectFiles()
        <Ctrl K><A>         SaveProjectFilesAndExit()

  Usage notes:

  Executing Project will prompt the user with a menu allowing PROJECTS
  to be added to the AutoLoad list.  Adding PROJECTS to the AutoLoad
  list will allow projects from the command line or from an initial
  picklist each time the editor is executed.

  To make changes to this macro or assign pre-defined functions to
  keys, see the "User Configurable Area" below.

  This file contains source for SAVING/RESTORING project information.
  Projects are stored in a PRJ subdirectory located just after the
  directory where the PROJECTS macro is located (eg) C:\TSE\MAC\PRJ.

  Now, when you save a project, you will be presented with a message
  box asking you for a project name (!!LAST!! is the default) Note
  that you should select your own name for the project, since !!LAST!!
  will be overwritten each time a project is saved.  That's it --
  project information will be saved, and made available for later
  restoration.  This allows for NEAR SEAMLESS EDITING across sessions.

  It is UNNECESSARY to change into the PRJ subdirectory to restart a
  project.  Simply type "e projectname" (with or without the ".PRJ"
  extension), and TSE will automatically open that project for you --
  REGARDLESS OF THE CURRENT DIRECTORY SETTING. (Note also that it is
  NOT necessary to have the "PRJ" subdirectory in your path
  statement).

  Although this is convenient, there is ANOTHER WAY.  Every time a
  project is saved, TWO project files are created -- one with the
  project name that you assign when you exit the editor, and the other
  with the name "!!LAST!!.PRJ".  Since an "!" is near the beginning of
  the alphabet, this file should always be the first file in a
  picklist of files.  By starting the editor with just "e <enter>",
  this picklist will be displayed.  Simply press <enter> a second time
  to edit the LAST PROJECT FILES, or move through the picklist to
  choose another project.  If you do not wish to edit a project, just
  press <Escape> to get the familiar "File(s) to edit" box.

  Saved information is as follows:

  ALL FILENAMES currently being edited.
  ALL STANDARD BOOKMARKS across ALL files.
  ALL AUDIT BOOKMARKS across ALL files.
  ALL KEYSTROKE MACROS (including scrap macro).
  The CURRENT DRIVE AND DIRECTORY.
  The VIDEO MODE (25, 28, 43, or 50 lines).
  The MAIN CLIPBOARD DATA (all marking types).
  Up to 26 NAMED CLIPBOARDS (single characters "A" through "Z" only).
  Any MARKED BLOCK (all marking types).
  The state of INSERT.
  The state of AUTOINDENT.
  The state of WORDWRAP.
  The state of the RIGHT MARGIN.
  The state of the HEX display function.
  The state of the BINARY display function.
  ALL HISTORY information.

*************************************************************************/

/************************************************************************
 *                                                                      *
 * String Globals                                                       *
 *                                                                      *
 ************************************************************************/

string ProjectName[255] = ""     // name of the project goes here

/************************************************************************
 *                                                                      *
 * Forward Procedures                                                   *
 *                                                                      *
 ************************************************************************/

forward string proc mGetMacroDir()
forward integer proc mSaveProjectFiles()
forward proc mMakeProjGlobal()
forward proc mSaveProjectFilesAndExit()
forward proc mFindaWordAtCursor(string s)
forward proc mGoNextSearchMark()
forward proc mGoPrevSearchMark()
forward proc mListOpenFiles()
forward proc mChangeProject()
forward proc mGrowProject()
forward proc mRestoreSession()
forward proc mSessionRestoreCheck()
forward proc mToggleBuffers()
forward proc mSuperFindWordAtCursor(string s)
forward proc mRecentFilesTracking()
forward proc mTrackFileChanges()

/************************************************************************
 *                                                                      *
 * Integer Globals                                                      *
 *                                                                      *
 ************************************************************************/

integer ProjectChkReqd = FALSE,     // permission to restore any project file
        EditorVersionOK = TRUE,     // TSE version matches one in project file
        EditorVersionMatch = TRUE,  // TSE version matches one in project file
        LockOutDoubleAudit = FALSE,
        UseBeforeValues = FALSE,
        BeforeCommandAuditID = 0,
        BeforeCommandAuditLine = 0,
        BeforeCommandAuditColumn = 0,
        BeforeCommandAuditXoffset = 0,
        BeforeCommandAuditRow = 0,
        PreviousID = 0,
        CurrentID = 0,
        SaveFileList,
        RestoreFileList

/*** mDirExists *********************************************************
 *                                                                      *
 * Check for the existence of a directory and return non zero if it     *
 * does exist.                                                          *
 *                                                                      *
 * Called by:   mSaveProjectFiles()                                     *
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

/*** mCurrFilenameCaps **************************************************
 *                                                                      *
 * Returns the current filename in upper case format.                   *
 *                                                                      *
 * Called by:   mSaveFilesScreenCoords() mWriteOutABookMark(),          *
 *              mAddMarkedBlocks()                                      *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     the current filename in upper case.                     *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

string proc mCurrFilenameCaps()
    return(CurrFilename())
end mCurrFilenameCaps


/*** DEFINES --- CONSTANTS AND STRINGS FOR PROJECTS *********************
 *                                                                      *
 * SOFTWARE:    PROJECTS                                                *
 * VERSION:     1.00                                                    *
 * DATE:        July 23, 1993                                           *
 * REV. DATE:   July 15th, 1994                                         *
 * AUTHOR:      Ian Campbell                                            *
 * TYPE:        Include file for PROJECTS                               *
 *                                                                      *
 ************************************************************************/

constant BEGINNING = 0,
         ENDING = 1,
         SPACE = 32,
         EQUALS = 61,
         BOOKMARKCOUNT = 26,
         AUDITBOOKMARKCOUNT = 26,
         SysBufferDelete = 3,
         MacroBuffer = 4,
         SYS_BUFFER_HISTORY = 6,
         Alt = 1,
         Ctrl = 2,
         Shift = 3,
         MaxFindOpt = 12

string StrToggleBuffer[] = "ToggleBuffer"
string StrBlockType[] = "BlockType"
string StrInclusive[] = "Inclusive"
string StrNonInclusive[] = "NonInclusive"
string StrLine[] = "Line"
string StrColumn[] = "Column"
string StrBlockBegCol[] = "BlockBegCol"
string StrBlockBegLine[] = "BlockBegLine"
string StrBlockEndCol[] = "BlockEndCol"
string StrBlockEndLine[] = "BlockEndLine"
String StrClipBoardName[] = "ClipBoardName"
string StrTSEPROJECT[] = "TSEPROJECT"
string StrCurrentDir[] = "CurrentDir"
string StrInsert[] = "Insert"
string StrAutoIndent[] = "AutoIndent"
string StrWordWrap[] = "WordWrap"
string StrRightMargin[] = "RightMargin"
string StrWindowHeight[] = "WindowHeight"
string StrFILENAMES[] = "FILENAMES"
string StrFILENAME[] = "FILENAME"
string StrCursorLine[] = "CursorLine"
string StrCursorRow[] = "CursorRow"
string StrCursorColumn[] = "CursorColumn"
string StrCursorXoffset[] = "CursorXoffset"
string StrBOOKMARK[] = "BOOKMARK"
string StrBookMarkFileName[] = "BookMarkFileName"
string StrBookMarkLine[] = "BookMarkLine"
string StrBookMarkColumn[] = "BookMarkColumn"
string StrBookMarkXoffset[] = "BookMarkXoffset"
string StrBookMarkRow[] = "BookMarkRow"
string StrMARKEDBLOCK[] = "MARKEDBLOCK"
string StrBlockFilename[] = "BlockFilename"
string StrBOOKMARKS[] = "BOOKMARKS"
string StrCLIPBOARD[] = "CLIPBOARD"
string StrClipBoards[] = "ClipBoard(s)"
string StrState[] = "State"
string StrEditorVersion[] = "EditorVersion"
string StrBinary[] = "Binary"
string StrHexDisplay[] = "HexDisplay"
string BookMarkMinus[] = "BookMark-"
string MarkedSpaceBlock[] = "Marked Block"
string StrMain[] = "Main"
string StrRestoring[] = "Restored "
string StrSaving[] = "Saving "
string StrPrjDir[] = "PRJ\*.PRJ"
string StrBufferListSort[] = "BufferSort"
string StrLast[] = "!!LAST!!"
string StrHistories[] = "Histories"
string StrSysBufferName[] = "SysBufferName"
string StrSYSTEMBUFFERS[] = "SYSTEM BUFFERS"
string StrMacroName[] = "MacroName"
string StrProjectName[] = "PROJ0200_SessionName"
string PrjRecent[] = "+++PROJ0200SessionRecent+++"
string CrossFileSearch[] = "Multi-File Search for:"
string ProjFiles[] = "+++PROJ0200SessionFiles+++"
string StrKeyMacros[] = "Key Macro(s)"
string StrSearch1[] = "Options [BGLIW"
string StrSearch2[] = "X] (Back Global Local Ignore-case Words "
string StrSearch3[] = "reg-eXp):"
string Str_Replace[] = "No-promp "

/*** AUDITPRJ -- SUPPORT MACROS FOR PROJECTS ****************************
 *                                                                      *
 * SOFTWARE:    PROJECT                                                 *
 * VERSION:     1.00                                                    *
 * DATE:        June 15, 1993                                           *
 * REV. DATE:   July 15th, 1994                                         *
 * AUTHOR:      Ian Campbell                                            *
 * TYPE:        Include file for PROJECTS                               *
 *                                                                      *
 ************************************************************************
 *                                                                      *
 * This file contains source for the audit bookmark routines.  These    *
 * routines allow an auditmark to be automatically dropped every time   *
 * an action is taken which allows a significant position change to     *
 * occur within the edited files.  Auditmarks are circular, in that the *
 * oldest one is flushed when a new one is created.  Routines allow the *
 * bookmarks to be sequentially accessed with the touch of a key, one   *
 * to move forward, and one to move backward through the auditmarks.    *
 *                                                                      *
 * By using this automated approach, I am ALWAYS able to backtrack.     *
 * This is especially useful when multiple files are loaded, and the    *
 * SuperSearch() routine is utilized.                                   *
 *                                                                      *
 * Note that these routines use their own bookmark routines -- they     *
 * in NO WAY INTERFERE WITH OR DEPEND ON THE EXISTING TSE BOOKMARK      *
 * ROUTINES.                                                            *
 *                                                                      *
 ************************************************************************/

/************************************************************************
 *                                                                      *
 * Integer globals                                                      *
 *                                                                      *
 ************************************************************************/

// index to next bookmark available (1 - AUDITBOOKMARKCOUNT)
integer BookMarkIndex = 1
integer AuditLineMark = -1      // search line number from mGetScreenMarks()
integer AuditColumnMark = -1    // search column number from mGetScreenMarks()
integer AuditIDMark = -1        // the buffer ID number from mGetScreenMarks()
integer AuditXoffsetMark = -1   // the Xoffset number from mGetScreenMarks()
integer AuditRowMark = -1       // the row number from mGetScreenMarks()

/************************************************************************
 *                                                                      *
 * String Globals                                                       *
 *                                                                      *
 ************************************************************************/

string ValidMarks[] = "00000000000000000000000000" // one of 26 audit bookmarks
string      AuditIDMarks[26*3] = "ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ"
string    AuditLineMarks[26*4] = "ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ"
string  AuditColumnMarks[26*2] = " ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ"
string AuditXoffsetMarks[26*2] = "ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ    ÿÿÿÿÿÿ"
string     AuditRowMarks[26*1] = "ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ      ÿ"

/*** mWriteAuditMark ****************************************************
 *                                                                      *
 * Save the current screen position integers in multiple strings to     *
 * compensate for the lack of integer indexing in TSE.                  *
 *                                                                      *
 * Called by:   mPlaceAuditMark()                                       *
 *                                                                      *
 * Enter With:  The string to fake the index with, the audit bookmark   *
 *              integer value, and the bookmark index (1 to 26)         *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       This routine compensates for the lack of integer        *
 *              indexing by substituting four strings and using their   *
 *              combined values as a 32 bit integer index value.        *
 *                                                                      *
 ************************************************************************/

proc mWriteAuditMark(var string AuditMarkString, integer d, integer index,
        integer size)
    string s[4] = ""
    integer i = 1, StringIndex
    /*
     Translate the 32 bit integer into a four byte string in s,
     lease significant byte first...
    */
    while i <= size
        s = SubStr(s, 1, i - 1)
            + Chr((d shr (i - 1) * 8) & 0xff)
                + SubStr(s, i + 1, SizeOf(s) - i)
        i = i + 1
    endwhile
    StringIndex = (index - 1) * size
    AuditMarkString = SubStr(AuditMarkString, 1, StringIndex)
        + s + SubStr(AuditMarkString, StringIndex + size + 1,
            (26 * size) - (StringIndex + size))
end mWriteAuditMark

/*** mReadAuditMark *****************************************************
 *                                                                      *
 * Audit bookmarks are stored as four byte characters in a long 104     *
 * byte string.  Strings were used because TSE offers no indexing for   *
 * integers, but does offer indexing for strings.                       *
 *                                                                      *
 * Called by:   mGetAuditMark()                                         *
 *                                                                      *
 * Enter With:  The string to index into (there are currently five      *
 *              different 104 byte strings), and the bookmark index     *
 *              into the string (1 of 26)                               *
 *                                                                      *
 * Returns:     The 32 bit integer value of the audit information.      *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

integer proc mReadAuditMark(string AuditMarks, integer index, integer size)
    integer i = 0,
            BookMarkValue = 0,
            StringIndex = (index - 1) * size

    while i < size
        BookMarkValue = BookMarkValue | (Asc(AuditMarks[StringIndex + i + 1])
            shl (i * 8))
        i = i + 1
    endwhile
    return(BookMarkValue)
end mReadAuditMark

/*** mPlaceAuditMark ****************************************************
 *                                                                      *
 * Save the current screen position in the form of an audit bookmark.   *
 *                                                                      *
 * Called by:   mSetScreenMark(), mRestoreFilesMarkCoords()             *
 *                                                                      *
 * Enter With:                                                          *
 *                                                                      *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

//proc mPlaceAuditMark(integer index)
proc mPlaceAuditMark(integer index, integer fid, integer MyLine,
        integer MyColumn, integer MyXoffset, integer MyRow)

    if UseBeforeValues
        fid = BeforeCommandAuditID
        MyLine = BeforeCommandAuditLine
        MyColumn = BeforeCommandAuditColumn
        MyXoffset =  BeforeCommandAuditXoffset
        MyRow = BeforeCommandAuditRow
    endif
    mWriteAuditMark(AuditIDMarks, fid, index, 3)
    mWriteAuditMark(AuditLineMarks, MyLine, index, 4)
    mWriteAuditMark(AuditColumnMarks, MyColumn, index, 2)
    mWriteAuditMark(AuditXoffsetMarks, MyXoffset, index, 2)
    mWriteAuditMark(AuditRowMarks, MyRow, index, 1)
end mPlaceAuditMark

/*** mGetAuditMark ******************************************************
 *                                                                      *
 * This routine retrieves bookmark information from all five 104 byte   *
 * strings, and places it into five globally accessable integers.       *
 *                                                                      *
 * Called by:   mGoAuditMark(), mGetScreenMarks()                       *
 *                                                                      *
 * Enter With:  The bookmark index                                      *
 *                                                                      *
 * Returns:     nothing -- rather, the data is stored in global         *
 *              integers.                                               *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mGetAuditMark(integer index)
    AuditIDMark = mReadAuditMark(AuditIDMarks, index, 3)
    AuditLineMark = mReadAuditMark(AuditLineMarks, index, 4)
    AuditColumnMark = mReadAuditMark(AuditColumnMarks, index, 2)
    AuditXoffsetMark = mReadAuditMark(AuditXoffsetMarks, index, 2)
    AuditRowMark = mReadAuditMark(AuditRowMarks, index, 1)
end mGetAuditMark

/*** mGoAuditMark *******************************************************
 *                                                                      *
 * Positions the screen to the one of AUDITBOOKMARKCOUNT audit marks.   *
 *                                                                      *
 * Called by:   mGoNextSearchMark(), mGoPrevSearchMark()                *
 *              mSaveMarkInformation()                                  *
 *                                                                      *
 * Enter With:  integer 1 - AUDITBOOKMARKCOUNT                          *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mGoAuditMark(integer index, integer load)
    LockOutDoubleAudit = TRUE
    mGetAuditMark(index)
    GotoBufferID(AuditIDMark)
    if load
        EditFile(CurrFilename())
    endif
    GotoLine(AuditLineMark)
    GotoColumn(AuditColumnMark)
    GotoXoffset(AuditXoffsetMark)
    ScrolltoRow(AuditRowMark)
end mGoAuditMark

/*** mBookMarkIndexPlusOne **********************************************
 *                                                                      *
 * Advance the bookmarks by one.                                        *
 *                                                                      *
 * Called by:   mSyncBookMarks(), mSetScreenMarks(),                    *
 *              mGoNextSearchMark(), mRestoreBookmark()                 *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     the new bookmark index                                  *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

integer proc mBookMarkIndexPlusOne()
    return (iif(BookMarkIndex >= AUDITBOOKMARKCOUNT, 1, BookMarkIndex + 1))
end mBookMarkIndexPlusOne

/*** mBookMarkIndexMinusOne *********************************************
 *                                                                      *
 * Decrement the bookmarks by one.                                      *
 *                                                                      *
 * Called by:   mSyncBookMarks(), mSetScreenMarks(),                    *
 *              mGoNextSearchMark()                                     *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     the new bookmark index                                  *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

integer proc mBookMarkIndexMinusOne()
    return (iif(BookMarkIndex > 1, BookMarkIndex - 1, AUDITBOOKMARKCOUNT))
end mBookMarkIndexMinusOne

/*** mSetScreenMark *****************************************************
 *                                                                      *
 * Sets/validates/invalidates a new bookmark for the current            *
 * screen. String ValidMarks is updated by this procedure.              *
 * Although a bookmark is always set, if invalidated, it will not       *
 * be used as an audit bookmark. BookMarkIndex is not changed by        *
 * this routine.                                                        *
 *                                                                      *
 * Called by:   mSetScreenMarks(), mRestoreBookmark()                   *
 *                                                                      *
 * Enter With:  valid = TRUE, if the mark is to be set, otherwise clear *
 *              the mark.                                               *
 *              index = the number of the mark that is to be set.       *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

// isValid = valid/not valid = create/remove a bookmark
// index = a 1 - AUDITBOOKMARKCOUNT index into the bookmark
proc mSetScreenMark(integer isValid, integer index)
    string ReadValidMarks[AUDITBOOKMARKCOUNT] = ValidMarks

    if (index >= 1) and (index <= AUDITBOOKMARKCOUNT)
        ValidMarks = SubStr(ReadValidMarks, 1, index - 1) + Str(isValid)
            + SubStr(ReadValidMarks, index + 1, AUDITBOOKMARKCOUNT - index)
    endif
end mSetScreenMark

/*** mGetScreenMarks ****************************************************
 *                                                                      *
 * A check is made to see if the index is valid.  If not valid, a       *
 * -1 is placed in AuditColumnMark and AuditLineMark globals. The       *
 * routine then returns the following global values about the audit     *
 * bookmark's position:                                                 *
 *                                                                      *
 * AuditLineMark                                                        *
 * AuditColumnMark                                                      *
 * AuditIDMark                                                          *
 * AuditXoffsetMark                                                     *
 * AuditRowMark                                                         *
 *                                                                      *
 * Called by:   mSetScreenMarks(), mGoPrevSearchMark()                  *
 *              mGoNextSearchMark()                                     *
 *                                                                      *
 * Enter With:  index = 1 of AUDITBOOKMARKCOUNT audit bookmarks.        *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mGetScreenMarks(integer index)
    if index >= 1 and index <= AUDITBOOKMARKCOUNT
        if ValidMarks[index] == "0"
            AuditColumnMark = -1        // set invalid audit marks
            AuditLineMark = -1          // set invalid audit marks
        else
            // get audit mark information
            mGetAuditMark(index)
        endif
    endif
end mGetScreenMarks

/*** mSyncBookMarks *****************************************************
 *                                                                      *
 * If SyncChar equals ENDING, advance BookMarkIndex to the end of       *
 * the bookmarks (default position). If SyncChar equals BEGINNING,      *
 * retreat BookMarkIndex to the beginning of the bookmarks.             *
 *                                                                      *
 * Called by:   mSetScreenMarks(), mSaveMarkInformation(),              *
 *              mSessionRestoreCheck()                                  *
 *                                                                      *
 * Enter With:  SyncChar = BEGINNING or ENDING.                         *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mSyncBookMarks(integer SyncChar)
    integer i

    if SyncChar == ENDING   // advance to the end of the bookmarks?
        i = 1               // the range is 1 to AUDITBOOKMARKCOUNT
        while i <= AUDITBOOKMARKCOUNT
            if ValidMarks[BookMarkIndex] == "0"
                break
            endif
            // advance to point at the next bookmark
            BookMarkIndex = mBookMarkIndexPlusOne()
            i = i + 1
        endwhile
    else                    // backup to the first bookmark
        i = 1
        while i <= AUDITBOOKMARKCOUNT
            if ValidMarks[mBookMarkIndexMinusOne()] == "0"
                break
            endif
            // retreit to the beginning of the bookmarks
            BookMarkIndex = mBookMarkIndexMinusOne()
            i = i + 1
        endwhile
    endif
end mSyncBookMarks

/*** mSetScreenMarks ****************************************************
 *                                                                      *
 * Make sure we're at the end of the bookmarks. Get the cursor          *
 * coordinates for the previous bookmark.  Don't allow two              *
 * sequential bookmarks to have the same coordinates -- simply          *
 * overwrite the previous one if this happens.  Write the new           *
 * bookmark, advance the bookmark index, and make sure the next         *
 * bookmark entry is cleared.                                           *
 *                                                                      *
 * Called by:   mGoPrevSearchMark(), mFindaWordAtCursor(),              *
 *              mSaveProjectFiles(), mFind(), mGotoLine(),              *
 *              mReplace(), DropValidfind()                             *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mSetScreenMarks(integer StopDoubleAudit)
    if StopDoubleAudit
        LockOutDoubleAudit = TRUE
    endif
    if BufferType() <> _SYSTEM_     // do NOT set marks in system buffer
        mSyncBookMarks(ENDING)      // make sure we're at end of bookmarks
        mGetScreenMarks(mBookMarkIndexMinusOne())
        if (UseBeforeValues)
            if BeforeCommandAuditColumn == AuditColumnMark and
                BeforeCommandAuditLine == AuditLineMark and
                    BeforeCommandAuditID == AuditIDMark
                        // dont write duplicate marks, back up and overwrite it!
                        BookMarkIndex = mBookMarkIndexMinusOne()
            endif
        else
            if CurrCol() == AuditColumnMark
                and  CurrLine() == AuditLineMark
                and GetBufferID() == AuditIDMark
                    // dont write duplicate marks, back up and overwrite it!
                    BookMarkIndex = mBookMarkIndexMinusOne()
            endif
        endif
        mSetScreenMark(TRUE, BookMarkIndex)    // Set bookmark to current index
        mPlaceAuditMark(BookMarkIndex, GetBufferID(), CurrLine(),
            CurrCol(), CurrXoffset(), CurrRow())
        BookMarkIndex = mBookMarkIndexPlusOne() // advance the bookmark index
        mSetScreenMark(FALSE, BookMarkIndex)   // Clear the next bookmark
    endif
end mSetScreenMarks

/*** mGoPrevSearchMark **************************************************
 *                                                                      *
 * Drop a new audit bookmark if first reversal.  Go back to the         *
 * previous audit bookmark.                                             *
 *                                                                      *
 * Called by:   Map this function directly to a key / key sequence.     *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mGoPrevSearchMark()
    // if pointing at end of the marks, this will return -1's
    mGetScreenMarks(BookMarkIndex)
    if AuditLineMark == -1 or AuditColumnMark == -1
        // drop a mark to signal the reversal
        mSetScreenMarks(TRUE)
        // back off the count to compensate for this new mark
        BookMarkIndex = mBookMarkIndexMinusOne()
    endif
    mGetScreenMarks(mBookMarkIndexMinusOne())
    if AuditLineMark <> -1 and AuditColumnMark <> -1
        mGoAuditMark(mBookMarkIndexMinusOne(), TRUE)
        BookMarkIndex = mBookMarkIndexMinusOne()
    endif
end mGoPrevSearchMark

/*** mGoNextSearchMark **************************************************
 *                                                                      *
 * If mGoPrevSearchMark() had been called previously, then              *
 * mGoNextSearchMark() may be called to move back towards the end of    *
 * the bookmark list.                                                   *
 *                                                                      *
 * Called by:   Map this function directly to a key.                    *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mGoNextSearchMark()
    mGetScreenMarks(BookMarkIndex)
    if AuditLineMark == -1 or AuditColumnMark == -1
        return()
    endif
    BookMarkIndex = mBookMarkIndexPlusOne()
    mGetScreenMarks(BookMarkIndex)
    if AuditLineMark <> -1 and AuditColumnMark <> -1
        mGoAuditMark(BookMarkIndex, TRUE)
        // look ahead
        mGetScreenMarks(mBookMarkIndexPlusOne())
        if AuditLineMark == -1 or AuditColumnMark == -1
            BookMarkIndex = mBookMarkIndexPlusOne()
        endif
    endif
end mGoNextSearchMark

/*** mRestoreBookmark ***************************************************
 *                                                                      *
 * This routine is called by mRestoreFilesMarkCoords().  Its purpose is *
 * to restore bookmarks from the project file at startup only.          *
 *                                                                      *
 * Called by:   mRestoreFilesMarkCoords                                 *
 *                                                                      *
 * Enter With:                                                          *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mRestoreBookmark(integer index, integer fid, integer MyLine,
        integer MyColumn, integer MyXoffset, integer MyRow)
    integer MyID = GetBufferID()

    GotoBufferID(fid)
    mSetScreenMark(TRUE, index)
    mPlaceAuditMark(index, fid, MyLine, MyColumn, MyXoffset, MyRow)
    Message("Restored Audit BookMark-", index, " in "
        + CurrFileName())
    GotoBufferID(MyID)
end mRestoreBookmark


/*** SEDITPRJ -- SUPPORT MACROS FOR PROJECTS ****************************
 *                                                                      *
 * SOFTWARE:    PROJECTS                                                *
 * VERSION:     1.00                                                    *
 * DATE:        June 15, 1993                                           *
 * REV. DATE:   July 15th, 1994                                         *
 * AUTHOR:      Ian Campbell                                            *
 * TYPE:        Include file for PROJECTS                               *
 *                                                                      *
 ************************************************************************/

/*** mPickFileDetete ****************************************************
 *                                                                      *
 * Flags that a delete key was pressed, and pushes an enter key to      *
 * exit the picklist.                                                   *
 *                                                                      *
 * Called by:   Tied to a key in the PickFileDeletions() keydef.        *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

integer DelFlag = FALSE
integer EndOfLine = FALSE
proc mPickFileDetete()
    DelFlag = TRUE
    EndProcess(1)
end mPickFileDetete

keydef PickFileDeletions
    <del>       mPickFileDetete()
    <GreyDel>   mPickFileDetete()
end PickFileDeletions

/*** mPickDirStartup ****************************************************
 *                                                                      *
 * Used to add deletions to the PickDir routine, as well as a           *
 * WindowHeader() and a WindowFooter() overwrite for the top and        *
 * bottom window box.                                                   *
 *                                                                      *
 * Called by:   hooked by mChooseProject()                              *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/
proc mPickDirStartup()

    string project_message[29]
    string bordertype[6] = "ÄÍÄÍÜÛ"
    string char[1] = " "

    enable(PickFileDeletions)

    // JHB: Start Workaround OEM/3D font usage
    if Query(CurrWinBorderType) in 1..6   // bounds checking
        char = bordertype[Query(CurrWinBorderType)]
    endif

    project_message = Format(char:7:char;"Project List";char:8:char)

    VGotoXY(Query(WindowX1) + (Query(WindowCols) / 2) - Length(project_message) / 2,
        Query(WindowY1) - 1)

    PutOemLine(project_message,Length(project_message),Query(MenuBorderAttr))
    // JHB: End workaround

    WindowFooter(" {Enter}-Load  {Esc}-Cancel  {Delete}-Delete ")
    DelFlag = FALSE
    if not EndOfLine
        Up()
    endif
end mPickDirStartup

proc mPickDirCleanup()
    EndOfLine = iif(NumLines() == CurrLine(), TRUE, FALSE)
end mPickDirCleanup

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
    if ImmediateReturn
        ShowMouse()
        return(OldCursor)
    endif
    ReturnCode = GetKey()
    ShowMouse()
    PopWinClose()
    Set(Cursor, OldCursor)
    return(ReturnCode)
end mMessageBox

proc mBlankScreen()
    integer OldTextAttr, BlankTextAttr, OldEofMarker, OldCursorLineAttr
    integer OldHelpLine = Set(ShowHelpLine, OFF)
    integer OldDisplayBoxed = Set(DisplayBoxed, 0)

    BlankTextAttr = ((Query(TextAttr) & 0xf0)
        | ((Query(TextAttr) & 0x70) shr 4))     // foregnd = backgnd color
    OldTextAttr = Set(TextAttr, BlankTextAttr)
    OldCursorLineAttr = Set(CursorAttr, BlankTextAttr)
    OldEofMarker = Set(ShowEofMarker, FALSE)
    Set(ShowStatusLine, FALSE)
    UpdateDisplay()
    Set(ShowEofMarker, OldEofMarker)
    Set(ShowStatusLine, TRUE)
    Set(TextAttr, OldTextAttr)
    Set(CursorAttr, OldCursorLineAttr)
    Set(ShowHelpLine, OldHelpLine)
    Set(DisplayBoxed, OldDisplayBoxed)
end mBlankScreen

/*** mChooseProject *****************************************************
 *                                                                      *
 * Present a project list box.                                          *
 *                                                                      *
 * Called by:   mChangeProject(), mHandleBlankCommandLine()             *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     The project filename that the user selects, or a null   *
 *              string.                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

string proc mChooseProject()
    string s1[255] = mGetMacroDir() + StrPrjDir
    string s2[255] = ""
    string AskMessage[255]

    while FileExists(s1)
        Hook(_PICKFILE_STARTUP_, mPickDirStartup)
        Hook(_PICKFILE_CLEANUP_, mPickDirCleanup)
        s2 = PickFile(s1)
        Unhook(mPickDirStartup)
        Unhook(mPickDirCleanup)
        if DelFlag
            s2 = SplitPath(s2, _DRIVE_ | _PATH_ | _NAME_)
            mBlankScreen()
            AskMessage = 'Delete project ' + '"'
                + Upper(SplitPath(s2, _NAME_)) + '"' + "  (Y/N) ? "
            loop
                case mMessageBox("PROJECTS", AskMessage, FALSE)
                    when <Escape>, <Enter>, <GreyEnter>, <n>, <Shift N>
                        break
                    when <y>, <Shift Y>
                        EraseDiskFile(s2 + ".prj")
                        EraseDiskFile(s2 + ".clp")
                        EraseDiskFile(s2 + ".kbd")
                        break
                endcase
            endloop
        else
            break
        endif
    endwhile
    return(s2)
end mChooseProject

/*** mChangeProject *****************************************************
 *                                                                      *
 * This macro will save editor context to a project file, save all of   *
 * the files which have changed, and then quit all files.  The user is  *
 * then prompted for another project.                                   *
 *                                                                      *
 * Called by:   Bound to a key                                          *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mChangeProject()
    string fn[255] = mChooseProject()
    integer remaining
    if not Length(fn)
        return()
    endif
    if not mSaveProjectFiles()
        return()
    endif
    RemoveUnloadedFiles()
    remaining = NumFiles() + (BufferType() <> _NORMAL_)
    while remaining
        if BufferType() == _NORMAL_ and not FileChanged()
            ExecHook(_ON_FILE_QUIT_)
            AbandonFile(GetBufferId())
        else
            NextFile(_DONT_LOAD_)
        endif
        remaining = remaining - 1
    endwhile
    ProjectChkReqd = TRUE
    EditFile(QuotePath(fn))
    mSessionRestoreCheck()
    ProjectChkReqd = FALSE
end mChangeProject

/*** mGrowProject *******************************************************
 *                                                                      *
 * The user is prompted for another project.  This project will be      *
 * appended to the original.                                            *
 *                                                                      *
 * Called by:   Bound to a key                                          *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mGrowProject()
    string fn[255]

    fn = mChooseProject()
    if length(fn)
        UnHook(mTrackFileChanges)
        UnHook(mRecentFilesTracking)
        EmptyBuffer(GetBufferID(PrjRecent))
        ProjectChkReqd = TRUE
        EditFile(QuotePath(fn))
        mSessionRestoreCheck()
        ProjectChkReqd = FALSE
        ProjectName = ""            // cancel the project name
        mMakeProjGlobal()
    endif
    UpdateDisplay()
end mGrowProject


/*** LSTFILES --- BUFFER LIST FOR PROJECTS ******************************
 *                                                                      *
 * SOFTWARE:    PROJECTS                                                *
 * VERSION:     1.00                                                    *
 * DATE:        July 23, 1993                                           *
 * REV. DATE:   July 15th, 1994                                         *
 * AUTHOR:      Ian Campbell                                            *
 * TYPE:        Include file for PROJECTS                               *
 *                                                                      *
 ************************************************************************/

constant    NAME = -1,
            PATHNAME = -2,
            EXTENSION = -3,
            BUFFER = -4,
            REVERSE_NAME = -5,
            REVERSE_PATHNAME = -6,
            REVERSE_EXTENSION = -7,
            REVERSE_BUFFER = -8

integer SortFlg = NAME     // the initial sort option is set to "NAME"

integer FileListBuffer, start_file, RecentLine
string TitleMessage[40]

/*** mRecentFilesTracking ***********************************************
 *                                                                      *
 *  This routine keeps track of all the files that have been accessed   *
 *  by the editor, most recent at the top of the list, followed by the  *
 *  older ones.                                                         *
 *                                                                      *
 * Called by:   Hooked during PROJECTS startup.                         *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       Tracks the last 20 files accessed in the                *
 *              "+++PROJ0200SessionRecent+++" system buffer.                        *
 *                                                                      *
 ************************************************************************/

proc mRecentFilesTracking()
    string fn[255] = CurrFilename()
    integer cid = GetBufferId()

    if BufferType() == _NORMAL_
        and GotoBufferId(GetBufferID(PrjRecent))
        if lFind(fn, "^$g")
            KillLine()
        elseif NumLines() > 20
            EndFile()
            KillLine()
        endif
        BegFile()
        InsertLine(fn)
        GotoBufferId(cid)
    endif
end mRecentFilesTracking

/*** mCycleRecentFiles **************************************************
 *                                                                      *
 * Highlight the files that are open, sequentially, in order, within    *
 * the buffer list box.                                                 *
 *                                                                      *
 * Called by:   Assigned to a keystroke in ListKeys keydef              *
 *                                                                      *
 * Enter With:  The direction to move through the recent files          *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mCycleRecentFiles(integer DirectionFwd)
    integer ID = GetBufferID(), i = 1
    string fn[255]

    while i < 20                    // limit this to 20 tries maximum
        i = i + 1
        if GotoBufferID(GetBufferID(PrjRecent))
            GotoLine(RecentLine)
            if DirectionFwd
                if Up()
                    RecentLine = CurrLine()
                else
                    RecentLine = NumLines()
                endif
            else
                if Down()
                    RecentLine = CurrLine()
                else
                    RecentLine = 1
                endif
            endif
            GotoLine(RecentLine)
            fn = rTrim(GetText(1, CurrLineLen()))
        endif
        GotoBufferID(ID)
        if lFind(fn, "GW")
           break
        endif
    endwhile
end mCycleRecentFiles

/*** mFillWithFileNames *************************************************
 *                                                                      *
 * Load all active filenames into a FileListBuffer, and position the    *
 * cursor at the first filename.  Load in either a forward or reverse   *
 * direction, depending upon the DirForward parameter.                  *
 *                                                                      *
 * Called by:   mSortFileNames(), mListOpenFiles()                      *
 *                                                                      *
 * Enter With:  An integer var for the largest filename count,          *
 *              and a boolean value indicating direction for loading    *
 *              the files.                                              *
 *                                                                      *
 * Returns:     A boolean value indicating whether or not a file has    *
 *              changed.                                                *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

integer proc mFillWithFileNames(var integer maxl, var integer LoadedFiles,
        integer DirForward)
    string fn[255]
    integer FileHasChanged, ID = GetBufferID(), n
    string filler[1]

    GotoBufferID(start_file)
    n = NumFiles() + (BufferType() <> _NORMAL_)
    if n == 0
        return(-1)
    endif
    FileHasChanged = 0
    EmptyBuffer(FileListBuffer)
    while n
        fn = CurrFilename()
        if length(fn)
            if length(fn) > maxl
                maxl = length(fn)
            endif
            filler = 'ù'                // assume file not loaded
            if NumLines()
                filler = ' '            // remove the 'ù'
                LoadedFiles = LoadedFiles + 1
            endif
            if FileChanged()
                FileHasChanged = TRUE
                filler = '*'
            endif
            if DirForward
                AddLine(filler + fn, FileListBuffer)
            else
                InsertLine(filler + fn, FileListBuffer)
            endif
        endif
        NextFile(_DONT_LOAD_)
        n = n - 1
    endwhile
    GotoBufferID(FileListBuffer)
    GotoLine(iif(DirForward, 1, NumLines()))
    GotoBufferID(ID)
    return(FileHasChanged)
end mFillWithFileNames

/*** mSortFileNames *****************************************************
 *                                                                      *
 *  Sorts filenames in buffer FileListBuffer according to the           *
 *  SortFlg parameter.  Filenames may be sorted by name, pathname,      *
 *  extension, and buffer order.                                        *
 *                                                                      *
 * Called by:   Many keys defined in keydef ListKeys.                   *
 *                                                                      *
 * Enter With:  The sort flag                                           *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mSortFileNames(integer TheSortFlg)
    string fn[255]
    string fnOrg[255]
    integer ID = GetBufferID(), maxl = 0
    integer LoadedFiles = 0
    integer level

    SortFlg = TheSortFlg
    GotoBufferID(FileListBuffer)
    fnOrg = rTrim(GetText(2, sizeof(fnOrg)))
    BegFile()
    repeat
//        GotoColumn(71)
        GotoColumn(270)
        KillToEol()
        fn = rTrim(GetText(2, sizeof(fn)))
        // we place NAMES (for sorting) starting at column 90
        case SortFlg
            when NAME, REVERSE_NAME
                InsertText(SplitPath(fn, _NAME_ | _EXT_))
            when PATHNAME, REVERSE_PATHNAME
                InsertText(fn)
            when EXTENSION, REVERSE_EXTENSION
                InsertText(SplitPath(fn, _EXT_))
        endcase
    until not Down()
    if SortFlg == BUFFER
        mFillWithFileNames(maxl, LoadedFiles, 1)
        EndFile()
    elseif SortFlg == REVERSE_BUFFER
        mFillWithFileNames(maxl, LoadedFiles, 0)
        EndFile()
    else
        PushBlock()             // save old marking information that might exist
        UnMarkBlock()           // turn off any old marking if it exists
        MarkColumn(1, 270, NumLines(), 524)
        level = Set(MsgLevel, _NONE_)
        Sort(iif(SortFlg < BUFFER, _DESCENDING_ , _DEFAULT_))
        KillBlock()
        Set(MsgLevel, level)
        PopBlock()                  // put back any old marking that might exist
    endif
    lFind(fnOrg, "BW")          // cursor to original filename (srch backwards)
    GotoBufferID(ID)            // back to the original file for a screen update
end mSortFileNames

keydef ListKeys
<Alt N>     mSortFileNames(NAME)
<Alt [>     mSortFileNames(PATHNAME)
<Alt E>     mSortFileNames(NAME)
            mSortFileNames(EXTENSION)
<Alt B>     mSortFileNames(BUFFER)
<Ctrl N>    mSortFileNames(REVERSE_NAME)
<Ctrl P>    mSortFileNames(REVERSE_PATHNAME)
<Ctrl E>    mSortFileNames(REVERSE_NAME)
            mSortFileNames(REVERSE_EXTENSION)
<Ctrl B>    mSortFileNames(REVERSE_BUFFER)
<Alt 0>     mCycleRecentFiles(0)
<Ctrl 0>    mCycleRecentFiles(1)
<F1>        mMessageBox("Buffer List Help",
                '              SORT`'
                + 'FORWARD     FUNCTION        REVERSE``'
                + ' Alt B      Buffer          Ctrl B`'
                + ' Alt E      Extension       Ctrl E`'
                + ' Alt N      Name            Ctrl N`'
                + ' Alt P      Pathname        Ctrl P``'
                + ' Alt 0      Recent Files    Ctrl 0```'
                + 'Press any key...',
                FALSE)
end ListKeys

/*** mListStartup *******************************************************
 *                                                                      *
 * Allows extra sort keys to be defined in the list box.  Allows the    *
 * title message to be colored via the PutHelpLine function, and places *
 * a help message on the bottom of the window.                          *
 *                                                                      *
 * Called by:   Hooked to _LIST_STARTUP_ in mListOpenFiles().           *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       The title for this box is found in string TitleMessage. *
 *                                                                      *
 ************************************************************************/

proc mListStartup()
    enable(ListKeys)
    RecentLine = 1              // point Recent files buffer to the top
    VGotoXY(Query(WindowX1) + (Query(WindowCols) / 2)
        - Length(TitleMessage) / 2,
            Query(WindowY1) - 1)
    PutHelpLine(TitleMessage)
    WindowFooter(" Sort Options: {B},{E},{N},{P},{0}  Help: {F1}")
end mListStartup

/*** mListIt ************************************************************
 *                                                                      *
 * Display all files in the editor's ring.  Allow cursor movement,      *
 * different sorting options, and a file picklist option.               *
 *                                                                      *
 * Called by:   mListOpenFiles()                                        *
 *                                                                      *
 * Enter With:  The window width.                                       *
 *                                                                      *
 * Returns:     Non zero if exited with ENTER, 0 if exited with ESCAPE. *
 *                                                                      *
 * Notes:       The title is stored in string TitleMessage.             *
 *                                                                      *
 ************************************************************************/

integer proc mListIt(integer width)
    integer OldY1 = Query(Y1), ReturnCode

    if (NumLines() + 2) < Query(ScreenRows)
        Set(Y1, ((Query(ScreenRows) + Query(StatusLineAtTop)
            - (NumLines() + 2)) / 2) + 1)
    endif
    if (Length(TitleMessage) + 8) > width
        width = Length(TitleMessage) + 8
    endif
    width = iif(width > Query(ScreenCols), Query(ScreenCols), width)
    ReturnCode = List("", width)
    Set(Y1, OldY1)
    Return(ReturnCode)
end mListIt

/*** mListOpenFiles *****************************************************
 *                                                                      *
 * List Files placed in the editor's internal ring of files.  Hilite    *
 * any changed files with an "*".  Note this is a replacement for       *
 * the same filename in TSE.S.  Many enhancements.                      *
 *                                                                      *
 * Called by:   Bound to the key that mListOpenFiles() used to be       *
 *              bound to (default = <Alt 0>)                            *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

string FileIsChanged[15] = 'Buffer List'
proc mListOpenFiles()
    string fn[255]
    integer maxl = 0,
            LoadedFiles = 0

    start_file = GetBufferId()
    FileListBuffer = CreateTempBuffer()
    GotoBufferID(start_file)
    if FileListBuffer == 0
        return()
    endif
    case mFillWithFileNames(maxl, LoadedFiles, iif(SortFlg==BUFFER, 1, 0))
        when -1
            return()
        when 1
           FileIsChanged = '{*Buffer List}'
    endcase
    GotoBufferID(start_file)
    case SortFlg
        when EXTENSION
            mSortFileNames(NAME)
            mSortFileNames(EXTENSION)
        when REVERSE_EXTENSION
            mSortFileNames(REVERSE_NAME)
            mSortFileNames(REVERSE_EXTENSION)
        otherwise
            mSortFileNames(SortFlg)
    endcase
    // does NOT include the filenames sort list
    Hook(_LIST_STARTUP_, mListStartup)
    GotoBufferID(FileListBuffer)
    TitleMessage = Format(FileIsChanged, ", ",
            NumLines()," Files [", LoadedFiles, "/",
            NumLines() - LoadedFiles, "]")
    if mListIt(maxl + 2)                    // bring up the list box now
        fn = rTrim(GetText(2, 80))          // Access the filename
        if Length(SplitPath(fn, _DRIVE_))   // Legit disk filename?
            EditFile(QuotePath(fn))
        else
            GotoBufferID(GetBufferID(fn))    // Access "special" file in ring
            ExecHook(_ON_CHANGING_FILES_)    // Tell everyone about it
        endif
    else
        GotoBufferID(start_file)
    endif
    UnHook(mListStartup)
    AbandonFile(FileListBuffer)             // done, dump the buffer list
end mListOpenFiles


/*** SRCHPRJ -- SUPPORT MACROS FOR PROJECTS *****************************
 *                                                                      *
 * SOFTWARE:    PROJECTS                                                *
 * VERSION:     1.00                                                    *
 * DATE:        June 15, 1993                                           *
 * REV. DATE:   July 15th, 1994                                         *
 * AUTHOR:      Ian Campbell                                            *
 * TYPE:        Include file for PROJECTS                               *
 *                                                                      *
 ************************************************************************
 *                                                                      *
 * This file contains all of the enhanced search routines,              *
 * including SuperSearch which does a repeat search across              *
 * multiple files.  Note that FINAL history items are duplicated here   *
 * for restoration across project saves.                                *
 *                                                                      *
 ************************************************************************/

/*** mGetLastHistoryStr *************************************************
 *                                                                      *
 * Reach into the history buffer and extract history information for    *
 * a requested item.                                                    *
 *                                                                      *
 * Called by:   FilterFindOptions(), DropValidfind(), mSuperSearch(),   *
 *              mRptFind()                                              *
 *                                                                      *
 * Enter With:  the history type (documented in AddHistoryStr())        *
 *                                                                      *
 * Returns:     a string with the history.                              *
 *                                                                      *
 * Notes:       This routine uses an UNDOCUMENTED TSE buffer.           *
 *                                                                      *
 ************************************************************************/

string proc mGetLastHistoryStr(integer HistoryType)
    return(GetHistoryStr(HistoryType, 1))
end mGetLastHistoryStr

/*** FilterFindOptions **************************************************
 *                                                                      *
 * Add words, regular expressions, and local blocked item, as           *
 * previously set, to the fixed options.                                *
 *                                                                      *
 * Called by:   mSuperSearch(), mRptFind()                              *
 *                                                                      *
 * Enter With:  the direction, and type = 1 for a SuperSearch           *
 *                                                                      *
 * Returns:     a combined set of history and fixed options.            *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

string proc FilterFindOptions(integer direction, integer type)
    string LastFindOptions[MaxFindOpt] = mGetLastHistoryStr(_FINDOPTIONS_HISTORY_)
    string FindOptions[MaxFindOpt] = iif(direction == _BACKWARD_, "B", "+")
    integer i = 1, j = Length(LastFindOptions)

    while i <= j
        case LastFindOptions[i]
            when "L", "l", "C", "c" // local/blocked item, current line
                if type <> 1        // type 1 = SuperSearch, type 0 = others
                    FindOptions = FindOptions + LastFindOptions[i]
                endif
            when "G", "g", "B", "b", "a", "A", "v", "V", "+"
                // just eat these
            otherwise
                FindOptions = FindOptions + LastFindOptions[i]
        endcase
        i = i + 1
    endwhile
    if type == 1
        if i < MaxFindOpt
            FindOptions[i+1] = 'a'
        else
            Warn("Options exceed available space.")
        endif
    endif
    return(FindOptions)
end FilterFindOptions

/*** DropValidfind ******************************************************
 *                                                                      *
 * Checks the word at the cursor between the previous find, and this    *
 * repeat find.  If different, drop an audit bookmark, otherwise don't. *
 *                                                                      *
 * Called by:   mSuperSearch(), mRptFind(), mSuperFind()                *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc DropValidfind()
    integer OrigPos = CurrPos()
    string LastFind[255] = mGetLastHistoryStr(_FIND_HISTORY_|_EDIT_HISTORY_)

    LockOutDoubleAudit = TRUE
    PushBlock()                     // Save current block status
    if MarkWord()                   // Mark the word
        if not lFind(LastFind, "ILG")
            mSetScreenMarks(TRUE)
        endif
    else
        mSetScreenMarks(TRUE)
    endif
    PopBlock()                      // Restore block status
    GotoPos(OrigPos)
end DropValidfind

/*** mHookKiller ********************************************************
 *                                                                      *
 * Temporarily disable the _ON_CHANGING_FILES_ hook.                    *
 *                                                                      *
 * Called by:   mSuperSearch(), mSuperReplace()                         *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mHookKiller()
    BreakHookChain()
end mHookKiller

/*** mSuperSearch *******************************************************
 *                                                                      *
 * Repeat a search for text by scanning either forward or reverse       *
 * through all files in the ring, until a match if found.               *
 * If not AllFilesScan, then only search CROSS files, NOT within the    *
 * current file.                                                        *
 *                                                                      *
 * Called by:   mSuperFind(), mSuperFindWordAtCursor()                  *
 *                                                                      *
 * Enter With:  Find String, Find Options                               *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       This macro will find anything.  Load an entire project  *
 *              and scan across all files in seconds.                   *
 *                                                                      *
 * GDB: 03-07-97 Major revision to use TSE Pro 2.5 functions.           *
 ************************************************************************/

proc mSuperSearch(string LastFind, string LastOptions)

    DropValidfind()

    // Save current buffer ID in case the file is not found
    PushPosition()
    if lFind(LastFind, LastOptions)
        KillPosition()
        UpdateDisplay()
        HiliteFoundText()
        ExecHook(_ON_CHANGING_FILES_)
        return()
    endif
    PopPosition()
    Message(LastFind + " not found.")
end mSuperSearch

/*** mSuperFind *********************************************************
 *                                                                      *
 * Scan across all files in the editor's ring for a text match.  The    *
 * scan may be either forward or reverse through the ring.              *
 *                                                                      *
 * Called by:   This macro is bound to two separate keys -- one for     *
 *              forward, and the other for reverse, (via direction      *
 *              parameters).                                            *
 *                                                                      *
 * Enter With:  direction to scan, 0 for forward, 1 for reverse.        *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       This macro will find anything.  Load an entire project  *
 *              and scan across all files in seconds.                   *
 *                                                                      *
 ************************************************************************/

proc mSuperFind(integer direction)
    string LastFind[255] = mGetLastHistoryStr(_FIND_HISTORY_|_EDIT_HISTORY_)
    string LastOptions[11] = FilterFindOptions(direction, 1)

    mSuperSearch(LastFind, LastOptions)
end mSuperFind

/*** mRptFind ***********************************************************
 *                                                                      *
 * Do a repeat search for text either forward or backwards.             *
 *                                                                      *
 * Called by:   This macro is bound to two separate keys -- one for     *
 *              forward, and the other for reverse, (via direction      *
 *              parameters.                                             *
 *                                                                      *
 * Enter With:  direction to scan, _FORWARD_, OR _BACKWARD_             *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       Unlike SuperSearch, this macro is limited to scanning   *
 *              just the current file.                                  *
 *                                                                      *
 ************************************************************************/

proc mRptFind(integer direction)
    string LastFind[255] = mGetLastHistoryStr(_FIND_HISTORY_|_EDIT_HISTORY_)
    string LastOptions[11] = FilterFindOptions(direction, 0)

    DropValidFind()
    Find(LastFind, LastOptions)
end mRptFind

/*** mFindaWordAtCursor *************************************************
 *                                                                      *
 * Find the word at the cursor.  Set an audit bookmark.  Update         *
 * history lists.                                                       *
 *                                                                      *
 * Called by:   This macro is bound to two separate keys -- one for     *
 *              forward, and the other for reverse.                     *
 *                                                                      *
 *              The forward key binding should look like this:          *
 *              mFindaWordAtCursor('I+')                                *
 *                                                                      *
 *              The backward key bindoing should look like this:        *
 *              mFindaWordAtCursor('IB')                                *
 *                                                                      *
 * Enter With:  "I+" for forward scan, "IB" for backward scan           *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mFindaWordAtCursor(string option)
    if Length(GetWord())
        mSetScreenMarks(TRUE)               // drop a bookmark
        AddHistoryStr(GetWord(), _FIND_HISTORY_|_EDIT_HISTORY_)
        Find(GetWord(), option)
    else
        Find()
    endif
end mFindaWordAtCursor

/*** mSuperFindWordAtCursor *********************************************
 *                                                                      *
 * Find the word at the cursor in a cross file search.  Set an audit    *
 * bookmark.  Update history lists.                                     *
 *                                                                      *
 * Called by:   This macro is bound to two separate keys -- one for     *
 *              forward, and the other for reverse.                     *
 *                                                                      *
 *              The forward key binding should look like this:          *
 *              mSuperFindWordAtCursor('I+')                            *
 *                                                                      *
 *              The backward key bindoing should look like this:        *
 *              mSuperFindWordAtCursor('IB')                            *
 *                                                                      *
 * Enter With:  "I+" for forward scan, "IB" for backward scan           *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mSuperFindWordAtCursor(string option)
    if Length(GetWord())
        mSetScreenMarks(TRUE)               // drop a bookmark
        AddHistoryStr(GetWord(), _FIND_HISTORY_|_EDIT_HISTORY_)
        mSuperSearch(GetWord(), option)
    endif
end mSuperFindWordAtCursor

/*** mFindSuperSearch  **************************************************
 *                                                                      *
 * Does a cross file search.                                            *
 *                                                                      *
 * Called by:   PROJECTS Search Menu                                    *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mFindSuperSearch()
    string s[255] = ""
    string s2[11] = ''

    if Ask(CrossFileSearch, s, _FIND_HISTORY_|_EDIT_HISTORY_)
        if Ask(StrSearch1 + StrSearch2 + StrSearch3,
            s2, _FIND_OPTIONS_HISTORY_|_EDIT_HISTORY_)
                mSuperSearch(s, s2)
        endif
    endif
end mFindSuperSearch

/*** mSuperReplace  *****************************************************
 *                                                                      *
 * Does a cross file Search/Replace.                                    *
 *                                                                      *
 * Called by:   PROJECTS Search menu.                                   *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mSuperReplace()
    string s0[255] = "",
           s1[255] = "",
           s2[11] = '',
           s3[255] = '',
           s4[255] = ''
    integer i,
            n,
            start_file,
            direction = 0,          // assume forward
            OnlyFlg = FALSE,
            AllFlg = FALSE,
            KeyStroke,
            MaxFiles,
            SpaceLen,
            MyKey

    if Ask(CrossFileSearch, s0, _FIND_HISTORY_|_EDIT_HISTORY_)
        if not Length(s0)
            return()
        endif
        if Ask("Replace with:", s1, _REPLACE_HISTORY_|_EDIT_HISTORY_)
            if Ask(StrSearch1 + "N" + StrSearch2 + Str_Replace + StrSearch3,
                s2, _REPLACEOPTIONS_HISTORY_|_EDIT_HISTORY_)
                DropValidfind()
                i = 1
                while i <= Length(s2)
                    if Lower(s2[i]) == 'b'
                        direction = _BACKWARD_
                        break
                    endif
                i = i + 1
                endwhile
                n = NumFiles() + (BufferType() <> _NORMAL_)
                MaxFiles = n
                if n
                    // Save current buffer ID in case the file is not found
                    start_file = GetBufferid()
                    while n
                        Hook(_ON_CHANGING_FILES_, mHookKiller)
                        n = n - 1
                        if direction == _BACKWARD_
                            PrevFile()
                            PushPosition()
                            EndFile()
                        else
                            NextFile()
                            PushPosition()
                            BegFile()
                        endif
                        Unhook(mHookKiller)
                        if KeyPressed()
                            MyKey = GetKey()
                            if MyKey == <Escape>
                                AllFlg = FALSE
                            endif
                        endif
                        if not AllFlg
                            case Query(key)
                                when <q>, <Shift Q>, <o>, <Shift O>, <Escape>
                                break
                            endcase
                            s3 = Format('Search "' + CurrFilename()
                                + '" (Yes/No/Only/Rest/Quit): ')
                            s4 = format(MaxFiles - n, " of ", MaxFiles)
                            SpaceLen = 79 - (Length(s3) + Length(s4))
                            if SpaceLen >= 0
                                s3 = s3 + format(" ":SpaceLen) + s4
                            endif
                            Message(s3)
                            UpdateDisplay()
                            while not KeyPressed()  // GetKey allows _IDLE_ -- inhibit!
                            endwhile
                            OnlyFlg = FALSE
SpinKeys:
                            KeyStroke = GetKey()
                            case KeyStroke
                                when <n>, <Shift N>
                                    PopPosition()
                                    Goto MyNextFile
                                when <o>, <Shift O>
                                    OnlyFlg = TRUE
                                when <y>, <Shift Y>, <Enter>, <GreyEnter>
                                when <r>, <Shift R>
                                    AllFlg = TRUE
                                    s2 = s2 + "N"
                                when <q>, <Shift Q>, <Escape>
                                    OnlyFlg = TRUE
                                    PopPosition()
                                    Goto MyNextFile
                                otherwise
                                    Goto SpinKeys
                            endcase
                        endif
                        if Replace(s0, s1, s2)
                            KillPosition()  // save position of last replace
                            UpdateDisplay()
                            ExecHook(_ON_CHANGING_FILES_)
                            start_file = GetBufferID()
                            if not AllFlg
                                i = 12
                                while i
                                    if KeyPressed()
                                        GetKey()
                                        break
                                    endif
                                    i = i - 1
                                    Delay(1)
                                endwhile
                            endif
                        else
                            PopPosition()
                        endif
MyNextFile:
                        if OnlyFlg
                            break
                        endif
                    endwhile
                    GotoBufferID(start_file)
                endif
            endif
        endif
    endif
end mSuperReplace


/*** SAVEKEYS -- INCLUDE FILE FOR PROJECTS ******************************
 *                                                                      *
 * SOFTWARE:    PROJECTS                                                *
 * VERSION:     1.00                                                    *
 * DATE:        June 15, 1993                                           *
 * REV. DATE:   July 15th, 1994                                         *
 * AUTHOR:      Ian Campbell                                            *
 * TYPE:        Include file for PROJECTS                               *
 *                                                                      *
 ************************************************************************
 *                                                                      *
 * This file contains all of the functions needed to save a keyboard    *
 * macro without requiring any human response to a prompt box.          *
 *                                                                      *
 ************************************************************************/

/*** mFlushKeys *********************************************************
 *                                                                      *
 * Provides a mechanism for flushing TSE's keyboard buffer.             *
 *                                                                      *
 * Called by:   mSaveKeyMacro()                                         *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mFlushKeys()
    while KeyPressed()
        GetKey()
    endwhile
end mFlushKeys

/*** OnSaveKeyMacroStartup **********************************************
 *                                                                      *
 * This handy little hook is activated when the SaveKeyMacro() prompt   *
 * activates, requesting input.  It first clears any info that might    *
 * already be in the prompt box, and then inserts the macro name.       *
 *                                                                      *
 * Called by:   TSE when the prompt box appears                         *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc OnSaveKeyMacroStartup()
    BegLine()
    KillToEol()
    InsertText(SplitPath(ProjectName, _DRIVE_ | _PATH_ | _NAME_) + ".KBD")
end OnSaveKeyMacroStartup

/*** mSaveKeyMacro ******************************************************
 *                                                                      *
 * Feeds the filename into the prompt box for SaveKeyMacro() and        *
 * preloads the keyboard buffer to handle all possible prompts.         *
 *                                                                      *
 * mFlushKeys() is called to initialize the keyboard buffer.            *
 *                                                                      *
 * A "Y" is pushed in case a box appears asking for permission to       *
 * overwrite an existing key macro file.                                *
 *                                                                      *
 * Enter is pushed to tell TSE to accept the filename.                  *
 *                                                                      *
 * The macro is then saved.                                             *
 *                                                                      *
 * Finally, mFlushKeys() is called to flush any remaining keys that     *
 * might be still outstanding, such as the and the "Y" key (as          *
 * mentioned above).                                                    *
 *                                                                      *
 * Called by:   mSaveProjectFiles()                                     *
 *                                                                      *
 * Enter With:  the path of the PRJ subdirectory.                       *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mSaveKeyMacro(string ProjPath)
    integer level

    // wipe out any possible !!last!! key macro
    EraseDiskFile(ProjPath + StrLast + ".KBD")
    Message(StrSaving + StrKeyMacros)
    level = Set(MsgLevel, _NONE_)       // shut down a snit message if no macro to save
    Hook(_PROMPT_STARTUP_, OnSaveKeyMacroStartup)
    mFlushKeys()                // flush editor keystrokes
    PushKey(<Escape>)
    PushKey(<Y>)                // in case "Overwrite existing File" appears
    PushKey(<Enter>)            // terminate the prompt
    SaveKeyMacro()              // try to save the macro now
    Unhook(OnSaveKeyMacroStartup)
    Set(MsgLevel, level)
    mFlushKeys()                // flush editor keystrokes
end mSaveKeyMacro


/*** PRJMENUS -- MENUS FOR PROJECTS *************************************
 *                                                                      *
 * SOFTWARE:    PROJECTS                                                *
 * VERSION:     1.00                                                    *
 * DATE:        May 8th, 1994                                           *
 * REV. DATE:   July 15th, 1994                                         *
 * AUTHOR:      Ian Campbell                                            *
 * TYPE:        Include file for PROJECTS                               *
 *                                                                      *
 ************************************************************************/

String  MyVersion[] = "1.0.0.0.168"

Menu FileMenu()
    history

    "&Open..."                          ,   Editfile()
    ""                                  ,                       ,   Divide
    "&Next"                             ,   NextFile()
    "&Previous"                         ,   PrevFile()
    "&List Open  "                     ,   mListOpenFiles()
    "Current File"                      ,                       ,   Divide
    "&Save"                             ,   SaveFile()
    "Save &As..."                       ,   SaveAs()
    "Save && Qui&t"                     ,   SaveAndQuitFile()
    "&Quit"                             ,   QuitFile()
    "Session snapshots"                 ,                       ,   Divide
    "&Restore session snapshot..."       ,   mRestoreSession()
    "Sa&ve session snapshot..."                  ,   mSaveProjectFiles()
    "Save snapshot && &Exit..."          ,   mSaveProjectFilesAndExit()
    "Save && switch session..."      ,   mChangeProject()
    "Add an&other snapshot's files..."   ,   mGrowProject()
end

Menu SearchMenu()
    history

    "A&udit Bookmarks - Forward"        ,   mGoNextSearchMark()
    "&Audit Bookmarks - Reverse"        ,   mGoPrevSearchMark()
    "Same File"                         ,                       , Divide
    "&Find..."                          ,   find()
    "Re&peat Find - Forward"            ,   mRptFind(_FORWARD_)
    "R&epeat Find - Reverse"            ,   mRptFind(_BACKWARD_)
    "F&ind Word at Cursor - Forward"    ,   mFindaWordAtCursor('I+')
    "Fi&nd Word at Cursor - Reverse"    ,   mFindaWordAtCursor('IB')
    "Repla&ce..."                       ,   Replace()
    "Multi-File"                        ,                       , Divide
    "Fin&d..."                          ,   mFindSuperSearch()
    "Repeat Find - F&orward"            ,   mSuperFind(_FORWARD_)
    "Repeat Find - Re&verse"            ,   mSuperFind(_BACKWARD_)
    "Find &Word at Cursor - Forward"    ,   mSuperFindWordAtCursor('I+')
    "Find Word at Cur&sor - Reverse"    ,   mSuperFindWordAtCursor('IB')
    "&Replace..."                       ,   mSuperReplace()
    ""                                  ,                       , Divide
    "Toggle To Previous Fi&le"          ,   mToggleBuffers()
end

Menu UtilityMenu()
    history

    "&View Clipboard  "        ,   ExecMacro("clipview")
    "View &Timelog  "          ,   ExecMacro("timelog")
    "&Compare To Backup  "     ,   ExecMacro("cmp2bkup")
end

proc AutoLoad(integer add)
    string fn[255]

    fn = CurrMacroFileName()
    if add
        AddAutoLoadMacro(fn)
    else
        DelAutoLoadMacro(fn)
    endif
end


Menu ConfigMenu()
    Title = "PROJ0200 Session tools"
    "&Integration information", Warn("Session tools load on demand through the PROJ0200 Project menu."), CloseAfter
end

Menu HelpMenu()
    history

    "&About...",    mMessageBox("About PROJECTS",
                        "`PROJECTS, Version " + MyVersion
                      + "``Save and restore the state of"
                      + "`the editor between sessions."
                      + "``Written by Ian Campbell"
                      + "`July 15th, 1994"
                      + "```Press any key...",
                            FALSE)
end

MenuBar MainMenu()
    history

    "&File  "     ,   FileMenu()
    "&Search  "   ,   SearchMenu()
    "&Utility  "  ,   UtilityMenu()
    "&Configure  ",   ConfigMenu()
    "&Help  "     ,   HelpMenu()
end

/*** mShowMainMenu() ****************************************************
 *                                                                      *
 * Show the main PROJECTS menu.                                         *
 *                                                                      *
 * Called by:   mHandleRightButton(), assigned to a key in PROJECTS.KEY *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mShowMainMenu()
    while MouseKeyHeld()        // wait for the mouse to be released
    endwhile
    MainMenu()
end mShowMainMenu

/*** mHandleRightButton *************************************************
 *                                                                      *
 * If the right mouse button is clicked on the status line, then show   *
 * the PROJECTS menu.  Otherwise, disable the keydef for this mouse     *
 * button (MouseKeys), and then push the key so that it will be         *
 * re-processed.  Use the _IDLE_ hook to re-enable the MouseKeys        *
 * keydef when this process is complete.                                *
 *                                                                      *
 * Called by:   when the <RightBtn> is pressed.                         *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mHandleRightButton()
    if MouseHotSpot() == _NONE_
        mShowMainMenu()
    else            // just pass this through for TSE.S to handle
        ChainCmd()
    endif
end mHandleRightButton

// Global mouse assignment omitted by PROJ0200 integration.


/********************** Begin User Configurable Area **********************

If any changes are made to this area, the PROJECTS macro must be re-compiled.

Press <Ctrl F9> while editing this file to re-compile and re-load PROJECTS.

**************************************************************************/

    /*
    ALLOW_CRASH (default = FALSE)

    FALSE = Automatically abandon the reload of history buffer if the
            buffer was saved with an older version of the editor.

    TRUE =  Reload the history buffer regardless of the TSE version number.

    */
    constant ALLOW_CRASH = FALSE

    /*
    FULLLOADALLFILES (default = FALSE)

    FALSE = only completely load the files that contain bookmarks or a
            marked block when a project is restored.  The rest of the
            project files are added to TSE's buffer ring, but are not
            actually loaded until they are switched to.

    TRUE =  Reload all files completely when a project is restored.

    */
    constant FULLLOADALLFILES = FALSE

    /*
    RESTORESALMACROS (default = FALSE)

    FALSE = Do not restore previously running SAL macros when a project is
            restored.

    TRUE =  Reload all macros that were loaded when a project is restored.

    */
    constant RESTORESALMACROS = FALSE

    //<Alt 0>             mListOpenFiles()            // File|List Open
// Global Ctrl-K assignment omitted by PROJ0200 integration.
// Global Ctrl-K assignment omitted by PROJ0200 integration.
// Global Ctrl-K assignment omitted by PROJ0200 integration.
    //<Ctrl K><C>         mChangeProject()            // File|Save & Load New Project...
    //<Ctrl K><G>         mGrowProject()              // File|Add Another Project's Files...
    //                    mGoNextSearchMark()         // Search|Audit Bookmarks - Forward
    //                    mGoPrevSearchMark()         // Search|Audit Bookmarks - Reverse
    //                    mRptFind(_FORWARD_)         // Search|Current File|Repeat Find - Forward
    //                    mRptFind(_BACKWARD_)        // Search|Current File|Repeat Find - Reverse
    //                    mFindaWordAtCursor('I+')    // Search|Current File|Find Word at Cursor - Forward
    //                    mFindaWordAtCursor('IB')    // Search|Current File|Find Word at Cursor - Reverse
    //                    mFindSuperSearch()          // Search|Multiple Files|Find...
    //                    mSuperFind(0)               // Search|Multiple Files|Repeat Find - Forward
    //                    mSuperFind(1)               // Search|Multiple Files|Repeat Find - Reverse
    //                    mSuperFindWordAtCursor('I+')// Search|Multiple Files|Find Word at Cursor - Forward
    //                    mSuperFindWordAtCursor('IB')// Search|Multiple Files|Find Word at Cursor - Reverse
    //                    mSuperReplace()             // Search|Multiple Files|Replace...
    //                    mToggleBuffers()            // Search|Toggle To Previous File
    //                    ExecMacro("clipview")       // Utility|View Clipboard  
    //                    ExecMacro("timelog")        // Utility|View &Timelog  
    //                    ExecMacro("cmp2bkup")       // Utility|Compare To Backup  

    /*
    Most of these items are commented out.  You may uncomment and define
    them to any appropriate accelerator keystroke(s) as required.  In any
    case, all of their functionality is made available via the PROJECTS
    pulldown menus.

    Remember that all keystrokes assigned in "PROJECTS.KEY" will REPLACE any
    duplicate entries in the TSE user interface key file, making those
    entries effectively inaccessible.
    */

//********************* End User Configurable Area **********************


/*** AddLineEquals ******************************************************
 *                                                                      *
 * Adds the string plus the integer converted to a string to the        *
 * filelist file.                                                       *
 *                                                                      *
 * Called by:   mStoreBlockInfo(), mSaveEditorSpecifics()               *
 *              mSaveFilesScreenCoords(), mWriteOutABookMark(),         *
 *                                                                      *
 * Enter With:  the string, the integer to convert and add to string,   *
 *              and the filelist buffer ID.                             *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc AddLineEquals(string s, integer i)
    AddLine(s + "=" + Str(i), SaveFileList)
end AddlineEquals

/*** AddLineEquals2 *****************************************************
 *                                                                      *
 * Writes the two strings separated by an equals sign to the buffer ID  *
 * designated by filelist.                                              *
 *                                                                      *
 * Called by:  mStoreBlockInfo(), mSaveHistory(), mSaveOneClipboard(),  *
 *             mSaveMacroNames(), mSaveEditorSpecifics(),               *
 *             mSaveFilesScreenCoords(), mWriteOutABookMark(),          *
 *             mAddMarkedBlocks                                         *
 *                                                                      *
 * Enter With: the first string, the second string, and the filelist    *
 *             bufferID.                                                *
 *                                                                      *
 * Returns:    nothing                                                  *
 *                                                                      *
 * Notes:      none                                                     *
 *                                                                      *
 ************************************************************************/

proc AddLineEquals2(string s1, string s2)
    AddLine(s1 + "=" + s2, SaveFileList)
end AddlineEquals2

/*** mAddSeparatorLine **************************************************
 *                                                                      *
 * This routine writes a separator line to the current file, and then   *
 * a blank line to the current file.                                    *
 *                                                                      *
 * Called by:   mSaveDividerLine(), mSaveOneClipboard()                 *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mAddSeparatorLine()
    AddLine("---")
    AddLine()
end mAddSeparatorLine

/*** mSaveDividerLine ***************************************************
 *                                                                      *
 * This routine writes a divider line to the .PRJ file (its function    *
 * is "decorative" ONLY).                                               *
 *                                                                      *
 * Called by:   mSaveClipboard(), mSaveEditorSpecifics(),               *
 *              mSaveFilesScreenCoords(), mAddMarkedBlocks(),           *
 *              mSaveMarkInformation()                                  *
 *                                                                      *
 * Enter With:  the .PRJ buffer ID                                      *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mSaveDividerLine()
    integer fid = GetBufferID()

    GotoBufferID(SaveFileList)
    mAddSeparatorLine()
    GotoBufferID(fid)
end mSaveDividerLine

/*** mStoreBlockInfo ****************************************************
 *                                                                      *
 * This routine adds all block marking information to the project file. *
 *                                                                      *
 * Called by:   mSaveOneClipboard(), mAddMarkedBlocks()                 *
 *                                                                      *
 * Enter With:  the buffer ID of the .PRJ file,  and the type of marked *
 *              block.                                                  *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mStoreBlockInfo(integer BlockType)
    integer BegBlockCol,
            BegBlockLine,
            EndBlockCol,
            EndBlockLine,
            MyBufferID = GetBufferID()

    GotoBufferID(Query(BlockID))        // go to the file with the block
    PushPosition()                      // save position in marked block buffer
    GotoBlockBegin()
    BegBlockCol = CurrCol()
    BegBlockLine = CurrLine()
    GotoBlockEnd()
    EndBlockCol = CurrCol()
    EndBlockLine = CurrLine()
    PopPosition()                       // restore position in marked block
    case BlockType
        when _INCLUSIVE_
            AddlineEquals2(StrBlockType, StrInclusive)
        when _NONINCLUSIVE_
            AddLineEquals2(StrBlockType, StrNonInclusive)
        when _LINE_
            AddLineEquals2(StrBlockType, StrLine)
        when _COLUMN_
            AddLineEquals2(StrBlockType, StrColumn)
    endcase
    AddlineEquals(StrBlockBegCol, BegBlockCol)
    AddlineEquals(StrBlockBegLine, BegBlockLine)
    AddlineEquals(StrBlockEndCol, EndBlockCol)
    AddlineEquals(StrBlockEndLine, EndBlockLine)
    Addline("", SaveFileList)
    GotoBufferID(MyBufferID)
end mStoreBlockInfo

/*** mSaveHistory *******************************************************
 *                                                                      *
 * This macro dumps the history system buffer to the ClipBufferID file, *
 * and updates the filelist with the co-ordinates of the data.          *
 *                                                                      *
 * Called by:   mSaveSystemBuffers()                                    *
 *                                                                      *
 * Enter With:  filelist, the buffer to place the data, and the         *
 *              system buffer ID preserving.                            *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       This routine accesses an UNDOCUMENTED system buffer.    *
 *                                                                      *
 ************************************************************************/

proc mSaveHistory(integer ClipBufferID, integer SysBufferID)
    integer OldBufferID = GetBufferID()
    string SystemBufferName[32]

    if SysBufferID == SYS_BUFFER_HISTORY
        SystemBufferName = StrHistories
    endif
    if GotoBufferID(SysBufferID)            // history buffer ID
        PushBlock()
        UnMarkBlock()
        MarkLine(1, NumLines())
        if IsBlockMarked()
            GotoBufferID(ClipBufferID)
            AddLine()                       // add a blank line
            AddLine(StrSysBufferName + "=" + SystemBufferName)
            AddLine()
            AddLine()
            BegLine()
            CopyBlock()
            GotoBlockEnd()
            AddLine()
            mAddSeparatorLine()         // add a "---" divider, then a blank line
            AddLineEquals2(StrSysBufferName, SystemBufferName)
            mStoreBlockInfo(0)
        endif
        PopBlock()
    endif
    GotoBufferID(OldBufferID)
end mSaveHistory

/*** mSaveOneClipboard **************************************************
 *                                                                      *
 * This macro pastes a clipboard's information onto the end of the      *
 * .CLP file.  Marking information is retained.  All positions          *
 * within the .CLP file for this marked block, along with the type      *
 * of marked block, are stored, for later recovery.  Prevously marked   *
 * blocks are restored when this routine finishes.                      *
 *                                                                      *
 * Called by:   mSaveClipboard()                                        *
 *                                                                      *
 * Enter With:  the buffer ID of the .PRJ file, the .CLP buffer ID,     *
 *              and the clipboard name.                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mSaveOneClipboard(integer MyNewID, string ClipbrdName)
    integer MyID = GetBufferID()
    integer BlockType, MarkHold

    GotoBufferID(MyNewID)
    PushBlock()
    UnMarkBlock()
    MarkHold = Set(UnMarkAfterPaste, OFF)
    Paste()
    Set(UnMarkAfterPaste, MarkHold)
    BlockType = IsBlockInCurrFile()
    if BlockType
        GotoBlockBegin()
        InsertLine(StrClipBoardName + "=" + ClipBrdName)
        AddLine()
        EndFile()
        AddLine()
        mAddSeparatorLine()         // add a "---" divider, then a blank line
        AddLine()
        AddLineEquals2(StrClipBoardName, ClipBrdName)
        // save the block info in filelist
        mStoreBlockInfo(BlockType)
    endif
    PopBlock()
    GotoBufferID(MyID)                  // put things back
end mSaveOneClipboard

/*** mSaveSystemBuffers *************************************************
 *                                                                      *
 * This macro saves the system buffers to the ClipStorageID, and        *
 * updates the co-ordinates to the filelist.                            *
 *                                                                      *
 * Called by:                                                           *
 *                                                                      *
 * Enter With:                                                          *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mSaveSystemBuffers(integer ClipStorageID)
    AddLine(StrSYSTEMBUFFERS)
    AddLine(StrSYSTEMBUFFERS, SaveFileList)
    Message(strSaving + StrHistories)
    // save the history system buffer
    mSaveHistory(ClipStorageID, SYS_BUFFER_HISTORY)
    mSaveDividerLine()
end mSaveSystemBuffers

/*** mSaveClipboard *****************************************************
 *                                                                      *
 * This macro is used to save clipboard information.  First, a          *
 * buffer is created with the .CLP extention. Section "CLIPBOARD"       *
 * is then added to the .PRJ file.                                      *
 *                                                                      *
 * Next, data in the main clipboard is pasted into the .CLP file.       *
 * Marking information is retained.  This information (the              *
 * co-ordinates of the block, and the block type) is then added to      *
 * the .PRJ file.                                                       *
 *                                                                      *
 * Next, all 26 Named Clipboards are scanned.  If they exist,           *
 * their information is sequentially appended to the .CLP file          *
 * (via the paste command), and marking information is again            *
 * stored in the .PRJ file.                                             *
 *                                                                      *
 * The .CLP file is then saved on disk in the PRJ subdirectory.         *
 *                                                                      *
 * Called by:   mSaveProjectFiles()                                     *
 *                                                                      *
 * Enter With:  the project buffer ID, and the project filename.        *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mSaveClipboard(string fn)
    integer MyID = GetBufferID(), ClipStorageID, i, NamedClipID
    integer OldClipBoardID = Query(ClipBoardID)

    Message(StrSaving + StrClipBoards)
    if GetBufferID(fn)
        // abandon projectname.clp if editing it
        AbandonFile(GetBufferID(fn))
    endif
    ClipStorageID = CreateBuffer(fn)          // projectname.clp
    if ClipStorageID
        AddLine("CLIPBOARDS")
        AddLine()
        AddLine()
        AddLine(StrCLIPBOARD, SaveFileList)
        mSaveOneClipboard(ClipStorageID, StrMain)
        i = 1
        while i <= 26
             NamedClipID = GetBufferID("+++" + Chr(Asc("A") + i - 1))
             if NamedClipID
                Set(ClipBoardID, NamedClipID)
                mSaveOneClipboard(ClipStorageID,
                    Chr(Asc("A") + i - 1))
            endif
            i = i + 1
        endwhile
        mSaveDividerLine()
        mSaveSystemBuffers(ClipStorageID)
        EraseDiskFile(SplitPath(fn, _Drive_ | _Path_) + StrLast + ".CLP")
        EraseDiskFile(fn)                   // erase projectname.clp
        if NumLines()                       // anything in projectname.clp?
            SaveFile()                      // then save it
        endif
        AbandonFile(ClipStorageID)
        Set(ClipBoardID, OldClipBoardID)
    endif
    GotoBufferID(MyID)                      // put things back
end mSaveClipboard

/*** mSaveMacroNames ****************************************************
 *                                                                      *
 * Save the loaded SAL macro names in the filelist buffer.              *
 *                                                                      *
 * Called by:   mSaveEditorSpecifics()                                  *
 *                                                                      *
 * Enter With:  the filelist buffer ID                                  *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mSaveMacroNames()
    integer cid = GetBufferID()
    string s[16]

    If GotoBufferID(MacroBuffer)
        PushPosition()
        EndFile()
        while lFind("","B")
            if CurrPos() == 3
                s = GetText(9, Asc(GetText(8, 1)))
                if GotoBufferID(SaveFileList)
                    Message(StrSaving + "Macro Name " + s)
                    AddLineEquals2(StrMacroName, s)
                    GotoBufferID(MacroBuffer)
                endif
            endif
        endwhile
        PopPosition()
    endif
    GotoBufferID(cid)
end mSaveMacroNames

/*** mSaveEditorSpecifics ***********************************************
 *                                                                      *
 * Saves a variety of information relating to a project file,           *
 * including the following:                                             *
 *                                                                      *
 * The current drive and directory                                      *
 * The state of the insert key                                          *
 * The state of autoindent                                              *
 * The state of wordwrap                                                *
 * The state of the right margin                                        *
 * Video Mode (25, 28, 43, or 50 lines)                                 *
 *                                                                      *
 * Called by:   mSaveMarkInformation()                                  *
 *                                                                      *
 * Enter With:  filelist buffer ID                                      *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       These entries represent the EDITOR SPECIFICS section    *
 *              of the project file.                                    *
 *                                                                      *
 ************************************************************************/

proc mSaveEditorSpecifics(string ProjName)
    Message(StrSaving + StrState)
    AddLineEquals2(StrTSEPROJECT, ProjName)
    AddLine("", SaveFileList)
    AddLine("TSE STATE", SaveFileList)
    AddLineEquals(StrEditorVersion, Version())
    AddLineEquals(StrBufferListSort, SortFlg)
    AddLineEquals2(StrCurrentDir, SplitPath(ExpandPath(""), _DRIVE_ | _PATH_))
    AddLineEquals(StrInsert, Query(Insert))
    AddLineEquals(StrAutoIndent, Query(AutoIndent))
    AddLineEquals(StrWordWrap, Query(WordWrap))
    AddLineEquals(StrRightMargin, Query(RightMargin))
    AddLineEquals(StrWindowHeight, Query(CurrVideoMode))
    mSaveMacroNames()
    AddLine("", SaveFileList)
    mSaveDividerLine()
end mSaveEditorSpecifics

/*** mSaveBinaryMarker **************************************************
 *                                                                      *
 * Save Binary information if the file is opened as a binary file.      *
 *                                                                      *
 * Called by:   mSaveFilesScreenCoords(), mWriteOutABookMark(),         *
 *              mAddMarkedBlocks()                                      *
 *                                                                      *
 * Enter With:  Buffer ID of the filelist buffer                        *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mSaveBinaryMarker()
    if BinaryMode()
        Addline(StrBinary + "=" + "-b" + Str(BinaryMode()), SaveFileList)
    endif
end mSaveBinaryMarker

/*** mSaveHexMarker *****************************************************
 *                                                                      *
 * Save Hex information if the file is displayed as a hex file.         *
 *                                                                      *
 * Called by:   mSaveFilesScreenCoords()                                *
 *                                                                      *
 * Enter With:  Buffer ID of the filelist buffer                        *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mSaveHexMarker()
    if DisplayMode() == _DISPLAY_HEX_
        Addline(StrHexDisplay, SaveFileList)
    endif
end mSaveHexMarker

/*** mGetFirstWord ******************************************************
 *                                                                      *
 * Return the next word on the current line.                            *
 *                                                                      *
 * Called by:   mGetFirstWord(), mGetSecondWord()                       *
 *                                                                      *
 * Enter With:  a 1 if the second word, 0 if the first word.            *
 *                                                                      *
 * Returns:     a string with the word in it.                           *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

string proc mGetFirstWord()
    EndLine()
    lFind("=", "cg")
    Right()
    return(GetText(1, CurrPos() - 2))
end mGetFirstWord

/*** mGetSecondWord *****************************************************
 *                                                                      *
 * Enter with the cursor pointing to the second word.  Return the       *
 * second word.                                                         *
 *                                                                      *
 * Called by:   mRestoreFilesScreenCoords(), mRestoreEditorSpecifics(), *
 *              mRestoreHistory(), mRestoreMarkedBlocks(),              *
 *              mRestoreFilesMarkCoords()                               *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     the second word.                                        *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

string proc mGetSecondWord()
    return(GetText(CurrPos(), CurrLineLen() + 1))
end mGetSecondWord

/*** mGetSecondInt ******************************************************
 *                                                                      *
 * Enter with the cursor pointing to the second word.  Convert this     *
 * word to an integer, and return the integer.                          *
 *                                                                      *
 * Called by:   mRestoreFilesScreenCoords(), mRestoreEditorSpecifics(), *
 *              mRestoreHistory(), mRestoreMarkedBlocks(),              *
 *              mRestoreFilesMarkCoords()                               *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     the second word in integer format                       *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

integer proc mGetSecondInt()
    return(val(GetText(CurrPos(), CurrLineLen() + 1)))
end mGetSecondInt

proc mGetProjectOffsets(var integer Line, var integer Row,
        var integer Column, var integer xOffset)
    string fn[255] = CurrFilename()
    integer fid = GetBufferID()
    integer pid = GetBufferID(ProjFiles)
    integer i = 0

    Line = 1
    Row = 1
    Column = 1
    xOffset = 0
    if pid
        if GotoBufferID(pid)
            if lFind(fn, "IGW$")
                while Down() and i < 4
                    case mGetFirstWord()
                        when StrCursorLine
                            Line = mGetSecondInt()
                        when StrCursorRow
                            Row = mGetSecondInt()
                        when StrCursorColumn
                            Column = mGetSecondInt()
                        when StrCursorXoffset
                            xOffset = mGetSecondInt()
                    endcase
                    i = i + 1
                endwhile
            endif
        endif
    endif
    GotoBufferID(fid)
end mGetProjectOffsets

proc mOnFirstEdit()
    integer CursorLine, CursorRow, CursorColumn, CursorXoffset

    mGetProjectOffsets(CursorLine, CursorRow, CursorColumn, CursorXoffset)
    GotoLine(CursorLine)
    ScrolltoRow(CursorRow)
    GotoColumn(CursorColumn)
    GotoXoffset(CursorXoffset)
end mOnFirstEdit

/*** mSaveFilesScreenCoords *********************************************
 *                                                                      *
 * Adds all filenames in the editor's ring to the filelist buffer       *
 *                                                                      *
 * Called by:   mSaveProjectFiles()                                     *
 *                                                                      *
 * Enter With:  Buffer ID of the filelist buffer                        *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

integer proc mSaveFilesScreenCoords()
    string fn[255]
    integer n, MyID = GetBufferID(), ReturnCode = TRUE
    integer Line, Row, Column, xOffset

    AddLine(StrFILENAMES, SaveFileList)
    n = NumFiles() + (BufferType() <> _NORMAL_)
    while n
        fn = mCurrFilenameCaps()
        if length(fn)
                and Length(SplitPath(fn, _DRIVE_))
                and BufferType() == _NORMAL_
            if FileChanged()
                if not SaveFile()
                    ReturnCode = FALSE
                endif
            endif
            Message(StrSaving + "position in " + fn)
            mSaveBinaryMarker()
            AddLineEquals2(StrFILENAME, fn)
            mSaveHexMarker()
            if NumLines()
                Line = CurrLine()
                Row = CurrRow()
                Column = CurrCol()
                xOffset = CurrXoffset()
            else
                mGetProjectOffsets(Line, Row, Column, xOffset)
            endif
            AddLineEquals(StrCursorLine, Line)
            AddLineEquals(StrCursorRow, Row)
            AddLineEquals(StrCursorColumn, Column)
            AddLineEquals(StrCursorXoffset, xOffset)
            AddLine("", SaveFileList)
        endif
        PrevFile(_DONT_LOAD_)
        n = n - 1
    endwhile
    if GotoBufferID(PreviousID)
        AddLineEquals2(StrToggleBuffer, CurrFilename())
    endif
    mSaveDividerLine()
    GotoBufferID(MyID)
    return(ReturnCode)
end mSaveFilesScreenCoords

/*** mWriteOutABookMark *************************************************
 *                                                                      *
 * Adds bookmark text to a filelist, in preparation for a project       *
 * save.                                                                *
 *                                                                      *
 * Called by:   mSaveMarkInformation()                                  *
 *                                                                      *
 * Enter With:  bookmark letter (A - Z), and the buffer ID for          *
 *              the filelist.                                           *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mWriteOutABookMark(string BookMarkName, integer line,
        integer column, integer Xoffset, integer Row)
    Message(StrSaving + BookMarkMinus + BookMarkName + " in " +
        mCurrFilenameCaps())
    AddLineEquals2(StrBOOKMARK, BookMarkName)
    mSaveBinaryMarker()
    AddLineEquals2(StrBookMarkFileName, mCurrFilenameCaps())
    AddLineEquals(StrBookMarkLine, line)
    AddLineEquals(StrBookMarkColumn, column)
    AddLineEquals(StrBookMarkXoffset, Xoffset)
    AddLineEquals(StrBookMarkRow, Row)
    AddLine("", SaveFileList)
end mWriteOutABookMark

/*** mAddMarkedBlocks ***************************************************
 *                                                                      *
 * This routine adds block marks to the project file.                   *
 *                                                                      *
 * Called by:   mSaveMarkInformation()                                  *
 *                                                                      *
 * Enter With:  the buffer ID via filelist                              *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mAddMarkedBlocks()
    integer BlockType = isBlockMarked()
    string MyFilename[79]

    if BlockType
        GotoBufferID(Query(BlockID))    // go to the file with the column block
        PushPosition()                  // save position in marked block file
        GotoBlockBegin()
        MyFilename = mCurrFilenameCaps()
        PopPosition()                   // restore position in marked block file
        AddLine(StrMARKEDBLOCK, SaveFileList)
        AddLine("", SaveFileList)
        mSaveBinaryMarker()
        AddLineEquals2(StrBlockFilename, MyFilename)
        mStoreBlockInfo(BlockType)
        mSaveDividerLine()
        Message(StrSaving + MarkedSpaceBlock)
    endif
end mAddMarkedBlocks

/*** mSaveMarkInformation ***********************************************
 *                                                                      *
 * Writes out all bookmarks, and sets a flag to indicate whether        *
 * or not they represent valid audit bookmarks.  Additionally, saves    *
 * the state of the 25 additional new "synthetic" bookmarks.            *
 *                                                                      *
 * Called by:   mSaveProjectFiles()                                     *
 *                                                                      *
 * Enter With:  the buffer ID for the filelist buffer                   *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mSaveMarkInformation()
    integer i, MyID = GetBufferID()

    AddLine(StrBOOKMARKS, SaveFileList)
    i = 1
    while i <= BOOKMARKCOUNT        // there are 26 manual bookmarks
        if GotoMark(Chr(Asc("A") + i - 1))  // valid bookmark?
            mWriteOutABookMark(Chr(Asc("A") + i - 1),
                CurrLine(), CurrCol(), CurrxOffset(), CurrRow())
        endif
        GotoBufferID(MyID)          // return to the edit buffer with the mark
        i = i + 1
    endwhile
    mSaveDividerLine()
    AddLine("AUDIT " + StrBOOKMARKS, SaveFileList)
    mSyncBookMarks(BEGINNING)       // point at the first valid bookmark
    i = 1
    while i <= AUDITBOOKMARKCOUNT
        if ValidMarks[BookMarkIndex] <> "1"
            break
        endif
        mGoAuditMark(BookMarkIndex, FALSE)  // lets go there now!
        mWriteOutABookMark(Str(BookMarkIndex), AuditLineMark,
            AuditColumnMark, AuditXoffsetMark, AuditRowMark)
        GotoBufferID(MyID)              // return to the edit buffer
        i = i + 1
        BookMarkIndex = mBookMarkIndexPlusOne()
    endwhile
    mSaveDividerLine()
    mSyncBookMarks(ENDING)              // make sure at the end of auditmarks
    GotoBufferID(MyID)
end mSaveMarkInformation

/*** mGetMacroDir ********************************************************
 *                                                                      *
 * Return the directory for all supplemental files in upper case.       *
 *                                                                      *
 * Called by:   mHandleBlankCommandLine(), mSaveProjectFiles(),         *
 *              and mSessionRestoreCheck()                              *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     Directory of Project.mac                                *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

string proc mGetMacroDir()
    return(SplitPath(CurrMacroFileName(), _DRIVE_ | _PATH_))
end mGetMacroDir

/*** mMakeProjGlobal() **************************************************
 *                                                                      *
 * Saves the ".PRJ" filename under a global that all macros can read.   *
 *                                                                      *
 * Called by:   mSaveProjectToDisk(), mGrowProject(),                   *
 *              mSessionRestoreCheck()                                  *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mMakeProjGlobal()
    string pn[255] = mGetMacroDir()
    string fn[255] = SplitPath(ProjectName, _NAME_)

    SetGlobalStr(StrProjectName, Upper(pn + fn))
end mMakeProjGlobal

/*** mSaveProjectToDisk() ***********************************************
 *                                                                      *
 * Saves the .PRJ file under both the project name and the !!LAST!!     *
 * name to disk.                                                        *
 *                                                                      *
 * Called by:   mSaveProjectFiles()                                     *
 *                                                                      *
 * Enter With:  filelist, project path, and the project name.           *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

integer proc mSaveProjectToDisk(string ProjPath, string ProjName)
    integer MyID = GetBufferID()

    ProjectName = ProjPath + ProjName + ".PRJ"
    mMakeProjGlobal()
    GotoBufferID(SaveFileList)              // switch to the filelist buffer
    // save the project file with the project name
    if not SaveAs(ProjectName, _DONT_PROMPT_|_OVERWRITE_)
        GotoBufferId(MyID)
        Warn("Unable to save the session snapshot: " + ProjectName)
        return(FALSE)
    endif
    // save the project file with the "!!LAST!!" name
    if not SaveAs(ProjPath + StrLast + ".PRJ", _DONT_PROMPT_|_OVERWRITE_)
        GotoBufferId(MyID)
        Warn("Unable to save the last-session snapshot.")
        return(FALSE)
    endif
    GotoBufferID(MyID)                  // put the original file back
    return(TRUE)
end mSaveProjectToDisk

/*** mSaveProjectFiles **************************************************
 *                                                                      *
 * This macro will save editor context to project file(s), and then     *
 * save all of the files which have changed.                            *
 *                                                                      *
 * Called by:   mSaveFilesAndExit(), Bound to a key                     *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     true if project saved OK, false otherwise               *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

integer proc mSaveProjectFiles()
    integer start_file = GetBufferID(), ReturnCode = FALSE
    string MacroDir[255]
    string ProjName[255]
    string ProjPath[255]

    MacroDir = mGetMacroDir()
    ProjPath = MacroDir + "PRJ"
    if not mDirExists(ProjPath)         // does prj directory exist?
        // if not, then create it
        Dos ("mkdir " + QuotePath(ProjPath), _DONT_CLEAR_ | _DONT_PROMPT_)
    endif
    if not mDirExists(ProjPath)
        mMessageBox("PROJECTS", "Can't Create " + ProjPath, FALSE)
        return(FALSE)
    endif
    ProjName = iif(Length(ProjectName), SplitPath(ProjectName, _NAME_),
        StrLast)
    if NumFiles() + (BufferType() <> _NORMAL_) == 0
        return(FALSE)
    endif
    OneWindow()                     // Cannot save windows, so cancel them
    UpdateDisplay()
    mSetScreenMarks(TRUE)           // drop an audit bookmark
    SaveFileList = CreateTempBuffer()
    if SaveFileList == 0
        return(FALSE)
    endif
    GotoBufferID(start_file)
    if Ask("Save session snapshot as:", ProjName, _EDIT_HISTORY_)
        ProjName = Upper(SplitPath(ProjName, _NAME_))  // make sure!
        ProjPath = ProjPath + GetDirSeparator()
        if (BufferType() <> _NORMAL_)
            NextFile()                      // avoid saving wierd buffers!
            start_file = GetBufferID()      // new original buffer
        endif
        Hook(_ON_CHANGING_FILES_, mHookKiller)
        Hook(_AFTER_UPDATEDISPLAY_, mHookKiller)
        mSaveEditorSpecifics(ProjName)
        mSaveClipboard(ProjPath + ProjName + ".CLP")
        ReturnCode = mSaveFilesScreenCoords()
        mAddMarkedBlocks()
        mSaveMarkInformation()
        if ReturnCode
            ReturnCode = mSaveProjectToDisk(ProjPath, ProjName)
        endif
        mSaveKeyMacro(ProjPath)             // save any keyboard macro
        UnHook(mHookKiller)
        UpdateDisplay()
    endif
    GotoBufferID(start_file)
    AbandonFile(SaveFileList)
    return(ReturnCode)
end mSaveProjectFiles

/*** mSaveProjectFilesAndExit *******************************************
 *                                                                      *
 * This macro will save editor context to project file(s) for the       *
 * following:                                                           *
 *                                                                      *
 * ALL files currently open                                             *
 * All bookmarks                                                        *
 * ALL macros                                                           *
 * The CURRENT DRIVE AND DIRECTORY.                                     *
 * The MAIN CLIPBOARD DATA (all types).                                 *
 * Up to 26 NAMED CLIPBOARDS ("A" through "Z" only)                     *
 * Any MARKED BLOCK (all types).                                        *
 * The state of INSERT.                                                 *
 * The state of AUTOINDENT.                                             *
 * The state of WORDWRAP.                                               *
 * The state of the RIGHT MARGIN.                                       *
 * Video Mode (25, 28, 43, or 50 lines)                                 *
 * All histories                                                        *
 *                                                                      *
 * The user is then prompted for a project name (!!LAST!! default is    *
 * provided if this is a new project).  The project will always be      *
 * dumped to filename !!LAST!!.PRJ.  If another name is given, the      *
 * project will be duplicated under that name (for long term storage).  *
 *                                                                      *
 * Projects are added to subdirectory "PRJ", located just under C:\TSE\ *
 * as provided by environment string "LOADDIR").  If this subdirectory  *
 * string does not exist, it will be created.  If a "LOADDIR"           *
 * environment string does not exist, then the Editor's directory       *
 * (found via the CurrMacroFileName() command) will be used.                      *
 *                                                                      *
 * All editor files which have changed are then saved to disk, and      *
 * TSE is exited.                                                       *
 *                                                                      *
 * Called by:   Bound to a key                                          *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       This macro must be assigned to a key / mouse sequence.  *
 *                                                                      *
 ************************************************************************/

proc mSaveProjectFilesAndExit()
    if mSaveProjectFiles()                  // did the save go ok?
        RemoveUnloadedFiles()
        Exit()                              // now save all files and exit
    endif
end mSaveProjectFilesAndExit

/*** mGetThisFile *******************************************************
 *                                                                      *
 * If FullLoad, then load a new file into TSE's ring.  Otherwise, just  *
 * load the filename but don't load the file.  Handle the binary        *
 * situation.                                                           *
 *                                                                      *
 * Called by:   mRestoreFilesScreenCoords(), mRestoreFilesMarkCoords()  *
 *                                                                      *
 * Enter With:  the filename to try to load/activate.                   *
 *                                                                      *
 * Returns:     the buffer ID of the file, 0 if not successful.         *
 *                                                                      *
 * Notes:       moderately heavy stack utilization -- use caution.      *
 *                                                                      *
 ************************************************************************/

integer proc mGetThisFile(string fn, string BinaryStr, integer FullLoad)
    string s[255]
    string b[255] = BinaryStr + " " + QuotePath(fn)
    integer level

    if FileExists(fn)               // is it on disk
        if (fn == (mGetMacroDir() + "PRJ\"
                + SplitPath(ProjectName, _NAME_) + ".PRJ"))
                or (SplitPath(fn, _NAME_) == StrLast)
            return(0)
        endif
        level = Set(MsgLevel, _NONE_)
        s = QuotePath(CurrFilename()) + " " + b
        if (FullLoad or FULLLOADALLFILES or (Length(s) > 159))
            Message("Loading " + fn)
            EditFile(b)
            UpdateDisplay()
        else
            if not GetBufferID(fn)
                Message("Adding " + fn)
                EditFile(s)
            endif
        endif
        Set(MsgLevel, level)
    endif
    return(GetBufferID(fn))
end mGetThisFile

/*** mRestoreFilesScreenCoords ******************************************
 *                                                                      *
 * This macro will restore the screen positions for all files saved     *
 * in the .PRJ file.                                                    *
 *                                                                      *
 * Called by:   mSessionRestoreCheck()                                  *
 *                                                                      *
 * Enter With:  filelist buffer ID, number of lines to search.          *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mRestoreFilesScreenCoords()
    integer fid, FilenameValid = FALSE
    string StartupFile[255] = ""
    string fn[255]
    string fn2[255]
    string BinaryStr[4] = ""
    integer line, row, column, xOffset

    Hook(_ON_CHANGING_FILES_, mHookKiller)
    Hook(_AFTER_UPDATEDISPLAY_, mHookKiller)
    GotoBufferID(RestoreFileList)
    if lFind(StrFILENAMES, "WG")
        PushBlock()
        UnMarkBlock()
        MarkChar()
        repeat
            case mGetFirstWord()
                when StrFILENAME
                    fn = mGetSecondWord()
                    if Length(fn)
                        fid = mGetThisFile(fn, BinaryStr,
                            not Length(StartupFile))
                        if fid
                            if length(StartupFile) == 0
                                StartupFile = fn
                            endif
                        endif
                        FilenameValid = fid
                    endif
                    BinaryStr = ""
                    if fid
                        GotoBufferID(fid)
                        if not NumLines()
                            Down(4)
                            FilenameValid = FALSE
                        endif
                    endif
                when StrCursorLine
                    Line = mGetSecondInt()
                when StrCursorRow
                    Row = mGetSecondInt()
                when StrCursorColumn
                    Column = mGetSecondInt()
                when StrCursorXoffset
                    if FilenameValid
                        xOffset = mGetSecondInt()
                        GotoBufferID(fid)
                        GotoLine(Line)
                        ScrollToRow(Row)
                        GotoColumn(Column)
                        GotoXoffset(xOffset)
                    endif
                when StrBinary
                    BinaryStr = mGetSecondWord()
                when StrToggleBuffer
                    fn2 = mGetSecondWord()
                    AddLine(fn2, GetBufferID(PrjRecent))
                    PreviousID = GetBufferID(fn2)
                when StrHexDisplay
                    GotoBufferID(fid)
                    DisplayMode(_DISPLAY_HEX_)
                when StrMARKEDBLOCK
                    break
                when StrBOOKMARKS
                    break
            endcase
            GotoBufferID(RestoreFileList)      // restore control buffer ID
        until not Down()
        MarkChar()
        CreateBuffer(ProjFiles, _SYSTEM_)
        if GetBufferID(ProjFiles)
            if GotoBufferID(GetBufferID(ProjFiles))
                EmptyBuffer()
                if IsBlockMarked()
                    CopyBlock()
                endif
            endif
        endif
        PopBlock()
        if Length(Startupfile)
            EditFile(QuotePath(Startupfile))
        endif
    endif
    UnHook(mHookKiller)
end mRestoreFilesScreenCoords

/*** mRestoreEditorSpecifics ********************************************
 *                                                                      *
 * This macro will restore editor context from project file(s) for the  *
 * following:                                                           *
 *                                                                      *
 * The current drive & directory of the project files                   *
 * The state of the insert key                                          *
 * The state of autoindent                                              *
 * The state of wordwrap                                                *
 * The state of the right margin                                        *
 * Video Mode (25, 28, 43, or 50 lines)                                 *
 *                                                                      *
 * Called by:   mSessionRestoreCheck()                                  *
 *                                                                      *
 * Enter With:  filelist buffer ID, number of lines to search           *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mRestoreEditorSpecifics()
    string wordst[255]
    integer MyID = GetBufferID()
    integer level

    GotoBufferID(RestoreFileList)
    Message(StrRestoring + StrState)
    BegFile()                   // start at the beginning of the project file
    repeat
        case mGetFirstWord()
            when StrEditorVersion
                if mGetSecondInt() <> Version()
                    EditorVersionOK = FALSE
                    EditorVersionMatch = FALSE
                    if ALLOW_CRASH
                        EditorVersionOK = TRUE
                    endif
                endif
            when StrBufferListSort
                SortFlg = mGetSecondInt()
            when StrTSEPROJECT   // get the correct project name
                // adjust project name to match name in the project file
                ProjectName = SplitPath(mGetSecondWord(), _NAME_)
            when StrCurrentDir
                wordst = mGetSecondWord()
                LogDrive(wordst)
                ChDir(wordst)
            when StrInsert
                Set(Insert, mGetSecondInt())
            when StrAutoIndent
                Set(AutoIndent, mGetSecondInt())
            when StrWordWrap
                Set(WordWrap, mGetSecondInt())
            when StrRightMargin
                Set(RightMargin, mGetSecondInt())
            when StrWindowHeight
                wordst = mGetSecondWord()
                // change only if video mode is different from requested mode
                if Query(CurrVideoMode) <> val(wordst)
                    Set(CurrVideoMode, val(wordst))
                endif
            when StrMacroName
                if RESTORESALMACROS
                    wordst = mGetSecondWord()
                    if not IsMacroLoaded(wordst)
                        Message(StrRestoring + "Macro " + wordst)
                        level = Set(MsgLevel, _NONE_)
                        LoadMacro(wordst)
                        Set(MsgLevel, level)
                    endif
                endif
            when strFILENAMES, strCLIPBOARD
                break
        endcase
        GotoBufferID(RestoreFileList)
    until not Down()
    GotoBufferID(MyID)
end mRestoreEditorSpecifics

/*** mRestoreHistory ****************************************************
 *                                                                      *
 * This macro will all restore history information stored int the       *
 * ".clp" buffer.                                                       *
 *                                                                      *
 * Called by:   mRestoreClipboard()                                     *
 *                                                                      *
 * Enter With:  filelist buffer ID, number of lines to search           *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       This routine accesses UNDOCUMENTED system buffers.      *
 *                                                                      *
 ************************************************************************/

proc mRestoreHistory()
    integer MyID = GetBufferID()
    string SysBufferName[32]
    integer aBlockBegCol, aBlockEndCol, aBlockBegLine, aBlockEndLine

    if EditorVersionOK
        GotoBufferID(RestoreFileList)
        if lFind(StrSYSTEMBUFFERS, "WG")
            Message(StrRestoring, StrHistories)
            repeat
                case mGetFirstWord()
                    when StrSysBufferName
                        SysBufferName = mGetSecondWord()
                    when strBlockBegCol
                        aBlockBegCol = mGetSecondInt()
                    when strBlockBegLine
                        aBlockBegLine = mGetSecondInt()
                    when strBlockEndCol
                        aBlockEndCol = mGetSecondInt()
                    when strBlockEndLine
                        aBlockEndLine = mGetSecondInt()
                        Message(StrRestoring + SysBufferName)
                        GotoBufferID(MyID)
                        GotoColumn(aBlockBegCol)
                        GotoLine(aBlockBegLine)
                        PushBlock()
                        UnMarkBlock()
                        MarkChar()
                        GotoLine(aBlockEndLine)
                        GotoColumn(aBlockEndCol)
                        MarkChar()
                        if SysBufferName == StrHistories
                            if GotoBufferID(SYS_BUFFER_HISTORY)   // undocumented
                                EmptyBuffer()
                                CopyBlock()
                            endif
                        endif
                        PopBlock()
                        SysBufferName = ""
                    when strFILENAMES
                        break
                endcase
                GotoBufferID(RestoreFileList)
            until not Down()
        endif
        GotoBufferID(MyID)
    endif
end mRestoreHistory

/*** mRestoreMarkedBlocks ***********************************************
 *                                                                      *
 * This macro will restore a marked block to the appropriate filename.  *
 * Block type will be preserved.                                        *
 *                                                                      *
 * Called by:   mSessionRestoreCheck(), mRestoreClipboard()             *
 *                                                                      *
 * Enter With:  filelist buffer ID, number of lines to search, if       *
 *              clipboard, the clipboard ID -- otherwise 0,             *
 *              the Section Type -- either ClipBoardType (0) or         *
 *              "MarkedBlockType" (1).                                  *
 *                                                                      *
 * Returns:     the clipboard name if a clipboard is being restored.    *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

string proc mRestoreMarkedBlocks(integer OverRideID,
    integer MarkedBlockType)

    integer fid = OverRideID, aBlockBegCol, aBlockEndCol
    integer aBlockBegLine, aBlockEndLine, MyID = GetBufferID()
    integer SectionFound = FALSE
    string BlockType[15] = ""
    string ClipbrdName[5] = ""
    string wordst[255] = ""

    GotoBufferID(RestoreFileList)
    repeat
        case mGetFirstWord()        // get the first word on the line
            when StrBlockType
                BlockType = mGetSecondWord()
            when StrBlockBegCol
                aBlockBegCol = mGetSecondInt()
            when StrBlockEndCol
                aBlockEndCol = mGetSecondInt()
            when StrBlockBegLine
                aBlockBegLine = mGetSecondInt()
            when StrBlockEndLine
                aBlockEndLine = mGetSecondInt()
                if SectionFound
                    break
                endif
            when StrBOOKMARKS, "SYSTEM", StrFILENAMES   // don't pass this point
                break
            when StrClipBoardName
                if not MarkedBlockType
                    ClipbrdName = mGetSecondWord()
                    SectionFound = TRUE
                endif
            when StrBlockFilename
                if MarkedBlockType
                    SectionFound = TRUE
                    wordst = mGetSecondWord()
                    if FileExists(wordst)       // is it on disk?
                        EditFile(wordst)
                        fid = GetBufferID()
                        GotoBufferID(RestoreFileList)
                    endif
                endif
        endcase
    until not Down()
    if fid and SectionFound
        UnMarkBlock()                       // precautionary
        GotoBufferID(fid)
        GotoLine(aBlockBegLine)
        GotoColumn(aBlockBegCol)
        case BlockType
            when StrInclusive
                MarkStream()
                GotoLine(aBlockEndLine)
                GotoColumn(aBlockEndCol)
                MarkStream()
            when StrNonInclusive
                MarkChar()
                GotoLine(aBlockEndLine)
                GotoColumn(aBlockEndCol)
                MarkChar()
            when StrLine
                MarkLine()
                GotoLine(aBlockEndLine)
                GotoColumn(aBlockEndCol)
                MarkLine()
            when StrColumn
                MarkColumn()
                GotoLine(aBlockEndLine)
                GotoColumn(aBlockEndCol)
                MarkColumn()
        endcase
        GotoBufferID(RestoreFileList)
    endif
    GotoBufferID(MyID)
    return(ClipbrdName)
end mRestoreMarkedBlocks

/*** mRestoreClipboard **************************************************
 *                                                                      *
 * This routine restores clipboard information for the main clipboard,  *
 * as well as all 26 Named Clipboards ("A" - "Z").                      *
 *                                                                      *
 * First, the .CLP file is opened (edited).  A loop is then set         *
 * up, and marked block information (the co-ordinates of the            *
 * block, and the block type) that was saved when the project was       *
 * last shut down is then pulled from the .PRJ file. The marked         *
 * blocks are then restored to the .CLP file.                           *
 *                                                                      *
 * For Named Clipboards, a new system buffer is created, and this       *
 * buffer is then temporarly assigned as a main clipboard buffer        *
 * replacement. Next the marked text in the .CLP file is then           *
 * transferred to the clipboard via the Copy() command.                 *
 *                                                                      *
 * This process repeats until all of the text in the .CLP file is       *
 * placed in the appropriate clipboard buffers.                         *
 *                                                                      *
 * Finally, the history buffers are restored via a call to              *
 * mRestoreHistory().                                                   *
 *                                                                      *
 * Called by:   mSessionRestoreCheck()                                  *
 *                                                                      *
 * Enter With:  the .PRJ buffer ID, number of lines in the .PRJ file,   *
 *              and the clipboard filename.                             *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mRestoreClipboard(string fn)
    integer MyID = GetBufferID(), j
    string ClipbrdName[5]
    integer OldClipBoardID = Query(ClipBoardID), NewClipBoardID
    integer MyTempClipBuffer
    integer level

    GotoBufferID(RestoreFileList)
    if lFind(StrCLIPBOARD, "WG")
        Message(StrRestoring + StrClipBoards)
        PushBlock()
        if FileExists(fn)
            MyTempClipBuffer = CreateTempBuffer()
            PushBlock()
            level  = Set(MsgLevel, _NONE_)
            InsertFile(fn)                // load projectname.CLP
            Set(MsgLevel, level)
            PopBlock()
            loop
                ClipbrdName = mRestoreMarkedBlocks(GetBufferID(), 0)
                if not Length(ClipbrdName)
                    break                   // exit loop when no more clipboards
                endif
                if Length(ClipbrdName) == 1   // named clipboard is only ONE char
                    j = 1
                    while j <= 26
                        if Asc(ClipbrdName) == Asc("A") + j - 1
                            NewClipBoardID = CreateBuffer("+++" + ClipbrdName,
                                _SYSTEM_)
                            if NewClipBoardID
                                Set(ClipBoardID, NewClipBoardID)
                                GotoBufferID(MyTempClipBuffer)
                                if IsBlockInCurrFile()
                                    Copy()
                                endif
                                Set(ClipBoardID, OldClipBoardID)
                            endif
                        endif
                        j = j + 1
                    endwhile
                elseif ClipbrdName == StrMain
                    if IsBlockInCurrFile()
                        Copy()
                    endif
                endif
            endloop
            mRestoreHistory()
            GotoBufferID(MyID)
            AbandonFile(MyTempClipBuffer)
        endif
        PopBlock()
    endif
    GotoBufferID(MyID)              // put things back
end mRestoreClipboard

/*** mRestoreFilesMarkCoords ********************************************
 *                                                                      *
 * This macro will restore bookmark context from the project file for   *
 * each file in the project containing bookmarks.                       *
 *                                                                      *
 * Called by:   mSessionRestoreCheck()                                  *
 *                                                                      *
 * Enter With:  filelist buffer ID, number of lines to search           *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mRestoreFilesMarkCoords()
    integer fid, FilenameValid = FALSE, MyID = GetBufferID()
    string fn[255]
    string BookMarkValue[2] = ""
    string BinaryStr[4] = ""
    integer MyRow, MyColumn, MyXoffset, MyLine, Value, IsAuditBookMark
    integer IsTSEBookMark

    Hook(_ON_CHANGING_FILES_, mHookKiller)
    Hook(_AFTER_UPDATEDISPLAY_, mHookKiller)
    GotoBufferID(RestoreFileList)
    if lFind(StrBOOKMARKS, "WG")
        repeat
            case mGetFirstWord()     // get the first word on the line
                when StrBOOKMARK
                    IsAuditBookMark = FALSE
                    IsTSEBookMark = FALSE
                    BookMarkValue = mGetSecondWord()
                    Value = Val(BookMarkValue)
                    if Value >= 1 and Value <= AUDITBOOKMARKCOUNT
                        IsAuditBookMark = TRUE
                    elseif Asc(BookMarkValue) >= Asc("A") and
                        Asc(BookMarkValue) <= Asc("Z")
                            IsTSEBookMark = TRUE
                    endif
                when StrBookMarkFileName
                    fn = mGetSecondWord()
                    if Length(fn)
                        fid = mGetThisFile(fn, BinaryStr, IsTSEBookMark)
                        FilenameValid = fid
                    endif
                    BinaryStr = ""
                when StrBookMarkLine
                    MyLine = mGetSecondInt()
                when StrBookMarkColumn
                    MyColumn = mGetSecondInt()
                when StrBookMarkXoffset
                    MyXoffset = mGetSecondInt()
                when StrBookMarkRow
                    if FilenameValid
                        MyRow = mGetSecondInt()
                        if IsAuditBookMark
                            mRestoreBookmark(Value, fid, MyLine, MyColumn,
                                MyXoffset, MyRow)
                        elseif IsTSEBookMark
                            GotoBufferID(fid)
                            GotoLine(MyLine)
                            GotoColumn(MyColumn)
                            GotoXoffset(MyXoffset)
                            ScrollToRow(MyRow)
                            PlaceMark(BookMarkValue)
                            Message (StrRestoring + BookMarkMinus
                                + BookMarkValue + " in " + fn)
                        endif
                        FilenameValid = FALSE
                    endif
                when StrBinary
                    BinaryStr = mGetSecondWord()
            endcase
            GotoBufferID(RestoreFileList)
        until not Down()
        GotoBufferID(MyID)
    endif
    UnHook(mHookKiller)
end mRestoreFilesMarkCoords

/*** mRestoreKeyMacro ***************************************************
 *                                                                      *
 * This macro restores any keyboard macro that would have been saved    *
 * if it existed when the previous shutdown occurred.  Even scrap       *
 * macros, if they exist, are restored by this routine.                 *
 *                                                                      *
 * Called by:   mSessionRestoreCheck()                                  *
 *                                                                      *
 * Enter With:  the KBD filename that is to be restored.  This file     *
 *              is located in the PRJ subdirectory.                     *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mRestoreKeyMacro(string fn)
    integer level

    if EditorVersionMatch
        if FileExists(fn)
            Message(StrRestoring + StrKeyMacros)
            level = Set(MsgLevel, _NONE_)
            LoadKeyMacro(fn)
            Set(MsgLevel, level)
        endif
    endif
end mRestoreKeyMacro

/*** mSetBeforeCommandValues ********************************************
 *                                                                      *
 * These values are captured and stored after each command.  This       *
 * allows audit bookmarks to be set both before and after this command  *
 * completes.                                                           *
 *                                                                      *
 * Called by:   mAfterCommand(), mSessionRestoreCheck()                 *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mSetBeforeCommandValues()
    BeforeCommandAuditID = GetBufferID()
    BeforeCommandAuditLine = CurrLine()
    BeforeCommandAuditColumn = CurrCol()
    BeforeCommandAuditXoffset = CurrXoffset()
    BeforeCommandAuditRow = CurrRow()
end mSetBeforeCommandValues

/*** mAfterCommand ******************************************************
 *                                                                      *
 * File position is stored and checked with current position after      *
 * each command.  If position is significantly different, then an       *
 * audit bookmark will be set.                                          *
 *                                                                      *
 * Called by:   a permanent _AFTER_COMMAND_ hook is set by              *
 *              mSessionRestoreCheck().                                 *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       Use caution in here.  A lot of macros will use this     *
 *              hook, and they all cost CPU.  Keep requirements to an   *
 *              absolute minimum!                                       *
 *                                                                      *
 ************************************************************************/

proc mAfterCommand()
    if BufferType() == _NORMAL_
        if LockOutDoubleAudit
            LockOutDoubleAudit = FALSE
        else
            if GetBufferID() <> BeforeCommandAuditID
                or Abs(CurrLine() - BeforeCommandAuditLine) > Query(ScreenRows)
                    if BeforeCommandAuditID         // something there?
                        UseBeforeValues = TRUE
                        mSetScreenMarks(FALSE)      // write previous bookmark
                        UseBeforeValues = FALSE
                    endif
                    mSetScreenMarks(FALSE)          // write current bookmark
            endif
        endif
        mSetBeforeCommandValues()
    endif
end mAfterCommand

/*** mTrackFileChanges **************************************************
 *                                                                      *
 * This macro is executed each time a file change occurs.  It keeps     *
 * track of the last two buffer ID's in two global variables, allowing  *
 * toggling between the last two accessed buffers whenever a kep is     *
 * pressed.                                                             *
 *                                                                      *
 * Called by:   mSessionRestoreCheck() sets an _ON_CHANGING_FILES_      *
 *              hook.                                                   *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mTrackFileChanges()
    if BufferType() <> _NORMAL_
        return()
    endif
    if GetBufferID() <> CurrentID
        PreviousID = CurrentID
        CurrentID = GetBufferID()
    endif
end mTrackFileChanges

/*** mToggleBuffers *****************************************************
 *                                                                      *
 * This macro allows toggling between the last two accessed buffers.    *
 *                                                                      *
 * Called by:   bind this macro to a key.                               *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mToggleBuffers()
    if PreviousID
        LockOutDoubleAudit = TRUE   // don't track a screen toggle
        GotoBufferID(PreviousID)
        EditFile(CurrFilename())
    endif
end mToggleBuffers

/*** mIsProject *********************************************************
 *                                                                      *
 * Check string s1 to see if it is a project (".prj" or"" extension)    *
 * then check for a project in the "prj" subdirectory.  If a project,   *
 * then return a string with the pathname of the project.  Otherwise    *
 * return a blank string.                                               *
 *                                                                      *
 * Called by:   mSessionRestoreCheck(), mHandleBlankCommandLine()       *
 *                                                                      *
 * Enter With:  a string with the pathname to check.                    *
 *                                                                      *
 * Returns:     the full pathname of the project or a null string.      *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

string proc mIsProject(string s1)
    string s2[255]
    string ProjDir[255] = mGetMacroDir() + "PRJ\"

    s2 = Lower(SplitPath(s1, _EXT_))
    if s2 == ".prj" or s2 == ""
        // get the directory where this .PRJ was requested from.  Note that
        // this is likely the WRONG directory, so a NEW .PRJ file will have
        // been opened -- with the WRONG path, and no project information!
        s2 = Upper(SplitPath(ExpandPath(s1), _DRIVE_ | _PATH_ ))
        if (Upper(ProjDir) == s2) or (not FileExists(s1))
            // correct path to TSE's project directory, might be project
            s2 = ProjDir + SplitPath(s1, _NAME_ ) + ".PRJ"
            if FileExists(s2)           // does a TSE .PRJ file exist?
                return(s2)
            endif
        endif
    endif
    return("")
end mIsProject

/*** mSessionRestoreCheck ***********************************************
 *                                                                      *
 * This macro usually only has effect when the first file is started at *
 * editor startup time.   All files are assumed to be a TSE project     *
 * file if they have a ".PRJ" extention, or if they have NO extention.  *
 *                                                                      *
 * Since the project directory is NOT intended to be in                 *
 * the path, this means that all project files will typically be        *
 * loaded from the wrong directory (and hence will initially be NEW     *
 * files as far as TSE is concerned).  This situation is checked for    *
 * by this macro, and the wrong "NEW" file will automatically be        *
 * exchanged for the correct ".PRJ" file.  Additionally, a ".PRJ"       *
 * extention will be forced to ensure a match.                          *
 *                                                                      *
 * If it is desired to edit a file with no extention, which is the      *
 * same name as a project file, then simply add a "." after the         *
 * filename to bypass project detection.                                *
 *                                                                      *
 * Editor context will then be taken from project file(s) for the       *
 * following:                                                           *
 *                                                                      *
 * ALL files saved in the project                                       *
 * ALL bookmarks                                                        *
 * The current drive & directory of the project files                   *
 * The state of the insert key                                          *
 * The state of autoindent                                              *
 * The state of wordwrap                                                *
 * The state of the right margin                                        *
 * Video Mode (25, 28, 43, or 50 lines)                                 *
 * All history information                                              *
 * Keystroke macros                                                     *
 *                                                                      *
 * Called by:   WhenLoaded()                                            *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mSessionRestoreCheck()
    string ProjDir[255] = mGetMacroDir() + "PRJ\"
    integer filelist = GetBufferID()        // get control buffer ID

    if ProjectChkReqd and BufferType() == _NORMAL_
        ProjectName = mIsProject(CurrFilename())
        if Length(ProjectName)
            if not lFind(StrTSEPROJECT + "=", "g")
                ProjectChkReqd = FALSE
                Warn("This file is not a PROJECTS session snapshot.")
                return()
            endif
            AbandonFile(filelist)       // dump NEW file (wrong path)
            // Clear before opening the control file to avoid recursive restore.
            ProjectChkReqd = FALSE
            EditorVersionOK = TRUE
            EditorVersionMatch = TRUE
            // get real project file now
            RestoreFileList = EditFile(QuotePath(ProjectName))
            if RestoreFileList
                ProjectChkReqd = FALSE
                mRestoreEditorSpecifics()
                mMakeProjGlobal()           // save the name golbally
                if lFind(StrMARKEDBLOCK, "WG")
                    Message(StrRestoring + MarkedSpaceBlock)
                    mRestoreMarkedBlocks(0, 1)
                endif
                mRestoreFilesMarkCoords()
                mRestoreFilesScreenCoords()
                mRestoreClipboard(ProjDir + ProjectName + ".CLP")
                mRestoreKeyMacro(ProjDir + ProjectName + ".KBD")
                mSyncBookMarks(ENDING)      // go to end of bookmarks
                AbandonFile(RestoreFileList)// done, dump the control buffer
                if not NumFiles()
                    ClrScr()
                    mMessageBox("PROJECTS",
                        'Unable to restore project "' + ProjectName + '"``'
                        + "Files may not exist...",
                            FALSE)
                    // Keep TSE running if restored source files no longer exist.
                endif
                UpdateDisplay()
            endif
        endif
    endif
end mSessionRestoreCheck

/*** mHandleBlankCommandLine() ******************************************
 *                                                                      *
 * Provides the user with a picklist of project files.  Whichever one   *
 * the user selects will be added to the Editor command line for        *
 * further processing.                                                  *
 *                                                                      *
 * Called by:   WhenLoaded() macro in TSE.S.  This TSE macro must be    *
 *              modified by adding the line:                            *
 *              // Startup command-line behavior remains owned by projstart/proj.                               *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       This macro MUST be called from WhenLoaded() in TSE.S.   *
 *              The line "mHandleBlankCommandLine()" must be added to   *
 *              the WhenLoaded TSE.S macro.                             *
 *                                                                      *
 ************************************************************************/

proc mHandleBlankCommandLine()
    string s1[255]

    if not NumFiles()
        // blank dos command line/no piped input?
        if not Length(Query(DosCmdLine)) and isCharDevice(_STDIN_)
            mBlankScreen()
            Set(DosCmdLine, mChooseProject())
            SignOn()
        endif
        // a final dot on the command line overrides project checking
        s1 = Query(DosCmdLine)
        if s1[Length(Query(DosCmdLine))] == "."
            ProjectChkReqd = FALSE
        else
            if Length(mIsProject(s1))
                ProjectChkReqd = TRUE
            endif
        endif
    endif
end mHandleBlankCommandLine

/*** mOneTimeThings *****************************************************
 *                                                                      *
 * Do a few things only once when the editor is first loaded.           *
 *                                                                      *
 * Called by:   Hooked in WhenLoaded() to _IDLE_                        *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mOneTimeThings()
    if BufferType() == _NORMAL_
        mSetBeforeCommandValues()
    endif
    Hook(_AFTER_COMMAND_, mAfterCommand)
    Hook(_ON_CHANGING_FILES_, mTrackFileChanges)
    Hook(_ON_CHANGING_FILES_, mRecentFilesTracking)
    CurrentID = GetBufferID()
    UnHook(mOneTimeThings)
end mOneTimeThings

/*** WhenLoaded *********************************************************
 *                                                                      *
 * This macro is executed when the macro file is loaded.  It sets up    *
 * a few hooks, and sets up the startup directory                       *
 *                                                                      *
 * Called by:   TSE at load time                                        *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc WhenLoaded()
    integer id, level

    id = GetBufferId()
    ProjectName = SplitPath(GetGlobalStr(StrProjectName), _NAME_)
    // Snapshot restore is invoked explicitly after EditFile has loaded it.
    Hook(_IDLE_, mOneTimeThings)
    Hook(_ON_FIRST_EDIT_, mOnFirstEdit)
    // present the project picklist if command line is blank
    // Startup command-line behavior remains owned by projstart/proj.
    if not GetBufferID(PrjRecent)
        if not CreateBuffer(PrjRecent, _SYSTEM_)
            Warn("Cannot create '",PrjRecent,"'.  PROJECTS unloaded")
            PurgeMacro(CurrMacroFileName())
        endif
    endif
    level = Set(MsgLevel, _NONE_)
    // timelog is optional and is loaded only when its menu entry is used.
    Set(MsgLevel, level)
    GotoBufferId(id)
end WhenLoaded

/*** Main ***************************************************************
 *                                                                      *
 * This macro is executed when the PROJECTS is executed.  Its only      *
 * function is to save an audit bookmark when this function is called.  *
 *                                                                      *
 * Called by:   PUBLIC MACRO                                            *
 *                                                                      *
 * Enter With:  nothing                                                 *
 *                                                                      *
 * Returns:     nothing                                                 *
 *                                                                      *
 * Notes:       none                                                    *
 *                                                                      *
 ************************************************************************/

proc mRestoreSession()
    string fn[255] = mChooseProject()
    if not Length(fn)
        return()
    endif
    ProjectChkReqd = TRUE
    EditFile(QuotePath(fn))
    mSessionRestoreCheck()
    ProjectChkReqd = FALSE
end

proc Main()
    string action[255] = Lower(Query(MacroCmdLine))
    case action
        when "-save"
            mSaveProjectFiles()
        when "-restore"
            mRestoreSession()
        when "-append"
            mGrowProject()
        otherwise
            mShowMainMenu()
    endcase
end Main

