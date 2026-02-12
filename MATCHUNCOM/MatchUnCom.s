/*
  Macro           MatchUnCom
  Author          Carlo.Hogeveen@xs4all.nl
  Version         0.1 - 6 Apr 2020
  Compatibility   TSE Pro v4.4 upwards

  This is a quick&dirty adaptation of Semware's "match" macro dd 6 Apr 2020.

  Like the Match macro, for the bracket under the cursor it jumps to its
  counterpart, but as requested by a user it ignores any in-between commented
  brackets. So it "matches uncommented" brackets. [Is that even English?]

  I do NOT recommend substituting Match by MatchUnCom.
  MatchUncom has known flaws:
  - It blindly assumes that comment colours are always delimiter colours,
    which for some configurations might be false.
  - It is badly tested. The user's example test case worked on the first try,
    and I didn't test any further.
*/

/**************************************************************************
  match.s

  log:
  Mar  26, 1993 SEM initial version
  Jan   2, 1997 SEM add string-length-between-quotes feature
  Apr  29, 1997 SEM re-work so it can be called by VisualMatch
  Nov  20, 1997 SEM in count code, if matching " not found, scan left for match
  Oct  16, 1998 SEM don't scroll horizontally unless we have to
  May      2003 SEM allow match function to work on any two
        tokens, e.g.:
        match('(', ')', forward, stay-in-window)
        match('begin', 'end', forward, false)
        match('end', 'begin', backward, false)

  1) If the cursor is on (){}[]<>, position to matching character.
  2) If the cursor is on '", count the number of characters in-between.
  3) Otherwise, go forward looking for a match character as in 1) above.
 **************************************************************************/


integer proc is_commented()
  string  comment_colour_regexp              [50] = ''
  integer found_string_length                     = 0
  integer result                                  = FALSE
  integer screen_read_length                      = 0
  string  screen_string_attributes [MAXSTRINGLEN] = ''
  string  screen_string_characters [MAXSTRINGLEN] = ''
  integer screen_x                                = 0
  integer screen_y                                = 0
  integer window_x                                = 0
  integer window_y                                = 0

  PushLocation()
  found_string_length = Length(GetFoundText())
  window_x = CurrCol() - CurrXoffset()
  if window_x + found_string_length - 1 > Query(WindowCols)
    // Scroll the whole found string into the window.
    ScrollRight(found_string_length - 1)
    window_x = CurrCol() - CurrXoffset()
  endif
  window_y = CurrRow()
  screen_x = window_x + Query(WindowX1) - 1
  screen_y = window_y + Query(WindowY1) - 1
  UpdateDisplay(_ALL_WINDOWS_REFRESH_) // Activate syntax highlighting.
  screen_read_length = GetStrAttrXY(screen_x, screen_y,
                                    screen_string_characters,
                                    screen_string_attributes,
                                    found_string_length)
  if screen_read_length > 0
    comment_colour_regexp = Format('[',
                                   '\d', Query(MultiLnDlmt1Attr ):3:'0',
                                   '\d', Query(MultiLnDlmt2Attr ):3:'0',
                                   '\d', Query(MultiLnDlmt3Attr ):3:'0',
                                   '\d', Query(SingleLnDlmt1Attr):3:'0',
                                   '\d', Query(SingleLnDlmt2Attr):3:'0',
                                   '\d', Query(SingleLnDlmt3Attr):3:'0',
                                   '\d', Query(ToEol1Attr       ):3:'0',
                                   '\d', Query(ToEol2Attr       ):3:'0',
                                   '\d', Query(ToEol3Attr       ):3:'0',
                                   ']')
    result = StrFind(comment_colour_regexp, screen_string_attributes, 'x')
  endif
  PopLocation()
  return(result)
end is_commented

integer proc lFind_uncommented(string search_string, string search_options)
  integer p                                   = 0
  integer findable                            = TRUE
  integer found                               = FALSE
  string  my_search_options    [MAXSTRINGLEN] = Trim(search_options)
  string  next_search_options  [MAXSTRINGLEN] = Trim(search_options)
  repeat
    p = Pos('g', Lower(next_search_options))
    if p
      next_search_options = next_search_options[1     : p - 1]        +
                            next_search_options[p + 1 : MAXSTRINGLEN]
    endif
  until not p
  if      Pos('x', Lower(next_search_options))
  and not Pos('+',       next_search_options )
    next_search_options = next_search_options + '+'
  endif
  PushLocation()
  repeat
    found = lFind(search_string, my_search_options)
    if found
      if is_commented()
        found = FALSE
      endif
    else
      findable = FALSE
    endif
  until     found
    or  not findable
  if found
    KillLocation()
  else
    PopLocation()
  endif
  return(found)
