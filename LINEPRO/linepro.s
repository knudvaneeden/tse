/*

        To use this macro within other macros via an #include statement,
        comment out the Main() procedure at the end of this file.

ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ LINE PROCESSOR ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

A) DESCRIPTION                                                            */

         helpdef descrip     title='LinePro Help'     x=4     y=1
'                                                                        '
' Cut Blanks       Delete all blank lines.                               '
'                                                                        '
' Cut Extra        Delete a blank line if preceeding line is also blank. '
'                                                                        '
' Cut Dupes        Delete any line identical to preceeding line.         '
'                                                                        '
' Cut String       Delete lines containing the specified string.         '
'                                                                        '
' Cut List         Delete lines containing ANY of the strings in the     '
'                  specified list (see: "LISTS", below)                  '
'                                                                        '
' Keep String      Keep only lines containing the specified string.      '
'                                                                        '
' Keep List        Keep only lines containing ALL of the strings in the  '
'                  specified list (see: "LISTS", below).                 '
'                                                                        '
' Double Space     Insert blank lines between existing lines.            '
'                                                                        '
' Insert String    Insert a string at cursor position. If cursor is      '
'                  inside a column block, insert string at left edge of  '
'                  block and shift only text within block.               '
'                                                                        '
' Append String    Append a string at end of line, skipping blank lines. '
'                  If cursor is inside a column block, append string     '
'                  after last non-white character in block.              '
'                                                                        '
' Number lines     Insert line number at cursor position, not counting   '
'                  blank lines. If cursor is inside a column block,      '
'                  insert number at left edge of block and shift only    '
'                  text within block.                                    '
'                                                                        '
' Flush to cursor  Shift line left or right, first non-white to cursor   '
'                  position. If cursor is inside a column block, shift   '
'                  only text within block. If cursor is on LAST column   '
'                  of column block, flush LAST charater within block to  '
'                  cursor position (align columnar data to the right).   '
'                                                                        '
' Squeeze          Compress multiple spaces to single, from cursor       '
'                  position to end of line, except for leading spaces    '
'                  (leading spaces are those between the cursor and the  '
'                  next non-white character). This can be used to undo   '
'                  a right justify operation.                            '
'                                                                        '
'   ùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùùù   '
'                                                                        '
' Mode             "Cut" and "Keep" functions will delete lines. These   '
'                  lines are dumped to a special clipboard. If the       '
'                  clipboard is in OVERWRITE mode, lines deleted during  '
'                  the next operation will overwrite what is currently   '
'                  in the clipboard. In APPEND mode, they will be        '
'                  appended.                                             '
'                                                                        '
' Go to            Look at clipboard contents. The clipboard cannot be   '
'                  edited directly. <Escape> to return to working file. '
'                                                                        '
' Paste            Insert contents of the special clipboard into the     '
'                  current file.                                         '
'                                                                        '
' Swap             Swap the contents of the current file with that       '
'                  of the special clipboard. Allows you to take a        '
'                  look at lines you just deleted. It also inverts       '
'                  the "Cut" and "Keep" functions, which expands the     '
'                  boolean possibilities of string lists:                '
'                                                                        '
'                 [CUT lines containing ANY string in list] + [SWAP]     '
'                    = [KEEP lines containing ANY string in list]        '
'                                                                        '
'                  [KEEP lines containing ALL string in list] + [SWAP]   '
'                    = [CUT lines containing ALL string in list]         '
'                                                                        '
' LISTS            With the "Cut" and "Keep" functions, instead of       '
'                  specifying a single string, you may specify a list.   '
'                  LinePro will prompt for a filename, which can be      '
'                  either a file currently in the editor or on disk. The '
'                  format must be straight ASCII with one string per     '
'                  line. Blank lines are ignored.                        '
'                                                                        '
' Selected process is applied on a line by line basis, from current line '
' to end of file. If cursor is within a marked block, process is applied '
' from first to last line of block. When "Cut" or "Keep" processes are   '
' applied to a column block, only text within the block is checked for   '
' criterion (useful with columnar data).                                 '
'                                                                        '
                               end descrip
