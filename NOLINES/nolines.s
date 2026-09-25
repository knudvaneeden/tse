/*
   Macro.         NoLines.
   Author.        Carlo.Hogeveen@xs4all.nl.
   Date-written.  5 November 1998.

   Version.       2.
   Date.          26 June 1999.
   Alterations.   NoLines no longer has the side effect of overwriting
                  the TSE clipboard with line numbers.
                  The original version required Global.zip, MacPar3.zip and
                  ClipBor2.zip.

   Version.       3
   Date.          3 Oct 2004.
   Alterations.   Removed the <ctrlshift v> key to togle no_lines.
                  Now executing the macro toggles n0_lines.

                  Fixed a bug: in TSE 4.0 the search string for "File ..."
                  was changed which made NoLines do nothing.

   Purpose.
      Any Find command using the V option will no longer display line numbers.
      If you edit the generated find list with <alt e>, it will not have line
      numbers either.

   Installation (original instructions).
      Put NoLines.s in TSE's mac directory,
      compile it from TSE with <escape> <M>acro <C>ompile,
      put NoLines in the menu's Macro AutoloadList,
      and restart TSE.

   Use.
      This package starts with line numbers hidden unless
      show_line_numbers=true is set in nolines.ini.

      In run-time you can toggle no_lines by executing the macro.
*/

integer no_lines = TRUE // Default when nolines.ini is missing.
integer lines_removed = FALSE
integer lines_id = 0

// The first eight characters of each Find-list line are saved in a
// temporary buffer. No clipboard macro or clipboard contents are used.
proc list_startup()
   integer org_id = GetBufferId()
   integer org_line = CurrLine()
   integer org_column = CurrCol()
   integer lineI = 1
   integer charI = 0
   string prefixS[9] = ""
   if no_lines
      BegFile()
      if lFind("^File: .*[0-9] occurrences found", "cgix")
         lines_removed = TRUE
         repeat
            InsertText("        ", _INSERT_)
         until not lFind("^File: ", "x+")
         if lines_id == 0
            lines_id = CreateTempBuffer()
         else
            GotoBufferId(lines_id)
         endif
         EmptyBuffer()
         GotoBufferId(org_id)
         while lineI <= NumLines()
            GotoLine(lineI)
            BegLine()
            prefixS = GetText(1, 8)
            AddLine(prefixS, lines_id)
            charI = 1
            while charI <= Length(prefixS)
               DelChar()
               charI = charI + 1
            endwhile
            lineI = lineI + 1
         endwhile
      endif
      GotoLine(org_line)
      GotoColumn(org_column)
   endif
end

proc list_cleanup()
   integer org_id = GetBufferId()
   integer org_line = CurrLine()
   integer org_column = CurrCol()
   integer lineI = 1
   integer charI = 0
   string prefixS[9] = ""
   if lines_removed
      lines_removed = FALSE
      if Query(Key) <> <alt e>
         while lineI <= NumLines()
            GotoBufferId(lines_id)
            GotoLine(lineI)
            prefixS = GetText(1, 8)
            GotoBufferId(org_id)
            GotoLine(lineI)
            BegLine()
            InsertText(prefixS, _INSERT_)
            lineI = lineI + 1
         endwhile
         BegFile()
         while lFind("^        File: ", "x")
            charI = 1
            while charI <= 8
               DelChar()
               charI = charI + 1
            endwhile
         endwhile
         GotoLine(org_line)
         GotoColumn(org_column)
      endif
   endif
end

proc WhenLoaded()
   no_lines = Lower(GetProfileStr("nolines", "show_line_numbers", "false", Query(StartUpPath) + "nolines.ini")) == "false"
   Hook(_LIST_STARTUP_, list_startup)
   Hook(_LIST_CLEANUP_, list_cleanup)
end

proc Main()
   no_lines = not no_lines
   if Lower(GetProfileStr("nolines", "silent", "false", Query(StartUpPath) + "nolines.ini")) <> "true"
      if no_lines
         Warn("NoLines 1.0.0.0.4 (GPT-6): Find-list line numbers are now hidden.")
      else
         Warn("NoLines 1.0.0.0.4 (GPT-6): Find-list line numbers are now shown.")
      endif
   endif
end
