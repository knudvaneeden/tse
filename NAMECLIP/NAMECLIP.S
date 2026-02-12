/****************************************************************************
                       TSE Named Clipboard System
 ****************************************************************************
                              Version 4.8
                    Copyright: (c) 1993 David Marcus

                  See nameclip.doc for ... everything.

 v 4.8 fixes a bug with PasteOverWrite and UnNamed Clipboards

/**************************************************************************
          þ Variable & Constant Declarations
 **************************************************************************/

CONSTANT
     /* for operation */
     COPY_OVERWRITE      = 10,           // NOTE: The order of these is
     COPY_APPEND         = 20,
     CUT_FILL_WITH_BLANKS= 25,
     CUT_OVERWRITE       = 30,           // use checks such as
     CUT_APPEND          = 40,           //   "IF FOO >= PASTE_APPEND ..."
     GETTING_FROM_FILE   = 50,           // GETTING from file
     PASTE_APPEND        = 60,
     PASTE_OVERWRITE     = 70,
     DELETE              = 80,
     VIEW                = 90,
     PRINT               = 95,
     RENAME              = 100,
     EDIT                = 110,

     /* for backup types */
     ADDITIVE = 2,
     NORMAL = 0,
     MAKING_BACKUP = 1,

     /* for clipboard_type */
     UNNAMED = 0,
     NAMED = 1,
     WINDOWS = 2,

     /* arg for toggles */
     REPORT_STATUS = 0,
     CHANGE_STATUS = 1,

     /* for add_clipboard_to_list */
     CURRENT = 0,

     /*  for post_paste_position */
     BEGINNING = 0,
     AT_END = 1,

     /*  for find_in_clipboard */
     DONT_QUERY = 0,
     QUERY_IT = 1,

     /* coordinates for menu */
     menuX = 3,                              // left side
     menuY = 3                               // top line

STRING
     backup_str[5] = '®BAK¯',                // :U: string prepended to buffer
                                             //     name for backups. Must end
                                             //     with other than a space.
     buffer_flag[20]='®clipboard start¯',    // :U: Separates buffers in
                                             //     saved file
                                             //     Arbitrary, but unique
     saveclipfilename[64]='!clipbrd.sav',    // :U: default file name
     clipboard_text[51]='',                  // added to viewing list
     clipboard_name[33] = '',                // name of each buffer
     selected_clipboard_name[33] = '',       // for rename and backup
     new_option[43] = '® new clipboard ¯',   // :U: Text added to top of list
     search_phrase[70],                      // for find_in_clipboard
     options[10],
     msg[33]=''

INTEGER
     use_picklists = TRUE,                   // :U: TRUE, FALSE
     backup_type = ADDITIVE,                 // :U: ON, OFF, ADDITIVE
     clipboard_type =   NAMED,               // :U: NAMED, UNNAMED, WINDOWS
     textflag = TRUE,                        // :U: include text on picklist?
                                             //     TRUE, FALSE
     auto_naming = OFF,                      // :U: use beginning of block
                                             //     as clipboard name
     unmark_flag = FALSE,                    // :U: unmark after copy
                                             //     TRUE, FALSE
     post_paste_position= AT_END,            // :U: just what it says!
                                             //     BEGINNING, AT_END
     delete_after_paste = FALSE,             // :U: just what it says!
                                             //     TRUE, FALSE
     bid_width = 5,                          // chars allocated for bufferid
     original_clip_ID,                       // original TSE clipboard ID
     buffer_to_use,                          // current named clipboard
     clipblocktype,                          // block type for current clipboard
     sid,                                    // starting buffer
     prompt_hist = 0,                        // history
     clip_list_ID = 0,                       // buffer clipboard name list
     max_width = 78,
     operation,                              // menu-selected operation
     lines,                                  // placekeeper for edit
     rows,                                   // placekeeper for edit
     counter,                                // for counting WITHIN a proc
     MSGL,                                   // to hold starting msglevel
//   ILBA,                                   //    insertlinesabove
     KM,                                     //    killmax
     UMAP                                    //    UnMarkAfterPaste

/**************************************************************************
          þ Forward Proc & Menu Declarations
 **************************************************************************/
forward proc                  add_contents_to_list()
forward proc                  add_clipboard_to_list(INTEGER type)
forward proc                  backup_clipboard()
forward integer proc          check_for_abort()
forward integer proc          count_buffer_lines(integer xid)
forward menu                  clipboardmenu()
forward proc                  clipboard(integer Action)
forward menu                  clipboard_global_menu()
forward menu                  clipboard_other_menu()
forward menu                  clipboard_settings_menu()
forward proc                  cut_and_blank_fill()
forward integer proc          delete_all_named_clipboards()
forward integer proc          delete_named_clipboard(integer xmode)
forward keydef                edit_keys
forward proc                  edit_named_clipboard()
forward string  proc          expanded_id()
forward proc                  expand_clipboard_name()
forward proc                  find_in_clipboard(integer xmode)
forward integer proc          get_buffer_number_from_list()
forward integer proc          get_clipboard_block_type()
forward proc                  get_clips_from_file()
forward string proc           get_name_from_id()
forward integer proc          if_clipboard_list_exists()
forward integer proc          list_clipboards()
forward proc                  mark_according_to_clipblocktype()
forward proc                  mark_ids()
forward proc                  mark_names()
forward integer proc          named_clipboard()
forward integer proc          paste_over()
forward proc                  pop_message( string title, integer mattr, integer xdelay )
forward proc                  print_named_clipboard()
forward proc                  print_string(STRING text)
forward proc                  rename_clipboard()
forward proc                  rename_it(STRING old_name, STRING new_name)
forward string proc           repl_char(string find_string, string repl_string, var string target)
forward proc                  save_clipboards_to_file()
forward proc                  setup_list_buffer()
forward proc                  set_clipblocktype()
forward proc                  sort_clip_list_by_name()
forward integer proc          store_name_on_clip_list(integer store_mode)
forward proc                  tahggle(var integer arg)
forward string proc           toggle_back_type(integer arg)
forward string proc           toggle_clip_type(integer arg)
forward proc                  toggle_textflag()
forward proc                  trim_clipboard_name()
forward proc                  view_named_clipboard()
forward proc                  x(integer arg)

/****************************************************************************
          þ KEY DEFS
****************************************************************************/
/* MENUS */

<f11>          clipboardmenu()
<Ctrl F11>     clipboard_other_menu()
<Shift F11>    clipboard_settings_menu()
<Alt F11>      clipboard_global_menu()

/* OPERATIONS */
<Grey*>        clipboard( PASTE_APPEND )
<Ctrl Grey*>   clipboard( Paste_OVERWRITE )
<Ctrl PrtSc>   clipboard( Paste_OVERWRITE )
<Grey+>        clipboard( Copy_OverWrite )
<Ctrl Grey+>   clipboard( Copy_APPEND )
<Grey->        clipboard( Cut_OverWrite )
<Ctrl Grey->   clipboard( Cut_APPEND )
<Alt Grey->    clipboard( Cut_FILL_WITH_BLANKS )

/* DAVID'S DIAGNOSTICS */
//<alt F5>  markstream()
//<alt f6>  PushPosition() GotoBufferid(clip_list_ID) list('',80) PopPosition()
//<alt f7>  warn(getclipboardid())


/**************************************************************************
          þ Code
 **************************************************************************/

