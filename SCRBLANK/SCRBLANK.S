/***************************************************************
 Program: scrblank.s
 Author : Bruce Riggins
 Date   : 12/28/93
 Purpose: Blank the TSE screen after a period of idleness.

          Shows the time in large block letters on the screen.
          Animation is also implemented, though turned off with the
          variable isAnimation.

          The time delay is configurable, and will be saved on exiting
          the editor if you choose.

          The time is found in the SCRBLANK.INI file in the LoadDir() +
          "\mac\" subdirectory, and is in minutes.  The macro actually
          maintains the time internally in seconds, though.

          Requires the BIGCHAR.MAC macro to be available.

****************************************************************/

constant IDLE_TIME = 600         // idle time in seconds (10 minutes)
constant REDRAW_INTERVAL = 2    // in seconds
constant ANIMATION_INTERVAL = 1   // in ticks
constant ANIMATION_COLOR = Color(Blue on Yellow)
constant BLANK_COLOR = Color(Black on Black)
constant MESSAGE_COLOR = Color(White on Black )
constant TORIGHT = TRUE
constant TOLEFT = FALSE
constant MESSAGE_HEIGHT = 8
constant MESSAGE_WIDTH = 48
constant ROW_INCREMENT = 1
constant COL_INCREMENT = 1
constant CHRWIDTH = 6

integer Total,
        IncAValue,
        IncBValue,
        isAnimation = FALSE,
        LastADrawTime,
        LastBDrawTime,
        ClockCnt,
        direction = TOLEFT

integer Blanker_Interval = IDLE_TIME,       // # of seconds between saves
        TimeChanged = FALSE
//integer bRow = 1,
//        bCol = 1


string  BlankScrnMessage[255] = "",
        RevAnimationStr[255]

integer proc CurrTimeInSeconds()
  integer hours,
          minutes,
          seconds,
          hundredths,
          subtotal

  GetTime(hours,minutes,seconds,hundredths)

  subtotal = (((hours * 60) + minutes) * 60) + seconds

  return (subtotal)
end

// Blank the screen
proc BlankScreen()
  integer row

  row = Query(ScreenRows)
  while row
    vGotoXY(1,row)
    PutAttr(BLANK_COLOR,Query(ScreenCols))
    row = row - 1
  endwhile

end

proc IncrementAnim ( var integer bCol, var integer bRow, integer amount )
  integer newpos = (bRow * Query(ScreenCols)) + (bCol-1) + amount

  if newpos < 0
    newpos = newpos + (Query(ScreenCols) * Query(ScreenRows))
  endif

  bRow = newpos / Query(ScreenCols)
  bCol = newpos mod Query(ScreenCols) + 1

  if bRow > Query(ScreenRows)
    bRow = 1
  endif

  if bRow < 1
    bRow = Query(ScreenRows)
  endif

  bCol = Abs(bCol)

end

proc IncrementMsg ( var integer bCol, var integer bRow, integer amount )
  integer newpos = (bRow * Query(ScreenCols)) + (bCol-1) + amount

  if newpos < 0
    newpos = newpos + (Query(ScreenCols) * Query(ScreenRows))
  endif

  bRow = newpos / (Query(ScreenCols) / ROW_INCREMENT)

  if bRow > Query(ScreenRows) - MESSAGE_HEIGHT
    bRow = ROW_INCREMENT

  elseif bRow < 1
    bRow = Query(ScreenRows) - MESSAGE_HEIGHT
  endif

  bCol = newpos mod Query(ScreenCols) + COL_INCREMENT

  if bCol + MESSAGE_WIDTH > Query(ScreenCols)
    bCol = 1
  elseif bCol < 1
    bCol = Query(ScreenCols) - MESSAGE_WIDTH
  endif

  bCol = Abs(bCol)

end

string proc BuildScrnMsg()
//  return( Format(" The time is ",GetTimeStr()," on ",GetDateStr()," "))
  return(GetTimeStr())
end

proc PutAnimationStr (  integer x, integer y, string s, integer attr,
                        integer direction)
  integer strlen,OldAttr

  if direction == TOLEFT
    RevAnimationStr = s
  else
    strlen = Length(s)
    RevAnimationStr = ""
    while strlen
      RevAnimationStr = RevAnimationStr + s[strlen]
      strlen = strlen - 1
    endwhile
    x = x - Length(RevAnimationStr) + 1
  endif

  OldAttr = Set(Attr,attr)
  vGotoXY(x,y)
  PutStr(RevAnimationStr)
  Set(Attr,OldAttr)

