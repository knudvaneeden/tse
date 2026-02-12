/*  Sort utility. Run an external sort if more than 1000 lines to
    sort. Emulates the internal sort pretty well.

    Written for Mike Albert's FSORT, available on the SemWare BBS.

    By Terry Harris, extentions by Mel Hulse
    Version 1.3, July 14, 1993

    Version 1.3

    þ   Problem with external case sensitive sorts fixed.

    þ   "Sort" from main menu bypasses the Sort Menu and executes
        with parameters set from utility menu.

    Features (changes marked with "|"):

    þ   Prompted choice of internal or external sort with default based
        on number of lines less/greater than 1000.

    þ   Sort Menu provided to set parameters and select internal or
        external sort.

|   þ   Choice of Main or Sort Menus to set TSE parameters and
|       execute.  Sort direct from Main Menu if desired.

    þ   Only one added keystroke if default sort is wanted.

    þ   Uses block type to determine sort field.  If a column block,
        uses start and width. Otherwise uses first 80 columns of each
        line.

    þ   Supports decimal column sort with "+", "-" and ".". Numbers need
        not be aligned. If selected, defaults to external sort.

    þ   Deletion of lines with duplicate sort keys.  If selected,
        defaults to external sort.

    þ   Sort parameters isolated to a single macro (BuildKey()).
        However, menu must be changed to accomodate capability
        differences.

    Setup:

    1)  FSort must be in a directory in your PATH statement.

    2)  Read the FSort manual.

    3)  #include this file in TSE.S just prior to the #include
        "TSE.KEYS" statement.  mSort uses TSE.S macros.

|   4)  In the list of global variables in TSE.S (around line 90) insert:
|       sort_flags,

|   5)  After the list of global variables insert:
|
|       FORWARD PROC mSort(integer M)

|   6)  Modify the TSE.S UtilMenu "&Sort" entry to call "mSort(Off)"
|       instead of "Sort(sort_flags)".

|   7)  Bind mSort(On) to a key in TSE.KEY if you want the Sort
|       Menu for access to additional features.

    8)  Recompile/burn-in TSE.S.

    Usage:

    1)  Mark the block to be sorted.

    2)  Optionally, set standard TSE parameters and execute sort
|       using the Main Utility pull-down menu. OR,

    3)  Touch key bound to mSort()

    4)  Select options, if desired.

|   5)  From Sort Menu select "S" when ready or "Q" to quit.
*/

integer btype, dups, ext, decimal, good, extra // "sort_flags" already in TSE.S

STRING PROC BuildKey(Integer sbbc, Integer sbec)

    Return(Format
          ("/",
           iIf(sort_flags == 0 OR sort_flags == 2, "+", "-"),  // Ascend or
                                                               // descend
           iIf(decimal == ON, "N", ""),                        // Decimal
           sbbc, ":", (sbec - sbbc + 1),                       // Begining and
                                                               // end
           iIf(sort_flags == 2 OR sort_flags == 3, " /C", ""), // Case
           iIf(dups == ON, " /U", ""))                         // Delete dups
          )
END

INTEGER PROC SortRoutine(Integer bbl, Integer bel)

    integer sbbc = 1,           // default key start
            sbec = 80,          // default key end
            sr   = CurrRow(),
            sl   = CurrLine(),
            sc   = CurrCol(),
            bbc  = Query(BlockBegCol),
            bec  = Query(BlockEndCol)

    Message("Preparing...")
    If(btype == _COLUMN_)   // If it's a column
        sbbc = bbc          // get beginning
        sbec = bec          // and end columns
    EndIf
    GotoBlockBegin()        // Make it a line block so I can write it to
    MarkLine()              // ...an input file
    GotoLine(bel)
    MarkLine()
    // save the block to a temp file and check for error
    If SaveBlock(Query(SwapPath) + "$tsees$i.$$$", _OVERWRITE_) == 0
        Warn("Could not write block")
        Return(FALSE)
    Else                    // no error, do fsort with parms & error check
        Message("Sorting...")
        If Dos(Format("fsort ",
                      Query(SwapPath), "$tsees$i.$$$ ",
                      Query(SwapPath), "$tsees$o.$$$ ",
                      BuildKey(sbbc, sbec)), _DONTCLEAR_) == 0
            Warn("Could not run external sort program")
        Else
            DelBlock()      // delete saved block from file
            GotoPos(0)      // beginning of line
            If InsertFile(Query(SwapPath) + "$tsees$o.$$$") == 0
                Undelete()  // error? get deleted data back
                Warn("Could not read sorted block")
            Else
                UnMarkBlock()
            EndIf
        EndIf
    EndIf
    // Delete temp files
    Message("Deleting temp files...")
    Dos("del " + Query(SwapPath) + "$tsees$?.$$$ > nul", _DONTCLEAR_)
    GotoLine(bbl)           // Go back
    GotoColumn(bbc)         // ...to where we started
    If btype == _COLUMN_    // ...and based on previous block type,
        MarkColumn()        // ...remark block begining
    Else
        If btype == _LINE_
            MarkLine()
        Else
            MarkStream()
        EndIf
    EndIf
    GotoLine(bel)           // and end
    GotoColumn(bec)
    If btype == _COLUMN_
        MarkColumn()
    Else
        If btype == _LINE_
            MarkLine()
        Else
            MarkStream()
        EndIf
    EndIf
    GotoLine(sl)            // Back to
    GotoColumn(sc)          // ...original position
    ScrollToRow(sr)         // ...and put it where it was in window
    GotoXoffset(0)          // ..on left margin
    return (TRUE)               // It worked
