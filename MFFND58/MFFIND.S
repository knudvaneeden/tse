/****************************************************************************
 *  FILENAME :  mffind.s                                                    *
 *  VERSION  :  5.8 (for TSE Pro 2.50a)                                     *
 *  AUTHOR   :  Ray Asbury (rasbury@msmailpc01.saic.com)                    *
 *  COPYRIGHT:  1995 E. Ray Asbury, Jr.  All Rights Reserved Worldwide.     *
 *  DATE     :  Mon 11-20-1995 09:38:34                                     *
 *  FILES    :  mffind.inc      mffind2.inc     mffind.ini                  *
 *              mffind.s        mffind2.s       mffind3.s                   *
 *              mffind4.s       mffind5.s       mffind6.s                   *
 *                                                                          *
 *  PURPOSE  :  MFFind is a multi-file search and replace utility, which    *
 *              supports most of the search and replace options of The      *
 *              Semware Editor (TSE) including Regular Expressions.         *
 *                                                                          *
 *              See the on-line help for more information.                  *
 *                                                                          *
 *  SETUP    :  First, copy all of the files (MFFIND*.*) to a directory     *
 *              listed in your System Interface variable, 'TSEPath'.        *
 *                                                                          *
 *              Second, change the key bindings at the end of this file to  *
 *              your own preferences.                                       *
 *                                                                          *
 *              Next, compile this file, using the command                  *
 *                                                                          *
 *                  "SC MFFIND"                                             *
 *                                                                          *
 *              After running MultiFind, you may wish to change some of the *
 *              custom settings, using the "Configure" menu option.         *
 *                                                                          *
 *  COMMENTS :  If you have any questions, comments, or suggestions, please *
 *              contact me either on any of the Semware mail conferences    *
 *              (except for CompuServe), or rasbury@msmailpc01.saic.com.    *
 *                                                                          *
 *  POSSIBLE                                                                *
 *  FUTURE                                                                  *
 *  FEATURES :  Add change indicator on replaces                            *
 *              Add ability to remove files from the ring based on a search *
 *                  string (both when it has string, and when it doesn't)   *
 *              Add ability to specify how many adjacent lines must meet    *
 *                  the search criteria before being considered a 'hit'     *
 *                                                                          *
 *  REVISIONS:  WHO DATE        DESCRIPTION                                 *
 *              --- --------    ------------------------------------------  *
 *              ERA 08-03-94    Added support for choosing history usage    *
 *                              Bumped version to "3.0"                     *
 *              ERA 08-04-94    Fixed mis-spelling in prompt strings        *
 *                              Auto highlight first hit on first picklist  *
 *                              Bumped version to "3.1"                     *
 *              ERA 08-08-94    Renamed symbols to my conventions           *
 *                              Bumped version to "3.2"                     *
 *              ERA 08-10-94    Modified to use PutHelpLine()               *
 *                              Added searching on current word             *
 *                              Added searching for functions               *
 *                              Bumped version to "3.3"                     *
 *              ERA 09-04-94    Re-compiled for TSE "1.60a"                 *
 *                              Bumped version to "3.4"                     *
 *              ERA 09-15-94    Corrected prompt strings                    *
 *                              Added menu option for help                  *
 *                              Bumped version to "3.5"                     *
 *              ERA 09-26-94    Added code to remove search/replace options *
 *                                  which aren't needed and to report them  *
 *                              Changed displayed TSE version to "2.00"     *
 *                              Added support for SAL DATADEF, HELPDEF, &   *
 *                                  KEYDEF to Find Functions                *
 *                              Bumped version to "3.7"                     *
 *              ERA 11-09-94    Added ability to delete lines based on      *
 *                                  whether they do (or don't) contain a    *
 *                                  user-specified string                   *
 *                              Bumped version to "3.8"                     *
 *              ERA 11-18-94    Reduced filename strings to 127 chars       *
 *                              Added ExecHook when exiting picklist file   *
 *                              Bumped version to "3.9"                     *
 *              ERA 11-22-94    Removed GotoBlock special handling          *
 *                              Bumped version to "4.0"                     *
 *              ERA 12-01-94    Allow user to specify characters for        *
 *                                  "select line" filling and also for      *
 *                                  "buffer id line" filling                *
 *                              Added hit counts for individual buffers     *
 *                              Added Incremental Search capability         *
 *                              Added ability to delete blank lines         *
 *                              Added ability to delete duplicate lines     *
 *                              Code cleanup and format changes             *
 *                              Bumped version to "4.1"                     *
 *              ERA 12-09-94    Restore existing block when exitting        *
 *                              Added cursor navigation to incremental      *
 *                              search (PageUp, PageDown, Up, & Down)       *
 *                              Added help text                             *
 *                              Bumped version to "4.2"                     *
 *              ERA 12-16-94    Added ability to add up to 10 user-defined  *
 *                                  file extensions for the function search *
 *                              Bumped version to "4.3"                     *
 *              ERA 12-20-94    Added use of INI file and ability to        *
 *                              configure it from the menu                  *
 *                              Bumped version to "4.4"                     *
 *              ERA 12-29-94    Force files to appear in picklist in same   *
 *                                  order as they exist in the ring, which  *
 *                                  may not correspond to ascending ID's    *
 *                                  (TSE allows file to be added anywhere   *
 *                                  within the ring, not just at the end,   *
 *                                  while buffer ID's are created on an     *
 *                                  incrementing basis)                     *
 *                              Re-organized menu structure                 *
 *                              Added configuration option to specify       *
 *                                  whether to pause during function        *
 *                                  searches when a file has an un-         *
 *                                  supported extension                     *
 *              ERA 01-05-95    Updated the help window                     *
 *              ERA 01-09-95    Fixed find string for special case of "^$"  *
 *                              Fixed delete lines {not}? containing proc   *
 *                              Bumped version to "4.5"                     *
 *              ERA 01-13-95    Added ability to generate ini file          *
 *                              Re-organized code distribution across files *
 *                              Added use of FindOptions setting when using *
 *                                  own histories                           *
 *                              Bumped version to "4.6"                     *
 *              ERA 01-26-95    Fixed display of replace prompt when not    *
 *                                  using the "N" option                    *
 *                              Fixed incorrect counts when replace found   *
 *                                  multiple "hits" on the same line        *
 *                              Added ability to "mark" secondary hits on   *
 *                                  the same line                           *
 *                              Fixed "Next" & "Previous" when encountering *
 *                                  a hit that was in a file which is no    *
 *                                  loaded                                  *
 *                              Re-worked history code                      *
 *                              Re-worked INI file code                     *
 *                              Word Search case sensitivity configureable  *
 *                              Bumped version to "4.7"                     *
 *              ERA 01-30-95    Added small help screen to hit-file display *
 *              ERA 01-31-95    Added progress messages to all searches &   *
 *                                  made it configureable                   *
 *              ERA 02-01-95    Added options to find lines                 *
 *                                  þ not containing a specified string     *
 *                                  þ which are blank                       *
 *                                  þ which are adjacent duplicates         *
 *                              Properly adjust line numbers when going to  *
 *                                  the location of a deleted line          *
 *              ERA 02-02-95    Added configureable verification when       *
 *                                  replacing text with an existing string  *
 *                                  (even when using Regular Expressions)   *
 *              ERA 02-06-95    Re-formatted messages                       *
 *                              Bumped version to "4.8"                     *
 *              ERA 02-11-95    Added 'Ask' option to these settings:       *
 *                                  Progress Messages                       *
 *                                  Distinguish Secondary Hits              *
 *                                  Verify Before Replacing                 *
 *                                  Word Search Case Sensitive              *
 *                              Added threshold for forcing progress        *
 *                                  messages                                *
 *                              Bumped version to "4.9"                     *
 *              ERA 02-13-95    Prevent endless loop on empty files         *
 *              ERA 02-14-95    Removed need to re-load when changing       *
 *                                  history types                           *
 *              ERA 02-21-95    Added "ask" option to all yes/no config     *
 *                                  settings which didn't have it           *
 *                              Added default "ask" answer to all           *
 *                                  yes/no/ask config settings              *
 *                              Bumped version to "5.0"                     *
 *              ERA 03-01-95    Fixed rare problem with deleting blank      *
 *                                  lines                                   *
 *                              Added 1-line C-style comment search         *
 *              ERA 03-02-95    Re-compiled for TSE Pro 2.01y               *
 *                              Bumped version to "5.1"                     *
 *              ERA 03-08-95    Updated Incremental Search help             *
 *              ERA 03-10-95    Fixed auto first hit highlight on line      *
 *                                  search options                          *
 *              ERA 03-15-95    Updated function search & compress view     *
 *                              Added main to start menu if MFFind is run   *
 *                              via ExecMacro or run from the Public list   *
 *                              Bumped version to "5.2"                     *
 *              ERA 04-05-95    Re-compiled for TSE Pro 2.02e               *
 *                              Fixed picklist header line count problem    *
 *                              Bumped version to "5.3"                     *
 *              ERA 04-22-95    Re-compiled for TSE Pro 2.02t               *
 *                              Bumped version to "5.4"                     *
 *              ERA 04-22-95    Bumped version to "5.5"                     *
 *              ERA 06-14-95    Removed Incremental Search                  *
 *                              Re-compiled for TSE Pro 2.02z               *
 *                              Bumped version to "5.6"                     *
 *              ERA 10-15-95    Changed some code to utilizie 2.50a         *
 *                                  features                                *
 *                              Re-compiled for TSE Pro 2.50a               *
 *                              Bumped version to "5.7"                     *
 *              ERA 11-20-95    Re-located help screen to (2,2) rather than *
 *                                  (4,4)                                   *
 *                              Fixed save of "Distinguish Secondary ..."   *
 *                              Bumped version to "5.8"                     *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> GLOBAL      Constants                                       *
 ****************************************************************************/

