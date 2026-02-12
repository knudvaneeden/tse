/*
   Macro.         Hirexp.
   Author.        Carlo Hogeveen (hyphen@xs4all.nl).
   Date-written.  28 May 1998.
   Version.       1.

   The current 32-bit versions of TSE Pro are not capable of
   syntax-hiliting everything that the 16-bit version can.

   This macro (for 32-bit versions of TSE Pro only) allows you to color
   parts of each screen line based on:
      the current file extension
      the current comment colors (by NOT recoloring them)
      multiple regular expressions

   Note: Always try using TSE Pro 32's built-in syntax hiliting first,
         because it is a lot faster, and regular expressions have their
         limits too.

   Put the macro HIREXP.S in TSE's mac directory, compile it,
   and add it to your Macro AutoloadList.

   Copy the example file HIREXP.DAT to TSE's mac directory
   and edit it to your heart's delight.

   Note for Cobol and Fortran programmers:

      There is a older and specialized macro CBLCOMNT, which colors Cobol
      and Fortran comments a lot faster than this macro does.

   Note for version 1:

      This macro was rather quickly built, after once again someone asked for
      a way to syntax-hilite regular expressions, and although pressed for
      time (two exams coming up) I realized that I already had a good start
      in the CBLCOMNT macro.

      Corners were cut in testing, in optimizing and in making a pretty file
      format for the HIREXP.DAT file.

      Report problems or wishes to the above e-mail address.
*/


/*
   Choose PRIORITY 1 for
      the fastest hiliting,
      the slowest keyboard response,
      the TSE task using the most processor time.
   Choose a higher number to shift that balance.
*/

#define PRIORITY 1


// These variables must be global:

string  current_extension [4] = ""
string  old_extension     [4] = ""
integer hilitable_extension   = false


// These variables are global for speed reasons:

integer old_state
integer row
integer col_offset
integer row_offset

integer cursor_attr
integer hilite_attr
integer block_attr
integer cursorinblock_attr

string  line_chars[255]
string  line_attrs[255]
integer line_length
integer line_index

integer dat_id
integer dat_line_first
integer dat_line_last
integer dat_line_number
string  dat_line_text[255]

string  syntax_color[2]
string  syntax_not_colors[255]
string  syntax_regexp[255]
string  syntax_options[255]
integer syntax_found
integer syntax_repeatable
integer syntax_param_counter

integer hilite_id
integer org_id

integer old_clockticks = 0


proc hilite_regular_expressions()
   if getclockticks() mod PRIORITY == 0
      current_extension = currext()
      if current_extension == ""
         current_extension = ". "
      endif
      if old_extension <> current_extension
         old_extension =  current_extension
         org_id = getbufferid()
         gotobufferid(dat_id)
         if lfind("^ *\[[~\]]*\" + current_extension, "gix")
            dat_line_first = currline() + 1
            if lfind("^ *\[.+\]", "ix+")
               dat_line_last = currline() - 1
            else
               endfile()
               dat_line_last = currline()
            endif
            hilitable_extension = true
         else
            hilitable_extension = false
         endif
         gotobufferid(org_id)
      endif
      if keypressed()
         old_clockticks = getclockticks() + PRIORITY
      endif
      if  hilitable_extension
      and getclockticks() - old_clockticks > PRIORITY
         old_state = sethookstate(off)
         cursor_attr        = iif(query(cursorattr) == query(textattr),
                                  MAXINT, query(cursorattr))
         hilite_attr        = iif(query(hiliteattr) == query(textattr),
                                  MAXINT, query(hiliteattr))
         block_attr         = iif(query(blockattr) == query(textattr),
                                  MAXINT, query(blockattr))
         cursorinblock_attr = iif(query(cursorinblockattr) == query(textattr),
                                  MAXINT, query(cursorinblockattr))
         buffervideo()
         org_id = getbufferid()
         col_offset = query(windowx1) - 1
         row_offset = query(windowy1) - 1
         for row = 1 to query(windowrows)
            vgotoxy(1 + col_offset, row + row_offset)
            line_chars = ""
            line_attrs = ""
            line_length = getstrattr(  line_chars,
                                       line_attrs,
                                       query(windowcols))
            line_length = line_length // Skip compiler warning
            gotobufferid(hilite_id)
            emptybuffer()
            addline(line_chars)
            begline()
            for dat_line_number = dat_line_first to dat_line_last
               gotobufferid(dat_id)
               gotoline(dat_line_number)
               dat_line_text        = gettext(1, currlinelen())
               syntax_color         = lower(gettoken(dat_line_text, "", 1))
               syntax_not_colors    = lower(gettoken(dat_line_text, "", 2))
               syntax_param_counter = 1
               syntax_found         = true
               syntax_repeatable    = true
               repeat
                  syntax_param_counter = syntax_param_counter + 2
                  syntax_regexp  = gettoken(dat_line_text, "",
                                            syntax_param_counter)
                  syntax_options = lower(gettoken(dat_line_text, "",
                                                  syntax_param_counter + 1))
                  if syntax_regexp == ""
                     if syntax_param_counter == 3
                        syntax_found = false
                     endif
                  else
                     gotobufferid(hilite_id)
                     if syntax_options == ""
                        syntax_options = "cix"
                     else
                        if pos("b", syntax_options)
                        or pos("g", syntax_options)
                           syntax_repeatable = false
                        endif
                        if pos(">", syntax_options)
                           right(length(getfoundtext()))
                           syntax_options[pos(">", syntax_options)] = " "
                        endif
                     endif
                     if not lfind(syntax_regexp, syntax_options)
                        syntax_found = false
                     endif
                  endif
               until syntax_found  == false
                  or syntax_regexp == ""
               if syntax_found
                  if not pos(str(asc(line_attrs[currpos()]), 16),
                             syntax_not_colors)
                     for line_index = currpos()
                     to currpos() + length(getfoundtext()) - 1
                        if asc(line_attrs[line_index])
                        in cursor_attr,
                           hilite_attr,
                           block_attr,
                           cursorinblock_attr
                        else
                           line_attrs[line_index] = chr(val(syntax_color, 16))
                        endif
                     endfor
                  endif
               endif
               gotobufferid(hilite_id)
               if  syntax_found
               and syntax_repeatable
                  right()
                  dat_line_number = dat_line_number - 1
               else
                  begline()
               endif
            endfor
            vgotoxy(1 + col_offset, row + row_offset)
            putstrattr(line_chars, line_attrs)
         endfor
         gotobufferid(org_id)
         unbuffervideo()
         sethookstate(old_state)
         old_clockticks = getclockticks() + PRIORITY
      endif
   endif
   if keypressed()
      old_clockticks = getclockticks() + PRIORITY
   endif
end


proc whenloaded()
   org_id = getbufferid()
   hilite_id = createtempbuffer()
   pushblock()
   if getbufferid(loaddir() + "mac\hirexp.dat")
      gotobufferid(getbufferid(loaddir() + "mac\hirexp.dat"))
      markline(1,numlines())
      copy()
   else
      editfile(loaddir() + "mac\hirexp.dat")
      markline(1,numlines())
      copy()
      abandonfile()
   endif
   dat_id = createtempbuffer()
   paste()
   popblock()
   gotobufferid(org_id)
   hook(_idle_, hilite_regular_expressions)
end


proc main()
   hilite_regular_expressions()
end

