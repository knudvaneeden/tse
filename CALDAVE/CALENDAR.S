// CALENDAR.S
// Original by Richard Hendricks
// Modifications by Dave Navarro, Jr.
// Last Modification: October 25, 1993

// Modifications:
//   DNJ 10/25/93 - Removed support for multiple calendar types.
//                  Uses getch() to get keyboard input.
//                  If <ENTER> is pressed, highlighted date is inserted into
//                  document at current cursor position.
//

forward proc PutSingleMonth( integer month,
                             integer day,
                             integer year )

forward proc DisplayCalendar()

Constant SingleMonth = 1
Constant TinySingleMonth = 2

integer CurrYear, CurrMonth, CurrDay, CurrDayOfWeek

integer NormalAttr = Color( White on Blue ),
        TodayAttr = Color( Black on White )

string proc DayThString( integer day )
  case day
    when 1, 21, 31
      return( format(day:2)+"st" )
    when 2, 22
      return( format(day:2)+"nd" )
    when 3, 23
      return( format(day:2)+"rd" )
  endcase
      return( format(day:2)+"th" )
end DayThString

string proc MonthNameString( integer month )
  string MonthNames[110] = "January  February March    April    May      June     July     August   SeptemberOctober  November December " // 9 characters each
  return( substr( MonthNames, ((Month-1)*9)+1, 9 ) )
end MonthNameString

integer proc DayOfWeekVal( integer month, integer day, integer year )
  // 1-Sunday, 2-Monday, 3-Tuesday,.. 7-Saturday
  string DayOfWeek[20]
  Integer DaysSince

  if(Month < 3)
   year = year - 1
   Month = Month + 12
  endif

  DaysSince = (year / 400 - year / 100 + year / 4 + year + Month * 3)
  if(Month > 4)
      DaysSince = DaysSince - 1
  endif
  if(Month > 6)
      DaysSince = DaysSince - 1
  endif
  if(Month > 9)
      DaysSince = DaysSince - 1
  endif
  if (Month > 11)
      DaysSince = DaysSince - 1
  endif
  DaysSince = DaysSince + Day

  return ( ( DaysSince mod 7 ) + 1 )
end DayOfWeekVal

integer proc isLeapYear( string Year )
  integer nyear

  nyear = val( year )
  return( iif( nyear mod 4 or (not nyear mod 100 and nyear mod 400),
                false, true ) )
end isLeapYear

integer proc DaysInMonthVal( integer month, integer year )
  string MonthDays[24]="312831303130313130313031"
  if month <> 2
    return( val( substr( MonthDays, ((Month-1)*2)+1, 2 ) ) )
  endif
  return( iif( isLeapYear( str(Year) ), 29, 28 ) )
end

proc DisplayCalendar()
  PutSingleMonth( CurrMonth, CurrDay, CurrYear )
end DisplayCalendar

proc Today()
  GetDate( CurrMonth, CurrDay, CurrYear, CurrDayOfWeek )
  DisplayCalendar()
end Today

proc NextYear()
  CurrYear = CurrYear + 1
  DisplayCalendar()
end NextYear

proc PrevYear()
  CurrYear = CurrYear - 1
  DisplayCalendar()
end PrevYear

proc NextMonth()
  CurrMonth = CurrMonth + 1
  CurrYear  = iif( CurrMonth > 12, CurrYear+1, CurrYear )
  CurrMonth = iif( CurrMonth > 12, 1, CurrMonth )
  CurrDay = iif( CurrDay > DaysInMonthVal( CurrMonth, CurrYear ),
                           DaysInMonthVal( CurrMonth, CurrYear ), CurrDay )
  DisplayCalendar()
end NextMonth

proc PrevMonth()
  CurrMonth = CurrMonth - 1
  CurrYear  = iif( CurrMonth < 1, CurrYear-1, CurrYear )
  CurrMonth = iif( CurrMonth < 1, 12, CurrMonth )
  CurrDay = iif( CurrDay > DaysInMonthVal( CurrMonth, CurrYear ),
                           DaysInMonthVal( CurrMonth, CurrYear ), CurrDay )
  DisplayCalendar()
end PrevMonth

proc NextDay()
  CurrDay = CurrDay + 1
  if CurrDay > DaysInMonthVal( CurrMonth, CurrYear )
    CurrMonth = CurrMonth + 1
    CurrDay = 1
  endif
  CurrYear  = iif( CurrMonth > 12, CurrYear+1, CurrYear )
  CurrMonth = iif( CurrMonth > 12, 1, CurrMonth )
  DisplayCalendar()
end NextDay

proc PrevDay()
  CurrDay = CurrDay - 1
  if CurrDay < 1
    CurrMonth = CurrMonth - 1
    CurrYear  = iif( CurrMonth < 1, CurrYear-1, CurrYear )
    CurrMonth = iif( CurrMonth < 1, 12, CurrMonth )
    CurrDay = DaysInMonthVal( CurrMonth, CurrYear )
  endif
  DisplayCalendar()
end PrevDay

