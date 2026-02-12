/*
  Macro.         eList2
  Author.        Carlo.Hogeveen@xs4all.nl
  Compatibility  TSE Pro v4.0 upwards
  Version        v0.1 - 13 Sep 2019

  CAVEAT !!!

    This is neither a finished nor a well-working macro.
    I do not see a way forward, so I am abandoning this one.

    The intention was to show "best matches first" for a search string, BUT:
    - Intentions turned out to be hard to catch in programming logic.
      I experimented with "weight", but the result is not satisfactory.
    - Implementing intentions turns unavoidably out to be implementing my own
      biases, and worse, my current biases based on my current porposes.
      That makes it impossible to make this a generic tool.
    - For larger files it works too slow. I reduced the searched number of
      results, but that reduced the results. Pun intended.

  PURPOSE
    This tool lists lines from the current file with a "shrink the list as you
    type" search function, that uses a multiple format search string, and ranks
    the search results by sorting the found lines on the most matching ones.

    It is intended as a much smarter alternative to TSE's built-in List() and
    lList() functions, and as an alternative to the eList macro.

    It has these differences from TSE's List() and lList() functions:
    - You cannot set the list's width and height: It determines its own width
      and height based on the length of the current file and its longest line.
    - You cannot set the search and horizontal scroll flags:
      Search is always enabled and irregardless of block scope.
      You can always scroll horizontally.
    - You can also call the function as a macro,
      so you can also use it as a "search the current file" command.
    - Typing in the list shrinks it to those lines that match the typed string.
    - The search string is interpreted in many ways.
    - Matching lines are sorted on the most matches.

    It has these differences from the eList macro:
    - It searches the typed search string using multiple search formats and
      options.
    - Default it sorts the found lines on the most matches.
      Note that this might not be what you want for files where line order
      matters, like source code.

    These combinations of search string interpretations will be tried:
    - Matching the whole line.
    - Matching a word.
    - Matching a regular expression.
    - All of the above both case-sensitive and case-insensitive.
    - Quoted parts (*) and unquoted whitespace-separated parts as all of the
      above.

    (*)
      If you double quote a string that contains spaces, then only matches for
      the whole string will be found.
      Conversely, you cannot search for a string that contains a double quote.


  INSTALLATION
    Copy this file to TSE's "mac" folder, open the file in TSE,
    and compile it with the Macro -> Compile menu.


  USAGE
    Example of including the eList2 macro in your own macro:
      #DEFINE ELIST2_INCLUDED TRUE
      #include ['eList2.s']
      eList2('My Enemies')

    When eList2 is included in your own macro, you must call it with exactly
    one string parameter, which may consist of zero to two actual parameters:
      eList2('')                      // Start the list with no title.
      eList2('My Enemies')            // Start the list using this title.
      eList2('My Enemies _NO_SORT_')  // Do NOT sort the list on most match.
      eList2('_NO_SORT_')             // No title, no sort on most match.

    Or you can call eList2 as an external macro:
      ExecMacro('eList2')
      ExecMacro('eList2 My Enemies')
      ExecMacro('eList2 My Enemies _NO_SORT_')
      ExecMacro('eList2 _NO_SORT_')

    _NO_SORT_
      Default found lines are sorted on the most matches.
      With this parameter found lines are shown in their original order.
      This was not the original purpose of this macro, but since your (and my
      future) mileage may vary and since this option is cheap, the _NO_SORT_
      parameter was added.
      Benefits:
      - The found lines remain in their original order.
      - One tool for normal search strings, regular expressions, etc.
      Cost:
      - The line you are actually looking for is less likely to appear
        near the top of the list, or even on the first page.
      Sometimes cost, sometimes benefit:
      - Possibly more (too many?) search results for the same search string
        than when using the eList macro or TSE itself.



  INNER WORKING NOTES
    The TSE lFind function itself returns FALSE for an illegal regular
    expression, so eList2 interprets that as not matching any lines and
    suppresses the accompanying warning.

    There are valid regular expressions that can also match an empty string,
    and would therefore in theory match all lines.
    In practice such regular expressions can cause a macro to loop infinitely
    because they might succeed without advancing the cursor.
    Therefore, and to save processing time, such regular expressions are
    treated as an explicitly recognized exception using the
    eList2_minimum_regexp_length procedure.

    Be aware that the eList2_rank_id buffer is (made) empty when the list
    equals the whole current file: In that case the knowledge is used that a
    list's selected line number will be equal to that of the current file.


  HISTORY
    v0.1 - 13 Sep 2019
      Initial beta.
*/



