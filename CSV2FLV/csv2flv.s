/*
   Macro          Csv2flv
   Author         Carlo.Hogeveen@xs4all.nl
   Date           29 Februari 2004
   Version        1.1
   Date           8 November 2006
   Compatibility  TSE Pro 2.5e upwards

   This macro converts a .csv file to a .flv file.

   In a .csv file:
      Each line containes comma separated values, hence the name.
      Microsoft applications typically use semicolons instead of commas.
      This macro accepts either, or any other field separator character.
      Terminology: in this context lines are also called records.
      Terminology: the Nth field is the collection of all Nth values.
      Terminology: type numeric means only containing valid numbers.
      Terminology: type alphanumeric means containing any character string.
      Within a line, values may be of a different type.
      Across lines, all first values are assumed to be of the same type,
      all second values are assumed to be of the same type, etcetera.
      No values may have leading or trailing spaces.
      Numeric values usually have no leading and trailing zeros.
      Numeric values may have a leading or trailing sign.
      Numeric values may contain one decimal character (either a point or a
      comma), and grouping characters (either a comma or a point) before or
      after every third digit, but they must do so consistently per field.
      Alphanumeric values containing spaces or quotes are quoted.
      A quote inside an alphanumeric value is represented by two quotes.
      The quoting character is usually a single or a double quote.
      This macro accepts either, or any other quoting character.
      Because of all of the above, values and lines have a variable length.

   In a .flv file:
      Each line has a fixed length.
      Each line consists of fixed length values, hence the name.
      This does not mean that values in one line have the same length.
      It means that across lines all first values have the same length,
      all second values have the same length, etcetera. The assumption is,
      that each line contains values for the same set of fields.
      The macro assumes that a field is numeric if it only contains valid
      numbers, otherwise it assumes the field to be alphanumeric.
      The user can override this to treat a numeric field as alphanumeric.
      Alphanumeric values are being left justified and get traling spaces
      to give them all the same length.
      Numeric values are being aligned on the decimal character, and get
      leading and trailing zeros to give them all the same length.
      Numeric commas and points mean opposit things in different countries:
      this macro determines which is which based on the input file; if that
      is impossible then it asks the user.
      Note that if a numeric field only contains one grouping character
      (either a point or comma) per value, then the user has to supply the
      opposite character (either a comma or point) as the decimal character.

   Installation:
      Just copy this source to TSE's "mac" directory,
      and compile it as a TSE macro.

   Use:
      Have a .csv file open and current in TSE, and execute this TSE macro.
      The .csv file is not removed from TSE and not changed.
      After a succesful conversion you have a copy, a new unsaved file
      with the same name, but with an extension .flv.
      You probably still have to adjust the columns to some external
      specification, but at least now you can do so with simple block
      operations.

   Disclaimer:
      This macro does not cover all possible .csv situations:
      use it at your own risk, and always check the result,
      especially the first lines.

   History:
      1.0   Initial version.
      1.1   Added an optional field separator for the generated FLV file
            as requested by user (Leslie) Ray Richey.
*/

#ifdef WIN32
#else
   string proc QuotePath(string s)
      string result [255] = s
      if Pos(" ", result)
         if SubStr(result,1,1) <> '"'
            result = '"' + result
         endif
         if SubStr(result,Length(result),1) <> '"'
            result = result + '"'
         endif
      endif
      return(result)
   end
#endif

proc status_report(string text, integer field)
   if CurrLine() mod 100 == 0
      Message(text, field, "     ", CurrLine()*100/NumLines(), " % ")
   endif
end

string proc digitize(string s)
   string  result [255] = s
   integer i = 1
   while i <= Length(result)
      if SubStr(result,i,1) in "0" .. "9"
         i = i + 1
      else
         result = SubStr(result,1,i-1) + SubStr(result,i+1,255)
      endif
   endwhile
   return(result)
end

