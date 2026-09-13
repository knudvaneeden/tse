/****************************************************************************\

    KeyFind.S

    Search key definitions

    Searches the keyboard definition file (ui_keys.si) for
    specifed strings and displays the result in a browsing list.

    Version         v3.01/18.04.97
    Copyright       (c) 1993-96 by DiK

    History
    v3.01/18.04.97  adaption for public release
    v3.00/22.10.96  adaption to TSE32
                    þ fixed search expressions
    v2.11/09.02.96  enhanced list sorting
    v2.10/12.10.95  adaption to v2.5 of TSE
                    þ added history list
    v2.00/28.10.94  adaption to v2.0 of TSE
    v1.10/25.01.94  added new browsing mode
    v1.00/29.12.93  primary release

\****************************************************************************/

/****************************************************************************\
    global variables
\****************************************************************************/

string cmd_path[] = "ui\"
string cmd_file[] = "tse.ui"

/****************************************************************************\
    show serach result
\****************************************************************************/

proc SortList( integer lb, integer rb )
    MarkColumn(1,lb,NumLines(),rb)
    Sort(_IGNORE_CASE_)
end

keydef BrowseKeys
    <Alt K>     SortList( 1,28)
    <Alt C>     SortList(29,64)
end

proc BrowseHook()
    ListFooter("  {Alt-K} Sort by Key  {Alt-C} Sort by Command  {Enter} Search  ")
    Enable(BrowseKeys)
    Unhook(BrowseHook)
end

integer proc Browse()
    integer lines =
        iif( NumLines() < Query(ScreenRows), NumLines(), Query(ScreenRows))

    Hook(_LIST_STARTUP_,BrowseHook)
    return (
        lList("Matching Key Assignments",
            80,lines,_ENABLE_SEARCH_|_ENABLE_HSCROLL_)
    )
end

/****************************************************************************\
    compress information
\****************************************************************************/

proc Compress( string fnd )
    repeat
        UnmarkBlock()
        MarkLine()
        BegLine()
        if not lFind(fnd,"lix")
            if lFind(fnd,"ix")
                Up()
                KillBlock()
            else
                EndFile()
                KillBlock()
                break
            endif
        endif
    until not Down()
    UnmarkBlock()
    BegFile()
end

/****************************************************************************\
    format search string
\****************************************************************************/

proc MakeFindString (var string fnd)
    integer RTW = Set(RemoveTrailingWhite,OFF)

    if Lower(fnd) == "all"
        InsertText("^<")
    else
        InsertText("{"+fnd+"}")
        lReplace(",#","}|{","gnx")
        BegLine()
        if fnd[1] == "<"
            InsertText("^",_INSERT_)
        else
            InsertText("^<.*",_INSERT_)
        endif
    endif
    fnd = GetText(1,CurrLineLen())
    Set(RemoveTrailingWhite,RTW)
end

/****************************************************************************\
    main program
\****************************************************************************/

proc main()
    integer rc
    string fnd[80]
    string msg[80] = "Enter search string(s) separated by commas ('all' for entire file)"

    if not CreateTempBuffer()
        Warn("Cannot allocate work space")
        return()
    endif
    PushPosition()

    repeat

        Set(X1,1)
        Set(Y1,1)
        fnd = ""
        if not Ask(msg,fnd,GetFreeHistory("KeyFind:find"))
            break
        endif
        MakeFindString(fnd)
        EmptyBuffer()

        if InsertFile(LoadDir()+cmd_path+cmd_file)
            Compress(fnd)
            if NumLines()
                rc = Browse()
            else
                Warn("No matching key assignments found")
            endif
        else
            Warn("Cannot find UI file")
            break
        endif
        EmptyBuffer()

    until rc == 0

    AbandonFile()
    PopPosition()
    UpdateDisplay()
    PurgeMacro(CurrMacroFileName())
end

