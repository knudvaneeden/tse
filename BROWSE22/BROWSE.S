// * Browse a file.

/***************************************************************************
|  TSE Macro  : Browse.s (for TSE Pro v2.5 or above)
|  Programmer : David Daniel Anderson
|
|  Purpose    : Makes TSE Pro a brawny clone of Vern Buerg's text reader
|               "LIST Plus". Switch between Browse and edit modes
|               instantaneously.
|
|  Revision   : 1994/08/10 - First public version
|  history           09/08 - Reworked interactive configuration menu,
|                            Fixed a couple of small bugs.  Removed
|                              hardcoded paths - now uses "SearchPath()".
|    v1.2            09/10 - Now creates BROWSE.INI with editor defaults
|                              if file is not found (instead of aborting).
|    v1.3            12/15 - Added check for mouse installation
|                    12/16 - Added line wrap (press 'W')
|                    12/17 - Added telephone dialer
|    v1.4       1995/03/17 - Removed most mouse code - too troublesome.
|                            Changed startup routine slightly.
|                            Moved explanation and notes to .DOC file.
|                            Added FILE date and time to status line.
|                            Documented format of BROWSE.INI.
|                            Rewrote the ContinuousScrolling procedure.
|                            Reworked interactive configuration menu.
|                            Dozens of other minor tweaks.
|    v1.5            04/07 - Added a different kind of mouse code.
|                            Removed ScrollDirection variable, and added
|                              ability to interactively set ScrollDelay.
|                            Added histories to search and file commands.
|                            Reduced number of hooks, reducing overhead.
|                            Added ability to sort pick file list.
|    v1.6            06/14 - Minor revisions to match TSE changes.
|    v1.7            07/12 - Modified C-Scrolling and bRepeatFind procs.
|                            More minor revisions to match TSE changes.
|                            Added two keys:
|                              "<" (,) = Repeat find backward
|                              ">" (.) = Repeat find forward
|    v2.0            10/18 - Added two keys:
|                              Alt <-  = RollLeft(2)
|                              Alt ->  = RollRight(2)
|                            Released to non-Beta testers.
|    v2.1       1996/02/21 - Fixed file date proc, removed US/Intl option
|                            Streamlined Color setting procedures
|                            Streamlined Write INI procedure
|                            * Compiled .MAC file is 1200 bytes smaller!
|    v2.2       1997/04/04 - Updated for TSE Pro v2.6 (32-bit).
|
|  Notice     : Public Domain.  Comments to author welcome,
|               on ILink, RIME, or Internet (ddanders@win.bright.net).
***************************************************************************/

/*  NEW WITH v1.4:  Browse.doc contains explanation and notes.

Procedure naming convention used:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   Since the vast majority of LIST functions did NOT have identical TSE
   counterparts, I had to write macros.  I've adopted the convention of
   prefacing user-written macros names with an additional letter, and here
   I've chosen 'b' (for 'B'rowse).

***************************************************************************/

string  browseini[64]='',
        datafile[64]='',                 // File to save marked lines to
        FileDT[16]='',                   // To display on status line
        bookmark[1]='a'                  // Most recently used bookmark
integer LongestLine=-1,                  // Length of longest line in file
        RestoreScreen=0,                 // Boolean, restore screen on exit?
                                         //   (not workable yet with TSE)
        ShowLines=0,
        ShowRuler=0,ShowToggles=0,       // Boolean, self-explanatory
        ShellEnabled=1,                  // Boolean, allow user to shell
        ModemCOMPort=2,                  // Port for Modem, for phone dialer
        Printing=FALSE,                  // Boolean, is Printing active?
        PrintLine=0,                     // Greatest line printed
        ContinuousScrollActive=FALSE,    // Boolean, is Scrolling active?
        ScrollDelay=18,                  // For bContinuousScroll()
        ScrollInc=8,                     // For Left/ Right movement
        FindRow=10,                      // Position of finds on screen
        FirstFile=0,                     // BufferID of first file in
                                         //   loaded or current ring when
                                         //   Browse macro activated.
        WrappedFile=0,                   // Wrapped file (buffer), if any
        Display_Mode=_DISPLAY_HEX_       // HEX or TEXT

// Positions cursor at upper left corner,
// called upon Browse startup and after movement
proc bUpperLeft()
  GotoColumn(CurrXoffset() + 1)
  GotoRow(1)
end bUpperLeft

// Next few are self-explanatory movement mini-macros
proc bRollUp()
  RollUp()
  bUpperLeft()
end bRollUp

proc bRollDown()
  RollDown()
  bUpperLeft()
end bRollDown

proc bBegFile()
  BegFile()
  ScrollToRow(1)
  bUpperLeft()
end bBegFile

proc bEndFile()
  GotoLine(NumLines()-Query(WindowRows)+2)
  ScrollToRow(1)
  bUpperLeft()
end bEndFile

proc bPageUp()
  PageUp()
  ScrollToRow(1)
  bUpperLeft()
end bPageUp

proc bPageDown()
  PageDown()
  ScrollToRow(1)
  bUpperLeft()
end bPageDown

proc bBegLine()
  BegLine()
  bUpperLeft()
end bBegLine

proc bFindLongestLine()  // find longest line, called by bEndLine() & AskToWrap()
  PushPosition()
    BegFile()
    LongestLine=0
    repeat
      LongestLine=iif(CurrLineLen()>LongestLine,CurrLineLen(),LongestLine)
    until NOT Down()
  PopPosition()
end bFindLongestLine

proc bEndLine()
  if LongestLine==-1  // LongestLine = -1 when _ON_CHANGING_FILES_
    bFindLongestLine()
  endif
  BegLine()
  GotoColumn(LongestLine)
  bUpperLeft()
end bEndLine

/* ********************************************************************** *
 * >>> Based on: <<<                                                      *
 * Macro: AutoScroll                                                      *
 * Date: 7-6-94,                                                          *
 * By: Richard Blackburn and George De Bruin,                             *
 * Revised: 7-7-94  -- GDB & SW                                           *
 * ********************************************************************** */

string proc mDirection(integer CurrKey)
    case CurrKey
        when <CursorUp>,<GreyCursorUp>
            Return("Up")
        When <CursorDown>,<GreyCursorDown>
            Return("Down")
        when <CursorLeft>,<GreyCursorLeft>
            Return("Left")
        when <CursorRight>,<GreyCursorRight>
            Return("Right")
    endcase
    Return("")   // (otherwise)
end mDirection

proc bContinuousScrolling()
string FileName[12] = SplitPath(CurrFileName(), _NAME_ | _EXT_),
       Velocity[20] = ''
integer Paused = TRUE, DelayTimeRemaining, Adjusted = FALSE,
        ScrollDirection = <CursorDown>,
        HelpLineRow = iif(Query(StatusLineRow)==1,Query(ScreenRows),1)

