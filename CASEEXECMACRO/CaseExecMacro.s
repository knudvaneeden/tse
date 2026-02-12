/*
  Macro           CaseExecMacro
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   Windows TSE v4       upwards,
                  Linux   TSE v4.41.12 upwards
  Version         v1.0.1   17 Sep 2022


  FUNCTIONALITY

  For Linux TSE this tool repairs ExecMacro commands in loaded user interface
  (UI) and macro files that try to execute (other) macros with a differently
  cased name than their disk name in TSE's "mac" folder.

  Linux-specific example:
    In a UI or macro file the command ExecMacro('Adjust') does not work if the
    macro's disk name is tse/mac/adjust.s .

  When this tool is executed it examines all loaded files
  and sets the case of all macro names in ExecMacro commands
  to the case of their corresponding macro source file in TSE's "mac" folder.


  So typically before you run this macro you load a user interface (UI) file,
  or a key definition file, or a macro source file.

  Or you just load all macro source files at once. (Tip: both *.s and *.S)

  Then execute this tool.

  It creates an unsaved report of the changes it made, and it does not save the
  changed files, so you can examine the report and the changed files at your
  leisure.


  This tool might not work for non-standard settings, but at worst it should do
  too little, and not create new errors. That said, it is always a good idea to
  make backups, and that should include your TSE folder.


  INSTALLATION

  Just put this macro source file in TSE's "mac" folder and compile it there,
  for instance by opening the file in TSE and using the Macro Compile menu.


  NOTES

  Tip:
  Get the Recompile macro, which recompiles all TSE macros in one go.
  Very handy after using this macro to bulk-repair ExecMacro commands.

  Windows functionality:
  This tool does run in Windows TSE, but beware that there you might have
  different macros and they might be differently cased, so you take a a high
  risk if you case a UI or macro file in Windows and then copy it to Linux.
  Since Windows TSE is case-insensitive, using it in Windows just for Windows
  has no functional result.

  Aside:
  Another Linux TSE issue is "include files".
  I found they mostly occur in obsolete macros that do not run anyway any more.
  The very few macros where they still have a function I adjusted manually.


  HISTORY

  v1        8 Sep 2019
    Initial release.

  v1.0.1   17 Sep 2022
    Fixed incompatibility with TSE's '-i' command line option
    and the TSELOADDIR environment variable.

*/



#ifdef LINUX
  #define IS_NOT_LINUX FALSE
  string  SLASH [1]  = '/'
#else
  #define IS_NOT_LINUX TRUE
  string  SLASH [1]  = '\'
#endif



/*
  Return TSE's original LoadDir() if LoadDir() has been redirected
  by TSE's "-i" commandline option or a TSELOADDIR environment variable.
*/
string proc original_LoadDir()
  return(SplitPath(LoadDir(TRUE), _DRIVE_|_PATH_))
end original_LoadDir



