// REMIND.S  06/11/1993  06/17/1993
// by Richard Hendricks

// Search Date Format: Month, Day and Year

// User Defined Options - See Below
//
// MinDateColumn = 1    // Event dates are found in columns MinDateColumn to MaxDateColumn
// MaxDateColumn = 15   // Event dates are found in columns MinDateColumn to MaxDateColumn
// MaxDateAdder  = 7    // curr date + MaxDateAdder = MaxDate
//                      // valid range 0 to 10
//

forward string proc GenerateRangeString( string Num1, string Num2 )
forward integer proc isLeapYear( string Year )
forward integer proc DaysInMonthVal( integer month, integer year )
forward string proc GenerateDateMask( string MinDate, string MaxDate ) // format YYYYMMDD
forward string proc MakeMaxDate( integer MinYear, integer MinMonth, integer MinDay, integer MaxDateAdder )

string proc GenerateRangeString( string Num1, string Num2 )
// if Num1 equals Num2, just return Num1 -else-
//    return a string in the format of "[n-n]"  ; the first n is less than the
//    second. TSE Regular Expressions do not permit [2-0], but must have [0-2]
  if Num1 == Num2
    return( Num1 )
  else
    return( "["+iif( Num1 < Num2, Num1+"-"+Num2, Num2+"-"+Num1 ) + "]" )
  endif
end GenerateRangeString

integer proc isLeapYear( string Year )
  integer nyear

  nyear = val( year )
  return( iif( nyear mod 4 or (not nyear mod 100 and nyear mod 400),
                false, true ) )
end isLeapYear

integer proc DaysInMonthVal( integer month, integer year )
  string MonthDays[24]="312831303130313130313031"
  if month <> 2
    return( val( SubStr( MonthDays, ((Month-1)*2)+1, 2 ) ) )
  else
    return( iif( isLeapYear( str(Year) ), 29, 28 ) )
  endif
end DaysInMonthVal

string proc GenerateDateMask( string MinDate, string MaxDate ) // format YYYYMMDD
// If the MinDate and MaxDate are the same Month, return a string with the
//    format [mm[p][d-d][d-d][p]y@y@yy] - else -
// return a string with the
//    format {[mm[p][d-d][d-d][p]y@y@yy]}|{[mm[p][d-d][d-d][p]y@y@yy]}
// The first is a Regular Expression for MinDate's Month (current date to max
// day in month) and the second is for MaxDate's Month (first day of month to
// max day) [p] is the date punctuation /, - or .
//
// Incoming format is YYYYMMDD
// Outgoing format will look for MM/DD/YYYY, MM-DD-YYYY, MM.DD.YYYY,
//                               MM/DD/YY, MM-DD-YY or MM.DD.YY

  string DateMask[100]
  string NumDaysInMonth[2]

  if SubStr( MinDate, 5, 2 ) == SubStr( MaxDate, 5, 2 ) // Same Month
    if MinDate[7] == MaxDate[7]  // Same First Day Digit
      DateMask = SubStr( MinDate, 5, 2 ) +  "[/\-\.]" +                   // Month
                 MinDate[7] + "[" + MinDate[8] + "-" + MaxDate[8] + "]" + // Day
                 "[/\-\.]" +
                 MinDate[1] + "@" + MinDate[2] + "@" +                    // Year
                 SubStr( MinDate, 3, 2 )
    else
      DateMask = SubStr( MinDate, 5, 2 ) +  "[/\-\.]" +                   // Month
                 "{" + MinDate[7] + "[" + MinDate[8] + "-" + "9"+ "]}|" + // Day
                 "{" + MaxDate[7] + "[" + "0" + "-" + MaxDate[8]+ "]}" +
                 "[/\-\.]" +
                 MinDate[1] + "@" + MinDate[2] + "@" +                    // Year
                 SubStr( MinDate, 3, 2 )
    endif
  else
    NumDaysInMonth = format( DaysInMonthVal( val( SubStr( MinDate, 5, 2 ) ),
                                             val( SubStr( MinDate, 1, 4 ) ) ):2:"0" )

    if MinDate[7] == NumDaysInMonth[1]  // Same First Day Digit
      DateMask = "{" + SubStr( MinDate, 5, 2 ) +  "[/\-\.]" +            // Month
                 MinDate[7] + GenerateRangeString( MinDate[8], NumDaysInMonth[2] ) + // Day
                 "[/\-\.]" +
                 MinDate[1] + "@" + MinDate[2] + "@" +                   // Year
                 SubStr( MinDate, 3, 2 ) + "}" +
                 "|" +
                 "{" + SubStr( MaxDate, 5, 2 ) + "[/\-\.]" +             // Month
                 MaxDate[7] + "[" + "1" + "-" + MaxDate[8] + "]" +       // Day
                 "[/\-\.]" +
                 MaxDate[1] + "@" + MaxDate[2]+ "@" +                    // Year
                 SubStr( MaxDate, 3, 2 ) + "}"
    else
      DateMask = "{" + SubStr( MinDate, 5, 2 ) +  "[/\-\.]" +            // Month
                 "{" + MinDate[7] + GenerateRangeString( MinDate[8], "9" ) + "}|" + // Day
                 "{" + NumDaysInMonth[1] + GenerateRangeString( "0", NumDaysInMonth[2] ) + "}" +
                 "[/\-\.]" +