// Global constants

// Must limit the number of results, or the performance becomes even more
// atrocious for larger files.
#define ELIST2_MAX_RESULT_LINES 1000



// Global variables

integer eList2_list_id                      = 0
integer eList2_rank_id                      = 0
string  eList2_search_string [MAXSTRINGLEN] = ''
string  eList2_sort_type               [12] = 'MOST_MATCHES'
integer eList2_source_id                    = 0

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
integer proc eList2_minimum_regexp_length(string s)
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
        addition = eList2_minimum_regexp_length(SubStr(s,prev_i+1,i-prev_i-1))
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
end eList2_minimum_regexp_length

proc eList2_find(string  search_string,
                 string  base_search_options,
                 integer insensitive_weight)
  string  case_search_option [1] = ''
  integer case_insensitivity     = FALSE
  integer found_lines            = 0
  integer line_nr                = 0
  string  loop_search_option [1] = ''
  integer rank                   = 0
  integer weight                 = insensitive_weight
  if  Pos('x', base_search_options)
  and eList2_minimum_regexp_length(search_string) <= 0
    // A regular expression matching the empty string would theoretically
    // match all lines, and possibly cause an infinite loop.
    NoOp() // Not functional, but added for human debugging.
  else
    GotoBufferId(eList2_rank_id)
    found_lines = NumLines()
    GotoBufferId(eList2_source_id)
    for case_insensitivity = 0 to 1
      case_search_option = iif(case_insensitivity, 'i', '')
      loop_search_option = 'g'
      while found_lines <= ELIST2_MAX_RESULT_LINES
      and   lFind(eList2_search_string,
                  base_search_options + case_search_option + loop_search_option)
        line_nr = CurrLine()
        GotoBufferId(eList2_rank_id)
        if lFind(Format(line_nr:10:'0', ' '), '^g')
          rank = Val(GetText(12, 10)) + weight
          GotoColumn(12)
          KillToEol()
          InsertText(Format(rank:10:'0'), _INSERT_)
        else
          if found_lines < ELIST2_MAX_RESULT_LINES
            EndFile() // Not functional, but added for human debugging.
            AddLine(Format(line_nr:10:'0', ' ', weight:10:'0'))
          endif
          found_lines = found_lines + 1
        endif
        GotoBufferId(eList2_source_id)
        loop_search_option = '+'
      endwhile
      weight = weight / 2
    endfor
  endif
end eList2_find

proc eList2_after_nonedit_command()
  integer i                             = 0
  integer last_key                      = Query(Key)
  integer line_nr                       = 0
  integer max_line_nr                   = 0
  integer max_line_nr_width             = 0
  string  msg            [MAXSTRINGLEN] = ''
  string  msg_extra_info [MAXSTRINGLEN] = 'Type more or <BackSpace>.'
  integer old_ilba                      = Set(InsertLineBlocksAbove, FALSE)
  integer old_msglevel                  = Set(MsgLevel             , _ALL_MESSAGES_)
  integer old_uap                       = Set(UnMarkAfterPaste     , TRUE)
  integer resized                       = FALSE
  if last_key in 32 .. 126
    eList2_search_string = eList2_search_string + Chr(last_key)
    resized              = TRUE
  elseif last_key == <BackSpace>
    if Length(eList2_search_string) > 0
      eList2_search_string = SubStr(eList2_search_string, 1, Length(eList2_search_string) - 1)
      resized              = TRUE
    endif
  endif
  if resized
    GotoBufferId(eList2_list_id)
    EmptyBuffer()
    GotoBufferId(eList2_rank_id)
    EmptyBuffer()
    GotoBufferId(eList2_source_id)
    PushPosition()
    PushBlock()
    if Length(eList2_search_string) == 0
      msg = 'Start typing a search string to shrink this list ... '
      Message(msg)
      Set(MsgLevel, _WARNINGS_ONLY_)
      MarkLine(1, NumLines())
      Copy()
      GotoBufferId(eList2_list_id)
      Paste()
      GotoBufferId(eList2_source_id)
    else
      msg = 'Lines most matching with "' + eList2_search_string + '" '
      Message(msg, ' ...')
      if Length(msg + msg_extra_info) <= Query(ScreenCols)
        msg = Format(msg, msg_extra_info: Query(ScreenCols) - Length(msg))
      endif
      Message(msg)
      Set(MsgLevel, _NONE_) // Also block illegal regexp messages.
      eList2_find(eList2_search_string, '^$', 1000000)
      eList2_find(eList2_search_string, 'w' ,   10000)
      eList2_find(eList2_search_string, ''  ,     100)
      eList2_find(eList2_search_string, 'x' ,       1)
      if NumFileTokens(eList2_search_string) > 1
        for i = 1 to NumFileTokens(eList2_search_string)
          eList2_find(GetFileToken(eList2_search_string, 1), '^$', 1000000)
          eList2_find(GetFileToken(eList2_search_string, 1), 'w' ,   10000)
          eList2_find(GetFileToken(eList2_search_string, 1), ''  ,     100)
          eList2_find(GetFileToken(eList2_search_string, 1), 'x' ,       1)
        endfor
      endif
    endif
    GotoBufferId(eList2_rank_id)
    if NumLines()
      // Always first sort on LINE_NR
      MarkColumn(1, 1, NumLines(), 10)
      ExecMacro('sort -i')
      Message('')
      EndFile()
      max_line_nr       = Val(GetText(1, 10))
      max_line_nr_width = Length(Str(max_line_nr))
      if eList2_sort_type <> 'LINE_NR'
        // Default sort on rank: 'MOST_MATCHES'
        MarkColumn(1, 12, NumLines(), 21)
        ExecMacro('sort -i -d')
        Message('')
      endif
      Message(msg)
      UnMarkBlock()
      BegFile()
      repeat
        line_nr = Val(GetText(1, 10))
        GotoBufferId(eList2_source_id)
        GotoLine(line_nr)
        MarkLine(line_nr, line_nr)
        Copy()
        GotoBufferId(eList2_list_id)
        EndFile()
        Paste()
        Down()
        BegLine()
        InsertText(Format(line_nr:max_line_nr_width, ':   '))
        GotoBufferId(eList2_rank_id)
      until not Down()
    endif
    PopPosition()
    PopBlock()
    GotoBufferId(eList2_list_id)
    BegFile()
  endif
  Set(InsertLineBlocksAbove, old_ilba)
  Set(MsgLevel             , old_msglevel)
  Set(UnMarkAfterPaste     , old_uap)