/****************************************************************************
     ADD_CONTENTS_TO_LIST()
          Adds opening contents of buffer to the clipboard list buffer
***************************************************************************/
proc                          add_contents_to_list()
     clipboard_text = ' º '
     PushPosition()
     GotoBufferID(buffer_to_use)
     Begfile()
     while Length(clipboard_text) < (SizeOf(clipboard_text)-3)
          if PosLastNonWhite() == 0     // skip line if blank
               if not Down()
                    goto ending         // breaks out of while
               endif
          else                          // add line break indicator
               if Length(clipboard_text) > 3
                    clipboard_text = clipboard_text + ' ³ '
               endif
               clipboard_text = clipboard_text + GetText( PosFirstNonWhite(),
                              PosLastNonWhite() - PosFirstNonWhite() + 1 )
               if not Down()
                    goto ending
               endif
          endif
     endwhile
   ending:
     GotoBufferID(clip_list_ID)
     if not lFind(expanded_id(), '^g')
          warn('hmmmmm....')
     endif
     GotoPos(bid_width + sizeof(clipboard_name) + 2)
     DeltoEol()
     InsertText(clipboard_text, _OverWrite_)
     PopPosition()
end

/****************************************************************************
     ADD_CLIPBOARD_TO_LIST()
          Adds an entry to the clip_list buffer
          Argument of CURRENT (0) - proc Sets clipblocktype to current
          Otherwise, it is Set to argument
 ****************************************************************************/
proc                          add_clipboard_to_list(INTEGER xmode)
     if isblockmarked() == 0 and
          xmode == CURRENT
               xmode = get_clipboard_block_type()  // just in case
     endif
     PushPosition()
     GotoBufferID(clip_list_ID)
     Begfile()
     AddLine( expanded_id()+
              Str(iif( xmode==CURRENT, isblockmarked(), clipblocktype ))
              + clipboard_name )
     PopPosition()
end

/****************************************************************************
     COUNT_BUFFER_LINES(INTEGER ID)
          returns the number of lines in buffer ID
 ***************************************************************************/
integer proc                  count_buffer_lines(integer id)
     PushPosition()
     if GotoBufferID(id) and (NumLines() > 1 or CurrLineLen())
          PopPosition()
          return(NumLines())
     else
          PopPosition()
          return(0)
     endif
     return(TRUE)
end

/****************************************************************************
     BACKUP_CLIPBOARD()
          This is the macro that handles backup before cut and copy.
****************************************************************************/
proc                          backup_clipboard()
     integer
          selected_clipboard = 0,
          backup_of_clipboard = 0,
          SCBID = GetClipBoardID()

     if backup_type and count_buffer_lines(buffer_to_use)   // if there are
          PushPosition()                                    // contents
          set_clipblocktype()                          // Sets type
          selected_clipboard = buffer_to_use           // stores buffer id
          selected_clipboard_name = clipboard_name     // stores name
          clipboard_name = backup_str + clipboard_name // Setup .bak name
          store_name_on_clip_list(MAKING_BACKUP)       // Sets buffer_to_use
                                                       // to .bak buffer
          backup_of_clipboard = buffer_to_use
          GotobufferID(selected_clipboard)
          SetClipBoardID(backup_of_clipboard)           // backup ID
          mark_according_to_clipblocktype()
          if backup_type <> ADDITIVE              // if not additive
               Copy()
          else
               Copy(_APPEND_)
          endif
          PopBlock()
          BegFile()
          buffer_to_use = backup_of_clipboard
          add_contents_to_list()
          buffer_to_use = selected_clipboard          // reSet for the copy/cut
          clipboard_name = selected_clipboard_name     //     from the text file
          PopPosition()
          SetClipBoardID( SCBID)
     endif
end

/**************************************************************************
     CHECK_FOR_ABORT()
 **************************************************************************/

integer proc                  check_for_abort()
     if KeyPressed() AND GetKey() == <escape>
          PushKey(<enter>)              // bypasses 'press any key'
          return(TRUE)                  // Avoid going back to where
     endif                              // check_for_abort was called
     return(FALSE)
end

/****************************************************************************
     CLIPBOARD(INTEGER ACTION)
          This macro handles unnamed and windows clipboard operations.
          It branches to named_clipboard() for named clipboard ops.
          It also takes care of the UnMarkAfterPaste operation, if Set,
               for all clipboard types.
****************************************************************************/
proc                          clipboard(integer Action)
    operation = action                 // Set global integer with action
    if clipboard_type == 2 AND (NOT IsMacroLoaded('winclip'))
        LoadMacro('winclip')
    endif


    if operation == PASTE_APPEND or
       operation == PASTE_OVERWRITE
          UMAP = set(UnMarkAfterPaste,FALSE)  // This allows us our choice
          if UMAP                             // of beg/end block after paste
               PushBlock()
          endif
     endif

    case clipboard_type
        when NAMED
               if if_clipboard_list_exists() == -99999
                    return()
               else
                    named_clipboard()
               endif
        when UNNAMED
             case action
                 when COPY_OVERWRITE    x(1) Copy() x(2)
                 when COPY_APPEND       x(1) Copy(_APPEND_)  x(2)
                 when PASTE_APPEND      Paste()
                 when PASTE_OVERWRITE   paste_over()
                 when CUT_FILL_WITH_BLANKS
                                        cut_and_blank_fill()
                 when CUT_OVERWRITE     Cut()
                 when CUT_APPEND        Cut(_APPEND_)
             endcase
         when WINDOWS
             case action
                 when COPY_OVERWRITE    x(1) Copy() ExecMacro('CopytoWindows') x(2)
                 when CUT_FILL_WITH_BLANKS
                                        cut_and_blank_fill()
                 when COPY_APPEND       message('Cannot APPEND to Windows clipboard')
                 when PASTE_APPEND      ExecMacro('PasteFromWindows') Paste()
                 when PASTE_OVERWRITE   message('Cannot OVERWRITE from Windows clipboard')
                 when CUT_OVERWRITE     Cut() ExecMacro('CopytoWindows')
                 when CUT_APPEND        message('Cannot APPEND to Windows clipboard')
             endcase
     endcase

     if (action == PASTE_APPEND) OR
        ((action == PASTE_OVERWRITE) AND (clipboard_type <> WINDOWS))
          if post_paste_position == BEGINNING
               GotoBlockBegin()
          else
               GotoBlockEnd()
          endif
     endif

    if operation == PASTE_APPEND or
       operation == PASTE_OVERWRITE
         if UMAP
               PopBlock()
         endif
         set(UnMarkAfterPaste,UMAP)
     endif

     if Query(UnMarkAfterPaste) and (action == PASTE_APPEND OR
                                     action == PASTE_OVERWRITE)
        PopBlock()
     endif

    // Done
    return ()
end

/****************************************************************************
     CLIPBOARDMENU()
****************************************************************************/
menu                          clipboardmenu()
          History
          Title = ' ClipBoard Menu '
          X = menuX
          Y = menuY
    "&Copy"             ,   clipboard( COPY_OVERWRITE ) , CloseAllBefore
    "Copy &Append"      ,   clipboard( COPY_APPEND )    , CloseAllBefore
    ""                  ,                                           , Divide
    "C&ut"              ,   clipboard( CUT_OVERWRITE )  , CloseAllBefore
    "Cu&t Append "      ,   clipboard( CUT_APPEND )     , CloseAllBefore
    "Cut && &Blank Fill",   clipboard( CUT_FILL_WITH_BLANKS)
                                                        , CloseAllBefore
    ""                  ,                               , Divide
    "&Paste"            ,   clipboard( PASTE_APPEND )   , CloseAllBefore
    "Paste &Over"       ,   clipboard( PASTE_OVERWRITE ), CloseAllBefore
    ""                  ,                               , Divide
    "Other &Functions " ,  Clipboard_other_menu()      , DontClose
    ""                  ,                               , Divide
    "&Global Actions " ,   clipboard_global_menu()      , DontClose
    ""                  ,                               , Divide
    "&Settings "       ,   Clipboard_Settings_Menu()   , DontClose
