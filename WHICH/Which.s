/*
  Macro   Which
  Author  Carlo.Hogeveen@xs4all.nl
  Date    29 may 2011
  Version 1.0.0
  date    29 May 2011

  Input:
    Asks for plain partial filename (without drive or directories).
    Wildcards and/or regular expressions are not supported.
  Output:
    When you Escaped or otherwise didn't supply a partial filename:
      Lists all PATH directories in an easier to read format.
    Otherwise:
      Lists those files in the directories from the PATH environment
      variable, which contain that part in their name, in the order
      in which the directories appear in the PATH environment variable.

  Nota bene:
    Depending on the way and/or place from which you started TSE,
    TSE might see a different value for the PATH environment variable,
    and in such a case this macro will list a corresponding different result.

  Technical note:
    PATH's can easily be longer than TSE's maximum string length, so we can't
    simply use TSE's GetEnvStr() function to get the PATH.
*/

integer ok = TRUE
string macro_name [MAXSTRINGLEN] = ''

proc WhenLoaded()
  macro_name = SplitPath(CurrMacroFilename(), _NAME_)
end WhenLoaded

proc Main()
  string  env_vars                 [17] = 'tmp;TMP;temp;TEMP'
  string  tmp_dir        [MAXSTRINGLEN] = ''
  string  path_dir       [MAXSTRINGLEN] = ''
  string  file_name_part [MAXSTRINGLEN] = ''
  integer i                             = 0
  integer pos_from                      = 0
  integer pos_to                        = 0
  integer new_id                        = 0
  integer tmp_id                        = 0
  integer handle                        = 0
  Ask('Search which filename(part) in PATH?   (Escape lists PATH)',
      file_name_part,
      GetFreeHistory(macro_name + ':file_name_part'))
  if ok
    while i <= 4
    and   tmp_dir == ''
      i = i + 1
      tmp_dir = GetEnvStr(GetToken(env_vars, ';', i))
      if not (FileExists(tmp_dir) & _DIRECTORY_)
        Warn('Environment variable ', tmp_dir, ' contains non-existing directory.')
        tmp_dir = ''
      endif
    endwhile
    if tmp_dir == ''
      ok = FALSE
      Warn('No temporary directories found in environment variables ', env_vars)
    endif
  endif
  if ok
    if SubStr(tmp_dir, Length(tmp_dir), 1) <> '\'
      tmp_dir = tmp_dir + '\'
    endif
    if not (FileExists(tmp_dir + 'tse') & _DIRECTORY_)
      Dos('mkdir "' + tmp_dir + 'tse"', _DONT_PROMPT_|_DONT_CLEAR_|_HIDDEN_)
      Delay(1)
      if not (FileExists(tmp_dir + 'tse') & _DIRECTORY_)
        ok = FALSE
        Warn('Error creating ' + tmp_dir + 'tse')
      endif
    endif
  endif
  if FileExists(tmp_dir + 'tse\' + macro_name + '.tmp')
    Dos('del ' + tmp_dir + 'tse\' + macro_name + '.tmp',
        _DONT_PROMPT_|_DONT_CLEAR_|_HIDDEN_)
    Delay(1)
    if FileExists(tmp_dir + 'tse\' + macro_name + '.tmp')
      ok = FALSE
      Warn('Error deleting ' + tmp_dir + 'tse\' + macro_name + '.tmp')
    endif
  endif
  if ok
    Dos('path > ' + tmp_dir + 'tse\' + macro_name + '.tmp',
        _DONT_PROMPT_|_DONT_CLEAR_|_HIDDEN_)
    Delay(1)
    if not FileExists(tmp_dir + 'tse\' + macro_name + '.tmp')
      ok = FALSE
      Warn('Error creating ' + tmp_dir + 'tse\' + macro_name + '.tmp')
    endif
  endif
  if ok
    new_id = NewFile()
    tmp_id = CreateTempBuffer()
    LoadBuffer(tmp_dir + 'tse\' + macro_name + '.tmp')
    BegFile()
    if Lower(GetText(1, 5)) == 'path='
      DelChar(5)
    endif
    while not (CurrChar() in _AT_EOL_, _BEYOND_EOL_)
      pos_from = CurrPos()
      if lFind(';', '')
        Right()
        pos_to = CurrPos() - 2
      else
        EndLine()
        pos_to = CurrPos() - 1
      endif
      path_dir = GetText(pos_from, pos_to - pos_from + 1)
      if file_name_part == ''
        AddLine(path_dir, new_id)
      else
        handle = FindFirstFile(path_dir + '\*', -1)
        if handle <> -1
          repeat
            if Pos(Lower(file_name_part), Lower(FFName())) > 0
              AddLine(path_dir + '\' + FFName(), new_id)
            endif
          until not FindNextFile(handle, -1)
          FindFileClose(handle)
        endif
      endif
    endwhile
    GotoBufferId(new_id)
    AbandonFile(tmp_id)
    BegFile()
    FileChanged(FALSE)
  endif
  if ok
    Dos('del ' + tmp_dir + 'tse\' + macro_name + '.tmp',
        _DONT_PROMPT_|_DONT_CLEAR_|_HIDDEN_)
    Delay(1)
  endif
  PurgeMacro(macro_name)
end Main

