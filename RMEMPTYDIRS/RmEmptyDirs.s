/*
  Macro           RmEmptyDirs
  Author          Carlo.Hogeveen@xs4all.nl
  Compatibility   TSE Pro v4.0 upwards
  Version         v1.0 - 22 Dec 2020

  This tool asks for a directory and generates a TSE buffer with "rmdir"
  commands for those directories there that contain no files.
  Directories containing only empty directories are listed too.

  You can examine and edit the resulting TSE buffer, and rename it to a .cmd
  file to execute it to remove the listed directories.

  CAVEAT
  This tool shares TSE's limitations, that it sees no directories and files the
  parent directory of which is longer than 255 characters, and that best-case
  it lists names that contain non-ANSI characters with substitute characters.
  On the bright side "rmdir" refuses to delete non-empty directories.

  INSTALLATION
  Copy this file to TSE's "mac" folder, and compile it there, for example by
  opening the file there in TSE and applying the Macro Compile menu.
  To apply the tool just execute the macro and supply a folder to its prompt.

*/

string macro_name [MAXSTRINGLEN] = ''

integer proc find_empty_dirs(string dir)
  integer files  = 0
  integer handle = 0
  handle = FindFirstFile(dir + '\*', -1)
  if handle <> -1
    repeat
      if FFAttribute() & _DIRECTORY_
        if not (FFName() in '.', '..')
          files = files + find_empty_dirs(dir + '\' + FFName())
        endif
      else
        files = files + 1
      endif
    until not FindNextFile(handle, -1)
    FindFileClose(handle)
  endif
  if files == 0
    AddLine(Format('rmdir'; QuotePath(dir)))
  endif
  return(files)
end find_empty_dirs

proc WhenLoaded()
  macro_name = SplitPath(CurrMacroFilename(), _NAME_)
end WhenLoaded

proc Main()
  string root_dir [MAXSTRINGLEN] = ''
  if Ask('Search empty directories in which directory?', root_dir,
         GetFreeHistory(macro_name + ':root_dir'))
    root_dir = Trim(root_dir)
    if root_dir <> ''
      root_dir = (root_dir)
      if FileExists(AddTrailingSlash(root_dir))
        NewFile()
        find_empty_dirs(RemoveTrailingSlash(root_dir))
      endif
    endif
  endif
  PurgeMacro(macro_name)
end Main