/**************************************************************************

C key       - turns continuous scrolling on or off    [but don't start scroll]

Up and Down - resume continuous scrolling                   > only if paused

spacebar    - or any key, interrupts continuous scrolling   > When NOT paused
                                                            > otherwise execute

+ (plus)    - makes continuous scroll incrementally faster  \ Only valid when
- (minus)   - makes continuous scroll slower                /   NOT paused

***************************************************************************/

    ContinuousScrollActive=TRUE   // ContinuousScrollActive is a global var
    UpdateDisplay(_STATUS_LINE_REFRESH_)
    LoopBegin:
    loop
        if KeyPressed()
          GetKey()
          if Paused
            case Query(Key)
              when <c>,<Shift C>
                      ContinuousScrollActive=FALSE
                      UpDateDisplay(_ALL_WINDOWS_REFRESH_|_HELPLINE_REFRESH_)
                      Break                         // Quit!

              when <CursorUp>,<GreyCursorUp>
                      RollUp()
                      ScrollDirection=<CursorUp>
                      Paused=FALSE

              when <CursorDown>,<GreyCursorDown>
                      RollDown()
                      ScrollDirection=<CursorDown>
                      Paused=FALSE

              otherwise
                      PressKey(Query(Key))  // Execute keystroke
                      UpdateDisplay()
                      if NOT ContinuousScrollActive
                        Break
                      endif
            endcase
          else
            case Query(Key)
              when <Grey+>,<=>,<Shift =>
                      ScrollDelay=iif(ScrollDelay <= 1, 1, ScrollDelay-1)
                      Adjusted = TRUE

              when <Grey->,<->
                      ScrollDelay=iif(ScrollDelay >= 40,40, ScrollDelay+1)
                      Adjusted = TRUE

              otherwise
                      Paused=TRUE
                      Adjusted = FALSE
                      PressKey(Query(Key))  // Execute keystroke
                      UpdateDisplay()
                      if NOT ContinuousScrollActive
                        Break
                      endif
            endcase
          endif
        endif

        Velocity = Format('':-((41-ScrollDelay)/2):"€")
                   +iif((ScrollDelay mod 2)==0,'›','')

        VGotoXY(1, HelpLineRow)
        Set(Attr, Query(StatusLineAttr))
        PutStr(Format
            ("File: ", FileName:-15,  // Display status message    //  [21]
             "Col: ",  CurrCol():-5,                               //  [ 9]
             "Line: ", CurrLine():-6,                              //  [12]
             iif(Paused,"Pause ", mDirection(ScrollDirection)):-7, //  [ 7]
             "Velocity: ", Velocity:-20))                 // 11 + 20 = [31]

        if (NOT Paused) and (NOT Adjusted)
          case ScrollDirection
            when <CursorUp>,<GreyCursorUp>
                    RollUp()
                    UpdateDisplay()
            when <CursorDown>,<GreyCursorDown>
                    RollDown()
                    UpdateDisplay()
            otherwise goto LoopBegin
          endcase
          DelayTimeRemaining = ScrollDelay
          while NOT KeyPressed()
            and DelayTimeRemaining
              Delay(1)
              DelayTimeRemaining = DelayTimeRemaining - 1
          endWhile
        else
          Adjusted = FALSE
        endif
    endloop

    bUpperLeft()
end bContinuousScrolling
/**************************************************************************/
//  End of bContinuousScrolling macro                                     *
/**************************************************************************/

// Goto a user-specified line, forward or backward
proc bRePosition(string direction)
string  hf[6]=''
integer how_far=0,
        Cursor=Set(Cursor,ON)
   if direction=='#'
      GotoLine()
   else
      Ask('How many lines do you want to move '+direction+'?',hf)
      how_far=val(hf)
      iif(direction=='back', GotoLine(CurrLine()-how_far), GotoLine(CurrLine()+how_far))
   endif
  ScrollToRow(1)
  bUpperLeft()
  Set(Cursor,Cursor)
end bRePosition

/*******************************************************************
  bPlaceMark() and bGotoMark() place and goto "bookmarks".
 ******************************************************************/
// string bookmark[1]='a'                 // Most recently used bookmark
proc bPlaceMark()
  bUpperLeft()
  PlaceMark(bookmark)   // Message('Set bookmark: ', bookmark)
  bookmark=iif (bookmark <> 'z', Chr(Asc(bookmark)+1), 'z')
end bPlaceMark

proc bGotoMark()
  bookmark=iif (bookmark <> 'a', Chr(Asc(bookmark)-1), 'a')
  GotoMark(bookmark)    // Message('Recalled bookmark: ', bookmark)
end bGotoMark

// Select a file name to edit (BROWSE), or a phone number to dial, or ???
// from the text on the screen
string proc bSelectText()
string selected_text[64]='',
  instruct[80]='Press <Enter> when cursor is at the beginning, and then the end of desired text.'
integer Cursor=Set(Cursor,ON)
  Set(Attr,Query(MsgAttr))
  VGotoXY(1,Query(ScreenRows))
  PutStr(instruct)      // Put instruction line at bottom of screen

  PushBlock()
  loop
    if KeyPressed()
       GetKey()
       case Query(Key)
         when <Escape>                          break
         when <CursorUp>,<GreyCursorUp>         Up()
         when <CursorDown>,<GreyCursorDown>     Down()
         when <CursorLeft>,<GreyCursorLeft>     Left()
         when <CursorRight>,<GreyCursorRight>   Right()
         when <PgUp>,<greyPgUp>                 PageUp()
         when <PgDn>,<greyPgDn>                 PageDown()
         when <Enter>,<greyEnter>               if isBlockMarked()
                                                   selected_text=(GetMarkedText())
                                                   break
                                                else
                                                   MarkColumn()
                                                endif
       endcase
       UpdateDisplay()
    endif
  endloop
  PopBlock()
  Set(Cursor,Cursor)
  bUpperLeft()
  UpdateDisplay(_ALL_WINDOWS_REFRESH_|_HELPLINE_REFRESH_)
  Return(selected_text)
end bSelectText

// Select a file name to edit from the text on the screen.
proc bSelectFile()
string filename[64]=''
  filename=bSelectText()
  while NOT EditFile(filename)
    if NOT Ask('Unable to load, please revise the file name:', filename, _EDIT_HISTORY_)
      break
    endif
  endwhile
end bSelectFile

// Hang up phone via modem
proc bHangupPhone()
  Dos('echo ath>com'+Str(ModemCOMPort)+':', _DONT_CLEAR_)
  Message('Hanging up phone, please wait...')
  Delay(36)
  UpdateDisplay()
end bHangupPhone

// Select a phone number to dial from the text on the screen.
// Based on a macro by Fabio Ferrero, and advice from David Boyd.
proc bDialPhone()
string phonenum[64]='',
       phonestr[64]=''
  phonenum=bSelectText()
  if phonenum <> ''        // Don't try to dial a null phone number!
    phonestr='echo atd'+phonenum+'>com'+Str(ModemCOMPort)+':'
    Dos('echo atzm1>com'+Str(ModemCOMPort)+':', _DONT_CLEAR_)
      Message('Initializing modem, please wait...')
      Delay(36)
    Dos(phonestr, _DONT_CLEAR_)
      Message('Dialed: "'+phonenum+'".  Press a key when you have picked up the phone!')
      GetKey()
    bHangupPhone()
  endif
  UpdateDisplay(_ALL_WINDOWS_REFRESH_|_HELPLINE_REFRESH_)
end bDialPhone

// Quit to next file
proc bQuitFile()
integer QuitToPrompt=Set(QuitToPrompt,ON)
  QuitFile()
  Set(QuitToPrompt,QuitToPrompt)
end bQuitFile

