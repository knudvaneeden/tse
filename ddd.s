/*
 * DayOfWeek.s
 *
 * A TSE SAL macro to calculate the day of the week given a date.
 */

proc Main()
    integer day = 0
    integer month = 0
    integer year = 0
    integer h = 0
    integer q = 0
    integer K = 0
    integer J = 0

    string sDay[4] = ""
    string sMonth[4] = ""
    string sYear[6] = ""
    string dayName[10] = ""

    if Ask("Enter Day (DD): ", sDay)
        if Ask("Enter Month (MM): ", sMonth)
            if Ask("Enter Year (YYYY): ", sYear)

                day = Val(sDay)
                month = Val(sMonth)
                year = Val(sYear)

                if (day < 1) or (day > 31) or (month < 1) or (month > 12)
                     Warn("Invalid date entered.")
                     return()
                endif

                /* Zeller's congruence */
                /* Adjust month and year */
                if month < 3
                    month = month + 12
                    year = year - 1
                endif

                q = day
                K = year mod 100
                J = year / 100

                /*
                   h = (q + floor(13*(m+1)/5) + K + floor(K/4) + floor(J/4) + 5*J) mod 7
                   Using 5*J instead of -2*J to keep numbers positive (modulo 7 arithmetic)
                */

                h = (q + (13 * (month + 1) / 5) + K + (K / 4) + (J / 4) + (5 * J)) mod 7

                case h
                    when 0 dayName = "Saturday"
                    when 1 dayName = "Sunday"
                    when 2 dayName = "Monday"
                    when 3 dayName = "Tuesday"
                    when 4 dayName = "Wednesday"
                    when 5 dayName = "Thursday"
                    when 6 dayName = "Friday"
                    otherwise dayName = "Error"
                endcase

                Message("The day of the week is: ", dayName)

            endif
        endif
    endif
end