end

/****************************************************************************
     CLIPBOARD_OTHER_MENU()
****************************************************************************/
menu                          clipboard_other_menu()
      History
      Title = ' Other ClipBoard Functions '
      x = menuX + 10
      y = menuY + 15
    "&View/Edit Named Clipboard"
                        ,   view_named_clipboard()      , CloseAllBefore
    "&Print Clipboard"
                        ,   print_named_clipboard()     , DontClose
    "&Rename Clipboard" ,   rename_clipboard()          , DontClose
    "&Delete Named Clipboard"
                        ,   delete_named_clipboard(0)   , DontClose
    "&Find String in Clipboard"
                        ,   find_in_clipboard(QUERY_IT) , DontClose
    "Find &Again"
                        ,   find_in_clipboard(DONT_QUERY)
                                                        , DontClose
    ""                  ,                               , Divide
    "&Global Actions " ,   clipboard_global_menu()     , DontClose
    ""                  ,                               , Divide
    "&Settings "       ,   Clipboard_Settings_Menu()   , DontClose
end

/****************************************************************************
     CLIPBOARD_GLOBAL_MENU()
****************************************************************************/
menu                          clipboard_global_menu()
          History
          Title = ' ClipBoard Global Actions '
          x = menuX + 20
//        y = menuY + 16
    "&Fill Clipboards From File",     get_clips_from_file()         , DontClose
    "&Save All Clipboards to a File", save_clipboards_to_file()     , DontClose
     ""                 ,                                           , Divide
    "&Delete All Named Clipboards"
                        ,   delete_all_named_clipboards()           , DontClose
end

/****************************************************************************
     CLIPBOARD_SETTINGS_MENU()
****************************************************************************/
menu                          clipboard_settings_menu()
      History
      Title = ' ClipBoard Settings '
      x = menuX + 10
      y = menuY + 15

     "Clipboard &Type"    [toggle_clip_type(REPORT_STATUS):7] ,
          toggle_clip_type(CHANGE_STATUS)                        , DontClose
     "Use &Picklists"             [iif(use_picklists, 'Yes', 'No') : 3],
          tahggle(use_picklists)                                 , DontClose
     "&Include Text on Picklists" [ iif(textflag,'Yes', 'No') : 3] ,
          tahggle(textflag)                                      , DontClose
     "Use &Auto Naming"           [ iif(auto_naming,'Yes', 'No') : 3] ,
          tahggle(auto_naming)                                      , DontClose
      ""                                                ,        , Divide
     "&Backup Clipboards" [toggle_back_type(REPORT_STATUS):8] ,
          toggle_back_type(CHANGE_STATUS)                        , DontClose
     ""                                                ,         , Divide
     "Use Curr &Line If No Block" [iif(Query(UseCurrLineIfNoBlock),'Yes', 'No') : 3] ,
          toggle(UseCurrLineIfNoBlock)                           , DontClose
     "&UnMark After Copy"[ iif(unmark_flag,'Yes', 'No') : 3] ,
          tahggle(unmark_flag)                                   , DontClose
     ""                                                        , , Divide
     "U&nMark After Paste"[iif(Query(UnMarkAfterPaste),'Yes', 'No') : 3] ,
          toggle(UnMarkAfterPaste)                               , DontClose
     "&Delete After Paste"[ iif(delete_after_paste,'Yes', 'No') : 3] ,
          tahggle(delete_after_paste)                            , DontClose
     "P&osition After Paste"  [iif(post_paste_position==BEGINNING, 'Beginning', 'End') : 9] ,
          tahggle(post_paste_position)                           , DontClose
end

/****************************************************************************
     CUT_AND_BLANK_FILL()
          Copies block to clipboard and fills its previous location
          with spaces.
****************************************************************************/
proc                          cut_and_blank_fill()
     x(1)
     PushBlock()
     if clipboard_type == WINDOWS
            ExecMacro('CopytoWindows')
     else
            Copy()
     endif
     PopBlock()
     FillBlock(" ")
     GotoBlockBegin()
     x(2)
end

/****************************************************************************
     DELETE_NAMED_CLIPBOARD(INTEGER xMODE)
          Deletes all named clipboards
               mode = 0 for all operations except
               mode = 1 when deleting after Paste
 **************************************************************************/
integer proc                  delete_named_clipboard(integer xmode)
     integer original_clipboard_id = getclipboardID()
     sid = getbufferid()
     operation = DELETE
     KM = set(KillMax, 0)
     msg = 'Delete clipboard:'

     PushPosition()
     if if_clipboard_list_exists() == -99999
          return(-99999)
     else
          GotoBufferID( if_clipboard_list_exists() )
     endif

     if xmode == 0
          list_clipboards()                        // Set buffer_to_use
     endif

     GotoBufferID(sid)
     warn(buffer_to_use, original_clipboard_id)
     if buffer_to_use == original_clipboard_id
          msg="Can't delete system clipboard"
          pop_message('', Query(MsgAttr), 18)
          goto endit
     elseif buffer_to_use
          if GotoBufferID( if_clipboard_list_exists() )
               mark_ids()
               if lFind(expanded_id(), 'glin')
                    DelLine()
                    if CurrLine() > NumLines()
                         Up()
                    elseif NumLines() == 1 and CurrLineLen() == 0
                         AbandonFile()
                         clip_list_ID = 0
                    endif

                    if GotoBufferID(buffer_to_use)
                         AbandonFile()
                    else
                         warn('Err 3')       // got buffer id but Goto
                         halt                   // failed
                    endif
               else
                    warn('Err 4')           // got id but can't find
                    halt
               endif
          else
               warn('whaaaa')
               halt
          endif
     endif
     PopBlock()
     endit:
     PopPosition()
     Set(KillMax, KM)
     Return(TRUE)
end

/****************************************************************************
     GET_NAME_FROM_ID()
          Helper to get name
****************************************************************************/
string proc                   get_name_from_id()
     PushPosition()
     GotoBufferID(clip_list_ID)
     lFind(expanded_id() , '^g')
     clipboard_name = GetText(bid_width+2, PosLastNonWhite())
     PopPosition()
     return(clipboard_name)
end

/****************************************************************************
     DELETE_ALL_NAMED_CLIPBOARDS()
***************************************************************************/
integer proc                  delete_all_named_clipboards()
     integer
          id
     KM = Set(KillMax,0)
     sid = getbufferid()
     if if_clipboard_list_exists() == -99999
          msg = 'No named clipboards exist'
          pop_message( '', Query(MsgAttr), 18 )
          return(-99999)
     else
          GotoBufferID( if_clipboard_list_exists() )
     endif
     Begfile()
     if NumLines() > 1
          GotoLine(2)
          while NumLines() >= CurrLine() AND CurrLineLen() > 0
               buffer_to_use = get_buffer_number_from_list()
               msg = get_name_from_id()
               pop_message('Deleting...', Query(MsgAttr), 12)
               AbandonFile(get_buffer_number_from_list())
               DelLine()
          endwhile
     endif
     AbandonFile()
     clip_list_id = 0
     GotoBufferid(sid)
     Set(KillMax,KM)
     Return(TRUE)
