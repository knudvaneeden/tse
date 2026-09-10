/*
Date algorithms copyright TurboPower Software Company --
Permission to redistribute, granted to SemWare Corp.
*/



// getdate.s
// 03/31/94 - 6:38 AM
// Author: Jim Sylva <jasylva@ucdavis.edu>

Constant
   MinYear = 1600,
   MaxYear = 3999,
   Threshold2000 = 1900,
   First2Months = 59         // 1600 was a leap year

// Global declarations
integer DMYtoDate, DaysInMonth,
        Mon, Day, Year,
        Date_Format, Date_Separator,
        Key, MKey, Insert_Key

string  DateStr[29]  = '',
        DateStr1[08] = '',
        DateStr2[11] = '',
        DateStr3[15] = '',
        DateStr4[19] = '',
        DateStr5[18] = '',
        DateStr6[29] = '',
        sYear[4], sDay[2], sMon[2],
        month_name[9]   = '',
        day_of_week1[9]  = '', day_of_week2[2] = '', day_of_week3[3] = ''

//******************************************************************************
integer proc IsLeapYear(Integer Year)
//******************************************************************************
// Return True (1) if Year is a leap year
   If (Year mod 4 == 0) and (Year mod 4000 <> 0) and
      ((Year mod 100 <> 0) or (Year mod 400 == 0))
      Return(True)  // return terminates the procedure
   EndIf
   Return(False)
End

//******************************************************************************
integer proc GetDaysInMonth(Integer Mon, Integer Year)
//******************************************************************************
// Return the number of days in the specified month of a given year

   If Year < 100
      Year = Year + 1900
      If Year < Threshold2000
        Year = Year + 100
      Endif
   Endif

   Case Mon
      When 1, 3, 5, 7, 8, 10, 12 DaysInMonth = 31
      When 4, 6, 9, 11 DaysInMonth = 30
      When 2 DaysInMonth = 28+IsLeapYear(Year)
   EndCase
   Return(DaysInMonth)
End

//******************************************************************************
integer proc DMYtoJulian(Integer Mon, Integer Day, Integer Year)
//******************************************************************************
   If Year < 100
      Year = Year + 1900
      If Year < Threshold2000
         Year = Year + 100
      EndIf
   EndIf

   If Year == MinYear And Mon < 3
      If Mon == 1
         DMYtoDate = Day-1
      Else
         DMYtoDate = Day+30
      EndIf
   Else
      If Mon > 2
         Mon = Mon-3
      Else
         Mon = Mon + 9
         Year = Year -1
      EndIf
      Year = Year - MinYear
      DMYtoDate = (((Year / 100)*146097) / 4)+
                  (((Year mod 100)*1461) / 4)+
                  (((153*Mon)+2) / 5) + Day + First2Months
   EndIf
   Return(DMYtoDate)
End

//******************************************************************************
proc JulianToDMY(Var Integer Julian, Var Integer Mon,
                 Var Integer Day, Var Integer Year)
//******************************************************************************
   integer i, j
   If Julian <= First2Months
      Year = MinYear
      If Julian <= 30
         Mon = 1
         Day = Julian-1
      Else
         Mon = 2
         Day = Julian-30
      EndIf
   Else
      i = (4*(Julian-First2Months))-1
      j = (4*((i mod 146097) / 4)) +3
      Year = (100*(i / 146097))+(j / 1461)
      i = (5*(((j mod 1461)+4) /4))-3
      Mon = i / 153
      Day = ((i mod 153)+5)/5
      If Mon < 10
         Mon = Mon+3
      Else
         Mon = Mon-9
         Year = Year+1
      EndIf
      Year = Year + MinYear
   EndIf
End

//******************************************************************************
integer proc DecMonth(Integer Mon, Integer Day, Integer Year)
//******************************************************************************
   integer PrevMonth, DaysInPrevMonth
   JulianToDMY(DMYtoDate,Mon,Day,Year)
   GetDaysInMonth(Mon,Year)
