/*
  Extension       UniExplorer_debug
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   Windows GUI TSE v4.50.27 upwards
  Version         v0.0.0.1   30 Oct 2026
  Local package   1.0.0.0.19   27 Nov 2026 (debug code unchanged)


  This macro is part of a work-around to run UniExplorer in TSE's debugger.

  The work-around:
  - Autoload UniExplorer_debug instead of UniExplorer.
  - Open a file from Windows File Explorer.
    UniExplorer_debug remembers the filename and opens uniexplorer.s instead.
  - Apply the menu Macro -> Debug on the open uniexplorer.s file.
    UniExplorer runs in TSE's debugger and uses the remembered filename.

*/


#define DOUBLE_QUOTE          34
#define MAX_CMDLINE_LENGTH    8191
#define MAX_CMDLINE_LENGTH_W  MAX_CMDLINE_LENGTH * 2


dll "<Kernel32.dll>"
  /*
    https://learn.microsoft.com/en-us/windows/win32/api/processenv/nf-processenv-getcommandlinew

    LPWSTR GetCommandLineW();
  */
  integer proc GetCommandLineW()
end


integer proc num_double_quotes_w(integer cmdline_address)
  integer c = 0
  integer i = 0
  integer r = 0

  for i = 0 to MAX_CMDLINE_LENGTH_W * 2 - 2
    c = PeekWord(AdjPtr(cmdline_address, i))
    if     c == DOUBLE_QUOTE
      r = r + 1
    elseif c == 0
      NoOp()
      break
    endif
  endfor

  return(r)
end num_double_quotes_w


proc check_command_line()
  integer c                = 0
  integer cmdline_address  = 0
  integer i                = 0
  integer org_id           = GetBufferId()
  string  s [MAXSTRINGLEN] = ''
  integer tmp_id           = 0

  //  The command line is returned as a double-quoted executable,
  //  always followed by a space even if there are no parameters,
  //  and then space-separated double-quoted parameters.
  //  The sometimes superfluous space is a Windows legacy quirk
  //  that serves no purpose.
  cmdline_address = GetCommandLineW()

  if num_double_quotes_w(cmdline_address) == 4
    tmp_id = CreateTempBuffer()
    ChangeCurrFilename(SplitPath(CurrMacroFilename(), _NAME_) + ':DosCmdLine',
                       _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
    AddLine()
    BegLine()
    c = PeekWord(AdjPtr(cmdline_address, i))
    while c
      //  Insert bytes in original UTF-16LE order.
      InsertText(Chr(c mod 256), _INSERT_)
      InsertText(Chr(c  /  256), _INSERT_)
      i = i + 2
      c = PeekWord(AdjPtr(cmdline_address, i))
    endwhile
    Set(DosCmdLine, '')
    //  The Lower() is for a bug in TSE 4.50.32,
    //  that lowercases CurrMacroFilename() in the TSE debugger.
    s = Lower(SplitPath(CurrMacroFilename(), _NAME_) + ':DosCmdLine')
    SetGlobalInt(s, tmp_id)
    GotoBufferId(org_id)
    s = SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_|_NAME_)
    s = SubStr(s, 1, Length(s) - Length('_debug'))
    s = s + '.s'
    EditThisFile(s)
  endif
end check_command_line


proc WhenLoaded()
  check_command_line()
  PurgeMacro(CurrMacroFilename())
end WhenLoaded

