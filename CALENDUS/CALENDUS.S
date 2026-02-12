/***********************************************************************
  TSE Macro CalendUS

  Calendar    Displays a US calendar for the current month. Sundays and
              Holidays are emphasized in RED; special days otherwise.
              Arrow keys move to previous or next month or year.

  Author:     Egon Bosved, m7723@msg.abc.se
              Macro control logic acc to Richard Hendricks as
              included in the TSE macro library.

  Date:       dec 1994 - original release

  Keys:
  I use just the arrow keys. Imagine you lay out all monthly calendars
  in a row from january to december - and the next year's in a row
  below etc.

   Y1    M1 M2 ........M12
   Y2    M1 M2 ..MM....M12
   Y3    M1 M2 ........M12  etc

   Suppose you are in the month MM in year Y2.
   Is'nt it intuitive how the arrow keys function?

   Concept: I number the days from 1968-01-01 until 2099-12-31 which
   in my opinion simplifies a lot of calculations. E g weekday is
   just DayNumber modulus 7. Weeknumbers are also easy if wanted.
   I added calculation of Holidays! In my opinion holidays are quite
   important in a calendar. However I am familiar with Swedish Holidays
   only and took the american one's from an old book. May need to be
   corrected.
 ***********************************************************************/

forward proc DisplayCalendar(integer Y, integer M, integer D)

Constant BaseYr  = 1964 // Some BaseYears are easier than others.

Constant StartYr = 1968 // no calendar is eternal; certainly not for
                        // the past. If holiday rules were changed last
                        // time year YYYY please set StarYr = YYYY.

Constant StopYr  = 2099 // to stop 2099 simplifies calculation of Leap
                 // years. Tests like div 100 , div 400 are not needed
                 // as 2000 IS a leap year; but 2100 is not. (The original
                 // test by Richard Hendricks gives wrong result for 1900!)

integer CurrYear, CurrMonth, CurrDay, CurrDayOfWeek
integer DayInYear, DayInMonth, WeekDay, GF, Row, LeapYear

integer TD1, TD2, TDdayZero
        // the above ought to be unsigned int, but still it works

integer NormalAttr = Color( Blue on Cyan ),
        TodayAttr = Color( Blue on White ),
        HoliDayAttr = Color( Red on Cyan),
        FrameTextAttr = Color( BRIGHT White on Red),
        TextAttr = Color( BRIGHT White on Cyan ),
        Spec1Attr = Color ( BRIGHT Green on Cyan),  // April
        Spec2Attr = Color ( Bright Yellow on Cyan)  // Halloween

integer Proc DateToTinydate (integer Year, integer Month, integer Day)

 //Calculates a DayNumber 1968-01-01 == 1, so e g 1969-01-01 == 367!
 //DayNumber mod 7 == 0 for Sunday ... 6 for Saturday

   Year = Year - BaseYr
   if(Month > 2)
       Month = Month + 1
   else
       Year = Year - 1
       Month = Month + 13
   endif
   return ( Year*365 + Year/4 +(306*Month)/10 + Day -1523)

   // I call this a TinyDate - as it is so very tiny; just an int.

end DateToTinydate

integer Proc CertainWeekdayInMonth(integer TDdayZero,
                                   integer FirstDaynoInMonth,
                                   integer WeekDay,
                                   integer OrderInMonth,
                                   integer LeapYear) //always zero before march

   return (FirstDaynoInMonth + 6 -
          ((TDdayZero + FirstDaynoInMonth + 6 - WeekDay) mod 7) +
          (OrderInMonth -1)*7 - LeapYear )

end CertainWeekdayInMonth

