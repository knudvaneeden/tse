/*
  Macro          HistList
  Author         Carlo.Hogeveen@xs4all.nl
  Compatibility  TSE Pro 4.0 upwards
  Version        1.0.2 - 9 Dec 2022

  PURPOSE

  This TSE extension changes searching in history lists from
  "only jump to the first match" to "show all matches".


  USAGE

  When in a standard TSE history list, just start typing to reduce the history
  list to all lines that match what you typed.

  What you type is interpreted as a case-insensitive TSE regular expression.
  For example, in the File Open history list:
    Type "mac" to show all previously opened TSE macros.
    Type "te?xt" to show files with "text" or "txt" in their names.
    Type  "\.s" or "s$" to show files with a ".s" extension.
  Invalid regular expressions result in an empty history list.
  For example:
    Typing "\.[s", "s|" and "*" will show an empty history list.

  Use the <BackSpace> key to delete typed characters.


  INSTALLATION

  Compile this macro, for instance by opening this file in TSE and using
  the Macro Compile menu.

  Then add this macro's name "HistList" to TSE's Macro AutoLoad List menu,
  and restart TSE.


  HISTORY

  v0.1 - 26 Oct 2019
    First beta release.
  v0.2 - 27 Oct 2019
    Fixed two major bugs in selecting a file.
  v0.3 - 28 Oct 2019
    Now hilites found results.
    Changed the search string and results colour to TSE's HiliteAttr,
    the same as the old history list uses for its one found result.
    Cannot match all values of TSE's InsertCursorSize configuration option,
    but now a history list cursor is used that better reflects its value
    using the characters " ", "_", "-", "=", "#" and "|".
  v1.0 - 29 Oct 2019
    Production release.
  v1.0.1 - 20 Sep 2020
    Fixed the bug, that if you deleted a history entry and without leaving
    the list immediately tried picking an entry below that, then you got the
    wrong entry.
  v1.0.2 - 9 Dec 2022
    Added <LeftBtn> as a way to select a history entry.
*/



// Global variables

integer augmented_history_list         = FALSE
string  cursor_character           [1] = '?'
string  cursor_status              [1] = ' '
integer full_list_id                   = 0
integer line_numbers_id                = 0
integer my_clipboard_id                = 0
string  my_macro_name   [MAXSTRINGLEN] = ''
integer result_updated                 = FALSE
string  search_string   [MAXSTRINGLEN] = ''
integer search_string_area_length      = 0
integer update_clockticks              = 0
integer work_list_id                   = 0


//  The following function determines the minimum amount of characters that a
//  given regular expression can match. For the practical purpose that they are
//  valid matches too, "^" and "$" are pretended to have length 1.
//  The purpose of this procedure is, to be able to beforehand avoid searching
//  for an empty string, which is logically pointless because it always succeeds
//  (with one exception: past the end of the last line).
//  Searching for an empty string in a loop makes it infinate and hangs a macro.
//  Properly applied, using this procedure can avoid that.

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

proc nonedit_idle_augmented_list()
  integer displayed_buffer_line_from = 0
  integer displayed_buffer_line_to   = 0
  integer displayed_Xoffset          = 0
  string  fnd_data    [MAXSTRINGLEN] = ''
  integer fnd_length                 = 0
  integer fnd_position               = 0
  integer line_nr                    = 0
  if GetBufferId() == work_list_id
    if result_updated
    or GetClockTicks() > update_clockticks
      result_updated    = FALSE
      update_clockticks = GetClockTicks() + 9

      // Display the search string with a trailing cursor.
      cursor_status = iif(cursor_status == ' ', cursor_character, ' ')
      if Length(search_string) + 1 > search_string_area_length
        search_string_area_length = Length(search_string) + 1
      endif
      PutStrAttrXY(2, 0,
                   Format(search_string + cursor_status:
                          search_string_area_length * -1),
                   '', Query(HiliteAttr))

      // Hilite the found strings in the found lines.
      displayed_buffer_line_from = CurrLine() - CurrRow() + 1
      displayed_buffer_line_to   = displayed_buffer_line_from +
                                   Query(WindowRows) - 1
      displayed_Xoffset          = CurrXoffset()
      GotoBufferId(line_numbers_id)
      for line_nr = displayed_buffer_line_from to displayed_buffer_line_to
        GotoLine(line_nr)
        if CurrLine() == line_nr
          fnd_data     = GetText(1, MAXSTRINGLEN)
          fnd_position = Val(GetToken(fnd_data, ' ', 2))
          fnd_length   = Val(GetToken(fnd_data, ' ', 3))
          if  fnd_position
          and fnd_length
            PutAttrXY(Query(WindowX1) + fnd_position - 1 - displayed_Xoffset,
                      Query(WindowY1) + line_nr - displayed_buffer_line_from,
                      Query(HiliteAttr),
                      fnd_length)
          endif
        endif
      endfor
      GotoBufferId(work_list_id)
    endif
  else
    Warn(my_macro_name, ': Program error 2.')
  endif
