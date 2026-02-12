/*
  Macro           Keys
  Author          Carlo.Hogeveen@xs4all.nl
  Version         1.0.3   17 Sep 2022
  Compatibility   Windows TSE v4.0     upwards,
                  Linux   TSE v4.41.31 upwards

  This TSE extension allows you to assign an editing action
  to a quickly typed sequence of defined keys or mouseclicks.

  It uses a Keys.ui interface definition file in TSE's "mac" folder,
  with syntax like a standard TSE .ui file with some minor restrictions.
  Unlike a standard TSE .ui file it compiles automatically when modified.


  INSTALLATION

  Copy this Keys.s file to TSE's "mac" folder.

  If this is a first time installation then do the same for the Keys.ui file.

  Compile the Keys.s file in TSE's "mac" folder,
  for example by opening it in TSE and applying the Macro Compile menu.

  Add "Keys" in the Macro AutoLoad List menu, and restart TSE.

  Optionally modify the Keys.ui file.
  Do NOT use TSE's standard Macro Compile for the Keys.ui file!
  The Keys.ui file will be compiled automatically by the Keys macro.



  DISCLAIMER

  This TSE extension is released as-is. Use it at your own risk.


  CLAIMER

  At the time of its release I have for some time happily used this macro
  myself on a daily basis in Windows TSE's GUI version (g32.exe), and it
  contains no known errors that are not documented here.

  If you find undocumented errors, please report them.


  KNOWN ERRORS

  One infrequent source of unnecessary pauses remains.
  This demonstrates that problem: If you keep alternately typing two different
  keys that are both the start of a defined key sequence, then the screen is
  not updated until you stop typing.
  See the "DOCUMENTATION" section further on on how to reduce necessary pauses.

  The extension will probably malfunction for key (sequence) definitions
  that contain the <<> or <>> key.

  A quick fix that solved interfering with TSE's incremental search in TSE's
  Help makes Keys do nothing too in regular files that contain TSE Help codes,
  like the file "TSE_Pro_v4.4_Undocumented_Features.txt".



  CONSOLE AND LINUX COMPATIBILITY

  The example Keys.ui file contains examples for the ANSI character set.
  TSE's Linux and Console versions do not support ANSI.
  Use TSE's standard Potpourri ShowKey menu option to view, select and insert
  those characters into your text that your TSE version does support.

  For Linux the TSE version v4.41.28 or higher is necessary to be able to store
  configuration options.



  COMPILING THE KEYS.UI FILE

  The Keys.ui file may NOT to be compiled by TSE's standard Macro Compile menu!
  It contains some specific text to prevent you from doing it accidentally.
  Instead the Keys.ui is compiled automatically by the Keys macro.

  The Keys.ui file needs to exist in TSE's "mac" folder.
  If it contains errors, warnings or notes the compilation will only show the
  first one; errors before warnings before notes.

  An error causes all key definitions to be ignored.
  As with the regular compiler you may ignore warnings and notes.

  In the background a compilation creates a "Keys_helper" macro.
  As a user you only need to know this so you know you can ignore it.

  For macro programmers:
  At Key.ui's compile-time the Keys macro creates the Keys_helper macro from
  the key sequences and their definitions.
  At Key.ui's compile-time and at TSE's load-time the Keys macro reads
  the Keys.ui file (again) for the key sequences to store them in memory in a
  hash, and when in run-time one of those key sequences is typed, then it calls
  the Keys_helper macro with the key names of the recognized sequence as a
  parameter.
  For debugging it might sometimes be advantageous to temporarily edit
  the Keys_helper macro directly, but beware that it will be overwritten the
  next time the Keys.ui file is modified.



  .UI SYNTAX

  The Keys.ui file has almost the same syntax and functionality
  as one of TSE's regular .ui files.

  The differences are:
  - You cannot and should not compile this file with the Macro Compile menu.
  - The defined keys do not appear in TSE's menus.
  - Anything before the first key definition is ignored.
  - All statements between one key definition and the next are scoped locally
    to the one key, so you cannot use global statements like "proc", "menu"
    and "forward", and declared variables are implicitly local to that key.
  - Duplicate key sequences are not allowed.
  - Longer key sequences do not overrule shorter ones,
    and the order in which they are defined does not matter.
    So you can have key definitions for both "<z><z><z>" and "<z><z><z><z>",
    in any order, and whichever you type rapidly gets its action performed.
  - When inserting a character in the text, use PushKey() instead
    of Insertext(): PushKey() honours overwriting shift-marked text.

  Warning: It is possible to disable TSE by defining an infinite loop of keys,
  for example:
    <a>  PushKey(KeyCode(<a>))
  If this makes TSE unusable, then you can rename the Keys.ui file (so Keys.ui
  does not exist any more), use TSE to remove the offending key definition from
  the renamed file, and rename the renamed file back to Keys.ui.



  RUN-TIME BEHAVIOUR

  There will be a small pause each time you type a key that is part of a
  defined key sequence: This pause is necessary to determine if you are going
  to type another key of the key sequence or not.

  By executing the Keys macro you can configure the length of the pause.
  In the configuration it is called the "Key timeout period".
  A too short pause makes it impossible to type a key sequence fast enough.
  A too long pause makes TSE slow to respond to defined sequence keys.

  The key timeout period is counted in about 1/18ths of a second.
  The default key timeout period is 5. I find a value of 3 works well for me.

  Another method to reduce pausing is by removing unused key sequence
  definitions. If you do not need the euro sign and remove the example
  <e><e><e> definition, then the single <e> key is not slowed down any more.



  TODO
    MUST
    SHOULD
    COULD
    - The known errors.
    WONT


  HISTORY
  v0.1 - 30 Mar 2020
    Initial beta release.
  v0.2 - 30 Mar 2020
    Documented two known bugs.
  v0.2.1 - 30 Mar 2020
    Solved incompatibility with TSE ConSole version and non-OEM fonts
    like Terminal.
    Documented more bugs.
  v0.3 - 7 Apr 2020
    In TSE's Help the incremental search is no nonger interfered with.
  v0.4 - 8 Apr 2020
    Solved the inability to delete shift-marked text by typing over it!
    Part of the solution was in the code, the other part is in the Keys.ui file
    by using PushKey() instead of InsertKey().
  v0.5 - 9 Apr 2020
    In Keys.ui the key names are no longer interpreted case-insensitively,
    so <O><O><E><E> and <o><o><e><e> are separate key definitions now.
  v0.6 - 10 Apr 2020
    Keeping a key sequence key pressed no longer blocks screen updates it until
    it is released.
    The most significant cause of unnecessary pauses was removed! A small one
    still remains.
  v0.7 - 11 Apr 2020
    Solved problems when entering a password in macros that hide typed input.
      Actually, testing revealed it must already have been solved as a
      by-product of a previous release.
    Made compilation result messages more explicit.
    Solved that TSE sometimes still needed to be restarted to activate new key
    definitions.
    At TSE's start-up, when the current Keys.ui is not compiled, it gets
    compiled.

  v1.0 - 12 Apr 2020
    Added a configuration menu.
    Added backwards compatibility down to TSE Pro v4.0.
    Added Linux compatibility.
    First production release.

  v1.0.1 - 14 Apr 2020
    Solves compile error for the <'> key.

  v1.0.2 - 20 Apr 2020
    Just documenting a huge increase in the keys defined in the example Keys.ui
    file. Especially, all diacritics are now defined for systems in which the
    keyboard has not been configured to support them natively.

  v1.0.2.1 - 19 Sep 2020
    Documented Keys doing nothing in files that contain TSE Help codes.

  1.0.3   17 Sep 2022
    Fixed incompatibility with TSE's '-i' command line option
    and the TSELOADDIR environment variable.
*/





