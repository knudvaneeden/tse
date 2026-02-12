/*
   Macro    MarkTokn
   Author   Carlo.Hogeveen@xs4all.nl
   Date     24 May 2004

   This macro marks and unmarks tokens in both directions,
   a token being a whole word or a single non-word character.

   What constitutes a word(-character) is defined by TSE's current wordset.

   In my humble opinion, the way that Windows applications or the CuaMark
   macro mark "words" with the Ctrl Shift Left and Right keys is clumsy.

   This macro is intended as a replacement that is handy.

   In that spirit some logic was added to sometimes also include the
   beginning spaces of a line, but only where the context makes it handy.

   Installation:
      Put this sourcefile is TSE's "mac" directory, and compile it.
      Outside this macro, attach two keys to it as follows:
         <CtrlShift CursorRight>       ExecMacro("MarkTokn forwards")
         <CtrlShift GreyCursorRight>   ExecMacro("MarkTokn forwards")
         <CtrlShift CursorLeft>        ExecMacro("MarkTokn backwards")
         <CtrlShift GreyCursorLeft>    ExecMacro("MarkTokn backwards")
      Do this for example in your .ui file, and recompile your .ui file.

      Note: you cannot attach keys inside this macro, because it depends on
            unloading itself when it is not marking tokens.

      Users of the CuaMark macro, who want this macro to overrule the key
      definitions of <CtrlShift CurSorRight> and <CtrlShift GreyCursorRight>,
      have to comment the following line in the CuaMark macro, and check that
      the CuaMark macro is unchanged after each upgrade of TSE:
         when <CtrlShift GreyCursorLeft>, <CtrlShift CursorLeft>     init() WordLeft()
         when <CtrlShift GreyCursorRight>, <CtrlShift CursorRight>   init() WordRight()

   Compatibility:
      This macro works from TSE 2.5 upwards.
*/

#define CARRIAGE_RETURN 13
#define FORMFEED        10
#define HORIZONTAL_TAB   9
#define SPACE           32

integer first_block_begin_line = 0
integer first_block_begin_pos  = 0
integer first_block_end_line   = 0
integer first_block_end_pos    = 0

integer block_begin_line
integer block_begin_pos
integer block_end_line
integer block_end_pos

integer new_cursor_line = 0
integer new_cursor_pos  = 0

integer proc currchar_is_whitespace()
   return (CurrChar() in _AT_EOL_, _BEYOND_EOL_,
                         CARRIAGE_RETURN, FORMFEED,
                         HORIZONTAL_TAB, SPACE)
end

proc get_marking_positions()
   PushPosition()
   GotoBlockBegin()
   block_begin_line = CurrLine()
   block_begin_pos  = CurrPos()
   GotoBlockEnd()
   block_end_line   = CurrLine()
   block_end_pos    = CurrPos()
   PopPosition()
end

proc re_mark_block()
   if GetWord(FALSE) == ""
      block_begin_line = CurrLine()
      block_begin_pos  = CurrPos()
      block_end_line   = CurrLine()
      block_end_pos    = CurrPos() + 1
   else
      MarkWord()
      get_marking_positions()
   endif
   new_cursor_line = block_end_line
   new_cursor_pos  = block_end_pos
   if block_begin_line <> 0
      if first_block_begin_line == 0
         first_block_begin_line = block_begin_line
         first_block_begin_pos  = block_begin_pos
         first_block_end_line   = block_end_line
         first_block_end_pos    = block_end_pos
      else
         if block_begin_line > first_block_begin_line
         or (   block_begin_line == first_block_begin_line
            and block_begin_pos  >  first_block_begin_pos )
            block_begin_line = first_block_begin_line
            block_begin_pos  = first_block_begin_pos
         endif
         if block_end_line < first_block_end_line
         or (   block_end_line == first_block_end_line
            and block_end_pos  <  first_block_end_pos )
            block_end_line = first_block_end_line
            block_end_pos  = first_block_end_pos
         endif
      endif
      UnMarkBlock()
      GotoLine(block_begin_line)
      GotoPos(block_begin_pos)
      MarkChar()
      GotoLine(block_end_line)
      GotoPos(block_end_pos)
      if new_cursor_line < block_end_line
      or (   new_cursor_line == block_end_line
         and new_cursor_pos  <  block_end_pos )
         MarkChar()
         GotoLine(new_cursor_line)
         GotoPos(new_cursor_pos)
      endif
   endif
end

proc mark_token_backwards()
   PrevChar()
   if GetWord(FALSE) <> ""
      Left(Length(GetWord()) - 1)
   endif
   while PrevChar()
   and   currchar_is_whitespace()
   and   (  CurrPos() <> 1
         or (  CurrLine()  > first_block_begin_line
            or (   CurrLine() == first_block_begin_line
               and CurrPos()  >  first_block_begin_pos
               )
            )
         )
   endwhile
end

proc mark_token_forwards()
   while currchar_is_whitespace()
   and   (  CurrPos() <> 1
         or (  CurrLine()  > first_block_begin_line
            or (   CurrLine() == first_block_begin_line
               and CurrPos()  >  first_block_begin_pos
               )
            )
         )
   and   NextChar()
   endwhile
end

proc idle()
   if isBlockMarked() <> _NON_INCLUSIVE_
      PurgeMacro(SplitPath(CurrMacroFilename(), _NAME_))
   endif
end

proc Main()
   string parameter [255] = Lower(GetToken(Query(MacroCmdLine), " ", 1))
   block_begin_line = 0
   block_begin_pos  = 0
   block_end_line   = 0
   block_end_pos    = 0
   if  first_block_begin_line == 0
   and isCursorInBlock()      == _NON_INCLUSIVE_
      get_marking_positions()
      first_block_begin_line = block_begin_line
      first_block_begin_pos  = block_begin_pos
      first_block_end_line   = block_end_line
      first_block_end_pos    = block_end_pos
   endif
   if not isBlockMarked()
      if parameter == "backwards"
         if CurrPos() < PosFirstNonWhite()
            BegLine()
         else
            NextChar()
         endif
      else
         if CurrPos() < PosFirstNonWhite()
            first_block_begin_line = CurrLine()
            first_block_begin_pos  = 0
            first_block_end_line   = CurrLine()
            first_block_end_pos    = 1
            GotoPos(1)
         endif
      endif
   endif
   UnMarkBlock()
   if parameter == "backwards"
      mark_token_backwards()
   else
      mark_token_forwards()
   endif
   re_mark_block()
   Hook(_IDLE_, idle)
end