end nonedit_idle_augmented_list

proc create_all_line_references()
  integer line_nr   = 0
  integer num_lines = 0
  integer org_id    = GetBufferId()
  GotoBufferId(full_list_id)
  num_lines = NumLines()
  GotoBufferId(line_numbers_id)
  EmptyBuffer()
  for line_nr = 1 to num_lines
    AddLine(Str(line_nr))
  endfor
  GotoBufferId(org_id)
end create_all_line_references

proc after_nonedit_command()
  integer deleted_full_line_nr = 0
  integer deleted_work_line_nr = 0
  string  find_options     [3] = 'gix'
  integer fnd_length           = 0
  integer fnd_line_nr          = 0
  integer fnd_position         = 0
  integer last_key             = Query(Key)
  integer line_nr              = 0
  integer old_ilba             = 0
  integer old_line_nr          = 0
  integer old_msglevel         = 0
  integer old_uap              = 0
  string  old_wordset     [32] = ''
  integer org_clipboard_id     = Set(ClipBoardId, my_clipboard_id)
  result_updated = FALSE
  if last_key in 32 .. 126
    search_string  = search_string + Chr(last_key)
    result_updated = TRUE
  elseif last_key == <BackSpace>
    if Length(search_string) > 0
      search_string  = SubStr(search_string, 1, Length(search_string) - 1)
      result_updated = TRUE
    endif
  elseif (last_key in <Del>, <GreyDel>)
    deleted_work_line_nr = CurrLine()
    GotoBufferId(line_numbers_id)
    GotoLine(deleted_work_line_nr)
    deleted_full_line_nr = Val(GetToken(GetText(1, 10), ' ', 1))
    if CurrLine() == NumLines()
      KillLine()
    else
      KillLine()
      old_wordset = Set(WordSet, ChrSet('0-9'))
      PushBlock()
      repeat
        BegLine()
        MarkWord()
        line_nr = Val(GetMarkedText())
        KillBlock()
        InsertText(Str(line_nr - 1), _INSERT_)
      until not Down()
      PopBlock()
      Set(WordSet, old_wordset)
    endif
    GotoBufferId(full_list_id)
    GotoLine(deleted_full_line_nr)
    KillLine()
    GotoBufferId(work_list_id)
    result_updated = FALSE
  endif
  if result_updated
    old_line_nr = CurrLine()
    EmptyBuffer()
    GotoBufferId(full_list_id)
    PushBlock()
    if Length(search_string) == 0
      MarkLine(1, NumLines())
      Copy()
      GotoBufferId(work_list_id)
      Paste()
      UnMarkBlock()
      create_all_line_references()
    else
      GotoBufferId(line_numbers_id)
      EmptyBuffer()
      GotoBufferId(full_list_id)
      old_ilba     = Set(InsertLineBlocksAbove, FALSE)
      old_msglevel = Set(MsgLevel             , _NONE_)
      old_uap      = Set(UnMarkAfterPaste     , TRUE)
      if minimum_regexp_length(search_string) <= 0
        BegFile()
        EndLine()
        find_options = 'ix+'
      endif
      while lFind(search_string, find_options)
        fnd_line_nr  = CurrLine()
        fnd_position = CurrPos()
        fnd_length   = Length(GetFoundText())
        MarkLine(fnd_line_nr, fnd_line_nr)
        Copy()
        GotoBufferId(work_list_id)
        Paste()
        Down()
        GotoBufferId(line_numbers_id)
        AddLine(Format(fnd_line_nr; fnd_position; fnd_length))
        GotoBufferId(full_list_id)
        EndLine()
        find_options = 'ix+'
      endwhile
      Set(InsertLineBlocksAbove, old_ilba)
      Set(MsgLevel             , old_msglevel)
      Set(UnMarkAfterPaste     , old_uap)
    endif
    PopBlock()
    GotoBufferId(work_list_id)
    if old_line_nr <= NumLines()
      GotoLine(old_line_nr)
    else
      EndFile()
    endif
    BegLine()
  endif
  Set(ClipBoardId, org_clipboard_id)