proc check_number(string      field_value  ,
                  string      decimal_char ,
                  var integer max_integers ,
                  var integer max_decimals ,
                  var integer sign_length  ,
                  var integer sign_trailing)
   string  integers [255] = ""
   string  decimals [255] = ""
   integer curr_integers  = 0
   if decimal_char == ""
      if SubStr(integers, 1, 1) in "+", "-"
         sign_length = 1
      endif
      if SubStr(integers, Length(integers), 1) in "+", "-"
         sign_length = 1
         sign_trailing = TRUE
      endif
      curr_integers = Length(digitize(field_value))
      if curr_integers > max_integers
         max_integers = curr_integers
      endif
   else
      integers = GetToken(field_value, decimal_char, 1)
      decimals = GetToken(field_value, decimal_char, 2)
      if SubStr(integers, 1, 1) in "+", "-"
         sign_length = 1
      endif
      integers = digitize(integers)
      if Length(integers) > max_integers
         max_integers = Length(integers)
      endif
      if SubStr(decimals, Length(decimals), 1) in "+", "-"
         sign_length = 1
         sign_trailing = TRUE
      endif
      decimals = digitize(decimals)
      if Length(decimals) > max_decimals
         max_decimals = Length(decimals)
      endif
   endif
end

proc expand_number(var string field_value  ,
                   string     decimal_char ,
                   integer    max_integers ,
                   integer    max_decimals ,
                   integer    sign_length  ,
                   integer    sign_trailing)
   string  integers [255] = GetToken(field_value, decimal_char, 1)
   string  decimals [255] = GetToken(field_value, decimal_char, 2)
   string  s          [1] = ""
   string  sign       [1] = ""
   if decimal_char == ""
      integers = field_value
      s = SubStr(integers, 1, 1)
      if s in "+", "-"
         sign = s
      endif
      s = SubStr(integers, Length(integers), 1)
      if s in "+", "-"
         sign = s
      endif
      integers = digitize(integers)
      field_value = Format(integers:max_integers:"0")
      if sign_length
         if sign == ""
            sign = "+"
         endif
         if sign_trailing
            field_value = field_value + sign
         else
            field_value = sign + field_value
         endif
      endif
   else
      integers = GetToken(field_value, decimal_char, 1)
      decimals = GetToken(field_value, decimal_char, 2)
      s = SubStr(integers, 1, 1)
      if s in "+", "-"
         sign = s
      endif
      integers = digitize(integers)
      s = SubStr(decimals, Length(decimals), 1)
      if s in "+", "-"
         sign          = s
      endif
      decimals = digitize(decimals)
      field_value = Format(integers:max_integers:"0",
                           decimals:(max_decimals * -1):"0")
      if sign_length
         if sign == ""
            sign = "+"
         endif
         if sign_trailing
            field_value = field_value + sign
         else
            field_value = sign + field_value
         endif
      endif
   endif
end

