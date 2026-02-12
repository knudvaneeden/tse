/**********************************************************************

   MULTI.S

   A multi-buffer search/replace/count extension for
   The SemWare Editor version 1.0.

   Copyright (C) 1993, Reed Esau, All Rights Reserved

   Non-commercial distribution and free use encouraged.  Commercial
   distribution available only through written permission from the
   author.

   No warranties either expressed or implied.  Use entirely
   at your own risk.

   Version 1.0, 04/27/93 10:00 pm   First cut
   Version 1.1, 04/29/93 12:00 pm   Fixed miscellaneous bugs.
                                    Added key assignments at end of file.
                                    Centers found text.

   Please direct all inquiries, bug reports, fixes and suggestions
   to my CompuServe Address: 76177,1501.

   Currently working on:

      Multi-buffer incremental search
      Multi-buffer word search
      Multi-buffer compress search

   Installation Suggestion:

      Replace your existing key mappings in your TSE.KEY file

           <Ctrl f>                mMultiFind(TRUE)
           <Ctrl l>                mMultiRepeatFind()
           <Ctrl r>                mMultiReplace(TRUE)
           <  ?  >                 mMultiCount(TRUE)

      Place the following line in your TSE.S file

           #include ["multi.s"]

      Replace the menu mappings in your TSE.S file

           "&Find..."              ,mMultiFind(TRUE)
           "&Replace..."           ,mMultiReplace(TRUE)
           "&Again"                ,mMultiRepeatfind()
           "Cou&nt..."             ,mMultiCount(TRUE)

      And finally burn the changes into your executable

            sc -bc:\tse\e.exe tse.s

 **********************************************************************/

constant
   mfind_mode_find = 0, mfind_mode_replace = 1, mfind_mode_count = 2
integer
   mfind_hist, mfind_options_history,
   mreplace_hist, mreplace_options_history,
   mfind_repeat_mode
string
   mfind_last_expr[65], mfind_last_repl[65], mfind_last_opts[12]

integer proc mZFind(string expr, string opts, integer end_id,
                     integer end_line, integer end_pos)
   integer
      rvalue = FALSE,
      curr_id = GetBufferId(), curr_line = CurrLine(), curr_pos = CurrPos(),
      opt_b = Pos("b", opts), opt_m = Pos("m", opts),
      past_end = curr_id <> end_id or
         (curr_id == end_id and
               ( (not opt_b and (curr_line < end_line or
                 (curr_line == end_line and curr_pos < end_pos)))
               or (opt_b and (curr_line > end_line or
                 (curr_line == end_line and curr_pos > end_pos)))))
   PushPosition()
   loop
      if lFind(expr, opts)
         curr_line = CurrLine()
         curr_pos = CurrPos()
         if past_end and curr_id == end_id and
               ( (not opt_b and (curr_line > end_line or
                 (curr_line == end_line and curr_pos >= end_pos)))
               or (opt_b and (curr_line < end_line or
                 (curr_line == end_line and curr_pos <= end_pos))) )
         else
            rvalue = TRUE
         endif
         break
      elseif not opt_m
         break
      endif
      if curr_id == end_id and past_end
         break
      endif
      if curr_id == end_id
         past_end = TRUE
      endif
      if opt_b
         PrevFile()
         EndFile()
      else
         NextFile()
         BegFile()
      endif
      curr_id = GetBufferId()
   endloop
   if rvalue
      KillPosition()
   else
      PopPosition()
   endif
   return (rvalue)
end mZFind

integer proc mMultiCount(integer prompt_user)
   string
      expr[65] = '', opts[12] = ''
   integer
      end_id, curr_id, end_line, end_pos,
      count = 0,
      opt_b = FALSE, opt_m = FALSE
   if mfind_hist == 0
      mfind_hist = GetFreeHistory()
      mfind_options_history = GetFreeHistory()
      AddHistoryStr(Query(FindOptions), mfind_options_history)
      prompt_user = TRUE
   endif
   if prompt_user
      if not Ask("String to count occurrences of:", expr, mfind_hist)
         return (FALSE)
      endif
      mfind_last_expr = expr
   else
      expr = mfind_last_expr
   endif
   if Length(expr) == 0
      return (FALSE)
   endif
   if prompt_user
      if not Ask("Options [MBGLIWNX] (Multi Back Local Ignore-case Words reg-eXp):",
         opts, mfind_options_history)
         return (FALSE)
      endif
      mfind_last_opts = opts
   else
      opts = mfind_last_opts
   endif
   if Pos("g", opts)
      Message("'g' is not an available option.")
      return (FALSE)
   endif
   if Pos("m", opts)
      Message("Searching multiple buffers...")
      opt_m = TRUE
   endif
   if Pos("l", opts) and opt_m
      Message("Cannot combine options 'l' and 'm'.")
      return (FALSE)
   endif
   if Pos("b", opts)
      opt_b = TRUE
   endif
   mfind_repeat_mode = mfind_mode_count
   end_id = GetBufferId()
   end_line = CurrLine()
   end_pos = CurrPos()
   PushPosition()
   while (mzFind(expr, opts, end_id, end_line, end_pos))
      if not opt_b
         NextChar()
      endif
      count = count + 1
   endwhile
   Message("Found ", count, " occurrence(s)")
   PopPosition()
   return (TRUE)
end