// Compatibility restrictions and mitigations



/*
  When compiled with a TSE version below TSE 4.0 the compiler reports
  a syntax error and hilights the first applicable line below.

  There is a beta Linux version of TSE that is not bug-free and in which some
  significant features do not work, but all its Linux versions are above
  TSE 4.0, and they all are 32-bits which is what WIN32 actually signifies.
*/

#ifdef LINUX
  #define WIN32       FALSE
  string  SLASH [1] = '/'
#else
  string  SLASH [1] = '\'
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
  integer proc StrCount(string needle, string haystack)
    integer i      = 0
    integer result = 0
    for i = 1 to Length(haystack)
      if SubStr(haystack, i, Length(needle)) == needle
        result = result + 1
      endif
    endfor
    return(result)
  end StrCount
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



// End of compatibility restrictions and mitigations





// Debugging - Global code

// #define DEBUG 0   // Must be defined or undefined, the value is irrelevant.

#ifdef DEBUG
  integer debug_msg_counter = 0

  proc debug_msg(string msg)
    Message('Debug';debug_msg_counter, ':'; msg)
    Delay(18)
  end debug_msg
#endif



// Global constants
#define CCF_OPTIONS                       _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_
string  KEY_SEQUENCE_SEARCH_STRING [11] = '^[ \d009]*<'
#define SEQUENCE_IS_COMPLETE_FLAG         2
#define SEQUENCE_IS_PARTIAL_FLAG          1
string  WORD_IS_DIGITS             [32] = ChrSet('[0-9]')
string  WORD_IS_LETTERS            [32] = ChrSet('[A-Za-z]')


