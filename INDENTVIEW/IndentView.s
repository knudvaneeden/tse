/*
  Macro           IndentView
  Author          Carlo Hogeveen
  Website         eCarlo.nl/tse
  Compatibility   Windows TSE Pro v4.0 upwards
  Version         v1   25 Aug 2021


  DESCRIPTION

  This tool compresses text into a list of lines with a maximum indentation
  that you control with the Right and Left keys.
  This can be used to navigate recursive lists and gain insight into programs.

  Use 1: Navigate large list of lists of lists ...
    Think of navigating a list that has topics, indented subtopics, more
    indented subsubtopics, etc.
  Use 2: Navigate program source code.
    Top-down it works somewhat like TSE's "Function List" menu, but with the
    added advantage that it can include lines with ever increasing indentation,
    which gives some insight into a program's structure.
    Bottom-up it shows lines with the current line's indentation or less, which
    gives insight to what the current line's place in the program structure is.


  INSTALLATION

  Put this macro file in TSE's "mac" folder and compile it there,
  for example by opening it there in TSE and applying the Macro, Compile menu.

  Start this tool either
    by applying the menu Macro, Execute and entering "IndentView", or
    by adding "IndentView" to the Potpourri menu, or
    by assigning ExecMacro("IndentView") to a key (which is what I did).


  EXAMPLE

  Suppose the current file contains the text:
    Shopping list
      Vegetables
        Spinach
        Kale
      Fruit
        Bananas
        Apples
      Dairy
        Milk
        Yoghurt

    Evil plans
      Teasing
        Pull my sister's braids
        Ring my neighbour's doorbell and run away
      World domination
        Cancel all my enemies

  Then initially this tool will show:
    Shopping list
    Evil plans

  After pressing the Right key this tool will show:
    Shopping list
      Vegetables
      Fruit
      Dairy
    Evil plans
      Teasing
      World domination
  with the cursor still on the same line.

  Pressing the Left key will undo each previous Right key.
  Pressing Enter will go to the selected line in the actual list.


  TODO
    MUST
    SHOULD
    COULD
    - I have the vague idea, that I want lines/paragraphs with a leading bullet
      character (like the "-" in this todo list) to be treated smarter, but no
      clear idea of what that should mean.
    WONT


  HISTORY

  v0.1   BETA   15 Aug 2021
    Initial beta release.
    This release is fully usable, though it misses some features that would
    further increase its usefulness.

  v1   25 Aug 2021
    The tab size is automatically determined.
    The list title shows the maximum indentation of the viewed lines.
    The tool starts at the indentation level of the current line.

*/





// Start of GetTabSize implementation

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


// Start of externally callable int_array procedures:

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



// Start of GetTabSize implementation   (Source: the GetTabSize macro)

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

// End of GetTabSize implementation





// Start of IndentView implementation


// Global constants
#define LIST_ACTION_LEFT  1
#define LIST_ACTION_RIGHT 2

// Global semi-constants   (global variables that are initialized only once)
string MACRO_NAME [MAXSTRINGLEN] = ''

// Global variables
integer indent_criterium = 1
integer list_action      = 0
integer tab_size         = 1


Keydef list_keys
  <CursorLeft>      list_action = LIST_ACTION_LEFT   PushKey(<Enter>)
  <GreyCursorLeft>  list_action = LIST_ACTION_LEFT   PushKey(<Enter>)
  <CursorRight>     list_action = LIST_ACTION_RIGHT  PushKey(<Enter>)
  <GreyCursorRight> list_action = LIST_ACTION_RIGHT  PushKey(<Enter>)
end list_keys

proc list_cleanup()
  UnHook(list_cleanup)
  Disable(list_keys)
end list_cleanup

proc list_startup()
  UnHook(list_startup)
  ListFooter('Use cursor Right/Left to view more/fewer lines')
  Enable(list_keys)
  Hook(_LIST_CLEANUP_, list_cleanup)
end list_startup

proc compressed_text_view()
  integer list_id           = 0
  integer list_line         = 0
  integer org_id            = GetBufferId()
  integer org_line          = CurrLine()
  integer ref_id            = 0
  integer selected_line     = 0
  integer stop              = FALSE
  PushLocation()
  list_id = CreateTempBuffer()
  ref_id  = CreateTempBuffer()
  repeat
    EmptyBuffer(list_id)
    EmptyBuffer(ref_id)
    GotoBufferId(org_id)
    if NumLines()
      BegFile()
      repeat
        if (PosFirstNonWhite() in 1 .. indent_criterium)
          AddLine(GetText(1, MAXSTRINGLEN), list_id)
          AddLine(Str(CurrLine())         , ref_id)
        endif
      until not Down()
      GotoBufferId(ref_id)
      if NumLines()
        while Val(GetText(1, MAXSTRINGLEN)) > org_line
        and   Up()
        endwhile
        org_line  = Val(GetText(1, MAXSTRINGLEN))
        list_line = CurrLine()
      else
        org_line  = 1
        list_line = 1
      endif
      GotoBufferId(list_id)
      GotoLine(list_line)
      ScrollToCenter()
      Hook(_LIST_STARTUP_, list_startup)
      list_action = 0
      if List('Showing indentations <= '
              + Str(indent_criterium),
              LongestLineInBuffer())
        list_line = CurrLine()
        GotoBufferId(ref_id)
        GotoLine(list_line)
        case list_action
          when LIST_ACTION_LEFT
            org_line         = Val(GetText(1, MAXSTRINGLEN))
            indent_criterium = Max(1, indent_criterium - tab_size)
          when LIST_ACTION_RIGHT
            org_line         = Val(GetText(1, MAXSTRINGLEN))
            indent_criterium = indent_criterium + tab_size
          otherwise
            selected_line    = Val(GetText(1, MAXSTRINGLEN))
            stop             = TRUE
        endcase
      else
        stop = TRUE
      endif
    endif
  until stop
  PopLocation()
  if selected_line
    GotoLine(selected_line)
    ScrollToCenter()
  endif
end compressed_text_view

proc Main()
  tab_size = get_tab_size(FALSE)
  while indent_criterium < PosFirstNonWhite() - 1
    indent_criterium = indent_criterium + tab_size
  endwhile
  compressed_text_view()
  PurgeMacro(MACRO_NAME)
end Main

proc WhenLoaded()
  MACRO_NAME = SplitPath(CurrMacroFilename(), _NAME_)
end WhenLoaded

// End of IndentView implementation