integer proc mMultiFind(integer prompt_user)
   string expr[65] = '', opts[12] = ''
   integer
      rvalue = FALSE,
      end_id, end_line, end_pos,
      opt_m = FALSE
   if mfind_hist == 0
      mfind_hist = GetFreeHistory()
      mfind_options_history = GetFreeHistory()
      AddHistoryStr(Query(FindOptions), mfind_options_history)
      prompt_user = TRUE
   endif
   if prompt_user
      if not Ask("Search for:", expr, mfind_hist)
         return (FALSE)
      endif
      mfind_last_expr = expr
   else
      expr = mfind_last_expr
   endif
   if Length(expr) == 0
      return (FALSE)
   endif
   if prompt_user
      if not Ask("Search options [MBGLIWX] (Multi Back Global Local Ignore-case Words reg-eXp):",
            opts, mfind_options_history)
         return (FALSE)
      endif
      mfind_last_opts = opts
   else
      opts = mfind_last_opts
   endif
   if Pos("m", opts)
      Message("Searching multiple buffers...")
      opt_m = TRUE
   endif
   if Pos("l", opts) and opt_m
      Message("Cannot combine options 'l' and 'm'.")
      return (FALSE)
   endif
   mfind_repeat_mode = mfind_mode_find
   end_id = GetBufferId()
   end_line = CurrLine()
   end_pos = CurrPos()
   if mzFind(expr, opts, end_id, end_line, end_pos)
      ScrollToRow(Query(WindowRows) / 2)
      HiLiteFoundText()
      rvalue = TRUE
   else
      Message(expr + " not found.")
   endif
   return (rvalue)
end mMultiFind

integer proc mMultiReplace(integer prompt_user)
   string
      expr[65] = '', opts[12] = '', repl[65] = '', immed_opts[12] = ''
   integer
      end_id, end_line, end_pos,
      count = 0, done = FALSE,
      opt_b = FALSE, opt_i = FALSE, opt_m = FALSE, opt_n = FALSE, opt_x = FALSE
   if mfind_hist == 0
      mfind_hist = GetFreeHistory()
      mfind_options_history = GetFreeHistory()
      AddHistoryStr(Query(FindOptions), mfind_options_history)
      prompt_user = TRUE
   endif
   if mreplace_hist == 0
      mreplace_hist = GetFreeHistory()
      mreplace_options_history = GetFreeHistory()
      AddHistoryStr(Query(ReplaceOptions), mreplace_options_history)
      prompt_user = TRUE
   endif
   if prompt_user
      if not Ask("Search for:", expr, mfind_hist)
         return (FALSE)
      endif
      mfind_last_expr = expr
   else
      expr = mfind_last_expr
   endif
   if Length(expr) == 0
      return (FALSE)
   endif
   if prompt_user
      if not Ask("Replace with:", repl, mreplace_hist)
         return (FALSE)
      endif
      mfind_last_repl = repl
   else
      repl = mfind_last_repl
   endif
   if prompt_user
      if not Ask("Options [MBGLIWNX] (Multi Back Global Local Ignore-case Words No-promp reg-eXp):",
            opts, mreplace_options_history)
         return (FALSE)
      endif
      mfind_last_opts = opts
   else
      opts = mfind_last_opts
   endif
   if Pos("m", opts)
      Message("Searching multiple buffers...")
      opt_m = TRUE
   endif
   if Pos("l", opts) and opt_m
      Message("Cannot combine options 'l' and 'm'.")
      return (FALSE)
   endif
   if Pos("b", opts)
      opt_b = TRUE
   endif
   if Pos("i", opts)
      opt_i = TRUE
   endif
   if Pos("n", opts)
      opt_n = TRUE
   endif
   if Pos("x", opts)
      opt_x = TRUE
   endif
   mfind_repeat_mode = mfind_mode_replace
   end_id = GetBufferId()
   end_line = CurrLine()
   end_pos = CurrPos()
   immed_opts = "1" + iif(opt_i, "i", "") + iif(opt_x, "x", "")
   while (mzFind(expr, opts, end_id, end_line, end_pos))
      if opt_n
         lReplace(expr, repl, immed_opts)
         if opt_b
            PrevChar()
         endif
         count = count + 1
      else
         ScrollToRow(Query(WindowRows) / 2)
         HiLiteFoundText()
         Message("Replace (Yes/No/Only/Rest/Quit):")
         done = FALSE
         loop
            case Chr(GetKey() & 0xff)
            when 'y', Chr(13)
               Message("Searching...")
               lReplace(expr, repl, immed_opts)
               if opt_b
                  PrevChar()
               endif
               count = count + 1
               break
            when 'n'
               Message("Searching...")
               if not opt_b
                  NextChar()
               else
                  PrevChar()
               endif
               break
            when 'o'
               lReplace(expr, repl, immed_opts)
               count = count + 1
               done = TRUE
               break
            when 'r'
               Message("Replacing rest...")
               opt_n = TRUE
               break
            when 'q'
               done = TRUE
               break
            when Chr(27)
               done = TRUE
               break
            otherwise
               Alarm()
            endcase
         endloop
         if done
            break
         endif
      endif
   endwhile
   message(count, " change(s) made.")
   return (TRUE)
end mMultiReplace

integer proc mMultiRepeatFind()
   integer rvalue = FALSE
   PushPosition()
   if not Pos("b", mfind_last_opts) and not Pos("g", mfind_last_opts)
      NextChar()
   endif
   if mfind_repeat_mode == mfind_mode_replace
      rvalue = mMultiReplace(FALSE)
   elseif mfind_repeat_mode ==  mfind_mode_count
      rvalue = mMultiCount(FALSE)
   else
      rvalue = mMultiFind(FALSE)
   endif
   if rvalue
      KillPosition()
   else
      PopPosition()
   endif
   return (rvalue)
end mMultiRepeatFind

// key assignments
<Ctrl f>                mMultiFind(TRUE)
<Ctrl l>                mMultiRepeatfind()
<Ctrl r>                mMultiReplace(TRUE)


