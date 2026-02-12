/****************************************************************************
 *  FILENAME :  sline.s                                                     *
 *  VERSION  :  1.0                                                         *
 *  AUTHOR   :  Ray Asbury (rasbury@msmailpc01.saic.com)                    *
 *  DATE     :  Tue 08-02-1994 21:23:20                                     *
 *  PURPOSE  :  Modifies the statusline using 1.53á's hooks to display:     *
 *                                                                          *
 *                  ù the current buffer's file's attributes                *
 *                  ù the current character's ASCII code in hex and decimal *
 *                      (almost exactly like that in TSE Jr./TSR 3.0)         *
 *                  ù uses Windows-like parsing to shorten the filename if  *
 *                      it is too long to display                           *
 *                                                                          *
 *  REVISIONS:  WHO DATE        DESCRIPTION                                 *
 *              --- --------    ------------------------------------------  *
 ****************************************************************************/

STRING  gCFName[250] = ""               // BUFFER FOR THE CURRENT FILENAME

INTEGER PROC mShortenFileName()

    STRING  gBuf[250] = ""              // TEMP WORKING BUFFER

    INTEGER maxLength = Query(ScreenCols) - 47,
            start

    gCFName = CurrFileName()
    IF (Length(gCFName) <= maxLength)   // IF IT FITS AS IS, LEAVE IT ALONE
        Return(FALSE)
    ENDIF
    gBuf = gCFName
    gCFName = Format(SubStr(gCFName, 1, 3), "...\")
    gBuf = SubStr(gBuf, 4, (Length(gBuf) - 3))
    WHILE (Length(gBuf) > (maxLength - 7))
        start = Pos("\", gBuf)
        gBuf = SubStr(gBuf, (start + 1), (Length(gBuf) - start))
    ENDWHILE
    gCFName = Format(gCFName,
                        gBuf:-(maxLength - 7):Chr(Query(StatusLineFillChar)))
    Return(TRUE)
END mShortenFileName

PROC mShowSpecialStats()

    STRING  cStr[15] = Chr(Query(StatusLineFillChar))

    INTEGER saveAttr,
            gLastCurrChar = 0,
            curChar,
            a,
            sLineLocation = 1

    IF (Query(StatusLineAtTop) == FALSE)
        sLineLocation = Query(ScreenRows)
    ENDIF

    /* GET CURRENT FILE'S ATTRIBUTES ****************************************/

    a = FileExists(CurrFileName())
    IF (a & _READONLY_)
        cStr = cStr + "R"
    ELSE
        cStr = cStr + Chr(Query(StatusLineFillChar))
    ENDIF
    IF (a & _ARCHIVE_)
        cStr = cStr + "A"
    ELSE
        cStr = cStr + Chr(Query(StatusLineFillChar))
    ENDIF
    IF (a & _SYSTEM_)
        cStr = cStr + "S"
    ELSE
        cStr = cStr + Chr(Query(StatusLineFillChar))
    ENDIF
    IF (a & _HIDDEN_)
        cStr = cStr + "H"
    ELSE
        cStr = cStr + Chr(Query(StatusLineFillChar))
    ENDIF

    /* GET CURR CHAR ASCII CODES ********************************************/

    curChar = CurrChar()
    IF (curChar < 0)
        cStr = Format(cStr, Chr(Query(StatusLineFillChar)),
                        '<EOL>':-8:Chr(Query(StatusLineFillChar)))
    ELSE
        gLastCurrChar = curChar
        cStr = Format(cStr, Chr(Query(StatusLineFillChar)),
                        Str(gLastCurrChar, 16):2, 'h,', gLastCurrChar:3, 'd')
    ENDIF

    /* GET STATUS LINE COLOR ATTRIBUTE **************************************/

    saveAttr = Set(Attr, Query(StatusLineAttr))

    /* DISPLAY THE STUFF ****************************************************/

    IF (mShortenFileName())
        VGotoXY(35, sLineLocation)
        PutStr(gCFName)
    ENDIF
    VGotoXY(Query(ScreenCols) - 12, sLineLocation)
    PutStr(cStr)
    Set(Attr, saveAttr)
END mShowSpecialStats

PROC main()
    Hook(_IDLE_, mShowSpecialStats)
    Hook(_AFTER_UPDATE_STATUSLINE_, mShowSpecialStats)
END main

