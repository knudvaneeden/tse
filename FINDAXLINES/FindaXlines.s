/*
  Tool            FindaXlines
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   TSE v4.0 upwards
  Version         v1.1   21 May 2022


As an experiment, I reformatted the below documentation to be compliant with
the Potpourri menu, meaning that it is limited to 68 characters per line.

Now you can
- copy the below text to the Windows clipboard,
- start the Potpourri menu,
- press the <Ins> key to add a new entry,
- enter "FindaXlines" as its name,
- paste the Windows clipboard into the empty text,
- press <Escape> followed by <e> to save it,
- and restart TSE.

Note that for an existing Potpourri entry it might be a lot faster
to delete the old one, create a new one, and copy/paste again.



START OF POTPOURRI COMPLIANT DOCUMENTATION

Find across lines.

This tool works like TSE's Find command, but with these differences:
- The search string:
  - Can match a text string that apans across lines.
  - The search sees each line end as a line feed character (LF).
  - If the search option contains an "x", then in the search string:
    - "^" and "$" will both match a line end,
      while "^" will also match the start of a file.
    - "\s" will match any whitespace character, like a space, tab,
      line end (carriage return or line feed) or any other control
      character.
- The search options
  - Only the search options g, i, m, v, x, + and digits are used.
  - Default a search range of at most 255 characters is matched.
  - In the search option you may add a different search range
    from 1 to MAXLINELEN - 2. In TSE 4.42 this is 31998 characters.
  - Or you may use the "m" to indicate the maximum search range.
- A found string is marked as a block.

You can execute the tool without parameters to be asked for them,
or execute it with a search string and search options.
If either contains spaces, then it must be double-quoted.

The search range is a character limit that applies to the sum of
whole line lengths, where each line ending counts as one character
too.
This means, that a search string will only match a string that
crosses lines, if the sum of all that string's lines' lengths is
smaller than or equal to the search range.
For example, suppose that in the following example lines each "b"
starts at column 1 of its line, then searching for "c.*c" with
search options "gix10" will not be found, because while it is 7
characters (including a line end) from c to c, the sum of their
lines' lengths is 14:
  b c e
  b c e

(  Aside: In other contexts something like the search range might
   be referred to as the look-ahead (size). )

The "v" search option produces a "View Finds" list of all found
occurrences.
This tool's "View Finds" list uses 5 TSE color configuration
options.
Here are the 5 TSE color configuration options that "View Finds"
uses, and for what:
  VARIABLE NAME        MENU NAME
  MenuSelectAttr       "Menu - Selected Item"
    Is used as the list's default text color on the current line.
  MenuTextAttr         "Menu/Help - Item Names"
    Is used as the list's default text color on other lines.
  CursorAttr           "Text - Cursor Line"
    Is used as the list's text color for found text on the current
    line.
  TextAttr             "Text - Normal"
    Is used as the list's text color for found text on other lines.
  HiliteAttr           "Text - Highlighted"
    If you type in the list, then matching text found in the list is
    hilited.

Examples:
  Execmacro('FindaXlines')                  // Asks for parameters.

  Reminder: In regular expressions "." now also matches a line end.

  ExecMacro('FindaXlines "word1 *word2" gix')     // Within a line.
  ExecMacro('FindaXlines word1.*word2 gix')       // Across lines.
  ExecMacro('FindaXlines word1.*word2 gix31998')
  ExecMacro('FindaXlines word1.*word2 gixm')

  When searching in this macro's source file,
  the following first example produces a simple short list,
  while the second example starts by finding two overlapping matches
  that end with the same 4 lines:

  ExecMacro('FindaXlines \swhile\s.*\sendwhile\s givx')
  ExecMacro('FindaXlines \swhile\s.*\sendwhile\s givx500')

END OF POTPOURRI COMPLIANT DOCUMENTATION



  TODO
    MUST
    SHOULD
    COULD
    - Configure user colors for the View Finds list.
    - Implement the "l" ("local in block") search option.
    - Implement the "a" ("across files") search option.
    WONT
    - Integrate this tool with a faster external search tool.


  HISTORY

  v0.1   13 May 2022
    Initial attempt. Roughly works, but sometimes positions the marking of the
    found result incorrectly.

  v0.2   13 May 2022
    A line ending now matches a line feed character instead of a space.
    You can now add its parameters on its macro command line.
    Added several new search options.
    Fixed several positioning bugs.

  v0.3   14 May 2022
    Renamed the tool from "FindAcrossLines" to "FindaXlines"
    so it fits in the Potpourri menu of newer TSE versions.

    Technical improvements:
      Improved the readability of the macro source code.
      Improved the macro maintaining and releasing its state.

  v0.4   14 May 2022
    Improved the tool's speed 37-fold.

    On my pc it now finds a string at the bottom of a 1 GB file in 12 minutes.

    Given the tool's intended functionality it is now at its speed limit,
    meaning it will not get any faster.

  v0.5   15 May 2022
    Implemented the "v" search option to list all found occurrences.
    <Enter> selects and marks one occurrence, <Alt E> edits the whole list.

  v0.5.1   16 May 2022
    Added "v" to the options prompt and documented a minor bug.

  v0.5.2   16 May 2022
    Bugs fixed in and from the View Finds list:
      Sometimes no empty line was placed between matches.
      Selecting a line that occurred in multiple matches always selected the
      first match.

  v0.6   18 May 2022
    The found matches are now also colored in the View Finds list.

  v1   19 May 2022
    For now I am done adding features, and no one reported issues.

  v1.0.1   19 May 2022
    Fixed the bug, that in the View Finds list each line's first found
    character was not colored with the found-color.

  v1.1   21 May 2022
    As an experiment I made the documentation Potpourri compliant,
    so it can be copied there.
*/