//               MinDate[1] + "@" + MinDate[2] + "@" +                   // Year
                 ".." +
                 SubStr( MinDate, 3, 2 ) + "}" +
                 "|" +
                 "{" + SubStr( MaxDate, 5, 2 ) + "[/\-\.]" +             // Month
                 MaxDate[7] + "[" + "1" + "-" + MaxDate[8] + "]" +       // Day
                 "[/\-\.]" +
//               MaxDate[1] + "@" + MaxDate[2] + "@" +                   // Year
                 ".." +
                 SubStr( MaxDate, 3, 2 ) + "}"
    endif
  endif
  return( DateMask )
end GenerateDateMask

string proc MakeMaxDate( integer MinYear, integer MinMonth, integer MinDay, integer MaxDateAdder )
  string MaxDate[10]
  integer MaxYear = 0, MaxMonth = 0, MaxDay = 0

  if DaysInMonthVal( MinMonth, MinYear ) >= (MinDay + MaxDateAdder)
    MaxDate = format( MinYear:4 )+format( MinMonth:2:'0' )+ format( MinDay+MaxDateAdder:2:'0' )
  else
    MaxDay = MaxDateAdder - (DaysInMonthVal( MinMonth, MinYear ) - MinDay + 1)
    MaxMonth = MinMonth + 1
    MaxYear = MinYear
    if MaxMonth > 12
      MaxMonth = 1
      MaxYear = MinYear + 1
    endif
    MaxDate = format( MaxYear:4 )+format( MaxMonth:2:'0' )+ format( MaxDay:2:'0' )
  endif
  return( MaxDate )
end MakeMaxDate

proc MAIN()
  integer MinDateColumn = 1    // Event dates are found in columns MinDateColumn to MaxDateColumn
  integer MaxDateColumn = 15   // Event dates are found in columns MinDateColumn to MaxDateColumn
  integer MaxDateAdder  = 7    // curr date + MaxDateAdder = MaxDate
                               // valid range 0 to 10
  string  DateMask[100]
  string  DateFindFlags[10] = "IXL"
  string  DateFindFlagsGlobal[10] = "IX"  // DateFindFlags without the Local
                                          //  Option -- Intended for interactive
                                          //  use.
  string  MinDate[10], MaxDate[10]
  integer month=0, day=0, year=0, day_of_week=0

  UnMarkBlock()
  BegFile()
  GotoPos( MinDateColumn )
  MarkColumn()
  GotoPos( MaxDateColumn )
  EndFile()
  MarkColumn()
  GotoBlockBegin()

  GetDate(month, day, year, day_of_week)

//month = 7    // Testing
//day   = 28   // Testing
//year  = 1993 // Testing

  MinDate = format( year:4 )+format( month:2:'0' )+ format( day:2:'0' )

  MaxDate = MakeMaxDate( year, month, day, MaxDateAdder )

  DateMask = GenerateDateMask( MinDate, MaxDate )

  AddHistoryStr( DateMask, _FINDHISTORY_ )
  AddHistoryStr( DateFindFlags, _FINDOPTIONS_HISTORY_ )
  AddHistoryStr( DateFindFlagsGlobal, _FINDOPTIONS_HISTORY_ )

  if FIND( DateMask, DateFindFlags )
    UnMarkBlock()
    MarkLine()
    MarkLine()
  else
    UnMarkBlock()
    warn( "No dates between "+SubStr( MinDate, 5, 2 ) + "/" +
                              SubStr( MinDate, 7, 2 ) + "/" +
                              SubStr( MinDate, 1, 4 ) + " and "+
                              SubStr( MaxDate, 5, 2 ) + "/" +
                              SubStr( MaxDate, 7, 2 ) + "/" +
                              SubStr( MaxDate, 1, 4 ) + " were found" )
  endif
  UpdateDisplay( _STATUSLINEREFRESH_ | _ALLWINDOWSREFRESH_ )
end MAIN
// end-of-file REMIND.S