end

/****************************************************************************
     KEYDEF EDIT_KEYS
****************************************************************************/
keydef                        edit_keys
     <escape>                 BegFile()
                              EndProcess()
                              Message('Done editing')
                              Delay(10)
end

/****************************************************************************
     EDIT_NAMED_CLIPBOARD()
****************************************************************************/
proc                          edit_named_clipboard()
     integer this_old_house,
             temp_id,
             SCBID = GetClipBoardID()
     KM = Set(KillMAX,0)
     Set(break, ON)
     operation = EDIT
     if buffer_to_use
          clipboard_name = get_name_from_ID()
          trim_clipboard_name()
          temp_id = CreateBuffer(clipboard_name+'¯CLP')
          this_old_house = buffer_to_use
          set_clipblocktype()                          // Sets clip block type to
          SetClipBoardID(this_old_house)
          PushBlock()
          Paste()
          PopBlock()
          GotoLine(lines)
          ScrollToRow(rows)
          Set(KillMax,KM)               // restore kill buffer use
          enable(edit_keys)
          process()                     /* editing occurs here */
          disable(edit_keys)
          Set(KillMax,0)
          SetClipBoardID(this_old_house)
          PushBlock()
          UnMarkBlock()
          mark_according_to_clipblocktype()
          Copy()
          PopBlock()
          GotoBufferID (this_old_house)
          BegFile()
          AbandonFile(temp_id)
          buffer_to_use = this_old_house
          add_contents_to_list()
     endif
     Set(KillMAX, KM)
     SetClipBoardID( SCBID)
     UpdateDisplay()
end

/****************************************************************************
     EXPAND_clipboard_name() adds trailing spaces
****************************************************************************/
proc                          expand_clipboard_name()
     clipboard_name = format(clipboard_name : - sizeof(clipboard_name) : ' ')
end

/****************************************************************************
     EXPANDED_ID()
          Returns zero-filled buffer_id
 ****************************************************************************/
string  proc                  expanded_id()
     return(Format(buffer_to_use:bid_width:'0'))
end

/****************************************************************************
     FIND_IN_CLIPBOARD(INTEGER XMODE)
          Finds the clipboard containing a string.
          XMODE = QUERY - ask for string, options
          XMODE = DONT_QUERY - dont ask, just find again
****************************************************************************/
proc                          find_in_clipboard(INTEGER xmode)
     integer
          starting_clipboard

     if if_clipboard_list_exists() == -99999
          return()
     else
          PushPosition()
          GotoBufferID( if_clipboard_list_exists() )
          if NumLines() <= 1
               PopPosition()
               msg = 'No named clipboards exist'
               pop_message( '', Query(MsgAttr), 18 )
               return()
          endif
     endif

     if xmode == DONT_QUERY             // this makes find_again
          if not Down()                 // start with next clipboard
               BegFile()                // from current
          endif
          if get_buffer_number_from_list() == 99999
               Down()
          endif
     endif
     starting_clipboard = get_buffer_number_from_list()
     if starting_clipboard == 99999
          Down()
          starting_clipboard  = get_buffer_number_from_list()
     endif
     PopPosition()

     /*
          Get string
     */
     if XMODE == QUERY_IT or Length(search_phrase) == 0
         Set(x1,1+10)
         Set(y1,menuX+13)
         if not (Ask('Search for:', search_phrase, _FIND_HISTORY_)
                 and Length(search_phrase))
              return()
         else
              Set(x1,1+10)
              Set(y1,menuX+13)
              if not Ask('Options: [IWX^$]', options)
                   return()
              endif
         endif
     endif

     /*
          Get rid of undesirable options
     */
     if length(options)
        lower(options)
        repl_char('g', '', options)
        repl_char('b', '', options)
        repl_char('l', '', options)
     endif

     PushPosition()
     GotoBufferID( if_clipboard_list_exists() )

     repeat
          PushPosition()                     // on list
          GotoBufferID (get_buffer_number_from_list() )
          BegFile()
          while lfind(search_phrase, options)
               buffer_to_use = get_buffer_number_from_list()
               clipboard_name = get_name_from_ID()
               trim_clipboard_name()
               if NOT list( format (clipboard_name + ' [' + str(CurrLine()) +
                                   "," + str(CurrPos()) +
                                   "]: <enter>/<esc>"
                                    : -70 : 'Ä'),
                              80 )
                    goto endit
               endif
               EndLine()
          endwhile
          PopPosition()       // back to list
          if not Down()
               BegFile()
          endif
          if get_buffer_number_from_list() == 99999
               Down()
          endif
     until starting_clipboard == get_buffer_number_from_list()
     message(search_phrase + ' not found')

     endit:
     PopPosition()
     PopPosition()
end

/****************************************************************************
     GET_CLIPBOARD_BLOCK_TYPE
          Determines the type of block that was copied to the
          current clipboard. Sets and returns clipblocktype.
****************************************************************************/
integer proc                  get_clipboard_block_type()
     integer tid,                            // temp buffer
          clipblocktype,
          gotcha
     PushPosition()
     PushBlock()
     tid=CreateTempBuffer()
     gotcha = Set(UnMarkAfterPaste,OFF)

     if NOT buffer_to_use                    // allows for use of
          buffer_to_use = GetClipBoardID()   // unnamed buffer as
     endif                                   // initial setting

     SetClipboardID(buffer_to_use)

     if not Paste()
          warn('paste failed')
          warn('gcbid ', getclipboardid())
          warn('ibm ' , isblockmarked() )
          warn('btu ' , buffer_to_use)
     else
          if isblockmarked() == 0
               warn('paste ok BUT clipblocktype is ', IsBlockMarked())
               warn('tid ', tid)
               warn('cid ', getbufferid())
               warn('numlines ', numlines())
               warn('btu ' , buffer_to_use)
          endif
     endif
     clipblocktype = IsBlockMarked()
     Set(UnMarkAfterPaste,gotcha)
     AbandonFile(tid)
     PopBlock()
     PopPosition()
     return(clipblocktype)
end

/****************************************************************************
     GET_BUFFER_NUMBER_FROM_LIST
          Quickie to return the buffer number for the buffer on the
          current line of clipboard list.
****************************************************************************/
integer proc                  get_buffer_number_from_list()
     return( val(gettext(1,bid_width)) )
end