/*

B) USAGE

  1. To use LinePro interactively, just execute LINEPRO.MAC and the menu
     will pop up.

  2. LinePro procedures can also be called from within other macros if they
     contain the statement:

                      #include ["linepro.s"]

     In that case, two strings must be passed to LinePro() when it is
     called. The first one is the process name (see LineProMenu, below, for
     syntax; note that the string is lowercase). The second string is the
     working string (case sensitive), or the filename of the list:

                      LinePro('cut string', 'TEST')

                      LinePro('cut list', 'BOMB.LIS')

     For processes that do not require a working string, pass an empty 2nd
     string:

                      LinePro('cut blanks', '')

     For processes that do require a working string, LinePro() will prompt
     for a string if the passed 2nd string is empty. To Paste lines from the
     special clipboard, call the mSpecialPaste() procedure. You can set the
     clipboard mode through the statement:

                      clip_mode = _APPEND_
                              or
                      clip_mode = _DEFAULT_

     To swap contents of current file with that of clipboard, call the
     following procedure:

                             mSwap()

     NOTE: There is a Main() procedure in LINEPRO.S. You will have to
     comment it out if you have another Main() in your macro, otherwise it
     will not compile.


C) HOW IT WORKS

In case you wish to modify the macro, here are some explanations.

Sub-routine mPickText() returns the text to analyze, or, if it contains only
spaces, returns a null string. In the case of a Column block, if EOL happens
before or within the block, the picked string is right justified with spaces
[Chr(32)] to the block width.

Sub-routine mStartPos() returns the position of the first non-white character
on the line, or, if the cursor is inside a column block, that of the first
non-white character in the block. If the cursor is on the last column of a
column block, returns position of the last non-white character hin the block.

The same loop controls execution of all processes, whether they delete
lines, add lines, or modify them. The following scheme is used to decide
when to exit the loop, based on the value of LOOP_FLAG:

          LOOP_FLAG             ACTION
             -1                 Exit loop unconditionnally
              0                 Execute Down() and loop if it returns TRUE
              1                 Loop unconditionnaly, do not execute Down()

                            -------------------

                             * Public Domain *

                     Jean Heroux [ heroux.jean@videotron.ca ]


þþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþþ*/

constant clip_text_attr   = Color(white on blue),
         clip_cursor_attr = Color(white on blue),
         clip_EOF_attr    = Color(blue on blue),
         clip_status_attr = Color(bright yellow on black)

integer lp_orig_id, lp_list_id, special_clip, start_id, list_hist,
        str_hist, prev_num, clip_mode =_DEFAULT_,
        normal_text_attr, normal_cursor_attr, normal_EOF_attr,
        normal_status_attr

string proc ModeStr(integer i)
    return (iif(i, "APPEND", "OVERWR"))
end

integer proc mLoadList(string list_spec)
    string list_name[60]=''
    if not list_hist
        list_hist = GetFreeHistory('linepro:list_hist')
    endif
    if list_spec<>''
        list_name = list_spec
    elseif not Ask('list name?', list_name, list_hist)
        return(FALSE)
    endif
    prev_num = NumFiles()
    EditFile(list_name)
    if NumFiles() > prev_num and not FileExists(list_name) // a new (empty)
        AbandonFile(lp_list_id)                               // file was just
        Message('Cannot find file:  '+ Upper(list_name))   // created by the
        return(FALSE)                                      // EditFile command
    endif
    lp_list_id = GetBufferId()
    GotoBufferId(lp_orig_id)
    return(TRUE)
end

