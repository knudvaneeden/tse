/*****************************************************************************
  4 May 93: G. Grafton Cole                                SCROLL FUNCTIONS

  I burned these macros into SE.
 ****************************************************************************/

/****************************************************************************
  4 May 93: G. Grafton Cole                                     SCROLL LOCK
   If scroll lock is ON: If more than one window is open.
      The cursor line goes to inverse video.
      Uses current window and next window and scrolls (rolls) both windows
         up or down.
****************************************************************************/

integer   scroll_lock    = 0,                               // global
          DEFcursor_att  = Color(Bright White on Blue)

proc ScrollLock()
    integer y   = WhereY()

    scroll_lock = scroll_lock ^ 1
    Message("Scroll Lock turned ", iif(scroll_lock, "on", "off"))

    if scroll_lock                             // change cursor line when ON
       VGoToXY(1,y)                            // position cursor
       PutAttr(Color(Blue on White),80)        // highlight line
       Set(CursorAttr, Color(Blue on White))   // set cursor line attribute
    else
       VGoToXY(1,y)                            // restore default cursor line
       PutAttr(DEFcursor_att,80)               //   attribute
       Set(CursorAttr, DEFcursor_att)
    endif
end
/******************************************************************************
  4 May 93: G. Grafton Cole                              TOGGLE SCROLL / ROLL
  Toggles between scroll and roll and implements scroll lock
 *****************************************************************************/

integer  scroll_mode = 1                                     // global

proc ScrollMode()                        // toggle
  scroll_mode = scroll_mode ^ 1
  Message(iif(scroll_mode, "  SCROLLING", "  ROLLING")+" is in effect")
end

proc mRollUp()
    if scroll_mode
       ScrollUp()
    else
       RollUp()
    endif
    if scroll_lock and NextWindow()         // if lock do both windows
       RollUp()
       PrevWindow()
    endif
end

proc mRollDown()
    if scroll_mode
       ScrollDown()
    else
       RollDown()
    endif
    if scroll_lock and NextWindow()
       RollDown()
       PrevWindow()
    endif
end

/****************************************************************************
  4 May 93: G. Grafton Cole                                    SCROLL ALIGN

 If more than one window:  uses current and next window
  Uses the current cursor line as the search string for next window
  If found:
    Positions the 2ed window to the next occurance of the search string
    Position the search and found string in the center of the windows
    Marks the lines in inverse video
  If not found:
    Returns Message with "string" NOT FOUND
  If only one window:  no action taken.

  This is a fairly primitive implementation, but if you are checking two
    versions of the same file, it does the job.
 ***************************************************************************/
proc ScrollAlign()
  string  s[30] = GetLine()
  integer     i = 0

    if NextWindow()                             // if only one window
        PrevWindow()                            // get out
    else
        Return()
    endif

    ScrollToRow(Query(WindowRows)/2)            // center query line
    if NextWindow()
        if Find(s," ")                          // search forward
          ScrollToRow(Query(WindowRows)/2)
          VGoToXY(2,WhereY())
          PutAttr(Color(Red on White),78)       // highlight line
          i = 1
        elseif Find(s,"g")                      // not found, search global
          ScrollToRow(Query(WindowRows)/2)
          VGoToXY(2,WhereY())
          PutAttr(Color(Red on White),78)       // highlight line
          i = 1
        else                                    // not found, giveup
          Message("<" + s + ">" + " NOT FOUND")
        endif
    endif
    PrevWindow()
    if i
      VGoToXY(2,(Query(WindowRows)/2)+2)          // ?? + 2
      PutAttr(Color(Red on White),78)             // highlight line
    endif
end
/*------------------ END OF SCROLL FUNCTIONS  -------------------------------*/