/****************************************************************************
     GET_CLIPS_FROM_FILE()
          loads from clipboard
****************************************************************************/
proc                          get_clips_from_file()
     integer
          temp,                              // temp buffer holds get file
          buffer                             // used to hold buffer #s

     original_clip_ID = GetClipBoardId()
     operation = GETTING_FROM_FILE
     KM = set(KILLMAX, 0)
     Setup_list_buffer()                     // just in case?
     PushPosition()
     PushBlock()
     Set(x1,menuX + 10)
     Set(y1,menuY + 15)
     if Ask('File name for clipboards?', saveclipfilename)
          AND Length(saveclipfilename)
     else
          msg = 'bad file name'
          pop_message('', Query(MsgAttr), 19)
          goto ending
     endif

     temp = CreateTempBuffer()
     MSGL = Set(msglevel, _NONE_)
     InsertFile(saveclipfilename)
     Set(msglevel, MSGL)

     while lFind(buffer_flag, '^')
          UnMarkBLock()
          buffer_to_use = CreateTempBuffer()
          SetClipBoardID(buffer_to_use)
          GotoBufferID(temp)
          clipblocktype = Val(GetText(Length(buffer_flag)+1,1))
          clipboard_name = GetText(Length(buffer_flag)+2,
                               CurrLineLen()-Length(buffer_flag))
          msg = clipboard_name
          pop_message('Processing... <esc> to abort', Query(MsgAttr), 12)
          if check_for_abort()
               goto ending
          endif

          /*
               Mark the clipboard contents
          */
          Down()
          BegLine()
          case clipblocktype
               when _LINE_
                    MarkLine()
               when _NON_INCLUSIVE_
                    MarkChar()
               when _INCLUSIVE_
                    MarkStream()
               when _COLUMN_
                    lines = CurrLine()
                    MarkLine()
               otherwise
                    warn('bad clipblocktype')
          endcase

          if lFind(buffer_flag, '^')
               Up()
          else
               EndFile()
          endif

          case clipblocktype
               when _LINE_
                    if currlinelen() == 0
                         DelLine()
                         Up()
                    endif
                    MarkLine()
               when _INCLUSIVE_
                    EndLine()
                    MarkChar()
               when _NON_INCLUSIVE_
                    EndLine()
                    Left()
                    MarkStream() // is right right
               when _COLUMN_
                    MarkLine()
                    counter = CurrLineLen()
                    GotoBlockBegin()
                    while Down() and IsCursorInBlock()
                         counter = iif(counter > CurrLineLen(),
                                   counter, CurrLineLen())
                    endwhile
                    GotoBlockEnd()
                    GotoPos(counter)
                    MarkColumn()
                    GotoLine(lines)
                    BegLine()
                    MarkColumn()
               otherwise
                    warn('bad clipblocktype')
          endcase
          Copy()
          GotoBufferID(clip_list_ID)         // return to list

          BegFile()
          add_clipboard_to_list(clipblocktype)
          add_contents_to_list()
          GotoBufferID(temp)
     endwhile

     sort_clip_list_by_name()

     ending:
          AbandonFile(temp)
          PopBlock()
          SetClipBoardID(original_clip_ID)
          set(KILLMAX, KM)
          PopPosition()
end

/****************************************************************************
     IF_CLIPBOARD_LIST_EXISTS()
          Helper to determine if clipboard list exists
          and return buffer id of it. Halts w/ msg if none exist
****************************************************************************/
integer proc                  if_clipboard_list_exists()
     PushPosition()
     if clip_list_ID and GotoBufferID(clip_list_ID)
          if (operation >= PASTE_APPEND) and (NumLines() < 2)
               goto bailout
          else
               PopPosition()
               return(clip_list_ID)
          endif
     else
          Setup_list_buffer()
          if (operation >= PASTE_APPEND)
               goto bailout
          endif
          PopPosition()
          return(clip_list_ID)
     endif

     bailout:
               msg = 'No named clipboards exist'
               pop_message( '', Query(MsgAttr), 18 )
               PopPosition()
               UpdateDisplay()
               if KM
                    set(KillMax,KM)
               endif
               return(-99999)
end

/****************************************************************************
     LIST_CLIPBOARDS()
          Helper to list named clipboards
          and return the bufferid of the selected one, if any
          or return 0 if <esc>
****************************************************************************/
integer proc                  list_clipboards()
     integer
          deleted = FALSE                    // flag

     if use_picklists == FALSE and Operation <= CUT_APPEND
          return(99999)
     endif

     sid = getbufferid()                     // starting bufferid

     if GotoBufferID( if_clipboard_list_exists() )
          if NumLines() <= 1                 // no named clipboards
               GotoBufferID(sid)
               return(99999)                 // 'create new' code
          endif
     endif

     Set(Killmax,1000)

     if operation > GETTING_FROM_FILE
          lfind(expanded_id(),'g')
     endif

     /*
          Delete bufferIDs before listing
     */
     PushBlock()
     mark_ids()
     DelBlock()

     /*
          Delete 'new clipboard' option for certain ops
     */
     if operation > GETTING_FROM_FILE
          PushPosition()
          BegFile()
          DelLine()
          PopPosition()
          deleted = TRUE
     else
          BegFile()                     // set default to <new>
                                        // for copy & cut

     endif
                                             // set list location
     Set(Y1,2)                               // line two
//   Set(X1,                                 // right justified
//       iif(textflag, Query (ScreenCols) - max_width - 1,
//                     Query (ScreenCols) - SizeOf(clipboard_name) - 2))
//          1)
     Set (X1, 0)
     Set (Y1, 0)
     if lList(
               iif(textflag, format(msg:-70:'Ä'), msg),
               iif(textflag, max_width + 1, SizeOf(clipboard_name) + 1),
               iif(NumLines() > 20, NumLines(), 20), _ENABLE_SEARCH_
             )
          PushPosition()
          BegFile()
          /*
               Restore 'new clipboard' option
          */
          if deleted
               UnDelete()
          endif

          /*
               Restore buffer IDs
          */
          UnDelete()

          PopPosition()
          PopBlock()     //----------
          buffer_to_use = get_buffer_number_from_list() // get the bufferid of
                                                  // the selected clipboard
          if buffer_to_use <> 99999               // 99999 is 'create new' flag
               clipboard_name = gettext(bid_width+2, sizeof(clipboard_name))
               trim_clipboard_name()
               AddHistoryStr(clipboard_name,prompt_hist)
          endif
     else                                    // <esc> was pressed
          buffer_to_use = 0
          PushPosition()
          BegFile()
          /*
               Restore 'new clipboard' option
          */
          if deleted
               UnDelete()
          endif
          /*
               Restore buffer IDs
          */
          UnDelete()
          PopPosition()
     endif
     PopBlock()
     GotoBufferID(sid)
     set(Killmax,KM)
     return(buffer_to_use)                       // 0 if <esc> for list
end

/****************************************************************************
     MARK_ACCORDING_TO_CLIPBLOCKTYPE()
****************************************************************************/
proc                          mark_according_to_clipblocktype()
          /*
               Mark block correctly
          */
          PushBlock()
          UnMarkBlock()
          case clipblocktype
               when _LINE_
                    Begfile()           MarkLine()
                    EndFile()           MarkLine()
               when _NON_INCLUSIVE_
                    Begfile()           MarkChar()
                    EndFile()           MarkChar()
               when _INCLUSIVE_
                    Begfile()           MarkStream()
                    EndFile() Left()    MarkStream() // is right right
               when _COLUMN_
                    counter = CurrLineLen()
                    Begfile()
                    while Down()
                         counter = iif(counter > CurrLineLen(),
                                   counter, CurrLineLen())
                    endwhile
                    Begfile() MarkColumn()
                    EndFile() GotoPos(counter) MarkColumn()
               otherwise
                    warn('bad copyclipblocktype')
          endcase
end

/****************************************************************************
     MARK_IDS()
          Help to mark id section of cliplist as a block.
****************************************************************************/
proc                          mark_ids()
     PushPosition()
     PushBlock()    UnMarkBLock()
     Begfile()      GotoPos(1)             MarkColumn()
     EndFile()      GotoPos(bid_width+1)   MarkColumn() // 1 is for type
     PopPosition()
end

/****************************************************************************
     MARK_NAMES()
          Helper to mark name area of cliplist
****************************************************************************/
proc                          mark_names()
     UnMarkBLock()
     Gotoline(2)    GotoPos(bid_width + 2)                     MarkColumn()
     EndFile()      GotoPos(bid_width + 1+ Sizeof(clipboard_name)) MarkColumn()
