/*
  As distributed this test file creates a log file of all positions in all
  lines in all open files that case-insensitively contain the letter 'e'.
*/

#Include ['Repeatable_lFind_lRepeatFind.inc']

proc Main()
  integer log_id = 0
  PushPosition()
  log_id = CreateTempBuffer()
  PopPosition()
  if repeatable_lFind('e', 'ai')
    repeat
      AddLine(Format('Found at line'; CurrLine():Length(Str(NumLines()));
                     'at pos'       ; CurrPos() :Length(Str(LongestLineInBuffer()));
                     'in file'      ; CurrFilename()),
              log_id)
    until not repeatable_lRepeatFind()
  else
    AddLine('No occurrences found.', log_id)
  endif
  GotoBufferId(log_id)
  BufferType(_NORMAL_)
  BegFile()
  PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end Main