// Global variables
integer hash_buffer_id                    = 0
string  helper_fqn_mac     [MAXSTRINGLEN] = ''
string  helper_fqn_s       [MAXSTRINGLEN] = ''
string  helper_macro_name  [MAXSTRINGLEN] = ''
integer idle_error_delay                  = 0
string  idle_error_message [MAXSTRINGLEN] = ''
integer key_timeout_period                = 0
string  log_fqn            [MAXSTRINGLEN] = ''
integer my_clipboard_id                   = 0
string  my_macro_name      [MAXSTRINGLEN] = ''
integer number_of_keys_to_ignore          = 0
integer old_dateformat                    = 0
integer old_dateseparator                 = 0
integer old_timeformat                    = 0
integer old_timeseparator                 = 0
string  ui_fqn             [MAXSTRINGLEN] = ''


// Local code

proc set_my_date_time_format()
  old_dateformat    = Set(DateFormat   , 6       ) // yyyy-mm-dd.
  old_dateseparator = Set(DateSeparator, Asc('-'))
  old_timeformat    = Set(TimeFormat   , 1       ) // hh:mm:ss, 24h, fixed length.
  old_timeseparator = Set(TimeSeparator, Asc(':'))
end set_my_date_time_format

proc restore_old_date_time_format()
  Set(DateFormat   , old_dateformat   )
  Set(DateSeparator, old_dateseparator)
  Set(TimeFormat   , old_timeformat   )
  Set(TimeSeparator, old_timeseparator)
end restore_old_date_time_format

string proc get_file_date_time(string fqn)
  string result [19] = ''
  if FindThisFile(fqn)
    set_my_date_time_format()
    result = FFDateStr() + ' ' + FFTimeStr()
    restore_old_date_time_format()
  endif
  return(result)
end get_file_date_time

// Return TSE's original LoadDir() if LoadDir() has been redirected
// by TSE's "-i" commandline option or a TSELOADDIR environment variable.
string proc original_LoadDir()
  return(SplitPath(LoadDir(TRUE), _DRIVE_|_PATH_))
end original_LoadDir

integer proc file_exists_as_file(string filename)
  integer file_exists = FileExists(filename)
  integer result      = TRUE
  if  not  file_exists
  or      (file_exists & _DIRECTORY_)
  or      (file_exists & _VOLUME_   )
    result = FALSE
  endif
  return(result)
end file_exists_as_file

string proc get_user()
  string user [MAXSTRINGLEN] = GetEnvStr('USERNAME')
  if user == ''
    user = GetEnvStr('USER')
  endif
  return(user)
end get_user

proc initialize_helper_macro_with_boilerplate_code()
  EmptyBuffer()
  AddLine(Format('//  This macro was generated automatically by the';
                 my_macro_name; 'macro'))
  AddLine(Format('//  on'; GetDateStr(); 'at'; GetTimeStr(); 'because user';
                 get_user(); 'modified the file'))
  AddLine(Format('//  ', ui_fqn; '.'))

  AddLine('proc Main()')
  AddLine('  string macro_cmd_line [MAXSTRINGLEN] = Query(MacroCmdLine)')
  AddLine('  case macro_cmd_line')
  AddLine('  endcase')
  AddLine('end Main')
end initialize_helper_macro_with_boilerplate_code

string proc get_key_sequence()
  // This proc assumes the current line starts with a key sequence.
  // It leaves the cursor on the ">" of the last key of the sequence,
  // and returns the found key sequence.
  integer key_pos_from                = 0
  string  key_sequence [MAXSTRINGLEN] = ''
  string  new_key      [MAXSTRINGLEN] = ''
  integer ok                          = TRUE
  string  search_options          [9] = 'cgx'
  BegLine() // In case erroneously no key sequence is found.
  while ok
  and   lFind('[ \d009]*\c<', search_options)
    key_pos_from = CurrPos()
    if lFind('>', 'c+')
      new_key      = GetText(key_pos_from, CurrPos() - key_pos_from + 1)
      key_sequence = key_sequence + new_key
    else
      key_sequence = key_sequence + '<...ERROR...'
      ok           = FALSE
    endif
    search_options = 'cx+'
  endwhile
  return(key_sequence)