end after_nonedit_command

proc augment_history_list()
  integer org_clipboard_id = Set(ClipBoardId, my_clipboard_id)
  work_list_id  = GetBufferId()
  search_string = ''
  search_string_area_length  = 0
  PushBlock()
  MarkLine(1, NumLines())
  Copy()
  GotoBufferId(full_list_id)
  EmptyBuffer()
  Paste()
  UnMarkBlock()
  create_all_line_references()
  GotoBufferId(work_list_id)
  PopBlock()
  Set(ClipBoardId, org_clipboard_id)
  if (Query(InsertCursorSize) in 0 .. 9)
    cursor_character = SubStr(' __--==##|', Query(InsertCursorSize) + 1, 1)
  else
    cursor_character = '!'
  endif
  Hook(_AFTER_NONEDIT_COMMAND_ , after_nonedit_command)
  Hook(_NONEDIT_IDLE_          , nonedit_idle_augmented_list)
end augment_history_list

proc process_augmented_history_selection()
  integer org_clipboard_id   = Set(ClipBoardId, my_clipboard_id)
  integer selected_full_line = 0
  integer selected_work_line = 0
  UnHook(after_nonedit_command)
  UnHook(nonedit_idle_augmented_list)
  if GetBufferId() == work_list_id
    if (Query(Key) in <Enter>, <GreyEnter>, <LeftBtn>)
      selected_work_line = CurrLine()
    endif
    PushBlock()
    GotoBufferId(full_list_id)
    MarkLine(1, NumLines())
    Copy()
    GotoBufferId(work_list_id)
    EmptyBuffer()
    Paste()
    UnMarkBlock()
    PopBlock()
    if selected_work_line
      GotoBufferId(line_numbers_id)
      GotoLine(selected_work_line)
      selected_full_line = Val(GetToken(GetText(1, 10), ' ', 1))
      GotoBufferId(work_list_id)
      GotoLine(selected_full_line)
    endif
  else
    Warn(my_macro_name, ': Program error 1.')
  endif
  Set(ClipBoardId, org_clipboard_id)
end process_augmented_history_selection

proc nonedit_idle_standard_list()
  string characters [MAXSTRINGLEN] = ''
  string attributes [MAXSTRINGLEN] = ''
  UnHook(nonedit_idle_standard_list)
  GetStrAttrXY(1, 0, characters, attributes, MAXSTRINGLEN)
  if Pos(' History ', characters)
    augmented_history_list = TRUE
    augment_history_list()
  endif
end nonedit_idle_standard_list

proc list_startup()
  augmented_history_list = FALSE
  Hook(_NONEDIT_IDLE_, nonedit_idle_standard_list)
end list_startup

proc list_cleanup()
  UnHook(nonedit_idle_standard_list)
  if augmented_history_list
    augmented_history_list = FALSE
    process_augmented_history_selection()
  endif
end list_cleanup

proc WhenPurged()
  AbandonFile(line_numbers_id)
  AbandonFile(my_clipboard_id)
  AbandonFile(full_list_id)
end WhenPurged

proc WhenLoaded()
  integer org_id = GetBufferId()
  my_macro_name   = SplitPath(CurrMacroFilename(), _NAME_)
  my_clipboard_id = CreateTempBuffer()
  ChangeCurrFilename(my_macro_name + ':ClipBoard',
                     _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
  line_numbers_id = CreateTempBuffer()
  ChangeCurrFilename(my_macro_name + ':LineNumbers',
                     _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
  full_list_id = CreateTempBuffer()
  ChangeCurrFilename(my_macro_name + ':SavedFullList',
                     _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
  GotoBufferId(org_id)
  Hook(_LIST_STARTUP_     , list_startup)
  Hook(_LIST_CLEANUP_     , list_cleanup)
end WhenLoaded