proc PutSingleMonth( integer month, integer day, integer year )
  integer MonthDayOfWeek, DaysInMonth,
          d, c_day, c_week
  String           // Month        Day         Year
    MonthCal01[40]="ÕÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¸",  // 36 X 18
    MonthCal02[40]="³                                  ³",
    MonthCal03[40]="ÔÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¾",
    MonthCal04[40]="ÚÄÄÄÄÂÄÄÄÄÂÄÄÄÄÂÄÄÄÄÂÄÄÄÄÂÄÄÄÄÂÄÄÄÄ¿",
    MonthCal05[40]="³ Su ³ Mo ³ Tu ³ We ³ Th ³ Fr ³ Sa ³",
    MonthCal06[40]="ÃÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄ´",
    MonthCal07[40]="³    ³    ³    ³    ³    ³    ³    ³",
    MonthCal08[40]="ÃÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄ´",
    MonthCal09[40]="³    ³    ³    ³    ³    ³    ³    ³",
    MonthCal10[40]="ÃÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄ´",
    MonthCal11[40]="³    ³    ³    ³    ³    ³    ³    ³",
    MonthCal12[40]="ÃÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄ´",
    MonthCal13[40]="³    ³    ³    ³    ³    ³    ³    ³",
    MonthCal14[40]="ÃÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄ´",
    MonthCal15[40]="³    ³    ³    ³    ³    ³    ³    ³",
    MonthCal16[40]="ÃÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄ´",
    MonthCal17[40]="³    ³    ³    ³    ³    ³    ³    ³",
    MonthCal18[40]="ÀÄÄÄÄÁÄÄÄÄÁÄÄÄÄÁÄÄÄÄÁÄÄÄÄÁÄÄÄÄÁÄÄÄÄÙ"

  Window( 23, 3, 23+35, 3+17 )
  VHomeCursor()
  ClrScr()
  Set( Attr, NormalAttr )
  Set( Cursor, Off )
  Write( MonthCal01 ) VGotoXY( 1, 2 )
  Write( MonthCal02 ) VGotoXY( 1, 3 )
  Write( MonthCal03 ) VGotoXY( 1, 4 )
  Write( MonthCal04 ) VGotoXY( 1, 5 )
  Write( MonthCal05 ) VGotoXY( 1, 6 )
  Write( MonthCal06 ) VGotoXY( 1, 7 )
  Write( MonthCal07 ) VGotoXY( 1, 8 )
  Write( MonthCal08 ) VGotoXY( 1, 9 )
  Write( MonthCal09 ) VGotoXY( 1, 10)
  Write( MonthCal10 ) VGotoXY( 1, 11)
  Write( MonthCal11 ) VGotoXY( 1, 12)
  Write( MonthCal12 ) VGotoXY( 1, 13)
  Write( MonthCal13 ) VGotoXY( 1, 14)
  Write( MonthCal14 ) VGotoXY( 1, 15)
  Write( MonthCal15 ) VGotoXY( 1, 16)
  Write( MonthCal16 ) VGotoXY( 1, 17)
  Write( MonthCal17 ) VGotoXY( 1, 18)
  Write( MonthCal18 ) VGotoXY( 1, 19)
  VGotoXY( 4, 2 )
  Write( MonthNameString( Month ) )
  VGotoXY( 30, 2 )
  Write( Str( Year ) )
  VGotoXY( 17, 2 )
  Write( DayThString( Day ) )  // 1st, 2nd, 3rd, 4th....
  MonthDayOfWeek = DayOfWeekVal( month, 1, year )  // First Day Of Month
  DaysInMonth = DaysInMonthVal( month, year )

  d = 1
  c_day  = MonthDayOfWeek
  c_week = 1
  while d <= DaysInMonth
    VGotoXY( iif( c_day == 1, 3, (c_day*5)-2 ), iif( c_week == 1, 7, (c_week*2)+5 ) )
    Write( Format( d:2 ) )
    if d == Day
      VGotoXY( iif( c_day == 1, 3, (c_day*5)-2 ), iif( c_week == 1, 7, (c_week*2)+5 ) )
      PutAttr( TodayAttr, 2 )
    endif
    c_day = c_day + 1
    if c_day > 7
      c_day = 1
      c_week = c_week + 1
    endif
    d = d + 1
  endwhile
  Set( Cursor, On )
end PutSingleMonth

proc Calendar()
  integer ch
  string  month_name[9] = ''
  GetDate( CurrMonth, CurrDay, CurrYear, CurrDayOfWeek )

  DisplayCalendar()
  loop
    ch = getkey()
    case ch
      when <Alt T>
        Today()
      when <CursorLeft>
        PrevDay()
      when <CursorRight>
        NextDay()
      when <CursorUp>
        PrevMonth()
      when <CursorDown>
        NextMonth()
      when <PgDn>
        PrevYear()
      when <PgUp>
        NextYear()
      when <Home>
        CurrDay = 1
        DisplayCalendar()
      when <End>
        CurrDay = DaysInMonthVal( CurrMonth, CurrYear )
        DisplayCalendar()
      when <Ctrl Home>
        CurrMonth = 1
        CurrDay = 1
        DisplayCalendar()
      when <Ctrl End>
        CurrMonth = 12
        CurrDay = 31
        DisplayCalendar()
      when <Enter>
        FullWindow()
        UpdateDisplay(_All_Windows_Refresh_)
        case CurrMonth
          when  1 month_name = 'January'
          when  2 month_name = 'February'
          when  3 month_name = 'March'
          when  4 month_name = 'April'
          when  5 month_name = 'May'
          when  6 month_name = 'June'
          when  7 month_name = 'July'
          when  8 month_name = 'August'
          when  9 month_name = 'September'
          when 10 month_name = 'October'
          when 11 month_name = 'November'
          when 12 month_name = 'December'
        endcase
        InsertText(Format(month_name,' ',CurrDay,', ',CurrYear))
        break
      when <Escape>
        FullWindow()
        UpdateDisplay(_All_Windows_Refresh_)
        break
    endcase
  endloop
end Calendar
// end-of-file CALENDAR.S