end

proc WriteFlowMsg(integer x, integer y, string msg, integer attr)
  integer ColsToEnd,
          Segment1Len,
          Segment2Len,
          Seg2X,
          OldAttr = Set(Attr,attr)


  if direction == TORIGHT
    ColsToEnd = x
    Seg2X = 1
  else
    ColsToEnd = Query(ScreenCols) - x + 1
    Seg2X = Query(ScreenCols)
  endif

  Segment1Len = iif ( Length(msg) > ColsToEnd,
                      ColsToEnd,
                      length(msg) )
  Segment2Len = iif ( Segment1Len < Length(msg),
                      Length(msg) - Segment1Len - 1,
                      0 )

  PutAnimationStr(x,y,Substr(msg,1,Segment1Len),attr,direction)

  if Length(msg) > ColsToEnd

    IncrementAnim(Seg2X,y,Query(ScreenCols))

    vGotoXY(Seg2X,y)
    PutChar(msg[Segment1Len + 1])

    if Segment2Len
      IncrementAnim(Seg2X,y,Query(ScreenCols))
      PutAnimationStr(Seg2X,y,SubStr(msg,Segment1Len + 1,Segment2Len),attr,
                      iif(direction==TORIGHT,TOLEFT,TORIGHT))
    endif

  endif
  Set(Attr,OldAttr)

end

proc WriteAnimation(var integer x, var integer y, integer attr)
  string AnimateStr[50] = "*********===============---------------------"

  // Draw the animation at the local location

  WriteFlowMsg(x,y,AnimateStr,attr)

end

proc WriteBlankerMsg(var integer x, var integer y, integer attr)
  integer OldAttr = Set(Attr,attr)

  BlankScrnMessage = BuildScrnMsg()

//  // Write the main message at the system location
//  if x + Length(BlankScrnMessage) > Query(ScreenCols)
//    x = Query(ScreenCols)
//    IncrementPos(x,y,IncBValue)
//  endif
//
//  vGotoXY(x,y)
//  PutStr(BlankScrnMessage)

  GotoXY(x,y)
  SetGlobalStr("BigStr",BuildScrnMsg())
  ExecMacro("BigChar")


  Set(Attr,OldAttr)
end

//proc WriteBlankerMsg(var integer x, var integer y)
//
//  if x + Length(BlankScrnMessage) > Query(ScreenCols)
//    x = Query(ScreenCols)
//    IncrementPos(x,y)
//  endif
//
//  vGotoXY(x,y)
//  PutStr(BlankScrnMessage)
//
//end

//proc WriteBlankerMsg(integer x, integer y)
//  integer ColsToEnd = Query(ScreenCols) - x + 1
//
//  vGotoXY(x,y)
//  PutStr(BlankScrnMessage)
//
//  if Length(BlankScrnMessage) > ColsToEnd
//
//    vGotoXY(1,iif(y==Query(ScreenRows),1,y+1))
//    PutStr(SubStr(BlankScrnMessage,ColsToEnd + 1,Length(BlankScrnMessage)))
//
//  endif
//
//end


proc DrawAnimationMsg(var integer aCol,var integer aRow)

    // redraw the animation

    WriteAnimation(aCol,aRow,BLANK_COLOR)

    IncrementAnim(aCol,aRow,IncAValue)
    WriteAnimation(aCol,aRow,ANIMATION_COLOR)

    if aCol == 1 and direction == TOLEFT
      WriteAnimation(aCol,aRow,BLANK_COLOR)
      direction = TORIGHT
      IncAVAlue = 1
      aRow = aRow - 2
      if aRow < 1
        aRow = Query(ScreenRows)
      endif
    elseif aCol == Query(ScreenCols) and direction == TORIGHT
      WriteAnimation(aCol,aRow,BLANK_COLOR) // to take care of problem with
                                            // leaving bits of the tail on the
                                            // screen when we increment the
                                            // row by 2
      direction = TOLEFT
      IncAValue = -1
      aRow = aRow - 2
      if aRow < 1
        aRow = Query(ScreenRows)
      endif
    endif
end

