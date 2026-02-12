/****************************************************************************
 *  FILENAME :  mffind2.s                                                   *
 *  VERSION  :  5.8 (for TSE Pro 2.50a)                                     *
 *  AUTHOR   :  Ray Asbury (rasbury@msmailpc01.saic.com)                    *
 *  COPYRIGHT:  1995 E. Ray Asbury, Jr.  All Rights Reserved Worldwide.     *
 *  DATE     :  Mon 11-20-1995 09:38:34                                     *
 *  FILES    :  mffind.inc      mffind2.inc     mffind.ini                  *
 *              mffind.s        mffind2.s       mffind3.s                   *
 *              mffind4.s       mffind5.s       mffind6.s                   *
 *                                                                          *
 *  PURPOSE  :  Help support functions                                      *
 *                                                                          *
 *  REVISIONS:  WHO DATE        DESCRIPTION                                 *
 *              --- --------    ------------------------------------------  *
 *              [SEE REVISIONS LIST IN MFFIND.S]                            *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> GLOBAL      Constants                                       *
 ****************************************************************************/

// SEE MFFIND.INC FOR ADDITIONAL CONSTANTS

/****************************************************************************
 *  SECTION --> GLOBAL      String Variables                                *
 ****************************************************************************/

// SEE MFFIND.INC FOR ADDITIONAL CONSTANTS

/****************************************************************************
 *  SECTION --> GLOBAL      Integer Variables                               *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> GLOBAL      Include Files                                   *
 ****************************************************************************/

#include ["mffind.inc"]

/****************************************************************************
 *  SECTION --> GLOBAL      Forward Declarations                            *
 ****************************************************************************/

FORWARD         PROC pnPromptStartup()

/****************************************************************************
 *  SECTION --> GLOBAL      Data Definitions                                *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> GLOBAL      Help Definitions                                *
 ****************************************************************************/

/* RIGHT MARGIN SHOULD BE 74 - ALSO, ADD A SPACE TO END OF LONGEST LINE *****/

