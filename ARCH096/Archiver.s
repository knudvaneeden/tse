/*


      Copyright (c) 2001 Michael Graham

      This package was originally based on Edgar Payne's save.s
      macro.  However very little actual code from that package
      remains here.

      The original notice on that package was:

      Copyright : (c)1994 by Sirius Software Services  All Rights Reserved.
                  (c)1994 by Edgar Ray Payne, Jr.  All Rights Reserved.

      Since I don't know how to get in touch with Edgar, all I can
      do is thank him here in this note and hope that he agrees with me
      that my inclusion of his code can be considered fair use.

*/

#define MAX_CMD_LINE 254

#ifdef _MAX_PATH_
#define MAX_PATH _MAX_PATH_
#else
#define MAX_PATH 254
#endif

#ifndef WIN32
#include ['profile.si']
#endif

#include ['setcache.si']
#include ['FindProf.si']
#include ['pathutil.si']

constant MODE_NO_BACKUP        = 0    // No Backups
constant MODE_STANDARD         = 1    // Standard TSE .bak style backups
constant MODE_INC_LOCAL        = 2    // Incremental Backups in same dir as original file
constant MODE_INC_LOCAL_SUBDIR = 3    // Incremental Backups in subdirectory of dir containing original file
constant MODE_INC_REMOTE       = 4    // Incremental Backups in central backup directory

// constant WRAP_DELETE_OLDEST    = 0    // Delete oldest
// constant WRAP_RUN_MACRO        = 1    // Run Macro
// constant WRAP_RUN_COMMAND      = 2    // Run Command

integer Safe_Buffer     = 0
integer Settings_Loaded = 0
integer Settings_Serial = 0
integer Max_Backups     = 0

integer Debug_Mode      = 0

string Global_Dir[MAX_CMD_LINE]

string Default_Exts_No_Backups[]           = '.bak,.tmp'
string Default_Exts_Standard_Backups[]     = ''
string Default_Exts_Local_Backups[]        = ''
string Default_Exts_Local_Subdir_Backups[] = ''
string Default_Exts_Global_Backups[]       = ''

string Exts_No_Backups[MAX_CMD_LINE]           = ''
string Exts_Standard_Backups[MAX_CMD_LINE]     = ''
string Exts_Local_Backups[MAX_CMD_LINE]        = ''
string Exts_Local_Subdir_Backups[MAX_CMD_LINE] = ''
string Exts_Global_Backups[MAX_CMD_LINE]       = ''

integer Wraparound_Beep               = 0
string Wraparound_Cmd[MAX_CMD_LINE]   = ''
string Wraparound_Macro[MAX_CMD_LINE] = ''

string Path_Separator[1] = '\'

string Local_Subdir[32]  = '\BAK'

proc LoadSettings()
    if (not Settings_Loaded) or NeedToReloadSettings(Settings_Serial)
        Settings_Serial        = GetSettingsRefreshSerial()
        Global_Dir             = GetProfileStr('Archiver','global_backup_dir',   '',    FindProfile())
        Local_Subdir           = GetProfileStr('Archiver','local_backup_subdir', 'bak', FindProfile())
        Max_Backups            = GetProfileInt('Archiver','max_backups',         0,     FindProfile())
        Wraparound_Beep        = GetProfileInt('Archiver','wraparound_beep',     0,     FindProfile())
        Wraparound_Cmd         = GetProfileStr('Archiver','wraparound_cmd',      '',    FindProfile())
        Wraparound_Macro       = GetProfileStr('Archiver','wraparound_macro',    '',    FindProfile())

        Exts_No_Backups           = GetProfileStr('Archiver','no_backups',           Default_Exts_No_Backups,       FindProfile())
        Exts_Standard_Backups     = GetProfileStr('Archiver','standard_backups',     Default_Exts_Standard_Backups, FindProfile())
        Exts_Local_Backups        = GetProfileStr('Archiver','local_backups',        Default_Exts_Local_Backups,    FindProfile())
        Exts_Local_Subdir_Backups = GetProfileStr('Archiver','local_subdir_backups', Default_Exts_Local_Subdir_Backups, FindProfile())
        Exts_Global_Backups       = GetProfileStr('Archiver','global_backups',       Default_Exts_Global_Backups,   FindProfile())


        // Add , to the end of all strings so we can search for strings delimited
        // with the comma
        Exts_Standard_Backups         = Exts_Standard_Backups     + ','
        Exts_Local_Backups            = Exts_Local_Backups        + ','
        Exts_Local_Subdir_Backups     = Exts_Local_Subdir_Backups + ','
        Exts_Global_Backups           = Exts_Global_Backups       + ','
        Exts_No_Backups               = Exts_No_Backups           + ','

        // Make Local_Subdir the default if none is specified
        if not Pos('.*,', Exts_Standard_Backups)
          and not Pos('.*,', Exts_Standard_Backups)
          and not Pos('.*,', Exts_Local_Backups)
          and not Pos('.*,', Exts_Local_Subdir_Backups)
          and not Pos('.*,', Exts_Global_Backups)
          and not Pos('.*,', Exts_No_Backups)
            if Length(Trim(Exts_Local_Subdir_Backups))
                Exts_Local_Subdir_Backups = Exts_Local_Subdir_Backups + ',.*,'
            else
                Exts_Local_Subdir_Backups = '.*,'
            endif
        endif

        if not Max_Backups
            Max_Backups = 1000
        endif

        // Add trailing slash
        if Local_Subdir[Length(Local_Subdir)] <> Path_Separator
            Local_Subdir = Local_Subdir + Path_Separator
        endif

        // Remove preceding slash
        if Local_Subdir[1] == Path_Separator
            Local_Subdir = Local_Subdir[2:Length(Local_Subdir)]
        endif

        // Add trailing slash
        if Global_Dir[Length(Global_Dir)] <> Path_Separator
            Global_Dir = Global_Dir + Path_Separator
        endif

        Settings_Loaded        = 1

        if Debug_Mode
            Warn("Archiver: loaded settings (global_dir: " + Global_Dir + "; Local_Subdir: "+Local_Subdir+")")
        endif

    endif