end eList2_after_nonedit_command

integer proc eList2(string parameters)
  integer list_selected_line_nr     = 0
  string  list_title [MAXSTRINGLEN] = Trim(parameters)
  eList2_source_id     = GetBufferId()
  eList2_search_string = ''
  if Pos('_NO_SORT_', Upper(list_title))
    eList2_sort_type = 'LINE_NR'
    list_title = list_title[1: Pos('_NO_SORT_', Upper(list_title)) - 1] +
                 list_title[Pos('_NO_SORT_', Upper(list_title)) + 9: MAXSTRINGLEN]
  else
    eList2_sort_type = 'MOST_MATCHES'
  endif
  PushPosition()
  PushBlock()
  MarkLine(1, NumLines())
  Copy()
  if eList2_rank_id
    GotoBufferId(eList2_rank_id)
    EmptyBuffer()
  else
    eList2_rank_id = CreateTempBuffer()
    ChangeCurrFilename(SplitPath(CurrMacroFilename(), _NAME_) + ':ranking',
                       _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
  endif
  if eList2_list_id
    GotoBufferId(eList2_list_id)
    EmptyBuffer()
  else
    eList2_list_id = CreateTempBuffer()
    ChangeCurrFilename(SplitPath(CurrMacroFilename(), _NAME_) + ':list',
                       _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
  endif
  Paste()
  UnMarkBlock()
  Message('Start typing a search string to shrink this list ... ')
  Set(Y1, 3)
  Hook(_AFTER_NONEDIT_COMMAND_, eList2_after_nonedit_command)
  if lList(list_title, LongestLineInBuffer(), Query(ScreenRows) - 3,
           _ENABLE_HSCROLL_)
    list_selected_line_nr = Val(GetToken(GetText(1, 10), ':', 1))
  endif
  UnHook(eList2_after_nonedit_command)
  GotoBufferId(eList2_source_id)
  PopPosition()
  PopBlock()
  if list_selected_line_nr
    GotoLine(list_selected_line_nr)
    ScrollToCenter()
    BegLine()
    if eList2_search_string <> ''
      lFind(eList2_search_string, 'cgix')
      // In case of a regexp it can be nice to see what it actually matched:
      MarkFoundText()
    endif
    UpdateDisplay()
  endif
  Message('')
  return(list_selected_line_nr)
end eList2

#ifndef ELIST2_INCLUDED
  proc Main()
    eList2(Query(MacroCmdLine))
    AbandonFile(eList2_rank_id)
    AbandonFile(eList2_list_id)
    PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
  end Main
#endif

