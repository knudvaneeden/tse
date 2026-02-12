/*
  Macro           Makro (Make read-only)
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   Windows TSE v4 upwards
  Version         v2   23 Sep 2022


  PURPOSE

  This tool creates an unsaved .cmd file with "attrib" commands.

  When saved and executed the .cmd adds or removes one file's or all forders'
  and subfolders' and files' read-only attributes.

  You can supply parameters on the macro command line or when asked.

  Parameters:
    {add|remove <fully qualified file or folder name>} ...

  As a safety measure against modifying essential Windows files and such,
  this tool stops when it encounters a system or hidden file or folder.


  NOTE

  Making a file read-only is a very light protection in Windows.
  You can always delete and thereby replace a read-only file.
  And even overwriting is sometimes still possible when the tool you are
  using does not honor the read-only attribute, sometimes after asking
  for confirmation.


  INSTALLATION

  Copy this file to TSE's "mac" folder.
  Compile this file, for instance by opening it in TSE
  and using the Macro -> Compile menu.


  USAGE

  Execute the macro "Makro" with or without parameters, for instance by using
  the Macro -> Execute menu.

  When finished, examine the buffer with the generated .cmd file, and choose
  whether to save and run it.


  HISTORY

  v1      29 Nov 2019
    Initial release.

  v1.0.1   6 Dec 2019
    Fixed stopping on hidden or system dirs "." and "..".

  v2      23 Sep 2022
    Rewrote it to only generate a buffer containg a .cmd file with a command
    per file and folder to add or remove its read-only attribute.
    It therefore no longer needs the SIM pqarameter.
    Changed the action parameters to "add" and "remove".
    Now also adds/removes a read-only attribute for a folder.
*/



// Global constants and semi-constants

#define CCF_FLAGS        _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_
#define EXPLICITLY_TRUE  TRUE
#define IMPLICITLY_TRUE  TRUE * -1
#define HIDDEN_OR_SYSTEM _HIDDEN_ | _SYSTEM_

string  MACRO_NAME [MAXSTRINGLEN] = ''



string proc unquote(string s)
  string r [MAXSTRINGLEN] = s
  if (r[1] in '"', "'")
  and r[1] == r[Length(r)]
    r = r[2:(Length(r) - 2)]
  endif
  return(r)
end unquote


