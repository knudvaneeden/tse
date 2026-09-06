/*
  Macro.         eList
  Author.        Carlo.Hogeveen@xs4all.nl
  Compatibility  TSE Pro 4.0 upwards
  Version        1.0.1   6 Jan 2019

  PURPOSE
    "List the current file" with a "shrink the list as you type" search function
    as an alternative to TSE's built-in List() and lList() functions.

    It has these differences:
    - You cannot set the list's width and height: It determines its own width
      and height based on the length of the current file and its longest line.
    - You cannot set the search and horizontal scroll flags:
      Search is always enabled and irregardless of block scope.
      You can always scroll horizontally.
    - You can also call the function as a macro,
      so you can also use it as a "search the current file" command.
    - Typing in the list shrinks it to those lines that match the typed string.
      The search string is treated as a case-insensitive TSE regular expression.
      An incomplete regular expression results in an empty list.

    Macro programmers be aware, that I am thinking about implementing
    ListFooter() and list-specific keys in the future: If you do the same for
    this list, then we might clash.

  INSTALLATION
    Copy this file to TSE's "mac" folder, open the file in TSE,
    and compile it with the Macro -> Compile menu.

  USAGE EXAMPLES
    In all cases you need to call eList with one parameter: its title.

    Calling the list as a user or externally from another macro:
      ExecMacro('eList My Enemies')

    Calling the list as a procedure after including the eList macro in your
    macro:
      #DEFINE ELIST_INCLUDED TRUE
      #include ['eList.s']
      eList('My Enemies')

    While in the list, without the quotes, and implicitly case-insensitive:
      Typing "mosquito" will reduce the list to lines containing the string
      "mosquito".
      Typing "{mosquito}|{daylight}" will reduce the list to lines containing
      either the string "mosquito" or the string "daylight" or both.
      Typing "{mosquito.*daylight}|{daylight.*mosquito}" will reduce the list
      to lines containing both the strings "mosquito" and "daylight" in either
      order.
      Typing "." will reduce the list to not-empty lines.
      Typing "\." will reduce the list to lines containing a ".".

  INNER WORKING NOTES
    The TSE lFind function itself returns FALSE for an illegal regular
    expression, so eList interpret that as not matching any lines and suppress
    the accompanying warning.

    There are legal regular expressions that can match an empty string, and
    would therefore in the best-case scenario match all lines. For such regular
    expressions that best-case scenario is explicitly implemented using the
    eList_minimum_regexp_length procedure.

    Be aware that the eList_lst_linenos_id buffer is (made) empty when the list
    equals the whole current file: In that case the knowledge is used that a
    list's selected line number will be equal to that of the current file.

  HISTORY
  v1.0    6 Jan 2019
    Initial release.
  v1.0.1  15 Jan 2019
    Fixed a design bug:
      The eList() proc could not receive the title parameter
      nor could it return a numeric result.
*/

integer eList_lst_linenos_id        = 0
integer eList_lst_text_id           = 0
integer eList_org_id                = 0
string  eList_typed  [MAXSTRINGLEN] = ''

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
integer proc eList_minimum_regexp_length(string s)
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
        addition = eList_minimum_regexp_length(SubStr(s,prev_i+1,i-prev_i-1))
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
end eList_minimum_regexp_length

