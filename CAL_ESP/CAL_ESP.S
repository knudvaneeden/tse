/***********************************************************************
  Cal_Esp     Displays a visual, changeable calendar

  Author:     Richard Hendricks

  Date:       Apr  5, 1993 - original release
              Apr  8, 1993 - 3 months at a time calendar. The Previous and
                             Next Months, always started on the same day
                             of the week as the current month. This has
                             been fixed in this release.
              Aug 30, 1994 - Modified to correct incompatibility with
                             COLORS.  Added a Help Line
              27/07/95     - several modifications to the keyboard handling,
                             and adapted to spanish calendars (i.e., weeks
                             begin in Monday and end in Sunday). All this
                             modifications by Miguel Farah.
              26/02/96     - added previous and next century, what I call
                             "pseudo-today", and some comments preparing this
                             file to be uploaded for everyone to use it. Also
                             corrected the IsLeapYear() funtion, which was
                             buggy.

  Overview:

  Three calendar displays are available -- Medium-Size Single Month,
  Three Months at a Time, and a Small Single Month. (Press <Alt C> to
  toggle between them.)

  A small calendar can be inserted into the current file by pressing
  <Alt I>. Here is a sample:

       +--------------------+
       |26 de febrero   1996|
       |lu ma mi ju vi sa do|
       |          1  2  3  4|
       | 5  6  7  8  9 10 11|
       |12 13 14 15 16 17 18|
       |19 20 21 22 23 24 25|
       [26]27 28 29         |
       +--------------------+

Days, months and everything is in spanish because I'm a spanish speaker... so
there. Obviously, you're aloud to modify it (just as I did...).
- Weeks begin on Monday, not on Sunday.
- <up> and <down> now move between weeks - quite practical (at least for me).
- <grey+> and <grey-> now move between years.
- <ctrl grey+> and <ctrl grey-> now move between centuries.
- No provision is made (yet) to correct pre-Gregorian calendar dates, so any
  date before 15/october/1582 has a incorrect day of week!


  Keys:
      Next Day                <CursorRight>
      Previous Day            <CursorLeft>
      ÿ
      Next Week                 <CursorDown> // new: moves to same day
      Previous Week             <CursorUp>   //      in next/prev week
      ÿ
      Next Month                <PgDn>, <SpaceBar> or <Enter>
      Previous Month            <PgUp> or <BackSpace>
      ÿ
      Next Year                 <grey+>      // new: add a year to current date
      Previous Year             <grey->      // new: substract a year
      ÿ
      Next Century              <ctrl grey+> // new: add 100 years to curr.date
      Previous Century          <ctrl grey-> // new: substract 100 years
      ÿ
      First Day Of Month        <Home>
      Last Day Of Month         <End>
      ÿ
      First Day Of Year         <Ctrl Home>
      Last Day Of Year          <Ctrl End>
      ÿ
      Today ("Hoy")             <Alt H>
      Pseudo-Today              <Ctrl H> // new: actual date, in the calendar's
                                         //      current year
      Change Calendar Type      <Alt C>
      Insert Calendar into Text <Alt I>
      Exit Calendar             <Escape>

 ***********************************************************************/


forward proc PutSingleMonth( integer month,
                             integer day,
                             integer year )

forward proc PutTinySingleMonth( integer month,
                                 integer day,
                                 integer year )

forward proc PutThreeMonths( integer month,
                             integer day,
                             integer year )

forward proc InsertTinySingleMonth( integer month,
                                    integer day,
                                    integer year )

forward proc DisplayCalendar()

Constant SingleMonth = 1
Constant TinySingleMonth = 2
Constant ThreeMonths = 3

integer CurrYear, CurrMonth, CurrDay, CurrDayOfWeek
integer CalType = SingleMonth

integer NormalAttr = Color( Black on White ),
        TodayAttr = Color( Red on White )

integer dummy

string proc DayThString( integer day )
  return("* "+format(day:2)+" *")
end DayThString

string proc MonthNameString( integer month )
  string MonthNames[110] = "enero    febrero  marzo    abril    mayo     junio    julio    agosto   setiembreoctubre  noviembrediciembre" // 9 characters each
  return( substr( MonthNames, ((Month-1)*9)+1, 9 ) )
end MonthNameString

integer proc DayOfWeekVal( integer month, integer day, integer year )
  // 1-Monday, 2-Tuesday,.. 6-Saturday, 7-Sunday
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

  return ( ( DaysSince mod 7 ) )
end DayOfWeekVal