END

PROC ToggleDupFlag()
   dups = iIf(dups == ON, OFF, ON)
   ext  = ON
END

PROC ToggleDecFlag()
    decimal = iIf(decimal == ON, OFF, ON)
    ext     = ON

END

PROC ToggleExtSort()
    ext = iIf(ext == ON, OFF, ON)
    If decimal == ON OR dups == ON
        ext = on
    EndIf
END

PROC GoodOn()
    good =ON
END

PROC WorkDone()                         // End game
    Integer i = 3
    Message("Done...")
    Repeat
        Sound(5000) Delay(1) NoSound()
        Sound(4000) Delay(1)  NoSound()
        i = i - 1
    Until i <= 0
    Delay(15)
    UpdateDisplay()
END

MENU SortMenu()
    Title = "Sort Options"
    X       =  24
    Y       =   6
    History
    NoEscape

    "",, Skip
    "     Alternate Sort Utility",, Skip
    "Authors: Terry Harris && Mel Hulse",, Skip
    "    Version 1.2, May 30, 1993 ",, Skip
    "",, Skip
    "",                         , Divide
    "&Sort"                     , GoodOn(),,
        "Go ahead and execute the sort."
    "&Quit"                   ,,, "Cancel the sort."
    "",                         , Divide
    "Sort &Order"                 [ShowSortFlag() : 10],
        ToggleSortFlag(1)       , ,//DontClose,
        "Same as main menu."
    "&Case-Sensitive Sort"        [OnOffStr((sort_flags & 2) == 0):3],
        ToggleSortFlag(2)       , ,//DontClose,
        "Same as main menu."
    "&External Sort"              [OnOffStr(ext) : 3],
        ToggleExtSort()         , ,//DontClose,
    "Force an external sort."
    "",                         , Divide
    "ÍÍÍÍµForces External SourceÆÍÍÍÍÍ"  ,, Skip
    "&Kill Dup Lines"             [OnOffStr(dups) : 3],
        ToggleDupFlag()         , ,//DontClose,
        "Deletes lines with duplicate sort keys."
    "&Decimal"                    [OnOffStr(decimal) : 3],
        ToggleDecFlag()         , ,//DontClose,
"Right justified decimal columns. Accepts '+', '-', '.' & scientIfic notation."
END

PROC mSort(Integer M)
Integer bbl     = Query(BlockBegLine),
        bel     = Query(BlockEndLine)

        good    = Off
        btype   = isBlockInCurrFile()
        dups    = OFF
        decimal = OFF
        extra   = FALSE

    If btype == 0
        Message("Block must be marked...")
    Else
        ext = iIf((bel - bbl < 1000), OFF, ON) // <1k lines, default = internal
        PushPosition()                  // Supports whether blank line at end
            EndFile()
            BegLine()
            If CurrChar() < 0
                extra = TRUE
            EndIf
        PopPosition()
        While good  == OFF              // 'til we get good input
            If M == ON
                Repeat
                    SortMenu()          // what's the user want
            Until (MenuOption() == 7 OR MenuOption() == 8)
            EndIf

            If MenuOption() == 8            // quit
                Message("Terminated by user...")
                good = ON
                Return()
            Else
                If ext == OFF               // Internal sort wanted?
                    If decimal == ON OR dups == ON
                      Warn("Decimal and kill duplicate parms not supported.")
                        decimal = OFF       // reset default
                        dups    = OFF       //       "
                        good = ON           // fix error
                    Else
                        Sort(sort_flags)    // internal sort
                        WorkDone()
                        Return()
                    EndIf
                Else
                    good = ON
                EndIf
            EndIf
        EndWhile                        // Go ahead with external sort
        If ext == ON AND SortRoutine(bbl, bel) // External sort
            WorkDone()                  // We're done
            PushPosition()              // Supports whether blank line at end
                EndFile()
                BegLine()
                If NOT extra AND CurrChar() < 0
                    DelLine()
                EndIf
            PopPosition()
        ElseIf ext == ON
            Warn("Error in running external sort...")
        EndIf
    EndIf
END