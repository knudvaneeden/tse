/*
   Macro          eVwFinds
   Author         Carlo.Hogeveen@xs4all.nl
   Date           1 oct 2009
   Compatibility  TSE Pro 2.5e upwards
   Version        1.3.9.1 (not-working version)
   Date           13 dec 2009

   This search-macro will show a list of the found lines,
   with additional lines before and after the found lines.

   Installation:
      Copy this source to TSE's "mac" directory.
      Open it in TSE, and menu-select Macro, Compile.
      Close TSE.
      Optionally you can either:
         Add it to the Potpurri menu.
         Attach it to a key.
         Add it to some menu.

   Execution:
      You can allways do: Menu, Macro, Execute, "eVwFinds".
      Or you use one of the used optional installation steps from above.


   History:

   v1.0     1 oct 2009     Initial release.

      Initial version: searches only current file, and there is no <Alt E>
      key to edit the result-list in a file.

   v1.1     2 oct 2009     Now sufficiently meets Why Tea's request.

      Can search across files using the 'a' option, and the result-list
      has an <Alt E> key to put it in an editing buffer, and when there are
      context-lines then result-blocks are separated by a dividing line.

      The macro now meets the request for its creation as stated
      by Why Tea (ytlim1@gmail.com).


   v1.1.1   2 oct 2009     Bug solved.

      There was an infinite loop when searching across files: solved.

      New minor bug found: the macro clashes with the NoLines macro,
      resulting in the front columns of the result not being shown.
      Only people who downloaded and installed the NoLines macro see this bug.
      It remains to be solved.

   v1.2     3 oct 2009     Meets Why Tea's additional requests.

      Automatically picks up marked text or otherwise the word under the
      cursor as the default search string.

         Assumption: we only want to use the marked text if we justed marked
         it, and therefore only if it starts on the current line.

      Shows total number of finds at the top.

         Interpretation: both for all files as for each file.

      Bonus feature:

         The "File:" lines are colored now for Windows versions of TSE.

      Bugs solved:

         When searching across files you couldn't select an occurrence
         outside the current file from the View Finds screen.

         The NoLines macro (only present if you explicitly downloaded and
         installed it) no longer interferes with this macro: It removed not
         only line numbers but also text from the beginning of lines in
         the View Finds list. Now NoLines is disabled during eVwFinds.

   v1.3     4 oct 2009     Hiliting the results added.

      In the 'View Finds' list, the found search-results are hilited.

      Made some minor improvements.

   v1.3.9 (beta) 26 nov 2009   Delimit result-context by regular expressions.

      This version isn't even a real beta: it is a half-built version 1.4.

   v1.3.9.1 (not working) 13 dec 2009 Mixed menu.

      The idea was to create a menu with both fillable fields and normal
      menu lines, but I cannot get it to work correctly. Usually I like
      the challenge of taking a tool past its intended use, but this has
      by now wasted way too much of my time, so I'm dropping it indefinitely.
*/

#ifdef MAXSTRINGLEN
#else
   #define MAXSTRINGLEN 255
#endif

string  search_string   [MAXSTRINGLEN] = ''
string  search_options            [25] = ''
string  lines_before              [10] = ''
string  lines_after               [10] = ''
string  regexp_before   [MAXSTRINGLEN] = ''
string  regexp_after    [MAXSTRINGLEN] = ''
string  file_type       [MAXSTRINGLEN] = ''
string  ini_file_name   [MAXSTRINGLEN] = ''

string  macro_name      [MAXSTRINGLEN] = ''
string  local_search_options      [25] = ''
integer hilite_id                      = 0
integer view_id                        = 0
integer current_line                   = 0
integer old_MenuSelectAttr             = 0
integer stop                           = FALSE
integer tabs_to_menu_field             = 0
string  menu_choice_name[MAXSTRINGLEN] = ''
integer in_menu_fields                 = TRUE

