/*
   Macro:   CblCase.
   Author:  carlo.hogeveen@xs4all.nl.
   Date:    30 september 2000.

   The macro was specifically written for Cobol 85 (and below) programs.
   The macro might work for Fortran programs too.

   This macro converts the case of letters to lower, UPPER or Capitalize,
   except in comments (if there is a character at position N)
   or inside quotes (either single or double),
   all of this configurable per file extension.

   Quoted strings are assumed not to span lines.
   A quoted string is assumed to be opened and
   closed with the same type of quote, " or '.

   If the column number filled to indicate a comment line is 7,
   then old Cobol (Cobol 85 and below) is assumed, and columns
   before 8 and after 72 are treated as comment as well,
   that is, they are left unchanged.

   Installation:

      Just put this macro in TSE's MAC directory and compile it.

      Execute the macro once to configure it.

      Put this macro in your Macro AutoLoad List and restart the editor,
      if you want it to format files as you open them.
*/

// Don't change the values here, but execute the macro to configure.
string ext [255] = ".cbl"
integer comment_indicator_position = 7
string action [10] = "capitalize"

integer resident = FALSE
string config_filename [255] = ""

proc do_cblcase()
   integer char = 0
   integer quote = 0
   if CurrExt() == ext
      PushPosition()
      PushBlock()
      UnMarkBlock()
      BegFile()
      repeat
         if comment_indicator_position == 0
            char = 0
         else
            char = CurrChar(comment_indicator_position)
         endif
         if char in 32, _AT_EOL_, _BEYOND_EOL_
            quote = 0
            if comment_indicator_position == 7  // Cobol.
               GotoColumn(8)
            else
               BegLine()
            endif
            char = CurrChar()
            while char <> _AT_EOL_
            and   char <> _BEYOND_EOL_
               if comment_indicator_position <> 7 // Cobol.
               or CurrCol() < 73
                  if char in 34, 39
                     if char == quote
                        quote = 0
                     else
                        quote = char
                     endif
                  else
                     if quote == 0
                        case action
                           when "lower"
                              Lower()
                           when "upper"
                              Upper()
                           when "capitalize"
                              if  CurrCol() > 1
                              and CurrChar(CurrCol() - 1) in 65 .. 90, 97 .. 122
                                 Lower()
                              else
                                 Upper()
                              endif
                        endcase
                     endif
                  endif
               endif
               Right()
               char = CurrChar()
            endwhile
         endif
      until not Down()
      PopBlock()
      PopPosition()
   endif
end

proc read_config()
   config_filename = LoadDir() + "mac\cblcase.cfg"
   if EditBuffer(config_filename)
      if lFind("^\" + ext, "gix")
         Right()
         WordRight()
         comment_indicator_position = Val(GetWord())
         WordRight()
         action = GetWord()
      endif
      AbandonFile()
   endif
end

proc on_first_edit()
   read_config()
   do_cblcase()
end

proc WhenLoaded()
   resident = TRUE
   Hook(_ON_FIRST_EDIT_, on_first_edit)
end

proc do_config()
   string answer [4] = "0"
   if Length(CurrExt()) > 1
      ext = Lower(CurrExt())
      comment_indicator_position = 0
      action = "none"
   endif
   read_config()
   if Ask("File extension to configure for (starting with a period):", ext)
      ext = Lower(GetToken(ext, " ", 1))
   else
      ext = ""
   endif
   if ext [1] == "."
      answer = Str(comment_indicator_position)
      repeat
         if not Ask("Column number filled to indicate a comment line:", answer)
            answer = ""
         endif
         comment_indicator_position = Val(answer)
      until comment_indicator_position >= 0
   endif
   if ext [1] == "."
      repeat
         if not Ask("Action (lower/upper/capitalize/deconfigure):", action)
            action = ""
         endif
         action = Lower(action)
      until action in "lower", "upper", "capitalize", "deconfigure"
      if action == "deconfigure"
         if EditBuffer(config_filename)
            if lFind("^\" + ext, "gix")
               KillLine()
               if SaveAs(CurrFilename(), _OVERWRITE_)
                  Message("File extension deconfigured: ", ext)
               else
                  Message("Problem writing: ", config_filename)
               endif
            else
               Message("Cannot deconfigure unconfigured file extension: ", ext)
            endif
         else
            Message("Cannot deconfigure unconfigured file extension: ", ext)
            AbandonFile()
         endif
         Delay(54)
         ext = ""
      endif
   else
      ext = ""
   endif
   if ext [1] == "."
      if EditBuffer(config_filename)
         if lFind("^\" + ext, "gix")
            Right()
            WordRight()
            KillToEol()
            EndLine()
         else
            EndFile()
            AddLine(ext)
            EndLine()
         endif
         InsertText(" " + Str(comment_indicator_position) + " " + action, _INSERT_)
         if SaveAs(config_filename, _OVERWRITE_)
            Message("File extension configured: ", ext)
         else
            Message("Problem writing: ", config_filename)
         endif
         Delay(54)
         AbandonFile()
      else
         Message("Problem with: ", config_filename)
      endif
      Delay(54)
   endif
end

proc Main()
   do_config()
   do_cblcase()
   if not resident
      PurgeMacro("CblCase")
   endif
end

