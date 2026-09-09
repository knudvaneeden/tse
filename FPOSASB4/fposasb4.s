/**********************************************************************\

  FPosAsB4 This macro saves the screen and cursor position
           whenever unloading a file and restores this info
           when the file is reloaded.

  Author   Steven Saunderson <StevenSaunderson@nlc.net.au>

  Date     2001-05-08

  Notes    This macro should be included in the AutoLoad list.
           PersistentHistory must be enabled.
           MaxHistoryPerList determines max saved entries.

           'ListID' must be from 1 to 127 (TSE requirement).
           'sep'    must not appear in a file name.

\**********************************************************************/

  integer       ListID = 127                    // history sub-list ID
  string        sep [1] = Chr (0x10)            // field separator

/*************************************************************\
*
*       When file loaded, restore screen and cursor pos.
*
\*************************************************************/

proc OnFirstEdit ()
  integer       i, len, lyn, col
  string        fn [240], s [255]

  fn = CurrFilename ()
  for i = 1 to NumHistoryItems (ListID)
    s = GetHistoryStr (ListID, i)
    len = Pos (sep, s) - 1
    if (len > 0) and (fn == SubStr (s, 1, len))         // if wanted entry
      s = SubStr (s, (len + 2), 40)
      lyn = val  (s)
      len = Pos  (sep, s)
      s = SubStr (s, (len + 1), 40)
      col = val  (s)
      len = Pos  (sep, s)
      s = SubStr (s, (len + 1), 40)
      GotoRow    (val (s))
      GotoLine   (lyn)
      GotoColumn (col)
      break
    endif
  endfor
end

/*************************************************************\
*
*       Save the name and current pos of the current file.
*
\*************************************************************/

integer proc FileInfoSave (integer items)
  integer       i, len, lyn, col, row
  string        fn [240], s [255]

  if (items < 0)                                // -1 = calc count
    items = NumHistoryItems (ListID)            // scan takes time
  endif
  fn = CurrFilename ()
  i = 1
  while (i <= items)                            // delete any old ent(s)
    s = GetHistoryStr (ListID, i)
    len = Pos (sep, s) - 1
    if (len < 1) or (fn == SubStr (s, 1, len))
      DelHistoryStr (ListID, i)
      items = items - 1
    else
      i = i + 1
    endif
  endwhile
  lyn = CurrLine ()
  col = CurrCol  ()
  row = CurrRow  ()
  if (lyn + col + row > 3)                      // record if pos not BOF
    AddHistoryStr (Format (fn, sep, lyn, sep, col, sep, row), ListID)
    if (items < Query (MaxHistoryPerList))      // maybe inc count
      items = items + 1
    endif
  endif
  return (items)
end

/*************************************************************\
*
*       When file quit, save current pos.
*
\*************************************************************/

proc OnFileQuit ()
  FileInfoSave (-1)
end

/*************************************************************\
*
*       When closing, save current pos for each file.
*
\*************************************************************/

proc OnClosing ()
  integer       files, items

  Message ("Writing...")                                // pacifier msg
  files = NumFiles () + (BufferType () <> _NORMAL_)
  items = -1                                            // -1 = calc count
  do files times
    NextFile (_DONT_LOAD_)
    items = FileInfoSave (items)
  enddo
end

/*************************************************************\
*
*       Load our hooks.
*
\*************************************************************/

proc WhenLoaded ()
  Hook (_ON_FIRST_EDIT_,  OnFirstEdit)          // restore pos on load
  Hook (_ON_FILE_QUIT_,   OnFileQuit)           // save pos on quit
  Hook (_ON_EXIT_CALLED_, OnClosing)            // save all on close
end

