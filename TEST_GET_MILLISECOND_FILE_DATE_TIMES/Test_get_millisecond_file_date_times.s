/*
  Macro           Test_get_millisecond_file_date_times
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   Windows TSE GUI v4 upwards
  Version         v1   11 Nov 2022

  The tool asks for a [path and] file or files, wildcards allowed, and returns
  a list of matching files and their last-writtten dates and times to the
  millisecond.

  Example input:
    c:\tse\mac\adjust.s
    c:\tse\mac\*.s*
    c:\tse\mac\*

  Context:
    TSE 4.47 and lower show file times rounded up to the next even second.
    This tool shows a macro way around this limitation.
*/

dll "<Kernel32.dll>"

  integer proc Windows_FindFirstFile(
    string lpFileName:cstrval,
    string lpFindFileData:strptr
    ):"FindFirstFileA"

  integer proc Windows_FindNextFile(
    integer handle,
    string  lpFindFileData:strptr
    ):"FindNextFileA"

  integer proc Windows_FileTimeToSystemTime(
    string lpFileTime:strptr,
    string lpSystemTime:strptr
    ):"FileTimeToSystemTime"

  integer proc Windows_SystemTimeToTzSpecificLocalTime(
    integer lpTimeZoneInformation,
    string  lpUniversalTime:strptr,
    string  lpLocalTime:strptr
    ):"SystemTimeToTzSpecificLocalTime"

  integer proc Windows_FindClose(
    integer hFindFile
    ):"FindClose"
end


integer proc word_to_val(string word)
  integer result = Asc(word[2]) * 256 + Asc(word[1])
  return(result)
end word_to_val


string WEEK_DAYS [56] = 'Sunday Monday Tuesday Wednesday Thursday Friday Saterday'

string proc word_to_dow(string word)
  integer day_of_week = Asc(word[2]) * 256 + Asc(word[1])
  string  result  [9] = ''
  result = GetToken(WEEK_DAYS, ' ', day_of_week + 1)
  return(result)
end word_to_dow


proc Main()
  // A returned file_data structure cab be longer than 255 bytes.
  // Just to be sure I reserved overflow space.
  // For global variables space is reserved in the order of their definition.
  // For local  variables space is reserved in the reverse order.
  string  file_data            [MAXSTRINGLEN] = Format('':MAXSTRINGLEN)
  string  file_data_overflow_1 [MAXSTRINGLEN] = Format('':MAXSTRINGLEN)
  string  file_data_overflow_2 [MAXSTRINGLEN] = Format('':MAXSTRINGLEN)
  string  file_data_overflow_3 [MAXSTRINGLEN] = Format('':MAXSTRINGLEN)
  string  file_data_overflow_4 [MAXSTRINGLEN] = Format('':MAXSTRINGLEN)
  string  file_data_overflow_5 [MAXSTRINGLEN] = Format('':MAXSTRINGLEN)
  string  file_data_overflow_6 [MAXSTRINGLEN] = Format('':MAXSTRINGLEN)
  string  file_data_overflow_7 [MAXSTRINGLEN] = Format('':MAXSTRINGLEN)
  string  file_data_overflow_8 [MAXSTRINGLEN] = Format('':MAXSTRINGLEN)
  string  file_data_overflow_9 [MAXSTRINGLEN] = Format('':MAXSTRINGLEN)
  integer file_handle                         = -1
  string  file_last_write_time            [8] = Format('':8)
  string  file_name            [MAXSTRINGLEN] = ''
  string  local_time           [MAXSTRINGLEN] = Format('':MAXSTRINGLEN)
  string  macro_name           [MAXSTRINGLEN] = SplitPath(CurrMacroFilename(), _NAME_)
  string  path_and_file        [MAXSTRINGLEN] = ''
  string  system_time          [MAXSTRINGLEN] = Format('':MAXSTRINGLEN)

  if  Ask('Enter a [path and] file(s):   (* and ? allowed for file-part)',
          path_and_file,
          GetFreeHistory(macro_name + ':path_and_file'))
  and Trim(path_and_file) <> ''
  and FileExists(Trim(path_and_file))
    path_and_file = Trim(path_and_file)

    file_handle = Windows_FindFirstFile(path_and_file, file_data)
    if file_handle <> -1
      NewFile()
      AddLine('Request:')
      AddLine(path_and_file)
      AddLine()
      AddLine('Result:')
      repeat
        file_name = file_data[45: MAXSTRINGLEN]
        if Pos(Chr(0), file_name)
          file_name = file_name[1: Pos(Chr(0), file_name) - 1]
        endif

        file_last_write_time = file_data[21: 8]
        Windows_FileTimeToSystemTime(file_last_write_time, system_time)
        Windows_SystemTimeToTzSpecificLocalTime(0, system_time, local_time)

        AddLine(Format(word_to_dow(local_time[ 5:2]):-9    ;

                       word_to_val(local_time[ 1:2]):4    , '-',
                       word_to_val(local_time[ 3:2]):2:'0', '-',
                       word_to_val(local_time[ 7:2]):2:'0'     ;

                       word_to_val(local_time[ 9:2]):2    , ':',
                       word_to_val(local_time[11:2]):2:'0', ':',
                       word_to_val(local_time[13:2]):2:'0', '.',
                       word_to_val(local_time[15:2]):3:'0'     ;

                       file_name))
      until not Windows_FindNextFile(file_handle, file_data)
      Windows_FindClose(file_handle)
      BegFile()
    else
      Warn('Error opening file(s).')
    endif
  else
    Message('No selection.')
    Delay(36)
  endif

  // Silence the compiler about apparently not using the overflow strings.
  file_data_overflow_1 = file_data_overflow_1
  file_data_overflow_2 = file_data_overflow_2
  file_data_overflow_3 = file_data_overflow_3
  file_data_overflow_4 = file_data_overflow_4
  file_data_overflow_5 = file_data_overflow_5
  file_data_overflow_6 = file_data_overflow_6
  file_data_overflow_7 = file_data_overflow_7
  file_data_overflow_8 = file_data_overflow_8
  file_data_overflow_9 = file_data_overflow_9

  PurgeMacro(CurrMacroFilename())
end Main

