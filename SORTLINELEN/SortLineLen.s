/*
  Macro           SortLineLen
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   TSE v4.0 upwards
  Version         1.1   13 Jan 2022

  This tool sorts all lines from the current buffer on their length
  into a new unnamed buffer.


  INSTALLATION

  Copy this file to TSE's "mac" folder, and compile it there, for example
  by opening the file in TSE and applying its Macro Compile menu.


  USE

  Go to the TSE buffer you want to sort, and execute SortLineLen as a macro,
  for example by opening the Macro Execute menu and entering "SortLineLen".


  HISTORY

  v1     12 Jan 2022
    Initial release.

  v1.1   13 Jan 2022
    No longer modifies the current buffer, but creates a new unnamed buffer.
    Improved the progress messages, which mattered for very large files.
*/

proc Main()
  integer all_messages           = (Query(MsgLevel) == _ALL_MESSAGES_)
  integer i                      = 0
  integer line_nr_new            = 0
  integer line_nr_old            = 0
  integer max_line_length_length = Length(Str(LongestLineInBuffer()))
  integer max_line_nr_length     = Length(Str(NumLines()))
  integer new_id                 = 0
  integer num_lines              = NumLines()
  integer org_id                 = GetBufferId()
  integer sort_id                = 0
  if num_lines
    PushLocation()
    sort_id = CreateTempBuffer()
    new_id  = NewFile()
    SetUndoOff()
    GotoBufferId(org_id)
    BegFile()
    repeat
      if  all_messages
      and CurrLine() mod 10000 == 0
        Message('Collecting sort keys'; CurrLine() / (NumLines() / 100); '%')
      endif
      AddLine(Format(CurrLine():max_line_nr_length;
                     CurrLineLen():max_line_length_length),
              sort_id)
    until not Down()
    if all_messages
      Message('Sorting the sort keys')
    endif
    GotoBufferId(sort_id)
    MarkColumn(1, max_line_nr_length + 2, NumLines(),
               max_line_nr_length + 2 + max_line_length_length - 1)
    ExecMacro('sort')
    UnMarkBlock()
    if all_messages
      Message('Creating the sorted buffer')
    endif
    GotoBufferId(new_id)
    for i = 1 to num_lines
      AddLine('')
    endfor
    GotoBufferId(sort_id)
    BegFile()
    repeat
      if  all_messages
      and CurrLine() mod 10000 == 0
        Message('Creating the sorted buffer'; CurrLine() / (NumLines() / 100); '%')
      endif
      line_nr_new = CurrLine()
      line_nr_old = Val(GetText(1, max_line_nr_length))
      GotoBufferId(org_id)
      GotoLine(line_nr_old)
      MarkColumn(CurrLine(), 1, CurrLine(), CurrLineLen())
      Copy()
      GotoBufferId(new_id)
      GotoLine(line_nr_new)
      BegLine()
      Paste()
      GotoBufferId(sort_id)
    until not Down()
    PopLocation()
    GotoBufferId(new_id)
    BegFile()
    SetUndoOn()
    AbandonFile(sort_id)
    if Query(MsgLevel) == _ALL_MESSAGES_
      Message('Done.')
    endif
  else
    NewFile()
    if Query(MsgLevel) == _ALL_MESSAGES_
      Message('Done.')
    endif
  endif
  PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end Main

