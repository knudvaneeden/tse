/*
  Macro         IndentResize
  Author        Carlo.Hogeveen@xs4all.nl
  Compatibility TSE Pro v4.0 upwards
  Version       2.1   -   13 Nov 2019

  This is a general purpose macro to change a file's indentation.

  There are two kinds of indentation: Tabbed and Aligned.

  For example, when changing the tab size from 3 to 2, which applies to first
  three lines, then the fourth line's indentation will shift as much as the 3rd
  line's indentation because it is aligned with it.
  So the indentation of
    ^   if life == 'hard'
    ^      cry(MAXINT)
    ^      Warn('I want',
    ^           'my mommy!')
  will be nicely resized to
    ^  if life == 'hard'
    ^    cry(MAXINT)
    ^    Warn('I want',
    ^         'my mommy!')

  Version 1 of the macro only understood tabbed indentation.
  Version 2 adds understanding alignment as it occurs in program source code.
  Version 3 might one day add alignment for text with a multi-line bullet point.

  The macro tries to determine what the old tab size is and proposes it to you.
  You decide what actual old tab size to assume, and what new tab size to
  convert it to.
  The macro figures out how to keep non-tabbed and multi-tabbed items aligned
  with their preceding lines.

  Automatically determining alignment works most of the time, especially for
  program source code.
  Aligning bulleted text where a bullet item has more than one line will fail:
  The plan is to solve this in version 3.
  Some rarely occurring alignments are not recognized and will remain as such:
  Adapting to their exceptions would require language-specific knowledge, which
  would go against the general purpose intent of this macro.

  Only indentation before the first character is changed;
  indentation between characters is left alone.

  The macro does not work for files with tab characters:
  Use another solution to first remove those pesky things.



  INSTALLATION

  Note that from version 1 to version 2 the macro name was changed
  from "IndentResizer" to "IndentResize" so it fits the new(*) Potpourri menu.
  Also the extension was changed from .s to .si: The reason is irrelevant for
  its installation and use: See INNER WORKINGS if you are a macro programmer.

  Just copy this file to TSE's "mac" folder.

  Compile it, for instance by opening the file with TSE and using
  the Macro Compile menu.

  Open the file you want the indentation resized of, and execute this macro.
  Or you can add it to the new(*) Potpourri menu

  (*) In May 2019 I created a new version of the Potpourri which accepts macro
      names of up to 12 characters instead of 8.
      This new Potpourri menu will be distributed with TSE versions released
      after May 2019, and can be downloaded from my website.



  TODO
    MUST
      None.
    SHOULD
      Recognizing bullet patterns. The problem with bulleted lines where
      bullets are short and there is a bullet which has multiple lines,
      then the text after the first line can start at the next tab position,
      which erroneously causes the next line to be tabbed instead of aligned.
      For example, when changing the tab size from 3 to 2, these lines
        ^   These are my favourite colours:
        ^   -  Green
        ^      The colour of spring!
        ^   -  Blue
        ^      The colour of the sky!
      will currently be reindented as
        ^  These are my favourite colours:
        ^  -  Green
        ^    The colour of spring!
        ^  -  Blue
        ^    The colour of the sky!
      .
    COULD
      None.
    WONT
      Aligning a line that should be, but starts at the next tab position.
      That would require language specifics, which are out of scope for this
      general purpose macro. Luckily these are very rare.
      For example, when changing the tab size from 3 to 2, these lines
        ^   until age >= 18
        ^      or age <= 74
      will remain to be reindented as
        ^  until age >= 18
        ^    or age <=74
      .



  HISTORY
  v1.0 - 16 Apr 2019
    Initial release: Only understood tabbed indentation.
  v2.0 - 4 Jun 2019
  - Some minor bug fixes.
  - Changed the name from "IndentResizer" to "IndentResize".
  - Changed the extension of the source file from ".s" to ".si" .
  - Added adapting for alignment as occuring in program source code.
  v2.1 - 13 Nov 2019
  - No execution functionality was changed.
    The installation functionality was changed:
    This file's extension was changed back from ".si" to the standard ".s".
    Please delete the old "IndentResize.si" file to avoid (automatic)
    recompile errors.
  - The implementation for arrays was completely rewritten in order to be more
    generically applicable, which also allowed the improvement of the the file
    extension.
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



// End of compatibility restriction and mitigations.





// Integer array implementation

/*
  Only use the following functions to manipulate integer arrays:
    integer proc int_array_create(string array_name)
    integer proc int_array_delete(string array_name)
    integer proc int_array_set(string array_name, integer index, integer value)
    integer proc int_array_get(string array_name, integer index)

    int_array_get() returns the value at the index; all other functions return
    true or false if the function succeeded or there was an error.

  Notes:
    An array name only needs to be unique within the macro it is used in.
    You can create as many arrays as TSE's memory will allow,
    altough creating an array will use up a bufffer id.
    An array always has 2 * MAXINT elements, indexed from MININT to MAXINT,
    and initially all elements have value zero.
    Deleting an array will delete all its elements and free up its memory.
    Sparse arrays will use little memory. Memory usage is mainly determined
    by the amount of elements with a non-zero value. As this implies, setting
    an element to zero can free up memory too.
    The array intentionally maintains no usage edges; the calling macro can do
    that more efficiently based on the specific usage of the array.
*/


