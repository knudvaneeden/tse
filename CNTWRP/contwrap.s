// Begin {Continuous WordWrap}

/************************************************************************
  Macros to wrap text "continuously", or nearly so.  Space and almost all
  "movement" keys are overridden (Up, Down, Left, Right, PgUp, Pgdn, etc.)

  If NOT in WrapPara mode, no wrapping takes place.
 ************************************************************************/

// Include required source for paragraph movement and position push/pop
#include ["movepara.s"]
#include ["abspos.s"]

/************************************************************************
  The next procedure does the actual "WrapPara()" work.
  Most movement macros call this function and
  then perform the requested movement.
 ************************************************************************/

integer WrapContDebug = 0               // debugging flag

proc mWrapCont()
    if Query(WordWrap)  // if WordWrap is on
        if WrapContDebug
            Warn("At Start, Line:Col " + Str(CurrLine()) + ":" + Str(CurrCol()))
        endif
        PushAbsPos()    //      save our absolute position
        PushBlock()     //      save prior block status
        UnMarkBlock()   //      so we can start a new block
        BeginPara()     //      goto start of paragraph
        MarkLine()      //      mark beginning
        EndPara()       //      go to end of paragraph
        MarkLine()      //      mark end
        GoToBlockBegin()
        WrapPara()      //      wrap the paragraph
        UnMarkBlock()   //      unmark it
        PopBlock()      //      restore prior block status
        if WrapContDebug
            Warn("After PopBlock, Line:Col " + Str(CurrLine()) + ":" + Str(CurrCol()))
        endif
        PopAbsPos()     //      restore our absolute position
        if WrapContDebug
            Warn("At End, Line:Col " + Str(CurrLine()) + ":" + Str(CurrCol()))
        endif
    endif
end mWrapCont

/************************************************************************
  Single-line movement macros that implement "Continuous WrapPara()"
 ************************************************************************/

proc mSpace()
    InsertText(' ')     // Insert the space character in current insert mode
    mWrapCont()         // Invoke "Continuous" WrapPara
end mSpace

proc mUp()
    mWrapCont()         // Invoke "Continuous" WrapPara FIRST
    Up()                // THEN Perform the movement function
end mUp

proc mDown()
    mWrapCont()         // Invoke "Continuous" WrapPara FIRST
    Down()              // THEN Perform the movement function
end mDown

proc mLeft()
    mWrapCont()         // Invoke "Continuous" WrapPara FIRST
    Left()              // THEN Perform the movement function
end mLeft

proc mRight()
    mWrapCont()         // Invoke "Continuous" WrapPara FIRST
    Right()             // THEN Perform the movement function
end mRight

proc mScrollUp()
    mWrapCont()         // Invoke "Continuous" WrapPara FIRST
    ScrollUp()          // THEN Perform the movement function
end mScrollUp

proc mScrollDown()
    mWrapCont()         // Invoke "Continuous" WrapPara FIRST
    ScrollDown()        // THEN Perform the movement function
end mScrollDown

proc mRollUp()
    mWrapCont()         // Invoke "Continuous" WrapPara FIRST
    RollUp()            // THEN Perform the movement function
end mRollUp

proc mRollDown()
    mWrapCont()         // Invoke "Continuous" WrapPara FIRST
    RollDown()          // THEN Perform the movement function
end mRollDown

proc mRollLeft()
    mWrapCont()         // Invoke "Continuous" WrapPara FIRST
    RollLeft()          // THEN Perform the movement function
end mRollLeft

proc mRollRight()
    mWrapCont()         // Invoke "Continuous" WrapPara FIRST
    RollRight()         // THEN Perform the movement function
end mRollRight

proc mTabLeft()
    mWrapCont()         // Invoke "Continuous" WrapPara FIRST
    TabLeft()           // THEN Perform the movement function
end mTabLeft

proc mTabRight()
    mWrapCont()         // Invoke "Continuous" WrapPara FIRST
    TabRight()          // THEN Perform the movement function
end mTabRight

proc mWordLeft()
    PushPosition()      // Save word-relative position
    mWrapCont()         // Invoke "Continuous" WrapPara
    PopPosition()       // Restore word-relative position
    WordLeft()          // THEN Perform the movement function
end mWordLeft

proc mWordRight()
    integer colcurr = CurrCol()
    if (colcurr <> 1)
        PushPosition()  // Save word-relative position
    endif
    mWrapCont()         // Invoke "Continuous" WrapPara
    if (colcurr <> 1)
        PopPosition()   // Restore word-relative position
    endif
    WordRight()         // THEN Perform the movement function
end mWordRight

proc mBegLine()
    mWrapCont()         // Invoke "Continuous" WrapPara FIRST
    BegLine()           // THEN Perform the movement function
end mBegLine

proc mEndLine()
    mWrapCont()         // Invoke "Continuous" WrapPara FIRST
    EndLine()           // THEN Perform the movement function
end mEndLine

/************************************************************************
  Multi-line movement macros that implement "Continuous WrapPara()".
  These require special handling, since all paragraphs moved over
  need to be reformatted.
 ************************************************************************/

constant                                // Function constants for MultiWrap()
    zPageUp     = 0,
    zPageDown   = 1,
    zBegWindow  = 2,
    zEndWindow  = 3,
    zBegFile    = 4,
    zEndFile    = 5

proc MarkWrapUp(integer movement)       // Upwards movement
    PushAbsPos()                        // save our absolute position
    EndPara()                           // go to end of current paragraph
    Markline()                          // mark the paragraphs to be moved over
    PopAbsPos()                         // restore our absolute position
    case (movement)                     // move as instructed
        when zPageUp    PageUp()
        when zBegWindow BegWindow()
        when zBegFile   BegFile()
    endcase
    BeginPara()                         // include entire paragraphs
    MarkLine()                          // end the marked block