/* !!!WARNING!!! DO NOT CHANGE THE FOLLOWING VALUES!!! **********************/

CONSTANT    koNBR_MAC_FILES                 = 6,
            koOPT_CONFIG_MFFIND             = 0x01,
            koOPT_DEL_LINES_BLNKS           = 0x02,
            koOPT_DEL_LINES_DUPS            = 0x03,
            koOPT_DEL_LINES_EXCLX           = 0x04,
            koOPT_DEL_LINES_INCLX           = 0x05,
            koOPT_FIND_CMNTS_BOTH           = 0x06,
            koOPT_FIND_CMNTS_C              = 0x07,
            koOPT_FIND_CMNTS_CPP            = 0x08,
            koOPT_FIND_CUR_WORD             = 0x09,
            koOPT_FIND_FCNS                 = 0x0A,
            koOPT_FIND_LINE_BLNKS           = 0x0B,
            koOPT_FIND_LINE_DUPS            = 0x0C,
            koOPT_FIND_LINE_EXCLX           = 0x0D,
            koOPT_FIND_LINE_INCLX           = 0x0E,
            koOPT_FIND_STR                  = 0x0F,
            koOPT_HIT_NEXT                  = 0x10,
            koOPT_HIT_PREVIOUS              = 0x11,
            koOPT_INIT_MFFIND               = 0x12,
            koOPT_PICK_AGAIN                = 0x13,
            KoOPT_REPLACE_STR               = 0x14,
            koOPT_SET_HISTORIES             = 0x15,
            koOPT_SHOW_HELP                 = 0x16

