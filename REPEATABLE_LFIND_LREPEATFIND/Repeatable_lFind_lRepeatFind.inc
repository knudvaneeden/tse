/*
  This include file provides macro programmers with these two functions:
    repeatable_lFind()
    repeatable_lRepeatFind()

  They work just like lFind() and lRepeatFind() but without the infinite loop
  that lRepeatFind() causes if lFind() was done with the 'a' search option.

  See the file Repeatable_lFind_lRepeatFind_Test.s for an example of its usage.
*/

integer repeatable_origin_id                     = 0
integer repeatable_origin_line                   = 0
integer repeatable_origin_pos                    = 0
string  repeatable_search_string  [MAXSTRINGLEN] = ''
string  repeatable_search_options [MAXSTRINGLEN] = ''

integer proc repeatable_lFind(string search_string, string search_options)
  integer result = FALSE
  result = lFind(search_string, search_options)
  if result
    repeatable_origin_id      = GetBufferId()
    repeatable_origin_line    = CurrLine()
    repeatable_origin_pos     = CurrPos()
    repeatable_search_string  = search_string
    repeatable_search_options = StrReplace('g', search_options, '', 'i') + '+'
  else
    repeatable_origin_id      = 0
    repeatable_origin_line    = 0
    repeatable_origin_pos     = 0
    repeatable_search_string  = ''
    repeatable_search_options = ''
  endif
  return(result)
end repeatable_lFind

integer proc repeatable_lRepeatFind()
  integer result = FALSE
  if repeatable_origin_id
    PushLocation()
    result = lFind(repeatable_search_string, repeatable_search_options)
    if result
      if  repeatable_origin_id   == GetBufferId()
      and repeatable_origin_line == CurrLine()
      and repeatable_origin_pos  == CurrPos()
        result = FALSE
        PopLocation()
      else
        KillLocation()
      endif
    else
      KillLocation()
    endif
  endif
  return(result)
end repeatable_lRepeatFind

