/*
   Macro          bFind
   Compatibility  TSE Pro 2.5e upwards
   Author         Carlo.Hogeveen@xs4all.nl
   Date           28 February 2006
   Version        1.02
   Date           7 March 2006

   A boolean/logical Find command, which allows you to combine quoted
   search-strings with the boolean operators AND, OR, NOT and brackets
   into a logical search-expression.

   Istallation:
      Copy this macro source to TSE's "mac" directory.
      Compile the macro either from the command-line or by opening the source
      in TSE and compiling it from the menu.
      Optionally add the macro to the Potpourri menu and/or assign a key
      to 'ExecMacro("bFind")'.
      Execute the macro from the Macro Execute menu or the Potpourri menu
      or press the key you assigned to it.

   The latest beta versions of my macros can be found at:
      http://www.xs4all.nl/~hyphen/tse

   Logical find expressions; explanation by example:
      not " "
      not ' '
      not a a
      not $ $
      not $\d032$
         All these expressions find all lines not containing a space.
      "cat" and "dog"
         Finds all lines containing both "cat" and "dog" in no particular
         order.
      "cat" or "dog"
         Finds all lines containing either "cat" or "dog" or both.
      not ("cat" or "dog")
         Finds all lines not containing either "cat" or "dog" or both.
      not ("cat" and "dog")
         Finds all lines not containing both "cat" and "dog" in no particular
         order.
      (("dog" and "cat") or ("cat" and ("mouse" or "canary"))) and not "eats"
         You get the idea: just nest away as much as you like!
      "cat" and "dog" or "canary"
      "cat" and ("dog" or "canary")
         These two expressions have the same result,
         but do yourself a favour and use the bracketed expression.
      "cat" or "dog" and "canary"
      "cat" or ("dog" and "canary")
         These two expressions have the same result,
         but do yourself a favour and use the bracketed expression.

   This macro is not intended to exist permanently: at some point I intend to
   add its functionality to the eFind macro, but because that might be some
   time away, I offer bFind for the time being.
   Because bFind is just an intermediate macro, it has the following
   limitations:
   -  Search options "a" and "c" do not work.
   -  Search options "g" and "v" are implicit.
   -  The ViewFinds buffer is immediately shown as an editable file.

   Rules for the logical search-expressions:
   -  The logical operators are "and", "or", "not", "(" and ")".
   -  When without brackets, "and" and "or" are processed left to right
      with equal precedence and with boolean short-circuiting.
   -  An empty logical expression is illegal syntax.
   -  Except for the size of the prompt box, there is no limit on the size
      of the logical expression.
   -  There is no limit on the depth of bracket nesting.
   -  Terminology: a logical search-expression is a single search-string or
      combines search-strings with logical operators.
   -  Each search-string is what TSE's standard find-command thinks is a
      search-string, except it must be quoted.
   -  The quoting character can be any non-whitespace character.
   -  The same search-options apply to all search-strings in the logical
      search-expression.

   History:

   v1.00    2 March 2006
   -  Initial version, despite the version number still a prototype.

   v1.01    5 March 2006
   -  Added syntax checking.
   -  Instead of always presenting an editable viewfinds buffer,
      now we get a List first, just like with TSE's standard Find command.
   -  Added awareness of the NoLines macro.

   v1.01    7 March 2006
   -  Solved bug: the "quoting character X not closed" error message
      caused TSE to loop almost infinitely.
   -  Took the opportunity to change this error message to the probably more
      understandable "missing quoting character(s)".
*/

#define SPACE           32
#define HORIZONTAL_TAB   9

// Made these variables global for performance reasons.
integer org_id    = 0
integer search_id = 0
integer stack_id  = 0
integer result_id = 0
integer edit_viewfinds_buffer = FALSE
integer no_lines = TRUE
string search_options [255] = ""

