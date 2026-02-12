/*
  Macro           LstRecent
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   Windows TSE PRo v4.0, Linux TSE Beta v4.41.35
  Version         v1   11 Jun 2021

  This tool list all recent files into an editable buffer.

  More specifically, it creates a new TSE buffer, that contains a list of the
  same files and buffers that are shown by TSE's "File List Recent" menu.


  INSTALLATION

  Copy this file into TSE's "mac" folder and compile it there, for example by
  opening the file in TSE and applying the Macro Compile menu.

  Execute the tool by executing the macro "LstRecent".
  One way to do this is with the Macro Execute menu.
  My choice was to add "LstRecent" to TSE's Potpourri menu,
  and start it from there without retyping its name every time.


  HISTORY
  v1.0     11 Jun 2021
    Initial version.
*/



string MY_MACRO_NAME [MAXSTRINGLEN] = ''

proc WhenLoaded()
  MY_MACRO_NAME = SplitPath(CurrMacroFilename(), _NAME_)
end WhenLoaded

proc Main()
  integer i               = 0
  integer old_ClipBoardId = 0
  integer tmp_ClipBoardId = 0
  integer tmp_id          = 0
  PushBlock()
  tmp_ClipBoardId = CreateTempBuffer()
  old_ClipBoardId = Set(ClipBoardId, tmp_ClipBoardId)
  tmp_id          = CreateTempBuffer()
  if GetBufferId('*Recent Files List*')
    GotoBufferId(GetBufferId('*Recent Files List*'))
    MarkLine(1, NumLines())
    Copy()
    GotoBufferId(tmp_id)
    Paste()
  else
    LoadBuffer(LoadDir() + 'tsefiles.dat', -1)
  endif
  // This buffer contains lots of trailing empty lines.
  BegFile()
  while lFind('^$', 'x')
    KillLine()
    Up()
  endwhile
  BegFile()
  if  NumLines()
  and CurrLineLen()
    MarkLine(1, NumLines())
    Copy()
    NewFile()
    Paste()
    BegFile()
  else
    NewFile()
  endif
  i = GetGlobalInt(MY_MACRO_NAME + ':HighestUsedIndex') + 1
  SetGlobalInt(MY_MACRO_NAME + ':HighestUsedIndex', i)
  ChangeCurrFilename('<' + MY_MACRO_NAME  + '-' + Str(i) + '>',
                     _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
  Set(ClipBoardId, old_ClipBoardId)
  PopBlock()
  AbandonFile(tmp_ClipBoardId)
  AbandonFile(tmp_id)
  PurgeMacro(MY_MACRO_NAME)
end Main