/*
  T E C H N I C A L   I N F O R M A T I O N


  SPEED TESTS

  Test file: 10 MB file with searched multi-line string at the bottom.
  Search options: "gixm".

    FindAcrossLines   4:41:10   4:42:65
    FindaXlines (1)   4:49:38   4:49:57
    FindaXlines (2)   4:43:32   4:42:46
    FindaXlines (3)      7.67      7.72

    (1) Changed Copy/Paste to CopyBlock.
    (2) Changed CopyBlock back to Copy/Paste.
    (3) Rewrote algorithm "create search buffer per file line"
        to algorithm "sliding window over file as search buffer".

  Test file: 1 GB file with searched multi-line string at the bottom.
  Search options: "gixm".

    FindaXlines (3)  11:52.93
*/



// Global constants and semi-constants

#define CHANGE_CURR_FILENAME_FLAGS   _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_
string  LF [1]                     = Chr(10)
integer LIST_FOUND_ID              = 0
integer LIST_ID                    = 0
string  MACRO_NAME [MAXSTRINGLEN]  = ''
integer META_BUFFER_ID             = 0
integer REAL_CURSORATTR            = 0
integer REAL_TEXTATTR              = 0
integer SLIDER_ID                  = 0

// Note for REAL_CURSORATTR and REAL_TEXTATTR:
// During a List(), TSE sets TextAttr to MenuTextAttr, and CursorAttr to
// MenuSelectAttr, while this tool wants to use their real values.



// Global variables

string  list_action [8] = ''



proc remove_option(string search_option, var string search_options)
  while Pos(search_option, search_options)
    search_options = search_options[1: Pos(search_option, search_options) - 1]
                   + search_options[Pos(search_option, search_options) + 1: MAXSTRINGLEN]
  endwhile
end remove_option


proc add_option(string search_option, var string search_options)
  if not Pos(search_option, search_options)
    search_options = search_options + search_option
  endif
end add_option


Keydef list_keys
  <Alt E>
    list_action = 'EditList'
    PushKey(<Enter>)
end list_keys


