/*
  Macro           Lengths
  Author          Carlo.Hogeveen@xs4all.nl
  Compatibility   Windows TSE v4       upwards
                  Linux   TSE v4.41.35 upwards
  Version         1.1.1 - 17 Sep 2022


  PURPOSE

    This TSE extension shows the lengths of the word, string and line that the
    cursor is on.

    What constitutes a word is defined by TSE's configured WordSet.

    Here the length of a string is its simple straightforward length, meaning
    anything between single or double quotes, including other delimiters and/or
    escape characters.

    Tiny note: Contrary to what TSE itself shows, a newly created file starts
    out without any lines, not even an empty one, and for such this macro will
    not show a line length.


  INSTALLATION

    This macro needs the "Status" macro to be installed. You should be able
    to download it from the same location you got this macro from. It has its
    own installation and configuration instructions.

    Then put this file (the one you are now reading) in TSE's "mac" folder, and
    compile it as a macro, for instance by opening this file in TSE and using
    the Macro Compile menu.

    Either add this macro "Lengths" to TSE's Macro AutoLoad List menu yourself,
    or execute the macro once and leave at least one status enabled.


  CONFIGURATION

    Either right-click (Windows only) or type [Shift] F10 on a displayed length,
    or you can execute this macro, for example with TSE's
    menu Macro -> Execute -> "Lengths".

    Both will pop-up a Lengths menu, where you can enable/disable each length
    individually, access the Help, or configure the status colours.

    Just for fun, typing F1 on a displayed status brings up the Help too.


  HISTORY
    1.0.1   22 Jan 2018
      Added the installation comment about optionally executing the macro once.

    1.0.2   23 Jan 2018
      Stopped infinite warnings if the Status macro is not installed.

    1.0.3   19 Feb 2018
      Optimized the isAutoLoaded() procedure for old TSE versions.

    1.0.4   15 Apr 2018
      Optimized the isAutoLoaded() procedure again for old TSE versions.

    1.0.5   19 Nov 2018
      Documentation improved: Versioned the isAutoLoaded() procedure.

    1.0.6   4 Jan 2019
      Tiny code improvement: Moved the calls to stop_processing_my_key()
      up a statement.

    1.1     30 Apr 2020
      Added Linux TSE Beta v4.41.35 upwards compatibility.
      Modified the configuration menu to be able to directly access the status
      colour configuration.

    1.1.1 - 17 Sep 2022
      Fixed incompatibility with TSE's '-i' command line option
      and the TSELOADDIR environment variable.
*/





// Start of compatibility restrictions and mitigations

#ifdef LINUX
  #define WIN32 FALSE
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

