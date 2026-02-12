/*
  Include file    get_drive_type.inc
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   Windows TSE Pro v4.0 upwards
  Version         v1.0 - 11 Mar 2021

  The function get_drive_type() requires two input parameters:
    file
      This can be anything from just a drive WITH a colon to a fully qualified
      folder or file name.
    refresh
      Because this function is relatively slow, you can indicate whether the
      function should refresh (TRUE/FALSE) its drive information each time it
      is called.
      A FALSE value optimizes performance when processing lots of files at
      once, while a TRUE value will notice if between calls you inserted a USB
      stick or connected a network drive.

  The function get_drive_type() returns the requested drive type as a number,
  because numbers are language and description independent. I have noticed that
  descriptions do vary.
    0   Unknown
    1   No Root Directory (I have no idea what this is)
    2   Removable Disk    (e.g. a USB stick and alledgedly some USB drives)
    3   Local Disk        (e.g. a harddisk  and definitely some USB drives)
    4   Network Drive
    5   Compact Disk      (e.g. a CD-ROM drive)
    6   RAM Disk

  Installation:
    Either copy this file to TSE's "mac" folder and include it in your own
    macro with
      #include ['get_drive_type.inc']
    or copy/paste the code from this file into your own macro.

  Techical notes about the function's internals:
  - Under the hood the Windows "wmic logicaldisk" command is used.
    An alternative to that would have been "fsutil fsinfo".
  - All my USB drives are recognized as type 3, and I have found no "wmic" or
    "fsutil" property that differs between a harddisk and a USB drive.    :-(
*/

integer get_drive_type_found_an_error = FALSE
integer get_drive_type_id             = 0
integer get_drive_type_is_initialized = FALSE

integer proc get_drive_type(string file, integer refresh)
  string  drive_name [MAXSTRINGLEN] = ''
  integer drive_type                = 0
  string  old_WordSet          [32] = Set(WordSet, ChrSet('~\d009\d032'))
  integer org_id                    = GetBufferId()
  string  tmp_name   [MAXSTRINGLEN] = ''

  if not get_drive_type_id
    get_drive_type_id = CreateTempBuffer()
    ChangeCurrFilename(SplitPath(CurrMacroFilename(), _NAME_)
                       + ':get_drive_type',
                       _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
    if not (FileExists(RemoveTrailingSlash(GetEnvStr('TMP'))) & _DIRECTORY_)
      Warn('Environment variable TMP does not contain valid folder.')
    endif
    GotoBufferId(org_id)
  endif

  if     refresh
  or not get_drive_type_is_initialized
    get_drive_type_is_initialized = TRUE
    if not get_drive_type_found_an_error
      get_drive_type_found_an_error = TRUE
      tmp_name = RemoveTrailingSlash(GetEnvStr('TMP'))
                                     + '\TSE_get_drive_type.tmp'
      // Alas, the output order of DriveType and Name is fixed.
      if Dos('wmic logicaldisk get DriveType,Name > ' + QuotePath(tmp_name),
             _DONT_PROMPT_|_DONT_CLEAR_|_START_HIDDEN_)
        GotoBufferId(get_drive_type_id)
        if LoadBuffer(tmp_name)
          if EraseDiskFile(tmp_name)
            #if EDITOR_VERSION < 4200h
              // For TSE v4.0 and older remove any UTF-16LE BOM,
              BegFile()
              if GetText(1, 2) == 'ÿþ'
                DelChar(2)
              endif
              // and quick&dirty change UTF-16 to ANSI.
              lReplace('\d000', '', 'gnx')
            #endif
            if  lFind('DriveType', 'gw')
            and lFind('Name'     , 'gw')
              get_drive_type_found_an_error = FALSE
            endif
          endif
        endif
        GotoBufferId(org_id)
      endif
    endif
  endif

  if not get_drive_type_found_an_error
    drive_name = SplitPath(file, _DRIVE_)
    if not (drive_name in 'Name', '')
      GotoBufferId(get_drive_type_id)
      if lFind(drive_name, 'giw')
        BegLine()
        drive_type = Val(GetWord())
      endif
      GotoBufferId(org_id)
    endif
  endif

  Set(WordSet, old_WordSet)
  return(drive_type)
end get_drive_type

