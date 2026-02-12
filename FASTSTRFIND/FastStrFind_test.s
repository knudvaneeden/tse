/*
  Macro     FastStrFind_test
  Author    Carlo Hogeveen
  Website   eCarlo.nl/tse
  Version   1 - 13 Feb 2021

  This is an executable macro that demonstrates and tests how the include
  file FastStrFind.inc and its procedure FastStrFind() is used.

  Just compile and execute this macro to see it produce and log test results.
*/

#Include ['FastStrFind.inc']

proc Main()
  integer i             = 0
  integer len           = 0
  integer max_time_size = 6
  integer sample_size   = 1000000
  integer time          = 0

  Message('Running ...')
  NewFile() // Log file
  AddLine('')
  AddLine(Format('The times are for'; sample_size; 'executions of each command.'))
  AddLine('')

  if      StrFind( '22', '111222333222111', '', 0, len) <>
     FastStrFind( '22', '111222333222111', '', 0, len)
    AddLine("Error: StrFind( '22', '111222333222111', '', 0, len) <> FastStrFind( '22', '111222333222111', '', 0, len)")
    AddLine(Format('      ';      StrFind('22', '111222333222111', '', 0, len);
                   '<>'    ; FastStrFind('22', '111222333222111', '', 0, len)))
    AddLine('')
  endif

  time = GetTime()
  for i = 1 to sample_size
    StrFind( '22', '111222333222111', '', 0, len)
  endfor
  AddLine(Format('Slow StrFind,  forward, find 1st:'; GetTime()-time:max_time_size; 'centiseconds.'))

  time = GetTime()
  for i = 1 to sample_size
    FastStrFind( '22', '111222333222111', '', 0, len)
  endfor
  AddLine(Format('Fast StrFind,  forward, find 1st:'; GetTime()-time:max_time_size; 'centiseconds.'))

  AddLine('')

  if      StrFind( '22', '111222333222111', '', 4, len) <>
     FastStrFind( '22', '111222333222111', '', 4, len)
    AddLine("Error: StrFind( '22', '111222333222111', '', 4, len) <> FastStrFind( '22', '111222333222111', '', 4, len)")
    AddLine(Format('      ';      StrFind('22', '111222333222111', '', 4, len);
                   '<>'    ; FastStrFind('22', '111222333222111', '', 4, len)))
    AddLine('')
  endif

  time = GetTime()
  for i = 1 to sample_size
    StrFind( '22', '111222333222111', '', 4, len)
  endfor
  AddLine(Format('Slow StrFind,  forward, find 4th:'; GetTime()-time:max_time_size; 'centiseconds.'))

  time = GetTime()
  for i = 1 to sample_size
    FastStrFind( '22', '111222333222111', '', 4, len)
  endfor
  AddLine(Format('Fast StrFind,  forward, find 4th:'; GetTime()-time:max_time_size; 'centiseconds.'))

  AddLine('')

  if      StrFind( '22', '111222333222111', 'b', 0, len) <>
     FastStrFind( '22', '111222333222111', 'b', 0, len)
    AddLine("Error: StrFind( '22', '111222333222111', 'b', 0, len) <> FastStrFind( '22', '111222333222111', 'b', 0, len)")
    AddLine(Format('      ';      StrFind('22', '111222333222111', 'b', 0, len);
                   '<>'    ; FastStrFind('22', '111222333222111', 'b', 0, len)))
    AddLine('')
  endif

  time = GetTime()
  for i = 1 to sample_size
    StrFind( '22', '111222333222111', 'b', 0, len)
  endfor
  AddLine(Format('Slow StrFind, backward, find 1st:'; GetTime()-time:max_time_size; 'centiseconds.'))

  time = GetTime()
  for i = 1 to sample_size
    FastStrFind( '22', '111222333222111', 'b', 0, len)
  endfor
  AddLine(Format('Fast StrFind, backward, find 1st:'; GetTime()-time:max_time_size; 'centiseconds.'))

  AddLine('')

  if      StrFind( '22', '111222333222111', 'b', 4, len) <>
     FastStrFind( '22', '111222333222111', 'b', 4, len)
    AddLine("Error: StrFind( '22', '111222333222111', 'b', 4, len)'")
    AddLine("         <> FastStrFind( '22', '111222333222111', 'b', 4, len)")
    AddLine(Format('      ';      StrFind('22', '111222333222111', 'b', 4, len);
                   '<>'    ; FastStrFind('22', '111222333222111', 'b', 4, len)))
    AddLine('       The first value 0 is from StrFind() and is incorrect, caused by a')
    AddLine('       known bug when searching backwards for an Nth occurrence where N > 1.')
    AddLine('       The second value 4 is from FastStrFind() and is correct.')
    AddLine('')
  endif

  time = GetTime()
  for i = 1 to sample_size
    StrFind( '22', '111222333222111', 'b', 4, len)
  endfor
  AddLine(Format('Slow StrFind, backward, find 4th:'; GetTime()-time:max_time_size; 'centiseconds.'))

  time = GetTime()
  for i = 1 to sample_size
    FastStrFind( '22', '111222333222111', 'b', 4, len)
  endfor
  AddLine(Format('Fast StrFind, backward, find 4th:'; GetTime()-time:max_time_size; 'centiseconds.'))

  AddLine('')

  time = GetTime()
  for i = 1 to sample_size
    StrFind( '11', '111222333222111', '^', 0, len)
  endfor
  AddLine(Format('Slow StrFind,  forward, find beg:'; GetTime()-time:max_time_size; 'centiseconds.'))

  time = GetTime()
  for i = 1 to sample_size
    FastStrFind( '11', '111222333222111', '^', 0, len)
  endfor
  AddLine(Format('Fast StrFind,  forward, find beg:'; GetTime()-time:max_time_size; 'centiseconds.'))

  AddLine('')

  time = GetTime()
  for i = 1 to sample_size
    StrFind( '11', '111222333222111', '$', 0, len)
  endfor
  AddLine(Format('Slow StrFind,  forward, find end:'; GetTime()-time:max_time_size; 'centiseconds.'))

  time = GetTime()
  for i = 1 to sample_size
    FastStrFind( '11', '111222333222111', '$', 0, len)
  endfor
  AddLine(Format('Fast StrFind,  forward, find end:'; GetTime()-time:max_time_size; 'centiseconds.'))

  AddLine('')

  BegFile()
  FileChanged(FALSE)
  Message('Done.')
end Main

