/*
   Macro:   Lines.
   Author:  carlo.hogeveen@xs4all.nl
   Date:    30 March 2001.

   Purpose:
      This macro only loads the first or last N lines of a file,
      or lines N thru M. It might be used for viewing parts of
      very large files files when memory or loading time is scarce.
      Loading the last lines only saves memory.

   Formats:
      e32.exe -eLines                  The macro asks for parameters.
      e32.exe -eLines:N:Filename       Load first N lines  of Filename.
      e32.exe -eLines:-N:Filename      Load last  N lines  of Filename.
      e32.exe -eLines:N-M:Filename     Load lines N thru M of Filename.

      execmacro("Lines")               Or likewise: Escape, Macro, Execute.
      execmacro("Lines N Filename")

      See par.doc for many more ways that you can start and supply
      parameters to a macro that uses macpar3.zip.

   Examples:
      e32 -eLines:5:\autoexec.bat
      e32 -elines:10:"c:\program files\desktop.ini"

   Installation:
      This macro needs global.zip and macpar3.zip from Semware's ftp-site
      to be installed first.
      It can then be copied to TSE's "mac" directory and be compiled there.
*/
#include ["initpar.si"]

integer filehandle = 0
string char    [1] = ""
string chars [255] = ""

string proc format_number(integer unformatted_number)
   integer n = unformatted_number
   string s [255] = ""
   if n <= 0
      s = Str(n)
   else
      repeat
         s = Format(n mod 1000:3:"0", " ") + s
         n = n / 1000
      until n == 0
      s = SubStr(s, 1, Length(s) - 1)
      while Length(s) > 0
      and   s[1] == "0"
         s = SubStr(s, 2, Length(s) - 1)
      endwhile
   endif
   return(s)
end

integer proc read_char()
   // This proc made file-reading 36% faster.
   integer result = TRUE
   integer chars_returned = 0
   if Length(chars) == 0
      chars_returned = fRead(filehandle, chars, 255)
      if chars_returned > 0
         char  = chars [1]
         chars = SubStr(chars, 2, Length(chars) - 1)
      else
         char  = ""
         chars = ""
         result = FALSE
      endif
   else
      char  = chars [1]
      chars = SubStr(chars, 2, Length(chars) - 1)
   endif
   return(result)
end

proc Main()
   integer old_clockticks     = 0
   integer line_from          = 0
   integer line_to            = 0
   integer num_lines          = 0
   integer lines_read         = 1
   integer old_rtw            = Set(RemoveTrailingWhite, OFF)
   string  lines        [255] = poppar()
   string  filename     [255] = poppar()
   string  Prev_Char      [1] = ""
   initpar()
   Message(
"Extract lines from a disc file without loading the entire file in memory")
   if lines == ""
      if Ask(
"Lines to extract, enter N/-N for first/last N lines, N-M for lines N thru M:",
             lines)
         lines = Trim(lines)
      endif
   endif
   if  lines    <> ""
   and filename == ""
      Message("Select the file to extract lines from:")
      if EditFile("-a- *.*", _DONT_LOAD_)
         filename = CurrFilename()
         AbandonFile()
      endif
   endif
   if Pos("-", lines) > 1
      line_from = Val(GetToken(lines, "-", 1))
      line_to   = Val(GetToken(lines, "-", 2))
      num_lines = line_to + 1 - line_from
   else
      line_from = 1
      num_lines = Val(lines)
      if num_lines < 0
         num_lines = num_lines * -1
         line_to   = MAXINT
      else
         line_to   = num_lines
      endif
   endif
   if line_from <= 0
   or line_to   <= 0
   or num_lines <= 0
   or line_from > line_to
   or line_to   < num_lines
   or not CreateBuffer("Lines_" + lines + "_of_" + filename)
      Warn("Error: illegal parameter format.")
   else
      #ifdef editor_version
         SetUndoOff()
      #endif
      filehandle = fOpen(filename)
      if filehandle == -1
         Warn("Error reading file: ", filename)
      else
         /*
            For performance reasons we err on the side of caution
            inside the loop by allowing some extra lines to be loaded.
            There is always at least one extra line at the end.
            We'll repair all this afterward outside the loop.
         */
         old_clockticks = GetClockTicks()
         while read_char()
         and   lines_read <= line_to
            if (   Asc(char)      == 10
               and Asc(prev_char) <> 13)
            or     Asc(char)      == 13
               if lines_read >= line_from
                  AddLine()
                  BegLine()
               endif
               if NumLines() > num_lines + 1
                  BegFile()
                  KillLine()
                  EndFile()
               endif
               if lines_read mod 1000 == 0
                  if  KeyPressed()
                  and GetKey() == <Escape>
                     line_to = 0
                  else
                     Message(format_number(lines_read),
                             " lines read (press Escape to interrupt) ...")
                  endif
               endif
               lines_read = lines_read + 1
            else
               if Asc(char) <> 10
                  if lines_read >= line_from
                     InsertText(char)
                     NextChar()
                  endif
               endif
            endif
            prev_char = char
         endwhile
         fClose(filehandle)
         if lines_read > 10000
            Alarm()
         endif
         UpdateDisplay()
         Message(format_number(lines_read - 1), " lines read",
                 " in ", (GetClockTicks() - old_clockticks) / 18, " seconds")
         /*
            Here we'll repair the extra lines selected.
         */
         while NumLines() > num_lines
            KillLine()
            Up()
         endwhile
      endif
      #ifdef editor_version
         SetUndoOn()
      #endif
   endif
   if NumLines() == 0
      AbandonFile()
   endif
   if SubStr(CurrFilename(),2,7) == "unnamed"
      AbandonEditor()
   endif
   Set(RemoveTrailingWhite, old_rtw)
   FileChanged(FALSE)
   BegFile()
end
