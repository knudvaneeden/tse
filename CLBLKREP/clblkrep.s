/****************************************************************************
 *   FILENAME:  C:\TSE\MAC\CLBLKREP.S                                       *
 *   AUTHOR  :  "Buddy" E. Ray Asbury, Jr.                                  *
 *   DATE    :  Mon 04-05-1993 10:27:06                                     *
 *   PURPOSE :  While putting together a data file for a macro, I needed    *
 *              to extract just the capital letters of a column block,      *
 *              putting them in front of the block and leaving the block    *
 *              un-touched.  I was suprised when text from outside the      *
 *              had also been replaced.                                     *
 *                                                                          *
 *              After thinking about what happened, I realized that this    *
 *              was caused by the fact that as text was removed, text which *
 *              wasn't originally in the block slowly moved into it, and    *
 *              was subsequently replaced.                                  *
 *                                                                          *
 *              These macros eliminate this from happening by               *
 *              effectively isolating the block by utilizing a temporary    *
 *              buffer.  As a side effect, it will also prevent a           *
 *              replacement string which is longer than the search          *
 *              string from pushing text outside of the marked block.       *
 *              Of course, when the cursor is not actually inside a         *
 *              column block, they function identically to the built- in    *
 *              commands.  Just bind mFind(), mReplace(), and               *
 *              mRepeatFind() to whatever keys you currently have           *
 *              Find(), Replace(), and RepeatFind() bound to.               *
 *                                                                          *
 ****************************************************************************/

FORWARD PROC mReplace(INTEGER isARepeat)

PROC mFind()
    IF (Find())
        SetGlobalInt("gColReplaceWasLast", FALSE)
    ENDIF
END mFind

PROC mRepeatFind()
    IF (GetGlobalInt("gColReplaceWasLast"))
        mReplace(TRUE)
    ELSE
        RepeatFind()
    ENDIF
END mRepeatFind

PROC mReplace(INTEGER isARepeat)
    STRING s[69] = "",
           r[69] = "",
           t[11] = "",
           o[11] = ""
    INTEGER cid = GetBufferID(),
            tid,
            loc
            //markingState

    IF (IsCursorInBlock() <> _COLUMN_)
        IF Replace()
            SetGlobalInt("gColReplaceWasLast", FALSE)
        ENDIF
    ELSEIF (isARepeat)
        //markingState = Set(Marking, OFF)
        Set(Marking, OFF)
        PushPosition()
        GotoBlockBegin()
        tid = CreateTempBuffer()
        CopyBlock()
        RepeatFind()
        GotoBufferID(cid)
        CopyBlock(_OVERWRITE_)
        PopPosition()
        //markingState = Set(Marking, markingState)
        AbandonFile(tid)
    ELSEIF (Ask("Search for:", s, _FindHistory_) AND
            Length(s))
        IF (NOT Ask("Replace with:", r, _ReplaceHistory_))
            Return()
        ENDIF
        IF (NOT Ask("Options [BGIWX] (Back Global Ignore-case Words reg-eXp):",
            t, _ReplaceOptionsHistory_))
            Return()
        ENDIF
        Upper(t)
        loc = Pos("L", t)
        IF (loc)
            o = SubStr(t, 1, (loc - 1)) +
                SubStr(t, (loc + 1), (Length(t) - loc))
        ELSE
            o = t
        ENDIF
        //markingState = Set(Marking, OFF)
        Set(Marking, OFF)
        PushPosition()
        GotoBlockBegin()
        tid = CreateTempBuffer()
        CopyBlock()
        Replace(s, r, o)
        GotoBufferID(cid)
        CopyBlock(_OVERWRITE_)
        PopPosition()
        //markingState = Set(Marking, markingState)
        AbandonFile(tid)
        SetGlobalInt("gColReplaceWasLast", TRUE)
    ENDIF
END mReplace