/*
  Macro           GetTabSize_Test
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   Windows TSE Pro v4.0 upwards
  Version         v1   24 Aug 2021

  This tool tests the GetTabSize tool on all text files in a folder
  by supplying just the folder name (without wildcard characters),
  though you can supply just a single filename too.

  If you supply a folder, then subfolders are tested too.
  Non-text files are listed with tab size "-".
  Determining which files are text files works very well for the purpose and
  context of this test.


  INSTALLATION AND USAGE

  Obviously you need to install GetTabSize first.

  Then copy this file to TSE's "mac" folder, and compile and execute it,
  for example by opening it there in TSE and applying the Macro Compile menu.

  Default it offers to determine the tab sizes of all text files in your TSE
  folder.

  I found it helpful and interesting to sort the resulting report on tab size.
*/



// Global constants
#ifdef LINUX
  string SLASH [1] = '/'
#else
  string SLASH [1] = '\'
#endif

// Global variables
integer log_id  = 0
integer file_id = 0



// Start of the independent is_text_file(file_name) function.

// This function determines whether a disk file is a text file.

// After testing with different criteria it works to my satisfaction.
// It is not perfect, but it "fails" in cases that are arguably ambiguous.

integer      is_text_file_id = 0

integer proc is_text_file(string file_name)
  integer non_newline_chars     = 0
  integer org_id                = GetBufferId()
  integer printable_ascii_chars = 0
  integer result                = FALSE
  integer total_chars           = 0

  // For debugging
  if SubStr(SplitPath(file_name, _NAME_), 1, 5) == 'teeny'
    result = result
  endif

  if FileExists(file_name)
    if is_text_file_id
      GotoBufferId(is_text_file_id)
    else
      is_text_file_id = CreateTempBuffer()
    endif
    LoadBuffer(file_name, 8192)
    if NumLines()
      EndFile()
      total_chars = (NumLines() - 1) * 8192 + CurrLineLen()
      if total_chars
        BegFile()
        repeat
          case CurrChar()
            when 20 .. 126
              non_newline_chars     = non_newline_chars     + 1
              printable_ascii_chars = printable_ascii_chars + 1
            when 10, 13
              NoOp()
            otherwise
              non_newline_chars     = non_newline_chars     + 1
          endcase
        until not NextChar()
        if non_newline_chars
          if non_newline_chars > MAXINT / 1000
            if printable_ascii_chars / (non_newline_chars / 100) >= 80  // >= 80%
              result = TRUE
            endif
          else
            if (printable_ascii_chars * 100) / non_newline_chars >= 80  // >= 80%
              result = TRUE
            endif
          endif
        endif
      endif
    endif
    EmptyBuffer()
    GotoBufferId(org_id)
  endif
  return(result)
end is_text_file

// End of the independent is_text_file(file_name) function.



proc get_file_tab_size(string file_name)
  integer old_MsgLevel = Query(MsgLevel)
  KeyPressed()
  Message(file_name)
  KeyPressed()
  if is_text_file(file_name)
    Set(MsgLevel, _NONE_)
    LoadBuffer(file_name)
    Set(MsgLevel, old_MsgLevel)
    // ExecMacro('GetTabSize_0_1 silently')
    ExecMacro('GetTabSize method2 silently')
    AddLine(Format(Query(MacroCmdLine):10, '   ', file_name), log_id)
  else
    AddLine(Format('-':10, '   ', file_name), log_id)
  endif
end get_file_tab_size

proc get_dir_tab_sizes(string dir)
  integer handle = FindFirstFile(dir + SLASH + '*', -1)
  KeyPressed()
  Message(dir)
  KeyPressed()
  if handle <> -1
    repeat
      if SubStr(FFName(), 1, 1) <> '.'  // Ignores ., .., .git, etcetera.
        if FFAttribute() & _DIRECTORY_
          get_dir_tab_sizes(dir + SLASH + FFName())
        else
          get_file_tab_size(dir + SLASH + FFName())
        endif
      endif
    until not FindNextFile(handle, -1)
    FindFileClose(handle)
  endif
end get_dir_tab_sizes

string proc unquote(string s)
  string result [MAXSTRINGLEN] = s
  if (result[1: 1] in '"', "'")
  and result[1: 1] == result[1: Length(result)]
    result = result[2: Length(result) - 2]
  endif
  return(result)
end unquote

proc Main()
  string dir_or_file [MAXSTRINGLEN] = ''
  string macro_name  [MAXSTRINGLEN] = SplitPath(CurrMacroFilename(), _NAME_)
  dir_or_file = GetHistoryStr(GetFreeHistory(macro_name + ':dir_or_file'), 1)
  if dir_or_file == ''
    dir_or_file = QuotePath(RemoveTrailingSlash(LoadDir()))
  endif
  if Ask('Get the tab sizes for which file or for all files in which folder:',
         dir_or_file,
         GetFreeHistory(macro_name + ':dir_or_file'))
    dir_or_file = RemoveTrailingSlash(unquote(trim(dir_or_file)))
    log_id = NewFile()
    AddLine('  Tab Size   File Name', log_id)
    file_id = CreateTempBuffer()
    if FileExists(dir_or_file) & _DIRECTORY_
      get_dir_tab_sizes(dir_or_file)
    else
      get_file_tab_size(dir_or_file)
    endif
    GotoBufferId(log_id)
    BegFile()
    AbandonFile(file_id)
  endif
  PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end Main