string proc mPickText()
    integer start = 1, wide = CurrLineLen()
    string txt[255] = '', white[255] = Format('':wide)
    if isBlockMarked()==_COLUMN_
        start = Query(BlockBegCol)
        wide = Query(BlockEndCol) - start + 1
        white = Format('':wide)
    endif
    txt = Format(GetText(start, wide):-wide)
    return(iif(txt==white, '', txt))
end

integer proc mStartPos()
    integer from_pos = PosFirstNonWhite()
    if isCursorInBlock()==_COLUMN_
        if CurrCol() <> Query(BlockEndCol)
            LFind('[~\d032\d009]','xgcl')   // anything but Space and Tab
        else
            case CurrChar()
                when 32, 9, _AT_EOL_, _BEYOND_EOL_
                    LFind('[~\d032\d009]','xbcl')
            endcase
        endif
        from_pos = CurrPos()
    endif
    return(from_pos)
end

proc mSpecialPaste()
    integer old_clip=Query(ClipboardId)
    Set(ClipboardId, special_clip)
    Paste()
    Set(ClipboardId, old_clip)
end

proc mToggleAppend()
    clip_mode = iif(clip_mode, _DEFAULT_, _APPEND_)
end

integer proc mCutLine()
    if CurrLine() > NumLines()
        return(FALSE)
    endif
    if isBlockMarked()
        PushBlock()
        UnmarkBlock()
        Cut(clip_mode)
        PopBlock()
    else
        Cut(clip_mode)
    endif
    clip_mode = _APPEND_
    return(TRUE)
end

proc LinePro(string process_name, string working_str)
  string  mem_text[255] = '', curr_text[255] = '',
          chaine[255] = working_str, sensitivity[20] = ''
  integer loop_flag, loop_count = 1, number_count = 1, beg_col = 0, end_col = 0,
          cursor_col = CurrCol(), mrk_block = isBlockInCurrFile(),
          mem_lines = NumLines(), text_lines = 0,
          old_clip = Query(ClipboardId), mem_clip_mode = clip_mode,
          old_use_curr_line = Query(UseCurrLineIfNoBlock)

  lp_list_id = FALSE
  lp_orig_id = GetBufferId()
  if not special_clip       // create special clipboard when first used
      special_clip = CreateTempBuffer()
      GotoBufferId(lp_orig_id)
  endif
  if mrk_block and not isCursorInBlock()
      Message("Cursor not within block")
      return()
  elseif mrk_block==_COLUMN_
      beg_col = Query(BlockBegCol)
      end_col = Query(BlockEndCol)
  endif
  Set(UseCurrLineIfNoBlock, ON)
  Set(ClipboardId, special_clip)
  if not str_hist
     str_hist = GetFreeHistory('linepro:str_hist')
  endif
  sensitivity = iif(Pos('keep', process_name) or Pos('cut', process_name),
                " (case sensitive): ", ": ")
  if not iif(Pos('string', process_name) and chaine=='',
                          Ask(process_name+sensitivity, chaine, str_hist), 1)
      return()
  endif
  if Pos('list', process_name) and not mLoadList(working_str)
      return()
  endif
  Message('working...')
  PlaceMark('q')
  if Pos('number', process_name)
      GotoLine(Query(BlockBegLine))
      repeat
          text_lines = text_lines + iif(mPickText()<>'', 1 , 0)
      until not Down() or (mrk_block and not isCursorInBlock())
      GotoMark('q')
  endif
  GotoBlockBegin()
  GotoColumn(cursor_col)