//*   DaysInCurrMonth = DaysInMonth
   PrevMonth = Mon-1
   GetDaysInMonth(PrevMonth,Year)
   DaysInPrevMonth = DaysInMonth

   If Day > DaysInPrevMonth
      DMYtoDate = DMYtoDate-Day
   Else
      DMYtoDate = DMYtoDate-DaysInPrevMonth
   EndIf
   Return(DMYtoDate)
end

//******************************************************************************
integer proc IncMonth(Integer Mon, Integer Day, Integer Year)
//******************************************************************************
   integer NextMonth, DaysInCurrMonth, DaysInNextMonth
   JulianToDMY(DMYtoDate,Mon,Day,Year)
   GetDaysInMonth(Mon,Year)
   DaysInCurrMonth = DaysInMonth
   NextMonth = Mon+1
   GetDaysInMonth(NextMonth,Year)
   DaysInNextMonth = DaysInMonth

   If Day > DaysInNextMonth
      DMYtoDate = DMYtoDate+DaysInCurrMonth-Day+DaysInNextMonth
   Else
      DMYtoDate = DMYtoDate+DaysInCurrMonth
   EndIf

   Return(DMYtoDate)
end

//******************************************************************************
integer proc DecYear(Integer Mon, Integer Day, Integer Year)
//******************************************************************************
   integer PrevYear
   JulianToDMY(DMYtoDate,Mon,Day,Year)
   PrevYear = Year-1
   If IsLeapYear(Year)
      If (Mon == 1) Or (Mon == 2 And Day <= 28)
         DMYtoDate = DMYtoDate-365
      Else
         DMYtoDate = DMYtoDate-366
      EndIf
   EndIf

   If IsLeapYear(PrevYear)
      If Mon > 2
         DMYtoDate = DMYtoDate-365
      Else
         DMYtoDate = DMYtoDate-366
      EndIf
   EndIf

   If (Not IsLeapYear(Year)) And (Not IsLeapYear(PrevYear))
      DMYtoDate = DMYtoDate-365
   EndIf
   Return(DMYtoDate)
end

//******************************************************************************
integer proc IncYear(Integer Mon, Integer Day, Integer Year)
//******************************************************************************
   integer NextYear
   JulianToDMY(DMYtoDate,Mon,Day,Year)
   NextYear = Year+1
   If IsLeapYear(Year)
      If (Mon == 1) Or (Mon == 2 And Day <= 28)
         DMYtoDate = DMYtoDate+366
      Else
         DMYtoDate = DMYtoDate+365
      EndIf
   EndIf

   If IsLeapYear(NextYear)
      If Mon > 2
         DMYtoDate = DMYtoDate+366
      Else
         DMYtoDate = DMYtoDate+365
      EndIf
   EndIf

   If (Not IsLeapYear(Year)) And (Not IsLeapYear(NextYear))
      DMYtoDate = DMYtoDate+365
   EndIf
   Return(DMYtoDate)
end

//******************************************************************************
Proc ExpandedGetDate(Var String Month_Name, Var String Day_Of_Week1,
                     Var String Day_Of_Week2, Var String Day_Of_Week3)
//******************************************************************************
    integer dow
    JulianToDMY(DMYtoDate,Mon,Day,Year)
    dow = DMYtoDate mod 7
    case mon
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

    case dow
        when  1 day_of_week1 = 'Sunday'
        when  2 day_of_week1 = 'Monday'
        when  3 day_of_week1 = 'Tuesday'
        when  4 day_of_week1 = 'Wednesday'
        when  5 day_of_week1 = 'Thursday'
        when  6 day_of_week1 = 'Friday'
        when  0 day_of_week1 = 'Saturday'
    endcase

   Case DoW
      When 1 Day_Of_Week2 = 'Su'
      When 2 Day_Of_Week2 = 'Mo'
      When 3 Day_Of_Week2 = 'Tu'
      When 4 Day_Of_Week2 = 'We'
      When 5 Day_Of_Week2 = 'Th'
      When 6 Day_Of_Week2 = 'Fr'
      When 0 Day_Of_Week2 = 'Sa'
   EndCase

   Case DOW
      When 1 Day_Of_Week3 = 'Sun'
      When 2 Day_Of_Week3 = 'Mon'
      When 3 Day_Of_Week3 = 'Tue'
      When 4 Day_Of_Week3 = 'Wed'
      When 5 Day_Of_Week3 = 'Thu'
      When 6 Day_Of_Week3 = 'Fri'
      When 0 Day_Of_Week3 = 'Sat'
   EndCase