integer proc isLeapYear( string Year )
  integer nyear

  nyear = val( year )
  return( iif( (nyear mod 4) or ((not (nyear mod 100)) and (nyear mod 400)),
                false, true ) )
end isLeapYear

integer proc DaysInMonthVal( integer month, integer year )
  string MonthDays[24]="312831303130313130313031"

  if month <> 2
    return( val( substr( MonthDays, ((Month-1)*2)+1, 2 ) ) )
  endif
  return( iif( isLeapYear( str(Year) ), 29, 28 ) )
end DaysInMonthVal

proc ToggleCalType()
  case CalType
    when SingleMonth
      CalType = TinySingleMonth
    when TinySingleMonth
      CalType = ThreeMonths
    when ThreeMonths
      CalType = SingleMonth
    otherwise
      CalType = SingleMonth
  endcase
  FullWindow()
  UpdateDisplay(_All_Windows_Refresh_)
  DisplayCalendar()
end ToggleCalType

proc DisplayCalendar()
  case CalType
    when SingleMonth
      PutSingleMonth( CurrMonth, CurrDay, CurrYear )
    when TinySingleMonth
      PutTinySingleMonth( CurrMonth, CurrDay, CurrYear )
    when ThreeMonths
      PutThreeMonths( CurrMonth, CurrDay, CurrYear )
    otherwise
      PutSingleMonth( CurrMonth, CurrDay, CurrYear )
  endcase
end DisplayCalendar

proc Today()
  GetDate( CurrMonth, CurrDay, CurrYear, CurrDayOfWeek )
  DisplayCalendar()
end Today

proc PseudoToday()
  GetDate( CurrMonth, CurrDay, dummy, dummy )
  DisplayCalendar()
end PseudoToday

proc NextCentury()
  CurrYear = CurrYear + 100
  DisplayCalendar()
end NextCentury

proc PrevCentury()
  CurrYear = CurrYear - 100
  DisplayCalendar()
end PrevCentury

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
    MonthCal05[40]="³ LU ³ MA ³ MI ³ JU ³ VI ³ SA ³ DO ³",
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
  VGotoXY( 16, 2 )
  Write( DayThString( Day ) )  // 1st, 2nd, 3rd, 4th....
  MonthDayOfWeek = DayOfWeekVal( month, 1, year )  // First Day Of Month
  if MonthDayOfWeek == 0 //correcci¢n para el d¡a domingo en primero de mes
     MonthDayOfWeek = 7
  endif

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

proc PutTinySingleMonth( integer month, integer day, integer year )
  integer MonthDayOfWeek, DaysInMonth,
          d, c_day, c_week
/*
  123456789  12cc 1234   8 x 20
  Su Mo Tu We Th Fr Sa
                    01
  02 03 04 05 06 07 08
  09 10 11 12 13 14 15
  16 17 18 19 20 21 22
  23 24 25 26 27 28 29
  30 31

*/
  Window( 60, 2, 60+19, 2+7 )
  VHomeCursor()
  ClrScr()
  Set( Attr, NormalAttr )
  Set( Cursor, Off )
  VGotoXY( 7, 1 )
  Write( MonthNameString( Month ) )
  VGotoXY( 17, 1 )
  Write( Str( Year ) )
  VGotoXY( 1, 1 )
  Write( format(day:2)+" de ")  // 1st, 2nd, 3rd, 4th....
  VGotoXY( 1, 2 )
  Write( "lu ma mi ju vi sa do" )
  MonthDayOfWeek = DayOfWeekVal( month, 1, year )  // First Day Of Month
  if MonthDayOfWeek == 0 //correcci¢n para el d¡a domingo en primero de mes
     MonthDayOfWeek = 7
  endif
  DaysInMonth = DaysInMonthVal( month, year )

  d = 1
  c_day  = MonthDayOfWeek
  c_week = 1
  while d <= DaysInMonth
    VGotoXY( iif( c_day == 1, 1, (c_day*3)-2 ), c_week+2 )
    Write( Format( d:2 ) )
    if d == Day
      VGotoXY( iif( c_day == 1, 1, (c_day*3)-2 ), c_week+2 )
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
end PutTinySingleMonth