/****************************************************************************
 *  SECTION --> GLOBAL      String Variables                                *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> GLOBAL      Integer Variables                               *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> GLOBAL      Include Files                                   *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> GLOBAL      Forward Declarations                            *
 ****************************************************************************/

FORWARD         MENU mnMFFind()
FORWARD         MENU mnMFFindDelete()
FORWARD         MENU mnMFFindLines()
FORWARD         PROC pnMFFind(INTEGER lpiWhichOpt)
FORWARD INTEGER PROC pnLoadOtherMacFile(STRING lpsWhichOne)

/****************************************************************************
 *  SECTION --> GLOBAL      Data Definitions                                *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> GLOBAL      Help Definitions                                *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> GLOBAL      Key Definitions                                 *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> SYSPROC     WhenLoaded                                      *
 ****************************************************************************/

PROC WhenLoaded()   //  !!!WARNING!!! CHANGE THIS PROCEDURE AT YOUR OWN RISK!!

    INTEGER liMacMissing    = FALSE,
            liCntr          = 2

    WHILE (liCntr <= koNBR_MAC_FILES)
        liMacMissing = pnLoadOtherMacFile(Str(liCntr))
        liCntr = IIF(liMacMissing, MAXINT, (liCntr + 1))
    ENDWHILE
    IF (liMacMissing)
        Warn("MFFind: Unable to load MFFIND", liMacMissing:1, ".MAC!")
        WHILE (liMacMissing > 2)
            liMacMissing = liMacMissing - 1
            PurgeMacro("MFFIND" + Str(liMacMissing))
        ENDWHILE
        PurgeMacro(CurrMacroFileName())
        Return()
    ENDIF
    pnMFFind(koOPT_INIT_MFFIND)