// Do not call or use these internal int_arrays variables and functions:

integer int_arrays_id                        = 0
string  int_arrays_macro_name [MAXSTRINGLEN] = ''
string  int_arrays_prefix     [MAXSTRINGLEN] = ''

proc int_arrays_context()
  integer org_id = 0
  if int_arrays_id == 0
    int_arrays_macro_name = SplitPath(CurrMacroFilename(), _NAME_)
    int_arrays_prefix     = int_arrays_macro_name + ':IntArray:'
    org_id                = GetBufferId()
    int_arrays_id         = CreateTempBuffer()
    GotoBufferId(org_id)
  endif
end int_arrays_context

proc int_array_warn(string s)
  if (Query(MsgLevel) in _ALL_MESSAGES_, _WARNINGS_ONLY_)
    if Query(Beep)
      Alarm()
    endif
    Warn(s)
  endif
end int_array_warn

// End of internal int_arrays variables and functions.


// Use these externally callable int_array functions:

integer proc int_array_create(string array_name)
  integer array_id = 0
  integer ok       = FALSE
  integer org_id   = GetBufferId()
  int_arrays_context()
  array_id = GetBufferInt(int_arrays_prefix + array_name, int_arrays_id)
  if array_id
    if (Query(MsgLevel) in _ALL_MESSAGES_, _WARNINGS_ONLY_)
      int_array_warn(Format('Cannot create existing array "', array_name,
                            '" in macro "', int_arrays_macro_name, '".'))
    endif
  else
    array_id = CreateTempBuffer()
    if array_id
      if SetBufferInt(int_arrays_prefix + array_name, array_id, int_arrays_id)
        ok = TRUE
      else
        int_array_warn(Format('Cannot create new buffer int for array "',
                              array_name, '" in macro "',
                              int_arrays_macro_name, '".'))
      endif
    else
      int_array_warn(Format('Cannot create new buffer id for array "',
                            array_name, '" in macro "', int_arrays_macro_name,
                            '".'))
    endif
    GotoBufferId(org_id)
  endif
  return(ok)
end int_array_create

integer proc int_array_delete(string array_name)
  integer array_id = 0
  integer ok       = FALSE
  int_arrays_context()
  array_id = GetBufferInt(int_arrays_prefix + array_name, int_arrays_id)
  if array_id
    ok = TRUE
    if not AbandonFile(array_id)
      int_array_warn(Format('Error deleting buffer "', array_id,
                            '" of array "', array_name,
                            '" in macro "', int_arrays_macro_name, '".'))
      ok = FALSE
    endif
    if not DelBufferVar(int_arrays_prefix + array_name, int_arrays_id)
      int_array_warn(Format('Error deleting buffer variable for array "',
                            array_name, '" in macro "', int_arrays_macro_name,
                            '".'))
      ok = FALSE
    endif
  else
    int_array_warn(Format('Cannot delete non-existing array "', array_name,
                          '" in macro "', int_arrays_macro_name, '".'))
  endif
  return(ok)
end int_array_delete

integer proc int_array_set(string array_name, integer index, integer value)
  integer array_id = 0
  integer ok       = FALSE
  int_arrays_context()
  array_id = GetBufferInt(int_arrays_prefix + array_name, int_arrays_id)
  if array_id
    if SetBufferInt(int_arrays_prefix + array_name + Str(index), value, array_id)
      ok = TRUE
    else
      int_array_warn(Format('Error setting value "', value, '" at index "',
                            index, '" for array "', array_name, '" in macro "',
                            int_arrays_macro_name, '".'))
    endif
  else
    int_array_warn(Format('Cannot set value for non-existing array "',
                          array_name, '" in macro "', int_arrays_macro_name,
                          '".'))
  endif
  return(ok)
end int_array_set