proc PutThreeMonths( integer month, integer day, integer year )
  integer MonthDayOfWeek, DaysInMonth,
          d, c_day, c_week,
          w_month, w_year
  String           // Month        Day         Year
    MonthCal01[80]="ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿",
    MonthCal02[80]="³                    ³                                  ³                    ³",
    MonthCal03[80]="ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ",
    MonthCal04[80]="ÚÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄ¿                                  ÚÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄÂÄÄ¿",
    MonthCal05[80]="³lu³ma³mi³ju³vi³sa³do³                                  ³lu³ma³mi³ju³vi³sa³do³",
    MonthCal06[80]="ÃÄÄÅÄÄÅÄÄÅÄÄÅÄÄÅÄÄÅÄÄÕÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¸ÄÄÅÄÄÅÄÄÅÄÄÅÄÄÅÄÄÅÄÄ´",
    MonthCal07[80]="³  ³  ³  ³  ³  ³  ³  ³                                  ³  ³  ³  ³  ³  ³  ³  ³",
    MonthCal08[80]="ÃÄÄÅÄÄÅÄÄÅÄÄÅÄÄÅÄÄÅÄÄÔÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¾ÄÄÅÄÄÅÄÄÅÄÄÅÄÄÅÄÄÅÄÄ´",
    MonthCal09[80]="³  ³  ³  ³  ³  ³  ³  ÉÍÍÍÍÑÍÍÍÍÑÍÍÍÍÑÍÍÍÍÑÍÍÍÍÑÍÍÍÍÑÍÍÍÍ»  ³  ³  ³  ³  ³  ³  ³",
    MonthCal10[80]="ÃÄÄÅÄÄÅÄÄÅÄÄÅÄÄÅÄÄÅÄÄº LU ³ MA ³ MI ³ JU ³ VI ³ SA ³ DO ºÄÄÅÄÄÅÄÄÅÄÄÅÄÄÅÄÄÅÄÄ´",
    MonthCal11[80]="³  ³  ³  ³  ³  ³  ³  ÇÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄ¶  ³  ³  ³  ³  ³  ³  ³",
    MonthCal12[80]="ÃÄÄÅÄÄÅÄÄÅÄÄÅÄÄÅÄÄÅÄÄº    ³    ³    ³    ³    ³    ³    ºÄÄÅÄÄÅÄÄÅÄÄÅÄÄÅÄÄÅÄÄ´",
    MonthCal13[80]="³  ³  ³  ³  ³  ³  ³  ÇÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄ¶  ³  ³  ³  ³  ³  ³  ³",
    MonthCal14[80]="ÃÄÄÅÄÄÅÄÄÅÄÄÅÄÄÅÄÄÅÄÄº    ³    ³    ³    ³    ³    ³    ºÄÄÅÄÄÅÄÄÅÄÄÅÄÄÅÄÄÅÄÄ´",
    MonthCal15[80]="³  ³  ³  ³  ³  ³  ³  ÇÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄ¶  ³  ³  ³  ³  ³  ³  ³",
    MonthCal16[80]="ÃÄÄÅÄÄÅÄÄÅÄÄÅÄÄÅÄÄÅÄÄº    ³    ³    ³    ³    ³    ³    ºÄÄÅÄÄÅÄÄÅÄÄÅÄÄÅÄÄÅÄÄ´",
    MonthCal17[80]="³  ³  ³  ³  ³  ³  ³  ÇÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄ¶  ³  ³  ³  ³  ³  ³  ³",
    MonthCal18[80]="ÀÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄº    ³    ³    ³    ³    ³    ³    ºÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÁÄÄÙ",
                         MonthCal19[80]="ÇÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄ¶",
                         MonthCal20[80]="º    ³    ³    ³    ³    ³    ³    º",
                         MonthCal21[80]="ÇÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄÅÄÄÄÄ¶",
                         MonthCal22[80]="º    ³    ³    ³    ³    ³    ³    º",
                         MonthCal23[80]="ÈÍÍÍÍÏÍÍÍÍÏÍÍÍÍÏÍÍÍÍÏÍÍÍÍÏÍÍÍÍÏÍÍÍÍ¼"

  Window( 2, 2, 79, 24 )
  VHomeCursor()
  ClrScr()
  Set( Cursor, Off )
  Set( Attr, NormalAttr )
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
  Write( MonthCal18 ) VGotoXY(22, 19)
  Write( MonthCal19 ) VGotoXY(22, 20)
  Write( MonthCal20 ) VGotoXY(22, 21)
  Write( MonthCal21 ) VGotoXY(22, 22)
  Write( MonthCal22 ) VGotoXY(22, 23)
  Write( MonthCal23 ) VGotoXY( 1, 24)

