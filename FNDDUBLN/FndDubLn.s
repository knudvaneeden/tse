/*
   Macro          FndDubLn
   Author         Carlo.Hogeveen@xs4all.nl
   Date           2 apr 2008
   Compatibility  TSE Pro 2.5 upwards
   Version        1.0.1
   Date           6 apr 2008

   Find double lines case- and whitespace-insensitive in an unsorted
   current file, and report them in a "ViewFinds buffer", leaving the
   current file unchanged.

   Here whitespace-insensitive means that any non-empty string of
   consecutive whitespace-characters matches any other such string.

   Here the whitespace characters are space, horizontal tab, and formfeed.

   FndDubLn ignores characters past column 255, empty lines, and lines
   containing only whitespaces.

   History:

   v1.0.0   2 apr 2008
      Initial version.

   v1.0.1   6 apr 2008
      Bug fix: The macro could not handle empty lines, resulting in erroneous
      reports. The macro now ignores empty lines and lines containing only
      whitespaces.
*/

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

proc Main()
   integer org_id          = GetBufferId()
   integer fnd_id          = 0
   integer i               = 0
   integer j               = 0
   integer deferred_up     = FALSE
   string  line      [255] = ""
   string  wildcards  [14] = ".^$|?[]*+@#{}\"
   if LongestLineInBuffer() > 255
      Warn("Warning: FndDubLn ignores characters past column 255.")
   endif
   // Copy the current file to a uniquely named ViewFinds buffer.
   PushBlock()
   MarkLine(1, NumLines())
   Copy()
   repeat
      i = i + 1
   until GetBufferId("*ViewFinds buffer " + Str(i) + "*") == FALSE
   fnd_id = CreateBuffer("*ViewFinds buffer " + Str(i) + "*")
   Paste()
   PopBlock()
   // Remove empty lines and lines containing only whitespaces.
   BegFile()
   while lFind("^[ \d009\d012]@$", "x")
      KillLine()
      Up()
   endwhile
   // Find matching lines.
   BegFile()
   repeat
      // If we couldn't do an "Up()" in a previous loop, do it now.
      if deferred_up
         Up()
         deferred_up = FALSE
      endif
      // Read the current line.
      line = GetText(1, 255)
      // Replace consecutive whitespaces by a single space.
      for i = 1 to Length(line)
         if line[i] in Chr(9), Chr(12), " "
            if line[i] in Chr(9), Chr(12)
               line[i] = " "
            endif
            if line[i - 1] == " "
               line = SubStr(line, 1, i - 1) + SubStr(line, i + 1, 255)
            endif
         endif
      endfor
      // Escape wildcard-characters.
      for i = 1 to Length(line)
         for j = 1 to Length(wildcards)
            if  line[i] == wildcards[j]
            and Length(line) < 255
               line = SubStr(line, 1, i - 1) + "\" + SubStr(line, i, 255)
               i    = i + 1
               j    = Length(wildcards)
            endif
         endfor
      endfor
      // Replace each single space by a regular expression for whitespaces.
      for i = 1 to Length(line)
         if  line[i] == " "
         and Length(line) < 255
            line = SubStr(line, 1, i - 1) + " #" + SubStr(line, i + 1, 255)
         endif
      endfor
      // If there are similar lines below the current line,
      // then delete the similar lines,
      // else delete the current line.
      PushPosition()
      i = 0
      EndLine()
      while NumLines() > 0
      and   CurrLine() <> NumLines()
      and   lFind("^" + line + "$", "ix")
         i = i + 1
         KillLine()
         Up()
         EndLine()
      endwhile
      if i == 0
         KillPosition()
         if NumLines() > 2
            KillLine()
            if CurrLine() > 1
               Up()
            else
               deferred_up = TRUE
            endif
         else
            KillLine(2)
         endif
      else
         PopPosition()
      endif
   until not Down()
   BegFile()
   if NumLines() == 0
      if Query(Beep)
         Alarm()
      endif
      GotoBufferId(org_id)
      AbandonFile(fnd_id)
      Message("Double lines not found.")
   endif
   PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end