end MarkWrapUp

proc MarkWrapDn(integer movement)       // Downwards movement
    PushAbsPos()                        // save our absolute position
    BeginPara()                         // go to start of current paragraph
    Markline()                          // mark the paragraphs to be moved over
    PopAbsPos()                         // restore our absolute position
    case (movement)                     // move as instructed
        when zPageDown  PageDown()
        when zEndWindow EndWindow()
        when zEndFile   EndFile()
    endcase
    EndPara()                           // include entire paragraphs
    MarkLine()                          // end the marked block
end MarkWrapDn

proc MultiWrap(integer movement)        // Multi-line Wrap Function
    if Query(WordWrap)                  // if WordWrap is on
        PushAbsPos()                    //     save our absolute position
        PushBlock()                     //     save prior block status
        UnMarkBlock()                   //     so we can start a new block
        case (movement)                 //     move and mark all paragraphs
            when zPageUp    MarkWrapUp(zPageUp   )
            when zPageDown  MarkWrapDn(zPageDown )
            when zBegWindow MarkWrapUp(zBegWindow)
            when zEndWindow MarkWrapDn(zEndWindow)
            when zBegFile   MarkWrapUp(zBegFile  )
            when zEndFile   MarkWrapDn(zEndFile  )
        endcase
        // mWrapPara()                     //     wrap the paragraphs marked
        WrapPara()                     //     wrap the paragraphs marked // now native TSE command [kn, ri, th, 03-09-2026 00:18:27]
        UnMarkBlock()                   //     remove the mark on the block
        PopBlock()                      //     restore prior block status
        PopAbsPos()                     //     restore our absolute position
    endif                               // end if WordWrap is on
end MultiWrap

proc mPageUp()
    MultiWrap(zPageUp)                  // Invoke "Continuous" WrapPara FIRST
    PageUp()                            // THEN Perform the movement function
end mPageUp

proc mPageDown()
    MultiWrap(zPageDown)                // Invoke "Continuous" WrapPara FIRST
    PageDown()                          // THEN Perform the movement function
end mPageDown

proc mBegWindow()
    MultiWrap(zBegWindow)               // Invoke "Continuous" WrapPara FIRST
    BegWindow()                         // THEN Perform the movement function
end mBegWindow

proc mEndWindow()
    MultiWrap(zEndWindow)               // Invoke "Continuous" WrapPara FIRST
    EndWindow()                         // THEN Perform the movement function
end mEndWindow

proc mBegFile()
    MultiWrap(zBegFile)                 // Invoke "Continuous" WrapPara FIRST
    BegFile()                           // THEN Perform the movement function
end mBegFile

proc mEndFile()
    MultiWrap(zEndFile)                 // Invoke "Continuous" WrapPara FIRST
    EndFile()                           // THEN Perform the movement function
end mEndFile

/************************************************************************
  Cut, Copy and Paste macros that implement "Continuous WrapPara()".
 ************************************************************************/

integer proc mCopyBlock(integer overlay)
    integer rc
    rc = CopyBlock(overlay)     // FIRST Perform the function
    mWrapCont()                 // Invoke "Continuous" WrapPara
    return (rc)                 // Return the function's return code
end mCopyBlock

integer proc mCut(integer append)
    integer rc
    rc = Cut(append)            // FIRST Perform the function
    mWrapCont()                 // Invoke "Continuous" WrapPara
    return (rc)                 // Return the function's return code
end mCut

integer proc mPaste(integer overlay)
    integer rc
    rc = Paste(overlay)         // FIRST Perform the function
    mWrapCont()                 // Invoke "Continuous" WrapPara
    return (rc)                 // Return the function's return code
end mPaste

/************************************************************************
  Save macros that implement "Continuous WrapPara()".
 ************************************************************************/

integer proc mSaveAllAndExit()
    mWrapCont()                 // Invoke "Continuous" WrapPara FIRST
    return (SaveAllAndExit())   // THEN Perform the function
end mSaveAllAndExit

integer proc mSaveAllFiles()
    mWrapCont()                 // Invoke "Continuous" WrapPara FIRST
    return (SaveAllFiles())     // THEN Perform the function
end mSaveAllFiles

integer proc mSaveAndQuitFile()
    mWrapCont()                 // Invoke "Continuous" WrapPara FIRST
    return (SaveAndQuitFile())  // THEN Perform the function
end mSaveAndQuitFile

integer proc mSaveAs(string filename, integer option)
    mWrapCont()                 // Invoke "Continuous" WrapPara FIRST
    return (SaveAs(filename, option))   // THEN Perform the function
end mSaveAs

integer proc mSaveBlock(string filename, integer option)
    mWrapCont()                 // Invoke "Continuous" WrapPara FIRST
    return (SaveBlock(filename, option))    // THEN Perform the function
end mSaveBlock

integer proc mSaveFile()
    mWrapCont()                 // Invoke "Continuous" WrapPara FIRST
    return (SaveFile())         // THEN Perform the function
end mSaveFile

#include ["contwrap.key"]       // Continuous-Wrap key definitions

/************************************************************************
  Key macro to toggle "Continuous WrapPara()" on and off (set to <Alt w>).
 ************************************************************************/

proc ToggleContWrap()           // Function to toggle Continuous WordWrap
    if ContWrap <> 1
        ContWrap = 1
        Set(WordWrap, On)
        OldAutoIndent = Set(AutoIndent, 0)
        Enable(ContWrapKeys)
    else
        ContWrap = 0
        Set(WordWrap, Off)
        Set(Autoindent, OldAutoIndent)
        OldAutoIndent = 0
        Disable(ContWrapKeys)
    endif
end ToggleContWrap

// End {Continuous WordWrap}

