/*
   Macro.   ccRepl.
   Author.  Carlo Hogeveen (hyphen@xs4all.nl).
   Date.    30 June 1999.

   Purpose. Executing a case copying replace action.

   Example. Letting this macro replace "road" by "path" with options "ginw"
             - will replace "road" by "path",
             - will replace "Road" by "Path",
             - will replace "ROAD" by "PATH",
             - will replace "rOaD" by "pAtH".

   Install. Put it in TSE's "mac" directory, compile it,
            and from then on just execute it.

            This is an appropriate macro to add to the PotPourri menu.

   Use.     It works just like the normal Replace command,
            and supports all replace-options except regular expressions.

            It supports replacing strings of a different length too.
            When replacing a shorter string by a longer string,
            the last letter of the shorter string decides the case
            of the rest of the letters of the longer string.
*/

#define find_history    168
#define replace_history 169
#define option_history  161

proc case_copying_replace()
   integer i, j
   integer times    = MAXINT
   integer skip_one = FALSE
   integer changes  = 0
   string character [1] = ""
   string old     [255] = ""
   string new     [255] = ""
   string opt     [255] = ""
   string old2    [255] = ""
   string new2    [255] = ""
   if  Ask("Search for:",                            old, find_history)
   and Ask("Replace with:",                          new, replace_history)
   and Ask("Search & replace options [abcgilnw^$#]", opt, option_history)
      opt = Lower(opt)
      if Length(old) == 0
         Message("Length of search string is zero")
      elseif Pos("v", opt)
      or     Pos("x", opt)
         Message("Options V and X are not allowed with this kind of replace")
      else
         PushPosition()
         for i = 1 to Length(opt)
            if opt[i] in "0" .. "9"
               for j = Length(opt) downto i
                  if opt[j] in "0" .. "9"
                     times = Val(SubStr(opt, i, j - i + 1))
                     j = i // Stop.
                  endif
               endfor
               i = Length(opt) // Stop.
            endif
         endfor
         while times > 0
         and   lFind(old, opt)
            skip_one = FALSE
            if Pos("n", opt) == 0
               if Query(CenterFinds)
                  ScrollToCenter()
               endif
               HiLiteFoundText()
               Message("L ", CurrLine(), "   Replace (Yes/No/Only/Rest/Quit):")
               repeat
                  character = Lower(Chr(GetKey()))
                  if Query(Key) == <Escape>
                     character = "q"
                  endif
               until character in "y", "n", "o", "r", "q"
               case character
                  when "y"
                     times = times
                  when "n"
                     skip_one = TRUE
                  when "o"
                     times = 1
                  when "r"
                     opt = opt + "n"
                  when "q"
                     skip_one = TRUE
                     times = 1
               endcase
            endif
            if not skip_one
               old2 = GetText(CurrPos(), Length(old))
               new2 = new
               DelChar(Length(old))
               for i = 1 to Length(new2)
                  j = Min(i, Length(old2))
                  if old2[j] in "A" .. "Z"
                     new2[i] = Upper(new2[i])
                  elseif old2[j] in "a" .. "z"
                     new2[i] = Lower(new2[i])
                  endif
               endfor
               InsertText(new2, _INSERT_)
               Left(Length(new2))
               changes = changes + 1
            endif
            if Pos("+", opt) == 0
               opt = opt + "+"
            endif
            opt[Pos("g", opt)] = " "
            times = times - 1
         endwhile
         PopPosition()
         Message(changes, " changes(s) made.")
      endif
   endif
end

proc Main()
   case_copying_replace()
   PurgeMacro("ccrepl")
end