end get_key_sequence

proc initialize_hash()
  integer org_id = GetBufferId()
  if hash_buffer_id
    // Deleting the buffer also deletes all buffer variables. Neat!
    AbandonFile(hash_buffer_id)
  endif
  hash_buffer_id = CreateTempBuffer()
  if hash_buffer_id
    ChangeCurrFilename(my_macro_name + ':key_sequences_hash',
                       CCF_OPTIONS)
  endif
  GotoBufferId(org_id)
end initialize_hash

integer proc get_hash_value(string hash_key)
  integer hash_value = GetBufferInt(my_macro_name + ':hash:' + hash_key,
                                    hash_buffer_id)
  return(hash_value)
end get_hash_value

proc set_hash_value(string key_sequence, integer hash_value)
  SetBufferInt(my_macro_name + ':hash:' + key_sequence,
               hash_value,
               hash_buffer_id)
end set_hash_value

proc set_hash_values(string key_sequence)
  string  hash_key [MAXSTRINGLEN] = ''
  integer new_hash_value_flag     = SEQUENCE_IS_COMPLETE_FLAG
  integer hash_value              = 0
  integer i                       = 0
  for i = Length(key_sequence) downto 1
    if key_sequence[i] == '>'
      hash_key   = key_sequence[1:i]
      hash_value = get_hash_value(hash_key)
      hash_value = hash_value | new_hash_value_flag
      set_hash_value(hash_key, hash_value)
      new_hash_value_flag = SEQUENCE_IS_PARTIAL_FLAG
    endif
  endfor
end set_hash_values

integer proc get_last_key_from_end_pos(    string  key_sequence,
                                       var integer end_pos     ,
                                       var string  key_name    )
  integer beg_pos = 0
  integer ok      = TRUE
  key_name = ''
  if end_pos > 0
    if key_sequence[end_pos] == '>'
      beg_pos = end_pos
      while beg_pos                >  0
      and   key_sequence[beg_pos] <> '<'
        beg_pos = beg_pos - 1
      endwhile
      if beg_pos > 0
        if key_sequence[beg_pos - 1] == '<'   // Account for key name "<<>".
          beg_pos = beg_pos - 1
        endif
        key_name = key_sequence[beg_pos .. end_pos]
        end_pos  = beg_pos - 1
      else
        Alarm()
        Warn(my_macro_name; 'program error 3: No "<" before pos'; end_pos;
           'of key_sequence "', key_sequence, '".')
        ok = FALSE
      endif
    else
      Alarm()
      Warn(my_macro_name; 'program error 2: No ">" at pos'; end_pos;
           'of key_sequence "', key_sequence, '".')
      ok = FALSE
    endif
  endif
  return(ok)
end get_last_key_from_end_pos

integer proc push_remaining_keys_onto_tse_kb_stack(string  key_sequence,
                                                   integer from_pos)
  integer end_pos                 = Length(key_sequence)
  integer key_code                = 0
  string  key_name [MAXSTRINGLEN] = 'dummy init value'
  integer ok                      = TRUE
  while ok
  and   key_name <> ''
  and   end_pos   > from_pos
    ok = get_last_key_from_end_pos(key_sequence, end_pos, key_name)
    if ok
      if key_name <> ''
        key_code = KeyCode(key_name[2 .. Length(key_name) - 1])
        PushKey(key_code)
      endif
    else
      Alarm()
      Warn(my_macro_name; 'program error 1: key_sequence = "', key_sequence, '".')
    endif
  endwhile
  return(ok)
end push_remaining_keys_onto_tse_kb_stack

proc exec_macro(string exec_macro_cmd_line)
  integer ok = TRUE
  ok = ExecMacro(exec_macro_cmd_line)
  if not ok
    Alarm()
    Warn('The "', my_macro_name, '"'; "macro's", my_macro_name,
         '.ui" file has not been installed.')
    PurgeMacro(my_macro_name)
  endif
end exec_macro

