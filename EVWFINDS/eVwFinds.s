/*
   Macro          eVwFinds
   Author         Carlo.Hogeveen@xs4all.nl
   Date           1 oct 2009
   Compatibility  TSE Pro 2.5e upwards
   Version        1.3
   Date           4 oct 2009

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
*/

#ifdef MAXSTRINGLEN
#else
   #define MAXSTRINGLEN 255
#endif

string  search_string   [MAXSTRINGLEN] = ''
string  search_options            [25] = ''
string  local_search_options      [25] = ''
integer hilite_id                      = 0
integer view_id                        = 0
integer current_line                   = 0

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

proc Main()
   integer org_ilba                             = Set(InsertLineBlocksAbove, FALSE)
   integer org_id                               = GetBufferId()
   integer org_line                             = CurrLine()
   integer org_nolines_loaded                   = isMacroLoaded('NoLines')
   integer lst_id                               = CreateTempBuffer()
   integer tmp_id                               = CreateTempBuffer()
   string  search_phase                     [1] = 'g'
   string  before_string         [MAXSTRINGLEN] = ''
   string  after_string          [MAXSTRINGLEN] = ''
   integer before                               = 0
   integer after                                = 0
   integer curr_line                            = 0
   integer selected_line                        = 0
   integer selected_bufferid                    = 0
   integer max_line_size                        = 0
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
   if  Ask("Search for:", search_string, _FIND_HISTORY_)
   and Ask("Options [AIWX] (All-files Ingnore-case Words reg-eXp):", search_options,
           _FINDOPTIONS_HISTORY_)
   and Ask("Lines before:", before_string,
           GetFreeHistory('eVwFinds:lines_before'))
   and Ask("Lines after:" , after_string,
           GetFreeHistory('eVwFinds:lines_after'))
   and NumLines() > 0
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
      before  = Abs(Val(before_string))
      after   = Abs(Val(after_string))
      PushPosition()
      BegFile()
      max_line_size = Length(Str(NumLines()))
      while keep_searching
      and   lFind(search_string, search_phase + search_options)
         curr_found_id        = GetBufferId()
         curr_found_line      = CurrLine()
         curr_found_file_name = CurrFilename()
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
               max_line_size    = Length(Str(NumLines()))
               total_file_finds = total_file_finds  + 1
               file_value_finds = 0
               file_line_finds  = 0
               prev_found_line  = 0
            endif
            if curr_found_line <> prev_found_line
               file_line_finds  = file_line_finds  + 1
               total_line_finds = total_line_finds + 1
            endif
            file_value_finds  = file_value_finds  + 1
            total_value_finds = total_value_finds + 1
            if curr_found_line <> prev_found_line
               prev_found_line = CurrLine()
               if  curr_found_id == prev_found_id
               and first_find_processed
               and before + after
                  AddLine(Format('':80:'-'), tmp_id)
               endif
               if prev_found_line - before > 0
                  GotoLine(prev_found_line - before)
               else
                  GotoLine(1)
               endif
               repeat
                  if  CurrLine() >= curr_found_line - before
                  and CurrLine() <= curr_found_line + after
                     curr_line = CurrLine()
                     MarkLine(CurrLine(), CurrLine())
                     Copy()
                     GotoBufferId(tmp_id)
                     Paste()
                     UnMarkBlock()
                     Down()
                     BegLine()
                     InsertText(Format(curr_line:max_line_size, ': '), _INSERT_)
                     GotoBufferId(curr_found_id)
                  endif
                  first_find_processed = TRUE
               until CurrLine() >= prev_found_line + after
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
   PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end