integer proc int_array_get(string array_name, integer index)
  integer array_id = 0
  integer value    = 0
  int_arrays_context()
  array_id = GetBufferInt(int_arrays_prefix + array_name, int_arrays_id)
  if array_id
    value = GetBufferInt(int_arrays_prefix + array_name + Str(index), array_id)
  endif
  return(value)
end int_array_get

// End of integer array implementation


// Global constants

#define DEBUG FALSE

string TAB_CHARACTER [1] = Chr(9h)


// Local code

string proc determine_old_tab_size()
  integer i                 = 0
  integer indent            = 0
  integer indented_lines    = 0
  integer max_indent_count  = 0
  integer top_array_element = 0
  string  result        [5] = '0'

  int_array_create('indent_count')

  BegFile()
  repeat
    if PosFirstNonWhite() > 1
      indented_lines = indented_lines + 1
      indent         = PosFirstNonWhite() - 1
      int_array_set('indent_count',
                    indent,
                    int_array_get('indent_count', indent) + 1)
      if indent > top_array_element
        top_array_element = indent
      endif
    endif
  until not Down()

  for indent = 1 to top_array_element / 2
    // Only if the indent also occurs by itself.
    if int_array_get('indent_count', indent)
      for i = 2 to top_array_element / indent
        // If an indent and a multiple of an indent occur
        if int_array_get('indent_count', indent * i)
          // add the count of the multiple to the count of the indent.
          int_array_set('indent_count',
                        indent,
                          int_array_get('indent_count', indent    )
                        + int_array_get('indent_count', indent * i))
        endif
      endfor
    endif
  endfor

  // Determine the indent that (adjusted) occurs most.
  indent = 0
  for i = 1 to top_array_element
    if int_array_get('indent_count', i) >= max_indent_count
      max_indent_count = int_array_get('indent_count', i)
      indent           = i
    endif
  endfor

  int_array_delete('indent_count')

  result = Str(indent)
  return(result)
end determine_old_tab_size