#ifdef WIN32
#else
   integer proc LongestLineInBuffer()
      integer result = 0
      PushPosition()
      BegFile()
      repeat
         if result < CurrLineLen()
            result = CurrLineLen()
         endif
      until not Down()
      PopPosition()
      return(result)
   end
#endif

string proc right_str(string s, integer len)
   // E.g. TSE 4.0 has a buggy RightStr("a", 2),
   // so I just avoid using it at all.
   string result [255] = ""
   if len > 0
      if len >= Length(s)
         result = s
      else
         result = SubStr(s, Length(s) - len + 1, len)
      endif
   endif
   return(result)
end

proc no_op()
   // Because NoOp() confuses the debugger in some TSE versions.
   integer dummy = 0
   dummy = dummy
end

proc mark_error()
   PushBlock()
   MarkLine(CurrLine(), CurrLine())
   UpdateDisplay()
   PopBlock()
end

proc short_circuit_brackets()
   integer bracket_nesting = 1
   PopPosition()
   GotoBufferId(search_id)
   repeat
      if lFind("^(|)$", "x+")
         if GetText(1,1) == "("
            bracket_nesting = bracket_nesting + 1
         else
            bracket_nesting = bracket_nesting - 1
         endif
      else
         bracket_nesting = 0
      endif
   until bracket_nesting == 0
   Up()
   GotoBufferId(stack_id)
end

proc check_this_line()
   integer line_no = 0
   integer process_one_more_stack_element = FALSE
   string line_match [5] = ""
   string token [255] = ""
   GotoBufferId(stack_id)
   BegFile()
   EmptyBuffer()
   GotoBufferId(search_id)
   BegFile()
   repeat
      GotoBufferId(search_id)
      token = GetText(1,5)
      if token == "value"
         token = GetText(7,255)
         GotoBufferId(org_id)
         if lFind(token, search_options)
            GotoBufferId(stack_id)
            EndFile()
            AddLine("true")
         else
            GotoBufferId(stack_id)
            EndFile()
            AddLine("false")
         endif
      else
         GotoBufferId(stack_id)
         EndFile()
         AddLine(token)
      endif
      // Process the stack
      repeat
         process_one_more_stack_element = FALSE
         EndFile()
         if GetText(1,255) in "(", "not"
            no_op()
         elseif GetText(1,255) == ")"
            KillLine()
            repeat
               Up()
            until GetText(1,255) == "("
            KillLine()
            process_one_more_stack_element = TRUE
         elseif GetText(1,255) == "and"
            KillLine()
            Up()
            if GetText(1,255) == "true"
               KillLine()
               Up()
            else
               PushPosition()
               if lFind("(", "b")
                  short_circuit_brackets()
               else
                  KillPosition()
                  line_match = "false"
               endif
            endif
         elseif GetText(1,255) == "or"
            KillLine()
            Up()
            if GetText(1,255) == "false"
               KillLine()
               Up()
            else
               PushPosition()
               if lFind("(", "b")
                  short_circuit_brackets()
               else
                  KillPosition()
                  line_match = "true"
               endif
            endif
         else  // Value "true" or "false".
            if Up()
               if GetText(1,255) == "not"
                  KillLine()
                  if GetText(1,255) == "true"
                     BegLine()
                     KillToEol()
                     InsertText("false")
                  else
                     BegLine()
                     KillToEol()
                     InsertText("true")
                  endif
                  process_one_more_stack_element = TRUE
               endif
            endif
         endif
      until not process_one_more_stack_element
      GotoBufferId(search_id)
      if CurrLine() == NumLines()
         if line_match == ""
            GotoBufferId(stack_id)
            line_match = GetText(1,255)
         endif
      else
         Down()
      endif
   until line_match <> ""
   GotoBufferId(org_id)
   if line_match == "true"
      line_no = CurrLine()
      PushBlock()
      MarkLine(CurrLine(), CurrLine())
      Copy()
      GotoBufferId(result_id)
      Paste()
      Down()
      BegLine()
      InsertText(Format(line_no:6,": "), _INSERT_)
      GotoBufferId(org_id)
      PopBlock()
   endif