proc display_list_line(integer is_cursorline)
  integer curr_line      = 0
  integer found_attr     = iif(is_cursorline, REAL_CURSORATTR, REAL_TEXTATTR)
  integer found_end      = FALSE
  integer found_pos_from = 0
  integer found_pos_to   = 0
  integer i              = 0
  integer normal_attr    = iif(is_cursorline, Query(MenuSelectAttr), Query(MenuTextAttr))
  if CurrLineLen()
    curr_line = CurrLine()
    PushLocation()
    GotoBufferId(LIST_FOUND_ID)
    GotoLine(curr_line)
    found_pos_from = Val(GetToken(GetText(1, MAXSTRINGLEN), ' ', 1))
    found_pos_to   = Val(GetToken(GetText(1, MAXSTRINGLEN), ' ', 2))
    found_end      = Val(GetToken(GetText(1, MAXSTRINGLEN), ' ', 3))
    PopLocation()
    for i = 1 + CurrXoffset() to CurrLineLen()
      case i
        when 1 .. found_pos_from - 1
          PutStr(GetText(i, 1), normal_attr)
        when found_pos_from .. found_pos_to
          PutStr(GetText(i, 1), found_attr)
        when found_pos_to + 1 .. CurrLineLen()
          PutStr(GetText(i, 1), normal_attr)
      endcase
    endfor
    if found_end
      Set(Attr, normal_attr)
    else
      Set(Attr, found_attr)
    endif
  else
    Set(Attr, normal_attr)
  endif
  ClrEol()
end display_list_line


proc hilite_found_list_text()
  HiLiteFoundText()
end hilite_found_list_text


proc list_cleanup()
  UnHook(list_cleanup)
   UnhookDisplay()
  Disable(list_keys)
end list_cleanup


proc list_startup()
  UnHook(list_startup)
  Hook(_LIST_CLEANUP_, list_cleanup)
  HookDisplay(display_list_line,,,hilite_found_list_text)
  ListFooter('{Enter}-Go to line {Escape}-Cancel {Alt E}-Edit this list')
  Enable(list_keys)
end list_startup


integer proc find_across_lines(string  search_string,
                               string  search_options_in,
                               integer search_range)
  integer dst_copy_length                = 0
  integer found_length                   = 0
  integer found_position                 = 0
  integer org_id                         = GetBufferId()
  integer result                         = FALSE
  string  search_options            [12] = search_options_in
  string  slider_find_options        [1] = ''
  integer slider_length                  = 0
  integer slider_lines                   = 0
  integer src_copy_length                = 0
  integer source_start_line              = 0
  integer source_start_pos               = 0

  GotoBufferId(SLIDER_ID)
  EmptyBuffer()

  GotoBufferId(org_id)
  PushBlock()
  PushLocation()

  if Pos('g', search_options)
    BegFile()
  endif

  source_start_line = CurrLine()
  source_start_pos  = CurrPos()

  repeat
    src_copy_length = Max(CurrLineLen() - CurrPos() + 1, 0)
    dst_copy_length = src_copy_length + 1

    if slider_length + dst_copy_length > search_range
      GotoBufferId(SLIDER_ID)
      while CurrLineLen()
      and   CurrLineLen() + dst_copy_length > search_range
        if lFind(LF, 'g')
          MarkColumn(1, 1, 1, CurrPos())
          KillBlock()
        else
          EmptyBuffer()
        endif
      endwhile
      slider_length = CurrLineLen()
      GotoBufferId(org_id)
    endif

    if src_copy_length
      UnMarkBlock()
      MarkChar()
      EndLine()
      MarkChar()
      Copy()
    endif

    GotoBufferId(SLIDER_ID)
    EndLine()

    if src_copy_length
      Paste()
      UnMarkBlock()
      EndLine()
    endif

    InsertText(LF)
    slider_length = CurrLineLen()
    BegLine()

    if lFind(search_string, search_options)
      result         = TRUE
      found_position = CurrPos()
      MarkFoundText() // Marks a _NON_INCLUSIVE_ character block, like MarkChar().
      GotoBlockEnd()  // Therefore goes to the position just after the block.
      found_length   = CurrPos() - found_position
    endif

    GotoBufferId(org_id)
    BegLine()
  until result
     or not Down()

  PopBlock()

  if result
    KillLocation()
    UnMarkBlock()

    // From the found position in the slider we need to derive the found
    // position in the source file.
    GotoBufferId(SLIDER_ID)

    // Determine the slider's number of concatenated source lines.
    slider_lines        = 0
    slider_find_options = 'g'
    while lFind(LF, slider_find_options)
      slider_lines        = slider_lines + 1
      slider_find_options = '+'
    endwhile

    // Now go the source file line that corresponds to the slider's first line.
    GotoBufferId(org_id)
    Up(slider_lines - 1)

    // Now go the source file column that corresponds to the slider's first column.
    if CurrLine() == source_start_line
      GotoPos(source_start_pos)
    else
      BegLine()
    endif

    // Now go to the source file's corresponding found position,
    // and mark the found string.
    NextChar(found_position - 1)
    UnMarkBlock()
    MarkStream()
    NextChar(found_length   - 1)
    MarkStream()
    GotoBlockBegin()
  else
    PopLocation()
  endif

  return(result)