END WhenLoaded

/****************************************************************************
 *  SECTION --> SYSPROC     WhenPurged                                      *
 ****************************************************************************/

PROC WhenPurged()

    INTEGER liCnt = koNBR_MAC_FILES

    WHILE (liCnt > 1)
        PurgeMacro("MFFIND" + Str(liCnt))
        liCnt = liCnt - 1
    ENDWHILE
END WhenPurged

/****************************************************************************
 *  SECTION --> SYSPROC     Main                                            *
 ****************************************************************************/

PROC Main()
    mnMFFind()
END Main

/****************************************************************************
 *  SECTION --> SYSPROC     Hooked Procedures                               *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> PROCS       Support Procedures                              *
 ****************************************************************************/

INTEGER PROC pnLoadOtherMacFile(STRING lpsWhichOne)
    IF (NOT IsMacroLoaded("MFFIND" + lpsWhichOne))
        IF (NOT LoadMacro("MFFIND" + lpsWhichOne))
            Return(Val(lpsWhichOne))
        ENDIF
    ENDIF
    Return(FALSE)
END pnLoadOtherMacFile

PROC pnMFFind(INTEGER lpiWhichOpt)

    INTEGER liBlkMarked = IsBlockMarked()

    SetGlobalInt("giMFFndCmd", lpiWhichOpt)
    IF (liBlkMarked)
        PushBlock()
    ENDIF
    ExecMacro("MFFIND2")
    IF (liBlkMarked)
        PopBlock()
    ENDIF
    ExecHook(_ON_CHANGING_FILES_)
END pnMFFind

/****************************************************************************
 *  SECTION --> PROCS       User Procedures                                 *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> MENU        The Menus                                       *
 ****************************************************************************/