proc resize_indentation(integer old_tab_size, integer new_tab_size)
  integer ancestor_indent        = 0
  integer curr_indent            = 0
  integer curr_line              = 0
  integer indent_id              = 0
  string  indent_type       [12] = ''
  integer indent_shift           = 0
  integer org_id                 = GetBufferId()
  integer prev_indent            = 0
  integer prev_line              = 0
  integer program_error_reported = FALSE
  // This proc uses a temporary buffer identified by ident_id.
  // Normally a line in the buffer will have format "LLLLLLLLLLSSSSSSSSSS".
  // When DEBUG is TRUE it as format "LLLLLLLLLLSSSSSSSSSS:<copy of line>".
  // LLLLLLLLLL  is 10 positions for the left-justified indent_type.
  // SSSSSSSSSSS is 11 positions for the left-justified signed indent_shift.
  // The ":" is a fixed visual aid at column 22.
  // <copy of line> is the original line.
  //
  // Aside:
  //   Here two arrays instead of a buffer would theoretically be more
  //   efficient and maintainable, but TSE's limited array size prohibits it
  //   for an array that needs as many elements as there are lines in a file.
  //
  // In the first pass we analyse and store each line's indentation type:
  //    e           Empty line, needs to be ignored by following lines.
  //    n           Non-empty line with no indentation.
  //    t           Tabbed line.
  //    <integer>   Aligned line, namely aligned with line <integer>.
  //    ?           Unknown indentation, not to be re-indented.
  #if DEBUG
    // Provide copy of original file with each line prefixed with analytics,
    // namely its indent type and its new indentation.
    indent_id = NewFile()
  #else
    // Temporary system file for just the analytics.
    indent_id = CreateTempBuffer()
  #endif
  GotoBufferId(org_id)
  BegFile()
  // Treat the first line as a special case to initialize the first pass.
  curr_indent = Max(PosFirstNonWhite() - 1, 0)
  if     curr_indent == 0
    indent_type = iif(PosFirstNonWhite(), 'n', 'e')
  elseif curr_indent mod old_tab_size == 0
    indent_type = 't'
  else
    indent_type = '?'
  endif
  prev_indent = curr_indent
  prev_line   = CurrLine()
  #if DEBUG
    AddLine(Format(indent_type:-22, ':', GetText(1, CurrLineLen())), indent_id)
  #else
    AddLine(indent_type, indent_id)
  #endif
  Down()
  repeat
    curr_indent = Max(PosFirstNonWhite() - 1, 0)
    curr_line   = CurrLine()
    indent_type = ''
    if     curr_indent == 0
      indent_type = iif(PosFirstNonWhite(), 'n', 'e')
    elseif curr_indent == prev_indent
      indent_type = Str(prev_line)
    elseif curr_indent <  prev_indent
      // Find the first previous line with an equal or smaller indent.
      Up()
      while Up()
      and   indent_type == ''
        ancestor_indent = Max(PosFirstNonWhite() - 1, 0)
        if not PosFirstNonWhite() // Is line empty?
          NoOp()                  // Skip empty lines.
        elseif ancestor_indent == curr_indent
          indent_type = Str(CurrLine())
        elseif ancestor_indent <  curr_indent
          if curr_indent mod old_tab_size == 0
            indent_type = 't'
          else
            indent_type = Str(CurrLine())
          endif
        endif
      endwhile
      GotoLine(curr_line)
      if indent_type == ''
        if curr_indent mod old_tab_size == 0
          indent_type = 't'
        else
          indent_type = '?'
        endif
      endif
    else // curr_indent > prev_indent
      if curr_indent == prev_indent + old_tab_size
        indent_type = 't'
      else
        if prev_indent == 0
          if curr_indent mod old_tab_size == 0
            indent_type = 't'
          else
            indent_type = '?'
          endif
        else
          indent_type = Str(prev_line)
        endif
      endif
    endif
    #if DEBUG
      AddLine(Format(indent_type:-21, ':', GetText(1, CurrLineLen())), indent_id)
    #else
      AddLine(indent_type, indent_id)
    #endif
    if indent_type <> 'e'
      prev_line   = curr_line
      prev_indent = curr_indent
    endif
  until not Down()

  // In the second pass we re-indent each line based on its indentation type,
  // while storing how much it shifted for the use of following lines.
  GotoBufferId(org_id)
  BegFile()
  repeat
    curr_line   = CurrLine()
    curr_indent = Max(PosFirstNonWhite() - 1, 0)
    GotoBufferId(indent_id)
    GotoLine(curr_line)
    indent_type = RTrim(GetText(1, 11))
    if     indent_type == 't'
      indent_shift = ((curr_indent / old_tab_size) * new_tab_size) - curr_indent
    elseif isDigit(indent_type)
      // StrFind('^[ \d009]@\+|\-[0-9]#[ \d009]@$', indent_type, 'x') // Is integer?
      GotoLine(Val(indent_type))
      indent_shift = Val(GetText(12, 11))
      GotoLine(curr_line)
    else
      indent_shift = 0
    endif
    GotoPos(12)
    InsertText(Str(indent_shift), _OVERWRITE_)
    GotoBufferId(org_id)
    BegLine()
    if indent_shift < 0
      if Trim(GetText(1, Abs(indent_shift))) == '' // Should always be TRUE.
        DelChar(Abs(indent_shift))
      else
        if not program_error_reported
          Warn('IndentResize program error at line ', CurrLine(),
               '. Indent shift to the left too big.')
          program_error_reported  = TRUE
        endif
      endif
    else
      InsertText(Format('':indent_shift), _INSERT_)
    endif
  until not Down()
  GotoBufferId(org_id)
  #if DEBUG
  #else
    AbandonFile(indent_id)
  #endif
end resize_indentation

proc Main()
  integer stop_step        = FALSE
  integer stop_all         = FALSE
  string  new_tab_size [5] = ''
  string  old_tab_size [5] = ''
  PushPosition()
  if NumLines() < 2
    NoOp()
  elseif lFind(TAB_CHARACTER, 'g')
    Warn('This macro does not work for files with TAB characters.')
  else
    old_tab_size = determine_old_tab_size()
    while not stop_step and not stop_all
      if Ask('Change tab size from old value:', old_tab_size)
        if isDigit(old_tab_size)
        and    Val(old_tab_size) > 0
          stop_step = TRUE
        else
          Alarm()
          Message('ERROR: Illegal value.')
        endif
      else
        Message('You escaped!')
        stop_all = TRUE
      endif
    endwhile

    stop_step = FALSE
    new_tab_size = old_tab_size
    while not stop_step and not stop_all
      if Ask(Format('Change tab size from ', old_tab_size, ' to:'),
             new_tab_size)
        if isDigit(new_tab_size)
        and    Val(new_tab_size) > 0
          stop_step = TRUE
        else
          Alarm()
          Message('ERROR: Illegal value.')
        endif
      else
        Message('You escaped!')
        stop_all = TRUE
      endif
    endwhile

    if not stop_all
      resize_indentation(Val(old_tab_size), Val(new_tab_size))
    endif
  endif
  PopPosition()
  PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end Main

