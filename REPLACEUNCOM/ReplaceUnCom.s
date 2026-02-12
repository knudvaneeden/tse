/*
  Macro           ReplaceUnCom
  Author          Carlo.Hogeveen@xs4all.nl
  Compatibility   TSE Pro v4.0 upwards
  Version         v1.0 - 17 May 2019

  In this case BETA means the macro is "finished" and is somewhat tested.


  Emulate TSE's Replace but only replace in uncommented text.

  It relies on the syntax hiliting colours for comments only being used for
  comments, and on no other colours being used inside comments.


  INSTALLATION

  Just put this file in TSE's "mac" folder, open it in TSE,
  and use the Macro -> Compile manu to compile it.

  Execute the macro with any of these methods:
  - With the Macro -> Execute menu.
  - Add it to the Potpourri menu.
  - Attach it to a key.


  HISTORY

  15 May 2019
    Someone requested this functionality in the mailing lists.

  v0.1 - 16 May 2019
    Basic functionality.

  v0.2 - 16 May 2019
    Optimized the comment colour check with a regular expression.
    Added the three ToEOL attributes as comment attributes.
    Added the check that comment colours must differ from other editing colours.

  v1.0 - 17 May 2019
    No changes, just lifting the beta status.
*/





// Compatibility restriction and mitigations



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



// End of Compatibility restriction and mitigations





// Global variables

string my_macro_name [MAXSTRINGLEN] = ''


// Macro code

integer proc colors_not_equal(integer comment_color_attr,
                              string  comment_color_name,
                              integer other_color_attr  ,
                              string  other_color_name  )
  integer result = TRUE
  if comment_color_attr == other_color_attr
    result = FALSE
    Alarm()
    Warn(my_macro_name, ':', Chr(13), Chr(13),
         'This command does not work if comment colours equal other editing colours.', Chr(13), Chr(13),
         'Currently ', comment_color_name, ' equals ', other_color_name, '.')
  endif
  return(result)
end colors_not_equal

integer proc is_comment_color_unique(integer color_attr, string color_name)
  integer result = FALSE
  if  colors_not_equal(color_attr, color_name, Query(TextAttr           ), 'TextAttr')
  and colors_not_equal(color_attr, color_name, Query(HiliteAttr         ), 'HiliteAttr')
  and colors_not_equal(color_attr, color_name, Query(BlockAttr          ), 'BlockAttr')
  and colors_not_equal(color_attr, color_name, Query(CursorAttr         ), 'CursorAttr')
  and colors_not_equal(color_attr, color_name, Query(CursorInBlockAttr  ), 'CursorInBlockAttr')
  and colors_not_equal(color_attr, color_name, Query(Directive1Attr     ), 'Directive1Attr')
  and colors_not_equal(color_attr, color_name, Query(Directive2Attr     ), 'Directive2Attr')
  and colors_not_equal(color_attr, color_name, Query(Directive3Attr     ), 'Directive3Attr')
  and colors_not_equal(color_attr, color_name, Query(Quote1Attr         ), 'Quote1Attr')
  and colors_not_equal(color_attr, color_name, Query(Quote2Attr         ), 'Quote2Attr')
  and colors_not_equal(color_attr, color_name, Query(Quote3Attr         ), 'Quote3Attr')
  and colors_not_equal(color_attr, color_name, Query(NumberAttr         ), 'NumberAttr')
  and colors_not_equal(color_attr, color_name, Query(IncompleteQuoteAttr), 'IncompleteQuoteAttr')
  and colors_not_equal(color_attr, color_name, Query(Keywords1Attr      ), 'Keywords1Attr')
  and colors_not_equal(color_attr, color_name, Query(Keywords2Attr      ), 'Keywords2Attr')
  and colors_not_equal(color_attr, color_name, Query(Keywords3Attr      ), 'Keywords3Attr')
  and colors_not_equal(color_attr, color_name, Query(Keywords4Attr      ), 'Keywords4Attr')
  and colors_not_equal(color_attr, color_name, Query(Keywords5Attr      ), 'Keywords5Attr')
  and colors_not_equal(color_attr, color_name, Query(Keywords6Attr      ), 'Keywords6Attr')
  and colors_not_equal(color_attr, color_name, Query(Keywords7Attr      ), 'Keywords7Attr')
  and colors_not_equal(color_attr, color_name, Query(Keywords8Attr      ), 'Keywords8Attr')
  and colors_not_equal(color_attr, color_name, Query(Keywords9Attr      ), 'Keywords9Attr')
    result = TRUE
  endif
  return(result)
end is_comment_color_unique