end

/****************************************************************************
     NAMED_CLIPBOARD()
          This is the macro that handles all named clipboard operations.
****************************************************************************/
integer proc                  named_clipboard()
     integer marked = FALSE                  // was curr line marked?

     KM = Set(KillMax,0)

     /*
          Save current ClipBoard Id
     */
     original_clip_ID = GetClipBoardId()

     /*
          Make sure the history buffer has been Setup
     */
     if prompt_hist == 0
          prompt_hist = GetFreeHistory()
          options = Query(FindOptions)
     endif

     /*
          Make sure the list of names buffer has been Setup
     */
     Setup_list_buffer()

     /*
          Saves (Cut/Copy) require a marked block in the current buffer
          unless UseCurrLineIfNoBlock is On
     */
     if Operation <= CUT_APPEND
        AND Query(BlockId) <> GetBufferId()
          if Query(useCurrLineifnoblock) == TRUE
               UnMarkBlock()
               MarkLine()
               MarkLine()
               marked = true
          else
               msg = 'Block must be in current file ... press <ESC>'
               pop_message('', Query(MsgAttr), 0)
               Set(KillMax,KM)
               return (FALSE)
          endif
     endif

     /*
          Set up user prompt/message used when prompting for name of CB
     */
     case Operation
          when COPY_OVERWRITE    Msg = "Copy to"
          when COPY_APPEND       Msg = "Copy/Append to"
          when CUT_OVERWRITE     Msg = "Cut to"
          when CUT_APPEND        Msg = "Cut/Append to"
          when CUT_FILL_WITH_BLANKS Msg = "Cut/Blank Fill to"
          when PASTE_APPEND      Msg = "Paste from"
          when PASTE_OVERWRITE   Msg = "Paste/Over from"
     endcase
     msg = msg + ' clipboard:'

     clipboard_name = ""
     buffer_to_use = list_clipboards()
     if buffer_to_use == 99999               // if 'create new'
          if NOT auto_naming
               trim_clipboard_name()
               if not Ask(Msg, clipboard_name, prompt_hist)
                    if marked
                         UnMarkBlock()
                    endif
                    Set(KillMax,KM)
                    return(FALSE)                 // return if <esc>
               endif
          else
//             clipboard_name = GetMarkedText()   // use auto-naming
  //           trim_clipboard_name()              // remove spaces
    //         while length(clipboard_name) and clipboard_name[1] == ' '
      //            clipboard_name = SubStr(clipboard_name,
        //                                  2, length(clipboard_name))
          //   endwhile
            // if clipboard_name == ''            // try alternate method
                    PushPosition()
                    GotoBlockBegin()
                    if isBlockMarked() == _LINE_
                         BegLine()
                    endif
                    repeat
                    until  (CurrChar() > 0 AND
                            CurrChar() <> 32 AND
                            CurrChar() <> 9 )
                            OR (NOT NextChar())
                    clipboard_name = GetText(CurrPos(), SizeOf(clipboard_name))
                    PopPosition()
           //  endif
          endif
          if not Length(clipboard_name)
               buffer_to_use = original_clip_id
               SetClipBoardId( store_name_on_clip_list(NORMAL) )
          else
               SetClipBoardId( store_name_on_clip_list(NORMAL) )
          endif
     elseif buffer_to_use == 0               // if returns 0 (<esc>)
          if marked
               UnMarkBlock()
          endif
          Set(KillMax,KM)
          return(FALSE)
     elseif buffer_to_use                    // else Set ID
          SetClipBoardId( buffer_to_use )
     endif
     if operation >= PASTE_APPEND
          and if_clipboard_list_exists() == -99999
          SetClipBoardID( original_clip_ID)
          return(-99999)
     endif
     case Operation
          when COPY_OVERWRITE    x(1)
                                 backup_clipboard()
                                 Copy()
                                 x(2)
          when COPY_APPEND       x(1)
                                 Copy(_APPEND_)
                                 x(2)
          when CUT_FILL_WITH_BLANKS
                                 cut_and_blank_fill()
          when CUT_OVERWRITE     backup_clipboard()
                                 Cut()
          when CUT_APPEND        Cut(_APPEND_)
          when PASTE_APPEND      if Paste() and delete_after_paste
                                   delete_named_clipboard(1)
                                 endif
          when PASTE_OVERWRITE   if paste_over() and delete_after_paste
                                   delete_named_clipboard(1)
                                 endif
     endcase
     if (operation == PASTE_APPEND) OR
        (operation == PASTE_OVERWRITE)
          if post_paste_position == BEGINNING
               GotoBlockBegin()
          else
               GotoBlockEnd()
          endif
     endif

     /*
          Add text to clipboard listing
     */
     if operation >= COPY_OVERWRITE AND
        operation <= CUT_APPEND
          add_contents_to_list()
     endif

     // Restore ClipBoard
     SetClipBoardId( original_clip_ID )
     Set(BREAK,OFF)
     Set(KillMax,KM)
     return(TRUE)
end

/****************************************************************************
     PASTE_OVER
          Does a Paste/Overwrite regardless of block type.
          (TSE only does this for COL blocks.)
****************************************************************************/
integer proc                  paste_over()
     string chartext[254] = ''          //
     integer clipblocktype,
          lines                         // # of lines in clipboard
     counter = 0
     Set(BREAK,ON)
     clipblocktype = get_clipboard_block_type()
     case clipblocktype
          when _COLUMN_
               if Paste(_OVERWRITE_)
                    Return(TRUE)
               endif
          when _LINE_
               PushPosition()
               GotoBufferID(buffer_to_use)
               lines = NumLines()
               PopPosition()
               repeat
                    DelLine()
                    counter = counter + 1
               until counter == lines
               if Paste()
                    Return(TRUE)
               endif
          when _INCLUSIVE_, _NON_INCLUSIVE_
               PushPosition()
               PlaceMark('T')           // Paste 'T'o buffer marker
               PlaceMark('A')           // First char paste position
               GotoBufferID(buffer_to_use)
               lines = NumLines()
               Begfile()
               PlaceMark('F')           // Paste 'F'rom buffer marker
               repeat                   // repeat once for each line
                    repeat              // repeat until EOL
                         chartext = GetText(CurrPos(), 254) // get text
                         GoToPos(CurrPos() + 254)           // move cursor
                         PlaceMark('F') GotoMark('T')
                         if not
                              InsertText(chartext, _OVERWRITE_)
                              return(FALSE)
                         endif
                         PlaceMark('Z') // last char paste position
                         PlaceMark('T') GotoMark('F')
                    until CurrChar() < 0
                    GotoMark('T')
                    if not Down()                      // in case bottom of file
                         AddLine()
                    endif
                    BegLine()
                    PlaceMark('T')      GotoMark('F')
                    Down()              BegLine()
                    PlaceMark('F')
                    counter = counter + 1
               until counter == lines
               unmarkblock()
               GotoMark('Z')       MarkChar()
               GotoMark('A')       MarkChar()
//               PopPosition()
                 if post_paste_position == BEGINNING
                      GotoBlockBegin()
                 else
                      GotoBlockEnd()
                 endif
               Return(TRUE)
     endcase
     return(FALSE)
end

