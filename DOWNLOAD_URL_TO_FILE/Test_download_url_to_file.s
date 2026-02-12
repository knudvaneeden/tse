/*
  Macro           Test_download_url_to_file
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   Windows TSE v4 upwards
  Version         1.0

  This tool dd 14 September 2022 implements downloading all 112 files from
    https://semware.com/tse-macros/
  and all 378 files from
    https://www.semware.com/html/tseprofilesd.php

  It does this dynamically, first downloading each web page, and then all
  downloadable files found on the web page.

  Note that this relies on these two web pages' current format,
  and might not work in the future.

  This tool creates a directory "TSE" + this macro's name in your Windows
  temporary directory as found in the TMP environment variable,
  and it creates 2 subdirectories there, one for each web page.

*/

// Start of compatibility restrictions and mitigations



#ifdef LINUX
  This macro is not Linux compatible
#endif

#ifdef WIN32
#else
   16-bit versions of TSE are not supported. You need at least TSE 4.0.
#endif

#ifdef EDITOR_VERSION
#else
   Editor Version is older than TSE 3.0. You need at least TSE 4.0.
#endif

#if EDITOR_VERSION < 4000h
   Editor Version is older than TSE 4.0. You need at least TSE 4.0.
#endif



#if EDITOR_VERSION < 4200h
  /*
    MkDir() 1.0

    This procedure implements the MkDir() command of TSE 4.2 upwards.
  */
  integer proc MkDir(string dir)
    Dos('MkDir ' + QuotePath(dir),
        _DONT_PROMPT_|_DONT_CLEAR_|_START_HIDDEN_|_RETURN_CODE_)
    return(not DosIOResult())
  end MkDir
#endif



#if EDITOR_VERSION < 4400h
  /*
    StrReplace() 1.0

    If you have TSE Pro 4.0 or 4.2, then this proc almost completely implements
    the built-in StrReplace() function of TSE Pro 4.4.
    The StrReplace() function replaces a string (pattern) inside a string.
    It works for strings like the Replace() function does for files, so read
    the Help for the Replace() function for the usage of the options, but apply
    these differences while reading:
    - Where Replace() refers to "file" and "line", StrReplace() refers to
      "string".
    - The options "g" ("global", meaning "from the start of the string")
      and "n" ("no questions", meaning "do not ask for confirmation on
      replacements") are implicitly always active, and can therefore be omitted.
    Notable differences between the procedure below with TSE 4.4's built-in
    function are, that here the fourth parameter "options" is mandatory
    and that the fifth parameter "start position" does not exist.
  */
  integer strreplace_id = 0
  string proc StrReplace(string needle, string haystack, string replacer, string options)
    integer i                      = 0
    integer org_id                 = GetBufferId()
    string  result  [MAXSTRINGLEN] = haystack
    string  validated_options [20] = 'gn'
    for i = 1 to Length(options)
      if (Lower(SubStr(options, i, 1)) in '0'..'9', 'b', 'i','w', 'x', '^', '$')
        validated_options = validated_options + SubStr(options, i, 1)
      endif
    endfor
    if strreplace_id == 0
      strreplace_id = CreateTempBuffer()
    else
      GotoBufferId(strreplace_id)
      EmptyBuffer()
    endif
    InsertText(haystack, _INSERT_)
    lReplace(needle, replacer, validated_options)
    result = GetText(1, CurrLineLen())
    GotoBufferId(org_id)
    return(result)
  end StrReplace
#endif



// End of compatibility restrictions and mitigations.

// Global variables
#define DOS_SYNC_CALL_FLAGS _DONT_PROMPT_|_DONT_CLEAR_|_START_HIDDEN_|_RETURN_CODE_
// string  FILENAME_WORDSET [32] = ChrSet('-&().0-9A-Z_a-z')

dll "<urlmon.dll>"
  integer proc URLDownloadToFile(
    integer pCaller,
    string  szURL     : CSTRVAL,
    string  szFileName: CSTRVAL,
    integer dwReserved,
    integer lpfnCB): "URLDownloadToFileA"
end

