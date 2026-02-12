/*  Sort utility. Run an external sort if more than 1000 lines to
    sort. Emulates the internal sort pretty well.

    Written for Mike Albert's FSORT, available on the SemWare BBS.

    By Terry Harris, extentions by Mel Hulse
    Version 1.3, July 14, 1993

    Multiple sort key enhancements by Joseph Baechtel
    Version 1.4, September 13, 1993

    Version 1.3

    þ   Problem with external case sensitive sorts fixed.

    þ   "Sort" from main menu bypasses the Sort Menu and executes
        with parameters set from utility menu.

    Version 1.4

    þ   Enhancements made to macro to allow the user to specify multiple
        sort "keys".  When user selects the multiple sort keys option, they
        may specify up to ten (10) keys for the external sort program to
        act upon.  (See Features Below).

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

|   þ   Multiple sort "keys" option to allow the user to specify multiple
|       sort "keys".  When user selects the multiple sort keys option, they
|       may specify up to ten (10) keys for the external sort program to
|       act upon.  If selected, defaults to external sort.

|   þ   When the multiple sort keys option is selected, each sort key may be
|       sorted differently (some ascending / some desending) then the other
|       keys.

|   þ   When the multiple sort keys option is selected, the user may specify
|       the starting and ending column positions of the sort keys by one of
|       two methods.
|
|       1).  Method One:  User is prompted for the starting and ending column
|            positions for each key.  They are then presenting with a menu to
|            select the "key type".  When all sort keys have been defined,
|            the user starts the sorting process by pressing the "Shift F3"
|            key.
|
|       2).  Method Two:  When the user is prompted for the first starting
|            column, they may select the "Point And Shoot" method of sort
|            key selection by press the "Enter" key instead of entering a
|            number.  The Point And Shoot method allows the user to position
|            the cursor to the starting column for the key and by then
|            pressing the "Enter" key, it is selected.  The cursor is then
|            positioned to the ending column for the key and the "Enter"
|            key is used once again to select it.  The user is then presented
|            with a menu to select the "key type".  When all sort keys have
|            been defined, the user starts the sorting process by pressing
|            the "Shift F3" key.
|
|       With both methods, once a sort key has been defined, the columns that
|       make up the key (within the current line) are "highlighted" to show
|       the user a "graphic representation" of the sort key positions.
|
    Setup:

|   1)  FSort must be in a directory in your PATH statement.
|       ***** Correction made to load the FSort program from the directory
|             specified by the "MacPath" variable (can be set in the
|             configuration through the "Option" section of the pull-down
|             menu).  If the FSort program is not found in the specified
|             directory, the root directory is searched and then the path
|             statement is used.

    2)  Read the FSort manual.

    3)  #include this file in TSE.S just prior to the #include
        "TSE.KEYS" statement.  mSort uses TSE.S macros.

|   4)  In the list of global variables in TSE.S (around line 90) insert:
|       sort_flags,
|       ***** This variable already exists, ignor this step.

|   5)  After the list of global variables insert:
|
|       FORWARD PROC mSort(integer M)

|   6)  Modify the TSE.S UtilMenu "&Sort" entry to call "mSort(Off)"
|       instead of "Sort(sort_flags)".

|   7)  Bind mSort(On) to a key in TSE.KEY if you want the Sort
|       Menu for access to additional features.
|       ***** It is suggested that you change the standard binding for the
|             "Shift F3" key to call this macro.

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

integer skey1start = 1,    // default multi key start
        skey1end = 80,     // default multi key end
        skey1type = 0,     // default multi key type
        skey2start = 0,    // default multi key start
        skey2end = 0,      // default multi key end
        skey2type = 0,     // default multi key type
        skey3start = 0,    // default multi key start
        skey3end = 0,      // default multi key end
        skey3type = 0,     // default multi key type
        skey4start = 0,    // default multi key start
        skey4end = 0,      // default multi key end
        skey4type = 0,     // default multi key type
        skey5start = 0,    // default multi key start
        skey5end = 0,      // default multi key end
        skey5type = 0,     // default multi key type
        skey6start = 0,    // default multi key start
        skey6end = 0,      // default multi key end
        skey6type = 0,     // default multi key type
        skey7start = 0,    // default multi key start
        skey7end = 0,      // default multi key end
        skey7type = 0,     // default multi key type
        skey8start = 0,    // default multi key start
        skey8end = 0,      // default multi key end
        skey8type = 0,     // default multi key type
        skey9start = 0,    // default multi key start
        skey9end = 0,      // default multi key end
        skey9type = 0,     // default multi key type
        skey0start = 0,    // default multi key start
        skey0end = 0,      // default multi key end
        skey0type = 0,     // default multi key type
        keys, ok, start_col, end_col, attr_save, esc_pressed,
        point_start, point_end, shiftF3_pressed, rewrite_col,
        rewrite_end, key, scan_code

string  sAskStart[4],      // default multi key start
        sAskEnd[4],        // default multi key end
        mark_char[1]       // mark multiple key char

FORWARD INTEGER PROC ReWriteKeys()

INTEGER PROC GetUserKey()
    GetUserKeyLoop:
    key = GetKey()              // Get User Key Slection
    scan_code = key shr 8       // Convert it to Scan Code
    case scan_code
         when 1                 // Esc pressed ?
               esc_pressed = 1  // Show Escape was pressed
               Return(True)     // Return to calling procedure
         when 28                // Enter pressed ?
               UpdateDisplay(_CLine_Refresh_) // Re-Draw current line
               ReWriteKeys()               // ReWrite Selected Keys
               GotoXY(((Currpos() + 1) - CurrXOffset()), CurrLine() + 2) // Move cursor to match current pos
               Return(True)     // Return to calling procedure
         when 224               // Enter pressed ?
               UpdateDisplay(_CLine_Refresh_) // Re-Draw current line
               ReWriteKeys()               // ReWrite Selected Keys
               GotoXY(((Currpos() + 1) - CurrXOffset()), CurrLine() + 2) // Move cursor to match current pos
               Return(True)     // Return to calling procedure
         when 71                // Home pressed ?
               GotoColumn(1)    // Home Cursor
         when 79                // End pressed ?
               EndLine()        // Goto EndLine
         when 75                // Left Arrow pressed ?
               Left()           // Move cursor left
         when 77                // Right Arrow pressed ?
               if CurrPos() >= (Query(ScreenCols) - 5)
                      ScrollRight()
               endif
               GotoColumn((CurrPos() + 1)) // Move cursor right
               UpdateDisplay(_CLine_Refresh_) // Re-Draw current line
               ReWriteKeys()               // ReWrite Selected Keys
               GotoXY(((Currpos() + 1) - CurrXOffset()), CurrLine() + 2) // Move cursor to match current pos
               Goto GetUserKeyLoop         // Try it again sam !
         when 86                // Shift F3 pressed ?
               shiftF3_pressed = 1 // Show Shift F3 was pressed
               Return(True)     // Return to calling procedure
         otherwise
               Alarm()          // Tell user bad key
    endcase
    GotoXY(Currpos() + 1, CurrLine() + 2) // Move cursor to match current pos
    UpdateDisplay(_CLine_Refresh_) // Re-Draw current line
    ReWriteKeys()               // ReWrite Selected Keys
    Goto GetUserKeyLoop         // Try it again sam !
    Return(True)                // Return to calling procedure
END

//
// Keydef -- Point And Shoot Multiple Sort Keys Start Position Key Definations
//
keydef PointAndShoot1Keys
       <HelpLine>   " {Point And Shoot} Method--->{Enter}                                 {Esc} To Cancel"
       <Alt HelpLine>    " {Point And Shoot} Method--->{Enter}                                 {Esc} To Cancel"
       <Ctrl HelpLine>    " {Point And Shoot} Method--->{Enter}                                 {Esc} To Cancel"
       <Shift HelpLine>    " {Point And Shoot} Method--->{Enter}                                 {Esc} To Cancel"
end

//
// Keydef -- Point And Shoot Multiple Sort Keys Start Position Key Definations
//
keydef PointAndShoot2Keys
       <HelpLine>   "                                                                 {Esc} To Cancel"
       <Alt HelpLine>    "                                                                 {Esc} To Cancel"
       <Ctrl HelpLine>    "                                                                 {Esc} To Cancel"
       <Shift HelpLine>    "                                                                 {Esc} To Cancel"
end


//
// Keydef -- Multiple Sort Keys Start Position Key Definations
//
keydef KeyStartKeys
       <HelpLine>   " Move Cursor To {Start Of Key}--->{Enter}     {Shift F3}--->Sort     {Esc} To Cancel"
       <Alt HelpLine> " Move Cursor To {Start Of Key}--->{Enter}     {Shift F3}--->Sort     {Esc} To Cancel"
       <Ctrl HelpLine> " Move Cursor To {Start Of Key}--->{Enter}     {Shift F3}--->Sort     {Esc} To Cancel"
       <Shift HelpLine> " Move Cursor To {Start Of Key}--->{Enter}     {Shift F3}--->Sort     {Esc} To Cancel"
end

//
// Keydef -- Multiple Sort Keys End Position Key Definations
//
keydef KeyEndKeys
       <HelpLine>   " Move Cursor To {End Of Key}--->{Enter}                              {Esc} To Cancel"
       <Alt HelpLine> " Move Cursor To {End Of Key}--->{Enter}                              {Esc} To Cancel"
       <Ctrl HelpLine> " Move Cursor To {End Of Key}--->{Enter}                              {Esc} To Cancel"
       <Shift HelpLine> " Move Cursor To {End Of Key}--->{Enter}                              {Esc} To Cancel"
end


INTEGER PROC PointAndShoot()
    esc_pressed = 0
    shiftF3_pressed = 0
    Enable(KeyStartKeys)
    UpdateDisplay(_HelpLine_Refresh_)
    Alarm()
    GetUserKey()           // Get user movement
    Disable(KeyStartKeys)
    UpdateDisplay(_HelpLine_Refresh_)
    if shiftF3_pressed == 1
        Return(True)
    endif
    if esc_pressed == 1
        Return(False)
    endif
    point_start = CurrPos()
    Enable(KeyEndKeys)
    UpdateDisplay(_HelpLine_Refresh_)
    Alarm()
    GetUserKey()           // Get user movement
    Disable(KeyEndKeys)
    UpdateDisplay(_HelpLine_Refresh_)
    if esc_pressed == 1
        Return(False)
    endif
    point_end = CurrPos()
    Return(True)
END

INTEGER PROC MarkKey(Integer rewrite_col)
    attr_save = Query(Attr)             // Save current attribute setting
    Set(Attr, Query(HiLiteAttr))        // Change to HiLite Mode
    GotoXY(rewrite_col, (CurrRow() + 2)) // Position Video Cursor
    mark_char = GetText(((rewrite_col - 1) + CurrXOffset()), 1) // Get character to re-write
    PutChar(mark_char)                  // Re-write with new attribute
    Set(Attr, attr_save)                // Yes--Change back to Normal Mode
    Return(True)                        // Return to calling procedure
END

INTEGER PROC ReWriteKeys()
    Set(Cursor, OFF)                // Turn off cursor for re-write
    rewrite_col = Query(WindowX1)   // Get cuurent window left edge
    rewrite_end = Query(WindowCols) // Get cuurent window right edge
    ReWriteLoop:
    if rewrite_col <= rewrite_end   // Are we done yet ?
          if skey1type <> 0
                if (rewrite_col - 1) >= (skey1start - CurrXOffset()) AND
                (rewrite_col - 1) <= (skey1end - CurrXOffset())
                      MarkKey(rewrite_col)
                endif
          endif
          if skey2type <> 0
                if (rewrite_col - 1) >= (skey2start - CurrXOffset()) AND
                (rewrite_col - 1) <= (skey2end - CurrXOffset())
                      MarkKey(rewrite_col)
                endif
          endif
          if skey3type <> 0
                if (rewrite_col - 1) >= (skey3start - CurrXOffset()) AND
                (rewrite_col - 1) <= (skey3end - CurrXOffset())
                      MarkKey(rewrite_col)
                endif
          endif
          if skey4type <> 0
                if (rewrite_col - 1) >= (skey4start - CurrXOffset()) AND
                (rewrite_col - 1) <= (skey4end - CurrXOffset())
                      MarkKey(rewrite_col)
                endif
          endif
          if skey5type <> 0
                if (rewrite_col - 1) >= (skey5start - CurrXOffset()) AND
                (rewrite_col - 1) <= (skey5end - CurrXOffset())
                      MarkKey(rewrite_col)
                endif
          endif
          if skey6type <> 0
                if (rewrite_col - 1) >= (skey6start - CurrXOffset()) AND
                (rewrite_col - 1) <= (skey6end - CurrXOffset())
                      MarkKey(rewrite_col)
                endif
          endif
          if skey7type <> 0
                if (rewrite_col - 1) >= (skey7start - CurrXOffset()) AND
                (rewrite_col - 1) <= (skey7end - CurrXOffset())
                      MarkKey(rewrite_col)
                endif
          endif
          if skey8type <> 0
                if (rewrite_col - 1) >= (skey8start - CurrXOffset()) AND
                (rewrite_col - 1) <= (skey8end - CurrXOffset())
                      MarkKey(rewrite_col)
                endif
          endif
          if skey9type <> 0
                if (rewrite_col - 1) >= (skey9start - CurrXOffset()) AND
                (rewrite_col - 1) <= (skey9end - CurrXOffset())
                      MarkKey(rewrite_col)
                endif
          endif
          if skey0type <> 0
                if (rewrite_col - 1) >= (skey0start - CurrXOffset()) AND
                (rewrite_col - 1) <= (skey0end - CurrXOffset())
                      MarkKey(rewrite_col)
                endif
          endif
          rewrite_col = (rewrite_col + 1)
          Goto ReWriteLoop
    else
          Set(Cursor, ON)     // Turn on cursor after re-write
          GotoXY(((Currpos() + 1) - CurrXOffset()), CurrLine() + 2) // Move cursor to match current pos
          Return(True)        // Yes--Return to calling procedure
    endif
    Return(0)
END

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

STRING PROC BuildMultiKey()

    Return(Format
          ("/",
           iIf(skey1type == 1, "+", ""),  // Ascend character
           iIf(skey1type == 2, "-", ""),  // Descend character
           iIf(skey1type == 3, "+N", ""), // Ascend decimal
           iIf(skey1type == 4, "-N", ""), // Descend decimal
           iIf(skey1type <> 0, Str(skey1start), ""),                   // Begining
           iIf(skey1type <> 0, ":", ""),                          // and
           iIf(skey1type <> 0, Str((skey1end - skey1start + 1)), ""),  // end
           iIf(skey2type == 1, " /+", ""),  // Ascend character
           iIf(skey2type == 2, " /-", ""),  // Descend character
           iIf(skey2type == 3, " /+N", ""), // Ascend decimal
           iIf(skey2type == 4, " /-N", ""), // Descend decimal
           iIf(skey2type <> 0, Str(skey2start), ""),                   // Begining
           iIf(skey2type <> 0, ":", ""),                          // and
           iIf(skey2type <> 0, Str((skey2end - skey2start + 1)), ""),  // end
           iIf(skey3type == 1, " /+", ""),  // Ascend character
           iIf(skey3type == 2, " /-", ""),  // Descend character
           iIf(skey3type == 3, " /+N", ""), // Ascend decimal
           iIf(skey3type == 4, " /-N", ""), // Descend decimal
           iIf(skey3type <> 0, Str(skey3start), ""),                   // Begining
           iIf(skey3type <> 0, ":", ""),                          // and
           iIf(skey3type <> 0, Str((skey3end - skey3start + 1)), ""),  // end
           iIf(skey4type == 1, " /+", ""),  // Ascend character
           iIf(skey4type == 2, " /-", ""),  // Descend character
           iIf(skey4type == 3, " /+N", ""), // Ascend decimal
           iIf(skey4type == 4, " /-N", ""), // Descend decimal
           iIf(skey4type <> 0, Str(skey4start), ""),                   // Begining
           iIf(skey4type <> 0, ":", ""),                          // and
           iIf(skey4type <> 0, Str((skey4end - skey4start + 1)), ""),  // end
           iIf(skey5type == 1, " /+", ""),  // Ascend character
           iIf(skey5type == 2, " /-", ""),  // Descend character
           iIf(skey5type == 3, " /+N", ""), // Ascend decimal
           iIf(skey5type == 4, " /-N", ""), // Descend decimal
           iIf(skey5type <> 0, Str(skey5start), ""),                   // Begining
           iIf(skey5type <> 0, ":", ""),                          // and
           iIf(skey5type <> 0, Str((skey5end - skey5start + 1)), ""),  // end
           iIf(skey6type == 1, " /+", ""),  // Ascend character
           iIf(skey6type == 2, " /-", ""),  // Descend character
           iIf(skey6type == 3, " /+N", ""), // Ascend decimal
           iIf(skey6type == 4, " /-N", ""), // Descend decimal
           iIf(skey6type <> 0, Str(skey6start), ""),                   // Begining
           iIf(skey6type <> 0, ":", ""),                          // and
           iIf(skey6type <> 0, Str((skey6end - skey6start + 1)), ""),  // end
           iIf(skey7type == 1, " /+", ""),  // Ascend character
           iIf(skey7type == 2, " /-", ""),  // Descend character
           iIf(skey7type == 3, " /+N", ""), // Ascend decimal
           iIf(skey7type == 4, " /-N", ""), // Descend decimal
           iIf(skey7type <> 0, Str(skey7start), ""),                   // Begining
           iIf(skey7type <> 0, ":", ""),                          // and
           iIf(skey7type <> 0, Str((skey7end - skey7start + 1)), ""),  // end
           iIf(skey8type == 1, " /+", ""),  // Ascend character
           iIf(skey8type == 2, " /-", ""),  // Descend character
           iIf(skey8type == 3, " /+N", ""), // Ascend decimal
           iIf(skey8type == 4, " /-N", ""), // Descend decimal
           iIf(skey8type <> 0, Str(skey8start), ""),                   // Begining
           iIf(skey8type <> 0, ":", ""),                          // and
           iIf(skey8type <> 0, Str((skey8end - skey8start + 1)), ""),  // end
           iIf(skey9type == 1, " /+", ""),  // Ascend character
           iIf(skey9type == 2, " /-", ""),  // Descend character
           iIf(skey9type == 3, " /+N", ""), // Ascend decimal
           iIf(skey9type == 4, " /-N", ""), // Descend decimal
           iIf(skey9type <> 0, Str(skey9start), ""),                   // Begining
           iIf(skey9type <> 0, ":", ""),                          // and
           iIf(skey9type <> 0, Str((skey9end - skey9start + 1)), ""),  // end
           iIf(skey0type == 1, " /+", ""),  // Ascend character
           iIf(skey0type == 2, " /-", ""),  // Descend character
           iIf(skey0type == 3, " /+N", ""), // Ascend decimal
           iIf(skey0type == 4, " /-N", ""), // Descend decimal
           iIf(skey0type <> 0, Str(skey0start), ""),                   // Begining
           iIf(skey0type <> 0, ":", ""),                          // and
           iIf(skey0type <> 0, Str((skey0end - skey0start + 1)), ""),  // end
           iIf(sort_flags == 2 OR sort_flags == 3, " /C", ""), // Case
           iIf(dups == ON, " /U", ""))                         // Delete dups
          )
END

MENU KeyTypeMenu()
    Title = "Sort Key Type"
    X       =  24
    Y       =   10
    History
    NoEscape

    "",, Skip
    "Choose Sort Key Type:",, Skip
    "",, Skip
    "",                         , Divide
    "&1) Ascending Character"   ,,, ""
    "&2) Descending Character"  ,,, ""
    "&3) Ascending Decimal"     ,,, ""
    "&4) Descending Decimal"    ,,, ""
END

INTEGER PROC GetMultiKeys()
    skey1type = 0
    skey2type = 0
    skey3type = 0
    skey4type = 0
    skey5type = 0
    skey6type = 0
    skey7type = 0
    skey8type = 0
    skey9type = 0
    skey0type = 0
    GetKey1Start:
    sAskStart = ""
    sAskEnd = ""
    Enable(PointAndShoot1Keys)
    UpdateDisplay(_HelpLine_Refresh_)
    ok = Ask("Enter starting column for search key 1:", sAskStart) // Get start
    if ok
      if Length(sAskStart) > 0       // if ok and something was entered
        if Val(sAskStart) > 0 AND Val(sAskStart) < 1009
          skey1start = Val(sAskStart)
          Disable(PointAndShoot1Keys)
          UpdateDisplay(_HelpLine_Refresh_)
          Enable(PointAndShoot2Keys)
          UpdateDisplay(_HelpLine_Refresh_)
          ok = Ask("Enter ending column for search key 1:", sAskEnd) // Get end
          if ok
            if Length(sAskEnd) > 0   // if ok and something was entered
              if sAskEnd <= sAskStart
                skey1end = Val(sAskStart)
              else
                if Val(sAskEnd) < 1009
                  skey1end = Val(sAskEnd)
                else
                  skey1end = 1009
                endif
              endif
            else
              skey1end = Val(sAskStart)
            endif
            KeyTypeMenu() // Get sort key type
            skey1type = (MenuOption() - 4)
          else
            Return(False)
          endif
        else
          Alarm()
          Goto GetKey1Start
        endif
      else
        Disable(PointAndShoot1Keys)
        UpdateDisplay(_HelpLine_Refresh_)
        PointAndShoot()      // User wishes to use "Point And Shoot" method
        if shiftF3_pressed   // Did user start sort ?
          Return(False)      // Yes--Tell Calling procedure
        endif
        if esc_pressed       // Did user cancel ?
          Return(False)      // Yes--Tell Calling procedure
        else
          KeyTypeMenu() // Get sort key type
          skey1type = (MenuOption() - 4)
          if point_start <= point_end
            skey1start = point_start
            skey1end = point_end
          else
            skey1start = point_end
            skey1end = point_start
          endif
          start_col = skey1start
          end_col = skey1end
          ReWriteKeys()
        endif
        PointAndShoot()      // User wishes to use "Point And Shoot" method
        if shiftF3_pressed   // Did user start sort ?
          Return(True)       // Yes--Tell Calling procedure
        endif
        if esc_pressed       // Did user cancel ?
          Return(False)      // Yes--Tell Calling procedure
        else
          KeyTypeMenu() // Get sort key type
          skey2type = (MenuOption() - 4)
          if point_start <= point_end
            skey2start = point_start
            skey2end = point_end
          else
            skey2start = point_end
            skey2end = point_start
          endif
          start_col = skey2start
          end_col = skey2end
          ReWriteKeys()
        endif
        PointAndShoot()      // User wishes to use "Point And Shoot" method
        if shiftF3_pressed   // Did user start sort ?
          Return(True)       // Yes--Tell Calling procedure
        endif
        if esc_pressed       // Did user cancel ?
          Return(False)      // Yes--Tell Calling procedure
        else
          KeyTypeMenu() // Get sort key type
          skey3type = (MenuOption() - 4)
          if point_start <= point_end
            skey3start = point_start
            skey3end = point_end
          else
            skey3start = point_end
            skey3end = point_start
          endif
          start_col = skey3start
          end_col = skey3end
          ReWriteKeys()
        endif
        PointAndShoot()      // User wishes to use "Point And Shoot" method
        if shiftF3_pressed   // Did user start sort ?
          Return(True)       // Yes--Tell Calling procedure
        endif
        if esc_pressed       // Did user cancel ?
          Return(False)      // Yes--Tell Calling procedure
        else
          KeyTypeMenu() // Get sort key type
          skey4type = (MenuOption() - 4)
          if point_start <= point_end
            skey4start = point_start
            skey4end = point_end
          else
            skey4start = point_end
            skey4end = point_start
          endif
          start_col = skey4start
          end_col = skey4end
          ReWriteKeys()
        endif
        PointAndShoot()      // User wishes to use "Point And Shoot" method
        if shiftF3_pressed   // Did user start sort ?
          Return(True)       // Yes--Tell Calling procedure
        endif
        if esc_pressed       // Did user cancel ?
          Return(False)      // Yes--Tell Calling procedure
        else
          KeyTypeMenu() // Get sort key type
          skey5type = (MenuOption() - 4)
          if point_start <= point_end
            skey5start = point_start
            skey5end = point_end
          else
            skey5start = point_end
            skey5end = point_start
          endif
          start_col = skey5start
          end_col = skey5end
          ReWriteKeys()
        endif
        PointAndShoot()      // User wishes to use "Point And Shoot" method
        if shiftF3_pressed   // Did user start sort ?
          Return(True)       // Yes--Tell Calling procedure
        endif
        if esc_pressed       // Did user cancel ?
          Return(False)      // Yes--Tell Calling procedure
        else
          KeyTypeMenu() // Get sort key type
          skey6type = (MenuOption() - 4)
          if point_start <= point_end
            skey6start = point_start
            skey6end = point_end
          else
            skey6start = point_end
            skey6end = point_start
          endif
          start_col = skey6start
          end_col = skey6end
          ReWriteKeys()
        endif
        PointAndShoot()      // User wishes to use "Point And Shoot" method
        if shiftF3_pressed   // Did user start sort ?
          Return(True)       // Yes--Tell Calling procedure
        endif
        if esc_pressed       // Did user cancel ?
          Return(False)      // Yes--Tell Calling procedure
        else
          KeyTypeMenu() // Get sort key type
          skey7type = (MenuOption() - 4)
          if point_start <= point_end
            skey7start = point_start
            skey7end = point_end
          else
            skey7start = point_end
            skey7end = point_start
          endif
          start_col = skey7start
          end_col = skey7end
          ReWriteKeys()
        endif
        PointAndShoot()      // User wishes to use "Point And Shoot" method
        if shiftF3_pressed   // Did user start sort ?
          Return(True)       // Yes--Tell Calling procedure
        endif
        if esc_pressed       // Did user cancel ?
          Return(False)      // Yes--Tell Calling procedure
        else
          KeyTypeMenu() // Get sort key type
          skey8type = (MenuOption() - 4)
          if point_start <= point_end
            skey8start = point_start
            skey8end = point_end
          else
            skey8start = point_end
            skey8end = point_start
          endif
          start_col = skey8start
          end_col = skey8end
          ReWriteKeys()
        endif
        PointAndShoot()      // User wishes to use "Point And Shoot" method
        if shiftF3_pressed   // Did user start sort ?
          Return(True)       // Yes--Tell Calling procedure
        endif
        if esc_pressed       // Did user cancel ?
          Return(False)      // Yes--Tell Calling procedure
        else
          KeyTypeMenu() // Get sort key type
          skey9type = (MenuOption() - 4)
          if point_start <= point_end
            skey9start = point_start
            skey9end = point_end
          else
            skey9start = point_end
            skey9end = point_start
          endif
          start_col = skey9start
          end_col = skey9end
          ReWriteKeys()
        endif
        PointAndShoot()      // User wishes to use "Point And Shoot" method
        if shiftF3_pressed   // Did user start sort ?
          Return(True)       // Yes--Tell Calling procedure
        endif
        if esc_pressed       // Did user cancel ?
          Return(False)      // Yes--Tell Calling procedure
        else
          KeyTypeMenu() // Get sort key type
          skey0type = (MenuOption() - 4)
          if point_start <= point_end
            skey0start = point_start
            skey0end = point_end
          else
            skey0start = point_end
            skey0end = point_start
          endif
          start_col = skey0start
          end_col = skey0end
          ReWriteKeys()
        endif
        Return(True)
      endif
    else
      Return(False)
    endif
    start_col = skey1start
    end_col = skey1end
    ReWriteKeys()
    GetKey2Start:
    sAskStart = ""
    sAskEnd = ""
    ok = Ask("Enter starting column for search key 2:", sAskStart) // Get start
    if ok
      if Length(sAskStart) > 0       // if ok and something was entered
        if Val(sAskStart) > 0 AND Val(sAskStart) < 1009
          skey2start = Val(sAskStart)
          ok = Ask("Enter ending column for search key 2:", sAskEnd) // Get end
          if ok
            if Length(sAskEnd) > 0   // if ok and something was entered
              if sAskEnd <= sAskStart
                skey2end = Val(sAskStart)
              else
                if Val(sAskEnd) < 1009
                  skey2end = Val(sAskEnd)
                else
                  skey2end = 1009
                endif
              endif
            else
              skey2end = Val(sAskStart)
            endif
            KeyTypeMenu() // Get sort key type
            skey2type = (MenuOption() - 4)
          else
            Disable(PointAndShoot2Keys)
            UpdateDisplay(_HelpLine_Refresh_)
            Return(False)
          endif
        else
          Alarm()
          Goto GetKey2Start
        endif
      else
        Return(True)
      endif
    else
      Disable(PointAndShoot2Keys)
      UpdateDisplay(_HelpLine_Refresh_)
      Return(False)
    endif
    start_col = skey2start
    end_col = skey2end
    ReWriteKeys()
    GetKey3Start:
    sAskStart = ""
    sAskEnd = ""
    ok = Ask("Enter starting column for search key 3:", sAskStart) // Get start
    if ok
      if Length(sAskStart) > 0       // if ok and something was entered
        if Val(sAskStart) > 0 AND Val(sAskStart) < 1009
          skey3start = Val(sAskStart)
          ok = Ask("Enter ending column for search key 3:", sAskEnd) // Get end
          if ok
            if Length(sAskEnd) > 0   // if ok and something was entered
              if sAskEnd <= sAskStart
                skey3end = Val(sAskStart)
              else
                if Val(sAskEnd) < 1009
                  skey3end = Val(sAskEnd)
                else
                  skey3end = 1009
                endif
              endif
            else
              skey3end = Val(sAskStart)
            endif
            KeyTypeMenu() // Get sort key type
            skey3type = (MenuOption() - 4)
          else
            Disable(PointAndShoot2Keys)
            UpdateDisplay(_HelpLine_Refresh_)
            Return(False)
          endif
        else
          Alarm()
          Goto GetKey3Start
        endif
      else
        Return(True)
      endif
    else
      Disable(PointAndShoot2Keys)
      UpdateDisplay(_HelpLine_Refresh_)
      Return(False)
    endif
    start_col = skey3start
    end_col = skey3end
    ReWriteKeys()
    GetKey4Start:
    sAskStart = ""
    sAskEnd = ""
    ok = Ask("Enter starting column for search key 4:", sAskStart) // Get start
    if ok
      if Length(sAskStart) > 0       // if ok and something was entered
        if Val(sAskStart) > 0 AND Val(sAskStart) < 1009
          skey4start = Val(sAskStart)
          ok = Ask("Enter ending column for search key 4:", sAskEnd) // Get end
          if ok
            if Length(sAskEnd) > 0   // if ok and something was entered
              if sAskEnd <= sAskStart
                skey4end = Val(sAskStart)
              else
                if Val(sAskEnd) < 1009
                  skey4end = Val(sAskEnd)
                else
                  skey4end = 1009
                endif
              endif
            else
              skey4end = Val(sAskStart)
            endif
            KeyTypeMenu() // Get sort key type
            skey4type = (MenuOption() - 4)
          else
            Disable(PointAndShoot2Keys)
            UpdateDisplay(_HelpLine_Refresh_)
            Return(False)
          endif
        else
          Alarm()
          Goto GetKey4Start
        endif
      else
        Return(True)
      endif
    else
      Disable(PointAndShoot2Keys)
      UpdateDisplay(_HelpLine_Refresh_)
      Return(False)
    endif
    start_col = skey4start
    end_col = skey4end
    ReWriteKeys()
    GetKey5Start:
    sAskStart = ""
    sAskEnd = ""
    ok = Ask("Enter starting column for search key 5:", sAskStart) // Get start
    if ok
      if Length(sAskStart) > 0       // if ok and something was entered
        if Val(sAskStart) > 0 AND Val(sAskStart) < 1009
          skey5start = Val(sAskStart)
          ok = Ask("Enter ending column for search key 5:", sAskEnd) // Get end
          if ok
            if Length(sAskEnd) > 0   // if ok and something was entered
              if sAskEnd <= sAskStart
                skey5end = Val(sAskStart)
              else
                if Val(sAskEnd) < 1009
                  skey5end = Val(sAskEnd)
                else
                  skey5end = 1009
                endif
              endif
            else
              skey5end = Val(sAskStart)
            endif
            KeyTypeMenu() // Get sort key type
            skey5type = (MenuOption() - 4)
          else
            Disable(PointAndShoot2Keys)
            UpdateDisplay(_HelpLine_Refresh_)
            Return(False)
          endif
        else
          Alarm()
          Goto GetKey5Start
        endif
      else
        Return(True)
      endif
    else
      Disable(PointAndShoot2Keys)
      UpdateDisplay(_HelpLine_Refresh_)
      Return(False)
    endif
    start_col = skey5start
    end_col = skey5end
    ReWriteKeys()
    GetKey6Start:
    sAskStart = ""
    sAskEnd = ""
    ok = Ask("Enter starting column for search key 6:", sAskStart) // Get start
    if ok
      if Length(sAskStart) > 0       // if ok and something was entered
        if Val(sAskStart) > 0 AND Val(sAskStart) < 1009
          skey6start = Val(sAskStart)
          ok = Ask("Enter ending column for search key 6:", sAskEnd) // Get end
          if ok
            if Length(sAskEnd) > 0   // if ok and something was entered
              if sAskEnd <= sAskStart
                skey6end = Val(sAskStart)
              else
                if Val(sAskEnd) < 1009
                  skey6end = Val(sAskEnd)
                else
                  skey6end = 1009
                endif
              endif
            else
              skey6end = Val(sAskStart)
            endif
            KeyTypeMenu() // Get sort key type
            skey6type = (MenuOption() - 4)
          else
            Disable(PointAndShoot2Keys)
            UpdateDisplay(_HelpLine_Refresh_)
            Return(False)
          endif
        else
          Alarm()
          Goto GetKey6Start
        endif
      else
        Return(True)
      endif
    else
      Disable(PointAndShoot2Keys)
      UpdateDisplay(_HelpLine_Refresh_)
      Return(False)
    endif
    start_col = skey6start
    end_col = skey6end
    ReWriteKeys()
    GetKey7Start:
    sAskStart = ""
    sAskEnd = ""
    ok = Ask("Enter starting column for search key 7:", sAskStart) // Get start
    if ok
      if Length(sAskStart) > 0       // if ok and something was entered
        if Val(sAskStart) > 0 AND Val(sAskStart) < 1009
          skey7start = Val(sAskStart)
          ok = Ask("Enter ending column for search key 7:", sAskEnd) // Get end
          if ok
            if Length(sAskEnd) > 0   // if ok and something was entered
              if sAskEnd <= sAskStart
                skey7end = Val(sAskStart)
              else
                if Val(sAskEnd) < 1009
                  skey7end = Val(sAskEnd)
                else
                  skey7end = 1009
                endif
              endif
            else
              skey7end = Val(sAskStart)
            endif
            KeyTypeMenu() // Get sort key type
            skey7type = (MenuOption() - 4)
          else
            Disable(PointAndShoot2Keys)
            UpdateDisplay(_HelpLine_Refresh_)
            Return(False)
          endif
        else
          Alarm()
          Goto GetKey7Start
        endif
      else
        Return(True)
      endif
    else
      Disable(PointAndShoot2Keys)
      UpdateDisplay(_HelpLine_Refresh_)
      Return(False)
    endif
    start_col = skey7start
    end_col = skey7end
    ReWriteKeys()
    GetKey8Start:
    sAskStart = ""
    sAskEnd = ""
    ok = Ask("Enter starting column for search key 8:", sAskStart) // Get start
    if ok
      if Length(sAskStart) > 0       // if ok and something was entered
        if Val(sAskStart) > 0 AND Val(sAskStart) < 1009
          skey8start = Val(sAskStart)
          ok = Ask("Enter ending column for search key 8:", sAskEnd) // Get end
          if ok
            if Length(sAskEnd) > 0   // if ok and something was entered
              if sAskEnd <= sAskStart
                skey8end = Val(sAskStart)
              else
                if Val(sAskEnd) < 1009
                  skey8end = Val(sAskEnd)
                else
                  skey8end = 1009
                endif
              endif
            else
              skey8end = Val(sAskStart)
            endif
            KeyTypeMenu() // Get sort key type
            skey8type = (MenuOption() - 4)
          else
            Disable(PointAndShoot2Keys)
            UpdateDisplay(_HelpLine_Refresh_)
            Return(False)
          endif
        else
          Alarm()
          Goto GetKey8Start
        endif
      else
        Return(True)
      endif
    else
      Disable(PointAndShoot2Keys)
      UpdateDisplay(_HelpLine_Refresh_)
      Return(False)
    endif
    start_col = skey8start
    end_col = skey8end
    ReWriteKeys()
    GetKey9Start:
    sAskStart = ""
    sAskEnd = ""
    ok = Ask("Enter starting column for search key 9:", sAskStart) // Get start
    if ok
      if Length(sAskStart) > 0       // if ok and something was entered
        if Val(sAskStart) > 0 AND Val(sAskStart) < 1009
          skey9start = Val(sAskStart)
          ok = Ask("Enter ending column for search key 9:", sAskEnd) // Get end
          if ok
            if Length(sAskEnd) > 0   // if ok and something was entered
              if sAskEnd <= sAskStart
                skey9end = Val(sAskStart)
              else
                if Val(sAskEnd) < 1009
                  skey9end = Val(sAskEnd)
                else
                  skey9end = 1009
                endif
              endif
            else
              skey9end = Val(sAskStart)
            endif
            KeyTypeMenu() // Get sort key type
            skey9type = (MenuOption() - 4)
          else
            Disable(PointAndShoot2Keys)
            UpdateDisplay(_HelpLine_Refresh_)
            Return(False)
          endif
        else
          Alarm()
          Goto GetKey9Start
        endif
      else
        Return(True)
      endif
    else
      Disable(PointAndShoot2Keys)
      UpdateDisplay(_HelpLine_Refresh_)
      Return(False)
    endif
    start_col = skey9start
    end_col = skey9end
    ReWriteKeys()
    GetKey0Start:
    sAskStart = ""
    sAskEnd = ""
    ok = Ask("Enter starting column for search key 0:", sAskStart) // Get start
    if ok
      if Length(sAskStart) > 0       // if ok and something was entered
        if Val(sAskStart) > 0 AND Val(sAskStart) < 1009
          skey0start = Val(sAskStart)
          ok = Ask("Enter ending column for search key 0:", sAskEnd) // Get end
          if ok
            if Length(sAskEnd) > 0   // if ok and something was entered
              if sAskEnd <= sAskStart
                skey0end = Val(sAskStart)
              else
                if Val(sAskEnd) < 1009
                  skey0end = Val(sAskEnd)
                else
                  skey0end = 1009
                endif
              endif
            else
              skey0end = Val(sAskStart)
            endif
            KeyTypeMenu() // Get sort key type
            skey0type = (MenuOption() - 4)
          else
            Disable(PointAndShoot2Keys)
            UpdateDisplay(_HelpLine_Refresh_)
            Return(False)
          endif
        else
          Alarm()
          Goto GetKey0Start
        endif
      else
        Return(True)
      endif
    else
      Disable(PointAndShoot2Keys)
      UpdateDisplay(_HelpLine_Refresh_)
      Return(False)
    endif
    start_col = skey0start
    end_col = skey0end
    ReWriteKeys()
    Return(True)
END

INTEGER PROC SortRoutine(Integer bbl, Integer bel)

    integer sbbc = 1,           // default key start
            sbec = 80,          // default key end
            sr   = CurrRow(),
            sl   = CurrLine(),
            sc   = CurrCol(),
            bbc  = Query(BlockBegCol),
            bec  = Query(BlockEndCol)

    If keys == on
        ok = GetMultiKeys()
        UpdateDisplay(_CLine_Refresh_)
        if ok
        else
            Message("Terminated by user...")
            Delay(9)
            Ext = Off
            Return(False)
        endif
    endif
    Message("Preparing...")
    Delay(9)
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
        Delay(9)
        case keys
             when on
                   If Dos(Format(Query(MacPath), "fsort ",
                                 Query(SwapPath), "$tsees$i.$$$ ",
                                 Query(SwapPath), "$tsees$o.$$$ ",
                                 BuildMultiKey()), _DONTCLEAR_) == 0
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
             otherwise
                   If Dos(Format(Query(MacPath), "fsort ",
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
        endcase
    EndIf
    // Delete temp files
    Message("Deleting temp files...")
    Delay(9)
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

PROC ToggleMultiKeys()
   keys = iIf(keys == ON, OFF, ON)
   ext  = ON
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
    Y       =   5
    History
    NoEscape

    "",, Skip
    "     Alternate Sort Utility",, Skip
    "Authors: Terry Harris && Mel Hulse",, Skip
    "  Enhancements : Joseph Baechtel",, Skip
    " Version 1.4, September 13, 1993 ",, Skip
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
    "Specify &Multiple Sort Keys" [OnOffStr(keys) : 3],
        ToggleMultiKeys()       , ,//DontClose,
        "Specify multiple sort key indexies."
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
        Delay(9)
    Else
        ext = iIf((bel - bbl < 1000), OFF, ON) // <1k lines, default = internal
        PushPosition()                  // Supports whether blank line at end
            EndFile()
            BegLine()
            If CurrChar() < 0
                extra = TRUE
            EndIf
        PopPosition()
        keys = OFF
        While good  == OFF              // 'til we get good input
            If M == ON
                Repeat
                    SortMenu()          // what's the user want
                Until (MenuOption() == 8 OR MenuOption() == 9)
            EndIf

            If MenuOption() == 9            // quit
                Message("Terminated by user...")
                Delay(9)
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