/*
  Given a searched object type (directory or file) in a given parent directory,
  return the object on disk that exactly matches the old object name,
  or otherwise the first one that matches it except for case,
  or otherwise an empty string.
*/
string proc get_disk_name(integer p_disk_object_type,
                          string  p_parent_path,
                          string  p_old_name)
  integer disk_object_type           = p_disk_object_type
  integer found                      = FALSE
  integer handle                     = 0
  string  new_name    [MAXSTRINGLEN] = ''
  string  parent_path [MAXSTRINGLEN] = p_parent_path
  if parent_path == ''
    parent_path = CurrDir()
  endif
  if      Length(parent_path)
  and not (parent_path[Length(parent_path): 1] in '/', '\')
    parent_path = parent_path + SLASH
  endif
  if p_disk_object_type <> _DIRECTORY_
    disk_object_type = -1  // All
  endif
  handle = FindFirstFile(parent_path + '*', disk_object_type)
  if handle <> -1
    repeat
      if EquiStr(FFName(), p_old_name)
        // We have at least a case-insensitive match ...
        if disk_object_type              == _DIRECTORY_ // We searched for that.
        or (FFAttribute() & _DIRECTORY_) == 0 // Searched all, now limit to file.
          // ... now of an object of the searched-for type ...
          if IS_NOT_LINUX
          or FFName() == p_old_name
            // A Windows match or a case-sensitive match:
            // Pick it and stop searching.
            new_name = FFName()
            found    = TRUE
          else
            // A case-insensitive Linux match:
            // Pick the first one, keep searching for a case-sensitive match.
            if new_name == ''
              new_name = FFName()
            endif
          endif
        endif
      endif
    until found
       or not FindNextFile(handle, -1)
    FindFileClose(handle)
  endif
  return(new_name)
end get_disk_name



proc Main()
  string  called_macro_name [MAXSTRINGLEN] = ''
  integer execmacros_adjusted              = 0
  string  disk_name         [MAXSTRINGLEN] = ''
  integer file_adjusted                    = FALSE
  integer files_adjusted                   = 0
  integer line_nr_width                    = 0
  string  my_wordset_chars            [10] = 'A-Za-z0-9_'
  integer old_loadwildfrominside           = Set(LoadWildFromInside, OFF)
  string  old_wordset                 [32] = Set(WordSet, ChrSet(my_wordset_chars))
  integer org_id                           = GetBufferId()
  integer report_id                        = 0
  integer start_id                         = 0
  PrevFile()
  NextFile()
  if BufferType() == _NORMAL_
    start_id  = GetBufferId()
    report_id = NewFile()
    BufferType(_HIDDEN_)
    GotoBufferId(start_id)
    repeat
      PushPosition()
      file_adjusted = FALSE
      line_nr_width = Length(Str(NumLines()))
      BegFile()
      while lFind('ExecMacro("|' + "'" + '\c[' + my_wordset_chars + ']', 'ix+')
        called_macro_name = GetWord()
        disk_name = get_disk_name(not(_DIRECTORY_),
                                  original_LoadDir() + 'mac' + SLASH,
                                  called_macro_name + '.s')
        if EquiStr(disk_name[Length(disk_name) - 1: 2], '.s')
          disk_name = disk_name[1: Length(disk_name) - 2]
        endif
        if  EquiStr(called_macro_name ,  disk_name)
        and         called_macro_name <> disk_name
          if not file_adjusted
            AddLine('File: ' + CurrFilename(), report_id)
            AddLine('', report_id)
            files_adjusted = files_adjusted + 1
            file_adjusted  = TRUE
          endif
          execmacros_adjusted = execmacros_adjusted + 1
          AddLine(Format(CurrLine():line_nr_width, ' ',
                         Trim(GetText(1, CurrLineLen()))),
                  report_id)
          if not MarkWord()
          or not KillBlock()
          or not InsertText(disk_name, _INSERT_)
            AddLine(Format(CurrLine():line_nr_width, ' ERROR!'), report_id)
          endif
          AddLine(Format(CurrLine():line_nr_width, ' ',
                         Trim(GetText(1, CurrLineLen()))),
                  report_id)
          AddLine('', report_id)
        endif
      endwhile
      PopPosition()
    until not NextFile()
       or GetBufferId() == start_id
  else
    GotoBufferId(org_id)
    Warn('No normal buffers found: No action.')
  endif
  if report_id
    GotoBufferId(report_id)
    if NumLines()
    or files_adjusted
    or execmacros_adjusted
      BufferType(_NORMAL_)
      BegFile()
      UpdateDisplay(_ALL_WINDOWS_REFRESH_)
      Warn(execmacros_adjusted, ' ExecMacros in ', files_adjusted,
           ' files adjusted.', Chr(13), Chr(13),
           'The adjusted files have not been saved yet!')
    else
      GotoBufferId(org_id)
      AbandonFile(report_id)
      Warn('No ExecMacros were adjusted in any of the loaded files.')
    endif
  endif
  Set(LoadWildFromInside, old_loadwildfrominside)
  Set(WordSet           , old_wordset)
  PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end Main