// Enhanced Find(), forward, backward, any case, exact case
proc bFind(string direction)
string text[64]=''
integer Cursor=Set(Cursor,ON)
  if Ask('Text to search for:',text,_FIND_HISTORY_) AND text <> ''
      if Find(text,direction)
         ScrollToRow(FindRow)
         HiLiteFoundText()
      else
         ScrollToRow(1)
      endif
  endif
  Set(Cursor,Cursor)
end bFind

// Enhanced RepeatFind() goes to other files if not found in current
proc bRepeatFind(integer direction)
integer cfile=GetBufferID(),
        found=FALSE,
        Cursor=Set(Cursor,ON)
  if direction==777
     repeat
       found=RepeatFind(_FORWARD_)
       if ((NOT found) AND NextFile())
          BegFile()
          UpdateDisplay()
       endif
     until found OR cfile==GetBufferID()
  else
     found=RepeatFind(direction)
  endif
  Set(Cursor,Cursor)
  if found
     ScrollToRow(FindRow)
     HiLiteFoundText()
  endif
end bRepeatFind

// Toggle whether beeps are issued
proc bToggleBeep()
  Set(Beep,iif(Query(Beep),FALSE,TRUE))
end bToggleBeep

// Mark bottom line of window, for saving to file
proc bMarkBotLine()
   PushPosition()
   EndWindow()
   MarkLine()
   PopPosition()
end bMarkBotLine

// Save current line or marked text to a newly specified file
proc bSaveData()
integer Cursor=Set(Cursor,ON)
  if NOT isBlockMarked()
     MarkLine()
  endif
  if Ask('New or existing file to append marked line(s) to: ',datafile,_EDIT_HISTORY_)
     SaveBlock(datafile,_DEFAULT_)
  endif
  UnmarkBlock()
  Set(Cursor,Cursor)
end bSaveData

// Save current line or marked text to previously specified file
proc bAppendData()
  if datafile==''
     bSaveData()
  else
    if NOT isBlockMarked()
       MarkLine()
    endif
     if fileExists(datafile)
       SaveBlock(datafile,_APPEND_)
     else
       SaveBlock(datafile,_DEFAULT_)
     endif
    UnmarkBlock()
  endif
end bAppendData

// Print current line or marked block
proc bPrintBlock()
    if NOT isBlockMarked()
       MarkLine()
    endif
    if PrintBlock() endif
    UnmarkBlock()
end bPrintBlock

// Turn Printing on and off
proc bPrintStream()
  if Printing
     Printing=FALSE
     ClosePrint()
  else
     Printing=TRUE
     Set(PrintDevice,'LPT1')
  endif
end bPrintStream

// After movement, check if more text should be printed
proc bCheckPrintQueue()
integer lastline, noerror=TRUE
  if Printing
     PushPosition()
     GotoRow(1)
       PrintLine=iif(CurrLine() > PrintLine,CurrLine()-1,PrintLine)
     GotoRow(Query(WindowRows))
       lastline=CurrLine()

     GotoLine(PrintLine+1)

     BegLine()
     PrevChar()
     while (NextChar() AND (CurrLine() < (lastline+1))) AND noerror
       if CurrChar() == _AT_EOL_
          noerror=PrintChar(Chr(13))
          noerror=PrintChar(Chr(10))
          noerror=(NOT (CurrLine() == NumLines()))
       else
          noerror=PrintChar(Chr(CurrChar()))
       endif
     endwhile
     RollUp()
     PrintLine=iif(CurrLine() > PrintLine,CurrLine(),PrintLine)
     PopPosition()
     if NOT noerror
        Warn('The end of file has been reached and Printing terminated!')
        bPrintStream()
     else
        Message('Continuous PRINT active!  Last line printed: '
                                      +Str(PrintLine)
             +'  Current lower line: '+Str(CurrLine()
             +   (Query(WindowRows)-CurrRow())))
     endif
  endif
end bCheckPrintQueue

// Eject a sheet from printer by sending a formfeed
proc bPrintFF()
   if NOT PrintChar(Chr(12))
     Warn('Page eject failed!')
   endif
end bPrintFF

/**************************************************************************
   Get the reverse of a color attribute, without blinking
   example: ReverseAttr of Red on Black or Bright Red on Black
            yields Black on Red
 **************************************************************************/
integer proc ReverseAttr(integer Attr)
  Return((((Attr mod 16) * 16) + (Attr / 16)) mod 128)
end ReverseAttr

// Use a minimum of specified attributes to set unspecified counterparts
proc bStandardizeAttributes()
     Set(CursorAttr,                  (Query(TextAttr)))
     Set(MenuTextAttr,                (Query(StatusLineAttr)))
     Set(MenuTextLtrAttr,  ReverseAttr(Query(MenuTextAttr)))
     Set(MenuSelectAttr,              (Query(MenuTextLtrAttr)))
     Set(MenuSelectLtrAttr,           (Query(MenuTextAttr)))
     Set(MenuBorderAttr,   ReverseAttr(Query(TextAttr)))

  if NOT (CurrFileName()==browseini)
     UpDateDisplay(_ALL_WINDOWS_REFRESH_|_HELPLINE_REFRESH_)
  endif
end bStandardizeAttributes

/**************************************************************************
   These next few procedures should be self-explanatory.
   They simply allow the user to cycle colors for various text areas.
 **************************************************************************/
proc bSetTextColor(integer Fore)
  if NOT isMacroLoaded('COLORS')
     if Fore
       Set(TextAttr,(((Query(TextAttr) / 16)*16)+(Query(TextAttr)+1) mod 16))
     else
       Set(TextAttr,((Query(TextAttr)+16) mod 128))
     endif
     bStandardizeAttributes()
  endif
end bSetTextColor

proc bSetTopBotColor(integer Fore)
  if NOT isMacroLoaded('COLORS')
     if Fore
       Set(StatusLineAttr,(((Query(StatusLineAttr) / 16)*16)+(Query(StatusLineAttr)+1) mod 16))
     else
       Set(StatusLineAttr,((Query(StatusLineAttr)+16) mod 128))
     endif
     bStandardizeAttributes()
  endif
end bSetTopBotColor

proc bSetFindColor(integer Fore)
integer TempAttr=Query(CursorAttr)
  if NOT isMacroLoaded('COLORS')
     PushBlock()
     UnMarkBlock()
       Set(CursorAttr,Query(HiLiteAttr))
       if Fore
         Set(CursorAttr,(((Query(CursorAttr) / 16)*16)+(Query(CursorAttr)+1) mod 16))
       else
         Set(CursorAttr,((Query(CursorAttr)+16) mod 128))
       endif
       UpDateDisplay(_CLINE_REFRESH_)
       PushKey(GetKey())
       Set(HiLiteAttr,Query(CursorAttr))
       Set(CursorAttr,TempAttr)
     PopBlock()
  endif
end bSetFindColor

// Toggle lines displayed on the screen between 25, 36, 44 and 50 lines.
// *** Does not work well with Ultravision active! ***
proc bToggleScreen()
integer Cursor=Query(Cursor)
  case Query(ScreenRows)
    when 25
      Set(CurrVideoMode, _36_LINES_)
    when 36
      Set(CurrVideoMode, _44_LINES_)
    when 44
      Set(CurrVideoMode, _50_LINES_)
    otherwise
      Set(CurrVideoMode, _25_LINES_)
  endcase
  Set(Cursor,Cursor)
  Message('Screen is now set to ', Query(ScreenRows),' lines.')
