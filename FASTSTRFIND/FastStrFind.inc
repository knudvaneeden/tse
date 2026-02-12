/*
  Include File  FastStrFind
  Author        Carlo Hogeveen
  Website       eCarlo.nl/tse
  Version       v1 - 13 Feb 2021

  This include file provides the procedure FastStrFind, which for non-regular,
  non-word expressions is a faster version of TSE's StrFind() function.

  If you call FastStrFind() with a regular expression or word option,
  then it will just past the call on to StrFind().

  You can use FastStrFind() just like StrFind() with these differences:
  - For FastStrFind() all 5 parameters are mandatory.
  - For a backwards search without a word or regular expression option
    when searching for an Nth occurrence where N > 1:
      StrFind() has a known bug: it returns erroneous results.
      FastStrFind() returns the correct results.


  INSTALLATION

  Just copy this file to TSE's "mac" folder, and add
    #include ['FastStrFind.inc']
  somewhere before FastStrFind()'s use in the code of your own macro.

  FastStrFind.inc has an accompanying example macro FastStrFind_test.s .


  TECHNICAL NOTES

  FastStrFind()'s faster speed is possible because StrFind() uses a slow
  algorithm. StrFind() copies the haystack to a temporary buffer and then
  uses lFind() to search the needle in that buffer.
  Obviously this incurs a large overhead.
  For simple operations FastStrFind() can improve on this by working directly
  on the haystack string instead.
  For more complex operations that advantage is lost, because FastStrFind()
  is implemented in the half compiled, half interpreted macro language,
  whereas StrFind() is fully compiled from C.
  So it is not possible to implement a faster StrFind() for regular expressions
  or word searches or to implement a faster StrReplace().

  FastStrFind_reverse_string() is a helper function for FastStrFind().

*/

proc FastStrFind_reverse_string(var string s)
  string  c [1] = ''
  integer i     = 0
  integer j     = Length(s)
  for i = 1 to j / 2
    c    = s[i]
    s[i] = s[j]
    s[j] = c
    j    = j - 1
  endfor
end FastStrFind_reverse_string

integer proc FastStrFind(string needle, string haystack, string options,
                         integer occurrence, var integer len)
  integer found_occurrence          = 0
  integer found_offset              = 0
  integer found_position            = 0
  string  l_haystack [MAXSTRINGLEN] = ''
  string  l_needle   [MAXSTRINGLEN] = ''
  string  l_options  [MAXSTRINGLEN] = Lower(options)
  integer needle_position           = 0
  integer searched_occurrence       = 0
  integer searched_position         = 0

  if Pos('w', l_options)
  or Pos('x', l_options)
    searched_position = StrFind(needle, haystack, options, occurrence, len)
  else
    if Pos('i', l_options)
      l_needle   = Lower(needle)
      l_haystack = Lower(haystack)
    else
      l_needle   = needle
      l_haystack = haystack
    endif
    if Pos('b', l_options)
      FastStrFind_reverse_string(l_haystack)
      FastStrFind_reverse_string(l_needle)
    endif
    len = 0
    searched_occurrence = Max(occurrence, 1)
    if     Pos('^', l_options)
      if  searched_occurrence == 1
      and l_haystack[1: Length(l_needle)] == l_needle
        searched_position = 1
      endif
    elseif Pos('$', l_options)
      if searched_occurrence == 1
        needle_position = Length(l_haystack) - Length(l_needle) + 1
        if l_haystack[needle_position: MAXSTRINGLEN] == l_needle
          searched_position = needle_position
        endif
      endif
    else
      repeat
        found_offset   = found_position + 1
        found_position = Pos(l_needle, l_haystack[found_offset: MAXSTRINGLEN])
        if found_position
          found_position   = found_position + found_offset - 1
          found_occurrence = found_occurrence + 1
          if found_occurrence == searched_occurrence
            len = Length(l_needle)
            if Pos('b', l_options)
  //          searched_position =   (Length(l_haystack) + 1)
  //                              - (found_position + (Length(l_needle) - 1))
  //          Which simplified equals:
              searched_position = Length(l_haystack) - found_position - len + 2
            else
              searched_position = found_position
            endif
          endif
        endif
      until len or not found_position
    endif
  endif
  return(searched_position)
end FastStrFind

