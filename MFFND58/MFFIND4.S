/****************************************************************************
 *  FILENAME :  mffind4.s                                                   *
 *  VERSION  :  5.8 (for TSE Pro 2.50a)                                     *
 *  AUTHOR   :  Ray Asbury (rasbury@msmailpc01.saic.com)                    *
 *  COPYRIGHT:  1995 E. Ray Asbury, Jr.  All Rights Reserved Worldwide.     *
 *  DATE     :  Mon 11-20-1995 09:38:34                                     *
 *  FILES    :  mffind.inc      mffind2.inc     mffind.ini                  *
 *              mffind.s        mffind2.s       mffind3.s                   *
 *              mffind4.s       mffind5.s       mffind6.s                   *
 *                                                                          *
 *  PURPOSE  :  INI verification and history support functions              *
 *                                                                          *
 *  REVISIONS:  WHO DATE        DESCRIPTION                                 *
 *              --- --------    ------------------------------------------  *
 *              [SEE REVISIONS LIST IN MFFIND.S]                            *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> GLOBAL      Constants                                       *
 ****************************************************************************/

// SEE MFFIND.INC FOR ADDITIONAL CONSTANTS

CONSTANT        koNBR_LINES_IN_INI_HEADER   = 19

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

FORWARD         PROC pnCheckIniFile()
FORWARD         PROC pnRemoveHistories()
FORWARD         PROC pnShowHistoryUsage(STRING lpsTitle)
FORWARD INTEGER PROC piSetHistories()

/****************************************************************************
 *  SECTION --> GLOBAL      Data Definitions                                *
 ****************************************************************************/

DATADEF ddIniFile
";*************"
"***************************************************************"
";*  FILENAME :"
"  mffind.ini                                                  *"
";*  VERSION  :"
"  5.8 (for TSE Pro 2.50a)                                     *"
";*  AUTHOR   :"
"  Ray Asbury (rasbury@msmailpc01.saic.com)                    *"
";*  COPYRIGHT:  1995 E. Ray Asbury, Jr.  All Rights Reserved"
" Worldwide.     *"
";*  DATE     :"
"  Fri 01-13-1995 11:46:27                                     *"
";*  FILES    :  mffind.inc"
"      mffind2.inc     mffind.ini                  *"
";*              mffind.s"
"        mffind2.s       mffind3.s                   *"
";*              mffind4.s"
"       mffind5.s       mffind6.s                   *"
";*                    x"
"                                                      *"
";*              mffind*.inc"
"   NOT DISTRIBUTED                               *"
";*              mffind[2-6].s"
" DISTRIBUTED IN COMPILED (.MAC) FORMAT ONLY    *"
";*           x"
"                                                               *"
";*  PURPOSE  :"
"  Ini file for Multi-File Find/Replace                        *"
";*           x"
"                                                               *"
";*  REVISIONS:"
"  WHO DATE        DESCRIPTION                                 *"
";*              ---"
" --------    ------------------------------------------  *"
";*              [SEE"
" REVISIONS LIST IN MFFIND.S]                            *"
";***************"
"*************************************************************"
""
"[Custom File Definitions]"
""
";   THE FOLLOWING ARE THE EXTENSIONS (AND THEIR SEARCH STRINGS) THAT"
";   MFFIND AUTOMATICALLY RECOGNIZES"
";"
";   '.c', '.cpp', '.h', '.pc'"
";"
";       '^{[a-zA-Z_].*}{) *\x7b *{{/\x2a.*\x2a/}|{//.*}}*}$'"
";"
";   '.s', '.ui', '.inc'"
";"
";       '^{{PUBLIC #}?{{INTEGER}|{STRING} #}?PROC}|{MENUBAR}|{MENU}|' +"
";       '{[DH][AE][LT][AP]DEF}|{KEYDEF} +[a-zA-Z_]\c'"
";"
";   '.prg','.spr','.mpr','.qpr','.fmt','.frg','.lbg','.ch'"
";"
";       '^{procedure}|{function} +[a-zA-Z_]'"
";"
";   IF YOU SPECIFY ANY OF THESE EXTENSIONS AS A CUSTOM FILE DEFINITION, IT"
";   WILL TAKE PRECEDENCE FOR THE DEFAULT DEFINITIONS"
""
"FileExtension1="
"SearchString1="
"FileExtension2="
"SearchString2="
"FileExtension3="
"SearchString3="
"FileExtension4="
"SearchString4="
"FileExtension5="
"SearchString5="
"FileExtension6="
"SearchString6="
"FileExtension7="
"SearchString7="
"FileExtension8="
"SearchString8="
"FileExtension9="
"SearchString9="
"FileExtension10="
"SearchString10="
""
"[Group Hits]"
"DefaultOnAsk=YES"
"DistinguishGroupHits=TRUE"
""
"[Fill Characters]"
"SelectLineCharacter=þ"
"BufferLineCharacter=²"
""
"[Function Search]"
"DefaultOnAsk=NO"
"PauseOnErrors=FALSE"
""
"[History Usage]"
"UseOwnHistories=FALSE"
""
"[Screen Updating]"
"DefaultOnAsk=YES"
"Minimal=TRUE"
""
"[Progress]"
"DefaultOnAsk=NO"
"Messages=FALSE"
"Threshold=20000"
""
"[Replace]"
"DefaultOnAsk=NO"
"Verify=ASK"
""
"[Word Search]"
"CaseSensitive=ASK"
"DefaultOnAsk=NO"
""
END ddIniFile