end bToggleScreen

// Toggle between one and two (horizontal) windows
proc bToggleWindows()
   if ZoomWindow()
      OneWindow()
   else
      HWindow()
   endif
end bToggleWindows

// Blank the screen, then restore it when a key is pressed.
proc bScreenSave()
integer mouseon=Query(MouseEnabled)
  if mouseon HideMouse() endif
  ClrScr()
  GetKey()
  if mouseon ShowMouse() endif
  UpDateDisplay(_ALL_WINDOWS_REFRESH_|_HELPLINE_REFRESH_)
end bScreenSave

// Shows the filename on the status line, compressed if necessary
proc bShowFName(integer numLen)
integer nameMax
integer pathOffset
string fullName[128], filePath[128], displayName[64]=''
  nameMax=numLen
  fullName=CurrFileName()
  if Length(fullName) > nameMax
     filePath=SplitPath(fullName,_PATH_|_NAME_|_EXT_)
     pathOffset=Length(filePath) - (nameMax - 6) + 1

     displayName=displayName+SubStr(fullName,1,2)  // Add drive letter
     displayName=displayName+'\.*'                 // Add ellipsis
     displayName=displayName+SubStr(filePath,pathOffset,nameMax-6)  // Add name

     Set(Attr,Query(StatusLineAttr))
     VGotoXY(35,Query(StatusLineRow))
     // PutStr(Format('':(Query(ScreenCols)-34):Chr(Query(StatusLineFillChar))))
     VGotoXY(35,Query(StatusLineRow))
     PutStr(displayName+' '+Chr(Query(StatusLineFillChar)))
  endif
end bShowFName

// ************************************************************************
//   bShowStatusInfo() reports total lines in file or the position in the *
//   file as a percentage). It also puts name/ date/ time on status line. *
// ************************************************************************
integer proc bShowStatusInfo()
// slfc[1]=Chr(Query(StatusLineFillChar))
string  sToWrite[8]=''
integer NL=NumLines(),
        PC=CurrLine()*100/NL,
        wStat
  Set(Attr,Query(StatusLineAttr))
  if ShowLines
    sToWrite=str(NL)+'l'
  else
    sToWrite=str(PC)+'%'
  endif
  wStat=Length(sToWrite)
  VGotoXY(Query(ScreenCols)-(wStat+1),Query(StatusLineRow))
  PutStr(' '+sToWrite+ ' ')

  VGotoXY(18,Query(StatusLineRow))
  PutStr(FileDT)
  BreakHookChain()
  Return(Length(sToWrite)+2)
end bShowStatusInfo

// Toggle between showing number of lines in file vs. % of way through file
proc bToggleLines()
  ShowLines=iif(ShowLines,FALSE,TRUE)
  ExecHook(_AFTER_UPDATE_STATUSLINE_)
end bToggleLines

// Show a ruler line at the top of the screen (up to 132 columns)
proc bShowRuler()
   Set(Attr,Query(StatusLineAttr))
   VGotoXY(1,1)
   PutStr(
    '˘˘˘˘≥˘˘˘˘1˘˘˘˘≥˘˘˘˘2˘˘˘˘≥˘˘˘˘3˘˘˘˘≥˘˘˘˘4˘˘˘˘≥˘˘˘˘5˘˘˘˘≥˘˘˘˘6˘˘˘˘≥'+
         '˘˘˘˘7˘˘˘˘≥˘˘˘˘8˘˘˘˘≥˘˘˘˘9˘˘˘˘≥˘˘˘˘0˘˘˘˘≥˘˘˘˘1˘˘˘˘≥˘˘˘˘2˘˘˘˘≥˘˘˘˘3˘˘')
   BreakHookChain()
end bShowRuler

// Toggle between status line and ruler line
proc bToggleRuler()
  ShowRuler=iif(ShowRuler,FALSE,TRUE)
  if ShowRuler
     Set(StatusLineUpdating,OFF)
  else
     Set(StatusLineUpdating,ON)
     UpdateDisplay(_STATUSLINE_REFRESH_)
  endif
end bToggleRuler

// Toggle between showing line info or ruler on status line
proc bStatusLine()
integer numLen
  if ShowRuler
      bShowRuler()
    else
      if NOT ContinuousScrollActive
        numLen=bShowStatusInfo()
        numLen=Query(ScreenCols)-35-numLen
        bShowFName(numLen)
      endif
  endif
end bStatusLine

// Place current status of toggles on "helpline"
proc bShowToggles()
   Set(Attr,Query(MenuTextAttr))
   VGotoXY(1,Query(ScreenRows))
   PutStr('[Display mode: ' + iif(Chr(iif(DisplayMode()==_DISPLAY_HEX_,Asc('H'),Asc('T')))=='H',' Hex','Text')
       +'] [Print: '        + iif(Chr(iif(Printing==TRUE,              Asc('Y'),Asc('N')))=='Y',' ON' ,'OFF' )
       +'] [Tabs expanded: '+ iif(Chr(iif(Query(ExpandTabs),           Asc('Y'),Asc('N')))=='Y','Yes' ,' No' )
       +'] [Scrolling: '    + iif(Chr(iif(ContinuousScrollActive==TRUE,Asc('Y'),Asc('N')))=='Y',' ON' ,'OFF' )+']')
end bShowToggles

// Toggle between showing toggles and helpline
proc bToggleHelpLine()
  ShowToggles=iif(ShowToggles,FALSE,TRUE)
  if ShowToggles
     if NOT Hook(_AFTER_COMMAND_,bShowToggles)
        Warn('Hook() for show toggles unsuccessful.  Continuing anyway.')
        ShowToggles=FALSE
     endif
  else
     UnHook(bShowToggles)
     UpdateDisplay(_HELPLINE_REFRESH_)
  endif
end bToggleHelpLine

// Get a number from user (adapted from a macro of same name in TSE.UI [2.0])
integer proc ReadNum(integer n)
string s[5] = str(n)
    ReadNumeric(s)
    Return(val(s))
end ReadNum

// Set tab interval
menu bSetTabIntervalMenu()
    title="Set tab interval"
    "&Tab Width"            [Query(TabWidth) : 5],
         set(TabWidth, ReadNum(Query(TabWidth))), CloseAfter
    "&Cancel     " ,  Message('Tab interval unchanged!')
end bSetTabIntervalMenu

// Toggle between text and hex display
proc bToggleDisplayMode()
   DisplayMode(iif (DisplayMode() == _DISPLAY_TEXT_, _DISPLAY_HEX_, _DISPLAY_TEXT_))
end bToggleDisplayMode

