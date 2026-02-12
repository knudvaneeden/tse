/*
  Macro           Recompile
  Author          Carlo.Hogeveen@xs4all.nl
  Version         v1.0.2 - 25 Apr 2020
  Compatibility   Windows TSE Pro v4.0 upwards,
                  Linux TSE Pro Beta v4.41.12 upwards.

  This macro recompiles all macros in TSE's "mac" folder. (*)

  This macro was written for Linux TSE, to alleviate that there recompiling
  all macros would otherwise be a bit more work, but this macro works
  from Windows TSE too.

  Requirement: Write permission in TSE's "mac" folder.


  INSTALLATION
    Put this macro in TSE's "mac" folder, and compile it, for instance by
    opening the file in TSE and using the MAcro Compile menu.


  EXECUTION
    Just execute this macro to recompile all macros.


  (*) Except macros with "&", "(" or ")" in their names.
      Those macros are skipped without logging.


  HISTORY
  v1.0    -  8 Sep 2019
    Initial release.
  v1.0.1  - 25 Mar 2020
    Bug fix: Also skip files with "(" or ")" in name, because Linux would stop
    compiling from such a file onwards, and they are probably just Windows
    copy files.
  v1.0.2  - 25 Apr 2020
    Bug fix: Bad testing on my part: The previous bug fix caused a compile
    error in Linux.
*/



#ifdef LINUX
  string SLASH [1]  = '/'
#else
  string SLASH [1]  = '\'
#endif

string macro_name [MAXSTRINGLEN] = ''


proc show_totals()
  integer macros               = 0
  integer macros_with_errors   = 0
  integer macros_with_notes    = 0
  integer macros_with_warnings = 0
  integer macro_has_errors     = 0
  integer macro_has_notes      = 0
  integer macro_has_warnings   = 0
  integer overall_errors       = 0
  integer overall_notes        = 0
  integer overall_warnings     = 0
  BegFile()
  UpdateDisplay(_ALL_WINDOWS_REFRESH_)
  repeat
    if lFind('^File: ', 'cgx')
      // Add to totals from previous macro
      macros_with_errors   = macros_with_errors   + macro_has_errors
      macros_with_warnings = macros_with_warnings + macro_has_warnings
      macros_with_notes    = macros_with_notes    + macro_has_notes
      // Count this macro and initialize its totals
      macros               = macros + 1
      macro_has_errors     = 0
      macro_has_warnings   = 0
      macro_has_notes      = 0
    elseif lFind('^Error ', 'cgx')
      overall_errors   = overall_errors + 1
      macro_has_errors = 1
    elseif lFind('^Warning ', 'cgx')
      overall_warnings   = overall_warnings + 1
      macro_has_warnings = 1
    elseif lFind('^Note ', 'cgx')
      overall_notes   = overall_notes + 1
      macro_has_notes = 1
    endif
  until not Down()
  // Add to totals from previous macro
  macros_with_errors   = macros_with_errors   + macro_has_errors
  macros_with_warnings = macros_with_warnings + macro_has_warnings
  macros_with_notes    = macros_with_notes    + macro_has_notes
  BegFile()
  Warn(macros              , ' macros: ',
       macros_with_errors  , ' with errors, ',
       macros_with_warnings, ' with warnings, and ',
       macros_with_notes   , ' with notes.',
       Chr(13), Chr(13)    , 'Overall there are ',
       overall_errors      , ' errors, ',
       overall_warnings    , ' warnings, and ',
       overall_notes       , ' notes.')
end show_totals

proc Main()
  string  cmd_fqn [MAXSTRINGLEN] = ''
  integer cmd_id                 = 0
  integer handle                 = 0
  string  log_fqn [MAXSTRINGLEN] = ''
  string  mac_dir [MAXSTRINGLEN] = LoadDir() + 'mac' + SLASH
  // integer org_id                 = GetBufferId()
  log_fqn = mac_dir + macro_name + '.log'
  if      FileExists   (log_fqn)
  and not EraseDiskFile(log_fqn)
    Warn(macro_name, ': Error deleting old log file: ', log_fqn)
  else
    cmd_fqn = mac_dir + macro_name + '.cmd'
    cmd_id  = EditFile(QuotePath(cmd_fqn))
    if not cmd_id
      Warn(macro_name, ': cannot open ', cmd_fqn)
    else
      EmptyBuffer()
      #ifdef LINUX
      #else
        AddLine('echo on')
        if mac_dir[2:1] == ':'
          AddLine(mac_dir[1:2])
        endif
      #endif
      AddLine('cd ' + mac_dir)
      handle = FindFirstFile(mac_dir + '*', -1)
      if handle == -1
        Warn(macro_name, ': Error searching for: ', mac_dir + '*')
      else
        repeat
          if not (FFAttribute() & _DIRECTORY_)
            if (Lower(SplitPath(FFName(), _EXT_)) in '.s', '.si')
#ifdef LINUX
              if  Pos('&', FFName()) == 0 // Skip the "Find&do" macro.
              and Pos('(', FFName()) == 0 // In Linux the compile-cmd stops on
              and Pos(')', FFName()) == 0 // these typical Windows copy names.
#else
              if  Pos('&', FFName()) == 0 // Skip the "Find&do" macro.
#endif
                AddLine(Format('..', SLASH, 'sc32 ', FFName(), ' >> ',
                               macro_name, '.log 2>&1'))
              endif
            endif
          endif
        until not FindNextFile(handle, -1)
        FindFileClose(handle)
        if NumLines()
          if SaveFile()
            #ifdef LINUX
              Dos('. ' + QuotePath(cmd_fqn), _DONT_PROMPT_)
            #else
              Dos(QuotePath(cmd_fqn), _DONT_PROMPT_)
            #endif
            if FileExists(log_fqn)
              EditFile(log_fqn)
              show_totals()
              AbandonFile(cmd_id)
            endif
          else
            Warn(macro_name, ': Error saving: ', CurrFilename())
          endif
        else
          Warn(macro_name, 'Error: no macros found.')
        endif
      endif
    endif
  endif
  PurgeMacro(macro_name)
end Main

proc WhenLoaded()
  macro_name = SplitPath(CurrMacroFilename(), _NAME_)
end WhenLoaded

