// euler019.s  -  Project Euler Problem 19: Counting Sundays
//
// How many Sundays fell on the first of the month
// during the twentieth century (1 Jan 1901 to 31 Dec 2000)?
//
// Known facts supplied by the problem:
//   1 Jan 1900 was a Monday  (day index 1, with 0=Sunday)
//   Leap year: divisible by 4, EXCEPT centuries unless divisible by 400
//
// Strategy:
//   Track day-of-week as a running integer (0=Sun .. 6=Sat).
//   Advance by whole months (using each month's day count).
//   Starting point: 1 Jan 1900 = Monday (dow=1).
//   Count only months in 1901-2000 where dow==0 on the 1st.
//
// Version : 1.0.0.0

// ---------------------------------------------------------------------------
// IsLeapYear(y)  -  returns 1 if y is a leap year, else 0
// ---------------------------------------------------------------------------
integer proc IsLeapYear(integer y)
    integer result

    result = 0
    if (y mod 400) == 0
        result = 1
    elseif (y mod 100) == 0
        result = 0
    elseif (y mod 4) == 0
        result = 1
    endif
    return(result)
end

// ---------------------------------------------------------------------------
// DaysInMonth(m, y)  -  returns number of days in month m of year y
//   m : 1..12
// ---------------------------------------------------------------------------
integer proc DaysInMonth(integer m, integer y)
    integer days

    case m
        when 1, 3, 5, 7, 8, 10, 12
            days = 31
        when 4, 6, 9, 11
            days = 30
        when 2
            if IsLeapYear(y)
                days = 29
            else
                days = 28
            endif
        otherwise
            days = 0
    endcase
    return(days)
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer year, month, dow, count, dim

    // 1 Jan 1900 is Monday => dow = 1
    dow   = 1
    count = 0

    // Advance through every month from Jan 1900 to Dec 2000.
    // For months in 1901-2000, check whether the 1st is a Sunday (dow==0).

    year = 1900
    while year <= 2000
        month = 1
        while month <= 12
            // Check BEFORE advancing: this is the 1st of (year, month)
            if year >= 1901
                if dow == 0
                    count = count + 1
                endif
            endif

            // Advance dow by the number of days in this month
            dim = DaysInMonth(month, year)
            dow = (dow + dim) mod 7

            month = month + 1
        endwhile
        year = year + 1
    endwhile

    Warn("Euler 019 - Counting Sundays: " + Str(count))
    CopyToWinClip( Str( count ) )
end
