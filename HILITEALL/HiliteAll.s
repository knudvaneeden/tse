/*
  Macro           HiliteAll
  Author          Carlo.Hogeveen@xs4all.nl
  Compatibility   TSE Pro 4.0 upwards
  Version         0.1 - 23 Apr 2019

  BETA VERSION !
  This macro is not finished and incompletely tested.

  TODO
  - Implement Replace.

  This macro hilites all matches after a Find or Replace command.
  It does so as a side effect and does not interfere with the existing commands.
  It only does so for commands started with a key, so not from a menu.


  INSTALLATION

  Copy this macro file to TSE's "mac" folder, and compile it,
  for instance by opening the file in TSE and using the Macro Compile menu.

  Execute the macro immediately or later to configure:
  - For which keyboard keys all occurrences of the last Find or Replace command
    should be hilited. This can differ based on your chosen TSE configuration,
    so e.g. look in your TSE's Search menu for your Find and Replace keys.
    Do not forget to add the key for finding "Again" too.
  - Whether to "hilite all" once or perpetually.
  - If perpetually, then which keys should stop it.

  Lastly add the macro's name "HiliteAll" to the Macro AutoLoad List menu,
  and restart TSE.


  KNOWN IMPERFECTIONS

  Hiliting more than some search options search for:

    If the user searches or replaces with options "c", "l", "^", "$", or a
    number, then you could argue that "hiliting all" should adhere to the
    limits those options impose, which it currently does not.

    Implementing that would be a lot of work, and currently this behaviour does
    not bother me a lot. Let us see how bothersome this will (not) turn out to
    be in practice.

*/





// Compatibility restrictions and mitigations

