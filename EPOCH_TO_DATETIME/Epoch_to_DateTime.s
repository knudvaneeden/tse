/*
  Macro           Epoch_to_DateTime
  Author          Carlo.Hogeveen@xs4all.nl
  Version         v1.0.2 - 16 Jan 2020
  Compatibility   Tse Pro v4.0 upwards,
                  Tested with TSE Pro for Linux v4.41.20.

  This tool is an TEST and EXAMPLE macro for the epoch_to_datetime() procedure,
  that given a time zone in hours can convert unix's epoch seconds
  (seconds since 1 Jan 1970 0:00:00) to a year, day, month, hours,
  minutes and seconds.

  Note that the tool uses the time zone hours you provide for all dates:
  it does not compensate for summer or winter time.

  Copy the epoch_to_datetime() procedure to your own macro
  if you want to use it.

  Its creation was triggered by a question posed by Fred H Olsen
  in the TSE Linux mailing list on Wednesday 15 Jan 2020 at 16:21.

  Converting epoch seconds to a date time can be done,
  but the time zone hours have to come from somewhere else.
  Getting the time zone from unix is a relatively expensive one-time operation,
  and therefore left out of the conversion procedure that might be called many
  times.

  Conversion has been separated from formatting, so everyone can format
  the resulting date time to their own preference.


  About the LIST test:

  It places "ERROR" before a list line if the macro's calculated and formatted
  date time is not equal to the formatted date time the unix "date" command
  generates for the same epoch seconds.

  A potential problem is that I adjusted the macro's formatting to the
  formatting MY Linux system generates for a unix command like
    date -d @1234567890 +%D%l:%M%p
  which format was provided in Fred's original question.
  So you might get an "ERROR" on different formatting on your system.

  Another potential problem is, that the macro uses one fixed time zone,
  while my Linux system possibly adjusts each date time by one hour for summer
  or winter time.
  So at best the LIST test gives me ERRORs for all date times in summer time
  or for all date times in winter time.


  HISTORY
  v1.0    - 15 Jan 2020
    Initial release.
  v1.0.1  - 15 Jan 2020
    Bug fix:
      Apparently only February can have a leap day.
  v1.0.2  - 16 Jan 2020
    Bug fix:
      Apparently November 2019 has no 31st day for one second.
*/

proc epoch_to_datetime(    integer epoch_seconds,
                           integer timezone_hours,
                       var integer year,
                       var integer month,
                       var integer day,
                       var integer hours,
                       var integer minutes,
                       var integer seconds)
  integer adjusted_epoch_seconds   = epoch_seconds + timezone_hours * 60 * 60
  string  days_in_month       [35] = '31 28 31 30 31 30 31 31 30 31 30 31'
  integer last_year                = 0
  integer last_year_seconds        = 0
  integer prev_prev_years_seconds  = 0
  integer prev_years_seconds       = 0
  integer seconds_into_day         = 0
  integer seconds_into_hour        = 0
  integer seconds_into_month       = 0
  integer seconds_into_year        = 0
  integer seconds_until_next_month = 60 * 60 * 24 * 31
  integer seconds_until_this_month = 0
  year = 1970
  while prev_years_seconds <= adjusted_epoch_seconds
    last_year         = year
    year              = year + 1
    last_year_seconds = 60 * 60 * 24 * 365
    if     last_year mod   4 == 0
    and (  last_year mod 100 <> 0
        or last_year mod 400 == 0)
      last_year_seconds = last_year_seconds + 60 * 60 * 24
    endif
    prev_prev_years_seconds = prev_years_seconds
    prev_years_seconds      = prev_years_seconds + last_year_seconds
  endwhile
  year = year - 1
  seconds_into_year = adjusted_epoch_seconds - prev_prev_years_seconds
  month = 1
  while month             <  12
  and   seconds_into_year >= seconds_until_next_month
    month                    = month + 1
    seconds_until_this_month = seconds_until_next_month
    seconds_until_next_month = seconds_until_next_month +
                        60 * 60 * 24 * Val(GetToken(days_in_month, ' ', month))
    if month == 2
      if     year mod   4 == 0
      and (  year mod 100 <> 0
          or year mod 400 == 0)
        seconds_until_next_month = seconds_until_next_month + 60 * 60 * 24
      endif
    endif
  endwhile
  seconds_into_month = seconds_into_year - seconds_until_this_month
  day                = seconds_into_month  /  (60 * 60 * 24) + 1
  seconds_into_day   = seconds_into_month mod (60 * 60 * 24)
  hours              = seconds_into_day    /  (60 * 60)
  seconds_into_hour  = seconds_into_day   mod (60 * 60)
  minutes            = seconds_into_hour   /   60
  seconds            = seconds_into_hour  mod  60
end epoch_to_datetime


#ifdef LINUX

  integer tmp_id                  = 0
  string  tmp_name [MAXSTRINGLEN] = ''

  string proc epoch_to_unix_datetime(integer epoch_seconds)
    integer org_id = GetBufferId()
    string result [maxstringlen] = ''
    string macro_name [maxstringlen] = splitpath(currmacrofilename(), _name_)
    if not tmp_id
      tmp_id   = CreateTempBuffer()
      tmp_name = Format('/tmp/tse_', macro_name, '.tmp')
    endif
    Dos(Format('date -d @', epoch_seconds, ' +%D%l:%M%p > ', tmp_name, ' 2>&1'),
        _DONT_PROMPT_)
    GotoBufferId(tmp_id)
    LoadBuffer(tmp_name)
    result = Trim(GetText(1, MAXSTRINGLEN))
    GotoBufferId(org_id)
    return(result)
  end epoch_to_unix_datetime

