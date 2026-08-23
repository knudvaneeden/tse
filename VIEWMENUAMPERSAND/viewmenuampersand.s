// author: Steve Kraus
//
// version 1.0.0.0.0
//
// usage: put the cursor inside TSE SAL source code and run this program. It will show the ampersand hotkey entries.
//
// ShowQuickKey() assists in TSE menu development by showing a list of
// all the quick-keys inside a given SAL menu sorted in order.
// Execute with cursor positioned inside a menu, select a menu line
// from the list, and it leaves the cursor on the quick-key
// This helps the macro writer choose mnemonic quick-keys for menus

string QuickKeyBuf_S[] = "<QuickKey>" // name of temp buffer

proc ShowQuickKey ()
   integer ILn                    // first line number in menu
   integer LLn = 0                // last menu line number or 0 if none
   integer iP                     // start of option string or 'menu'
   integer nP                     // number of chars in option string
   integer L_Width = 15           // width of popup list
   integer L_Height = 0           // height of popup list
   integer List_buf               // list view buffer
   integer iCurrLine              // line number from menu
   string QuickKey[2]             // "&C" quick key for option string
   string MenuLine[255]           // option string in menu

// Set iLfn and iP to line and position of "menu" line before cursor
   PushPosition ()
   EndLine ()
   if lFind (" @menu ", "^XBI")
      ILn = CurrLine ()           // line number of "menu"
      iP = CurrPos ()             // column position for indentation

// Allocate a buffer for listing, reuse existing buffer if found
      List_buf = GetBufferID (QuickKeyBuf_S)
      if List_buf
         EmptyBuffer (List_buf)
      else
         PushPosition ()
         List_buf = CreateBuffer (QuickKeyBuf_S, _HIDDEN_)
         PopPosition ()
      endif
      if List_buf == 0
         Warn ("Could not create"; QuickKeyBuf_S; "buffer")
         PopPosition ()
         return ()
      endif

// Look for "end" line matching "menu" indentation & set LLn
      while not LLn and lFind ("end", "+WI")
         if iP == CurrPos ()
            LLn = CurrLine ()
         endif
      endwhile
      if LLn == 0
         Warn ("No menu 'end' found")
         PopPosition ()
         return ()
      endif

// Search thru menu looking for ampersand, '&' inside double quotes '"'
      GotoLine (ILn + 1)
      PushBlock ()
// While finding '&' in center of a " " strong & before menu end at LLn
      while lFind ('".*&.*"', "X+") and CurrLine () < LLn
// iP = first column of menu quote string, nP to length of menu string
         MarkFoundText ()
         iP = CurrPos ()
         nP = 1 + Query (BlockEndCol) - Query (BlockBegCol)
// Find '&' inside a menu string. Store quick key string in QuickKey
         lFind ("&", "+C")
         QuickKey = GetText (CurrPos (), 2)
// If "&&" found in option string, ignore & find the next '&' quick key
         if QuickKey == "&&" and Right () and lFind ("&", "+C")
            QuickKey = GetText (CurrPos (), 2)
         endif
// Format option string:  "&Q  Option String &Quick key"
// Count height and width of option string for List buffer
         MenuLine = Format (QuickKey, "  ", GetText (iP, nP) )
         L_Width = Max (L_Width, (4 + nP) ) // menu string width+4 char
         L_Height = L_Height + 1  // height of popup list
// Add current line number to column 240 of List buffer line
// List buffer line format:  "&Q  Option String &Quick key"
//                               ...spaces...   136"
         MenuLine = Format (MenuLine, " " : 239-Length (MenuLine) : ' '
                             , CurrLine () )
         AddLine (MenuLine, List_buf)  // add to List buffer
      endwhile

// Switch to List buffer and mark column containing Quick Keys
// Sort the List buffer ascending order ignoring case
      PushPosition ()
      GotoBufferID (List_buf)
      MarkColumn (1, 1, NumLines (), 2)
      Sort (_IGNORE_CASE_)
// Position List window at the right margin
      if L_Width < (Query (ScreenCols) - 2)
         Set (X1, Query (ScreenCols) - 2 - L_Width)
      endif
// List the buffer. If selected with Enter jump to the line number
      GotoLine (L_Height / 2)     // start at line half-way up buffer
      if lList ("Menu Quick Keys", L_Width, L_Height
               , _ENABLE_SEARCH_ | _BLOCK_SEARCH_)
         if CurrLineLen () > 240
            iCurrLine = Val (GetText (240, 6) ) // line number from menu
         endif
      else                        // user pressed Esc
         iCurrLine = 0            // no menu line selected
      endif
      PopPosition ()              // back into buffer containing menu
      PopBlock ()
   else
      Warn ("Not inside a menu")
   endif

// iCurrLine is set if user selected menu line, else PopPosition
   if iCurrLine                   // if line number to jump
      KillPosition ()
      GotoLine (iCurrLine)
      lFind ('".@&\c..@"', "XCG") // position cursor at quick key
   else
      PopPosition ()
   endif
end  ShowQuickKey


proc Main ()
   Message ("<CtrlAltShift Q>  inside a menu shows quick-key list")
   ShowQuickKey()
   GotoBufferId (GetBufferId (QuickKeyBuf_S) )
end Main

<CtrlAltShift Q>  ShowQuickKey ()
// <CtrlAltShift G>  GotoBufferId (GetBufferId (QuickKeyBuf_S) )