/****************************************************************************
 *  SECTION --> GLOBAL      Help Definitions                                *
 ****************************************************************************/

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
    fsTseVer = fsTseVer         // PREVENT COMPILER NOTES ABOUT UN-REF'D VARS
    fsVer    = fsVer            // PREVENT COMPILER NOTES ABOUT UN-REF'D VARS
    pnRemoveHistories()
END WhenPurged

/****************************************************************************
 *  SECTION --> SYSPROC     Main                                            *
 ****************************************************************************/

PROC Main()
    IF (koDEBUG)
        Set(Break, ON)
    ENDIF
    CASE (GetGlobalInt("giMFFndCmd"))
        WHEN koOPT_INI_CHK
            pnCheckIniFile()
        WHEN koOPT_SET_HISTORIES
            IF (NOT piSetHistories())
                Warn(fsMsgPrefix, "MFFIND: Unable to create histories - ",
                        "using standard histories")
                SetGlobalInt("giMFFndHistType", koHIST_STD)
                piSetHistories()
            ENDIF
        OTHERWISE
            Warn(fsMsgPrefix, "MFFIND4 should not be executed directly - ",
                    "use MFFIND")
    ENDCASE
END Main

/****************************************************************************
 *  SECTION --> SYSPROC     Hooked Procedures                               *
 ****************************************************************************/

/****************************************************************************
 *  SECTION --> PROCS       Support Procedures                              *
 ****************************************************************************/

PROC pnCheckIniFile()

    STRING  lsIniFile[127]  = ""

    INTEGER liIId,
            liCid           = GetBufferId(),
            liMonth,
            liDay,
            liYear,
            liDayOfWeek,
            liHr,
            liMin,
            liSec,
            liHun

    lsIniFile = SearchPath(fsIniFile, Query(TSEPath), "mac")
    IF (NOT Length(lsIniFile))
        Warn(fsMsgPrefix, "Unable to locate 'MFFIND.INI'")
        lsIniFile = SearchPath("mffind.mac", Query(TSEPath), "mac")
        lsIniFile = SubStr(lsIniFile, 1, (Length(lsIniFile) - 3)) +
                    "ini"
        Warn(fsMsgPrefix, "Creating '", lsIniFile, "' using defaults")
        liIId = EditFile(lsIniFile)
        InsertData(ddIniFile)
        LReplace(Chr(39), Chr(34), "gn")    // REPLACE SGL W/DBL QUOTES
        BegFile()
        WHILE (CurrLine() <= koNBR_LINES_IN_INI_HEADER)
            EndLine()
            IF (CurrLine() IN 10, 13, 15)
                Left()
                DelChar()
            ENDIF
            JoinLine()
            Down()
        ENDWHILE
        BegFile()
        MarkLine()
        Down(7)
        MarkLine()
        IF (LFind("DATE @:", "XLG"))
            WordRight()
            IF (CurrChar() < 0) // AT OR BEYOND EOL
                TabRight()
            ENDIF
            GetDate(liMonth, liDay, liYear, liDayOfWeek)
            GetTime(liHr, liMin, liSec, liHun)
            InsertText(Format(SubStr("SunMonTueWedThuFriSat",
                                        ((liDayOfWeek - 1) * 3 + 1), 3),
                                " ", liMonth:2:"0", Chr(Query(DateSeparator)),
                                liDay:2:"0", Chr(Query(DateSeparator)),
                                liYear:4:"0", " ", liHr:2:"0", ":",
                                liMin:2:"0", ":", liSec:2:"0"), _OVERWRITE_)
        ENDIF
        IF (SaveFile())
            SetGlobalInt("giMFFndCmd", koOPT_INI_CREATED)
        ELSE
            Warn(fsMsgPrefix, "Unable to save ", lsIniFile)
            lsIniFile = ""
            SetGlobalInt("giMFFndCmd", FALSE)
        ENDIF
        GotoBufferId(liCid)
        AbandonFile(liIId)
    ENDIF
    SetGlobalStr("gsMFFndIniFile", lsIniFile)
END pnCheckIniFile