end find_across_lines


integer proc find_all_across_lines(string  search_string,
                                   string  search_options_in,
                                   integer search_range)
  integer found_pos_from            = 0
  integer found_pos_to              = 0
  integer line_number                = 0
  integer listed_line                = 0
  integer listed_match               = 0
  integer list_line                  = 0
  integer list_line_len              = 0
  integer list_prefix_length         = 0
  integer longest_line_number_length = 0
  string  meta_data   [MAXSTRINGLEN] = ''
  integer meta_data_line_from        = 0
  integer meta_data_line_to          = 0
  integer meta_data_pos_from         = 0
  integer meta_data_pos_to           = 0
  integer old_InsertLineBlocksAbove  = Set(InsertLineBlocksAbove, OFF)
  integer org_id                     = GetBufferId()
  integer result                     = FALSE
  string  search_options        [12] = search_options_in

  // Create list buffers.
  PushLocation()
  if not LIST_ID
    LIST_ID        = CreateTempBuffer()
    ChangeCurrFilename(MACRO_NAME + ':List' , CHANGE_CURR_FILENAME_FLAGS)
  endif
  if not LIST_FOUND_ID
    LIST_FOUND_ID = CreateTempBuffer()
    ChangeCurrFilename(MACRO_NAME + ':Found', CHANGE_CURR_FILENAME_FLAGS)
  endif
  if not META_BUFFER_ID
    META_BUFFER_ID = CreateTempBuffer()
    ChangeCurrFilename(MACRO_NAME + ':Meta' , CHANGE_CURR_FILENAME_FLAGS)
  endif
  PopLocation()


  // Find all occurrences of search string and just collect their meta data
  // in META_BUFFER_ID, while determining the length of the longest found
  // line number.

  PushLocation()
  remove_option('v', search_options)

  while find_across_lines(search_string,
                          search_options,
                          search_range)
    GotoBlockEnd()
    meta_data_line_to   = CurrLine()
    meta_data_pos_to    = CurrPos()
    GotoBlockBegin()
    meta_data_line_from = CurrLine()
    meta_data_pos_from  = CurrPos()
    remove_option('g', search_options)
    add_option   ('+', search_options)
    AddLine(Format(meta_data_line_from; meta_data_pos_from; meta_data_line_to;
                   meta_data_pos_to),
            META_BUFFER_ID)
    if Length(Str(meta_data_line_to)) > longest_line_number_length
      longest_line_number_length = Length(Str(meta_data_line_to))
    endif
    result = TRUE
  endwhile


  // If the search string was found at least once
  if result

    // Generate the list from the meta data,
    // inserting line numbers formatted with their longest found length,
    // and pre-calculating each line's from/to-hiliting positions.
    GotoBufferId(META_BUFFER_ID)
    BegFile()
    list_prefix_length = longest_line_number_length + 1 + Length(': ')

    repeat
      meta_data           = GetText(1, MAXSTRINGLEN)
      meta_data_line_from = Val(GetToken(meta_data, ' ', 1))
      meta_data_pos_from  = Val(GetToken(meta_data, ' ', 2))
      meta_data_line_to   = Val(GetToken(meta_data, ' ', 3))
      meta_data_pos_to    = Val(GetToken(meta_data, ' ', 4))

      GotoBufferId(org_id)
      MarkLine(meta_data_line_from, meta_data_line_to)
      Copy()

      GotoBufferId(LIST_ID)
      EndFile()
      if CurrLineLen()
        AddLine()
      endif
      Paste()
      UnMarkBlock()
      EndFile()
      Up(meta_data_line_to - meta_data_line_from)

      for line_number = meta_data_line_from to meta_data_line_to
        list_line     = CurrLine()
        list_line_len = CurrLineLen()
        BegLine()
        InsertText(Format(line_number: longest_line_number_length + 1, ': '))

        // Pre-calculate the hiliting positions for this list line.
        GotoBufferId(LIST_FOUND_ID)
        if not GotoLine(list_line)
          EndFile()
          repeat
            AddLine()
          until CurrLine() == list_line
        endif
        BegLine()
        if line_number == meta_data_line_from
          found_pos_from = list_prefix_length + meta_data_pos_from
        else
          found_pos_from = list_prefix_length + 1
        endif
        if line_number == meta_data_line_to
          found_pos_to   = list_prefix_length + meta_data_pos_to
        else
          found_pos_to   = list_prefix_length + list_line_len
        endif
        InsertText(Format(found_pos_from; found_pos_to; line_number == meta_data_line_to))

        GotoBufferId(LIST_ID)
        Down()
      endfor

      GotoBufferId(META_BUFFER_ID)
    until not Down()

    GotoBufferId(LIST_ID)
    BegFile()
    list_action = ''
    Hook(_LIST_STARTUP_, list_startup)

    if lList('View Finds', LongestLineInBuffer(), NumLines(), _ENABLE_SEARCH_|_ENABLE_HSCROLL_)
      if list_action == 'EditList'
        MarkLine(1, NumLines())
        Copy()
        NewFile()
        Paste()
        UnMarkBlock()
        BegFile()
        KillLocation()
      elseif CurrLineLen()
        list_line    = CurrLine()
        listed_line  = Val(GetToken(GetText(1, MAXSTRINGLEN), ':', 1))
        listed_match = 1
        BegFile()
        repeat
          if not CurrLineLen()
            listed_match = listed_match + 1
          endif
        until CurrLine() == list_line
           or not Down()

        GotoBufferId(META_BUFFER_ID)
        GotoLine(listed_match)
        repeat
          meta_data = GetText(1, MAXSTRINGLEN)
          meta_data_line_from = Val(GetToken(meta_data, ' ', 1))
          meta_data_pos_from  = Val(GetToken(meta_data, ' ', 2))
          meta_data_line_to   = Val(GetToken(meta_data, ' ', 3))
          meta_data_pos_to    = Val(GetToken(meta_data, ' ', 4))
        until (listed_line in meta_data_line_from .. meta_data_line_to)
           or not Down()

        GotoBufferId(org_id)
        GotoLine(meta_data_line_from)
        GotoPos(meta_data_pos_from)
        UnMarkBlock()
        MarkStream()
        GotoLine(meta_data_line_to)
        GotoPos(meta_data_pos_to)
        MarkStream()
        BegLine() // For optimal window positioning
        if     listed_line == meta_data_line_from
          GotoBlockBegin()
        elseif listed_line == meta_data_line_to
          GotoBlockEnd()
        else
          GotoLine(listed_line)
        endif
        KillLocation()
      else
        PopLocation()
      endif
    else
      PopLocation()
    endif
  else
    PopLocation()
  endif

  Set(InsertLineBlocksAbove, old_InsertLineBlocksAbove)
  return(result)