end

integer proc BackupMode()
    integer backup_mode  = MODE_NO_BACKUP

    string  curr_ext[10] = iif(
                               isMacroLoaded('CurrExt')
                               and ExecMacro('CurrExt'),
                                   GetGlobalStr('CurrExt'),
                                   CurrExt()
                           ) + ','


    if Pos(curr_ext, Exts_No_Backups)
        backup_mode = MODE_NO_BACKUP
    elseif Pos(curr_ext, Exts_Standard_Backups)
        backup_mode = MODE_STANDARD
    elseif Pos(curr_ext, Exts_Local_Backups)
        backup_mode = MODE_INC_LOCAL
    elseif Pos(curr_ext, Exts_Local_Subdir_Backups)
        backup_mode = MODE_INC_LOCAL_SUBDIR
    elseif Pos(curr_ext, Exts_Global_Backups)
        backup_mode = MODE_INC_REMOTE
    elseif Pos('.*,', Exts_No_Backups)
        backup_mode = MODE_NO_BACKUP
    elseif Pos('.*,', Exts_Standard_Backups)
        backup_mode = MODE_STANDARD
    elseif Pos('.*,', Exts_Local_Backups)
        backup_mode = MODE_INC_LOCAL
    elseif Pos('.*,', Exts_Local_Subdir_Backups)
        backup_mode = MODE_INC_LOCAL_SUBDIR
    elseif Pos('.*,', Exts_Global_Backups)
        backup_mode = MODE_INC_REMOTE
    endif

    return(backup_mode)
end

proc SetBufferCounter(integer counter)
    if Version() >= 3
        SetBufferInt("archiver::counter", counter)
    else
        SetGlobalInt("archiver::"+CurrFileName(), counter)
    endif
end

integer proc GetBufferCounter()
    integer counter = 0
    if Version() >= 3
        counter = GetBufferInt("archiver::counter")
    else
        counter = GetGlobalInt("archiver::"+CurrFileName())
    endif
    return(counter)
end

proc Chirp()
    #if EDITOR_VERSION >= 0x4000
        Sound(2000, 1)
        Sound(1000, 1)
    #else
        Sound(2000)
        delay(1)
        NoSound()
        Sound(1000)
        delay(1)
        NoSound()
    #endif
end

proc HandleWrapAround(string backup_dir)
    integer dos_flag = 0

    #ifdef WIN32
        dos_flag = _DONT_CLEAR_|_START_HIDDEN_|_RUN_DETACHED_
    #else
        dos_flag = _DONT_CLEAR_
    #endif

    if Wraparound_Beep
        Chirp()
    endif

    if Length(Wraparound_Macro)
        ExecMacro(Wraparound_Macro + ' ' + backup_dir)
    endif

    if Length(Wraparound_Cmd)
        Dos(Wraparound_Cmd + ' "' + backup_dir + '" "' + CurrFileName() + '"', dos_flag)
    endif