PROC pnRemoveHistories()

    INTEGER liHist

    liHist = GetGlobalInt("giMFFndHistFnd")
    IF (liHist)
        IF (liHist <> _FIND_HISTORY_)
            DelHistory(liHist)
        ENDIF
        SetGlobalInt("giMFFndHistFnd", 0)
    ENDIF
    liHist = GetGlobalInt("giMFFndHistFndOpts")
    IF (liHist)
        IF (liHist <> _FINDOPTIONS_HISTORY_)
            DelHistory(liHist)
        ENDIF
        SetGlobalInt("giMFFndHistFndOpts", 0)
    ENDIF
    liHist = GetGlobalInt("giMFFndHistRep")
    IF (liHist)
        IF (liHist <> _REPLACE_HISTORY_)
            DelHistory(liHist)
        ENDIF
        SetGlobalInt("giMFFndHistRep", 0)
    ENDIF
    liHist = GetGlobalInt("giMFFndHistRepOpts")
    IF (liHist)
        IF (liHist <> _REPLACEOPTIONS_HISTORY_)
            DelHistory(liHist)
        ENDIF
        SetGlobalInt("giMFFndHistRepOpts", 0)
    ENDIF
    SetGlobalInt("giMFFndHistSet", FALSE)
    pnShowHistoryUsage("Histories: Removed")
END pnRemoveHistories

INTEGER PROC piSetHistories()

    INTEGER liHist

    pnRemoveHistories()
    IF (GetGlobalInt("giMFFndHistType") == koHIST_OWN)
        liHist = GetFreeHistory("MFFind:giMFFndHistFnd")
        IF (liHist)
            SetGlobalInt("giMFFndHistFnd", liHist)
        ELSE
            Return(FALSE)
        ENDIF
        liHist = GetFreeHistory("MFFind:giMFFndHistFndOpts")
        IF (liHist)
            SetGlobalInt("giMFFndHistFndOpts", liHist)
            AddHistoryStr(Query(FindOptions), liHist)
        ELSE
            pnRemoveHistories()
            Return(FALSE)
        ENDIF
        liHist = GetFreeHistory("MFFind:giMFFndHistRep")
        IF (liHist)
            SetGlobalInt("giMFFndHistRep", liHist)
        ELSE
            pnRemoveHistories()
            Return(FALSE)
        ENDIF
        liHist = GetFreeHistory("MFFind:giMFFndHistRepOpts")
        IF (liHist)
            SetGlobalInt("giMFFndHistRepOpts", liHist)
        ELSE
            pnRemoveHistories()
            Return(FALSE)
        ENDIF
    ELSE
        SetGlobalInt("giMFFndHistFnd",
                        _FIND_HISTORY_)
        SetGlobalInt("giMFFndHistFndOpts",
                        _FINDOPTIONS_HISTORY_)
        SetGlobalInt("giMFFndHistRep",
                        _REPLACE_HISTORY_)
        SetGlobalInt("giMFFndHistRepOpts",
                        _REPLACEOPTIONS_HISTORY_)
    ENDIF
    SetGlobalInt("giMFFndHistSet", TRUE)
    pnShowHistoryUsage("Histories: " +
                        IIF((GetGlobalInt("giMFFndHistType") == koHIST_OWN),
                                "OWN", "STD"))
    Return(TRUE)
END piSetHistories

PROC pnShowHistoryUsage(STRING lpsTitle)

    INTEGER liCid,
            liTid

    IF (koDEBUG_HISTORIES)
        liCid = GetBufferID()
        liTid = CreateTempBuffer()
        GotoBufferID(liTid)
        AddLine(Format("giMFFndHistFnd":-30,
                        GetGlobalInt("giMFFndHistFnd"):3))
        AddLine(Format("_FIND_HISTORY_":-30,
                        _FIND_HISTORY_:3))
        AddLine(Format("Ä":33:"Ä"))
        AddLine(Format("giMFFndHistFndOpts":-30,
                        GetGlobalInt("giMFFndHistFndOpts"):3))
        AddLine(Format("_FINDOPTIONS_HISTORY_":-30,
                        _FINDOPTIONS_HISTORY_:3))
        AddLine(Format("Ä":33:"Ä"))
        AddLine(Format("giMFFndHistRep":-30,
                        GetGlobalInt("giMFFndHistRep"):3))
        AddLine(Format("_REPLACE_HISTORY_":-30,
                        _REPLACE_HISTORY_:3))
        AddLine(Format("Ä":33:"Ä"))
        AddLine(Format("giMFFndHistRepOpts":-30,
                        GetGlobalInt("giMFFndHistRepOpts"):3))
        AddLine(Format("_REPLACEOPTIONS_HISTORY_":-30,
                        _REPLACEOPTIONS_HISTORY_:3))
        List(lpsTitle, IIF((Length(lpsTitle) > 33), Length(lpsTitle), 33))
        GotoBufferID(liCid)
        AbandonFile(liTid)
    ENDIF
END pnShowHistoryUsage

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