end  // ExpandedGetDate

//******************************************************************************
string proc jDate()
//******************************************************************************
   DateStr = sMon+'/'+sDay+'/'+SubStr(sYear,3,2)
   Return(DateStr)
end

//******************************************************************************
string proc jDateDay()
//******************************************************************************
   DateStr = sMon+'/'+sDay+'/'+SubStr(sYear,3,2)+' '+Day_Of_Week2
   Return(DateStr)
end

//******************************************************************************
string proc jDateDay2()
//******************************************************************************
   DateStr = sMon+'/'+sDay+'/'+SubStr(sYear,3,2)+'    '+Day_Of_Week3
   Return(DateStr)
end

//******************************************************************************
string proc MonthDate()
//******************************************************************************
   DateStr = Format(Month_name,' ',day,', ',year)
   Return(DateStr)
end

//******************************************************************************
string proc DayMonthDate()
//******************************************************************************
   DateStr = Format(Day_of_Week1+', ',Month_name,' ',day,', ',year)
   Return(DateStr)
end

//******************************************************************************
string proc DayDate()
//******************************************************************************
   DateStr = Day_Of_Week1+', '+ sMon+'/'+sDay+'/'+SubStr(sYear,3,2)
   Return(DateStr)
end

//******************************************************************************
proc GetDefaultSettings()
//******************************************************************************
   Insert_Key     = Query(Insert)
   Date_Format    = Query(DateFormat)
   Date_Separator = Query(DateSeparator)
   Set(DateFormat,1)
   Set(DateSeparator,47)
end

//******************************************************************************
proc ResetDefaultSettings()
//******************************************************************************
   Set(DateSeparator,Date_Separator)
   Set(DateFormat,Date_Format)
   Set(Insert,Insert_Key)
end

//******************************************************************************
proc FormatStr(Var String DateStr1, Var String DateStr2,
               Var String DateStr3, Var String DateStr4,
               Var String DateStr5, Var String DateStr6)
//******************************************************************************
   DateStr1 = sMon+'/'+sDay+'/'+SubStr(sYear,3,2)
   DateStr2 = sMon+'/'+sDay+'/'+SubStr(sYear,3,2)+' '+Day_Of_Week2
   DateStr3 = sMon+'/'+sDay+'/'+SubStr(sYear,3,2)+'    '+Day_Of_Week3
   DateStr4 = Format(Day_Of_Week1+', '+ sMon+'/'+sDay+'/'+SubStr(sYear,3,2))
   DateStr5 = Format(Month_name,' ',day,', ',year)
   DateStr6 = Format(Day_of_Week1,', ',Month_name,' ',day,', ',year)
end

//******************************************************************************
menu DateMenu()
//******************************************************************************
   title = 'Date Formats'
     X     = 43       // Col
     Y     = 6        // Row
   History = 2
   '&1'[DateStr1:SizeOf(DateStr1)], jDate()
   '&2'[DateStr2:SizeOf(DateStr2)], jDateDay()
   '&3'[DateStr3:SizeOf(DateStr3)], jDateDay2()
   '&4'[DateStr4:SizeOf(DateStr4)], DayDate()
   '&5'[DateStr5:SizeOf(DateStr5)], MonthDate()
   '&6'[DateStr6:SizeOf(DateStr6)], DayMonthDate()
end