proc process_key_sequence(string key_sequence)
  string  exec_macro_cmd_line [MAXSTRINGLEN] = ''
  integer i                                  = Length(key_sequence)
  integer j                                  = 0
  integer key_sequence_length                = Length(key_sequence)
  integer ok                                 = TRUE
  integer old_after_getkey_hookstate         = 0
  #ifdef DEBUG
    // debug_msg(Format('process_key_sequence: key_sequence ='; key_sequence))
  #endif
  while i > 0
  and   not (get_hash_value(key_sequence[1:i]) & SEQUENCE_IS_COMPLETE_FLAG)
    // Subtracting chars instead of keys: Logically inefficient, but it works
    // too, and is in practice not that inefficient given the small loop size.
    i = i - 1
  endwhile
  if i > 0
    ok = push_remaining_keys_onto_tse_kb_stack(key_sequence, i + 1)
    if ok
      exec_macro_cmd_line = Format(my_macro_name, '_helper'; key_sequence[1:i])
      exec_macro(exec_macro_cmd_line)
    endif
  else
    ok = push_remaining_keys_onto_tse_kb_stack(key_sequence, 1)
    if ok
      for i = 2 to key_sequence_length
        if get_hash_value(key_sequence[i .. key_sequence_length])
          number_of_keys_to_ignore = StrCount('<', key_sequence[1 .. i - 1])
          break
        else
          for j = i to key_sequence_length
            if get_hash_value(key_sequence[i..j]) & SEQUENCE_IS_COMPLETE_FLAG
              number_of_keys_to_ignore = StrCount('<', key_sequence[1 .. i - 1])
              break
            endif
          endfor
          if number_of_keys_to_ignore
            break
          endif
        endif
      endfor
      if not number_of_keys_to_ignore
        number_of_keys_to_ignore = StrCount('<', key_sequence)
      endif
    endif
  endif
  if KeyPressed()
    old_after_getkey_hookstate = SetHookState(OFF, _AFTER_GETKEY_)
    GetKey()
    SetHookState(old_after_getkey_hookstate, _AFTER_GETKEY_)
    if number_of_keys_to_ignore > 0
      number_of_keys_to_ignore = number_of_keys_to_ignore - 1
    endif
  endif
end process_key_sequence

proc hide_key_from_others()
  Set(Key, -1)
end hide_key_from_others

integer proc waiting_for_next_key_timed_out(var string key_name)
  integer has_timed_out = FALSE
  integer timer         = 0
  while timer <= KEY_TIMEOUT_PERIOD
  and   not KeyPressed()
    Delay(1)
    timer = timer + 1
  endwhile
  if KeyPressed()
    GetKey()
    key_name      = '<' + KeyName(Query(Key)) + '>'
  else
    key_name      = ''
    has_timed_out = TRUE
  endif
  return(has_timed_out)
end waiting_for_next_key_timed_out

integer proc in_help_buffer()
  integer result = GetBufferInt(my_macro_name + ':is_help_buffer')
  if     result == 1
    result = TRUE
  elseif result == 2
    result = FALSE
  else
    PushLocation()
    if lFind('®[BIL]¯' , 'gx')
      PopLocation()
      SetBufferInt(my_macro_name + ':is_help_buffer', 1)
      result = TRUE
    else
      KillLocation()
      SetBufferInt(my_macro_name + ':is_help_buffer', 2)
      result = FALSE
    endif
  endif
  return(result)
end in_help_buffer

proc after_getkey()
  integer key_code                    = Query(Key)
  string  key_name     [MAXSTRINGLEN] = '<' + KeyName(key_code) + '>'
  string  key_sequence [MAXSTRINGLEN] = ''
  integer old_after_getkey_hookstate  = 0

  if (key_code in 65535, 32767, 2047, -1) // Key -1 turned out to have synonyms.
    // Do nothing: Let other macros or TSE handle the key.
  elseif number_of_keys_to_ignore > 0
    number_of_keys_to_ignore = number_of_keys_to_ignore - 1
    // Do nothing: Let other macros or TSE handle the key.
  elseif key_sequence             == ''
  and    get_hash_value(key_name) == 0
    // Do nothing: Let other macros or TSE handle the key.
  elseif in_help_buffer()
    // Keys interferes with the incremental search capability in TSE's Help.
    // This is a quick work-around.
    //
    // Do nothing: Let other macros or TSE handle the key.
  else
    old_after_getkey_hookstate = SetHookState(OFF, _AFTER_GETKEY_)
    repeat
      hide_key_from_others()
      key_sequence = key_sequence + key_name
      key_name     = ''
    until (not (get_hash_value(key_sequence) & SEQUENCE_IS_PARTIAL_FLAG))
       or     waiting_for_next_key_timed_out(key_name)
    if key_name <> ''
      hide_key_from_others()
    endif
    SetHookState(old_after_getkey_hookstate, _AFTER_GETKEY_)
    process_key_sequence(key_sequence)
  endif
end after_getkey