// Toggle between line-wrapped and normal display
proc bToggleLineWrap()
integer accuracy=1000000, WrapRightMarg=Query(WindowCols),
        filepos=(CurrLine()*accuracy/NumLines()), CFile=GetBufferID()

  if BufferType()==_SYSTEM_
    filepos=(CurrLine()*accuracy/NumLines())  // Goto approximate equivalent
    AbandonFile()                             // position
    GotoLine((filepos*NumLines())/accuracy)
  else
    PushPosition()
    PushBlock()                               // Save original block status
    UnMarkBlock()

    BegFile() MarkLine()                      // Mark the entire file
    EndFile() MarkLine()
    WrappedFile=CreateTempBuffer()            // Allocate a buffer,
    GotoBufferID(WrappedFile)                 // and go to it

    CopyBlock()                           // Copy the file into the temp buffer
    UnMarkBlock()
    repeat
      while CurrLineLen() > WrapRightMarg
        GotoColumn(WrapRightMarg+1)
        repeat   // Try to split at word break between 70 & 80 (or other vals)
          Left()
        until (CurrChar()==32) OR (CurrCol() < (WrapRightMarg-10))

        if CurrChar()==32 // Don't wrap the space itself
           Right()
        else
           GotoColumn(WrapRightMarg+1)
        endif

        SplitLine()            // Now split the long line,
        Down()                 // and go to the new (shorter) line
      endwhile
    until NOT Down()

    GotoBufferID(CFile)        // Return to original file momentarily
    PopPosition()              // Restore saved position
    PopBlock()                 // Restore original block

    GotoBufferID(WrappedFile)  // Go to temp buffer for rest of the macro
    GotoLine((filepos*NumLines())/accuracy)  // Goto approximate equivalent
    ScrollToRow(1)                           // position
    BegLine()
  endif
end bToggleLineWrap

// If file is .TXT or .DOC or .1ST or .DIZ, ask if Wrap mode should be executed
proc AskToWrap()
  case Upper(CurrExt())
   when ".TXT", ".DOC", ".1ST", ".DIZ"
    if LongestLine==-1  // LongestLine = -1 when _ON_CHANGING_FILES_
      bFindLongestLine()
    endif
    if LongestLine > Query(ScreenCols)
      if YesNo('File contains long lines, wrap this file?')==1
        bToggleLineWrap()
      endif
    endif
  endcase
end AskToWrap

// Quit the _SYSTEM_ buffer used in WRAP mode
proc bQuitWrappedMode()
  if BufferType()==_SYSTEM_
     AbandonFile()
  endif
  WrappedFile=0
end bQuitWrappedMode

// Get the word at cursor  (lifted from TSE help)
/**************************************************************************
  Return the word at (or to the left of) the cursor as a
  string.
 **************************************************************************/
string proc WordAtCursor()
string word[64]=''
    PushPosition()
    PushBlock()                  // Save current block status
    if MarkWord() or (Left() and MarkWord()) // Mark it
                word = GetMarkedText()       // Get it
    endif
    PopBlock()                  // Restore block status
    PopPosition()
    return (word)               // That's all, folks!
end WordAtCursor

// Helper routine for bWriteBINI()
proc bGotoText(string text)
  if NOT lFind(text,'gi')
    EndFile() AddLine()
  endif
  BegLine()
end bGotoText

proc bWriteBINIvar(string ivar, integer ival)
string istr[50]=''
  istr=Format(ivar:-18) + '= '+ Format(Str(ival):-18)
  bGotoText(ivar)
  InsertText(istr,_OVERWRITE_)
end bWriteBINIvar

// "Clone" current settings
proc bWriteBINI()
  EditFile(browseini)
  if SplitPath(CurrFileName(),_NAME_|_EXT_) <> 'browse.ini'
    Warn('Unable to write BROWSE.INI options - no INI file defined.')
    Return()
  endif

  bWriteBINIvar('ShowToggles', ShowToggles)
  bWriteBINIvar('ShowRuler', ShowRuler)
  bWriteBINIvar('ShowLines', ShowLines)
  bWriteBINIvar('TabWidth', Query(TabWidth))
  bWriteBINIvar('ExpandTabs', Query(ExpandTabs))
  bWriteBINIvar('ScrollInc', ScrollInc)
  bWriteBINIvar('FindRow', FindRow)
  bWriteBINIvar('Beep', Query(Beep))
  bWriteBINIvar('Display_Mode', DisplayMode())
  bWriteBINIvar('RestoreScreen', RestoreScreen)
  bWriteBINIvar('ShellEnabled', ShellEnabled)
  bWriteBINIvar('ModemCOMPort', ModemCOMPort)
  bWriteBINIvar('ScrollDelay', ScrollDelay)

  if NOT isMacroLoaded('COLORS')
     bWriteBINIvar('TextAttr', Query(TextAttr))
     bWriteBINIvar('HiLiteAttr', Query(HiLiteAttr))
     bWriteBINIvar('StatusLineAttr', Query(StatusLineAttr))
  endif

  SaveFile() AbandonFile()
end bWriteBINI

// Shell to OS if option enabled
proc bShell()
  iif (ShellEnabled==TRUE,Shell(),Warn('Shell not enabled!'))
end bShell

// Called when changing from Browse to edit mode
proc bEndProcess()
  bQuitWrappedMode()
  EndProcess()
  ContinuousScrollActive=FALSE
end bEndProcess

// Called when 'E' (edit file) is pressed
proc bStartEditing()
  if YesNo("Enable EDIT mode?")==1
    bEndProcess()
  endif
end bStartEditing

// These next three are supposed to be different ways of exiting,
// but TSE does not allow flexibility in this area.  Maybe later.
proc bExitCLS()  // This proc doesn't do what it claims
//  ClrScr()          // This doesn't work
/*
  PushKey(<enter>)    // This doesn't work
  PushKey(<s>)
  PushKey(<l>)
  PushKey(<c>)
*/
  bEndProcess()
  Exit()
//  DOS('CLS')        // This doesn't work
end bExitCLS

proc bExitLeaveScreen()  // This proc doesn't do what it claims
  bEndProcess()
  Exit()
end bExitLeaveScreen

proc bExitRestoreScreen() // This proc DOES do what it claims!
  bEndProcess()
  Exit()
end bExitRestoreScreen

/**************************************************************************
  This PickFileStartUp() routine is a cross between the one from the
  Hook.DOC file (distributed with TSE v2.0), and one in F.S, (first
  distributed with the TSE 2.01s Beta).  The routine was tested by DDA.
***************************************************************************/
/*
 tag         1 character                  1, 1
 attribute   1 character                  2, 2
 time        2 bytes, encoded             3, 4
 date        2 bytes, encoded             5, 6
 size        4 bytes (SAL INTEGER)        7,10
 filename   13 bytes (NULL terminated)   11,18
*/

   keydef pickkeys
      <Alt N> Set(PickFileSortOrder, "ne"  )  Sort(_pick_sort_)    // Name
      <Alt E> Set(PickFileSortOrder, "en"  )  Sort(_pick_sort_)    // Ext
      <Alt S> Set(PickFileSortOrder, "sne" )  Sort(_pick_sort_)    // Size
      <Alt D> Set(PickFileSortOrder, "dtne")  Sort(_pick_sort_)    // Date
      <Alt A> Set(PickFileSortOrder, "ane" )  Sort(_pick_sort_)    // Attribute
//    <Del>   Warn(GetText(1,18))
    end

   proc PickFileStartUp()
       enable(pickkeys)
       WindowFooter("Sort by: {Alt} {N}ame, {E}xt, {S}ize, {D}ate, {A}ttr")
   end
/**************************************************************************/

