/*
   Macro    MinRxLen
   Author   Carlo.Hogeveen@xs4all.nl
   Version  1.01
   Date     1 May 2006

   Because TSE Pro up to 4.40.13 hangs if you do a Replace which searches
   for a regular expression that can equal an empty string, this macro
   attempts to determine beforehand what the minimum length of a found string
   could possibly be given a certain regular expression.

   V1.01    4 May 2006
      For practical purposes it appears we SHOULD allow empty strings
      which contain the "^" or "$" character.
      v1.01 does this by pretending those two characters have a length of 1.
*/

#define THIS_TIME 1
#define NEXT_TIME 2

integer proc minimum_regexp_length(string s)
   integer result = 0
   integer i = 0
   integer prev_i = 0
   integer addition = 0
   integer prev_addition = 0
   integer tag_level = 0
   integer orred_addition = 0
   integer use_orred_addition = FALSE
   // For each character.
   for i = 1 to Length(s)
      // Ignore this zero-length "character".
      if Lower(SubStr(s,i,2)) == "\c"
         i = i + 1
      else
         // Skip index for all these cases so they will be counted as one
         // character.
         case SubStr(s,i,1)
            when "["
               while i < Length(s)
               and   SubStr(s,i,1) <> "]"
                  i = i + 1
               endwhile
            when "\"
               i = i + 1
               case Lower(SubStr(s,i,1))
                  when "x"
                     i = i + 2
                  when "d", "o"
                     i = i + 3
               endcase
         endcase
         // Now start counting.
         if use_orred_addition == NEXT_TIME
            use_orred_addition =  THIS_TIME
         endif
         // Count a literal character as one:
         if SubStr(s,i-1,1) == "\" // (Using the robustness of SubStr!)
            addition = 1
         // Count a tagged string as the length of its subexpression:
         elseif SubStr(s,i,1) == "{"
            prev_i = i
            tag_level = 1
            while i < Length(s)
            and   (tag_level <> 0 or SubStr(s,i,1) <> "}")
               i = i + 1
               if SubStr(s,i,1) == "{"
                  tag_level = tag_level + 1
               elseif SubStr(s,i,1) == "}"
                  tag_level = tag_level - 1
               endif
            endwhile
            addition = minimum_regexp_length(SubStr(s,prev_i+1,i-prev_i-1))
         // For a "previous character or tagged string may occur zero
         // times" operator: since it was already counted, subtract it.
         elseif SubStr(s,i,1) in "*", "@", "?"
            addition = -1 * Abs(prev_addition)
         // This is a tough one: the "or" operator.
         // For now subtract the length of the previous character or
         // tagged string, but remember doing so, because you might have
         // to add it again instead of the length of the character or
         // tagged string after the "or" operator.
         elseif SubStr(s,i,1) == "|"
            addition = -1 * Abs(prev_addition)
            orred_addition = Abs(prev_addition)
            use_orred_addition = NEXT_TIME
         else
         // Count ordinary characters as 1 character.
            addition = 1
         endif
         if use_orred_addition == THIS_TIME
            if orred_addition < addition
               addition = orred_addition
            endif
            use_orred_addition = FALSE
         endif
         result = result + addition
         prev_addition = addition
      endif
   endfor
   return(result)
end

proc Main()
   string s [255] = ""
   while Ask("Regular expression:", s)
      Message("This regulular expression's minimum result length = ",
              minimum_regexp_length(s))
   endwhile
   Message("You escaped!")
   Delay(36)
   PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end