proc add_ui_line_number(integer ui_line_nr, integer ui_line_nr_sizing)
  if CurrLineLen() < 70
    GotoPos(70)
  else
    EndLine()
    Right()
  endif
  InsertText(Format('//', ui_line_nr:ui_line_nr_sizing))
end add_ui_line_number

string proc escape_single_quotes(string key_sequence)
  integer i                     = 0
  string  result [MAXSTRINGLEN] = ''
  for i = 1 to Length(key_sequence)
    if key_sequence[i] == "'"
      result = result + "' + Chr(39) + '"
    else
      result = result + key_sequence[i]
    endif
  endfor
  return(result)
end escape_single_quotes

proc generate_helper_macro_proc(integer helper_id   ,     integer ui_id    ,
                                string  key_sequence, var integer proc_counter)
  integer helper_line       = 0
  integer helper_line_from  = 0
  integer helper_line_to    = 0
  integer initial_indent    = 0
  integer old_NumLines      = 0
  integer ui_line           = 0
  integer ui_line_from      = 0
  integer ui_line_nr_sizing = 0
  integer ui_line_to        = 0
  proc_counter = proc_counter + 1
  GotoBufferId(ui_id)
  ui_line_nr_sizing = Length(Str(NumLines())) + 1
  PushBlock()
  UnMarkBlock()
  Right()
  PushLocation()
  if lFind('[~ \d009]', 'cx')
    PopLocation()
    initial_indent = CurrPos() - 1
    MarkChar()
  else
    KillLocation()
    Down()
    BegLine()
    initial_indent = 0
    MarkChar()
  endif
  ui_line_from = CurrLine()
  PushLocation()
  if lFind(KEY_SEQUENCE_SEARCH_STRING, 'x+')
    Up()
    EndLine()
    MarkChar()
  else
    EndFile()
    MarkChar()
  endif
  ui_line_to = CurrLine()
  Copy()
  PopLocation()
  GotoBufferId(helper_id)
  lFind('endcase', 'bg')
  InsertLine(Format("    when '", escape_single_quotes(key_sequence), "'"))
  AddLine   (Format('      proc_', proc_counter, '()'))
  lFind('proc Main()', 'bg')
  InsertLine()
  InsertLine(Format('proc proc_', proc_counter, '()'))
  add_ui_line_number(ui_line_from, ui_line_nr_sizing)
  helper_line_from = CurrLine() + 1
  AddLine(Format('end proc_', proc_counter))
  add_ui_line_number(ui_line_to, ui_line_nr_sizing)
  InsertLine(Format('':initial_indent:' '))
  GotoPos(initial_indent + 1)
  old_NumLines = NumLines()
  Paste()
  UnMarkBlock()
  helper_line_to  = helper_line_from + NumLines() - old_NumLines
  ui_line         = ui_line_from
  for helper_line = helper_line_from to helper_line_to
    GotoLine(helper_line)
    add_ui_line_number(ui_line, ui_line_nr_sizing)
    ui_line = ui_line + 1
  endfor
  PopBlock()
  GotoBufferId(ui_id)
end generate_helper_macro_proc

proc idle_redisplay_error()
  idle_error_delay = idle_error_delay - 1
  ScrollToCenter()
  UpdateDisplay(_ALL_WINDOWS_REFRESH_)
  Message(idle_error_message)
  if idle_error_delay <= 0
    UnHook(idle_redisplay_error)
  endif
end idle_redisplay_error

