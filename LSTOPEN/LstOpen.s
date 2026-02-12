/*
  Macro           LstOpen
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   Windows TSE PRo v4.0, Linux TSE Beta v4.41.35
  Version         v1.0.1   11 Jun 2021

  This tool list all open files into an editable buffer.

  More specifically, it creates a new TSE buffer, that contains a sorted list
  of the same files and buffers that are shown by TSE's "File List Open" menu.


  INSTALLATION

  Copy this file into TSE's "mac" folder and compile it there, for example by
  opening the file in TSE and applying the Macro Compile menu.

  Execute the tool by executing the macro "LstOpen".
  One way to do this is with the Macro Execute menu.
  My choice was to add "LstOpen" to TSE's Potpourri menu,
  and start it from there without retyping its name every time.


  HISTORY
  v1.0      6 Jun 2021
    Initial version.
  v1.0.1   11 Jun 2021
    Gave the new buffer a signicicant name.
    Improved the documentation.
*/



string MY_MACRO_NAME [MAXSTRINGLEN] = ''

proc WhenLoaded()
  MY_MACRO_NAME = SplitPath(CurrMacroFilename(), _NAME_)
end WhenLoaded

proc Main()
  integer curr_id  = 0
  integer i        = 0
  integer org_id   = GetBufferId()
  integer start_id = 0
  integer list_id  = 0
  string  filename [255] = ""
  list_id = NewFile()
  BufferType(_HIDDEN_)
  GotoBufferId(org_id)
  repeat
    if  start_id     == 0
    and BufferType() == _NORMAL_
      start_id = GetBufferId()
    endif
    filename = CurrFilename()
    curr_id = GetBufferId()
    GotoBufferId(list_id)
    AddLine(filename)
    GotoBufferId(curr_id)
  until not NextFile(_DONT_LOAD_)
    or GetBufferId() == start_id
  GotoBufferId(list_id)
  BufferType(_NORMAL_)
  BegFile()
  if CurrLineLen() == 0
    KillLine()
  endif
  PushBlock()
  MarkLine(1,NumLines())
  Sort(_IGNORE_CASE_)
  PopBlock()
  BegFile()
  i = GetGlobalInt(MY_MACRO_NAME + ':HighestUsedIndex') + 1
  SetGlobalInt(MY_MACRO_NAME + ':HighestUsedIndex', i)
  ChangeCurrFilename('<' + MY_MACRO_NAME  + '-' + Str(i) + '>',
                     _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
  PurgeMacro(MY_MACRO_NAME)
end Main