//  process_lines = iif(mrk_block, Query(BlockEndLine), mem_lines) - CurrLine() +1
  repeat
      if mrk_block and not isCursorInBlock()
        break
      endif
      loop_flag = 0
      case process_name

        when 'cut blanks'
            loop_flag = iif(mPickText()=='', mCutLine(), 0)

        when 'cut extra'
            curr_text = mPickText()
            if loop_count > 1 and  curr_text=='' and mem_text==curr_text
                loop_flag = mCutLine()
            else
                mem_text = curr_text
            endif

        when 'cut dupes'
            if loop_count > 1 and  mem_text == mPickText()
                loop_flag = mCutLine()
            else
                mem_text = mPickText()
            endif

        when 'cut string'
            if Pos(chaine, mPickText())
              loop_flag = mCutLine()
            endif

        when 'cut list'
            GotoBufferId(lp_list_id)
            GotoLine(1)
            repeat
                chaine = GetText(1, CurrLineLen())
                GotoBufferId(lp_orig_id)
                if Pos(chaine, mPickText())
                    loop_flag = mCutLine()
                endif
                GotoBufferId(lp_list_id)
            until not Down()
            GotoBufferId(lp_orig_id)

        when 'keep string'
             if not Pos(chaine, mPickText())
                 loop_flag = mCutLine()
             endif

        when 'keep list'
            GotoBufferId(lp_list_id)
            GotoLine(1)
            repeat
                chaine = GetText(1, CurrLineLen())
                if chaine <> ''
                    GotoBufferId(lp_orig_id)
                    if not Pos(chaine, mPickText())
                        loop_flag = mCutLine()
                    endif
                    GotoBufferId(lp_list_id)
                endif
            until not Down()
            GotoBufferId(lp_orig_id)

        when 'double space'
             if CurrLine() < iif(mrk_block, Query(BlockEndLine), NumLines())
                 AddLine()
             endif

        when 'insert string'
            if beg_col
                ShiftText(Length(chaine))
                GotoColumn(beg_col)
            endif
            InsertText(chaine, iif(beg_col, _OVERWRITE_, _INSERT_))
            GotoColumn(cursor_col)

        when 'squeeze'
             LReplace('{[!-þ]#}  #','\1 ','xcn')

        when 'flush'
            if PosFirstNonWhite()
                ShiftText(CurrPos() - mStartPos())
            endif
            GotoPos(cursor_col)

        when 'append string'
            if mPickText()<>''
                if not mrk_block or not end_col
                    EndLine()
                    InsertText(chaine)
                else
                    GotoColumn(end_col)
                    mStartPos()
                    Right()
                    InsertText(Substr(chaine, 1, end_col - CurrCol() + 1),
                               _OVERWRITE_)
                endif
                GotoColumn(cursor_col)
            endif

        when 'number lines'
            if mPickText()<>''
                if beg_col
                    ShiftText(Length(Str(text_lines))+2)
                    GotoColumn(beg_col)
                endif
                InsertText(Format(number_count:Length(Str(text_lines)))
                              + ". ", iif(beg_col, _OVERWRITE_, _INSERT_))
                number_count = number_count + 1
                GotoColumn(cursor_col)
            endif

        otherwise
            Message('LinePro unknown process:  '+process_name)
            Delay(18)
            return()

      endcase
      loop_count = loop_count + 1
  until not iif(loop_flag==0, Down(), loop_flag)
  if Pos('keep', process_name) or Pos('cut', process_name)
      Message('Done!  -  '+Str(mem_lines - NumLines())+' line(s) deleted')
  else
      Message('Done!')
  endif
  if lp_list_id and NumFiles() > prev_num
      AbandonFile(lp_list_id)
  endif
  GotoMark('q')
  GotoColumn(cursor_col)
  Set(UseCurrLineIfNoBlock, old_use_curr_line)
  Set(ClipboardId, old_clip)
  clip_mode = mem_clip_mode
end

// Swap contents of current file with that of clipboard
proc mSwap()
    integer start_id = GetBufferId()
    if not GotoBufferId(special_clip)
        Message('No clipboard exists yet')
    else
        MarkLine(1, NumLines())
        GotoBufferId(start_id)
        GotoLine(1)
        MoveBlock()
        GotoBlockEnd()
        UnmarkBlock()
        if NumLines() > CurrLine()
            MarkLine(CurrLine()+1, NumLines())
            GotoBufferId(special_clip)
            MoveBlock()
            UnmarkBlock()
            GotoBufferId(start_id)
        endif
        BegFile()
    endif