end find_all_across_lines


integer proc get_parameters(var string search_string,
                            var string search_options)

  string  macro_cmd_line [MAXSTRINGLEN] = Trim(Query(MacroCmdLine))
  integer result                        = TRUE

  if macro_cmd_line == ''
    if  Ask('Search for:',
            search_string,
            _FIND_HISTORY_)
    and Ask('Options [GIMVX] (Global Ignore-case Max-range View-all reg-eXp):',
            search_options,
            _FIND_OPTIONS_HISTORY_)
      result = TRUE
    else
      result = FALSE
    endif
  else
    search_string  = GetFileToken(macro_cmd_line, 1)
    search_options = GetFileToken(macro_cmd_line, 2)
  endif

  return(result)
end get_parameters


integer proc convert_parameters(var string  search_string,
                                var string  search_options,
                                var integer search_range_integer)
  integer i                            = 0
  integer result                       = TRUE
  string  search_range_string     [10] = ''

  for i = 1 to Length(search_options)
    if (search_options[i] in '0' .. '9')
      search_range_string = search_range_string + search_options[i]
    endif
  endfor

  search_range_integer = Val(search_range_string)

  if search_range_integer == 0
    search_range_integer = 255
  elseif search_range_integer > MAXLINELEN - 2
    Warn('ERROR: Requested search range (', search_range_integer,
         ') > MAXLINELEN - 2 (', MAXLINELEN - 2, ').')
    result = FALSE
  endif

  if result
    i = 1
    while i <= Length(search_options)
      if search_options[i] == 'm'
        search_range_integer = MAXLINELEN - 1
      endif

      // This is not mandatory, because TSE's lFind() ignores unknown search
      // options, but because this tool calls lFind() a massive amount of times,
      // cleaning up the search options beforehand will make the tool a tiny
      // bit faster.
      // And cleaning up clutter improves maintenability of this tool.
      if not (search_options[i] in 'g', 'i', 'v', 'x', '+')
        search_options = search_options[1: i - 1] + search_options[i + 1: MAXSTRINGLEN]
      endif
      i = i + 1
    endwhile

    if Pos('x', search_options)
      i = 1
      while i <= Length(search_string)
        if     search_string[i   ] == '^'
          search_string    = search_string[1: i - 1]
                           + '^|' + LF
                           + search_string[1 + 1: MAXSTRINGLEN]
        elseif search_string[i   ] == '$'
          search_string[i] = LF
        elseif search_string[i: 2] == '\s'
          search_string    = search_string[1: i - 1]
                           + '[\x00-\x20]'
                           + search_string[i + 2: MAXSTRINGLEN]
        endif
        i = i + 1
      endwhile
    endif
  endif

  return(result)
