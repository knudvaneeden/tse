/*
   Macro.         NoLines.
   Author.        Carlo.Hogeveen@xs4all.nl.
   Date-written.  5 November 1998.

   Version.       2.
   Date.          26 June 1999.
   Alterations.   NoLines no longer has the side effect of overwriting
                  the TSE clipboard with line numbers.
                  NoLines now requires Global.zip, MacPar3.zip and
                  ClipBor2.zip: the newer versions are mandatory!

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

   Installation.
      Download and install Global.zip, MacPar3.zip and ClipBor2.zip.
      Put NoLines.s in TSE's mac directory,
      compile it from TSE with <escape> <M>acro <C>ompile,
      put NoLines in the menu's Macro AutoloadList,
      and restart TSE.

   Use.
      Default there will be no line numbers.
      You can change the default by changing the initial value
      of the variable "no_lines" a few lines below.

      In run-time you can toggle no_lines by executing the macro.
*/

integer no_lines = TRUE // Set this variable to true or false for the default.
integer lines_removed = FALSE
integer lines_id = 0

proc list_startup()
   integer org_id = GetBufferId()
   integer org_line = CurrLine()
   integer org_column = CurrCol()
   if no_lines
      BegFile()
      if lFind("^File: .*[0-9] occurrences found", "cgix")
         lines_removed = TRUE
         repeat
            InsertText("        ", _INSERT_)
         until not lFind("^File: ", "x+")
         PushBlock()
         ExecMacro("clipbord push")
         MarkColumn(1, 1, NumLines(), 8)
         Cut(_DEFAULT_)
         if lines_id == 0
            lines_id = CreateTempBuffer()
         else
            GotoBufferId(lines_id)
         endif
         EmptyBuffer()
         Paste(_DEFAULT_)
         ExecMacro("clipbord pop")
         UnMarkBlock()
         PopBlock()
         GotoBufferId(org_id)
      endif
      GotoLine(org_line)
      GotoColumn(org_column)
   endif
end

proc list_cleanup()
   integer org_id = GetBufferId()
   integer org_line = CurrLine()
   integer org_column = CurrCol()
   if lines_removed
      lines_removed = FALSE
      if Query(Key) <> <alt e>
         PushBlock()
         ExecMacro("clipbord push")
         GotoBufferId(lines_id)
         MarkColumn(1, 1, NumLines(), 8)
         Copy(_DEFAULT_)
         GotoBufferId(org_id)
         BegFile()
         Paste(_DEFAULT_)
         UnMarkBlock()
         while lFind("^        File: ", "x")
            DelChar(8)
         endwhile
         ExecMacro("clipbord pop")
         PopBlock()
         GotoLine(org_line)
         GotoColumn(org_column)
      endif
   endif
end

proc WhenLoaded()
   Hook(_LIST_STARTUP_, list_startup)
   Hook(_LIST_CLEANUP_, list_cleanup)
end

proc Main()
   no_lines = not no_lines
end