end

integer proc mSaveFile()
    string local_dir[MAX_PATH]  = ""
    string file_name[MAX_PATH]  = ""
    string backup_dir[MAX_PATH] = ""
    string temp_name[MAX_PATH]  = ""

    integer ret_val            = FALSE
    integer saved_makebackups  = Query(MakeBackups)
    integer counter            = 0

    string real_short_name[12] = ''
    string drive_letter[1]     = ''

    integer backup_mode
    integer run_sreload = FALSE

    // fool SAL into thinking that we actually use this
    // variable under win32
    #ifdef WIN32
        if 0 warn(real_short_name) endif
    #endif

    LoadSettings()

    backup_mode = BackupMode()

    if Debug_Mode
        Warn('Backup_Mode: ' + Str(backup_mode))
    endif

    // Special case.  If we are saving TSE.INI, then run the sreload
    // macro if it is available.  This will automatically notify
    // all running macros that the settings have changed

    if Lower(CurrFilename()) == Lower(FindProfile())
        if IsMacroLoaded('sreload') or Loadmacro('sreload')
            if Debug_Mode
                Warn('TSE.INI saved - running sreload')
            endif
            run_sreload = TRUE
        endif
    endif

    local_dir = SplitPath( CurrFilename(), _DRIVE_ | _PATH_ )

    // Easy cases first.  File not changed
    if not FileChanged()
        Message("No changes pending, save request ignored.")
        return(0)
    endif

    // Or this file type shouldn't be backed up
    if backup_mode == MODE_NO_BACKUP
        ret_val = SaveFile()
        // Run pending sreload command, if necessary
        if run_sreload
            ExecMacro('sreload')
        endif
        return(ret_val)
    endif

    // Or this file type should just do the default '.bak'
    if backup_mode == MODE_STANDARD
        Set(MakeBackups, TRUE)
        ret_val = SaveFile()
        Set(MakeBackups, saved_makebackups)
        // Run pending sreload command, if necessary
        if run_sreload
            ExecMacro('sreload')
        endif
        return(ret_val)
    endif

    Set(MakeBackups,FALSE)          // Turn backups off

    // Find the Backup Directory
    case backup_mode
        when MODE_INC_LOCAL
            backup_dir = local_dir

        when MODE_INC_LOCAL_SUBDIR
            backup_dir = local_dir + Local_Subdir

        when MODE_INC_REMOTE
            drive_letter = SplitPath( CurrFilename(), _DRIVE_ )
            backup_dir   = Global_Dir + drive_letter + SplitPath( CurrFilename(), _PATH_ )

            // backup_dir = backup_dir[1..Length(backup_dir) - 1]

            if not (FileExists(Global_Dir) & _DIRECTORY_)
                backup_dir = local_dir + Local_Subdir
            endif
    endcase

    // If the backup dir does not exist, create it
    if not (FileExists(backup_dir) & _DIRECTORY_)
        // Skip directory creation if we're not going to back up
        // this file

        if Debug_Mode
            warn("making backup tree: " + backup_dir)
        endif

        CreateDirectoryTree(backup_dir)
    endif

    // Determine the file name of the backup file
    #ifdef WIN32
        // Long file names: 'file.ext.001'
        file_name = SplitPath(CurrFileName(), _NAME_ | _EXT_)
    #else
        // Short file names: 'file.001'
        file_name = SplitPath(CurrFileName(), _NAME_)
    #endif


    // Find the numeric extension for the current file,
    // based on what numbered files already exist in the
    // backup directory.
    //

    // Start with the current count of the current buffer (if it exists)
    counter = GetBufferCounter()

    // Loop till we find an unused numeric extension

    repeat

        temp_name = backup_dir + file_name
                  + "." + Format(Str(counter):3:"0")

        // If more than max_backup files exist, wrap around to 000
        if counter > Max_Backups
            counter = 0
            temp_name = backup_dir + file_name + ".000"

            HandleWrapAround(backup_dir)

            break
        endif

        counter = counter + 1

    until not FileExists(temp_name)

    // Always erase file.ext+1 so that we can stop at the right file, even
    // between editing sessions.
    //
    // E.g. if we've got max_backups set to 50, and we've looped back to
    // 000 and quit the editor at 10, we need to know that the next
    // available slot is 011.  Otherwise all the files between 000 and 050
    // would still exist, and we wouldn't know next time where to save.

    EraseDiskFile(
        backup_dir + file_name
        + "." + Format(Str(counter+1):3:"0")
    )

    // Save the current count of the current buffer for next time
    SetBufferCounter(counter)

    if Debug_Mode
        warn("Archiver: temp_name: " + temp_name)
    endif

    // Copy current_file, using OS copy command
    if Length(temp_name) and FileExists(CurrFileName())
        CopyFile(CurrFileName(), temp_name)
    endif


    // The following hack is to preserve the LFN case of file names on
    // Samba shares, when run by the DOS version of TSE.
    // (part 2)

    // (part 1) rename file to itself - preserving desired case (part 1)
    #ifndef WIN32
        if Length(SplitPath(GetLongPathName(CurrFileName()), _NAME_)) <= 8
          and Length(SplitPath(GetLongPathName(CurrFileName()), _EXT_)) <= 4
          real_short_name = SplitPath(GetLongPathName(CurrFilename()),_NAME_|_EXT_)

        endif
    #endif

    ret_val = SaveFile()

    // The following hack is to preserve the LFN case of file names on
    // Samba shares, when run by the DOS version of TSE.
    // (part 2)

    #ifndef WIN32
        if real_short_name <> ''
            // Test that RenameDiskFile works!!
            // Dos(OS_Rename_Cmd + CurrFilename() + ' ' + real_short_name, _DONT_CLEAR_ | RUN_WIN_HIDDEN)
            RenameDiskFile(CurrFilename(), real_short_name)
        endif
    #endif

    // Run pending sreload command, if necessary
    if run_sreload
        ExecMacro('sreload')
    endif

    if ret_val
        Message("Save successful.")
    else
        Message("Save failed.  Return code = " + Str(ret_val))
    endif

    Set(MakeBackups, saved_makebackups)
    return(ret_val)