integer proc are_comment_colors_unique()
  integer result = FALSE
  if  is_comment_color_unique(Query(MultiLnDlmt1Attr ), 'MultiLnDlmt1Attr' )
  and is_comment_color_unique(Query(MultiLnDlmt1Attr ), 'MultiLnDlmt1Attr' )
  and is_comment_color_unique(Query(MultiLnDlmt1Attr ), 'MultiLnDlmt1Attr' )
  and is_comment_color_unique(Query(SingleLnDlmt1Attr), 'SingleLnDlmt1Attr')
  and is_comment_color_unique(Query(SingleLnDlmt1Attr), 'SingleLnDlmt1Attr')
  and is_comment_color_unique(Query(SingleLnDlmt1Attr), 'SingleLnDlmt1Attr')
  and is_comment_color_unique(Query(ToEol1Attr       ), 'ToEol1Attr'       )
  and is_comment_color_unique(Query(ToEol2Attr       ), 'ToEol2Attr'       )
  and is_comment_color_unique(Query(ToEol3Attr       ), 'ToEol3Attr'       )
    result = TRUE
  endif
  return(result)
end are_comment_colors_unique

integer proc replace_uncommented()
  integer ask_replace_questions                   = TRUE
  string  comment_colour_regexp              [50] = ''
  integer found_string_length                     = 0
  integer keep_searching                          = TRUE
  string  plus_option                         [1] = ''
  integer replacements                            = 0
  string  replace_options          [MAXSTRINGLEN] = ''
  integer replace_this_one                        = TRUE
  string  replace_with             [MAXSTRINGLEN] = ''
  integer response_key                            = 0
  integer screen_read_length                      = 0
  string  screen_string_attributes [MAXSTRINGLEN] = ''
  string  screen_string_characters [MAXSTRINGLEN] = ''
  integer screen_x                                = 0
  integer screen_y                                = 0
  string  search_for               [MAXSTRINGLEN] = ''
  integer window_x                                = 0
  integer window_y                                = 0
  screen_read_length = screen_read_length // Pacify compiler.
  PushPosition()
  if  are_comment_colors_unique()
  and Ask('Search for:   (but not in comments)',
          search_for,
          _FIND_HISTORY_)
  and Ask('replace_with:   (but not in comments)',
          replace_with,
          _REPLACE_HISTORY_)
  and Ask('[AGIWNX] (All-files Global Ignore-case Words No-prompt reg-eXp):',
          replace_options,
          _REPLACE_OPTIONS_HISTORY_)
    if Pos('l', Lower(replace_options))
      Warn('The L option to locally replace inside a block is not supported.')
    elseif Pos('b', Lower(replace_options))
      Warn('The B option to search backwards is not supported.')
    elseif StrFind('[0-9]', replace_options, 'x')
      Warn('Replacing a supplied number of times is not supported.')
    else
      if Pos('n', Lower(replace_options))
        ask_replace_questions = FALSE
        replace_options       = StrReplace('n', replace_options, '', 'i')
      endif
      replace_options = StrReplace('v', replace_options, '', 'i')
      replace_options = replace_options + '1'
      comment_colour_regexp = Format('[',
                                     '\d', Query(MultiLnDlmt1Attr ):3:'0',
                                     '\d', Query(MultiLnDlmt2Attr ):3:'0',
                                     '\d', Query(MultiLnDlmt3Attr ):3:'0',
                                     '\d', Query(SingleLnDlmt1Attr):3:'0',
                                     '\d', Query(SingleLnDlmt2Attr):3:'0',
                                     '\d', Query(SingleLnDlmt3Attr):3:'0',
                                     ']')
      PushBlock()
      UnMarkBlock()
      while keep_searching
      and   lFind(search_for, replace_options + plus_option)
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
        UpdateDisplay(_ALL_WINDOWS_REFRESH_) // Activate syntax highlighting, we hope.
        screen_read_length = GetStrAttrXY(screen_x, screen_y,
                                          screen_string_characters,
                                          screen_string_attributes,
                                          found_string_length)
        PutAttrXY(screen_x, screen_y, Query(HiliteAttr), found_string_length)
        replace_options = StrReplace('g', replace_options, '', 'i')
        replace_options = StrReplace('+', replace_options, '', '' )
        plus_option     = '+'
        if not StrFind(comment_colour_regexp, screen_string_attributes, 'x')
          replace_this_one = TRUE
          if ask_replace_questions
            Message('L ', CurrLine(),'    Replace (Yes/No/Only/Rest/Quit):')
            response_key = GetKey()
            case response_key
              when <Q>, <q>, <Escape>
                keep_searching   = FALSE
                replace_this_one = FALSE
              when <R>, <r>
                ask_replace_questions = FALSE
              when <O>, <o>
                keep_searching   = FALSE
              when <N>, <n>
                replace_this_one = FALSE
            endcase
          endif
          if replace_this_one
            lReplace(search_for, replace_with, replace_options)
            replacements = replacements + 1
          endif
        endif
      endwhile
      PopBlock()
    endif
  endif
  PopPosition()
  Message(replacements, ' change(s) made.')
  return(replacements)
end replace_uncommented

proc WhenLoaded()
  my_macro_name = SplitPath(CurrMacroFilename(), _NAME_)
end WhenLoaded

proc Main()
  replace_uncommented()
  PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end Main