proc download_url_to_file(string url, string file)
  EraseDiskFile(file)
  // Warn( url; file )
  URLDownloadToFile( 0, url, file, 0, 0)
  Delay(18)
end download_url_to_file

string proc random_name_part()
  string s[12] = ''
  #ifdef INTERNAL_VERSION
    s = Upper(Format(Random():6:'0':36,
                     Random():6:'0':36))
  #else
    s = Str(GetTime())
  #endif
  return(s)
end random_name_part

proc download_list(string list_url,
                   string base_url,
                   string macro_download_dir,
                   string sub_dir)
  integer download_attempts                = 0
  string  download_dir      [MAXSTRINGLEN] = ''
  string  download_dir_file [MAXSTRINGLEN] = ''
  string  download_file     [MAXSTRINGLEN] = ''
  string  download_url      [MAXSTRINGLEN] = ''
  string  listed_file       [MAXSTRINGLEN] = ''
  integer max_download_attempts            = 0 // Against infinite loops
  integer org_id                           = GetBufferId()
  integer tmp_id                           = 0

  download_dir = macro_download_dir + '\' + sub_dir
  MkDir(download_dir)

  KeyPressed()
  Message('Downloading list'; list_url; '...')
  KeyPressed()

  download_url      = list_url
  download_dir_file = download_dir + '\dir_list_' + random_name_part() + '.tmp'

  download_url_to_file(download_url, download_dir_file)

  if FileExists(download_dir_file)
    tmp_id =  EditFile(QuotePath(download_dir_file), _DONT_PROMPT_)
    if tmp_id
      max_download_attempts = NumLines()
      BegFile()
      while download_attempts < max_download_attempts
      and   lFind('href="{.*}"', 'ix')
        // listed_file = Trim(GetToken(GetText(1, MAXSTRINGLEN), '"', 2))
        listed_file = GetFoundText( 1 )
        download_attempts = download_attempts + 1
        // Warn( listed_file )
        listed_file = StrReplace('&amp;', listed_file, '&', '')
        /*
        if (    sub_dir == 'LatestTseMacroSources'
            and isWord(listed_file, FILENAME_WORDSET))
        or (    sub_dir == 'OldUserUploads'
            and listed_file[1: 7] == '/files/')
        or (    sub_dir == 'Occamstoothbrush' )
        */

          KeyPressed()
          Message('Downloading file'; listed_file; '...')
          KeyPressed()

          download_url  = base_url + listed_file
          download_file = download_dir + '\' + SplitPath(listed_file, _NAME_|_EXT_)

          // Warn( download_url, download_file)

          download_url_to_file(download_url, download_file)
        // endif
        EndLine()
      endwhile
      EraseDiskFile(download_dir_file)
      Message('Done.')
    else
      Warn('ERROR: Failed to open temporary dir list.')
    endif
  else
    Warn('ERROR: No downloaded file.')
  endif
  GotoBufferId(org_id)
  AbandonFile(tmp_id)
end download_list

proc Main()
  string macro_download_dir [MAXSTRINGLEN] = ''
  macro_download_dir = Format(GetEnvStr('TMP'),
                              '\TSE_',
                              SplitPath(CurrMacroFilename(), _NAME_))
  if FileExists(macro_download_dir)
    Dos('rmdir /s /q ' + QuotePath(macro_download_dir), DOS_SYNC_CALL_FLAGS)
  endif
  MkDir(macro_download_dir)

  download_list('https://ecarlo.nl/tse/',
                'https://ecarlo.nl/tse/', // prefix URL
                macro_download_dir,
                'Carlo_Hogeveen')

  download_list('https://www.occamstoothbrush.com/tsemac/',
                'https://www.occamstoothbrush.com/', // prefix URL
                macro_download_dir,
                'Occamstoothbrush')

  download_list('https://semware.com/tse-macros/',
                'https://semware.com/tse-macros/', // prefix URL
                macro_download_dir,
                'LatestTseMacroSources')

  download_list('https://www.semware.com/html/tseprofilesd.php',
                'https://semware.com', // prefix URL
                macro_download_dir,
                'OldUserUploads')

  PurgeMacro(CurrMacroFilename())
end Main