HELPDEF hdText
"Multi-File Find/Replace v 5.8"
"Compatible with The SemWare Editor Pro v2.50a"
"Copyright (c) 1995 by E. Ray Asbury, Jr."
"All Rights Reserved Worldwide"
"SemWare is a registered trademark of SemWare Corporation"
""
"General Description"
"อออออออออออออออออออ"
""
"  MFFind is a multi-file search and replace utility, which supports most"
"  of the search and replace options of The Semware Editor (TSE) including"
"  Regular Expressions."
""
"  Besides the usual stuff, MFFind uses a special 'hit-list' file so that"
"  you can navigate from one 'hit' to the next (or back).  Simply place the "
"  cursor on the line you wish to visit, and press enter.  You may also"
"  jump to the previous or next 'hit' without re-visiting the 'hit-list'"
"  file (see 'Next' and 'Previous' below).  When replacing text, the"
"  'hit-list' shows what the text was before the replacement, so that you"
"  can compare the before/after text before saving it!"
""
"  It should be noted that, when a line contains multiple 'hits', that line"
"  will show up in the 'hit-list' file once for each hit.  You may"
"  configure how such lines are listed in the 'hit-list' file."
""
"  Lines may be deleted from all files in the buffer ring based on the"
"  following criteria:"
""
"    þ Blank lines"
"    þ Duplicate lines which are adjacent to each other"
"    þ Lines containing a user-specified string"
"    þ Lines which do not contain a user-specified string"
""
"  You can also edit the 'hit-list' file, if you have the need."
""
"  Additionally, MFFind can be configured to"
""
"    þ Be case sensitive/insensitive when doing 'word' searches"
"    þ Display progress messages"
"    þ Pause on errors"
"    þ Recognize up to ten custom file extensions for function searches"
"    þ Use either the standard histories of TSE or it's own"
"    þ Use user-specified fill characters for the 'hit-list' file"
""
"Installation"
"ออออออออออออ"
""
"  First, copy all of the files (MFFIND*.*) to a directory listed in your"
"  System Interface variable, 'TSEPath'."
""
"  Second, change the key bindings at the end of this file to your own"
"  preferences."
""
"  Next, compile this file, using the command"
""
"    'SC MFFIND'"
""
"  After running MultiFind, you may wish to change some of the custom"
"  settings, using the 'Configure' menu option.  Your configuration"
"  settings are kept in an INI file, which may be directly edited, if you"
"  so wish."
""
"Usage"
"อออออ"
""
"  þ Find String"
""
"      Searches all files in the buffer ring for the user-specified string."
"      Regular expressions are supported."
""
"  þ Find Current Word"
""
"      Searches all files in the buffer ring for the word on which the"
"      cursor is located.  If the cursor is not on a word (i.e., the"
"      current character is not in the current WordSet), a message is"
"      displayed, and the search is aborted.  The configuration menu may be"
"      used to determine whether the search is sensitive to case or not."
""
"  þ Find Functions"
""
"      Similar to the stock CompressView, except that all recognized files"
"      in the buffer ring are searched.  Currently, this feature supports"
"      files with the following extensions:"
""
"        bat     c       ch      cpp     fmt     frg     h       inc"
"        lbg     mpr     pc      prg     qpr     s       spr     ui"
""
"      Additionally, you may specify up to ten custom file extensions.  If"
"      any files with other extensions (other than user-defined ones) are"
"      in the buffer ring, a warning may be displayed (if 'Pause on Find"
"      Functions Errors' is TRUE) and they are skipped over during the"
"      search.  If you specify a definition for any of the above"
"      extensions, your definition will override the default definition."
""
"  þ Find Lines"
""
"    þ Blank"
""
"        Finds all blank lines in all files in the buffer ring."
""
"    þ Duplicates"
""
"        Finds lines in all files in the buffer ring which are adjacent to"
"        another line(s) which is has the exact same text.  For example,"
"        if three adjacent lines have the same text, in the same location,"
"        the last two of them will be found."
""
"    þ Containing"
""
"        Finds all lines in all files in the buffer ring which contain"
"        the user-specified search string.  Regular expressions are"
"        supported.  Although very similar to 'Find String', this option"
"        will only list a line once, even when the line may contain the"
"        search string more than once."
""
"    þ Not Containing"
""
"        Finds all lines in all files in the buffer ring which do not"
"        contain the user-specified search string.  Regular expressions are"
"        supported."
""
"    þ 1-Line Comments"
""
"      þ Standard C"
""
"          Finds all lines which are, in their entirety, a C style comment."
""
"      þ C++"
""
"          Finds all lines which are, in their entirety, a C++ style"
"          comment."
""
"      þ Both"
""
"          Finds all lines which are, in their entirety, either a C or a"
"          C++ style comment."
""
"  þ Replace"
""
"      Very similar to the stock Replace command, except for the following:"
""
"        þ All files in the buffer ring are processed"
"        þ The 'L' (local) option is ignored."
""
"      The Hit-list will show the text before the replace was made.  This"
"      can be handy to verify proper operation, as well as providing a"
"      reference to use if you need to make manual changes after executing"
"      a Replace."
""
"  þ Delete Lines"
""
"    þ Blank"
""
"        Deletes all blank lines in all files in the buffer ring."
""
"    þ Duplicates"
""
"        Deletes duplicate lines in all files in the buffer ring which are"
"        adjacent to another line(s) which is exactly the same.  For"
"        example, if three adjacent lines have the same text, in the same"
"        location, two of them will be deleted."
""
"    þ Containing"
""
"        Deletes all lines in all files in the buffer ring which contain"
"        the user-specified search string.  Regular expressions are"
"        supported."
""
"    þ Not Containing"
""
"        Deletes all lines in all files in the buffer ring which do not"
"        contain the user-specified search string.  Regular expressions are"
"        supported."
""
"  þ Show Hit-list"
""
"      Displays the results of any of the above options (except for"
"      showing filename, line number, up to 79 characters of the line's"
"      text, the buffer's ID number, and the beginning column where"
"      the target text was found.  The hit-list provides a summary of the"
"      last operation, and the user may edit a copy of this file, if"
"      desired."
""
"  þ Next"
""
"      Automatically takes you to the location of the next 'hit'.  However,"
"      it doesn't 'wrap' around from the last to the first."
""
"      If you have successfully executed a search, but escaped out of the"
"      'hit-file', pressing this option will take you to the first 'hit'."
""
"  þ Previous"
""
"      Automatically takes you to the location of the previous 'hit'.  As"
"      with 'Next', this option doesn't 'wrap' from the first to the last."
""
"      If you have successfully executed a search, but escaped out of the"
"      'hit-file', pressing this option will display the message,"
"      'MFFind: At first hit'."
""
"  þ Configure MFFind"
""
"    þ Custom File Settings"
""
"        You can set up MFFind to recognize up to ten additional file"
"        extensions when searching for functions.  For each one, you"
"        specify the extension, as well as the search string to use.  If"
"        you are not familiar with Regular Expressions, please consult the"
"        manuals.  Here are the extensions MFFind automatically handles,"
"        and their respective search strings:"
""
"          '.c', '.cpp', '.h', '.pc'"
""
"            '^{[a-zA-Z_].*}{) *\x7b *{{/\x2a.*\x2a/}|{//.*}}*}$'"
""
"          '.s', '.ui', '.inc'"
""
"            '^{{PUBLIC #}?{{INTEGER}|{STRING} #}?PROC}|{MENUBAR}|' +"
"            '{MENU}|{[DH][AE][LT][AP]DEF}|{KEYDEF} +[a-zA-Z_]\c'"
""
"          '.prg','.spr','.mpr','.qpr','.fmt','.frg','.lbg','.ch'"
""
"            '^{procedure}|{function} +[a-zA-Z_]'"
""
"        If a custom file setting's extension is also one of the pre-"
"        defined extensions, the custom file settings take precedence."
""
"    þ Distinguish Secondary Group Hits"
""
"        This option is used to differentiate hits which are located near"
"        each other.  There are two types of 'grouped' hits:"
""
"          þ Multiple hits on the same line"
""
"              This type applies to the following search methods:"
""
"                þ Find Current Word"
"                þ Find String"
"                þ Replace"
""
"              When 'hits' are found on the same line, that line will"
"              appear in the hit-file once for each hit.  If this option is"
"              set to YES, each subsequent hit on a line will be shown in"
"              the hit-file as a 'secondary hit' and the text of the line"
"              will not be duplicated."
""
"          þ Hits on adjacent lines"
""
"              This type applies to the following search methods:"
""
"                þ Find Blank Lines"
"                þ Find Duplicate Lines"
""
"              When adjacent lines meet the search criteria, each line will"
"              be marked as an 'adjacent hit' if this option is set to YES."
"              An exception is that the first line of adjacent lines will"
"              contain the original text."
""
"        You may be prompted for which setting to use 'on the fly' by"
"        setting this option to 'Ask'.  When doing so, you will be further"
"        asked which option ('yes' or 'no') you wish to be the default"
"        (highlighted) when being prompted 'on the fly'."
""
"    þ Fill Characters"
""
"      þ Select Line Fill Character"
""
"          This character is used to 'fill' the line in the 'hit-list' file"
"          which is used to edit a copy of the 'hit-list' file."
""
"      þ Buffer Line Fill Character"
""
"          This character is used to 'fill' lines in the 'hit-list' file"
"          where each filename is located."
""
"    þ Histories"
""
"        This setting is used to determine whether MFFind will use its own"
"        history lists or the lists for the standard Find & Replace"
"        commands.  When using separate histories, the setting of TSE's"
"        'FindOptions' is used for the beginning default search option."
""
"    þ Minimal Screen Updating"
""
"        Setting this option to YES stops most screen updating, thus"
"        providing the fastest possible performance."
""
"        You may be prompted for which setting to use 'on the fly' by"
"        setting this option to 'Ask'.  When doing so, you will be further"
"        asked which option ('yes' or 'no') you wish to be the default"
"        (highlighted) when being prompted 'on the fly'."
""
"    þ Pause on 'Find Functions' Errors"
""
"        During Function Searches, MFFind can be set to either pause when a"
"        file is encountered which is not recognized, or to simply proceed,"
"        ignoring that file."
""
"        You may be prompted for which setting to use 'on the fly' by"
"        setting this option to 'Ask'.  When doing so, you will be further"
"        asked which option ('yes' or 'no') you wish to be the default"
"        (highlighted) when being prompted 'on the fly'."
""
"    þ Progess Messages"
""
"      þ Display"
""
"          MFFind can display running progress messages during lengthy"
"          processes by setting this option to YES.  Although it does"
"          affect performance, turning the messages on will provide a"
"          visual indication during long searches that MFFind is still"
"          running."
""
"          You may be prompted for which setting to use 'on the fly' by"
"          setting this option to 'Ask'.  When doing so, you will be"
"          further asked which option ('yes' or 'no') you wish to be the"
"          default (highlighted) when being prompted 'on the fly'."
""
"      þ Automatic Display Threshold"
""
"          This is used to determine when MFFind wil automatically begin"
"          to display progress messages, regardless of the 'Display'"
"          setting.  When the total number of lines in all of the loaded"
"          fiels exceeds this value, progress messages automatically"
"          appear."
""
""
"    þ Verify Before Replacing"
""
"        This option can be very useful when you are changing a string and"
"        want to be sure that the string you are changing it to doesn't"
"        already exist."
""
"        If this option is set to YES, MFFind will look for the"
"        replacement string in all of the files before allowing the"
"        replacement to occur, even if you are using Regular Expressions."
"        When determining whether the replacement already exists, MFFind"
"        will prompt you for the search options to use.  The available"
"        options are limited to 'I' & 'W'.  If the replacement string"
"        already exists in a file, MFFind will prompt you as to whether to"
"        continue or not.  If you chose not to, you will be prompted"
"        whether to go to the location of the found string."
""
"        You may be prompted for which setting to use 'on the fly' by"
"        setting this option to 'Ask'.  When doing so, you will be further"
"        asked which option ('yes' or 'no') you wish to be the default"
"        (highlighted) when being prompted 'on the fly'."
""
"    þ Word Search Case Sensitive"
""
"        Use this option to specify whether 'Word' searches should be"
"        sensitive to case or not."
""
"        You may be prompted for which setting to use 'on the fly' by"
"        setting this option to 'Ask'.  When doing so, you will be further"
"        asked which option ('yes' or 'no') you wish to be the default"
"        (highlighted) when being prompted 'on the fly'."
""
"    þ Restore Settings from INI File"
""
"        This option will re-read the MFFIND.INI file, resetting all of the"
"        configuration options, except for History Use, which requires that"
"        MFFind be removed from memory and reloaded."
""
"    þ Save Current Settings as default"
""
"        This option writes all current configuration options to the"
"        MFFIND.INI file."
""
"  þ Help"
""
"      Displays this text."
""
"  þ Remove From Memory"
""
"      Removes MFFind from memory."
""
"Support"
"อออออออ"
""
"  Should you have any questions, comments, or suggestions, please contact"
"  me either on any of the Semware mail conferences (except for"
"  CompuServe), or rasbury@msmailpc01.saic.com."
""
END hdText