/****************************************************************************
     POP_MESSAGE( STRING TITLE, STRING MSG, INTEGER MATTR, INTEGER XDELAY )
****************************************************************************/
proc                          pop_message( string title, integer mattr, integer xdelay )
          // by Richard Hendricks
  integer maxX, maxY, maxL, saveattr, boxtype, x1, y1, x2, y2, tlen, mlen
  if xdelay == 0
     msg = msg + ' ... press any key to continue.'
  endif
  maxX = Query( ScreenCols )
  maxY = Query( ScreenRows )
  tlen = length( title )
  mlen = length( msg )
  maxL = iif( tlen < mlen, mlen, tlen )
  x1 = (maxX - maxL - 3) / 2
  x1 = iif( x1<0, 0, x1)
  y1 = (maxY - 3) / 2
  y1 = iif( y1<0, 0, y1)
  x2 = x1 + maxL + 3
  y2 = y1 + 2
  boxtype = 6
  PopWinOpen( x1, y1, x2, y2, boxtype, title, Query(hiliteattr) )
  saveattr = Query( Attr )
  Set( Attr, mattr )
  VHomeCursor()
  ClrScr()
  Set( Cursor, Off )
  Write( Format(" ":((maxL-length(msg)+3)/2))+msg ) // center msg
  if xdelay == 0
     GetKey()
  else
     delay(xdelay)
  endif
  Set( Attr, saveattr )
  PopWinClose()
  Set( Cursor, On )
end pop_message

/****************************************************************************
     PRINT_NAMED_CLIPBOARD()
****************************************************************************/
proc                          print_named_clipboard()
     operation = PRINT
     KM = set(KillMax, 0)
     msg = 'Print clipboard:'
     PushPosition()
     if if_clipboard_list_exists() == -99999
          return()
     else
          GotoBufferID( if_clipboard_list_exists() )
     endif
     buffer_to_use = list_clipboards()                        // get list of clips
     if buffer_to_use
          clipboard_name = get_name_from_ID()
          trim_clipboard_name()
          counter = 0
          if GotoBufferID(buffer_to_use)
               print_string('Clipboard: ' + clipboard_name                               + chr(13) + chr(10)
                              + chr(13) + chr(10) )
               PrintFile()
          else
               warn('Err 4')
          endif
     endif
     PopPosition()
     UpdateDisplay()
     Set(KillMax, KM)
end

/****************************************************************************
     PRINT_STRING()
          Helper functions to a print a string
****************************************************************************/
proc                          print_string(STRING text)
     while counter <= length(text) and PrintChar(text[counter])
          counter = counter + 1
     endwhile
end

/****************************************************************************
     RENAME_CLIPBOARD()
****************************************************************************/
proc                          rename_clipboard()
     selected_clipboard_name=''
     PushPosition()
     if if_clipboard_list_exists() == -99999
          return()
     else
          GotoBufferID( if_clipboard_list_exists() )
          if NumLines() <= 1
               PopPosition()
               msg = 'No named clipboards exist'
               pop_message( '', Query(MsgAttr), 18 )
               return()
          else
               PopPosition()
          endif
     endif
     sid = GetBufferID()
     KM = set(KillMax, 0)
     operation = RENAME
     msg = 'Rename clipboard:'
     buffer_to_use = list_clipboards()
     if not buffer_to_use
          goto ending
     endif
     clipboard_name = get_name_from_ID()
     trim_clipboard_name()
     if Ask('New name for ' +  clipboard_name + '?', selected_clipboard_name, prompt_hist) AND
          Length(selected_clipboard_name)
          rename_it(clipboard_name, selected_clipboard_name)
          sort_clip_list_by_name()
     endif
     ending:
          GotoBufferID(sid)
          Set(KillMax, KM)
end

/****************************************************************************
     RENAME_IT(STRING OLD_NAME, STRING NEW_NAME)
****************************************************************************/
proc                          rename_it(STRING old_name, STRING new_name)
     GotoBufferID(clip_list_ID)
     clipboard_name = old_name
     expand_clipboard_name()
     if not lFind(expanded_id() + '[0-9]'+ clipboard_name, '^gx')
          warn(  "Err 5" )
          halt
     endif
     GotoPos(bid_width + 2)
     clipboard_name = new_name
     expand_clipboard_name()
     InsertText(clipboard_name, _OVERWRITE_)
end

/****************************************************************************
     REPL_CHAR(STRING find_string, STRING repl_string, VAR STRING target)
          Replaces character within a string
****************************************************************************/
string proc                   repl_char(STRING find_string,
                                        STRING repl_string,
                                        VAR STRING target)
     while Pos(find_string, target)
          target = SubStr(target,
                          1,
                          Pos(find_string, target)-1
                          ) +
                    repl_string +
                    SubStr(target,
                           Pos(find_string, target)+
                               Length(find_string),
                           Length(target)
                           )
     endwhile
     return(target)
end

/****************************************************************************
     SAVE_CLIPBOARDS_TO_FILE()
****************************************************************************/
proc                          save_clipboards_to_file()
     integer
          scf=0                       // working buffer
     if if_clipboard_list_exists() == -99999
          return()
     else
          clip_list_id = if_clipboard_list_exists()
     endif

     PushPosition()
     GotoBufferID(clip_list_id)
     if numlines() <= 1
          msg = 'No named clipboards exist'
          pop_message( '', Query(MsgAttr), 18 )
          PopPosition()
          UpdateDisplay()
          return()
     endif

     original_clip_ID = GetClipBoardId()

     /*
          Get file name
     */
     askfile:
     Set(x1,menuX + 10)
     Set(y1,menuY + 15)
     if Ask('File name for clipboard storage?', saveclipfilename)
          and Length(saveclipfilename)
     else
          goto ending
     endif

     /*
          Verify replacement if exists
     */
     if FileExists(saveclipfilename)
          Set(x1,menuX + 30)
          Set(y1,menuY + 16)
          case YesNo('Overwrite '+saveclipfilename+ '?')
               when 1                   // Yes
                    if Query(MakeBackups)
                         msg = saveclipfilename
                         pop_message('Backing up file', Query(MsgAttr), 16)
                         DOS('copy ' + saveclipfilename + ' ' +
                              SplitPath(saveclipfilename, _DRIVE_ | _NAME_)
                              + Query(BackupExt) + ' >nul', _DONT_CLEAR_)
                    endif
               when 2 goto askfile      // No
               when 0,3 goto ending     // Esc, Cancel
          endcase
     endif

     /*
          If file is loaded, get rid of it
     */
     MSGL = Set(msgLevel, _NONE_)
     if EditFile(saveclipfilename)
          AbandonFile()
     endif
     Set(msgLevel, MSGL)

     scf = CreateBuffer(saveclipfilename)
     GotoBufferID(clip_list_id)
     Begfile()
     while Down()
          buffer_to_use = get_buffer_number_from_list()
          SetClipBoardId( buffer_to_use )
          set_clipblocktype()
          clipboard_name = GetText(bid_width+2, CurrLineLen() - bid_width - 1)
          msg = clipboard_name
          pop_message('Processing... <esc> to abort', Query(MsgAttr), 12)
          if check_for_abort()
               AbandonFile(scf)
               goto ending
          endif
          GotoBufferID(scf)
          AddLine(buffer_flag + str(clipblocktype) + clipboard_name)
          AddLine()
          BegLine()
          Paste()
          EndFile()
          GotoBufferID(clip_list_id)
     endwhile
     GotoBufferID(scf)
     MSGL = Set(MsgLevel, _NONE_)
     if SaveFile()
          AbandonFile()
     else
          msg = "Couldn't save; keeping file"
          pop_message('', Query(MsgAttr), 0)
     endif
     Set(MsgLevel, MSGL)
     ending:
          SetClipBoardID(original_clip_ID)
          PopPosition()