proc DrawStaticMsg(var integer bCol,var integer bRow)
    // redraw the message

    WriteBlankerMsg(bCol,bRow,BLANK_COLOR)

    bRow = bRow + 1
    IncrementMsg(bCol,bRow,IncBValue)
    WriteBlankerMsg(bCol,bRow,MESSAGE_COLOR)

end

proc DrawBlankerMsg(var integer bCol,var integer bRow,
                    var integer aCol,var integer aRow)

  integer CurrTime = CurrTimeInSeconds()

  if ClockCnt <> CurrTime
    WriteBlankerMsg(bCol,bRow,MESSAGE_COLOR)
    ClockCnt = CurrTime
  endif

  if LastBDrawTime + REDRAW_INTERVAL < CurrTime

    DrawStaticMsg(bCol,bRow)
    LastBDrawTime = CurrTime

  endif

  // Handle midnight shift
  if LastBDrawTime > CurrTime
    LastBDrawTime = CurrTime
  endif

  if (LastADrawTime + ANIMATION_INTERVAL) < GetClockTicks() and isAnimation
    DrawAnimationMsg(aCol,aRow)
    LastADrawTime = GetClockTicks()
  endif

  // Handle midnight shift
  if LastADrawTime > GetClockTicks()
    LastADrawTime = GetClockTicks()
  endif

end

proc doBlankScreen()
  integer bCol,bRow,aCol,aRow

  PushPosition()

  HideMouse()
  Set(Cursor,OFF)
  BlankScreen()
  BlankScrnMessage = BuildScrnMsg()
  bCol = (Query(ScreenCols) - (Length(BlankScrnMessage) * CHRWIDTH)) / 2
  bRow = (Query(ScreenRows) - MESSAGE_HEIGHT) / 2
  aCol = Query(ScreenCols)
  aRow = Query(ScreenRows) - 3
  LastADrawTime = GetClockTicks()
  LastBDrawTime = CurrTimeInSeconds() - REDRAW_INTERVAL  // force first draw
  ClockCnt = LastBDrawTime

  IncAValue = -1
  IncBValue = 1

  // Wait for user input

  while not KeyPressed()
    DrawBlankerMsg(bCol,bRow,aCol,aRow)
  endwhile

  // Get rid of key pressed
  GetKey()

  // Redraw the screen

  Set(Cursor,ON)
  ShowMouse()
  UpdateDisplay(_ALL_WINDOWS_REFRESH_ | _HELPLINE_REFRESH_)

  // Reseed the time counter
  Total = CurrTimeInSeconds()

  PopPosition()
end

proc Idle()
  if Blanker_Interval and ((Total + Blanker_Interval) < CurrTimeInSeconds())
    doBlankScreen()
  endif

  // Handle shift at midnight

  if Total > CurrTimeInSeconds()
    Total = CurrTimeInSeconds()
  endif
end


// save last Screen Blanker time interval to control file
proc SaveScreenBlankerTime()
  integer setbak = Set(MakeBackups,OFF)

  if CreateBuffer(loaddir()+"\mac\scrblank.ini")
    InsertText(Format(Blanker_Interval/60))
    SaveAndQuitFile()
  endif
  Set(MakeBackups,setbak)
end

// load last auto save time interval from control file
proc LoadScreenBlankerTime()
  string fn[80] = loaddir()+"\mac\scrblank.ini"

  if FileExists(fn) and EditFile(fn)
    Blanker_Interval = Val(GetText(PosFirstNonWhite(),CurrLineLen())) * 60
    AbandonFile()
  endif
end

public proc Set_Blanker_Interval()
  string Blanker_Interval_Min[3] = Str(Blanker_Interval / 60)

  if Ask("Interval for Screen Blanker (in minutes): ",Blanker_Interval_Min)
    Blanker_Interval = Val(Blanker_Interval_Min) * 60
    TimeChanged = TRUE
  endif
end

public proc BlankScreenNow()
  doBlankScreen()
end

proc AfterCommand()
  Total = CurrTimeInSeconds()
end

proc WhenLoaded()
  Hook(_AFTER_COMMAND_,AfterCommand)
  Hook(_IDLE_,Idle)
  Hook(_ON_ABANDON_EDITOR_,WhenPurged)

  LoadScreenBlankerTime()
  AfterCommand()     // force initialization of blanker
end

proc WhenPurged()
  if TimeChanged and
      YesNo("Screen Blanker time has changed.  Do you wish to save?") == 1
    SaveScreenBlankerTime()
  endif
end


//<F12> doblankscreen()