proc eList_after_nonedit_command()
  string  find_options [3] = 'gix'
  integer last_key                = Query(Key)
  integer old_ilba                = Query(InsertLineBlocksAbove)
  integer old_uap                 = Query(UnMarkAfterPaste)
  integer old_msglevel            = Query(MsgLevel)
  integer org_lineno              = 0
  integer org_num_lines           = 0
  integer resized                 = FALSE
  if last_key in 32 .. 126
    eList_typed = eList_typed + Chr(last_key)
    resized     = TRUE
  elseif last_key == <BackSpace>
    if Length(eList_typed) > 0
      eList_typed = SubStr(eList_typed, 1, Length(eList_typed) - 1)
      resized     = TRUE
    endif
  endif
  if resized
    EmptyBuffer()
    GotoBufferId(eList_lst_linenos_id)
    EmptyBuffer()
    GotoBufferId(eList_org_id)
    PushPosition()
    PushBlock()
    if Length(eList_typed) == 0
      Message('Start typing letters and digits or a TSE regular expression to shrink this list.')
      org_num_lines = NumLines()
      MarkLine(1, org_num_lines)
      Copy()
      GotoBufferId(eList_lst_text_id)
      Paste()
      GotoBufferId(eList_org_id)
    else
      Message('Lines matching with (reg exp) "', eList_typed,
              '".          Type more or <Backspace>.')
      old_ilba     = Set(InsertLineBlocksAbove, FALSE)
      old_msglevel = Set(MsgLevel             , _NONE_)
      old_uap      = Set(UnMarkAfterPaste     , TRUE)
      if eList_minimum_regexp_length(eList_typed) <= 0
        BegFile()
        EndLine()
        find_options = 'ix+'
      endif
      while lFind(eList_typed, find_options)
        org_lineno = CurrLine()
        MarkLine(org_lineno, org_lineno)
        Copy()
        GotoBufferId(eList_lst_text_id)
        Paste()
        Down()
        GotoBufferId(eList_lst_linenos_id)
        AddLine(Str(org_lineno))
        GotoBufferId(eList_org_id)
        EndLine()
        find_options = 'ix+'
      endwhile
      Set(InsertLineBlocksAbove, old_ilba)
      Set(MsgLevel             , old_msglevel)
      Set(UnMarkAfterPaste     , old_uap)
    endif
    PopPosition()
    PopBlock()
    GotoBufferId(eList_lst_text_id)
    BegFile()
  endif
end eList_after_nonedit_command

integer proc eList(string eList_title)
  integer lst_selected_lineno = 0
  integer org_selected_lineno = 0
  eList_org_id = GetBufferId()
  eList_typed  = ''
  PushPosition()
  PushBlock()
  MarkLine(1, NumLines())
  Copy()
  if eList_lst_linenos_id
    GotoBufferId(eList_lst_linenos_id)
    EmptyBuffer()
  else
    eList_lst_linenos_id = CreateTempBuffer()
    ChangeCurrFilename(SplitPath(CurrMacroFilename(), _NAME_) + ':lst_linenos',
                       _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
  endif
  if eList_lst_text_id
    GotoBufferId(eList_lst_text_id)
    EmptyBuffer()
  else
    eList_lst_text_id = CreateTempBuffer()
    ChangeCurrFilename(SplitPath(CurrMacroFilename(), _NAME_) + ':lst_text',
                       _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
  endif
  Paste()
  UnMarkBlock()
  Message('Start typing letters and digits or a TSE regular expression to shrink this list.')
  Set(Y1, 3)
  Hook(_AFTER_NONEDIT_COMMAND_, eList_after_nonedit_command)
  if lList(eList_title, LongestLineInBuffer(), Query(ScreenRows) - 3, _ENABLE_HSCROLL_)
    lst_selected_lineno = CurrLine()
  endif
  UnHook(eList_after_nonedit_command)
  if lst_selected_lineno <> 0
    GotoBufferId(eList_lst_linenos_id)
    GotoLine(lst_selected_lineno)
    org_selected_lineno = Val(GetText(1, MAXSTRINGLEN))
    if org_selected_lineno == 0
      org_selected_lineno = lst_selected_lineno
    endif
  endif
  GotoBufferId(eList_org_id)
  PopPosition()
  PopBlock()
  if org_selected_lineno
    GotoLine(org_selected_lineno)
    ScrollToCenter()
    BegLine()
    if eList_typed <> ''
      lFind(eList_typed, 'cgix')
      // In case of a regexp it can be nice to see what it actually matched:
      MarkFoundText()
    endif
    UpdateDisplay()
  endif
  Message('')
  return(org_selected_lineno)
end eList

#ifndef ELIST_INCLUDED
  proc Main()
    eList(Query(MacroCmdLine))
    AbandonFile(eList_lst_linenos_id)
    AbandonFile(eList_lst_text_id)
    PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
  end Main
#endif