// Display Current Month

  VGotoXY( 25, 7 )
  Write( MonthNameString( Month ) )
  VGotoXY( 51, 7 )
  Write( Str( Year ) )
  VGotoXY( 37, 7 )
  Write( DayThString( Day ) )  // 1st, 2nd, 3rd, 4th....
  MonthDayOfWeek = DayOfWeekVal( month, 1, year )  // First Day Of Month
  if MonthDayOfWeek == 0 //correcci¢n para el d¡a domingo en primero de mes
     MonthDayOfWeek = 7
  endif
  DaysInMonth = DaysInMonthVal( month, year )

  d = 1
  c_day  = MonthDayOfWeek
  c_week = 1
  while d <= DaysInMonth
    VGotoXY( iif( c_day == 1, 24, 21+(c_day*5)-2 ), iif( c_week == 1, 12, (c_week*2)+10 ) )
    Write( Format( d:2 ) )
    if d == Day
      VGotoXY( iif( c_day == 1, 24, 21+(c_day*5)-2 ), iif( c_week == 1, 12, (c_week*2)+10 ) )
      PutAttr( TodayAttr, 2 )
    endif
    c_day = c_day + 1
    if c_day > 7
      c_day = 1
      c_week = c_week + 1
    endif
    d = d + 1
  endwhile

// Display Previous Month

  w_month = month - 1
  w_year  = year
  w_year  = iif( w_month < 1, w_year - 1, w_year )
  w_month = iif( w_month < 1, 12, w_month )
  VGotoXY( 3, 2 )
  Write( MonthNameString( w_month ) )
  VGotoXY( 17, 2 )
  Write( Str( w_year ) )
  MonthDayOfWeek = DayOfWeekVal( w_month, 1, w_year )  // First Day Of Month
  if MonthDayOfWeek == 0 //correcci¢n para el d¡a domingo en primero de mes
     MonthDayOfWeek = 7
  endif
  DaysInMonth = DaysInMonthVal( w_month, w_year )

  d = 1
  c_day  = MonthDayOfWeek
  c_week = 1
  while d <= DaysInMonth
    VGotoXY( iif( c_day == 1, 2, (c_day*3)-1 ), iif( c_week == 1, 7, (c_week*2)+5 ) )
    Write( Format( d:2 ) )
    c_day = c_day + 1
    if c_day > 7
      c_day = 1
      c_week = c_week + 1
    endif
    d = d + 1
  endwhile

// Display Next Month

  w_month = month + 1
  w_year  = year
  w_year  = iif( w_month > 12, w_year + 1, w_year )
  w_month = iif( w_month > 12, 1, w_month )
  VGotoXY( 59, 2 )
  Write( MonthNameString( w_month ) )
  VGotoXY( 73, 2 )
  Write( Str( w_year ) )
  MonthDayOfWeek = DayOfWeekVal( w_month, 1, w_year )  // First Day Of Month
  if MonthDayOfWeek == 0 //correcci¢n para el d¡a domingo en primero de mes
     MonthDayOfWeek = 7
  endif
  DaysInMonth = DaysInMonthVal( w_month, w_year )

  d = 1
  c_day  = MonthDayOfWeek
  c_week = 1
  while d <= DaysInMonth
    VGotoXY( iif( c_day == 1, 58, 56+(c_day*3)-1 ), iif( c_week == 1, 7, (c_week*2)+5 ) )
    Write( Format( d:2 ) )
    c_day = c_day + 1
    if c_day > 7
      c_day = 1
      c_week = c_week + 1
    endif
    d = d + 1
  endwhile
  Set( Cursor, On )
end PutThreeMonths

proc InsertTinySingleMonth( integer month, integer day, integer year )
  integer MonthDayOfWeek, DaysInMonth,
          d, c_day, c_week,
          scol
