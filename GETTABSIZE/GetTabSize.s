/*
  Macro           GetTabSize
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   Windows TSE Pro v4.0 upwards
  Version         v1   24 Aug 2021

  This is a tool for macro programmers to determine a buffer's best tab size.

  Here tab size means how many SPACE and TAB characters are consistently used
  to increase a next line's indentation.
  See the algorithm's description further on for details on what this means.
  A TAB character is treated as one SPACE character.

  This tool comes with a tool GetTabSize_Test to test and demonstrate its use.


  DISCLAIMER

  For a tiny minority of files no sensible tab size can or will be determined,
  for example for files that do not use fixed tab sizes, for files that use
  different fixed tab sizes in different parts of the file, or for files that
  use TAB characters.

  After testing several algorithms on all text files in my TSE folder and
  visually chacking the results, 97% of files got the same tab size from
  all algoritms, and the final 3% of files got the best acceptable results
  from the currently used algorithm.


  INSTALLATION

  Copy this file to TSE's "mac" folder and compile it there, for example by
  opening it there in TSE and applying the Macro Compile menu.


  USAGE

  You can execute GetTabSize interactively by just executing it as a macro
  without parameters, and the tool will create a report listing the current
  buffer's found and determined tab size properties.

  However, it makes more sense to use GetTabSize from another macro that needs
  to automatically determine a buffer's tab size.

  There are two main ways to do that:

  - One way is to ExecMacro('GetTabSize silently')
               or ExecMacro('GetTabSize silently keeploaded')
    Afterwards Query(MacroCmdLine) returns the tab size as a string.

    GetTabSize is already smart in not unloading itself from memory during a
    program loop and unloading itself afterwards, but you might want to
    explicitly keep it loaded with the "keeploaded" parameter if you
    use GetTabSize from a hook in a permanently loaded macro.

  - Another way is to copy all this macro's lines from "end get_tab_size"
    upwards to your own macro, and to call the get_tab_size(FALSE) procedure
    directly.

    There is a comment above the idle() and Main() procedures to help with
    this.

  Both ways have their pros and cons when it comes to the maintenance and
  distribution of new versions of GetTabSize and its calling macros.


  ALGORITHM

  To determine the current buffer's tab size the tool counts the relative
  increase in indentation between consecutive lines.

  Take this example, using the ^ character to indicate the start of a line:
    ^if a
    ^  if b
    ^    x = 1
    ^  endif
    ^endif
  The 5 lines have absolute indentations 0, 2, 4, 2 and 0.
  The algorith only looks at relative increases, so between line 1 and 2 and
  between line 2 and 3, giving tab sizes 2 and 2.

  The algorithm is even a bit smarter than that.
  Take this example:
    ^if a
    ^  if (   b >= 1
    ^     and b <= 3 )
    ^    x = 1
    ^  endif
    ^endif
  The 5 lines have absolute indentations 0, 2, 5, 4, 2 and 0.
  Between lines 4 and 5 the indentation increases with 3, but because the total
  indentation of line 5 is 5 and because this absolute indentation 5 is not a
  multiple of 3 (the increase in indentation), this line is ignored.
  The algorithm therefore sees an indentation increase of 2 between lines 2
  and 4, and counts that as a possible tab size of 2. Allrighty!

  Of course there are sequences of lines that make the algorithm fail, but
  tests in practice so far show, that the determined tab size for the whole
  buffer is always defendable, even though in a few worst cases that might be
  because there is no one sensible tab size for a particular buffer.
*/



// Start of Integer array implementation

// Do not use the internal int_arrays_... variables and procedures
// directly below.
//
// Instead only call the external int_array_... procedures further on:
//    integer proc int_array_create(string array_name)
//    integer proc int_array_delete(string array_name)
//    integer proc int_array_set(string array_name, integer index, integer value)
//    integer proc int_array_get(string array_name, integer index)

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

// End of internal int_arrays variables and procedures.