#endif


string proc us_format(integer year , integer month  , integer day    ,
                      integer hours, integer minutes, integer seconds)
  string result [MAXSTRINGLEN] = ''
  string us_formatted_hours          [2] = ''
  // A dummy statement to avoid a compiler warning for not using seconds.
  result = Str(seconds)
  if hours == 0
    us_formatted_hours = '12'
  else
    us_formatted_hours = iif(hours > 12, Str(hours - 12), Str(hours))
  endif
  result = Format(month:2:'0'                         , '/',
                  day:2:'0'                           , '/',
                  (year mod 100):2:'0'                , '' ,
                  us_formatted_hours:2                , ':',
                  minutes:2:'0'                       , '' ,
                  iif(hours < 12, 'AM', 'PM'       )       )
  return(result)
end us_format


proc interactive_test()
  string  asked_epoch_seconds [11] = '1579096340'
  string  asked_timezone_hours [3] = '+0'
  string  datetime [MAXSTRINGLEN] = ''
  integer stop                     = FALSE
  integer timezone_hours           = +0
  integer year, month, day, hours, minutes, seconds

  epoch_to_datetime(1483470000, timezone_hours,
                    year, month, day, hours, minutes, seconds)
  datetime = us_format(year, month, day, hours, minutes, seconds)
  Warn('"1483470000" -> "', datetime, '".  Expected for TZ=+0: "01/03/17 7:00PM".')

  epoch_to_datetime(1579096340, timezone_hours,
                    year, month, day, hours, minutes, seconds)
  datetime = us_format(year, month, day, hours, minutes, seconds)
  Warn('"1579096340" -> "', datetime, '".  Expected for TZ=+0: "01/15/20 1:52PM".')

  repeat
    if  Ask('Enter your own epoch seconds:'  , asked_epoch_seconds )
    and Ask('Chose your own time zone hours:', asked_timezone_hours)
      epoch_to_datetime(Val(asked_epoch_seconds ),
                        Val(asked_timezone_hours),
                        year, month, day, hours, minutes, seconds)
      datetime = us_format(year, month, day, hours, minutes, seconds)
      Warn('"', asked_epoch_seconds, '" and "',
           iif(Val(asked_timezone_hours) >= 0, '+', ''),
           Val(asked_timezone_hours), '" -> "', datetime, '".')
    else
      stop = TRUE
    endif
  until stop == TRUE
end interactive_test


proc test_list()
  string  datetime      [MAXSTRINGLEN] = ''
  integer epoch_seconds                = 0
  string  epoch_seconds_from      [11] = '1483470000'
  string  epoch_seconds_step      [11] = '3600'
  string  epoch_seconds_to        [11] = '1579096340'
//string  epoch_seconds_to        [11] = '1483470001'
  string  error_message [MAXSTRINGLEN] = ''
  integer max_calc_len                 = 0
  integer max_unix_len                 = 0
  string  timezone_hours           [3] = '+0'
  string  unix_datetime [MAXSTRINGLEN] = ''
  integer year, month, day, hours, minutes, seconds
  if  Ask('Start from epoch seconds:', epoch_seconds_from)
  and Ask('End at epoch seconds:'    , epoch_seconds_to  )
  and Ask('Step how many seconds:'   , epoch_seconds_step)
  and Ask('Time zone hours:'         , timezone_hours    )
    NewFile()
    AddLine('Time zone hours = '                  +
            iif(Val(timezone_hours) > 0, '+', '') +
            Str(Val(timezone_hours)             ) )
    for epoch_seconds = Val(epoch_seconds_from)
                     to Val(epoch_seconds_to  )
                     by Val(epoch_seconds_step)
      epoch_to_datetime(    epoch_seconds  ,
                        Val(timezone_hours),
                        year, month, day, hours, minutes, seconds)
      datetime      = us_format(year, month, day, hours, minutes, seconds)
      #ifdef LINUX
        unix_datetime = epoch_to_unix_datetime(epoch_seconds)
      #else
        unix_datetime = datetime  // For partial testability under Windows.
      #endif
      max_calc_len  = Max(Length(     datetime), max_calc_len)
      max_unix_len  = Max(Length(unix_datetime), max_unix_len)
      error_message = iif(datetime == unix_datetime, '', 'ERROR')
      AddLine(Format(error_message:-6,
                     epoch_seconds:11,
                     '  ->  Calculated: ', datetime     : max_calc_len * -1,
                     '  Unix: '          , unix_datetime: max_unix_len * -1))
    endfor
  endif
end test_list

proc Main()
  integer selection = 0
  selection = MsgBoxEx('Test',
                       'Select test:',
                       '[&Interactive];[&List];[&Cancel]')
  case selection
    when 1
      interactive_test()
    when 2
      test_list()
  endcase
  PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end Main