integer proc is_numeric(string      s                 ,
                        var string  decimal_char      ,
                        var integer max_integers      ,
                        var integer max_decimals      ,
                        var integer numeric_separators)
   integer result               = TRUE
   integer i                    = 0
   string  s_unsigned     [255] = s
   string  s_rest         [255] = s
   string  delimiter      [255] = ""
   string  prev_delimiter [255] = ""
   string  token          [255] = ""
   integer toggled_delimiter    = 0
   integer token_length         = 0
   integer num_tokens           = 0
   for i = 1 to Length(s)
      if not (SubStr(s,i,1) in "0".."9", ".", ",", "+", "-")
         result = FALSE
      endif
   endfor
   if result
      if  Pos("+", s)
      and Pos("-", s)
         result = FALSE
      else
         if not (Pos("+", s) in 0, 1, Length(s))
         or not (Pos("-", s) in 0, 1, Length(s))
            result = FALSE
         else
            if Pos("+", s) == 1
            or Pos("-", s) == 1
               s_unsigned = SubStr(s,2,255)
            else
               if Pos("+", s) == Length(s)
               or Pos("-", s) == Length(s)
                  s_unsigned = SubStr(s,1,Length(s)-1)
               endif
            endif
         endif
      endif
   endif
   if result
      prev_delimiter     = ""
      toggled_delimiter  = 0
      s_rest             = s_unsigned
      num_tokens         = NumTokens(s_rest, ",.")
      if num_tokens > 1
         numeric_separators = TRUE
      endif
      for i = 1 to num_tokens
         token        = GetToken(s_rest, ",.", 1)
         token_length = Length(token)
         s_rest       = SubStr(s_rest, token_length + 1, 255)
         delimiter    = SubStr(s_rest, 1, 1)
         s_rest       = SubStr(s_rest, 2, 255)
         if  i >  1
         and i == num_tokens
         and token_length <> 3
            if decimal_char == ""
               decimal_char = prev_delimiter
               max_integers = 0
               max_decimals = 0
            else
               if decimal_char <> prev_delimiter
                  result = FALSE
               endif
            endif
         endif
         if  prev_delimiter <> ""
         and delimiter      <> ""
            if delimiter == prev_delimiter
               if decimal_char == ""
                  decimal_char = iif(delimiter == ".", ",", ".")
               else
                  if decimal_char == delimiter
                     result = FALSE
                  endif
               endif
            else
               toggled_delimiter = toggled_delimiter + 1
            endif
         endif
         if toggled_delimiter > 2
            result = FALSE
         endif
         prev_delimiter = delimiter
      endfor
   endif
   return(result)
end

integer proc count_char(string char)
   integer result = 0
   PushPosition()
   if lFind(char, "g")
      result = 1
      while CurrLine() < 100
      and   lFind(char, "+")
         result = result + 1
      endwhile
   endif
   PopPosition()
   return(result)
end

menu numeric_menu()
   title    = "Select how to treat numeric fields:"
   x        = 10
   y        = 10
   history  =  3
   "Treat this field as numeric"
   "Treat this field as alphanumeric"
   "Treat all numeric fields as numeric"
   "Treat all numeric fields as alphanumeric"
end

menu decimal_menu()
   title   = "What is the decimal character for this field:"
   x       = 10
   y       = 10
   history
   "Treat this field as alphanumeric"
   "Use a point as the decimal character for this field"
   "Use a comma as the decimal character for this field"
   "Use a point as the decimal character for all fields"
   "Use a comma as the decimal character for all fields"
end

