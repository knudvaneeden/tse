/* *********************************************************************
    LocateNextTo - will locate paragraphs that contain a FIRST target
    (word or phrase), followed by a SECOND target (word or phrase),
    within any single paragraph, even if split across lines, with only
    space separating them.  The found paragraphs will be copied to a
    file named "Found.txt" in the current directory.
********************************************************************* */

proc LocateNextTo()
    integer newid, LMarg, RMarg
    string FIRST[40]="", SECOND[40]=""  // adjust to suit your needs

    if Ask("First target to find?", FIRST, GetFreeHistory("LocateNear:FIRST"))
        and Length(FIRST)
    else Warn("You must enter a target to locate!") Return()
    endif
    if Ask("Second target to find?", SECOND, GetFreeHistory("LocateNear:SECOND"))
        and Length(SECOND)
    else Warn("You must enter a second target target to locate!") Return()
    endif

    if NOT isCursorInBlock()           // bail out if no block
        Warn("Only works in a marked block")
        Return()
    else
        Copy()                         // copy the marked text
    endif

    newid = CreateBuffer("foo")        // create a temp buffer
        if NOT newid
        Warn("Failed to create new buffer")
        Return()                       // bail out if buffer not created
    endif

    Paste()                            // paste text into the temp buffer
    BegFile()                          // make sure at beginning

    LMarg = set("LeftMargin",0)        // store old, set new margins
    RMarg = set("RightMargin",16000)   // set to maximum for your version

    while CurrLine() < NumLines()      // operate on entire file
        WrapPara()                     // re-wrap paras to one long line
        Message("I'm working!")        // gives assurance on large files
    endwhile
    BegFile()                          // back to top of buffer

    while lFind(FIRST + " " + SECOND, "xi")  // search for both targets
        MarkLine() Copy()              // copy lines containing targets
        EditFile("Found.txt")          // to end of a file
        EndFile() AddLine()
        Paste() EndFile()              // back to temp buffer for next search
        PrevFile() Down() BegLine()
    endwhile
    AbandonFile(newid)                 // don't need temp buff any more
    Message("")                        // removes the "working" message

    EditFile("Found.txt") BegFile()    // re-wrap long lines to paras again
    set("LeftMargin",LMarg)            // using margins as set in orig file
    set("RightMargin",RMarg)
    while CurrLine() < NumLines()
        WrapPara()
    endwhile
    BegFile()                          // ready to use found text as desired
end

proc main()
    LocateNextTo()
end