#if EDITOR_VERSION < 4400h
  /*
    isAutoLoaded() 1.0

    This procedure implements TSE 4.4's isAutoLoaded() function for older TSE
    versions. This procedure differs in that here no parameter is allowed,
    so it can only examine the currently running macro's autoload status.
  */
  integer autoload_id           = 0
  string  file_name_chrset [44] = "- !#$%&'()+,.0-9;=@A-Z[]^_`a-z{}~\d127-\d255"
  integer proc isAutoLoaded()
    string  autoload_name [255] = ''
    string  old_wordset    [32] = Set(WordSet, ChrSet(file_name_chrset))
    integer org_id              = GetBufferId()
    integer result              = FALSE
    if autoload_id
      GotoBufferId(autoload_id)
    else
      autoload_name = SplitPath(CurrMacroFilename(), _NAME_) + ':isAutoLoaded'
      autoload_id   = GetBufferId(autoload_name)
      if autoload_id
        GotoBufferId(autoload_id)
      else
        autoload_id = CreateTempBuffer()
        ChangeCurrFilename(autoload_name, _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
      endif
    endif
    LoadBuffer(LoadDir() + 'tseload.dat')
    result = lFind(SplitPath(CurrMacroFilename(), _NAME_), "giw")
    Set(WordSet, old_wordset)
    GotoBufferId(org_id)
    return(result)
  end isAutoLoaded
#endif



/*
  compare_versions()  v2.0

  This proc compares two version strings version1 and version2, and returns
  -1, 0 or 1 if version1 is smaller, equal, or greater than/to version2.

  For the comparison a version string is split into parts:
  - Explicitly by separating parts by a period.
  - Implicitly:
    - Any uninterrupted sequence of digits is a "number part".
    - Any uninterrupted sequence of other characters is a "string part".

  Spaces are mostly ignored. They are only significant:
  - Between two digits they signify that the digits belong to different parts.
  - Between two "other characters" they belong to the same string part.

  If the first version part is a single "v" or "V" then it is ignored.

  Two version strings are compared by comparing their respective version parts
  from left to right.

  Two number parts are compared numerically, e.g: "1" < "2" < "11" < "012".

  Any other combination of version parts is case-insensitively compared as
  strings, e.g: "12" < "one" < "three" < "two", or "a" < "B" < "c" < "d".

  Examples: See the included unit tests further on.

  v2.0
    Out in the wild there is an unversioned version of compare_versions(),
    that is more restricted in what version formats it can recognize,
    therefore here versioning of compare_versions() starts at v2.0.
*/

// compare_versions_standardize() is a helper proc for compare_versions().

string proc compare_versions_standardize(string p_version)
  integer char_nr                  = 0
  string  n_version [MAXSTRINGLEN] = Trim(p_version)

  // Replace any spaces between digits by one period. Needs two StrReplace()s.
  n_version = StrReplace('{[0-9]} #{[0-9]}', n_version, '\1.\2', 'x')
  n_version = StrReplace('{[0-9]} #{[0-9]}', n_version, '\1.\2', 'x')

  // Remove any spaces before and after digits.
  n_version = StrReplace(' #{[0-9]}', n_version, '\1', 'x')
  n_version = StrReplace('{[0-9]} #', n_version, '\1', 'x')

  // Remove any spaces before and after periods.
  n_version = StrReplace(' #{\.}', n_version, '\1', 'x')
  n_version = StrReplace('{\.} #', n_version, '\1', 'x')

  // Separate version parts by periods if they aren't yet.
  char_nr = 1
  while char_nr < Length(n_version)
    case n_version[char_nr:1]
      when '.'
        NoOp()
      when '0' .. '9'
        if not (n_version[char_nr+1:1] in '0' .. '9', '.')
          n_version = n_version[1:char_nr] + '.' + n_version[char_nr+1:MAXSTRINGLEN]
        endif
      otherwise
        if (n_version[char_nr+1:1] in '0' .. '9')
          n_version = n_version[1:char_nr] + '.' + n_version[char_nr+1:MAXSTRINGLEN]
        endif
    endcase
    char_nr = char_nr + 1
  endwhile
  // Remove a leading 'v' if it is by itself, i.e not part of a non-numeric string.
  if  (n_version[1:2] in 'v.', 'V.')
    n_version = n_version[3:MAXSTRINGLEN]
  endif
  return(n_version)
end compare_versions_standardize

integer proc compare_versions(string version1, string version2)
  integer result                 = 0
  string  v1_part [MAXSTRINGLEN] = ''
  string  v1_str  [MAXSTRINGLEN] = ''
  string  v2_part [MAXSTRINGLEN] = ''
  string  v2_str  [MAXSTRINGLEN] = ''
  integer v_num_parts            = 0
  integer v_part_nr              = 0
  v1_str      = compare_versions_standardize(version1)
  v2_str      = compare_versions_standardize(version2)
  v_num_parts = Max(NumTokens(v1_str, '.'), NumTokens(v2_str, '.'))
  repeat
    v_part_nr = v_part_nr + 1
    v1_part   = Trim(GetToken(v1_str, '.', v_part_nr))
    v2_part   = Trim(GetToken(v2_str, '.', v_part_nr))
    if  v1_part == ''
    and isDigit(v2_part)
      v1_part = '0'
    endif
    if v2_part == ''
    and isDigit(v1_part)
      v2_part = '0'
    endif
    if  isDigit(v1_part)
    and isDigit(v2_part)
      if     Val(v1_part) < Val(v2_part)
        result = -1
      elseif Val(v1_part) > Val(v2_part)
        result =  1
      endif
    else
      result = CmpiStr(v1_part, v2_part)
    endif
  until result    <> 0
     or v_part_nr >= v_num_parts
  return(result)
end compare_versions



// End of compatibility restrictions and mitigations





// Global constants
string  STATUS_MACRO_NAME                 [6] = 'Status'
string  STATUS_MACRO_REQUIRED_VERSION     [3] = '1.2'


// Global variables
integer abort                                 = FALSE
string  add_line_length_call   [MAXSTRINGLEN] = ''
string  add_string_length_call [MAXSTRINGLEN] = ''
string  add_word_length_call   [MAXSTRINGLEN] = ''
string  del_line_length_call   [MAXSTRINGLEN] = ''
string  del_string_length_call [MAXSTRINGLEN] = ''
string  del_word_length_call   [MAXSTRINGLEN] = ''
integer line_length_displayed                 = FALSE
integer show_line_length                      = FALSE
integer show_string_length                    = FALSE
integer show_word_length                      = FALSE
string  my_macro_name          [MAXSTRINGLEN] = ''
integer string_length_displayed               = FALSE
integer word_length_displayed                 = FALSE



/*
  An ExecMacro that eventually stops this macro if the Status is not installed,
  thereby avoiding an infinite loop.
*/
proc exec_macro(string macro_cmd_line)
  string  status_macro_current_version [MAXSTRINGLEN] = ''
  string  extra_version_text           [MAXSTRINGLEN] = ''
  integer ok                                          = TRUE
  ok = ExecMacro(macro_cmd_line)
  if ok
    status_macro_current_version = GetGlobalStr(STATUS_MACRO_NAME + ':Version')
    if compare_versions(status_macro_current_version,
                        STATUS_MACRO_REQUIRED_VERSION) == -1
      ok                 = FALSE
      extra_version_text = 'at least version ' +
                           STATUS_MACRO_REQUIRED_VERSION + ' of '
    endif
  endif
  if not ok
    Alarm()
    Warn(my_macro_name, ' macro stops: It needs ', extra_version_text,
         'the "', status_macro_name, '" macro to be installed!')
    PurgeMacro(my_macro_name)
    abort = TRUE
  endif
end exec_macro


/*
  This proc returns 0 or the straightforward length of the string the cursor
  is in or on.
  Here a string means anything between either single or double quotes,
  and straightforward means that possible escape characters are ignored.

  Example strings with their straightforward lengths:
    "a"           1
    "b 'c' d"     7
    'ef'          2
    'e f "g h"'   9
    'aa           0
    'aaa\'aaa'    4
*/
integer proc get_string_length()
  string  char             [1] = ''
  integer counter              = 0
  integer counter_is_relevant  = FALSE
  integer org_pos              = CurrPos()
  string  quote            [1] = ''
  integer result               = -1
  integer x_pos                = 1
  while result == -1
  and   x_pos  <= CurrLineLen()
    char = GetText(x_pos, 1)
    if x_pos == org_pos
      if quote <> ''
      or (char in '"', "'")
        counter_is_relevant = TRUE
      endif
    endif
    if quote == ''
      if (char in '"', "'")
        quote = char
      endif
    else
      if char == quote
        if counter_is_relevant
          result = counter
        endif
        counter_is_relevant = FALSE
        counter = 0
        quote = ''
      else
        counter = counter + 1
      endif
    endif
    x_pos = x_pos + 1
  endwhile
  GotoPos(org_pos)
  return(result)
end get_string_length

proc idle()
  integer line_length   = iif(NumLines(), CurrLineLen(), -1)
  integer word_length   = Length(GetWord(TRUE))
  integer string_length = get_string_length()
  if show_line_length
  or show_string_length
  or show_word_length
    if show_line_length
      if line_length <> -1
        exec_macro(add_line_length_call + Str(line_length))
        line_length_displayed = TRUE
      elseif line_length_displayed
        exec_macro(del_line_length_call)
        line_length_displayed = FALSE
      endif
    endif
    if show_string_length
      if string_length <> -1
        exec_macro(add_string_length_call + Str(string_length))
        string_length_displayed = TRUE
      elseif string_length_displayed
        exec_macro(del_string_length_call)
        string_length_displayed = FALSE
      endif
    endif
    if show_word_length
      if word_length > 0
        exec_macro(add_word_length_call + Str(word_length))
        word_length_displayed = TRUE
      elseif word_length_displayed
        exec_macro(del_word_length_call)
        word_length_displayed = FALSE
      endif
    endif
  else
    PurgeMacro(my_macro_name)
  endif
end idle

proc WhenLoaded()
  my_macro_name = SplitPath(CurrMacroFilename(), _NAME_)

  #ifdef LINUX
    if compare_versions(VersionStr(), '4.41.35') == -1
      Warn('ERROR: In Linux the Lengths extension needs at least TSE v4.41.35.')
      PurgeMacro(my_macro_name)
      abort = TRUE
    endif
  #endif

  if not abort
    show_line_length   = GetProfileStr(my_macro_name + ':config', 'line'  , 'Enabled') == 'Enabled'
    show_string_length = GetProfileStr(my_macro_name + ':config', 'string', 'Enabled') == 'Enabled'
    show_word_length   = GetProfileStr(my_macro_name + ':config', 'word'  , 'Enabled') == 'Enabled'

    add_word_length_call   = status_macro_name + ' ' + my_macro_name + ':WrdLen,callback WrdLen '
    del_word_length_call   = status_macro_name + ' ' + my_macro_name + ':WrdLen'
    add_string_length_call = status_macro_name + ' ' + my_macro_name + ':StrLen,callback StrLen '
    del_string_length_call = status_macro_name + ' ' + my_macro_name + ':StrLen'
    add_line_length_call   = status_macro_name + ' ' + my_macro_name + ':LinLen,callback LinLen '
    del_line_length_call   = status_macro_name + ' ' + my_macro_name + ':LinLen'
    Hook(_IDLE_, idle)
  endif
end WhenLoaded

proc show_help()
  string  full_macro_source_name [MAXSTRINGLEN] = SplitPath(CurrMacroFilename(), _DRIVE_|_PATH_|_NAME_) + '.s'
  string  help_file_name         [MAXSTRINGLEN] = '*** ' + my_macro_name + ' Help ***'
  integer hlp_id                                = GetBufferId(help_file_name)
  integer org_id                                = GetBufferId()
  integer tmp_id                                = 0
  if hlp_id
    GotoBufferId(hlp_id)
    UpdateDisplay()
  else
    tmp_id = CreateTempBuffer()
    if LoadBuffer(full_macro_source_name)
      // Separate characters, otherwise my SynCase macro gets confused.
      if lFind('/' + '*', 'g')
        PushBlock()
        UnMarkBlock()
        Right(2)
        MarkChar()
        if not lFind('*' + '/', '')
          EndFile()
        endif
        MarkChar()
        Copy()
        CreateTempBuffer()
        Paste()
        UnMarkBlock()
        PopBlock()
        BegFile()
        ChangeCurrFilename(help_file_name,
                           _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
        BufferType(_NORMAL_)
        FileChanged(FALSE)
        BrowseMode(TRUE)
        UpdateDisplay()
      else
        GotoBufferId(org_id)
        Warn('File "', full_macro_source_name, '" has no multi-line comment block.')
      endif
    else
      GotoBufferId(org_id)
      Warn('File "', full_macro_source_name, '" not found.')
    endif
    AbandonFile(tmp_id)
  endif
end show_help

proc menu_length_set(string object, string state)
  case object
    when 'line'
      show_line_length   = (state == 'Enabled')
    when 'string'
      show_string_length = (state == 'Enabled')
    when 'word'
      show_word_length   = (state == 'Enabled')
  endcase
  if  GetProfileStr(my_macro_name + ':config', object, 'Enabled') <> state
    WriteProfileStr(my_macro_name + ':config', object, state)
  endif
  if   show_line_length
  or show_string_length
  or   show_word_length
    if not isAutoLoaded()
      AddAutoLoadMacro(my_macro_name)
    endif
  else
    if isAutoLoaded()
      exec_macro(del_line_length_call)
      exec_macro(del_string_length_call)
      exec_macro(del_word_length_call)
      DelAutoLoadMacro(my_macro_name)
    endif
  endif
end menu_length_set

string proc menu_length_get(string object)
  string result [9] = GetProfileStr(my_macro_name + ':config', object, 'Enabled')
  result = iif((result in 'Enabled', 'Disabled'), result, 'Enabled')
  menu_length_set(object, result)
  return(result)
end menu_length_get

proc menu_length_toggle(string object)
  string result [9] = GetProfileStr(my_macro_name + ':config', object, 'Enabled')
  result = iif(result == 'Enabled', 'Disabled', 'Enabled')
  menu_length_set(object, result)
end menu_length_toggle

menu config_menu()
  title       = 'Lengths Configuration'
  x           = 5
  y           = 5

  '&Escape', NoOp(), _MF_CLOSE_ALL_BEFORE_, 'Exit this menu'
  '&Help ...'  , show_help(), _MF_CLOSE_ALL_BEFORE_, 'Read the documentation'
  '&Status colour ...' , exec_macro('Status ConfigureStatusColor'),
    _MF_CLOSE_ALL_BEFORE_, 'For instance change the status text colour ...'
  '',, _MF_DIVIDE_
  '&Line length   ' [menu_length_get('line'):8],
    menu_length_toggle('line'), _MF_DONT_CLOSE_,
    'Enable/disable showing the line length.'
  'Strin&g length ' [menu_length_get('string'):8],
    menu_length_toggle('string'), _MF_DONT_CLOSE_,
    'Enable/disable showing the string length.'
  '&Word length   ' [menu_length_get('word'):8],
    menu_length_toggle('word'), _MF_DONT_CLOSE_,
    'Enable/disable showing the word length.'
end config_menu

proc stop_processing_my_key()
  PushKey(-1)
  GetKey()
end stop_processing_my_key

proc Main()
  string key_name [26] = ''
  if not abort
    // Is this a callback from the Status macro?
    if        GetToken(Query(MacroCmdLine), ' ', 1)  == 'callback'
    and Lower(GetToken(Query(MacroCmdLine), ' ', 2)) == 'status'
      // Yes, the user interacted with the cursor on the status,
      // so now the status macro calls us back reporting the specific action.
      // Note that a KeyName may contain a space, so also get any 5th parameter.
      key_name = Trim(GetToken(Query(MacroCmdLine), ' ', 4) + ' ' +
                      GetToken(Query(MacroCmdLine), ' ', 5))
      case key_name
        when 'F1'
          stop_processing_my_key()
          show_help()
        when 'RightBtn', 'F10', 'Shift F10'
          stop_processing_my_key()
          config_menu()
        otherwise
          // Not mine: Let the editor or some other macro process the key.
          NoOp()
      endcase
    else
      // No, the user executed the macro.
      config_menu()
    endif
  endif
end Main