end

integer proc tokenize_search_string(integer tmp_id, integer search_id)
   // This proc takes the free formatted search value from the temp buffer
   // and creates a search buffer which contains the search value in the
   // format of exactly one token per line. This boosts performance later
   // on.
   integer org_id = GetBufferId()
   integer left_pos = 0
   integer right_pos = 0
   integer result = TRUE
   string token [255] = ""
   string quote [255] = ""
   // This proc assumes that in the search-condition-buffer the cursor is
   // on the next unprocessed character, which is never past the end of a
   // line.
   GotoBufferId(tmp_id)
   BegFile()
   repeat
      token = ""
      // If on a whitespace character, go to a non-whitespace character.
      while (CurrChar() in SPACE, HORIZONTAL_TAB, _AT_EOL_)
        and NextChar()
         No_Op()
      endwhile
      if Lower(GetText(CurrPos(),3)) in "not", "and"
         token = Lower(GetText(CurrPos(),3))
         Right(3)
      elseif Lower(GetText(CurrPos(),2)) in "or"
         token = Lower(GetText(CurrPos(),2))
         Right(2)
      elseif Lower(GetText(CurrPos(),1)) in "(", ")"
         token = Lower(GetText(CurrPos(),1))
         Right()
      elseif not (CurrChar() in _AT_EOL_, _BEYOND_EOL_)
         // A quote character can be anything but a whitespace or a
         // key-token. A matching closing quote is mandatory.
         quote = GetText(CurrPos(),1)
         left_pos = CurrPos() + 1
         if lFind(quote, "c+")
            right_pos = CurrPos() - 1
            Right()
            token = "value " + GetText(left_pos, right_pos - left_pos + 1)
         else
            mark_error()
            Warn("Logical expression syntax error: missing quoting character(s)")
            result = FALSE
         endif
      endif
      GotoBufferId(search_id)
      AddLine(token)
      GotoBufferId(tmp_id)
   until not result
      or (    CurrLine() == NumLines()
         and (CurrChar() in _AT_EOL_, _BEYOND_EOL_))
   GotoBufferId(search_id)
   while lFind("^$", "gx")
      KillLine()
      Up()
   endwhile
   GotoBufferId(org_id)
   return(result)
end

integer proc syntax_check_logical_expression(integer search_id)
   integer org_id = GetBufferId()
   integer result = TRUE
   integer brackets_open = 0
   string prev_token [255] = ""
   string token [255] = ""
   GotoBufferId(search_id)
   BegFile()
   repeat
      prev_token = token
      token = GetText(1,5)
      if   prev_token == ""
      and (     token in "and", "or", ")")
         mark_error()
         Warn('Syntax error: logical expression starts with: "', token, '"')
         result = FALSE
      elseif (prev_token in "(", "or", "and", "not")
      and    (     token in ")", "or", "and"       )
         mark_error()
         Warn('Logical expression syntax error: "', prev_token, '" followed by "', token, '" ')
         result = FALSE
      elseif (prev_token in ")", "value"       )
      and    (     token in "(", "value", "not")
         mark_error()
         Warn('Logical expression syntax error: "', prev_token, '" followed by "', token, '" ')
         result = FALSE
      endif
      if token == "("
         brackets_open = brackets_open + 1
      elseif token == ")"
         brackets_open = brackets_open - 1
      endif
   until not result
      or not Down()
   if  result
   and brackets_open <> 0
      mark_error()
      Warn('Logical expression syntax error: brackets opened - closed = ', brackets_open)
      result = FALSE
   endif
   GotoBufferId(org_id)
   return(result)
end

proc foundlist_to_file()
   edit_viewfinds_buffer = TRUE
   PushPosition()
   GotoLine(2)
   if lFind("^ @[0-9]#: ", "cgx")
      // The macro NoLines has temporarily removed the line numbers.
      no_lines = FALSE
      PopPosition()
   else
      KillPosition()
   endif
   PushKey(<Enter>)
