/*
  Macro           fState
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   TSE Pro v4.0 upwards
  Version         v1.4.3   17 Sep 2022

  This TSE extension remembers the cursor position of recently viewed files.

  Default it works for both regular and temporary files
  It treats regular files and temporary files differently.
  A regular file is remembered based on its full path and file name.
  A temporary file is remembered just based on its file name.

  The latter is to accomodate TSE being used for editing remote files.
  Typically this happens when you use another tool to browse a remote file
  system, and TSE is configured as its editor: typically the browsing tool
  copies the file to a local folder for temporary files, adding another
  folder to make the filepath unique, and then calls TSE: If this happens
  multiple times for the same file, then TSE sees different paths for that same
  file. Therefore this macro ignores the complete path for files in a temporary
  folder.
  A temporary folder is one where its path contains one of these strings:
    "\tmp\"
    "\temp\"
    If not empty the value of the TMP environment variable.
    If not empty the value of the TEMP environment variable.

  INSTALLATION
    Put the macro's .s source (this file) in TSE's "mac" directory.
    Compile the macro using TSE's Macro/Compile menu.
    Add the macro to the Macro AutoLoad List using TSE's Macro menu.
    Optional: Execute the macro to partially disable its features.

  HISTORY
    v1.1   6 Jul 2010
      Also remember cursor-position for non-temporary files.

    v1.2   24 Jun 2011
      Don't reposition if the current file has a marked block or a hilited
      (found) text: this is probably the result of the file being opened
      and already positioned by another macro.

    v1.3   17 Jul 2011
      Made the macro configurable by executing it.

    v1.4   15 Dec 2018
    - Don't reposition the cursor when it is not at the beginning of the file.
      To me this happened in two cases where the macro turned out to be
      counterproductive:
      - If the Find key is pressed while still loading a very large file,
        then the Find prompted and executed before the cursor was repositioned.
        The Find positioned the cursor on its search result and then this
        extension repositioned the cursor on some old position. Arg!
      - When opening a lot of files at once with the "-a" option, and then
        searching them all with Find's "a" option. All non-current files are
        loaded during the search. So after the Find locates the searched
        position this extension saw a newly loaded file and repositioned the
        cursor on some old position. Growl!
    - Added the TMP and TEMP environment variables to also determine what
      constitutes a temporary folder.
    - Improved the code and the documentation a bit.

    v1.4.1   26 Aug 2020
    - Do not restore the cursor position for files named "<unnamed-n>", where
      "n" is a number that starts at 1 for each new TSE session. Such files are
      created by TSE's "File New" menu and by any utility using TSE's NewFile()
      function. The "<unnamed-1>" file of one TSE session will typically have a
      completely different content from the "<unnamed-1>" file of another TSE
      session, so they have no cursor positions in common.
    - Added a warning if Write_Profile_Str() fails. There was a user who requested
      this for another TSE extension, so now I do this for other macros too.
    - Improved the documentation a bit.

    v1.4.2   13 Dec 2021
      TSE GUI v4.0 introduced a functional close button.
      This fState version works around the TSE GUI's bug, that when the editor
      is closed with the close button, then the _ABANDON_EDITOR_ hook is not
      called if the TSE option "Empty Command-Line Action" has one of these
      values:
        Menu   (default)
        Restore State
        Also Restore State
      Functionally the bug caused fState's new file positions not to be saved.
      This work-around only works for TSE GUI v4.2 upwards.
      For TSE v4.0 it has no impact, and the close button bug remains.

    v1.4.3   17 Sep 2022
      Fixed incompatibility with TSE's '-i' command line option
      and the TSELOADDIR environment variable.
*/



// Global constants

// You may change this number to anything between 1 and 2000000000.
// In TSE's "mac" folder the extension will maintain a configuration
// file "<macro name>.dat" with cursor positions for that many files.
integer FILE_POSITIONS_TO_REMEMBER = 1000



// Global variables

integer dat_id                            = 0
string  delimiter                     [1] = ':'
integer enable_for_normal_files           = TRUE
integer enable_for_temporary_files        = TRUE
string  env_var_temp_value [MAXSTRINGLEN] = '\temp\'
string  env_var_tmp_value  [MAXSTRINGLEN] = '\tmp\'
string  macro_name         [MAXSTRINGLEN] = ''
integer timer                             = 0

#if EDITOR_VERSION >= 4200h
  integer on_abandon_editor_expected      = FALSE
#endif

proc Write_Profile_Str(string section_name, string item_name, string item_value)
  if not WriteProfileStr(section_name, item_name, item_value)
    Warn('"', macro_name; '" was unable to write its configuration for "',
         item_name,  '".')
  endif