proc process_ui_file(integer have_to_generate_helper_macro)
  integer both_column_nr              = 0
  string  error_type              [8] = ''
  integer helper_id                   = 0
  integer helper_line_nr              = 0
  string  key_sequence [MAXSTRINGLEN] = ''
  integer log_id                      = 0
  string  log_line     [MAXSTRINGLEN] = ''
  integer ok                          = TRUE
  integer old_clipboard_id            = Set(ClipBoardId, my_clipboard_id)
  integer org_id                      = GetBufferId()
  integer proc_counter                = 0
  string  search_options          [9] = ''
  integer ui_id                       = 0
  integer ui_line_nr                  = 0
  if file_exists_as_file(ui_fqn)
    initialize_hash()
    ui_id = GetBufferId(ui_fqn)
    if ui_id
      if FileChanged()
        Alarm()
        UpdateDisplay(_ALL_WINDOWS_REFRESH_)
        Warn('Warning: Compiling this UNSAVED .ui file!')
      endif
    else
      ui_id = CreateTempBuffer()
      ChangeCurrFilename(my_macro_name + ':ui_file', CCF_OPTIONS)
      if not LoadBuffer(ui_fqn)
        Alarm()
        Warn(my_macro_name, ': Error when loading "', ui_fqn, '".')
        ok = FALSE
      endif
    endif
    if ok
      if have_to_generate_helper_macro
        PurgeMacro(helper_macro_name)
        helper_id = CreateTempBuffer()
        ChangeCurrFilename(my_macro_name + ':helper_file', CCF_OPTIONS)
        initialize_helper_macro_with_boilerplate_code()
        GotoBufferId(ui_id)
      endif
      search_options = 'gx'
      while ok
      and   lFind(KEY_SEQUENCE_SEARCH_STRING, search_options)
        search_options = 'x+'
        key_sequence   = get_key_sequence()
        if get_hash_value(key_sequence) & SEQUENCE_IS_COMPLETE_FLAG
          Alarm()
          UpdateDisplay(_ALL_WINDOWS_REFRESH_)
          Warn(my_macro_name; 'error: Duplicate key sequence "',
               key_sequence, '" defined.')
          ok = FALSE
        else
          set_hash_values(key_sequence)
          if  have_to_generate_helper_macro
          and helper_id
            // Beware, this call has a cursor position dependency.
            generate_helper_macro_proc(helper_id   , ui_id       ,
                                       key_sequence, proc_counter)
          endif
        endif
      endwhile
      if  ok
      and have_to_generate_helper_macro
        GotoBufferId(helper_id)
        if SaveAs(helper_fqn_s, _DONT_PROMPT_|_OVERWRITE_)
          Dos(Format(original_LoadDir(), 'sc32';
                     QuotePath(helper_fqn_s); '>';
                     QuotePath(log_fqn)),
              _DONT_PROMPT_|_DONT_CLEAR_|_START_HIDDEN_)
          log_id = CreateTempBuffer()
          ChangeCurrFilename(my_macro_name + ':log_file', CCF_OPTIONS)
          if LoadBuffer(log_fqn)
            if lFind('Error '  , '^gi')
            or lFind('Warning ', '^gi')
            or lFind('Note '   , '^gi')
              error_type = GetWord(FALSE, WORD_IS_LETTERS)
              log_line   = GetText(    1, MAXSTRINGLEN)
              lFind('[0-9],', 'cgx')
              helper_line_nr = Val(GetWord(FALSE, WORD_IS_DIGITS))
              lFind('[0-9])', 'cx+')
              both_column_nr = Val(GetWord(FALSE, WORD_IS_DIGITS))
              GotoBufferId(helper_id)
              GotoLine(helper_line_nr)
              EndLine()
              ui_line_nr     = Val(GetWord(TRUE , WORD_IS_DIGITS))
              GotoBufferId(ui_id)
              GotoLine(ui_line_nr)
              BegLine()
              GotoColumn(both_column_nr)
              UpdateDisplay(_ALL_WINDOWS_REFRESH_)
              ScrollToCenter()
              if lFind('.', 'cx')
                MarkFoundText()
              else
                MarkColumn(CurrLine(), CurrCol(), CurrLine(), CurrCol())
              endif
              log_line = StrReplace('([0-9]#,',
                                    log_line,
                                    '(' + Str(ui_line_nr) + ',',
                                    'gx1')
              Message(log_line)
              if error_type == 'Error'
                Alarm()
                Warn('Compilation failed:', Chr(13), Chr(13),
                     ui_fqn, Chr(13), Chr(13), log_line)
                idle_error_message = log_line
                initialize_hash()
              else
                Alarm()
                Warn('Compilation succeeded, but with'; Lower(error_type),
                     's:', Chr(13), Chr(13),
                     ui_fqn, Chr(13), Chr(13), log_line)
              endif
            else
              Alarm()
              Warn('Compilation successful!', Chr(13), Chr(13), ui_fqn)
            endif
          else
            Alarm()
            Warn(my_macro_name; ': Error when loading "', log_fqn, '".')
            ok = FALSE
          endif
        else
          Alarm()
          Warn(my_macro_name; ': Error when saving "', helper_fqn_s, '".')
          ok = FALSE
        endif
      endif
    endif
    GotoBufferId(ui_id)
    if ok
      if error_type == 'Error'
        if BufferType() <> _NORMAL_
          if not EquiStr(CurrFilename(), ui_fqn)
            AbandonFile(GetBufferId(ui_fqn))
            ChangeCurrFilename(ui_fqn, CCF_OPTIONS)
          endif
          BufferType(_NORMAL_)
          InitSynhiCurrFile()
          idle_error_delay = 3
          Hook(_IDLE_, idle_redisplay_error)
        endif
      else
        if BufferType() == _NORMAL_
          GotoBufferId(org_id)
        else
          GotoBufferId(org_id)
          AbandonFile(ui_id)
        endif
      endif
      AbandonFile(helper_id)
      AbandonFile(log_id)
    endif
  else
    Alarm()
    Warn('User interface file does not exist:', Chr(13), Chr(13), ui_fqn)
    ok = FALSE
  endif
  if not ok
    PurgeMacro(my_macro_name)
  endif
  Set(ClipBoardId, old_clipboard_id)