/*
  When compiled with a TSE version below TSE 4.0 the compiler reports
  a syntax error and hilights the first applicable line below.
*/

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
    StrFind() 1.0

    If you have TSE Pro 4.0 or 4.2, then this proc implements the core of the
    built-in StrFind() function of TSE Pro 4.4.
    The StrFind() function searches a string or pattern inside another string
    and returns the position of the found string or zero.
    It works for strings like the regular Find() function does for files,
    so read the Help for the regular Find() function for the usage of the
    options, but apply these differences while reading:
    - Where the Find() (related) documentation refers to "file" and "line",
      StrFind() refers to "string".
    - The search option "g" ("global", meaning "from the start of the string")
      is implicit and can therefore always be omitted.
    As with the regular Find() function all characters are allowed as options,
    but here only these are acted upon: b, i, w, x, ^, $.

    Notable differences between the procedure below with TSE 4.4's built-in
    function:
    - The third parameter "options" is mandatory.
    - No fourth parameter "start" (actually occurrence: which one to search).
    - No fifth  parameter "len" (returning the length of the found text).

    Technical implementation notes:
    - To be reuseable elsewhere the procedure's source code is written to work
      independently of the rest of the source code.
      That said, it is intentionally not implemented as an include file, both
      for ease of installation and because one day another macro might need its
      omitted parameters, which would be an include file nightmare.
    - A tiny downside of the independent part is, that StrFind's buffer is not
      purged with the macro. To partially compensate for that if the macro is
      restarted, StrFind's possibly pre-existing buffer is searched for.
    - The fourth and fifth parameter are not implemented.
      - The first reason was that I estimated the tiny but actual performance
        gain and the easier function call to be more beneficial than the
        slight chance of a future use of these extra parameters.
      - The main reason turned out to be that in TSE 4.4 the fourth parameter
        "start" is erroneously documented and implemented.
        While this might be corrected in newer versions of TSE, it neither
        makes sense to me to faithfully reproduce these errors here, nor to
        make a correct implementation that will be replaced by an incorrect
        one if you upgrade to TSE 4.4.
  */
  integer strfind_id = 0
  integer proc StrFind(string needle, string haystack, string options)
    integer i                           = 0
    string  option                  [1] = ''
    integer org_id                      = GetBufferId()
    integer result                      = FALSE  // Zero.
    string  strfind_name [MAXSTRINGLEN] = ''
    string  validated_options       [7] = 'g'
    for i = 1 to Length(options)
      option = Lower(SubStr(options, i, 1))
      if      (option in 'b', 'i', 'w', 'x', '^', '$')
      and not Pos(option, validated_options)
        validated_options = validated_options + option
      endif
    endfor
    if strfind_id
      GotoBufferId(strfind_id)
      EmptyBuffer()
    else
      strfind_name = SplitPath(CurrMacroFilename(), _NAME_) + ':StrFind'
      strfind_id   = GetBufferId(strfind_name)
      if strfind_id
        GotoBufferId(strfind_id)
        EmptyBuffer()
      else
        strfind_id = CreateTempBuffer()
        ChangeCurrFilename(strfind_name, _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
      endif
    endif
    InsertText(haystack, _INSERT_)
    if lFind(needle, validated_options)
      result = CurrPos()
    endif
    GotoBufferId(org_id)
    return(result)
  end StrFind
#endif

// End of compatibility restrictions and mitigations.





#define CCF_OPTIONS     _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_
#define MENU_VALUE_SIZE 13

string  cfg_find_keys_section    [MAXSTRINGLEN] = ''
string  cfg_replace_keys_section [MAXSTRINGLEN] = ''
string  cfg_settings_section     [MAXSTRINGLEN] = ''
string  cfg_duration                       [10] = ''
string  cfg_stop_keys_section    [MAXSTRINGLEN] = ''
integer hilite_all_finds                        = FALSE
integer hilite_all_replaces                     = FALSE
integer idle_timer                              = 0
string  my_macro_name            [MAXSTRINGLEN] = ''
integer new_menu_dependency                     = FALSE
integer search_buffer_id                        = 0
integer search_results_buffer_id                = 0
integer il=Color( INTENSE BRIGHT RED ON YELLOW ) // [kn, ri, tu, 23-04-2019 14:32:04]

/*
  The following function determines the minimum amount of characters that a
  given regular expression can match. For the practical purpose that they are
  valid matches too, "^" and "$" are pretended to have length 1.
  The purpose of this procedure is, to be able to beforehand avoid searching
  for an empty string, which is logically pointless because it always succeeds
  (with one exception: past the end of the last line).
  Searching for an empty string in a loop makes it infinate and hangs a macro.
  Properly applied, using this procedure can avoid that.
*/
integer proc minimum_regexp_length(string s)
  integer addition           = 0
  integer i                  = 0
  integer NEXT_TIME          = 2
  integer orred_addition     = 0
  integer prev_addition      = 0
  integer prev_i             = 0
  integer result             = 0
  integer tag_level          = 0
  integer THIS_TIME          = 1
  integer use_orred_addition = FALSE
  // For each character.
  for i = 1 to Length(s)
    // Ignore this zero-length "character".
    if Lower(SubStr(s,i,2)) == "\c"
      i = i + 1
    else
      // Skip index for all these cases so they will be counted as one
      // character.
      case SubStr(s,i,1)
        when "["
          while i < Length(s)
          and   SubStr(s,i,1) <> "]"
            i = i + 1
          endwhile
        when "\"
          i = i + 1
          case Lower(SubStr(s,i,1))
            when "x"
              i = i + 2
            when "d", "o"
              i = i + 3
          endcase
      endcase
      // Now start counting.
      if use_orred_addition == NEXT_TIME
         use_orred_addition =  THIS_TIME
      endif
      // Count a literal character as one:
      if SubStr(s,i-1,1) == "\" // (Using the robustness of SubStr!)
        addition = 1
      // Count a tagged string as the length of its subexpression:
      elseif SubStr(s,i,1) == "{"
        prev_i = i
        tag_level = 1
        while i < Length(s)
        and   (tag_level <> 0 or SubStr(s,i,1) <> "}")
          i = i + 1
          if SubStr(s,i,1) == "{"
            tag_level = tag_level + 1
          elseif SubStr(s,i,1) == "}"
            tag_level = tag_level - 1
          endif
        endwhile
        addition = minimum_regexp_length(SubStr(s,prev_i+1,i-prev_i-1))
      // For a "previous character or tagged string may occur zero
      // times" operator: since it was already counted, subtract it.
      elseif SubStr(s,i,1) in "*", "@", "?"
        addition = -1 * Abs(prev_addition)
      // This is a tough one: the "or" operator.
      // For now subtract the length of the previous character or
      // tagged string, but remember doing so, because you might have
      // to add it again instead of the length of the character or
      // tagged string after the "or" operator.
      elseif SubStr(s,i,1) == "|"
        addition           = -1 * Abs(prev_addition)
        orred_addition     = Abs(prev_addition)
        use_orred_addition = NEXT_TIME
      else
      // Count ordinary characters as 1 character.
        addition = 1
      endif
      if use_orred_addition == THIS_TIME
        if orred_addition < addition
          addition = orred_addition
        endif
        use_orred_addition = FALSE
      endif
      result        = result + addition
      prev_addition = addition
    endif
  endfor
  return(result)
end minimum_regexp_length

proc after_getkey()
  string key_name [30] = KeyName(Query(Key))
  if GetProfileInt(cfg_find_keys_section, key_name, FALSE)
    hilite_all_finds    = TRUE
  endif
  if GetProfileInt(cfg_replace_keys_section, key_name, FALSE)
    hilite_all_replaces = TRUE
  endif
  if GetProfileInt(cfg_stop_keys_section, key_name, FALSE)
    hilite_all_finds    = FALSE
    hilite_all_replaces = FALSE
  endif
end after_getkey

proc after_command()
  hilite_all_replaces = FALSE
  idle_timer          = 0
end after_command

integer proc num_lines(integer to_check_buffer_id)
  integer org_buffer_id = GetBufferId()
  integer result        = 0
  GotoBufferId(to_check_buffer_id)
  result = NumLines()
  GotoBufferId(org_buffer_id)
  return(result)
end num_lines

proc idle()
  string  a                     [1] = ''
  integer buffer_line_from          = 0
  integer buffer_line_to            = 0
  string  find_str   [MAXSTRINGLEN] = ''
  string  old_WordSet          [32] = ''
  string  options_str           [9] = ''
  string  option_extra_str      [1] = ''
  integer option_pos                = 0
  integer org_buffer_id             = 0
  integer result_line               = 0
  integer result_pos                = 0
  string  result_str [MAXSTRINGLEN] = ''
  string  s                     [1] = ''
  integer x                         = 0
  integer y                         = 0
  if hilite_all_finds
    if NumLines()
      idle_timer = idle_timer - 1
      if idle_timer <= 0
        // Do not clog up the _idle_ hook.
        idle_timer = 36
        // Which buffer lines are on the screen?
        buffer_line_from = CurrLine() - CurrRow() + 1
        buffer_line_to   = buffer_line_from + Query(WindowRows) - 1
        if buffer_line_to > NumLines()
          buffer_line_to = NumLines()
        endif
        // Let's search the lines elsewhere and not disturb the current buffer.
        org_buffer_id = GetBufferId()
        PushBlock()
        MarkLine(buffer_line_from, buffer_line_to)
        GotoBufferId(search_buffer_id)
        EmptyBuffer()
        CopyBlock()
        UnMarkBlock()
        find_str    =       GetHistoryStr(_FIND_HISTORY_        , 1)
        options_str = Lower(GetHistoryStr(_FIND_OPTIONS_HISTORY_, 1))
        // Protect against a regular expression with an empty search result:
        if Pos('x', options_str)          == 0
        or minimum_regexp_length(find_str) > 0
          // Remove unusable and not implemented options.
          repeat
            option_pos = StrFind('[0-9acglnv+^$]', options_str, 'x')
            if option_pos
              options_str = options_str[1                .. (option_pos - 1)   ] +
                            options_str[(option_pos + 1) .. Length(options_str)]
            endif
          until not option_pos
          option_extra_str = 'g'
          while lFind(find_str, options_str + option_extra_str)
            AddLine(Format(CurrLine(), ' ', CurrPos(), ' ', GetFoundText()),
                    search_results_buffer_id)
            option_extra_str = '+'
          endwhile
          // Back to the original buffer to hilite the search results.
          GotoBufferId(org_buffer_id)
          PopBlock()
          old_WordSet = Set(WordSet, ChrSet('0-9'))
          while num_lines(search_results_buffer_id)
            GotoBufferId(search_results_buffer_id)
            BegFile()
            result_line = Val(GetWord())
            WordRight()
            result_pos  = Val(GetWord())
            Right(Length(GetWord()) + 1)
            result_str = GetText(CurrPos(), MAXSTRINGLEN)
            KillLine()
            BegFile()
            GotoBufferId(org_buffer_id)
            // Note: CUAmark uses block marking instead of hiliting.
            x = result_pos  + Query(WindowX1) - CurrXoffset() - 1
            y = result_line + Query(WindowY1)                 - 1
            if      GetStrAttrXY(x, y, s, a, 1)
            and not (Asc(a) in Query(HiliteAttr), Query(BlockAttr),
                               Query(CursorInBlockAttr))
             PutStrAttrXY(x, y, result_str, '', il )
            endif
          endwhile
          Set(WordSet, old_WordSet)
          if cfg_duration <> 'Perpetual'
            hilite_all_finds = FALSE
          endif
        endif
      endif
    else
      // Not for empty files.
      hilite_all_finds = FALSE
    endif
  else
    idle_timer = 0
  endif
end idle

proc WhenPurged()
  AbandonFile(search_buffer_id)
end WhenPurged

integer proc create_buffer(string buffer_specification)
  // Side effect: This proc switches to the created buffer!
  integer buffer_id                  = 0
  string  buffer_name [MAXSTRINGLEN] = my_macro_name + ':' + buffer_specification
  buffer_id = GetBufferId(buffer_name)
  if buffer_id
    GotoBufferId(buffer_id)
    EmptyBuffer()
  else
    buffer_id = CreateBuffer(buffer_name, _SYSTEM_)
  endif
  return(buffer_id)
end create_buffer

proc WhenLoaded()
  integer org_buffer_id = GetBufferId()
  my_macro_name            = SplitPath(CurrMacroFilename(), _NAME_)
  cfg_find_keys_section    = my_macro_name + ':' + 'SearchKeys'
  cfg_replace_keys_section = my_macro_name + ':' + 'ReplaceKeys'
  cfg_stop_keys_section    = my_macro_name + ':' + 'StopKeys'
  cfg_settings_section     = my_macro_name + ':' + 'GeneralSettings'
  cfg_duration             = GetProfileStr(cfg_settings_section, 'Duration', 'Once')
  search_buffer_id         = create_buffer('Search Buffer')
  search_results_buffer_id = create_buffer('Search Results Buffer')
  GotoBufferId(org_buffer_id)
  Hook(_AFTER_GETKEY_ , after_getkey )
  Hook(_AFTER_COMMAND_, after_command)
  Hook(_IDLE_         , idle         )
end WhenLoaded

proc show_help()
  string  full_macro_source_name [MAXSTRINGLEN] = LoadDir() + 'mac\' + my_macro_name + '.s'
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
      // Separate / and * characters, otherwise my SynCase macro gets confused.
      if lFind('/' + '*', 'g')
        PushBlock()
        UnMarkBlock()
        Right(2)
        MarkChar()
        if not lFind('*' + '/', '')
          EndFile()
        endif
        MarkChar()
        CreateTempBuffer()
        CopyBlock()
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

proc browse_website()
  StartPgm('https://www.ecarlo.nl/tse/index.html#hiliteall')
end browse_website


integer proc get_duration_flag()
  integer flag = _MF_DONT_CLOSE_|_MF_ENABLED_
  if cfg_duration == 'Once'
    flag = _MF_SKIP_|_MF_GRAYED_
  endif
  return(flag)
end get_duration_flag

proc toggle_duration_setting()
  cfg_duration = iif(cfg_duration == 'Once', 'Perpetual', 'Once')
  WriteProfileStr(cfg_settings_section, 'Duration', cfg_duration)
  new_menu_dependency = TRUE
  PushKey(<end>)
end toggle_duration_setting

proc do_list_key(string list_key)
  integer key_code = 0
  case list_key
    when 'Del'
      KillLine()
    when 'Ins'
      Delay(9)
      Message('Press <Escape> or the new key (combination) you want to add ... ')
      key_code = GetKey()
      Message('')
      AddLine(KeyName(key_code))
      if lFind('^$', 'gx')
        KillLine()
      endif
  endcase
  PushKey(<Escape>)
end do_list_key

Keydef extra_list_keys
  <Ins>     do_list_key('Ins')
  <GreyIns> do_list_key('Ins')
  <KeyPad0> do_list_key('Ins')

  <Del>     do_list_key('Del')
  <GreyDel> do_list_key('Del')
  <KeyPad.> do_list_key('Del')
end extra_list_keys

proc extra_list_keys_starter()
   UnHook(extra_list_keys_starter)
   if Enable(extra_list_keys)
      ListFooter(" {Ins}/{Del} Add or Delete a key (combination)")
   endif
end extra_list_keys_starter

proc configure_keyboard_keys(string cfg_section_name)
  integer cfg_changed               = FALSE
  string  item_name  [MAXSTRINGLEN] = ''
  string  item_value [MAXSTRINGLEN] = ''
  string  key_name             [30] = ''
  integer lst_buffer_id             = 0
  integer org_buffer_id             = GetBufferId()
  integer prev_FileChanged          = 0
  lst_buffer_id = CreateTempBuffer()
  if LoadProfileSection(cfg_section_name)
    while GetNextProfileItem(item_name, item_value)
      AddLine(item_name)
    endwhile
  endif
  repeat
    if NumLines()
      PushBlock()
      MarkLine(1, NumLines())
      Sort()
      UnMarkBlock()
      PopBlock()
    else
      AddLine('')
    endif
    prev_FileChanged = FileChanged()
    lFind(key_name, 'g^$')
    Hook(_LIST_STARTUP_, extra_list_keys_starter)
    List(cfg_section_name, Max(LongestLineInBuffer(), 44))
    key_name = GetText(1, CurrLineLen())
    Disable(extra_list_keys)
    cfg_changed = cfg_changed or FileChanged() <> prev_FileChanged
  until FileChanged() == prev_FileChanged
  if cfg_changed
    RemoveProfileSection(cfg_section_name)
    BegFile()
    repeat
      key_name = GetText(1, CurrLineLen())
      if key_name <> ''
        WriteProfileInt(cfg_section_name, key_name, TRUE)
      endif
    until not Down()
  endif
  GotoBufferId(org_buffer_id)
  AbandonFile(lst_buffer_id)
end configure_keyboard_keys

menu configuration_menu()
  title       = 'Hilite All - Configuration Menu'
  x           = 5
  y           = 5
//history     = menu_history_number

  '&Escape', NoOp(),, 'Exit this menu'
  '&Help ...', show_help(),, 'Read the documentation'
  '&Version ...'
    [GetProfileInt(cfg_settings_section, 'Version', 0):MENU_VALUE_SIZE],
    browse_website(),,
    'Check the website for a newer version ...'
  '',, _MF_DIVIDE_

  'Configure the &Find keys ...',
    configure_keyboard_keys(cfg_find_keys_section),
    _MF_DONT_CLOSE_|_MF_ENABLED_,
    "Configure the Find keyboard keys for which to hilite all."

  'Configure the &Replace keys ...',
    configure_keyboard_keys(cfg_replace_keys_section),
    _MF_DONT_CLOSE_|_MF_ENABLED_,
    "Configure the Replace keyboard keys for which to hilite all."

  'Configure the &Stop keys ...',
    configure_keyboard_keys(cfg_stop_keys_section),
    get_duration_flag(),
    "Configure the Stop keyboard keys for which to stop hiliting all."

  'Toggle the hilite-all &duration'
    [GetProfileStr(cfg_settings_section, 'Duration', 'Once'):MENU_VALUE_SIZE],
    toggle_duration_setting(),
    _MF_CLOSE_ALL_BEFORE_|_MF_ENABLED_,
    'Toggle whether the Search/Replace keys should be learned automatically.'
end configuration_menu

proc configure()
  repeat
    new_menu_dependency = FALSE
    configuration_menu()
  until not new_menu_dependency
end configure

proc Main()
  // Pacify the compiler about this not yet used variable.
  hilite_all_replaces = hilite_all_replaces

  configure()
end Main