proc Main()
   integer ok                     = TRUE
   integer csv_id                 = GetBufferId()
   integer old_break              = Set(Break, ON)
   integer old_rtw                = Query(RemoveTrailingWhite)
   integer old_line               = CurrLine()
   integer separator_found        = FALSE
   integer quoted                 = FALSE
   integer end_of_record          = FALSE
   integer field_start_column     = 1
   integer max_separator_column   = 0
   integer field                  = 0
   integer field_is_numeric       = TRUE
   string  field_value      [255] = ""
   integer field_length           = 0
   integer max_integers           = 0
   integer max_decimals           = 0
   integer sign_length            = 0
   integer sign_trailing          = FALSE
   integer all_numeric            = 0
   integer all_decimal_problems   = 0
   string  decimal_char       [1] = ""
   integer numeric_separators     = FALSE
   integer decimal_problem        = FALSE
   string  char               [1] = ""
   integer quote                  = 0
   integer field_separator        = 0
   integer separator_column       = 0
   integer flv_id = EditFile(QuotePath(SplitPath(CurrFilename(),
                                                 _DRIVE_|_PATH_|_NAME_)
                                       + ".flv"),
                             _DONT_PROMPT_)
   string  new_field_separator [255] =
      GetHistoryStr(GetFreeHistory(SplitPath(CurrMacroFilename(),
                                             _NAME_)
                                   + ":new_field_separator"), 1)
   integer new_field_separator_len = 0
   Message("Converting .csv to .flv format ... ")
   Delay(36)
   if not flv_id
      ok = FALSE
   endif
   if ok
      EmptyBuffer()
      GotoBufferId(csv_id)
      MarkLine(1,NumLines())
      Copy()
      GotoBufferId(flv_id)
      Paste()
      UnMarkBlock()
      Message("Determining the old field separator ... ")
      Delay(9)
      char = iif(count_char(",") < count_char(";"), ";", ",")
      Set(X1,10)
      Set(Y1,10)
      if not Ask("Optionally correct the old field separator:", char)
      or char == ""
         ok = FALSE
      endif
   endif
   if ok
      if not Ask("New field separator (enter empty string for none):",
                  new_field_separator,
                  GetFreeHistory(SplitPath(CurrMacroFilename(),
                                           _NAME_)
                                 + ":new_field_separator"))
         ok = FALSE
      endif
   endif
   if ok
      field_separator = Asc(char)
      Message("Determining the quoting character ... ")
      Delay(9)
      char = iif(count_char("'") < count_char('"'), '"', "'")
      Set(X1,10)
      Set(Y1,10)
      if not Ask("Optionally correct the quoting character:", char)
      or char == ""
         ok = FALSE
      endif
   endif
   if ok
      quote = Asc(char)
      Set(RemoveTrailingWhite, OFF)
      repeat // For each field.
         repeat // Until no decimal char problem for a numeric field.
            if decimal_problem
               decimal_problem   = FALSE
            else
               field             = field + 1
               decimal_char      = ""
            endif
            field_is_numeric     = TRUE
            max_separator_column = 0
            max_integers         = 0
            max_decimals         = 0
            sign_length          = 0
            sign_trailing        = FALSE
            numeric_separators   = FALSE
            BegFile()
            repeat // For each value of the field.
               status_report("Checking  field ", field)
               GotoColumn(field_start_column)
               separator_found = FALSE
               quoted          = FALSE
               repeat
                  case CurrChar()
                     when quote
                        if  quoted
                        and CurrChar(CurrCol() + 1) == quote
                           Right()
                        else
                           quoted = not(quoted)
                        endif
                     when field_separator, _AT_EOL_
                        if not quoted
                           separator_found = TRUE
                           separator_column = CurrCol()
                           if  separator_column > field_start_column
                           and CurrChar(field_start_column  ) == quote
                           and CurrChar(separator_column - 1) == quote
                              separator_column = separator_column - 2
                           endif
                           if max_separator_column < separator_column
                              max_separator_column = separator_column
                           endif
                        endif
                        if CurrChar() == _AT_EOL_
                           end_of_record = TRUE
                        endif
                  endcase
               until separator_found
                  or CurrChar() == _AT_EOL_
                  or not Right()
               if CurrCol() == MAXLINELEN
                  ok = FALSE
                  Warn("Error: line length at ",
                        MAXLINELEN, " (TSE's maximum)   ")
               else
                  if field_is_numeric
                     field_value = GetText(field_start_column,
                                           CurrCol() - field_start_column)
                     if  Asc(SubStr(field_value,                  1,1)) == quote
                     and Asc(SubStr(field_value,Length(field_value),1)) == quote
                        field_value = SubStr(field_value,2,Length(field_value)-2)
                     endif
                     field_is_numeric = is_numeric(field_value, decimal_char,
                                                   max_integers, max_decimals,
                                                   numeric_separators)
                     if field_is_numeric
                        check_number(field_value , decimal_char,
                                     max_integers, max_decimals,
                                     sign_length , sign_trailing)
                     endif
                  endif
               endif
            until not ok
               or not Down()
            BegFile()
            if  ok
            and field_is_numeric
               if all_numeric == 2
                  field_is_numeric = FALSE
               elseif all_numeric == 0
                  Message("Field ", field, " is numeric")
                  Delay(9)
                  numeric_menu()
                  case MenuOption()
                     when 0
                        Message("Stopping conversion ... ")
                        Delay(36)
                        ok = FALSE
                     when 2
                        field_is_numeric = FALSE
                     when 3
                        all_numeric      = 1
                     when 4
                        field_is_numeric = FALSE
                        all_numeric      = 2
                  endcase
               endif
            endif
            if  ok
            and field_is_numeric
               if  numeric_separators
               and decimal_char == ""
                  if     all_decimal_problems == 1
                     decimal_char = "."
                     decimal_problem = TRUE
                  elseif all_decimal_problems == 2
                     decimal_char = ","
                     decimal_problem = TRUE
                  else
                     Message("Decimal character undeterminable for numeric field ",
                             field)
                     Delay(9)
                     decimal_menu()
                     case MenuOption()
                        when 0
                           Message("Stopping conversion ... ")
                           Delay(36)
                           ok = FALSE
                        when 1
                           field_is_numeric = FALSE
                        when 2
                           decimal_char = "."
                           decimal_problem = TRUE
                        when 3
                           decimal_char = ","
                           decimal_problem = TRUE
                        when 4
                           decimal_char = "."
                           decimal_problem = TRUE
                           all_decimal_problems = 1
                        when 5
                           decimal_char = ","
                           decimal_problem = TRUE
                           all_decimal_problems = 2
                     endcase
                  endif
               endif
            endif
         until not decimal_problem
         if ok
            repeat
               status_report("Expanding field ", field)
               GotoColumn(field_start_column)
               separator_found = FALSE
               quoted          = FALSE
               repeat
                  case CurrChar()
                     when quote
                        if  quoted
                        and CurrChar(CurrCol() + 1) == quote
                           DelChar()
                        else
                           quoted = not(quoted)
                        endif
                     when field_separator, _AT_EOL_
                        if not quoted
                           separator_found  = TRUE
                           separator_column = CurrCol()
                           field_length = separator_column - field_start_column
                           if CurrChar() == field_separator
                              DelChar()
                           endif
                           if field_is_numeric
                              field_value = GetText(field_start_column,
                                                    field_length)
                              if  Asc(SubStr(field_value,                  1,1)) == quote
                              and Asc(SubStr(field_value,Length(field_value),1)) == quote
                                 field_value = SubStr(field_value,2,Length(field_value)-2)
                              endif
                              if field_length > 0
                                 MarkColumn(CurrLine(), field_start_column,
                                            CurrLine(), separator_column - 1)
                                 KillBlock()
                              endif
                              expand_number(field_value  ,
                                            decimal_char ,
                                            max_integers ,
                                            max_decimals ,
                                            sign_length  ,
                                            sign_trailing)
                              InsertText(field_value, _INSERT_)
                           else
                              if  field_length > 0
                              and CurrChar(field_start_column)   == quote
                              and CurrChar(separator_column - 1) == quote
                                 GotoColumn(separator_column - 1)
                                 DelChar()
                                 GotoColumn(field_start_column)
                                 DelChar()
                                 field_length     = field_length     - 2
                                 separator_column = separator_column - 2
                              endif
                              GotoColumn(separator_column)
                              while CurrCol() < max_separator_column
                                 InsertText(" ", _DEFAULT_)
                              endwhile
                           endif
                        endif
                  endcase
               until separator_found
                  or CurrChar() == _AT_EOL_
                  or not Right()
               if field_start_column > 1
                  GotoColumn(field_start_column)
                  InsertText(new_field_separator, _INSERT_)
               endif
            until not Down()
            if field_start_column == 1
               new_field_separator_len = 0
            else
               new_field_separator_len = Length(new_field_separator)
            endif
            if field_is_numeric
               field_start_column = field_start_column
                                  + max_integers
                                  + max_decimals
                                  + sign_length
            else
               field_start_column = max_separator_column
            endif
            field_start_column = field_start_column
                               + new_field_separator_len
         endif
      until not ok
         or end_of_record
   endif
   if ok
      BegFile()
      UpdateDisplay()
      Message("Done.   (all files will now be saved with trailing whitespaces!)")
   else
      Set(RemoveTrailingWhite, old_rtw)
      old_line = CurrLine()
      GotoBufferId(csv_id)
      GotoLine(old_line)
      BegLine()
      AbandonFile(flv_id)
      UpdateDisplay()
      Message("Aborted")
   endif
   Set(Break, old_break)
   PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
end

