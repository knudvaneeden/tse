/**************************************************************************
     AutoWrap ... a macro that, when Hooked to _IDLE_, provide
     automatic paragraph wrapping.

     Version .91 ... a slightly refined version of the original.

     Slightly changed for WP4PROG -- MH
 **************************************************************************/

forward proc         autowrap()
forward proc         mBegPara()
forward integer proc excluded_paragraph()
forward proc         mMarkPara()
forward integer proc mTimerProc(integer StartTimer)

/*******************************************************************
 Add extensions below to disable autowrap for additional file types.
 If extension is <3 chars, pad with spaces.

 Changes WP4:
   - moved out to a global for testing by alt-keydefs below
   - added some obvious file extensions to eliminate code wrapping
*******************************************************************/
string
     no_autowrap[64] = '.c   .h   .bas  .s   .inc .bat .def .asm'


/*  This proc taken out for WP4 interface, since file is compiled into E.EXE
proc whenloaded()
    Hook(_IDLE_, autowrap)
    SetGlobalInt('AutoWrapOnOff', 1)
end
*/

proc autowrap()
     integer
          row = CurrRow(),
          startlength = CurrLineLen(),
          sl_attr=Set(Attr, Query(StatusLineAttr)),
          changed
          /*
             Note change to this test -- reversed it to allow all files
             except probable code files to pass test, which is reversed
             below (I hope!)
          */

     mTimerProc(0)                                // Start timer.
     if GetGlobalInt('AutoWrapOnOff') == 0        // Check for no-go conditions.
        OR language
        OR cmode
        OR not Query(WordWrap)
        OR not Query(Insert)
        OR not PosFirstNonWhite()
        OR IsCursorInBlock()
    /*  OR not Pos( SplitPath(currfilename(), _EXT_),
                    autowrap_allowed )              original code */
        OR Pos( SplitPath(currfilename(), _EXT_),
                    no_autowrap )                   // chgd for WP4
        OR excluded_paragraph() <> 0                // see below; chgd WP4
        OR KeyPressed()
        OR CurrPos() > PosLastNonwhite()            // at end of line

          if Query(WordWrap) and Query(ShowStatusLine)
               VGoToXY(21, iif( Query(StatusLineAtTop), 1, Query(ScreenRows)))
               if GetGlobalInt('AutoWrapOnOff') == 1
                    PutLine('p',1)      // ON but inactive
               else
                    PutLine('W',1)      // OFF but WordWrap is on
               endif
        endif
          Set(Attr, sl_attr)

          return()
     endif

     If Query(ShowStatusLine)
          VGoToXY(21,iif( Query(StatusLineAtTop), 1, Query(ScreenRows) ))
          PutLine('P',1)
     endif
     Set(Attr, sl_attr) // reset original attribute

     if GetGlobalInt('AutoWrapNOW') == FALSE
          repeat                                  // if key pressed
               if keypressed()                    // don't wrap.
                    return()                      // avoid flicker
               endif
          until mTimerProc(1) >= 100              // keep checking until
     else                                         // this many millisecs
          SetGlobalInt('AutoWrapNOW', FALSE )
     endif

     PushPosition()
     Up()                               // Go to line above to start wrap
     if not PosFirstNonWhite()          // unless it is blank
          Down()
     endif

     changed = FileChanged()              // store changed status
     WrapPara()                         // wrap para
     FileChanged(changed)              // restore changed status

     PopPosition()                      // restore position in file
     ScrolltoRow(row)                   // restore position in screen

     if CurrLineLen() <> startlength    // repaint changed part of screen
          PushPosition()
          Set(Cursor,Off)
          Up()
          repeat
               UpDateDisplay(_CLINE_REFRESH_ | _REFRESH_THIS_ONLY_ )
          until CurrRow() == Query(WindowRows) or NOT Down()

          PopPosition()
          Set(Cursor,On)
          UpDateDisplay(_CLINE_REFRESH_ | _REFRESH_THIS_ONLY_ )
     endif

     PushPosition()
     BegLine()
     PopPosition()

end

integer proc excluded_paragraph()
     /*
          Change this proc to search for conditions
          that, when found, indicate a paragraph NOT
          to be wrapped.
     */
     integer result
        result = 0

     PushBlock()
     PushPosition()
     mMarkPara()
     /*
        Need to exclude some obvious things that would indicate we are in
        a code segment or another place where wrapping is not desireable.
        Keep checking through list until find a reason NOT to wrap.
         Additions - MH WP4Prog
     */
     result = lFind('<R>', 'gl')        // if true, exclude -- orig test case
     if result == 0
        result = lFind('/*', 'gl')      // exclude commented; probably code
     endif
     if result == 0
        result = lFind('*/', 'gl')      // ditto above
     endif
     if result == 0
        result = lFind('//', 'gl')      // ditto above
     endif
     if result == 0
        result = lFind('    ', 'gl')    // exclude w/tabs - indented para?
     endif
     if result == 0
        result = lFind('|', 'gl')       // obviously code ... maybe ...
     endif
     if result == 0
        result = lFind('=', 'gl')       // obviously code ... maybe ...
     endif
     if result == 0
        result = lFind('->', 'gl')       // obviously code ... maybe ...
     endif
     if result == 0
        result = lFind('()', 'gl')       // obviously code ... maybe ...
     endif
     PopBlock()
     PopPosition()
     Return(result)
end

// temporary keydefs for autowrap testing
//<alt E> message(excluded_paragraph())
//<alt F> message(Pos( SplitPath(currfilename(), _EXT_), no_autowrap) )


integer hours, minutes, seconds, hundreds, millisecs, elapsed
integer proc mTimerProc(integer StartTimer)     // By IAN CAMPBELL, modified  DRM
    if StartTimer == 0                           // 0 = start  1 = stop
        GetTime(hours, minutes, seconds, hundreds)
        millisecs = (((minutes * 60) + seconds) * 1000) + (hundreds * 10)
        return(0)
     else
        GetTime(hours, minutes, seconds, hundreds)
        elapsed = (((minutes * 60) + seconds) * 1000) + (hundreds * 10)
        elapsed = elapsed - millisecs
        return( elapsed)
    endif
    return(elapsed)
end mTimerProc

proc mBegPara()
     /*
          Goes to beginning of current or next paragraph:
               When on a non-blank line, goes to:
               (a) First line following the first blank line above
                   the current line, or
               (b) First line of file if no blank line above current line.
               When on a blank line, goes to:
               (a) Next non-blank line, or
               (b) Last line of file if no non-blank line found.
     */
     if PosLastNonWhite() == 0
          repeat until ( Down() AND PosLastNonWhite() <> 0 )
                    OR ( CurrLine() == NumLines() )
     else
          repeat until ( Up() AND PosLastNonWhite() == 0 )
                    OR ( CurrLine() == 1 )
          if currline() <> 1
               Down()
          endif
     endif
     GotoPos(PosFirstNonWhite())
end

proc mEndPara()
     Down()
     if PosLastNonWhite() == 0                   // get to first line
          Up()
          mBegPara()
     endif
     repeat until ( Down() AND PosLastNonWhite() == 0 )
               OR ( CurrLine() == NumLines() )
     if CurrLine() <> NumLines()
          Up()
     endif
     EndLine()
end

proc mMarkPara()
     UnMarkBlock()  PushPosition()
     mBegPara()     MarkLine()
     mEndPara()     MarkLine()
     PopPosition()
end

/*********************************************************
     Key Definition
 *********************************************************/

<Ctrl Enter> CReturn() CReturn()