end Write_Profile_Str

// Return TSE's original LoadDir() if LoadDir() has been redirected
// by TSE's "-i" commandline option or a TSELOADDIR environment variable.
string proc original_LoadDir()
  return(SplitPath(LoadDir(TRUE), _DRIVE_|_PATH_))
end original_LoadDir

proc save_dat_file()
  PushLocation()
  GotoBufferId(dat_id)
  if GetBufferId() == dat_id
    BegFile()
    GotoLine(FILE_POSITIONS_TO_REMEMBER + 1)
    if CurrLine() == FILE_POSITIONS_TO_REMEMBER + 1
      PushBlock()
      MarkLine(CurrLine(), NumLines())
      KillBlock()
      BegFile()
      PopBlock()
    endif
    SaveAs(original_LoadDir() + 'mac\' + macro_name + '.dat', _OVERWRITE_|_DONT_PROMPT_)
  endif
  PopLocation()
end save_dat_file

integer proc is_temporary_file(string filename)
  integer result = FALSE
  if (  Pos('\tmp\'           , Lower(filename))
     or Pos('\temp\'          , Lower(filename))
     or Pos(env_var_tmp_value , Lower(filename))
     or Pos(env_var_temp_value, Lower(filename)))
    result = TRUE
  endif
  return(result)
end is_temporary_file

proc restore_cursor_position()
  integer org_id                       = GetBufferId()
  integer remembered_line              = 0
  integer remembered_column            = 0
  string  curr_filename [MAXSTRINGLEN] = CurrFilename()
  integer is_normal_file               = TRUE
  if timer == 0
   timer = 3
  else
    timer = timer - 1
    if timer == 0
      SetBufferInt(macro_name + delimiter + 'is_repositioned', TRUE)
      if  not isBlockInCurrFile()
      and CurrLine() == 1
      and CurrPos()  == 1
      and (  GetFoundText() == ''
          or GetFoundText() <> GetText(CurrPos(), Length(GetFoundText())))
      and Pos('<unnamed-', Lower(CurrFilename())) == 0
        if is_temporary_file(curr_filename)
          curr_filename  = SplitPath(curr_filename, _NAME_|_EXT_)
          is_normal_file = FALSE
        endif
        if enable_for_normal_files
        or enable_for_temporary_files
          if (   enable_for_normal_files
             and is_normal_file)
          or (       enable_for_temporary_files
             and not is_normal_file)
            GotoBufferId(dat_id)
            if GetBufferId() == dat_id
              if  Length(Trim(curr_filename)) > 0
              and lFind(delimiter + curr_filename, 'g$')
                BegLine()
                remembered_line   = Val(GetWord())
                WordRight()
                remembered_column = Val(GetWord())
                GotoBufferId(org_id)
                GotoLine(remembered_line)
                GotoColumn(remembered_column)
                ScrollToCenter()
                UpdateDisplay()
              else
                GotoBufferId(org_id)
              endif
            endif
          endif
        else
          PurgeMacro(macro_name)
        endif
      endif
    endif
  endif
end restore_cursor_position

proc save_cursor_position()
  integer curr_col                     = CurrCol()
  string  curr_filename [MAXSTRINGLEN] = CurrFilename()
  integer curr_line                    = CurrLine()
  integer org_id                       = GetBufferId()
  integer remembered_col               = 0
  integer remembered_line              = 0
  integer store_new_cursor_position    = TRUE
  if  Length(Trim(curr_filename)) > 0
  and (Query(BufferFlags) & _LOADED_)
  and Pos('<unnamed-', Lower(CurrFilename())) == 0
    if is_temporary_file(curr_filename)
      curr_filename = SplitPath(curr_filename, _NAME_|_EXT_)
    endif
    GotoBufferId(dat_id)
    if GetBufferId() == dat_id
      if lFind(delimiter + curr_filename, 'g$')
        BegLine()
        remembered_line = Val(GetWord())
        WordRight()
        remembered_col  = Val(GetWord())
        if curr_line <> remembered_line
        or curr_col  <> remembered_col
          KillLine()
        else
          store_new_cursor_position = FALSE
        endif
      endif
      if store_new_cursor_position
        if curr_line > 1
        or curr_col  > 1
          BegFile()
          InsertLine(Format(curr_line, delimiter, curr_col, delimiter, curr_filename))
        endif
      endif
    endif
    GotoBufferId(org_id)
  endif
end save_cursor_position

proc idle()
  #if EDITOR_VERSION >= 4200h
    on_abandon_editor_expected = FALSE
  #endif
  if not GetBufferInt(macro_name + delimiter + 'is_repositioned')
    restore_cursor_position()
    BreakHookChain()
  endif
end idle

proc on_abandon_editor()
  #if EDITOR_VERSION >= 4200h
    on_abandon_editor_expected = FALSE
  #endif
  save_dat_file()
end on_abandon_editor

#if EDITOR_VERSION >= 4200h
  proc losing_focus()
    if on_abandon_editor_expected
      on_abandon_editor()
    endif
  end losing_focus
#endif

proc on_exit_called()
  #if EDITOR_VERSION >= 4200h
    on_abandon_editor_expected = TRUE
  #endif
  save_cursor_position()
end on_exit_called

proc on_file_quit()
  save_cursor_position()
end on_file_quit

string proc get_env_str_for_temporary_path(string env_var_name)
  string env_var_value [MAXSTRINGLEN] = ''
  if (Lower(env_var_name) in 'tmp', 'temp')
    env_var_value = Lower(GetEnvStr(env_var_name))
    if env_var_value == ''
      env_var_value = '\' + Lower(env_var_name) + '\'
    endif
    if SubStr(env_var_value, Length(env_var_value), 1) <> '\'
      env_var_value = env_var_value + '\'
    endif
  else
    Warn('PROGRAM ERROR: parameter "TMP" or "TEMP" expected.')
    PurgeMacro(macro_name)
  endif
  return(env_var_value)
end get_env_str_for_temporary_path

proc WhenPurged()
  save_dat_file()
end WhenPurged

proc WhenLoaded()
  integer org_id = GetBufferId()
  macro_name = SplitPath(CurrMacroFilename(), _NAME_)
  enable_for_temporary_files = (Lower(GetProfileStr(macro_name,
                                      'enable_for_temporary_files',
                                      'y')) <> 'n')
  enable_for_normal_files    = (Lower(GetProfileStr(macro_name,
                                      'enable_for_normal_files',
                                      'y')) <> 'n')
  dat_id = CreateTempBuffer()
  if dat_id
    LoadBuffer(original_LoadDir() + 'mac\' + macro_name + '.dat')
    // Convert version v1.0 format to v1.1 format.
    if lFind('^[0-9]# [0-9]# ', 'gx')
      lReplace('^{[0-9]#} {[0-9]#} ', '\1:\2:', 'gnx')
    endif
    // Remove "<unnamed-n>" entries. They are obsolete as of v1.4.1.
    while lFind('<unnamed-', 'g')
      KillLine()
    endwhile
    BegFile()
  endif
  GotoBufferId(org_id)
  env_var_tmp_value  = get_env_str_for_temporary_path('TMP')
  env_var_temp_value = get_env_str_for_temporary_path('TEMP')
  Hook(_IDLE_             , idle             )
  Hook(_ON_FILE_QUIT_     , on_file_quit     )
  Hook(_ON_EXIT_CALLED_   , on_exit_called   )
  Hook(_ON_ABANDON_EDITOR_, on_abandon_editor)
  #if EDITOR_VERSION >= 4200h
    Hook(_LOSING_FOCUS_   , losing_focus     )
  #endif
end WhenLoaded

proc configure()
  integer configuration_changed = FALSE
  if not enable_for_temporary_files
    PushKey(<CursorDown>)
  endif
  case YesNo('Remember last line and column for temporary files?')
    when 1
      if not enable_for_temporary_files
        enable_for_temporary_files = TRUE
        Write_Profile_Str(macro_name, 'enable_for_temporary_files', 'y')
        configuration_changed = TRUE
      endif
    when 2
      if enable_for_temporary_files
        enable_for_temporary_files = FALSE
        Write_Profile_Str(macro_name, 'enable_for_temporary_files', 'n')
        configuration_changed = TRUE
      endif
  endcase
  if not enable_for_normal_files
    PushKey(<CursorDown>)
  endif
  case YesNo('Remember last line and column for normal files?')
    when 1
      if not enable_for_normal_files
        enable_for_normal_files = TRUE
        Write_Profile_Str(macro_name, 'enable_for_normal_files', 'y')
        configuration_changed = TRUE
      endif
    when 2
      if enable_for_normal_files
        enable_for_normal_files = FALSE
        Write_Profile_Str(macro_name, 'enable_for_normal_files', 'n')
        configuration_changed = TRUE
      endif
  endcase
  if configuration_changed
    Warn('The new configuration will only be effective for newly loaded files.')
  endif
end Configure

proc Main()
  configure()
end Main