// Editfile() prompt in current directory
proc bChooseFile()
  PushKey(<Enter>)
  PushKey(<BackSpace>)
  PushKey(<SpaceBar>)
  EditFile()
end bChooseFile

// Normal EditFile(), cursor turned on first
proc bEditFile()
string NewFileName[64]=''
integer Cursor=Set(Cursor,ON)
  if (Ask('New file(s) to edit:',NewFileName,_EDIT_HISTORY_) and
          (NewFileName <> ''))
    EditFile(NewFileName)
  else
    bChooseFile()
  endif
  Set(Cursor,Cursor)
end bEditFile

// Popped up when <Escape> is pressed, to allow extended options
menu bExitMenu()
    title="Exit, edit, or select new?"
    history=1
    x=3
    y=2
    NoEscape
    NoKeys
    "e&Xit editor"          , bExitRestoreScreen()
    "&Edit current file(s)" , bEndProcess()
    "&Select new file(s)"   , bChooseFile()
    "&Cancel"
end bExitMenu

// If <Escape> is pressed when only one unchanged file is loaded, just exit
// (unless QuitToPrompt==TRUE)
proc bExit()
integer eqb
  bQuitWrappedMode()
  if (NumFiles() <= 1) AND (NOT FileChanged())
     AbandonFile()
     ClrScr()
     if Query(QuitToPrompt)
       bChooseFile()
     endif
  else             // if more than one file open, ask what to do
     eqb=Set(EquateEnhancedKbd,_ON_)
     bExitMenu()
     Set(EquateEnhancedKbd,eqb)
  endif
end bExit

/**************************************************************************
   Get the date and time of file in order to display on status line

   Note: There are two routines here, the first for TSE Pro/32 v2.6 (the
   Win32 console editor), and the second for TSE Pro 2.5 (DOS editor).
 **************************************************************************/
#ifdef WIN32  // aka, if TSE Pro/32 v2.6

   proc bGetFileDateTime()
     if FindThisFile(CurrFileName(),_READONLY_|_HIDDEN_|_SYSTEM_|_ARCHIVE_)
       FileDT=FFDateStr()+' '+SubStr(FFTimeStr(),1,5)
     else
       FileDT='00/00/00 00:00'
     endif
     FileDT=FileDT+chr(32)+chr(4)  // FileDT is a global var
   end bGetFileDateTime

#else  // aka, if TSE Pro v2.5

   string proc ReturnFileDateTime(string path)
     string dta[80]='', dtString[80]='', FileDate[8]='00/00/00', FileTime[5]='00:00'
     setDTA(dta)
     if FindFirst(path,_READONLY_|_HIDDEN_|_sYsTEM_|_ARCHIVE_|_DIRECTORY_)
        dtString = DecodeDTA(dta)
        FileDate=dtString[26:8]
        FileTime=dtString[35:8]
     endif
     return(FileDate+' '+FileTime)
   end ReturnFileDateTime

   proc bGetFileDateTime()
     if FileExists(CurrFileName())
       FileDT=ReturnFileDateTime(CurrFileName())
     else
       FileDT='00/00/00 00:00'
     endif
     FileDT=FileDT+chr(32)+chr(4)  // FileDT is a global var
   end bGetFileDateTime

#endif  // End Conditional Compilation portion.

// Set up any needed info for current file
proc bInitFile()
integer cfile=GetBufferID()
  if GotoBufferID(WrappedFile) AND BufferType()==_SYSTEM_  // First exit temp
     bQuitWrappedMode()                                    // buffer, if any
  endif
  GotoBufferID(cfile)
  bGetFileDateTime()
  LongestLine=-1
  bUpperLeft()
end bInitFile

// Get init value from a line in Browse.ini ("clone") file
string proc bGetInit()
string svd_word_set[32] = Set(WordSet,ChrSet("0-9<>A-Z_a-z")),
       wac[32]=''
   GotoPos(PosLastNonWhite())
   wac=WordAtCursor()
   Set(WordSet,svd_word_set)
   Return(wac)
end bGetInit

// Reads the values of variables found in Browse.ini
proc bReadBINI()
integer cfile=GetBufferID(), iniBuffer=CreateTempBuffer()
  GotoBufferID(iniBuffer)
  InsertFile(browseini)
  UnMarkBlock()
  BegFile()
  repeat
    BegLine()
    GotoPos(PosFirstNonWhite())
    case WordAtCursor()
      when 'ShowToggles'           ShowToggles     =val(bGetInit())
      when 'ShowRuler'             ShowRuler       =val(bGetInit())
      when 'ShowLines'             ShowLines       =val(bGetInit())
      when 'TabWidth'          Set(TabWidth        ,val(bGetInit()))
      when 'ExpandTabs'        Set(ExpandTabs      ,val(bGetInit()))
      when 'ScrollInc'             ScrollInc       =val(bGetInit())
      when 'FindRow'               FindRow         =val(bGetInit())
      when 'Beep'              Set(Beep            ,val(bGetInit()))
      when 'Display_Mode'          Display_Mode    =val(bGetInit())
      when 'RestoreScreen'         RestoreScreen   =val(bGetInit())
      when 'ShellEnabled'          ShellEnabled    =val(bGetInit())
      when 'ModemCOMPort'          ModemCOMPort    =val(bGetInit())
      when 'ScrollDelay'           ScrollDelay     =val(bGetInit())
    endcase
  until NOT Down()

  BegFile()
  if NOT isMacroLoaded('COLORS')
     repeat
       BegLine()
       GotoPos(PosFirstNonWhite())
       case WordAtCursor()
          when 'TextAttr'          Set(TextAttr          ,val(bGetInit()))
          when 'HiLiteAttr'        Set(HiLiteAttr        ,val(bGetInit()))
          when 'StatusLineAttr'    Set(StatusLineAttr    ,val(bGetInit()))
       endcase
     until NOT Down()
  endif

  AbandonFile()
  GotoBufferID(cfile)
end bReadBINI

// ************************************************************************
//  Initialize colors and other things (read from Browse.ini)             *     *
// ************************************************************************
proc bBrowseInit()
   Display_Mode=DisplayMode(_DISPLAY_TEXT_)
   AddHistoryStr('',_EDIT_HISTORY_)
   if browseini==''
     browseini=SearchPath('browse.ini',Query(TSEPath))
     if browseini==''
       browseini=SearchPath('browse.ini',LoadDir(),'usermac')
       if browseini==''
         browseini=SearchPath('browse.ini',LoadDir(),'mac')
         if browseini==''
           browseini=SearchPath('browse.ini',GetEnvStr('PATH'),'.')
         endif
       endif
     endif
   endif

// ************************************************************************
//  If we couldn't find Browse.INI in any of those places, we will create *
//  one in the LoadDir()+usermac or LoadDir()+mac directory, if possible, *
//  otherwise we have to create Browse.INI in the LoadDir() itself.       *
// ************************************************************************

   if browseini==''
     if (FileExists(LoadDir()+'usermac') & _DIRECTORY_)
       browseini=LoadDir()+'usermac\browse.ini'
     else
       if (FileExists(LoadDir()+'mac') & _DIRECTORY_)
         browseini=LoadDir()+'mac\browse.ini'
       else
         browseini=LoadDir()+'browse.ini'
       endif
     endif
     Warn('BROWSE.INI not found, creating '+browseini+'!')
     bWriteBINI()          // Create from defaults
   else
     bReadBINI()
   endif
   if NOT isMacroLoaded('COLORS')
     bStandardizeAttributes()
   endif
   DisplayMode(Display_Mode)
