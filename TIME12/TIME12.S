// FILE: TIME12.S
// Macro to print time in 12 hour format on a computer that uses 24
// hour time format - one space is added after the time - if there
// is a leading zero, it is stripped.
// Example output: 9:30 AM, 12:30 PM
// Jim Fouch - April 21, 1993
// NOTE: you must uncomment either the line following (1) Or (2).

// (1) Uncomment the next line to if you add this to TIMEDATE.S
// (1) by Tom Klein
// PUBLIC proc time12()

// (2) Uncomment the next line to use as a stand alone macro
// PROC main()

    string  timebuf[5] = ''
    string  hours[2]   = ''
    string  mins[2]    = ''
    string  am_pm[2]   = "AM"

    timebuf = GetTimeStr()
    mins = SubStr(timebuf,4,2)

    if SubStr(timebuf,1,2) == "00"          // between 00:00 and 01:00,
        hours = "12"                        //      replace 00 with 12
    elseif SubStr(timebuf,1,1) == "0"       // between 01:00 and 10:00,
        hours = SubStr(timebuf,2,1)         //      strip leading zero
    else
        hours = SubStr(timebuf,1,2)         // 10:00 or later
    endif

    if Val(SubStr(timebuf,1,2)) >= 12       // if 12:00 or later, it is PM
        am_pm = "PM"
        if Val(SubStr(timebuf,1,2)) > 12    // if it is 13:00 or later,
            hours = Str(Val(hours) - 12)    //      convert to 12 hour time
        endif
    endif

    InsertText(Format(hours, ':', mins, ' ', am_pm, ' '))

end // time12() - File: TIME12.S