end convert_parameters


proc idle()
  // Do a lazy purge from memory of this macro,
  // namely when it is not or no longer being called by another macro.
  PurgeMacro(CurrMacroFilename())
end idle


proc WhenPurged()
  AbandonFile(LIST_FOUND_ID)
  AbandonFile(LIST_ID)
  AbandonFile(META_BUFFER_ID)
  AbandonFile(SLIDER_ID)
end WhenPurged


proc WhenLoaded()
  PushLocation()

  MACRO_NAME      = SplitPath(CurrMacroFilename(), _NAME_)
  REAL_TEXTATTR   = Query(TextAttr)
  REAL_CURSORATTR = Query(CursorAttr)

  SLIDER_ID       = CreateTempBuffer()
  ChangeCurrFilename(MACRO_NAME + ':Slider', CHANGE_CURR_FILENAME_FLAGS)
  BinaryMode(MAXLINELEN - 2)

  PopLocation()
end WhenLoaded


proc Main()
  integer old_Insert                        = Set(Insert, ON)
  integer result                            = FALSE
  string  tool_search_options          [12] = ''
  integer tool_search_range                 = 0
  string  tool_search_string [MAXSTRINGLEN] = ''
  string  user_search_options          [12] = ''
  string  user_search_string [MAXSTRINGLEN] = ''

  if get_parameters(user_search_string,
                    user_search_options)
    tool_search_string  = user_search_string
    tool_search_options = user_search_options
    if convert_parameters(tool_search_string,
                          tool_search_options,
                          tool_search_range)
      if Pos('v', tool_search_options)
        result = find_all_across_lines(tool_search_string,
                                       tool_search_options,
                                       tool_search_range)
      else
        result = find_across_lines(tool_search_string,
                                   tool_search_options,
                                   tool_search_range)
      endif
      if not result
        if Query(MsgLevel) == _ALL_MESSAGES_
          Message(user_search_string, ' not found.')
        endif
        if Query(Beep)
          Alarm()
        endif
      endif
    endif
  endif

  Hook(_IDLE_, idle)
  Set(Insert, old_Insert)
end Main