//******************************************************************************
proc FormatDate(Integer Mon, Integer Day, Integer Year,
                Var String sMon, Var String sDay, Var String sYear)
//******************************************************************************
   If Mon < 10
      sMon = '0'+Str(Mon)
   Else
      sMon  = Str(Mon)
   EndIf
   If Day < 10
      sDay = '0'+Str(Day)
   Else
      sDay  = Str(Day)
   EndIf
   sYear = Str(Year)
end

//******************************************************************************
proc Main()
//******************************************************************************
   integer Mon, Day, Year, Dow, CurrWinBorder, MenuSelect
   GetDefaultSettings()
   CurrWinBorder = Query(CurrWinBorderAttr)
   MenuSelect    = Query(MenuSelectAttr)
   Set(Attr,MenuSelect)
   GetDate(Mon,Day,Year,Dow)
   DMYtoJulian(Mon,Day,Year)
   ExpandedGetDate(Month_Name,Day_Of_Week1,Day_Of_Week2,Day_Of_Week3)
   FormatDate(Mon,Day,Year,sMon,sDay,sYear)
   DateStr = sMon+'/'+sDay+'/'+sYear+' '+Day_Of_Week2
   PopWinOpen(57,2,79,4,1,'Use //^^, CR',CurrWinBorder)
   Write('    '+DateStr+'    ')
   Set(Cursor,off)
   Repeat
      Repeat
         Key = GetKey()
         Case Key
            When <CursorDown>         DMYtoDate = DMYtoDate+1
            When <CursorUp>           DMYtoDate = DMYtoDate-1
            When <CursorLeft>         DMYtoDate = DecMonth(Mon,Day,Year)
            When <CursorRight>        DMYtoDate = IncMonth(Mon,Day,Year)
            When <Ctrl CursorLeft>    DMYtoDate = DecYear(Mon,Day,Year)
            When <Ctrl CursorRight>   DMYtoDate = IncYear(Mon,Day,Year)

            When <GreyCursorDown>         DMYtoDate = DMYtoDate+1
            When <GreyCursorUp>           DMYtoDate = DMYtoDate-1
            When <GreyCursorLeft>         DMYtoDate = DecMonth(Mon,Day,Year)
            When <GreyCursorRight>        DMYtoDate = IncMonth(Mon,Day,Year)
            When <Ctrl GreyCursorLeft>    DMYtoDate = DecYear(Mon,Day,Year)
            When <Ctrl GreyCursorRight>   DMYtoDate = IncYear(Mon,Day,Year)
         EndCase
         JulianToDMY(DMYtoDate,Mon,Day,Year)
         ExpandedGetDate(Month_Name,Day_Of_Week1,Day_Of_Week2,Day_Of_Week3)
         FormatDate(Mon,Day,Year,sMon,sDay,sYear)
         DateStr = sMon+'/'+sDay+'/'+sYear+' '+Day_Of_Week2
         Gotoxy(1,1)
         Write('    '+DateStr+'    ')
      Until Key == <Enter> Or Key == <Escape>
      If Key == <Enter>
         ExpandedGetDate(Month_Name,Day_Of_Week1,Day_Of_Week2,Day_Of_Week3)
         FormatStr(DateStr1,DateStr2,DateStr3,DateStr4,DateStr5,DateStr6)
         DateMenu()
         Set(Attr,MenuSelect)
         MKey = MenuKey()
      Endif
      If Key == <Escape>
         Set(Cursor,on)
         Halt
      EndIf
   Until MKey == <Enter> Or MKey == <1> Or MKey == <2> Or MKey == <3> Or MKey == <4> Or Key == <Escape>
   If MKey == <Enter> Or MKey == <1> Or MKey == <2> Or MKey == <3> Or MKey == <4> //And Key == <Enter>
      If Insert_Key == 1
         InsertText(DateStr,_INSERT_)
      Else
         InsertText(DateStr,_OVERWRITE_)
      Endif
   Endif
   ResetDefaultSettings()
   PopWinClose()
   Set(Cursor,on)
end

