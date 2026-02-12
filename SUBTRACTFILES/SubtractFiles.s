/*
  Macro           SubtractFiles
  Author          Carlo.Hogeveen@xs4all.nl
  Version         v1.0   -   11 Dec 2019
  Compatibility   TSE Pro v4.0 upwards

  This tool assumes that you want to subtract the lines in the current
  file case-insensitively from the lines in the previous file,
  putting the result in a new file.

  It was created in answer to a user's question on 11 Dec 2019
  in the semware@googlegroups.com mailing list.

  Content-wise as per his example, if the previous file contains:
    AAAU
    ACIM
    ACWF
    ACWX
    ADRD
    ADRE
    ADRU
    AGG
  and the currect file contains:
    ACIM
    ACWF
    AGG
  and the macro is executed, then a new file is created containing:
    AAAU
    ACWX
    ADRD
    ADRE
    ADRU
*/

proc Main()
  integer result_list_id                 = 0
  integer subtractee_list_id             = 0
  string  subtractor_line [MAXSTRINGLEN] = ''
  integer subtractor_list_id             = 0

  subtractor_list_id = GetBufferId()
  PrevFile()
  subtractee_list_id = GetBufferId()
  NextFile()
  result_list_id = NewFile()

  GotoBufferId(subtractee_list_id)
  MarkLine(1, NumLines())
  Copy()
  GotoBufferId(result_list_id)
  Paste()
  UnMarkBlock()

  GotoBufferId(subtractor_list_id)
  BegFile()
  repeat
    subtractor_line = GetText(1, MAXSTRINGLEN)
    GotoBufferId(result_list_id)
    while lFind(subtractor_line, 'gi^$')
      KillLine()
    endwhile
    GotoBufferId(subtractor_list_id)
  until not Down()

  GotoBufferId(result_list_id)
  BegFile()

  PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end Main