end

/****************************************************************************
     SETUP_LIST_BUFFER()
          Helper to set up the buffer for list of clipboards.
****************************************************************************/
proc                          setup_list_buffer()
     if clip_list_ID == 0
          PushPosition()
          clip_list_ID = CreateTempBuffer()
          AddLine(  '99999-' +
                    format(new_option : sizeof(clipboard_name) ) +
                    ' º' )
          PopPosition()
     endif
end

/****************************************************************************
     SET_CLIPBLOCKTYPE()
          Sets clipblocktype to that of clipboard_name
 ****************************************************************************/
proc                          set_clipblocktype()
     PushPosition()
     GotoBufferID(clip_list_ID)
     if lFind(expanded_id() , '^g')
          clipblocktype = val(gettext(bid_width + 1, 1))
     else
          warn('err 42')
     endif
     PopPosition()
     return()
end

/****************************************************************************
     SORT_CLIP_LIST_BY_NAME()
          Helper to sort list of names of clipboards
****************************************************************************/
proc                          sort_clip_list_by_name()
     PushPosition()
     GotoBufferID(clip_list_ID)
     PushBlock()
     mark_names()
     MSGL = Set(MsgLevel, _NONE_)
     sort(_IGNORE_CASE_)
     Set(MsgLevel, MSGL)
     PopBlock()
     PopPosition()
end

/****************************************************************************
     STORE_NAME_ON_CLIP_LIST(INTEGER STORE_MODE)
          Helper to store names of clipboards;
               Create clipboard if does not exist;
               Returns buffer id either way.
          store_mode = NORMAL for all operations except
                     = BACKUPS when creating backup buffers

****************************************************************************/
integer proc                  store_name_on_clip_list(integer store_mode)
     sid = getbufferid()

     if if_clipboard_list_exists() == -99999
          return(-99999)
     else
          GotoBufferID(if_clipboard_list_exists())     // Goto list buffer
     endif

     /*
          Mark for Local Search (to exclude IDs)
     */
     PushBlock()
     mark_names()
     xtop:
     expand_clipboard_name()
     if not lFind(clipboard_name, '^gli')              // if not find 'name'
          PopBlock()
          if (not (buffer_to_use == original_clip_id)) or
             (store_mode == MAKING_BACKUP)
               buffer_to_use = CreateTempBuffer()  // create buffer
          endif                                    // if not original
          if not buffer_to_use
               warn('Err 2a')              // Create buffer failed
               halt
          endif
          add_clipboard_to_list(CURRENT)
          sort_clip_list_by_name()
          lFind(clipboard_name, 'gin')           // position to last add
          goto ending
     endif
     trim_clipboard_name()

     if ( store_mode <> MAKING_BACKUP ) and  // i.e., isn't a backup buffer
        ( use_picklists == TRUE ) and        // picklists are being used
        (Operation < VIEW ) and              // cut or copy
        length(clipboard_name)                   // no Query to overwrite unnamed

          case YesNo(clipboard_name+ ' exists; overwrite?')
               when 2                        // re-ask
                    if not Ask(Msg, clipboard_name, prompt_hist) and Length(clipboard_name)
                         PopBlock()
                         GotoBufferID(sid)
                         return(-99999)
                    endif
                    goto xtop
               when 1                        // overwrite
                    buffer_to_use = get_buffer_number_from_list()
                    PopBlock()
               otherwise                     // bail out for esc, cancel
                    PopBlock()
                    GotoBufferID(sid)
                    return(-99999)

          endcase
     else                                    // is a backup buffer
                                             // or etc
          buffer_to_use = get_buffer_number_from_list()
                                             // so no overwrite prompt
          PopBlock()
     endif

   ending:
     GotoBufferID(sid)
     return(buffer_to_use)
end

/****************************************************************************
     TAHGGLE( VAR INTEGER ARG )
          Toggles arg
****************************************************************************/

proc                          tahggle(var integer arg)
     arg = not arg
end

/****************************************************************************
     TOGGLE_backup_type(INTEGER ARG)
          Toggles backup type.
****************************************************************************/
string proc                   toggle_back_type(integer arg)
     case arg
          when REPORT_STATUS
               case backup_type
                    when OFF return('Off')
                    when ON return('On')
                    when ADDITIVE return('Additive')
               endcase
          when CHANGE_STATUS
               backup_type = (backup_type + 1) Mod 3
     endcase
     return('')
end

/****************************************************************************
     TOGGLE_CLIP_TYPE(INTEGER ARG)
          Toggles clipboard type.
          If WINCLIP.MAC is present it is loaded so that
               presence of Windows clipboard can be tested
               to see if OK to toggle type to WINDOWS.
****************************************************************************/
string proc                   toggle_clip_type(integer arg)
     case arg
          when REPORT_STATUS
               case clipboard_type
                    when UNNAMED return('UnNamed')
                    when NAMED return('Named')
                    when WINDOWS return('Windows')
               endcase
          when CHANGE_STATUS
               MSGL = Set(msglevel,_NONE_)
               if loadmacro('winclip')
                    Set(MsgLevel,MSGL)
                    ExecMacro('IWCP')
                    clipboard_type =
                         (clipboard_type + 1)
                         Mod ( iif(GetGlobalInt('IWCP'), 3, 2) )
               else
                    Set(MsgLevel,MSGL)
                    clipboard_type = NOT clipboard_type
               endif
     endcase
     Set(MsgLevel,MSGL)
     if clipboard_type == NAMED                  // just changed to NAMED
          PushPosition()                         // so add system clipboard
          original_clip_id = GetClipboardID()    // to clip_list
          GotoBufferid(original_clip_id)
          Setup_list_buffer()
          if NumLines() > 0
               buffer_to_use = original_clip_id
               clipboard_name = ''
               store_name_on_clip_list(NORMAL)
               add_contents_to_list()
          endif
          PopPosition()
     endif

     return('')
end

/****************************************************************************
     VIEW_NAMED_CLIPBOARD()
****************************************************************************/
proc                          view_named_clipboard()
     operation = VIEW
     msg = 'View clipboard:'
     PushPosition()
     if if_clipboard_list_exists() == -99999
          return()
     else
          GotoBufferID( if_clipboard_list_exists() )
     endif
     KM = set(KillMax, 0)
     buffer_to_use = list_clipboards()                        // get list of clips
     if buffer_to_use
          clipboard_name = get_name_from_ID()
          trim_clipboard_name()
          if GotoBufferID(buffer_to_use)
               if CurrLine() <= NumLines()
                    Up()
               endif
               if list(clipboard_name,80)
                    lines = CurrLine()
                    rows =  CurrRow()
                    edit_named_clipboard()
               endif
          else
               warn('Err 4')
          endif
     endif
     PopPosition()
     UpdateDisplay()
     Set(KillMax, KM)
end

/****************************************************************************
     TRIM_clipboard_name() removes trailing spaces
****************************************************************************/
proc                          trim_clipboard_name()
     while length(clipboard_name) AND clipboard_name[length(clipboard_name)] == ' '
          clipboard_name = substr(clipboard_name, 1, length(clipboard_name) -1)
     endwhile
end

/****************************************************************************
     X(INTEGER ARG)
          A quickie helper to do a push or pop block -- but only when the
          unmark after copy/cut flag is ON.
****************************************************************************/
proc                          x(integer arg)
     if unmark_flag
          return()
     else
          case arg
               when 1 PushBlock()
               when 2 PopBlock()
          endcase
     endif
end
