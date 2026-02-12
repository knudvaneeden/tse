/*
  Macro           get_drive_type_test
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   Windows TSE Pro v4.0 upwards
  Version         v1.0 - 11 Mar 2021

  This tool lists all the current drives and their drive type
  in order to test and demonstrate the get_drive_type() function.

  Installation:
    Copy this file and the "get_drive_type.inc" file to TSE's "mac" folder,
    and compile this file, for example by opening it in TSE and applying the
    menu "Macro, Compile".

    Then just execute the compiled macro.
*/

#Include ['get_drive_type.inc']

string drive_descriptions [MAXSTRINGLEN] =
  'Unknown;No Root Directory;Removable Disk;Local Disk;Network Drive;Compact Disk;RAM Disk'

proc Main()
  string  drive_description [MAXSTRINGLEN] = ''
  string  drive_name        [MAXSTRINGLEN] = ''
  integer drive_type                       = 0
  integer log_id                           = 0
  integer tmp_id                           = 0
  string  tmp_name          [MAXSTRINGLEN] = ''

  log_id = NewFile()
  tmp_id = CreateTempBuffer()
  ChangeCurrFilename(SplitPath(CurrMacroFilename(), _NAME_) + ':Main',
                     _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
  tmp_name = RemoveTrailingSlash(GetEnvStr('TMP'))
  if (FileExists(tmp_name) & _DIRECTORY_)
    tmp_name = tmp_name + '\' + SplitPath(CurrMacroFilename(), _NAME_) + '.tmp'
    if Dos('wmic logicaldisk get Name > ' + QuotePath(tmp_name),
           _DONT_PROMPT_|_DONT_CLEAR_|_START_HIDDEN_)
      if FileExists(tmp_name)
        if LoadBuffer(tmp_name)
          if EraseDiskFile(tmp_name)
            #if EDITOR_VERSION < 4200h
              // For TSE v4.0 and older remove a UTF-16LE BOM,
              BegFile()
              if GetText(1, 2) == 'ÿþ'
                DelChar(2)
              endif
              // and quick&dirty change UTF-16 to ANSI.
              lReplace('\d000', '', 'gnx')
            #endif
            // Get all drives and for each get and list their type.
            BegFile()
            repeat
              drive_name = Trim(GetText(1, MAXSTRINGLEN))
              if not (drive_name in 'Name', '')
                drive_type        = get_drive_type(drive_name, FALSE)
                drive_description = GetToken(drive_descriptions, ';',
                                             drive_type + 1)
                AddLine(Format(drive_name;;; drive_type;;; drive_description),
                        log_id)
              endif
            until not Down()
          endif
        endif
      endif
    endif
  endif
  GotoBufferId(log_id)
  AbandonFile(tmp_id)
  PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end Main