MENU mnMFFind()
    Title = "Multi-File Find/Replace v5.8"
    History

    // HOTKEY USE:  CDEFHIMNORUW

    "&Find String...",      pnMFFind(koOPT_FIND_STR),           CloseAllBefore
    "Find Current &Word",   pnMFFind(koOPT_FIND_CUR_WORD),      CloseAllBefore
    "Find Fun&ctions",      pnMFFind(koOPT_FIND_FCNS),          CloseAllBefore
    "Find &Lines       ",  mnMFFindLines(),                    DontClose
    "",                     ,                                   Divide
    "&Replace...",          pnMFFind(KoOPT_REPLACE_STR),        CloseAllBefore
    "",                     ,                                   Divide
    "&Delete Lines     ",  mnMFFindDelete(),                   DontClose
    "",                     ,                                   Divide
    "Sh&ow Hit-list",       pnMFFind(koOPT_PICK_AGAIN),         CloseAllBefore
    "&Next Hit",            pnMFFind(koOPT_HIT_NEXT),           CloseAllBefore
    "Pr&evious Hit",        pnMFFind(koOPT_HIT_PREVIOUS),       CloseAllBefore
    "",                     ,                                   Divide
    "Config&ure MFFind ",  pnMFFind(koOPT_CONFIG_MFFIND),      DontClose
    "&Help",                pnMFFind(koOPT_SHOW_HELP),          DontClose
    "",                     ,                                   Divide
    "Remove From &Memory",  PurgeMacro(CurrMacroFileName()),    CloseAllBefore
END mnMFFind

MENU mnMFFindDelete()
    Title = "MFFind v5.8 - Delete Lines"
    History

    // HOTKEY USE:  BCDN

    "&Blank",               pnMFFind(koOPT_DEL_LINES_BLNKS),    CloseAllBefore
    "&Duplicates",          pnMFFind(koOPT_DEL_LINES_DUPS),     CloseAllBefore
    "&Containing...",       pnMFFind(koOPT_DEL_LINES_INCLX),    CloseAllBefore
    "&Not Containing...",   pnMFFind(koOPT_DEL_LINES_EXCLX),    CloseAllBefore
END mnMFFindDelete

MENU mnMFFindLines()
    Title = "MFFind v5.8 - Find Lines"
    History

    // HOTKEY USE:  BCDNOS+

    "&Blank",               pnMFFind(koOPT_FIND_LINE_BLNKS),    CloseAllBefore
    "&Duplicates",          pnMFFind(koOPT_FIND_LINE_DUPS),     CloseAllBefore
    "&Containing...",       pnMFFind(koOPT_FIND_LINE_INCLX),    CloseAllBefore
    "&Not Containing...",   pnMFFind(koOPT_FIND_LINE_EXCLX),    CloseAllBefore
    "1-Line Comments",      ,                                   Divide
    "&Standard C",          pnMFFind(koOPT_FIND_CMNTS_C),       CloseAllBefore
    "C&++",                 pnMFFind(koOPT_FIND_CMNTS_CPP),     CloseAllBefore
    "B&oth",                pnMFFind(koOPT_FIND_CMNTS_BOTH),    CloseAllBefore
END mnMFFindLines

/****************************************************************************
 *  SECTION --> KEYS        Key Bindings                                    *
 ****************************************************************************/

  <AltShift 1>              pnMFFind(koOPT_HIT_PREVIOUS)
  <AltShift 2>              pnMFFind(koOPT_HIT_NEXT)
  <Alt v><a>                pnMFFind(koOPT_PICK_AGAIN)
  <Alt v><c>                pnMFFind(koOPT_FIND_FCNS)
  <Alt v><d>                mnMFFindDelete()
  <Alt v><f>                pnMFFind(koOPT_FIND_STR)
  <Alt v><h>                pnMFFind(koOPT_SHOW_HELP)
  <Alt v><l>                mnMFFindLines()
  <Alt v><n>                pnMFFind(koOPT_HIT_NEXT)
  <Alt v><p>                pnMFFind(koOPT_HIT_PREVIOUS)
  <Alt v><r>                pnMFFind(KoOPT_REPLACE_STR)
  <Alt v><u>                pnMFFind(koOPT_CONFIG_MFFIND)
  <Alt v><v>                mnMFFind()
  <Alt v><w>                pnMFFind(koOPT_FIND_CUR_WORD)

