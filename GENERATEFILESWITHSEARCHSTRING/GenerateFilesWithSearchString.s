/*
  Macro           GenerateFilesWithSearchString
  Author          Carlo Hogeveen
  Website         ecarlo.nl/tse
  Compatibility   TSE Pro 4.0 upwards
  Version         v1.0

  This tool was created at the request of a user.

  My generalized interpretation of the request was:
    From a file with N different search-recognizable keywords, like
      File.txt:
        apple 123
        banana 234
        apple 626
        carrot 543
        carrot 8464
        banana  09574
    generate N keyword-named files with the corresponding lines, like
      apple.txt:
        apple 123
        apple 626
      banana.txt
        banana  09574
        banana 234
      carror.txt
        carrot 543
        carrot 8464

    Using the above example, you would
    - load "File.txt"
    - execute this macro
    - tell it to search for "^[~ ]#"
      (a keyword is any sequence of non-spaces at the beginning of a line)
    - with search option "x".

    The result is a list of open not-yet-saved files that you can check
    before deciding to save them or not.
*/

proc Main()
  string  files_path    [MAXSTRINGLEN] = SplitPath(CurrFilename(), _DRIVE_|_PATH_)
  string  file_full_name[MAXSTRINGLEN] = SplitPath(CurrFilename(), _DRIVE_|_PATH_)
  string  found_string  [MAXSTRINGLEN] = ''
  integer loop_start_id                = 0
  string  my_macro_name [MAXSTRINGLEN] = SplitPath(CurrMacroFilename(), _NAME_)
  integer ok                           = TRUE
  integer old_InsertLineBlocksAbove    = Set(InsertLineBlocksAbove, OFF)
  integer option_position              = 0
  string  search_options          [12] = ''
  string  search_phase             [1] = 'g'
  string  search_string [MAXSTRINGLEN] = ''
  if Ask('Search string:', search_string,
         GetFreeHistory(my_macro_name + ':search_string'))
    if Ask('Search options:', search_options,
          GetFreeHistory(my_macro_name + ':search_options'))
      option_position = Pos('g', Lower(search_options))
      if option_position
        search_options = search_options[1: option_position - 1] +
                         search_options[option_position + 1: MAXSTRINGLEN]
      endif
      PushLocation()
      while ok
      and   lFind(search_string, search_options + search_phase)
        found_string = GetFoundText()
        if Trim(found_string) <> ''
          MarkLine(CurrLine(), CurrLine())
          PushLocation()
          file_full_name = files_path + '\' + found_string + '.txt'
          if GetBufferId(file_full_name)
            GotoBufferId(GetBufferId(file_full_name))
          else
            ok = EditFile(file_full_name, _DONT_PROMPT_)
            if ok
              CopyBlock()
              UnMarkBlock()
              Down()
            else
              Warn('ERROR: Could not create buffer'; QuotePath(file_full_name))
            endif
          endif
          PopLocation()
        endif
        search_phase = '+'
      endwhile
      if ok
        if BufferType() == _NORMAL_
        or NextFile()
          loop_start_id = GetBufferId()
          repeat
            BegFile()
          until not NextFile()
             or GetBufferId() == loop_start_id
        endif
        PopLocation()
        ExecMacro('ListOpen')
      else
        KillLocation()
      endif
    endif
  endif
  Set(InsertLineBlocksAbove, old_InsertLineBlocksAbove)
  PurgeMacro(my_macro_name)
end Main

