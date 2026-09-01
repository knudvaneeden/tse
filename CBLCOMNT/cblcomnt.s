/*
   Macro.            CblComnt.
   Author.           Carlo.Hogeveen@xs4all.nl.
   Date-written.     18 April 1998.
   Compatibility.    TSE Pro 2.8 upwards.
   Version.          1.1.
   Date-updated.     10 March 2009.

   This macro remedies two Cobol issues:
   -  TSE Pro is not capable of coloring columns, neither column 1 thru 6
      nor column 73 thru the end of line.
   -  Cobol versions up to and including Cobol-85 indicate comments by
      putting an asterisk or a slash on column 7.
      Since version 3.0 TSE Pro supports this with to-end-of-line syntax
      hiliting if a configurable character is present at a configurable
      column. TSE Pro 2.8 users need this macro to do the same.

   Installation:
      Only if your TSE version is 2.8, then change the #define of the
      COLOR_COBOL_COMMENTS variable to TRUE, otherwise TSE itself is or can
      be configured to syntax hilite Cobol comments.

      Put this macro source in TSE's "mac" directory,
      compile it,
      and add it to your Macro AutoloadList.

   Fortran programmers:
      I understand that Fortran indicates a comment by putting an asterisk
      on column 1. Simply adjust the initial values of the constants and
      the variables at the begin of the source to make this a macro for
      Fortran comments.

   History:
      10 Mar 2009
         Greatly reduced the amount of processor time this macro needed.
         Default disabled syntax hiliting of Cobol comments by this macro,
         because TSE Pro 3.0 upwards can do this itself.
*/


/*
   Choose PRIORITY  1 for the fastest cobol comment hiliting.
   Choose PRIORITY 18 for a one second delay, etcetera.
   You might want slow cobol comment hiliting to avoid or overrule another
   hiliting macro.
*/

#define PRIORITY 1


/*
   In Cobol versions up to and including Cobol-85, columns 1 thru 6 of each
   line are ignored (they might contain line numbers) an columns 73 and
   further are ignored (sometimes used for small comments).
   It is obvious to color these margins just like (to-end-of-line) comments,
   because they don't influence the code.
*/

#define COLOR_COBOL_COMMENTS FALSE // No longer needed in modern TSE versions.
#define COLOR_COBOL_LEFT_MARGIN TRUE
#define COLOR_COBOL_RIGHT_MARGIN TRUE


integer prev_line    = 0
integer prev_column  = 0
integer prev_xoffset = 0
integer prev_row     = 0


proc hilite_cobol_comments()

// Begin of configuration variables:

   string  comment_color      [1] = Chr(Query(ToEOL1Attr))
   string  left_margin_color  [1] = Chr(Query(ToEOL1Attr))
   string  right_margin_color [1] = Chr(Query(ToEOL1Attr))

   integer comment_position = 7

   string  comment_characters [10] = "*/"

   string  comment_extensions [40] = ".cbl.cob"

// End of configuration variables.

   integer state = SetHookState(OFF)
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

   if GetClockTicks() mod PRIORITY == 0
      if Pos(CurrExt(), comment_extensions)
         if prev_line    <> CurrLine()
         or prev_column  <> CurrCol()
         or prev_xoffset <> CurrXoffset()
         or prev_row     <> CurrRow()
            prev_line    = CurrLine()
            prev_column  = CurrCol()
            prev_xoffset = CurrXoffset()
            prev_row     = CurrRow()
            cursor_attr        = iif(Query(CursorAttr)        == Query(TextAttr), MAXINT, Query(CursorAttr))
            hilite_attr        = iif(Query(HiLiteAttr)        == Query(TextAttr), MAXINT, Query(HiLiteAttr))
            block_attr         = iif(Query(BlockAttr)         == Query(TextAttr), MAXINT, Query(BlockAttr))
            cursorinblock_attr = iif(Query(CursorInBlockAttr) == Query(TextAttr), MAXINT, Query(CursorInBlockAttr))
            col_offset = Query(WindowX1) - 1
            row_offset = Query(WindowY1) - 1
            BufferVideo()
            for row = 1 to Query(WindowRows)
               VGotoXY(1 + col_offset, row + row_offset)
               line_chars = ""
               line_attrs = ""
               line_length = GetStrAttr(  line_chars,
                                          line_attrs,
                                          Query(WindowCols))
               if COLOR_COBOL_COMMENTS
                  if Pos(line_chars[comment_position], comment_characters)
                     if line_attrs[comment_position] <> comment_color
                        for line_index = 1 to line_length
                           if Asc(line_attrs[line_index]) in cursor_attr,
                                                             hilite_attr,
                                                             block_attr,
                                                             cursorinblock_attr
                           else
                              line_attrs[line_index] = comment_color
                           endif
                        endfor
                     endif
                  endif
               endif
               if COLOR_COBOL_LEFT_MARGIN
                  for line_index = 1 to 6
                     if Asc(line_attrs[line_index]) in cursor_attr,
                                                       hilite_attr,
                                                       block_attr,
                                                       cursorinblock_attr
                     else
                        line_attrs[line_index] = right_margin_color
                     endif
                  endfor
               endif
               if COLOR_COBOL_RIGHT_MARGIN
                  for line_index = 73 to line_length
                     if Asc(line_attrs[line_index]) in cursor_attr,
                                                       hilite_attr,
                                                       block_attr,
                                                       cursorinblock_attr
                     else
                        line_attrs[line_index] = left_margin_color
                     endif
                  endfor
               endif
               VGotoXY(1 + col_offset, row + row_offset)
               PutStrAttr(line_chars, line_attrs)
            endfor
            UnBufferVideo()
         endif
      endif
   endif
   SetHookState(state)
end


proc WhenLoaded()
   Hook(_IDLE_, hilite_cobol_comments)
end


proc Main()
end