// Do use these externally callable int_array procedures:

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
    int_array_warn(Format('Cannot Set value for non-existing array "',
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



// Get tab size implementation

proc get_tab_size_create_report(integer best_tab_size,
                                integer max_tab_size)
  string  curr_file_name [MAXSTRINGLEN] = CurrFilename()
  integer first_log_line                = 0
  integer last_log_line                 = 0
  integer tab_size                      = 0
  NewFile()
  SetUndoOff()
  AddLine('')
  AddLine(curr_file_name)
  AddLine('')
  AddLine(Format('Tab Size':10, 'Occurs':10))
  first_log_line = CurrLine() + 1
  for tab_size = 1 to max_tab_size
    if int_array_get('tab_size_count', tab_size)
      AddLine(Format(tab_size:10, int_array_get('tab_size_count', tab_size):10))
    endif
  endfor
  last_log_line = CurrLine()
  if first_log_line < last_log_line
    PushBlock()
    MarkLine(first_log_line, last_log_line)
    Sort()
    PopBlock()
  endif
  EndLine()
  AddLine('')
  AddLine(Format('Best tab size:'; best_tab_size))
  AddLine('')
  SetUndoOn()
  BegFile()
  UpdateDisplay()
end get_tab_size_create_report

/*
  This method counts each indentation increase as an occurrence of a tab size
  if the new indentation is a multiple of the increase,
  and it also counts it as an occurrence of the same tab size if such an
  indentation is continued on a consecutive line.

*/
integer proc get_tab_size(integer create_report)
  integer best_tab_size        = 1
  integer best_tab_size_count  = 0
  integer indentation          = 0
  integer indentation_increase = 0
  integer max_tab_size         = 0
  integer prev_indentation     = 1
  integer tab_size             = 0
  if NumLines()
    int_array_create('tab_size_count')
    PushLocation()
    BegFile()
    repeat
      indentation = PosFirstNonWhite()
      if indentation
        indentation_increase = indentation - prev_indentation
        if indentation_increase >= 0
          if indentation_increase             // > 0
            if (indentation - 1) mod indentation_increase
              // Invalid tab size: negative dummy value to ignore this line.
              indentation_increase = -1
            else
              tab_size = indentation_increase // New tab size.
            endif
          else
            // Same indentation: positive dummy value to count last tab size.
            indentation_increase = +1
          endif
        else
          tab_size = 0 // Negative increase: ignore line and restart scratch.
        endif
        if  tab_size
        and indentation_increase >= 0
          int_array_set('tab_size_count',
                        tab_size,
                        int_array_get('tab_size_count', tab_size) + 1)
        endif
        prev_indentation = indentation
        if tab_size > max_tab_size
          max_tab_size = tab_size
        endif
      endif
    until not Down()
    PopLocation()
  endif

  for tab_size = 1 to max_tab_size
    if int_array_get('tab_size_count', tab_size) > best_tab_size_count
      best_tab_size_count = int_array_get('tab_size_count', tab_size)
      best_tab_size       = tab_size
    endif
  endfor

  if create_report
    get_tab_size_create_report(best_tab_size, max_tab_size)
  endif

  int_array_delete('tab_size_count')

  return(best_tab_size)
end get_tab_size


// ============================================================================
// *IF* you copy this macro's code into your own macro,
// then copy everything above this comment, and in your own code use
//   <your tab size variable> = get_tab_size(FALSE)
// on the current buffer.
// ============================================================================

integer idle_is_hooked = FALSE

proc idle()
  PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end

proc Main()
  integer i                      = 0
  integer create_report          = TRUE
  integer keep_loaded            = FALSE
  integer tab_size               = 0

  for i = 1 to NumFileTokens(Query(MacroCmdLine))
    case Lower(GetFileToken(Query(MacroCmdLine), i))
      when 'silently'
        create_report = FALSE
      when 'keeploaded'
        keep_loaded   = TRUE
    endcase
  endfor

  tab_size = get_tab_size(create_report)

  if not (keep_loaded or idle_is_hooked)
    Hook(_IDLE_, idle)
    idle_is_hooked = TRUE
  endif

  Set(MacroCmdLine, Str(tab_size))
end Main