integer Proc YearToGoodFriday(integer Year)
   // returns the TinyDate for GoodFriday in Year

  integer ka,kb,kc,kd,ke,kh,ki,kk,kl,km,kn,EasterDay, EasterMonth

  ka = Year mod 19
  kb = Year/100
  kc = Year mod 100
  kd = kb/4
  ke = kb mod 4
  kh = (19*ka+kb-kd+9) mod 30
  ki = kc/4
  kk = kc mod 4
  kl = (32+2*ke+2*ki-kh-kk) mod 7
  km = (ka+11*kh+22*kl)/451
  kn = kh+kl-7*km+114
  EasterDay = (kn mod 31)+1    //parenthesis seemed essential
  EasterMonth = kn/31
  return (DateToTinydate( Year, EasterMonth, EasterDay) - 2)

end YearToGoodFriday

proc NextYear()
  CurrYear = iif(CurrYear < StopYr, CurrYear+1, StopYr)
  DisplayCalendar(CurrYear, CurrMonth, CurrDay)
end NextYear

proc PrevYear()
  CurrYear = iif(CurrYear > StartYr, CurrYear - 1, StartYr)
  DisplayCalendar(CurrYear, CurrMonth, CurrDay)
end PrevYear

proc NextMonth()
  CurrMonth = CurrMonth + 1
  CurrYear  = iif( CurrMonth > 12, CurrYear+1, CurrYear )
  CurrYear  = iif(CurrYear > StopYr, StopYr, CurrYear )
  CurrMonth = iif( CurrMonth > 12, 1, CurrMonth )
  DisplayCalendar(CurrYear, CurrMonth, CurrDay)
end NextMonth

proc PrevMonth()
  CurrMonth = CurrMonth - 1
  CurrYear  = iif( CurrMonth < 1, CurrYear-1, CurrYear )
  CurrYear  = iif (CurrYear < StartYr, StartYr, CurrYear )
  CurrMonth = iif( CurrMonth < 1, 12, CurrMonth )
  DisplayCalendar(CurrYear, CurrMonth, CurrDay)
end PrevMonth

proc mBreakHookChain()
  BreakHookChain()
end mBreakHookChain

keydef CalKeys

  <CursorUp>          PrevYear()
  <CursorDown>        NextYear()

  <CursorRight>       NextMonth()
  <CursorLeft>        PrevMonth()

  <Escape>            FullWindow()
                      UnHook( mBreakHookChain )
                      UpdateDisplay(_All_Windows_Refresh_)
                      DisAble( CalKeys )

  <HelpLine> "{}Prev Month| {}Next Month| {}Prev Year| {}Next Year| {Esc} Exit"
end CalKeys

string proc MonthNameString( integer month )
  string MonthNames[110] = "January  February March    April    May      June     July     August   SeptemberOctober  November December " // 9 characters each
  return( substr( MonthNames, ((Month-1)*9)+1, 9 ) )
end MonthNameString