end lFind_uncommented

string proc fixup(string s)
    integer i
    string s2[255] = ""

    for i = 1 to Length(s)
        if Pos(s[i], "`~!@#$%^&*()-_=+\|[]{};:,./<>?")
            s2 = s2 + '\' + s[i]
        else
            s2 = s2 + s[i]
        endif
    endfor
    return (s2)
end

integer proc Match(string ch, string mc, integer onward, integer stay_in_window)
    integer level, start_line, start_row, start_xoffset
    string find_str[80], find_options[10]

    start_xoffset = CurrXoffset()
    start_line = CurrLine()
    start_row = CurrRow()

    level = 1                       // Start out at level 1

    find_options = "x" + iif(onward, "+", "b")
    // what about things like 'begin', 'end'? use word option if
    // either token begins and ends in an alpha character
    if isAlpha(ch[1]) and isAlpha(ch[Length(ch)]) or
       isAlpha(mc[1]) and isAlpha(mc[Length(mc)])
        find_options = find_options + 'w'
    endif

    PushBlock()
    if stay_in_window
        find_options = find_options + "l"
        PushPosition()
        BegWindow()
        MarkLine()
        EndWindow()
        MarkLine()
        PopPosition()
    endif

    if Length(ch) == 1 and Length(mc) == 1
        find_str = "[\" + ch + "\" + mc + "]"
    else
        find_str = "{" + fixup(ch) + "}|{" + fixup(mc) + "}"
    endif

    while lFind_uncommented(find_str, find_options)
        case CurrChar()             // And check out the current character
            when Asc(ch)
                level = level + 1
            when Asc(mc)
                level = level - 1
                if level == 0
                    if CurrXoffset() <> start_xoffset
                        GotoXoffset(start_xoffset)       // Fix up possible horizontal scrolling
                    endif
                    ScrollToRow(CurrLine() - start_line + start_row)
                    PopBlock()
                    return (TRUE)           // And return success
                endif
        endcase
    endwhile

    PopBlock()
    return (FALSE)
end

proc CountString()
    integer c1

    PushPosition()

    c1 = CurrPos()
    if lFind_uncommented(Chr(CurrChar()), "+c") or lFind_uncommented(Chr(CurrChar()), "bc")
        Message("String is ", Abs(CurrPos() - c1) - 1, " characters long.")
    else
        Message("End of string not found...")
    endif

    PopPosition()
end

/****************************************************************************
  The match command.  Use this macro to match (){}{}<> chars.

  If first arg is "vmatch", just match, and return true/false accordingly.
 ***************************************************************************/
proc Main()
    integer p, start_line, start_row
    string ch[1], mc[1], match_chars[32] = "(){}[]<>"   // pairs of chars to match


    p = Pos(Chr(CurrChar()), match_chars)
    if p
        ch = match_chars[p]             // Get the character we're matching
        mc = match_chars[iif(p & 1, p + 1, p - 1)]  // And its reverse
    endif

    if Lower(Query(MacroCmdLine)) == "vmatch"
        Set(MacroCmdLine, iif(p and Match(ch, mc, p & 1, TRUE), "true", "false"))
        return ()
    endif

    start_line = CurrLine()
    start_row = CurrRow()
    // If we're not already on a match char, go forward to find one
    if p == 0
        if CurrChar() in Asc('"'), Asc("'")
            CountString()
        elseif lFind_uncommented("[(){}[\]<>]", "x")
            ScrollToRow(CurrLine() - start_line + start_row)
        endif
    else
        PushPosition()
        if Match(ch, mc, p & 1, FALSE)
            KillPosition()
        else
            PopPosition()
            Warn("Match not found")
        endif
    endif
end

#if 0
// to match /* */ multiline comments:
<f3>  if CurrChar() in Asc('/')
        Match('/*', '*/', TRUE, FALSE)
      elseif CurrChar() in Asc('*')
        Match('*/', '/*', FALSE, FALSE)
      endif
// to match "begin" "end":

<f3>  if CurrChar() in Asc('b')
        Match('begin', 'end', TRUE, FALSE)
      elseif CurrChar() in Asc('e')
        Match('end', 'begin', FALSE, FALSE)
      endif
#endif