end bBrowseInit

// Called from interactive configuration menu, to prevent file position
// from being altered
proc bRestoreInit()
  PushPosition()
  bBrowseInit()
  ShowRuler  =iif(ShowRuler,FALSE,TRUE)    bToggleRuler()
  ShowToggles=iif(ShowToggles,FALSE,TRUE)  bToggleHelpLine()
  PopPosition()
end bRestoreInit

// Allow user to specify row that finds will be displayed on
proc bSetFindRow()  // Not bound to a key - use interactive menu
  FindRow=ReadNum(FindRow)
end bSetFindRow

// Allow user to specify which COM port the modem is on (for phone dialer)
proc bSetModemCOMPort()
  ModemCOMPort=ReadNum(ModemCOMPort)
end bSetModemCOMPort

// Allow user to toggle setting of RestoreScreen on exit
// (currently does not really work, but if TSE ever allows it, so will I)
proc bToggleRS()
  RestoreScreen=iif(RestoreScreen==0,TRUE,FALSE)
end bToggleRS

// Allow user to toggle whether shelling to OS is allowed
proc bToggleShellEnabled()
  ShellEnabled=iif(ShellEnabled==0,TRUE,FALSE)
end bToggleShellEnabled

// Allow user to specify distance to scroll when moving right or left
proc sScrollInc()
  ScrollInc=ReadNum(ScrollInc)
end sScrollInc

// Allow user to specify delay for bContinuousScroll proc
proc sScrollDelay()
  ScrollDelay=ReadNum(ScrollDelay)
end sScrollDelay

// Shows value of a Boolean (based on a macro found in TSE.UI)
string proc YesNoStr(integer i)
  return (iif(i, "Yes", "No"))
end YesNoStr

// Shows what the current display mode is
string proc bHexText()
  case DisplayMode()
    when _DISPLAY_TEXT_  Return('Text')
    when _DISPLAY_HEX_   Return('Hex')
  endcase
  Return('')
end bHexText

menu bStatusLineToggles()
   history
   title="Status line toggles"
   "Show &toggles"                         [YesNoStr(ShowToggles) : 5],
       bToggleHelpLine()    , CloseAllAfter
   "Show &ruler line"                      [YesNoStr(ShowRuler)   : 5],
       bToggleRuler()       , CloseAllAfter
   "Show &number of lines"                 [YesNoStr(ShowLines)   : 5],
       bToggleLines()       , CloseAllAfter
end bStatusLineToggles

menu bTabSettings()
   history
   title="Tab settings"
   "&Tab width"                            [Query(TabWidth)      : 5],
       Set(TabWidth, ReadNum(Query(TabWidth))), CloseAllAfter
   "Tabs e&xpanded (display only)"         [YesNoStr(Query(ExpandTabs)) : 5],
       Toggle(ExpandTabs)   , CloseAllAfter
end bTabSettings

menu bPositioning()
   history
   title="Positioning, search options"
   "Left and right &scroll increment"      [ScrollInc            : 5],
       sScrollInc()         , DontClose
   "&Cont. Scroll delay (18ths/sec, 1-40)" [ScrollDelay          : 5],
       sScrollDelay()       , DontClose
   "&Find row position"                    [FindRow              : 5],
       bSetFindRow()        , DontClose
   "Sound &beep on failed finds"           [YesNoStr(Query(Beep)): 5],
       bToggleBeep()        , DontClose
end bPositioning

menu bColorSet()
   history
   title="Display and Colors"
   "Display &mode"                         [bHexText()            : 5],
       bToggleDisplayMode() , CloseAllAfter
   "Color of &normal text"                 [Query(TextAttr)      : 5],
       Set(TextAttr, ReadNum(Query(TextAttr))), CloseAllAfter
   "Color of &status lines and menus"      [Query(StatusLineAttr): 5],
       Set(StatusLineAttr, ReadNum(Query(StatusLineAttr))), CloseAllAfter
   "Color of &highlighted (found) text"    [Query(HiLiteAttr)    : 5],
       Set(HiLiteAttr, ReadNum(Query(HiLiteAttr))), DontClose
end bColorSet

menu bExitMisc()
   history
   title="Exit and miscellaneous options"
   "Restore &original screen on exit"      [YesNoStr(RestoreScreen) : 5],
       bToggleRS()          , DontClose
   "Enable &shell to DOS"                  [YesNoStr(ShellEnabled) : 5],
       bToggleShellEnabled(), DontClose
   "Modem &COM Port"                       [ModemCOMPort           : 5],
       bSetModemCOMPort()   , DontClose
end bExitMisc

// ************************************************************************
//  Full blown interactive menu for options.  Like LISTOPT, I suppose.    *
// ************************************************************************
integer QuitConfig
proc bQuitConfig()
  QuitConfig=TRUE
end bQuitConfig

menu bBrowseConfigMenu()   // menus
    history
    title="BROWSE configuration menu"
    x=3
    y=3

   "&Quit BROWSE interactive configuration  "  , bQuitConfig(), CloseAfter
   "&Clone settings to: "  [browseini:26]      , bWriteBINI() , DontClose
   "&Undo changes  (restore saved BROWSE.INI options)", bRestoreInit()
                                                              , CloseAfter
   "Change current settings"            ,                     , Divide

   "&Status line toggles  "            , bStatusLineToggles(), DontClose
   "&Tab settings  "                   , bTabSettings()      , DontClose
   "&Positioning, search options  "    , bPositioning()      , DontClose
   "&Display and Colors  "             , bColorSet()         , DontClose
   "&Exit and miscellaneous options  " , bExitMisc()         , DontClose

end bBrowseConfigMenu

// Call interactive menu, and force all variables to be updated.
proc bBrowseConfig()
  QuitConfig=FALSE
  repeat
    bBrowseConfigMenu()
    bStandardizeAttributes()
    ExecHook(_AFTER_UPDATE_STATUSLINE_)
    ExecHook(_AFTER_COMMAND_)
  until (MenuKey() == <Escape>) or QuitConfig
end bBrowseConfig

// Use mouse to page up or page down
proc bMousePage()
integer MiddleOfWindow=(Query(WindowRows) / 2), MouseRow
  MouseRow=Query(MouseY)-WhereYAbs()  // Mouse Abs pos - Window Abs pos
  if MouseRow >= MiddleOfWindow
    bPageDown()
  else
    bPageUp()
  endif
end bMousePage

// Gives the left mouse button ability to handle windows, and paging
proc bLeftBtn()
  bUpperLeft()
  MouseStatus()   // get current state
  case MouseHotSpot()
    when _NONE_
      bMousePage()
    when _MOUSE_MARKING_
      if MouseWindowID() <> WindowID()
        GotoWindow(MouseWindowID())
      else
        bMousePage()
      endif
    otherwise ProcessHotSpot()
  endcase
end bLeftBtn

#include ['browse.hlp']        // Quick help file
#include ['browse.key']        // Key file

// ************************************************************************
// Exit file and lose changes
proc bLoseChanges()
  if AbandonFile()
     FirstFile=GetBufferID()
  endif
  if FirstFile==0
     Exit()
  endif