end

keydef extra_keys
   <alt e> foundlist_to_file()
end

proc extra_keys_starter()
   UnHook(extra_keys_starter)
   if Enable(extra_keys)
      ListFooter(" {Enter}-Go to line   {Escape}-Cancel   {Alt E}-Edit this list")
   endif
end

proc Main()
   integer old_ilba = Set(InsertLineBlocksAbove, OFF)
   integer tmp_id = 0
   integer counter = 1
   integer line_no = 0
   string org_filename [255] = CurrFilename()
   string macro_name   [255] = SplitPath(CurrMacroFilename(), _NAME_)
   string search_value [255] = ""
   org_id = GetBufferId()
   PushPosition()
   if Ask("Search for:", search_value,
           GetFreeHistory(macro_name + ":search_value"))
      if Trim(search_value) == ""
         Warn("Error: logical search expression may not be empty")
      else
         tmp_id = CreateTempBuffer()
         InsertText(search_value)
         search_id = CreateTempBuffer()
         if  tokenize_search_string(tmp_id, search_id)
         and syntax_check_logical_expression(search_id)
            if Ask("Search options:", search_options,
                    GetFreeHistory(macro_name + ":search_options"))
               if Pos("a", Lower(search_options)) <> 0
               or Pos("c", Lower(search_options)) <> 0
                  Warn('Options "a" and "c" do not work for logical finds')
               else
                  search_options = search_options + "c"
                  if Pos("g", Lower(search_options)) == 0
                     search_options = search_options + "g"
                  endif
                  stack_id  = CreateTempBuffer()
                  result_id = CreateTempBuffer()
                  GotoBufferId(org_id)
                  BegFile()
                  repeat
                     check_this_line()
                  until not Down()
               endif
            else
               Warn("No search")
            endif
         endif
      endif
   else
      Warn("No search")
   endif
   Set(InsertLineBlocksAbove, old_ilba)
   if result_id
      GotoBufferId(result_id)
      BufferType(_NORMAL_)
      while GetBufferId("*ViewFinds buffer " + Str(counter) + "*")
         counter = counter + 1
      endwhile
      ChangeCurrFilename("*ViewFinds buffer " + Str(counter) + "*",
                         _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
      edit_viewfinds_buffer = FALSE
      BegFile()
      InsertLine(Format("File: ",
                        right_str(org_filename,
                                  80 - 6 - 1 - Length(Str(NumLines())) - 18)
                        :(80 - 6 - 1 - Length(Str(NumLines())) - 18) * -1,
                        " ",
                        NumLines(),
                        " occurrences found"))
      Hook(_LIST_STARTUP_, extra_keys_starter)
      if lList(CurrFilename(), LongestLineInBuffer(), NumLines() + 2,
               _ENABLE_SEARCH_|_ENABLE_HSCROLL_)
         Disable(extra_keys)
         if edit_viewfinds_buffer
            if no_lines
               // The macro NoLines permanently removes ViewFind line numbers
               // for the regular Find command, but only temporarily for this
               // bFind macro, so if the NoLines macro is active, then we
               // have to remove line numbers ourselves.
               PushPosition()
               PushBlock()
               BegFile()
               while lFind("^ @[0-9]#: ", "x")
                  MarkFoundText()
                  KillBlock()
               endwhile
               PopBlock()
               BegFile()
               PopPosition()
            endif
         else
            line_no = Val(GetText(1, Pos(":", GetText(1,55))))
            PopPosition()
            AbandonFile(result_id)
            if line_no > 0
               GotoLine(line_no)
            endif
         endif
      else
         Disable(extra_keys)
         PopPosition()
         AbandonFile(result_id)
      endif
   else
      PopPosition()
      AbandonFile(result_id)
   endif
   AbandonFile(tmp_id)
   AbandonFile(search_id)
   AbandonFile(stack_id)
   PurgeMacro(macro_name)
end