proc DisplayCalendar( integer Year, integer Month, integer Day )
  String
    Frame01[22]="лллллллллллллллллллллл",
    Frame02[22]="н                    о",
    Frame03[22]="н                    о",
    Frame04[22]="н                    о",
    Frame05[22]="н                    о",
    Frame06[22]="н                    о",
    Frame07[22]="н                    о",
    Frame08[22]="н                    о",
    Frame09[22]="лллллллллллллллллллллл"
  Window( 28, 8, 28+21, 8+8)
  VHomeCursor()
  ClrScr()
  Set( Attr, HolidayAttr )
  Set( Cursor, Off )
  Write( Frame01 ) VGotoXY( 1, 2 )
  Write( Frame02 ) VGotoXY( 1, 3 )
  Write( Frame03 ) VGotoXY( 1, 4 )
  Write( Frame04 ) VGotoXY( 1, 5 )
  Write( Frame05 ) VGotoXY( 1, 6 )
  Write( Frame06 ) VGotoXY( 1, 7 )
  Write( Frame07 ) VGotoXY( 1, 8 )
  Write( Frame08 ) VGotoXY( 1, 9 )
  Write( Frame09 ) VGotoXY( 2, 1)
  Set( Attr, FrameTextAttr )
  Write( MonthNameString( Month ) )
  VGotoXY( 18, 1 )
  Write( Str( Year ) ) VGotoXY( 2, 2)
  Set( Attr, TextAttr )
  Write( "Su Mo Tu We Th Fr Sa" )

  TD1 = DateToTinyDate(Year, Month, 1)     // dayno for 1:st day in month.
  TD2 = DateToTinyDate(Year, Month + 1, 1) // to determin days in month
                                           // works even over december
  TDdayZero = DateToTinyDate(Year, 1, 1) - 1 // NewYearsEve prev year
  DayInYear = TD1 - TDdayZero
  LeapYear = 0
  if(Year mod 4 == 0)
     LeapYear = 1
  endif
  if((DayInYear > 59) and LeapYear) //adjust for Leap year
     DayInYear = DayInYear - 1
  endif

  GF=0

  DayInMonth = 1
  Row = 3

  While (TD1 < TD2)          // this is the print loop
     WeekDay = TD1 mod 7
     GF=0
     VGotoXY( WeekDay*3+2, Row)
     Set(Attr,HolidayAttr)

     if( CurrMonth <5 )

        GF = YearToGoodFriday(Year)- TDdayZero - (Year mod 4 == 0)

        Case DayInYear                 // test for holidays
           when 1   // New Year        // first at fixed dates
                Write("NY")
           when 45  // Saint Valentines Day
                Write("  ")
           when 91  // April Fools Day
                Set(Attr, Spec1Attr)
                Write(" ")
           when GF                      // Good Friday
                Write("GF")
           when GF+2                    // Easter
                Write("ED")
           when    // Martin Luther King Jr Day
                 CertainWeekdayInMonth(TDdayZero,1,1,3,0)
                 Write("ML")
           when     // President's Day
                 CertainWeekdayInMonth(TDdayZero,32,1,3,0)
                 Write("Pr")
           otherwise

                Set(Attr, NormalAttr)
                if (WeekDay==0)
                   Set(Attr, HoliDayAttr)
                endif
                If(DayInMonth == Day)
                   Set(Attr, ToDayAttr)
                endif
           Write( DayInMonth:2 )
        endcase
     endif

     if( CurrMonth > 4)

        Case DayInYear                 // test for holidays

           when 185  // Independence Day
                Write("ID")
           when 304
                Set(Attr, Spec2Attr)
                Write(" ")
           when 359  // Christmas
                Write("Xm")
             // special days (Mondays mostly)
           when      // Memorial Day; first monday in June - 1 week
                 CertainWeekdayInMonth(TDdayZero,152,1,1,LeapYear) -7
                 Write("Mm")
           when      // Labor  Day
                 CertainWeekdayInMonth(TDdayZero,244,1,1,LeapYear)
                 Write("La")
           when      // Columbus Day
                 CertainWeekdayInMonth(TDdayZero,274,1,2,LeapYear)
                 Write("Co")
           when      // Veteran's Day
                 CertainWeekdayInMonth(TDdayZero,305,4,2,LeapYear)
                 Write("Vt")
           when      // Thanksgiving Day on 4:th Thursday
                 CertainWeekdayInMonth(TDdayZero,305,4,4,LeapYear)
                 Write("Th")
           otherwise
                Set(Attr, NormalAttr)
                if (WeekDay==0)
                   Set(Attr, HoliDayAttr)
                endif
                If(DayInMonth == Day)
                   Set(Attr, ToDayAttr)
                endif
           Write( DayInMonth:2 )
        endcase
     endif

     TD1 = TD1 +1
     DayInMonth = DayInMonth + 1
     DayInYear = DayInYear + 1
     If (WeekDay == 6)
         Row = Row + 1
     endif
  EndWhile
  Set(Cursor, On)

end DisplayCalendar

proc MAIN()
  GetDate( CurrMonth, CurrDay, CurrYear, CurrDayOfWeek )

  Hook( _AFTER_UPDATE_DISPLAY_, mBreakHookChain )
  Enable( CalKeys, _EXCLUSIVE_ )
  DisplayCalendar(CurrYear, CurrMonth, CurrDay)
end MAIN