end bLoseChanges

// Ensure files are saved or exited before Browsing
menu bSaveFirstMenu()
    title="Save or abandon?"
    x=10
    y=2
    NoEscape
    NoKeys
    "&Save file"     ,  SaveFile()
    "&Abandon file"  , bLoseChanges()
    "&Cancel"
end bSaveFirstMenu

/**************************************************************************/
/* …ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕª */
/* ∫ mBrowse is the command center.  Startup and exit are handled here. ∫ */
/* ∫ Each subroutine of mBrowse is described as it appears.             ∫ */
/* »ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº */
/**************************************************************************/

proc mBrowse()
// ************************************************************************
//  Store variables which are in effect before starting Browse, so they   *
//  may be restored upon exiting Browse mode (either exiting the files    *
//  or changing to Edit mode).                                            *
// ************************************************************************
integer Insert            =Set(Insert,OFF),
        Cursor            =Set(Cursor,OFF),
        CenterFinds       =Set(CenterFinds,OFF),
        ExpandTabs        =Query(ExpandTabs),
        TabWidth          =Query(TabWidth),
        Beep              =Query(Beep),

        QuitToPrompt      =Query(QuitToPrompt),
        StatusLineAtTop   =Set(StatusLineAtTop,ON),
        StatusLineUpdating=Set(StatusLineUpdating,ON),
        ShowHelpLine      =Set(ShowHelpLine,ON),

        CursorAttr        =Query(CursorAttr),
        TextAttr          =Query(TextAttr),
        HiLiteAttr        =Query(HiLiteAttr),
        StatusLineAttr    =Query(StatusLineAttr),

        MenuSelectAttr    =Query(MenuSelectAttr),
        MenuSelectLtrAttr =Query(MenuSelectLtrAttr),
        MenuTextAttr      =Query(MenuTextAttr),
        MenuTextLtrAttr   =Query(MenuTextLtrAttr),
        MenuBorderAttr    =Query(MenuBorderAttr)

// ************************************************************************
//  Make sure at least one file is loaded.                                *
// ************************************************************************
  if NOT Hook(_PICKFILESTARTUP_, PickFileStartUp)
     Warn('Hook() for pick file start up unsuccessful.  Continuing anyway.')
  endif
  if (NumFiles() == 1) AND (Pos('unnamed', CurrFileName()))
     Set(QuitToPrompt,ON)
     AbandonFile()
     ClrScr()
     bChooseFile()
     if NumFiles() == 0
        Goto PurgeBrowse
     endif
  endif

// ************************************************************************
//  Then make sure all loaded files are saved (or exited and not loaded). *
// ************************************************************************
  FirstFile=GetBufferID()
  repeat
     if FileChanged() AND BufferType()==_NORMAL_ AND CurrFileName() <> "[<stdin>]"
        UpdateDisplay(_ALL_WINDOWS_REFRESH_)
        Message('Warning: ['+SplitPath(CurrFileName(),_NAME_|_EXT_)+'] must be saved or abandoned before browsing!')
        bSaveFirstMenu()
        UpdateDisplay(_STATUSLINE_REFRESH_)
        if MenuStr(bSaveFirstMenu,MenuOption())=="Cancel"
           GotoBufferID(FirstFile)
           Goto PurgeBrowse
        endif
     endif
     NextFile()
  until GetBufferID()==FirstFile

// ************************************************************************
//  Enable Browse keys exclusively, since the editor should be disabled.  *
// ************************************************************************
  if Enable(BrowseKeys,_EXCLUSIVE_)

// ************************************************************************
//  The procedure to get the variables from Browse.ini                    *
// ************************************************************************
     bBrowseInit()

// ************************************************************************
//  Set up all the Hooks, and init the file-specific vars for current one *
// ************************************************************************
     if NOT Hook(_ON_CHANGING_FILES_, bInitFile)
        Warn('Hook() for file initialization unsuccessful.  Continuing anyway.')
     endif
     bInitFile()  // Initialize variables for current file
     if NOT Hook(_AFTER_UPDATE_DISPLAY_, bCheckPrintQueue)
        Warn('Hook() for continuous print unsuccessful.  Continuing anyway.')
     endif
     if NOT (Hook(_AFTER_UPDATE_STATUSLINE_, bStatusLine))
        Warn('Hook() for custom status line unsuccessful.  Continuing anyway.')
     endif

// ************************************************************************
//  Set up events associated with showing ruler and toggles               *
// ************************************************************************
     ShowRuler  =iif(ShowRuler,FALSE,TRUE)    bToggleRuler()
     ShowToggles=iif(ShowToggles,FALSE,TRUE)  bToggleHelpLine()
     AskToWrap()  // Wrap long lines in text files on startup?

// ************************************************************************
//  Process() signals the end of the set up, and the beginning of Browse  *
// ************************************************************************
     Process()

// ************************************************************************
//  Once Process() executes, we only return here if exiting Browse mode   *
// ************************************************************************
     Disable(BrowseKeys)

// ************************************************************************
//  Reset all editor variables to what they were on startup               *
// ************************************************************************
       Set(CursorAttr,       CursorAttr)
       Set(TextAttr,         TextAttr)
       Set(HiLiteAttr,       HiLiteAttr)
       Set(StatusLineAttr,   StatusLineAttr)

       Set(MenuSelectAttr,   MenuSelectAttr)
       Set(MenuSelectLtrAttr,MenuSelectLtrAttr)
       Set(MenuTextAttr,     MenuTextAttr)
       Set(MenuTextLtrAttr,  MenuTextLtrAttr)
       Set(MenuBorderAttr,   MenuBorderAttr)

       Set(QuitToPrompt,     QuitToPrompt)
       DisplayMode          (Display_Mode)
       Set(TabWidth,         TabWidth)
       Set(ExpandTabs,       ExpandTabs)
       Set(Beep,             Beep)
       if Printing==TRUE ClosePrint() endif
  endif

// ************************************************************************
//  A label to go to if Browse mode is cancelled or not possible          *
// ************************************************************************
PurgeBrowse:

// ************************************************************************
//  Quit if no files are loaded                                           *
// ************************************************************************
  if (NumFiles() < 1)
     AbandonEditor()
  endif

// ************************************************************************
//  Restore some more editor variables (which were set in declarations)   *
// ************************************************************************
  Set(Insert, Insert)
  Set(Cursor, Cursor)
  Set(CenterFinds, CenterFinds)
  Set(StatusLineAtTop, StatusLineAtTop)
  Set(StatusLineUpdating, StatusLineUpdating)
  Set(ShowHelpLine, ShowHelpLine)

// ************************************************************************
//  PurgeMacro is maybe not necessary but it sure made debugging easier!  *
// ************************************************************************
  PurgeMacro('browse')
end mBrowse

// ************************************************************************
//  I left all but the one procedure out of main() so that it -could- be  *
//  started by TSESTART.MAC by removing "main()" and "PurgeMacro()", and  *
//  and including BROWSE.SI in TSESTART.S (and recompiling TSESTART).     *
//                                                                        *
//  The BEST way to have Browse accessible is bind "ExecMacro('browse')"  *
//  to your desired key, and burn that key binding in to TSE.             *
// ************************************************************************
proc main()
  mBrowse()
end main