end

proc mClipMsg()
    Message(' LinePro Clipboard     <Up>  <Down>  <PgUp>  <PgDn>  <Home>  <End>  <Escape>')
end

proc mReturnFromClip()
    GotoBufferId(start_id)
    Set(TextAttr, normal_text_attr)
    Set(EOFMarkerAttr, normal_EOF_attr)
    Set(CursorAttr, normal_cursor_attr)
    Set(StatusLineAttr, normal_status_attr)
    Unhook(mClipMsg)
end

keydef clip_keys
    <Escape>                mReturnFromClip() Disable(clip_keys)
    <CursorUp>              Up()
    <CursorDown>            Down()
    <PgUp>                  PageUp()
    <PgDn>                  PageDown()
    <Home>                  BegFile()
    <End>                   EndFile()
end

proc mGotoClip()
    start_id = GetBufferId()
    normal_text_attr = Query(TextAttr)
    normal_cursor_attr = Query(CursorAttr)
    normal_EOF_attr = Query(EOFMarkerAttr)
    normal_status_attr = Query(StatusLineAttr)
    if not GotoBufferId(special_clip)
        Message('Clipboard not created yet')
        return()
    else
        Set(TextAttr, clip_text_attr)
        Set(EOFMarkerAttr, clip_EOF_attr)
        Set(CursorAttr, clip_cursor_attr)
        Set(StatusLineAttr, clip_status_attr)
        BegFile()
        mClipMsg()
        Hook(_AFTER_COMMAND_, mClipMsg)
        Enable(clip_keys, _EXCLUSIVE_)
    endif
end

menu LineProMenu()
      Title = "LinePro"
      history
      x = 80
      y = 24

     "Cut &Blanks"           , LinePro('cut blanks','')        ,
                             , 'Delete blank lines'
     "Cut &Extra"            , LinePro('cut extra','')         ,
                             , 'Delete extra blank lines'
     "Cut &Dupes"            , LinePro('cut dupes','')         ,
                             , 'Delete duplicate lines'
     "Cut &String"           , LinePro('cut string','')        ,
                             , 'Delete lines containing string'
     "Cut &List"             , LinePro('cut list','')          ,
                             , 'Delete lines containing ANY string in list'
     "&Keep String"          , LinePro('keep string','')       ,
                             , 'Keep only lines containing string'
     "Keep Lis&t"            , LinePro('keep list','')         ,
                             , 'Keep only lines containing ALL strings in list'
     "D&ouble Space"         , LinePro('double space','')      ,
                             , 'Insert blank lines between existing lines'
     "&Insert String"        , LinePro('insert string','')     ,
                             , 'Insert string at cursor column (or left edge of Column block)'
     "&Append String"        , LinePro('append string','')     ,
                             , 'Append string at end of line'
     "&Number lines"         , LinePro('number lines','')      ,
                             , 'Insert line numbers at cursor column (or left edge of Column block)'
     "&Flush to cursor"      , LinePro('flush','')             ,
                             , 'Shift line, first character to cursor column'
     "Squee&ze"              , LinePro('squeeze','')           ,
                             , 'Remove extra blank characters'
     "clipboard"             ,                                  , Divide
     "&Mode"
      [ModeStr(clip_mode):6] , mToggleAppend()                  , dontclose
                             , 'Toggle append/overwrite'
     "&Go to clipboard"      , mGotoClip()                      ,
                             , 'Look at clipboard contents'
     "&Paste"                , mSpecialPaste()                  ,
                             , 'Insert contents of clipboard at current line'
     "s&Wap"                 , mSwap()                      ,
                             , 'Swap contents of current file with that of clipboard'
     ""                      ,                                  , Divide
     "&Help"                 , QuickHelp(descrip)               , dontclose
end

// Comment out the following lines to use in another macro via #include
proc Main()
    LineProMenu()
end
