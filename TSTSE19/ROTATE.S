/* Copy a column as a block, or vice versa for SemWare's TSE editor
   V2.5. To make this SAL macro operational, invoke the main menu
   (F10), choose "Macro", choose "Compile" and press Enter at
   "Execute Macro".

....................................................................
Prof. Timo Salmi   Co-moderator of news:comp.archives.msdos.announce
Moderating at ftp:// & http://garbo.uwasa.fi archives  193.166.120.5
Department of Accounting and Business Finance  ; University of Vaasa
mailto:ts@uwasa.fi  <URL:http://uwasa.fi/~ts>  ; FIN-65101,  Finland
*/

// The contents of a simple help, tied later to the CtrlAlt-H key
helpdef tHelpData
  title = "ROTATE.S HELP"         // The help's caption
  x = 10                          // Location
  y = 3
  // The actual help text
  " Prof. Timo Salmi's column to row or vice versa "
  ""
  " Makes a single column a row or a single row a "
  ' column. In the latter e.g. a "Timo" would be '
  " copied at the cursor location as "
  "   T"
  "   i"
  "   m"
  "   o"
  ""
  " A third macro option is reversing a text. "
  ""
  " First mark the target block to be copied as a "
  " column block. "
  ""
  " You can use <F11> to invoke the command menu "
  " after first exiting this help. "
  ""
  " Last updated Tue 27-February-1996 22:22:21 "
end tHelpData

proc timoRotateColToRow()
  string s[255] = ''
  integer i = 0
  //
  if not (isBlockInCurrFile() == _COLUMN_)
    Warn('No column block in the current window')
  else
    PushPosition()
    GotoBlockBegin()
    //
    // Check that the width is only 1
    Right()
    if isCursorInBlock()
      Warn('The maximum block width is 1 for this operation')
      PopPosition()
      return()
    endif
    //
    // Read the column, then write it rotated
    GotoBlockBegin()
    repeat
      i = i + 1
      if i > 255
        Warn('Block too long')
        PopPosition()
        return()
      endif
      s = s + Chr(CurrChar())
    until not Down() or not isCursorInBlock()
    PopPosition()
    InsertText(s,_INSERT_)
  endif
end timoRotateColToRow

proc timoRotateRowToCol()
  string s[255] = ''
  integer i = 0
  integer p
  integer atBottom = false
  //
  if not (isBlockInCurrFile() == _COLUMN_)
    Warn('No column block in the current window')
  else
    PushPosition()
    //
    // Check that the height is only 1
    GotoBlockBegin()
    if Down()
      if isCursorInBlock()
        Warn('The maximum block height is 1 for this operation')
        PopPosition()
        return()
      endif
    endif
    //
    // Read the row, then write it rotated
    PopPosition()
    PushPosition()
    s = GetMarkedText()
    p = Length(s)
    repeat
      i = i + 1
      InsertText(s[i])
      Left()
      if Down()
        atBottom = false
      else
        atBottom = true
      endif
    until (i >= p) or atBottom
    PopPosition()
  endif
  //
  // Was the block truncated
  if atBottom
    Warn('Bottom of file encountered, block will be truncated')
  endif
end timoRotateRowToCol

proc timoReverseBlock()
  string s[255] = ''
  integer i = 0
  integer p
  //
  if not (isBlockInCurrFile() == _COLUMN_)
    Warn('No column block in the current window')
  else
    PushPosition()
    //
    // Check that the height is only 1
    GotoBlockBegin()
    if Down()
      if isCursorInBlock()
        Warn('The maximum block height is 1 for this operation')
        PopPosition()
        return()
      endif
    endif
    //
    // Read the row, then write it reversed
    PopPosition()
    PushPosition()
    s = GetMarkedText()
    p = Length(s)
    repeat
      i = i + 1
      InsertText(s[i])
      Left()
    until i >= p
    PopPosition()
  endif
end timoReverseBlock

// New keys and menus **************************************************
forward Menu timoRotateMenu()
forward proc tDisableNewKeys()

// Add the new key definitions
keydef new_keys
  <CtrlAlt 5>      timoRotateColToRow()
  <CtrlAlt 6>      timoRotateRowToCol()
  <CtrlAlt 7>      timoReverseBlock()
  <CtrlAlt 0>      tDisableNewKeys()
  <CtrlAlt H>      QuickHelp(tHelpData)
  <F11>            timoRotateMenu()
end

// Disabling the new extra keys ***************************************
proc tDisableNewKeys()
  if YesNo("Disable the extra keys:") == 1 Disable(new_keys) endif
end

// The rotate menu ****************************************************
Menu timoRotateMenu()
  Title = "Timo's rotate menu"
  Width = 19
  x = 40
  y = 3
  history
  "&Column to row     <CtrlAlt 5>"   , timoRotateColToRow()
  "&Row to column     <CtrlAlt 6>"   , timoRotateRowToCol()
  "Reverse &block     <CtrlAlt 7>"   , timoReverseBlock()
  "",,Divide
  "Disable &new keys  <CtrlAlt 0>"   , tDisableNewKeys()
  "&Help              <CtrlAlt H>"   , QuickHelp(tHelpData)
  "This Menu         <F11>"
end timoRotateMenu

proc Main()
  Enable (new_keys)
  timoRotateMenu()
end
