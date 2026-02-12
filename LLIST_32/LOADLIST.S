/****************************************************************************
 *  FILENAME :  loadlist.s                                                  *
 *  VERSION  :  3.2 (for TSE 2.00)                                          *
 *  AUTHOR   :  Ray Asbury (rasbury@msmailpc01.saic.com)                    *
 *  DATE     :  Fri 09-16-1994 11:04:37                                     *
 *  PURPOSE  :  Loads all files that are listed in the current file, then   *
 *              kills the List file AND goes to the first file that was     *
 *              found.  mLoadFileList() uses LoadWildFromInside to simulate *
 *              wildcard expansion.                                         *
 *                                                                          *
 *              It is possible for some files NOT to be loaded that match   *
 *              the wildcard spec.  This occurs WHEN the base filename      *
 *              matches two OR more extensions in DefaultExt.  Only the     *
 *              file with the extension which occurs first in DefaultExt is *
 *              loaded.                                                     *
 *                                                                          *
 *              The following is a sample of how files may be specified in  *
 *              the List file:                                              *
 *                                                                          *
 *              ÚÄ´listfileÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿ *
 *              ³ *.S     Read.*  .\*.ASC ..\..\*.AS?                     ³ *
 *              ³ -..\..\*.ASC                                            ³ *
 *              ³ C:\AUTOEXEC.BAT                         C:\CONFIG.SY?   ³ *
 *              ³                 -D:.\FIRST.ASC                          ³ *
 *              ³                                                         ³ *
 *              ³ D:.\*.ASC                                               ³ *
 *              ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ *
 *                                                                          *
 *              The following rules apply:                                  *
 *                                                                          *
 *              1.  DOS wildcards (*,?) may be used (see 4 below).          *
 *              2.  Any valid DOS path/filename specification may be used.  *
 *              2.  Filenames may be located anywhere with the List file    *
 *                  as long as they are separated by at least one space,    *
 *                  Tab, OR blank line.                                     *
 *              3.  Files may be excluded by preceding the name with an     *
 *                  '-'.  For example, the above sample says to load all    *
 *                  files with an extension of 'Asc' that are in the root   *
 *                  directory of D: drive, but to exclude 'first.Asc' (Note *
 *                  that it doesn't matter whether the 'INCLUDE' OR         *
 *                  'exclude' occurs first)                                 *
 *              4.  Exclude file specifications MUST NOT INCLUDE any DOS    *
 *                  wildcards.  In the above example, '-..\..\*.ASC' causes *
 *                  a warning Message to appear.  Execution will CONTINUE   *
 *                  WHEN <Escape> is pressed by the user.                   *
 *                                                                          *
 *  USAGE    :  Although LoadList may be used like any other macro          *
 *              (provided that the List file is the current file), the      *
 *              easiest way to use it is to have it automatically executed  *
 *              using the '/E' Command line option of the editor.  For      *
 *              example, "EDIT <List file> /Eloadlist" will start the       *
 *              editor with <List file> as the current file AND then run    *
 *              LoadList.  It should be noted that LoadList purges itself.  *
 *                                                                          *
 *  REVISIONS:  WHO DATE        DESCRIPTION                                 *
 *              --- --------    ------------------------------------------  *
 *              ERA 09-23-92    Added code to enforce execution of the      *
 *                                  mOnChangingFiles() procedure.           *
 *              ERA 09-24-92    Changed EditFile(lsTextLine) to             *
 *                                  EditFile(CurrFileName()+ ' ' +          *
 *                                  lsTextLine) suggested by Kyle Watkins   *
 *                                  via Tom Hogshead)                       *
 *              ERA 08-03-93    Replaced 09-24-92 modification with         *
 *                                  ExecHook() call                         *
 *                              Removed logic surrounding LoadWildFromInside*
 *              ERA 08-08-94    Changed symbols to my conventions           *
 *                              Bumped version to "3.1"                     *
 *              ERA 09-16-94    Re-compiled for TSE 2.00                    *
 *                              Bumped version to "3.2"                     *
 ****************************************************************************/

PROC Main()

    STRING  lsTextLine[254]     = ""

    INTEGER liFirstFileID       = 0,
            liInitLoadInside    = Set(LoadWildFromInside, TRUE),
            liListFileID        = GetBufferID(),
            liSearchFileID

    Set(MsgLevel, _NONE_)
    Set(Cursor, OFF)

    /* INSURE THAT EACH FILESPEC IS ON A LINE BY ITSELF *********************/

    WHILE (LFind('\c #', 'x'))
        DelRightWord()
        CReturn()
    ENDWHILE

    /* LOAD THE FILES *******************************************************/

    BegFile()
    REPEAT
        MarkLine()
        lsTextLine = GetMarkedText()
        IF ( (lsTextLine <> '') AND (lsTextLine[1] <> '-') )
            PrevFile()
            Message(Format("Loading ", lsTextLine:-70))
            EditFile(CurrFileName() + " " + lsTextLine)
            IF NOT liFirstFileID
                NextFile(_DONT_LOAD_)
                liFirstFileID = GetBufferID()
                PrevFile(_DONT_LOAD_)
            ENDIF
            GotoBufferID(liListFileID)
        ENDIF
        UnMarkBlock()
    UNTIL NOT Down()

    /* REMOVE FILES MARKED FOR REMOVAL **************************************/

    BegFile()
    REPEAT
        MarkLine()
        lsTextLine = GetMarkedText()
        IF ( (lsTextLine <> '') AND (lsTextLine[1] == '-') )
            lsTextLine = SubStr(lsTextLine, 2, (Length(lsTextLine) - 1))
            liSearchFileID = 0
            liSearchFileID = GetBufferID(lsTextLine)
            IF (liSearchFileID)
                AbandonFile(liSearchFileID)
                GotoBufferID(liListFileID)
            ELSE
                Warn('Unable to remove ' + lsTextLine)
            ENDIF
        ENDIF
        UnMarkBlock()
    UNTIL NOT Down()

    /* REMOVE THE liListFileID BUFFER FROM THE EDITOR ***********************/

    AbandonFile(liListFileID)

    /* GO TO THE FIRST FILE THAT WAS LOADED *********************************/

    GotoBufferID(liFirstFileID)
    ExecHook(_ON_CHANGING_FILES_)

    /* RESET IF NECESSARY ***************************************************/

    Set(LoadWildFromInside, liInitLoadInside)

    /* FINISH Up ************************************************************/

    UpdateDisplay(_STATUSLINE_REFRESH_ | _WINDOW_REFRESH_)
    Set(Cursor, ON)
    PurgeMacro(CurrMacroFileName())
END Main