string proc get_ini_file(string ini_file_name)
   // Returns fully qualified ini_file_name or an empty string.
   integer org_id = GetBufferId()
   integer tmp_id = 0
   integer i      = 0
   string result [MAXSTRINGLEN] =
                           SearchPath(ini_file_name, Query(TSEPath), 'mac')
   if result == ''
      tmp_id = CreateTempBuffer()
      if  not SaveAs(LoadDir() + 'mac\' + ini_file_name, _DONT_PROMPT_)
      and not SaveAs(LoadDir() +          ini_file_name, _DONT_PROMPT_)
         for i = 1 to NumTokens(Query(TSEPath), ';')
            if SaveAs(GetToken(Query(TSEPath), ';', i) + '\mac\' + ini_file_name, _DONT_PROMPT_)
            or SaveAs(GetToken(Query(TSEPath), ';', i) + '\'     + ini_file_name, _DONT_PROMPT_)
               i = NumTokens(Query(TSEPath), ';') + 1
            endif
         endfor
      endif
      GotoBufferId(org_id)
      AbandonFile(tmp_id)
      result = SearchPath(ini_file_name, Query(TSEPath), 'mac')
   endif
   return(result)
end get_ini_file

proc foundlist_to_file()
   integer org_id   = GetBufferId()
   integer counter  = 0
   MarkLine(1, NumLines())
   Copy()
   repeat
      counter = counter + 1
      view_id = CreateBuffer("*View Finds buffer " + Str(counter) + "*",
                              _NORMAL_)
   until view_id
   Paste()
   UnMarkBlock()
   GotoBufferId(org_id)
   PushKey(<Escape>)
end

keydef extra_keys
   <alt e> foundlist_to_file()
end

proc list_startup()
   current_line = CurrLine()
   UnHook(list_startup)
   if Enable(extra_keys)
      ListFooter(" {Enter}-Go to line   {Escape}-Cancel   {Alt E}-Edit this list")
   endif
end

string proc join2sides(string left_part, string right_part)
   string result [MAXSTRINGLEN] = ''
   integer max_columns = Query(ScreenCols) - 2
   if max_columns > MAXSTRINGLEN
      max_columns = MAXSTRINGLEN
   endif
   if Length(left_part) + 1 + Length(right_part) > max_columns
      if Length(left_part) + 1 + Length(right_part) > MAXSTRINGLEN
         result = left_part
      else
         result = left_part + ' ' + right_part
      endif
   else
      result = left_part
               + Format('':(max_columns - Length(left_part) - Length(right_part)))
               + right_part
   endif
   return(result)
end

proc copy_tmp_to_lst(integer tmp_id, integer lst_id, string file_name,
                     integer file_value_finds, integer file_line_finds)
   integer org_id = GetBufferId()
   GotoBufferId(tmp_id)
   MarkLine(1, NumLines())
   Cut()
   GotoBufferId(lst_id)
   if NumLines() > 1
      EndFile()
      AddLine()
   else
      // Create an empty line, so Paste() will paste below it.
      InsertText('', _INSERT_)
   endif
   Paste()
   UnMarkBlock()
   BegLine()
   InsertText(join2sides(Format('File: ', file_name),
                         Format(file_value_finds,
                                ' occurrences found on ',
                                file_line_finds, ' lines')),
              _INSERT_)
   GotoBufferId(org_id)
end

proc color_search_strings_in_line()
   integer org_id                    = GetBufferId()
   string  s          [MAXSTRINGLEN] = ''
   string  search_phase          [1] = 'g'
   integer mark_attr                 = Query(HiLiteAttr)
   if CurrLine() == current_line
      mark_attr = Query(HiLiteAttr)
   endif
   GetStrXY(1, VWhereY(), s, Query(ScreenCols))
   GotoBufferId(hilite_id)
   EmptyBuffer()
   InsertText(s, _INSERT_)
   while lFind(search_string, search_phase + local_search_options)
      PutOemStrXY(CurrPos(),
                  VWhereY(),
                  GetFoundText(),
                  mark_attr,
                  _USE_3D_)
      search_phase = '+'
   endwhile
   GotoBufferId(org_id)
end

proc hookdisplay_draw()
   integer line_color = Query(HelpTextAttr)
   if CurrLine() == current_line
      line_color = Query(CursorAttr)
   elseif GetText(1, 6) in 'File: ', '------'
      line_color = Query(HelpItalicsAttr)
   endif
   PutOemStrXY(VWhereX(),
               VWhereY(),
               Format(GetText(CurrPos(),255):-Query(WindowCols)),
               line_color,
               _USE_3D_)
   color_search_strings_in_line()
end

proc after_nonedit_command()
   if GetText(1, 80) == Format('':80:'-')
      if Query(Key) in <CursorUp>, <GreyCursorUp>, <PgUp>, <GreyPgUp>
         Up()
      elseif Query(Key) in <CursorDown>, <GreyCursorDown>, <PgDn>, <GreyPgDn>
         Down()
      endif
   elseif GetText(1, 14) == 'File: Totals: '
      BegFile()
      Down(2)
   elseif GetText(1,  6) == 'File: '
      if CurrLine() == 2
         BegFile()
         Down(2)
      else
         if Query(Key) in <CursorUp>, <GreyCursorUp>, <PgUp>, <GreyPgUp>
            Up()
         elseif Query(Key) in <CursorDown>, <GreyCursorDown>, <PgDn>, <GreyPgDn>
            Down()
         endif
      endif
   endif
   current_line = CurrLine()
end

keydef prompt_keys
   <Enter>     Disable(prompt_keys) PushKey(<Escape>) PushKey(<Enter>)
   <Escape>    Disable(prompt_keys) PushKey(<Escape>) PushKey(<Escape>) if tabs_to_menu_field == 0 stop = TRUE endif
   <tab>       Disable(prompt_keys)
               Message('menu_choice_name=',menu_choice_name,'.')
               if menu_choice_name in 'search_string',
                                      'search_options',
                                      'file_type',
                                      'lines_before',
                                      'lines_after',
                                      'regexp_before'
                  PushKey(<enter>) PushKey(<tab>) PushKey(<enter>)
               elseif menu_choice_name == 'regexp_after'
                  menu_choice_name = 'save_options'
                  Set(MenuSelectAttr, old_MenuSelectAttr)
                  in_menu_fields = FALSE
                  PushKey(<tab>) PushKey(<enter>)
               elseif menu_choice_name == 'save_options'
                  menu_choice_name = 'preferences'
                  PushKey(<tab>)
               elseif menu_choice_name == 'preferences'
                  menu_choice_name = 'help'
                  PushKey(<tab>)
               elseif menu_choice_name == 'help'
                  PushKey(<enter>) PushKey(<tab>)
               else
                  PushKey(<tab>)
               endif
   <shift tab> Disable(prompt_keys) PushKey(<enter>)  PushKey(<shift tab>) PushKey(<enter>)
   <LeftBtn>   Disable(prompt_keys) PushKey(<LeftBtn>)
end

integer proc find_profile_section(string searched_section_name)
   integer result = FALSE
   string found_section_name [MAXSTRINGLEN] = ''
   LoadProfileSectionNames(ini_file_name)
   while not result
   and   GetNextProfileSectionName(found_section_name)
      if Lower(searched_section_name) == Lower(found_section_name)
      and (    Lower(found_section_name)       == 'all'
           or SubStr(found_section_name, 1, 1) == '.')
         result = TRUE
      endif
   endwhile
   return(result)
end

proc list_cleanup()
   tabs_to_menu_field = 2
   PushKey(<Escape>)
   PushKey(<Tab>)
end

proc read_param(var string parameter_value, string parameter_name)
   integer i                                  = 0
   string  section_name        [MAXSTRINGLEN] = ''
   string  old_parameter_value [MAXSTRINGLEN] = parameter_value
   menu_choice_name = parameter_name
   // PushKey(<tab>)
   if parameter_name == 'search_string'
      Read(parameter_value, _FIND_HISTORY_)
   elseif parameter_name == 'search_options'
      Read(parameter_value, GetFreeHistory(macro_name + ':search_options'))
   elseif parameter_name == 'file_type'
      // We maintain an existing history to remember the order of past user
      // choices: therefor new choices go to the top of the history list.
      for i = NumHistoryItems(GetFreeHistory(macro_name + ':file_type')) downto 1
         if not find_profile_section(GetHistoryStr(GetFreeHistory(macro_name + ':file_type'),
                                                   i))
            DelHistoryStr(GetFreeHistory(macro_name + ':file_type'), i)
         endif
      endfor
      LoadProfileSectionNames(ini_file_name)
      while GetNextProfileSectionName(section_name)
         if section_name == 'all'
         or SubStr(section_name, 1, 1) == '.'
            if not FindHistoryStr(section_name, GetFreeHistory(macro_name + ':file_type'))
               AddHistoryStr(section_name, GetFreeHistory(macro_name + ':file_type'))
            endif
         endif
      endwhile
      Hook(_LIST_CLEANUP_, list_cleanup)
      Read(parameter_value, GetFreeHistory(macro_name + ':file_type'))
      UnHook(list_cleanup)
      if parameter_value <> old_parameter_value
         lines_before  = GetProfileStr(parameter_value, 'lines_before' , '', ini_file_name)
         lines_after   = GetProfileStr(parameter_value, 'lines_after'  , '', ini_file_name)
         regexp_before = GetProfileStr(parameter_value, 'regexp_before', '', ini_file_name)
         regexp_after  = GetProfileStr(parameter_value, 'regexp_after' , '', ini_file_name)
      endif
   else
      Read(parameter_value)
   endif
end

string proc get_param(var string parameter_value, string parameter_name)
   // Note: get_param also gets called after leaving a field.
   in_menu_fields = TRUE
   if parameter_value == ''
      if parameter_name == 'search_string'
         parameter_value = GetHistoryStr(_FIND_HISTORY_, 1)
      elseif parameter_name == 'search_options'
         parameter_value = GetHistoryStr(GetFreeHistory(macro_name
                                                        + ':search_options'),
                                         1)
      else
         parameter_value = GetProfileStr(file_type, parameter_name, '',
                                         ini_file_name)
      endif
   endif
   return(parameter_value)
end

proc write_profile_str(string parameter_name, string parameter_value)
   if parameter_value == ''
      RemoveProfileItem(file_type, parameter_name, ini_file_name)
   else
      WriteProfileStr(file_type, parameter_name, parameter_value,
                      ini_file_name)
   endif
end

proc save_result_options_to_filetype()
   string filetype_to [MAXSTRINGLEN] = file_type
   if Ask('Save result options to which filetype?',
          filetype_to)
      if SubStr(filetype_to, 1, 1) <> '.'
         filetype_to = '.' + filetype_to
      endif
      // We remove the old one so the new one is created in the new case.
      RemoveProfileSection(filetype_to, ini_file_name)
      WriteProfileStr(filetype_to, 'lines_before' , lines_before , ini_file_name)
      WriteProfileStr(filetype_to, 'lines_after'  , lines_after  , ini_file_name)
      WriteProfileStr(filetype_to, 'regexp_before', regexp_before, ini_file_name)
      WriteProfileStr(filetype_to, 'regexp_after' , regexp_after , ini_file_name)
      while KeyPressed()
         Alarm()
         Message('Discarding key ', KeyName(GetKey()), '.')
         Delay(99)
      endwhile
   endif
end

proc edit_preferences()
   NoOp()
end

proc show_help()
   NoOp()
end

menu search_menu()
   title = 'Search:'
   '&For              ' [get_param(search_string  ,'search_string'  ):-50], read_param(search_string  , 'search_string'  ),_MF_DONT_CLOSE_,'The string or regular expression you want to search for'

   '&Options [aiwx]   ' [get_param(search_options ,'search_options' ): -5], read_param(search_options , 'search_options' ),_MF_DONT_CLOSE_,'Search options: All files, Ignore case, Whole Word, regular eXpression'
   ''                                                 ,                                                                            ,_MF_SKIP_
   'Result:'                                                 ,                                                                            ,_MF_DIVIDE_
   '&Use options for filetype:      ' [get_param(file_type      ,'file_type'      ):-36], read_param(file_type      , 'file_type'      ),_MF_DONT_CLOSE_,'Select the options of another filetype'
   ''                                                 ,                                                                            ,_MF_SKIP_
   '   Show lines  before result   ' [get_param(lines_before   ,'lines_before'   ): -3], read_param(lines_before   , 'lines_before'   ),_MF_DONT_CLOSE_,'Show this many lines before each search result'
   '   Show lines  after  result   ' [get_param(lines_after    ,'lines_after'    ): -3], read_param(lines_after    , 'lines_after'    ),_MF_DONT_CLOSE_,'Show this many lines after each search result'
   '   Show regexp before result   ' [get_param(regexp_before  ,'regexp_before'  ):-36], read_param(regexp_before  , 'regexp_before'  ),_MF_DONT_CLOSE_,'Show lines Up to this regular expression before each search result'
   '   Show regexp after  result   ' [get_param(regexp_after   ,'regexp_after'   ):-36], read_param(regexp_after   , 'regexp_after'   ),_MF_DONT_CLOSE_,'Show lines Up to this regular expression after each search result'
   ''                                                 ,                                                                            ,_MF_SKIP_
   '&Save options to filetype ...',save_result_options_to_filetype(),_MF_DONT_CLOSE_|_MF_ENABLED_,'Save the above four result options to another filetype extension'
   ''                                                 ,                                                                            ,_MF_DIVIDE_
   '&Preferences ...',edit_preferences(),_MF_CLOSE_BEFORE_,"Configure your preferences for this tool's behaviour"
   '&Help ...'       ,show_help()       ,_MF_CLOSE_BEFORE_,'Help!'
end search_menu

proc prompt_startup()
    Enable(prompt_keys)
    BreakHookChain()
    // Make selected line visible in history lists started from prompts:
    Set(MenuSelectAttr, old_MenuSelectAttr)
end

proc prompt_cleanup()
   Disable(prompt_keys)
   if in_menu_fields
      Set(MenuSelectAttr, Query(MenuTextAttr))
   else
      Set(MenuSelectAttr, old_MenuSelectAttr)
   endif
end

proc WhenLoaded()
   macro_name = SplitPath(CurrMacroFilename(), _NAME_)
end

proc Main()
   integer org_ilba                             = Set(InsertLineBlocksAbove, FALSE)
   integer org_id                               = GetBufferId()
   integer org_line                             = CurrLine()
   integer org_nolines_loaded                   = isMacroLoaded('NoLines')
   integer lst_id                               = CreateTempBuffer()
   integer tmp_id                               = CreateTempBuffer()
   string  search_phase                     [1] = 'g'
   integer line_before                          = 0
   integer line_after                           = 0
   integer curr_line                            = 0
   integer selected_line                        = 0
   integer selected_bufferid                    = 0
   integer max_line_size_size                   = 0
   integer first_find_processed                 = FALSE
   integer keep_searching                       = TRUE
   integer first_found_type                     = 0
   integer first_found_id                       = 0
   integer first_found_line                     = 0
   integer first_found_pos                      = 0
   integer total_file_finds                     = 0
   integer file_value_finds                     = 0
   integer total_value_finds                    = 0
   integer file_line_finds                      = 0
   integer total_line_finds                     = 0
   integer curr_found_id                        = 0
   integer curr_found_line                      = 0
   string  curr_found_file_name  [MAXSTRINGLEN] = ''
   integer prev_found_id                        = 0
   integer prev_found_line                      = 0
   string  prev_found_file_name  [MAXSTRINGLEN] = ''
   integer i                                    = 0
   if org_nolines_loaded
      PurgeMacro('NoLines')
   endif
   hilite_id = CreateTempBuffer()
   GotoBufferId(org_id)
   if isBlockInCurrFile()
      curr_line = CurrLine()
      PushPosition()
      GotoBlockBegin()
      if CurrLine() == curr_line
         search_string = GetMarkedText()
      endif
      PopPosition()
   endif
   if search_string == ''
      search_string = GetWord()
   endif
   Hook(_PROMPT_STARTUP_, prompt_startup)
   Hook(_PROMPT_CLEANUP_, prompt_cleanup)
   old_MenuSelectAttr = Set(MenuSelectAttr, Query(MenuTextAttr))
   stop               = FALSE
   file_type          = iif(CurrExt()=='', '.', CurrExt())
   ini_file_name      = get_ini_file(macro_name + '.ini')
   repeat
      PushKey(<Enter>)
      while tabs_to_menu_field > 0
         PushKey(<Tab>)
         tabs_to_menu_field = tabs_to_menu_field - 1
      endwhile
      search_menu()
   until tabs_to_menu_field == 0
   Set(MenuSelectAttr, old_MenuSelectAttr)
   UnHook(prompt_startup)
   UnHook(prompt_cleanup)
   if  NumLines() > 0
   and not stop
   and not in_menu_fields
      // Begin saving the menu choices.
      AddHistoryStr(search_string, _FIND_HISTORY_)
      AddHistoryStr(search_options, GetFreeHistory(macro_name
                                                   + ':search_options'))
      Write_Profile_Str('lines_before' , lines_before )
      Write_Profile_Str('lines_after'  , lines_after  )
      Write_Profile_Str('regexp_before', regexp_before)
      Write_Profile_Str('regexp_after' , regexp_after )
      // Finished saving the menu choices.
      PushBlock()
      for i = 1 to Length(search_options)
         if not (Lower(search_options[i]) in 'a', 'i', 'w', 'x')
            search_options[i] = SubStr(search_options, 1, i - 1)
                                + SubStr(search_options, i + 1, MAXSTRINGLEN)
         endif
      endfor
      local_search_options = search_options
      repeat
         i = Pos('a', Lower(local_search_options))
         if i
            local_search_options = SubStr(local_search_options, 1, i - 1)
                                   + SubStr(local_search_options, i + 1,
                                            MAXSTRINGLEN)
         endif
      until i == 0
      PushPosition()
      BegFile()
      max_line_size_size = Length(Str(NumLines()))
      while keep_searching
      and   lFind(search_string, search_phase + search_options)
         curr_found_id        = GetBufferId()
         curr_found_line      = CurrLine()
         curr_found_file_name = CurrFilename()
         // I made a design choice here concerning the "a" search option.
         // TSE's search behaviour is to ignore the "a" search option
         // when the current buffer is a hidden or system buffer.
         // This macro's search behaviour is to search
         // the current buffer and all normal buffers.
         if first_found_line == 0
         or (   first_found_type <> _NORMAL_
            and BufferType()     == _NORMAL_)
            first_found_type = BufferType()
            first_found_id   = GetBufferId()
            first_found_line = CurrLine()
            first_found_pos  = CurrPos()
         elseif first_found_id   == GetBufferId()
         and    first_found_line == CurrLine()
         and    first_found_pos  == CurrPos()
            keep_searching = FALSE
         endif
         if keep_searching
            if curr_found_id <> prev_found_id
               if prev_found_id
                  copy_tmp_to_lst(tmp_id, lst_id, prev_found_file_name,
                                  file_value_finds, file_line_finds)
               endif
               max_line_size_size = Length(Str(NumLines()))
               total_file_finds   = total_file_finds  + 1
               file_value_finds   = 0
               file_line_finds    = 0
               prev_found_line    = 0
            endif
            if curr_found_line <> prev_found_line
               file_line_finds  = file_line_finds  + 1
               total_line_finds = total_line_finds + 1
            endif
            file_value_finds  = file_value_finds  + 1
            total_value_finds = total_value_finds + 1
            if curr_found_line <> prev_found_line
               if  curr_found_id == prev_found_id
               and first_find_processed
               and Abs(Val(lines_before)) + Abs(Val(lines_after))
                  AddLine(Format('':80:'-'), tmp_id)
               endif
               line_before = curr_found_line - Abs(Val(lines_before))
               if line_before < 1
                  line_before = 1
               endif
               if regexp_before <> ''
                  PushPosition()
                  if lFind(regexp_before, 'bix')
                     if CurrLine() > line_before
                        line_before = CurrLine()
                     endif
                     PopPosition()
                  else
                     KillPosition()
                  endif
               endif
               line_after = curr_found_line + Abs(Val(lines_after))
               if regexp_after <> ''
                  PushPosition()
                  if lFind(regexp_after, 'ix')
                     if CurrLine() < line_after
                        line_after = CurrLine()
                     endif
                     PopPosition()
                  else
                     KillPosition()
                  endif
               endif
               GotoLine(line_before)
               repeat
                  if  CurrLine() >= line_before
                  and CurrLine() <= line_after
                     curr_line = CurrLine()
                     MarkLine(CurrLine(), CurrLine())
                     Copy()
                     GotoBufferId(tmp_id)
                     Paste()
                     UnMarkBlock()
                     Down()
                     BegLine()
                     InsertText(Format(curr_line:max_line_size_size, ': '),
                                _INSERT_)
                     GotoBufferId(curr_found_id)
                  endif
                  first_find_processed = TRUE
               until CurrLine() >= line_after
                  or not Down()
               GotoLine(curr_found_line)
            endif
            prev_found_id        = curr_found_id
            prev_found_line      = curr_found_line
            prev_found_file_name = curr_found_file_name
         endif
         search_phase = '+'
      endwhile
      if curr_found_id
         copy_tmp_to_lst(tmp_id, lst_id, prev_found_file_name,
                         file_value_finds, file_line_finds)
      endif
      GotoBufferId(lst_id)
      BegFile()
      InsertLine(join2sides('File: Totals:  ',
                            Format(total_value_finds,
                                   ' occurrences found on ',
                                   total_line_finds, ' lines in ',
                                   total_file_finds, ' files')))
      // Align the list's current line near the source's current line.
      while CurrLine()                          < NumLines()
      and   Val(GetToken(GetText(1,255),':',1)) < org_line
         Down()
      endwhile
      ScrollToCenter()
      HookDisplay(hookdisplay_draw,,,)
      Hook(_LIST_STARTUP_, list_startup)
      Hook(_AFTER_NONEDIT_COMMAND_ , after_nonedit_command)
      if  List('View Finds', 255)
      and GetText(1,80) <> Format('':80:'-')
      and GetText(1, 6) <> 'File: '
         UnHookDisplay()
         UnHook(list_startup)
         UnHook(after_nonedit_command)
         Disable(extra_keys)
         KillPosition()
         selected_line = Val(GetToken(GetText(1,255),':',1))
         lFind('^File: ', 'bx')
         if not lFind('[0-9]# occurrences found on [0-9]# lines', 'cgx')
            EndLine()
         endif
         selected_bufferid = GetBufferId(Trim(GetText(7, CurrPos() - 7)))
         if selected_bufferid
            GotoBufferId(selected_bufferid)
            GotoLine(selected_line)
            BegLine()
            ScrollToCenter()
         else
            if Query(Beep)
               Alarm()
            endif
            Warn('Error: selected filename not found. Is it > 255?')
            GotoBufferId(org_id)
         endif
      else
         UnHookDisplay()
         UnHook(list_startup)
         Disable(extra_keys)
         PopPosition()
      endif
      if view_id
         GotoBufferId(view_id)
      endif
      PopBlock()
   endif
   Set(InsertLineBlocksAbove, org_ilba)
   if org_nolines_loaded
      LoadMacro('NoLines')
   endif
   PurgeMacro(macro_name)
end