/****************************************************************************
 *  SECTION --> GLOBAL      Key Definitions                                 *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> SYSPROC     WhenLoaded                                      *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> SYSPROC     WhenPurged                                      *
 ****************************************************************************/

PROC WhenPurged()
    fsIniFile = fsIniFile       // PREVENT COMPILER NOTES ABOUT UN-REF'D VARS
    fsTseVer = fsTseVer         // PREVENT COMPILER NOTES ABOUT UN-REF'D VARS
    fsVer    = fsVer            // PREVENT COMPILER NOTES ABOUT UN-REF'D VARS
END WhenPurged

/****************************************************************************
 *  SECTION --> SYSPROC     Main                                            *
 ****************************************************************************/

PROC Main()

    INTEGER liCreatedIniFile = FALSE

    IF (koDEBUG)
        Set(Break, ON)
    ENDIF
    Hook(_PROMPT_STARTUP_, pnPromptStartup)
    UnHook(pnPromptStartup)

    CASE (GetGlobalInt("giMFFndCmd"))
        WHEN koOPT_INIT_MFFIND
            SetGlobalInt("giMFFndCmd", koOPT_INI_CHK)
            ExecMacro("MFFIND4")
            CASE (GetGlobalInt("giMFFndCmd"))
                WHEN koOPT_INI_CREATED
                    liCreatedIniFile = TRUE
                WHEN FALSE
                    PurgeMacro("MFFIND")
            ENDCASE
            SetGlobalInt("giMFFndCmd", koOPT_INI_READ)
            ExecMacro("MFFIND3")
            IF (liCreatedIniFile)
                SetGlobalInt("giMFFndCmd", koOPT_CONFIG_MFFIND)
                ExecMacro("MFFIND3")
            ENDIF
            IF (NOT GetGlobalInt("giMFFndHistSet"))
                SetGlobalInt("giMFFndCmd", koOPT_SET_HISTORIES)
                ExecMacro("MFFIND4")
            ENDIF
        WHEN koOPT_CONFIG_MFFIND
            ExecMacro("MFFIND3")
        WHEN koOPT_SET_HISTORIES
            ExecMacro("MFFIND4")
        WHEN koOPT_DEL_LINES_BLNKS, koOPT_DEL_LINES_DUPS,
             koOPT_DEL_LINES_EXCLX, koOPT_DEL_LINES_INCLX,
             koOPT_FIND_LINE_BLNKS, koOPT_FIND_LINE_DUPS,
             koOPT_FIND_LINE_EXCLX, koOPT_FIND_LINE_INCLX,
             koOPT_HIT_NEXT, koOPT_HIT_PREVIOUS, koOPT_PICK_AGAIN
            ExecMacro("MFFIND5")
        WHEN koOPT_FIND_CMNTS_BOTH, koOPT_FIND_CMNTS_C, koOPT_FIND_CMNTS_CPP,
             koOPT_FIND_CUR_WORD, koOPT_FIND_FCNS, koOPT_FIND_STR,
             KoOPT_REPLACE_STR
            ExecMacro("MFFIND6")
        WHEN koOPT_SHOW_HELP
            Set(X1, 2)
            Set(Y1, 2)
            QuickHelp(hdText)
        OTHERWISE
            Warn(fsMsgPrefix, "Invalid option - contact author")
    ENDCASE
END Main

/****************************************************************************
 *  SECTION --> SYSPROC     Hooked Procedures                               *
 ****************************************************************************/

PROC pnPromptStartup()
    Set(X1, 1)
    Set(Y1, 2)
END pnPromptStartup

/****************************************************************************
 *  SECTION --> PROCS       Support Procedures                              *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> PROCS       User Procedures                                 *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> MENU        The Menus                                       *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> KEYS        Key Bindings                                    *
 ****************************************************************************/