end

integer proc MaybeExit()
    integer currbuff = GetBufferId()

    if Safe_Buffer == 0
        Safe_Buffer = CreateBuffer('**__Archiver:Safe_Buffer__**', _SYSTEM_)
    endif

    GotoBufferId(Safe_Buffer)

    if NumFiles() == 0
        Exit()
    else
        GotoBufferId(currbuff)
    endif

    return(1)
end

integer proc mSaveAndQuitFile()
   integer ret_val

   ret_val = mSaveFile()
   AbandonFile()

   return(ret_val)
end

integer proc mSaveAllFiles()
   integer
      ret_val = FALSE,
      start   = GetBufferID()

   repeat
      if (BufferType() == _NORMAL_)
         ret_val = mSaveFile()
      endif

      NextFile()
   until (GetBufferID() == start)

   return(ret_val)
end

proc mSaveAllAndExit()
   integer
      start  = GetBufferID()

   repeat
      if (BufferType() == _NORMAL_)
         mSaveFile()
      endif

      NextFile()
   until (GetBufferID() == start)
   Exit()
end

Menu QuitMenu()
   title = "Save Changes?"

   "&Yes"    ,   mSaveAndQuitFile()
   "&No"     ,   AbandonFile()
   "&Cancel"
end

integer proc mQuitFile()
    if FileChanged()
       return (QuitMenu() and MaybeExit())
    else
       return (AbandonFile() and MaybeExit())
    endif
    return(0)
end

proc mExit()
     if mQuitFile()
         while NextFile(_DONT_LOAD_)
            if BufferType() == _NORMAL_
                UpdateDisplay(_STATUSLINE_REFRESH_ | _WINDOW_REFRESH_)
                if not mQuitFile()
                    break
                endif
            endif
         endwhile
         if BufferType() == _NORMAL_
             UpdateDisplay(_STATUSLINE_REFRESH_ | _WINDOW_REFRESH_)
             mQuitFile()
         endif
     endif
     MaybeExit()
end

proc Main()
    integer result = 0
    string cmd[4]  = Query(MacroCmdLine)

    case cmd
        when '-s'   // savefile
            result = mSaveFile()
        when '-sq'  // save and quit file
            result = mSaveAndQuitFile()
        when '-q'   // quit file
            result = mQuitFile()
        when '-sa'  // save all files
            result = mSaveAllFiles()
        when '-sax' // save all and exit
            mSaveAllAndExit()
        when '-d'  // debug mode on
            Debug_Mode = 1
        when '-n'  // debug mode off
            Debug_Mode = 0
        when '-x' // exit
            mExit()
    endcase
    Set(MacroCmdLine, Str(result))
end