integer proc is_or_in_hidden_or_system(string file_fqn)
  integer file_attributes           = 0
  string  parent_fqn [MAXSTRINGLEN] = file_fqn
  integer result                    = FALSE
  file_attributes = FileExists(parent_fqn)
  while not result
  and   file_attributes
  and   NumTokens(parent_fqn, '\') >= 2
    result = file_attributes & HIDDEN_OR_SYSTEM
    if not result
      parent_fqn = SubStr(parent_fqn, 1,
                          Length(parent_fqn)
                          - Length(GetToken(parent_fqn, '\',
                                            NumTokens(parent_fqn, '\')))
                          - 1)
      file_attributes = FileExists(parent_fqn)
    endif
  endwhile
  return(result)
end is_or_in_hidden_or_system


integer proc modify_ro(string action, string file_name, integer file_attributes)
  integer ok = TRUE
  if file_attributes & _READ_ONLY_
    if action == 'remove'
      AddLine('attrib -r ' + QuotePath(file_name))
    endif
  else
    if action == 'add'
      AddLine('attrib +r ' + QuotePath(file_name))
    endif
  endif
  return(ok)
end modify_ro


integer proc makro(string action, string file_name)
  integer file_attributes = 0
  integer handle          = 0
  integer ok              = TRUE
  if (file_name in '.', '..')
  or file_name[Length(file_name) - 1: 2] == '\.'
  or file_name[Length(file_name) - 2: 3] == '\..'
    NoOp()
  else
    file_attributes = FileExists(file_name)
    if file_attributes
      if not (file_attributes & HIDDEN_OR_SYSTEM)
        if file_attributes & _DIRECTORY_
          modify_ro(action, file_name, file_attributes)
          handle = FindFirstFile(file_name + '\*', -1)
          if handle <> -1
            repeat
              ok = makro(action, file_name + '\' + FFName())
            until not ok
               or not FindNextFile(handle, -1)
            FindFileClose(handle)
          endif
        else
          modify_ro(action, file_name, file_attributes)
        endif
      else
        AddLine('Stopping on system or hidden file:')
        AddLine('  ' + file_name)
        UpdateDisplay(_ALL_WINDOWS_REFRESH_)
        Warn('Stopping on system or hidden file: ', file_name)
        ok = FALSE
      endif
    else
      AddLine('Stopping on non-existing file:')
      AddLine('  ' + file_name)
      UpdateDisplay(_ALL_WINDOWS_REFRESH_)
      Warn('Stopping on non-existing file: ', file_name)
      ok = FALSE
    endif
  endif
  return(ok)
end makro


proc WhenLoaded()
  MACRO_NAME = SplitPath(CurrMacroFilename(), _NAME_)
end WhenLoaded


proc Main()
  string  action     [MAXSTRINGLEN] = ''
  integer cmd_id                    = 0
  string  cmd_name   [MAXSTRINGLEN] = ''
  string  file_name  [MAXSTRINGLEN] = ''
  integer i                         = 0
  integer ok                        = TRUE
  integer org_id                    = GetBufferId()
  string  parameters [MAXSTRINGLEN] = Trim(Query(MacroCmdLine))
  string  postfix    [MAXSTRINGLEN] = Trim(Query(MacroCmdLine))
  string  token      [MAXSTRINGLEN] = Trim(Query(MacroCmdLine))

  NewFile()
  repeat
    cmd_name = GetEnvStr('TMP') + '\Tse_' + MACRO_NAME + postfix + '.cmd'
    ok       = ChangeCurrFilename(cmd_name, CCF_FLAGS)
    i        = i + 1
    postfix  = '_' + Str(i)
  until ok
    and i < 1000
    and not FileExists(cmd_name)

  ok = ok and not FileExists(cmd_name)

  if ok
    if parameters == ''
      i = MsgBoxEx('Action for read-only attributes',
                   'Add or remove read-only attributes?',
                   '[&Add];[&Remove];[&Cancel]')
      case i
        when 1
          action = 'add'
        when 2
          action = 'remove'
        otherwise
          ok     = FALSE
      endcase

      if  ok
      and Ask('For which file or folder [' + CurrDir() + ']:', file_name,
              GetFreeHistory(MACRO_NAME + ':file_name'))
        file_name = RemoveTrailingSlash(unquote(Trim(file_name)))
        if not FileExists(file_name)
          Warn('Not a file or folder:'; QuotePath(file_name))
          ok = FALSE
        endif
      endif

      if ok
        if is_or_in_hidden_or_system(file_name)
          Warn('Is (in) hidden or system fir or folder:'; QuotePath(file_name))
          ok = FALSE
        else
          ok = makro(action, file_name)
        endif
      endif
    else
      for i = 1 to NumFileTokens(parameters)
        if ok
          token = GetFileToken(parameters, i)
          if (Lower(token) in 'add', 'remove')
            action = Lower(token)
          else
            file_name = RemoveTrailingSlash(unquote(Trim(token)))
            if FileExists(file_name)
              if action == ''
                Warn('No action provided for:'; QuotePath(file_name))
                ok = FALSE
              else
                if is_or_in_hidden_or_system(file_name)
                  Warn('Is (in) hidden or system fir or folder:'; QuotePath(file_name))
                  ok = FALSE
                else
                  ok        = makro(action, file_name)
                  action    = ''
                  file_name = ''
                endif
              endif
            endif
          endif
        endif
      endfor
    endif
  endif
  if not ok
    GotoBufferId(org_id)
    AbandonFile(cmd_id)
  endif
  PurgeMacro(MACRO_NAME)
end Main