/*
 +--------------------+
 |123456789  12cc 1234|
 |Su Mo Tu We Th Fr Sa|
 |                  01|
 |02 03 04 05 06 07 08|
 |09 10 11 12 13 14 15|
 |16 17 18 19 20 21 22|
 |23 24 25 26 27 28 29|
 |30 31               |
 +--------------------+
*/
  scol = CurrCol()
  PushPosition()
  GotoColumn( scol )
  InsertText( "+--------------------+ ", _INSERT_ )
  if not Down()
    AddLine()
  endif
  GotoColumn( scol )
  InsertText( "|                    | ", _INSERT_ )
  GotoColumn( scol+7 )
  InsertText( MonthNameString( Month ), _OVERWRITE_ )
  GotoColumn( scol+17 )
  InsertText( Str( Year ), _OVERWRITE_ )
  GotoColumn( scol+1 )
  InsertText( format(day:2)+" de ", _OVERWRITE_ )  // 1st, 2nd, 3rd, 4th....
  if not Down()
    AddLine()
  endif
  GotoColumn( scol )
  InsertText( "|lu ma mi ju vi sa do| ", _INSERT_ )
  MonthDayOfWeek = DayOfWeekVal( month, 1, year )  // First Day Of Month
  if MonthDayOfWeek == 0 //correcci¢n para el d¡a domingo en primero de mes
     MonthDayOfWeek = 7
  endif
  DaysInMonth = DaysInMonthVal( month, year )

  d = 1
  c_day  = MonthDayOfWeek
  c_week = 1
  if not Down()
    AddLine()
  endif
  GotoColumn( scol )
  InsertText( "|                    | ", _INSERT_ )
  while d <= DaysInMonth
    GotoColumn( iif(c_day == 1, 2, (c_day*3)-1 ) + scol - 1 )
    InsertText( Format( d:2 ), _OVERWRITE_ )
    if d == Day
      GotoColumn( iif(c_day == 1, 1, (c_day*3)-2 ) + scol - 1 )
      InsertText( "["+Format( d:2 )+"]", _OVERWRITE_ )
    endif
    c_day = c_day + 1
    if c_day > 7
      c_day = 1
      c_week = c_week + 1
      if not Down()
        AddLine()
      endif
      GotoColumn( scol )
      InsertText( "|                    | ", _INSERT_ )
    endif
    d = d + 1
  endwhile
  if not Down()
    AddLine()
  endif
  GotoColumn( scol )
  InsertText( "+--------------------+ ", _INSERT_ )
  PopPosition()
end InsertTinySingleMonth

proc mBreakHookChain()
  BreakHookChain()
end mBreakHookChain

keydef CalKeys
  <Alt H>             Today()
  <Ctrl H>            PseudoToday()

  <Alt C>             ToggleCalType()
  <Alt I>             InsertTinySingleMonth( CurrMonth, CurrDay, CurrYear )
                      FullWindow()
                      UpdateDisplay(_All_Windows_Refresh_)
                      DisplayCalendar()

  <Enter>             NextMonth()
  <SpaceBar>          NextMonth()
  <PgDn>              NextMonth()
  <PgUp>              PrevMonth()
  <BackSpace>         PrevMonth()

  <Grey+>             NextYear()
  <Grey->             PrevYear()
  <Ctrl Grey+>        NextCentury()
  <Ctrl Grey->        PrevCentury()

  <CursorRight>       NextDay()
  <CursorLeft>        PrevDay()

  <CursorUp>          if CurrDay >7
                        CurrDay=CurrDay-7
                      else
                        PrevMonth()
                        CurrDay=DaysInMonthVal(CurrMonth,CurrYear)-7+CurrDay
                      endif
                      DisplayCalendar()

  <CursorDown>        CurrDay=CurrDay+7
                      if CurrDay>DaysInMonthVal(CurrMonth, CurrYear)
                        CurrDay=CurrDay-DaysInMonthVal(CurrMonth, CurrYear)
                        NextMonth()
                      endif
                      DisplayCalendar()

  <Home>              CurrDay = 1  // First Day Of Month
                      DisplayCalendar()

  <End>               CurrDay = DaysInMonthVal( CurrMonth, CurrYear )  // Last Day Of Month
                      DisplayCalendar()

  <Ctrl Home>         CurrMonth = 1 // First Day Of January
                      CurrDay = 1
                      DisplayCalendar()

  <Ctrl End>          CurrMonth = 12 // Last Day Of December
                      CurrDay = 31
                      DisplayCalendar()

  <Escape>            FullWindow()
                      UnHook( mBreakHookChain )
                      UpdateDisplay(_All_Windows_Refresh_)
                      DisAble( CalKeys )

  <HelpLine>       "{D}:cursor {M}:Page {A}:-/+ {M I/F}:Home/End {A I/F}:^Home/^End {Hoy}:@H {cambiar}:@C {Insrt}:@I"
  <Ctrl HelpLine>  "            {siglo}:-/+                          {Pseudo-Hoy}:^H"

end CalKeys

proc MAIN()
  GetDate( CurrMonth, CurrDay, CurrYear, CurrDayOfWeek )

  Hook( _AFTER_UPDATE_DISPLAY_, mBreakHookChain )
  Enable( CalKeys, _EXCLUSIVE_ )
  DisplayCalendar()
end MAIN

// end-of-file CAL_ESP.S