end process_ui_file

proc after_file_save()
  if EquiStr(CurrFilename(), ui_fqn)
    process_ui_file(TRUE)
  endif
end after_file_save

integer proc is_current_ui_file_compiled()
  integer result                       = FALSE
  string ui_fqn_date_time         [19] = ''
  string helper_mac_fqn_date_time [19] = ''
  ui_fqn_date_time         = get_file_date_time(        ui_fqn)
  helper_mac_fqn_date_time = get_file_date_time(helper_fqn_mac)
  result = (ui_fqn_date_time <= helper_mac_fqn_date_time)
  return(result)
end is_current_ui_file_compiled

proc WhenPurged()
  AbandonFile(my_clipboard_id)
  AbandonFile(hash_buffer_id)
  PurgeMacro(helper_macro_name)
end WhenPurged

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
        ChangeCurrFilename(help_file_name, CCF_OPTIONS)
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

proc WhenLoaded()
  integer have_to_recompile_ui_file = FALSE
  integer org_id                    = GetBufferId()
  my_macro_name     = SplitPath(CurrMacroFilename(), _NAME_)
  helper_macro_name = my_macro_name + '_helper'
  helper_fqn_s      = original_LoadDir() + 'mac' + SLASH + helper_macro_name + '.s'
  helper_fqn_mac    = original_LoadDir() + 'mac' + SLASH + helper_macro_name + '.mac'
  ui_fqn            = original_LoadDir() + 'mac' + SLASH + my_macro_name     + '.ui'
  log_fqn           = original_LoadDir() + 'mac' + SLASH + my_macro_name     + '.log'
  my_clipboard_id   = CreateTempBuffer()
  ChangeCurrFilename(my_macro_name + ':clipboard', CCF_OPTIONS)
  GotoBufferId(org_id)
  key_timeout_period = GetProfileInt(my_macro_name + ':Configuration',
                                     'key_timeout_period', 5)
  have_to_recompile_ui_file = not is_current_ui_file_compiled()
  process_ui_file(have_to_recompile_ui_file)
  Hook(_AFTER_FILE_SAVE_, after_file_save)
  Hook(_AFTER_GETKEY_   , after_getkey)
end WhenLoaded

proc write_profile_error()
  Warn(my_macro_name; 'error writing configuration to file "tse.ini"')
end write_profile_error

integer proc write_profile_int(string  section_name,
                               string  item_name,
                               integer item_value)
  integer result = WriteProfileInt(section_name,
                                   item_name,
                                   item_value)
  if not result
    write_profile_error()
  endif
  return(result)
end write_profile_int

integer proc read_key_timeout_period()
  string  s  [3] = ''
  integer result = 0
  result = GetProfileInt(my_macro_name + ':Configuration',
                         'key_timeout_period', 5)
  s      = Str(result)
  ReadNumeric(s)
  result = Val(s)
  if result < 1
    Message('No value selected, so the standard value of 5 18ths of a second is set.')
    result = 5
  elseif result == 1
    Message('Value "1" denied: It is not possible to type that fast!')
    result = 2
  elseif result > 90
    Message('Selected value out of maximum range. Set value to 90, which is about 5 seconds.')
    result = 90
  endif
  Write_Profile_Int(my_macro_name + ':Configuration', 'key_timeout_period', result)
  key_timeout_period = result
  return(result)
end read_key_timeout_period

menu configuration_menu()
  title = 'Keys Configuration Menu'
  '&Help   - read the documentation ...', show_help(),, 'Read the documentation'
  '&Key timeout period' [Format(GetProfileInt(my_macro_name + ':Configuration',
                                             'key_timeout_period',
                                             5):3):3],
    read_key_timeout_period(), _MF_DONT_CLOSE_|_MF_ENABLED_,
    'Set 18ths of a second to wait for a next sequence key [standard 5, range 2-90]'
  '&Escape - exit this menu',,, 'Exit this menu'
end configuration_menu

proc Main()
  configuration_menu()
end Main

