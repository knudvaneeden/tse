/*
  Extension     ViewFinds
  Author        Carlo Hogeveen
  Website       ecarlo.nl/tse
  Compatibility TSE v4.50    (26 Oct 2024) upwards for comment and search-term hiliting
                TSE v4.50.26 ( 1 Jul 2026) upwards for full syntax-hiliting
                All TSE variants, including TSE for Linux.
  Version       v1.1.10  21 Aug 2026

  If you do a search with the "v" option or use the "grep" macro from TSE's
  Potpourri menu, then the lines of the search-results will have colored
  comments or be fully syntax-hilited.

  Comment-coloring shows us at a glance which found strings are (not) in
  comments.

  From TSE v4.50.26 upwards ViewFinds adds full syntax hiliting.

  For earlier versions (TSE v4.50 to v4.50.24, including release candidates like v4.50.rc24),
  ViewFinds now adds both comment and search-term coloring.
  This works well for single-line comments, as well as for multi-line comments
  in already loaded files, but does not work for multi-line comments in files
  that are loaded by the search.


  INSTALLATION

    Installation instructions: I keep this file in my TSE working
                               directory.

    For more permanent installation: Put the macro in your TSE g32.exe
                                     command line with parameter
                                     -e<filename> startup file

                                      or in the file tsestart.s

                                      or in your TSE autoload list.

    Optionally: Put this file in TSE's "mac" folder and compile it
                there, for example by opening it there in TSE and
                applying the Macro Compile menu.

                Add the extension's name "ViewFinds" to TSE's Macro
                AutoLoad List menu, and restart TSE.

                Optionally configure the extension by executing it, for
                example by entering its name "ViewFinds" in the Macro
                Execute menu.

    You can configure two options:

      Current line background color
        This is especially useful for users who configured TSE to have a
        current line with the same color as other lines.
        During editing the cursor still indicates the current line, but in
        a "View Finds" list there is no cursor to indicate the current line.

      Trailing spaces color
        In a "View Finds" list short lines will have trailing spaces.
        These trailing spaces can be colored like editor-text or like a menu.
        An advantage of the "Text" color is, that you experience lines even
        more like they occur in their originating text.
        An advantage of the "Menu" color is, that it is a constant visual
        reminder that you are not in a text but in a list.


  KNOWN DEFICIENCIES

    Multi-line delimited text (typically comments) can be colored incorrectly.
    In TSE v4.50.26 upwards that will rarely happen.
    In older TSE versions it will happen for files that are loaded on-the-fly.


  NOTES

    Unlike a default View Finds list, the enhanced list will horizontally
    scroll any listed file name headers.
    This is deliberate to make today's longer file names viewable.


  HISTORY
  
  v1.1.10           21 Aug 2026
  - Fixed SAL compiler syntax error by properly elevating all variable declarations 
    to the top of the display procedure.

  v1.1.9            21 Aug 2026
  - Fundamental redesign for older TSE versions (< v4.50.25). Replaced upfront 
    buffer pre-calculation with on-the-fly Lazy Evaluation inside the display hook. 
    Loading times for massive grep lists are now instantaneous.

  v1.1.8            21 Aug 2026
  - Eliminated the interpreted buffer-switching loop entirely for older versions. 
    Colors are now natively stamped using direct string formatting.

  v1.1.7            20 Aug 2026
  - Massively optimized the attribute construction loops by replacing O(N) 
    character-by-character insertions with O(1) string chunks.
  - Pre-calculated search history fetching to eliminate redundant engine queries.

  v1.1.6            20 Aug 2026
  - Fixed a critical "Not Responding" freeze caused by the macro silently 
    running LoadBuffer() on massive document files (e.g. gigabyte scale). 
    File loads are now aborted if FFSize exceeds 10MB.
    
  v1.1.5            20 Aug 2026
  - Optimized the fallback syntax loop to prevent infinite hangs on massive lines 
    (e.g., in document files) and enforced MAXLINELEN bounds to prevent buffer overruns.
  
  v1.1.4            20 Aug 2026
  - Added enhanced installation instructions.
  
  v1.1.3            20 Aug 2026
  - Added search-term highlighting fallback for earlier TSE versions (e.g. v4.50 to v4.50.24).
  - Explicitly added compatibility note for TSE for Linux.

  v1.1.2            23 Jul 2026
  - Made the extension adhere to one of Sammy's sanity tests,
    and as a side-effect made it a millisecond faster.

  v1.1.1            10 Jul 2026
  - Fixed two insignificant bugs regarding ViewFind's list's <Del> key.

  v1.1             4 Jul 2026
  - Now works in the "grep" macro's "View Finds" list too.
  - Added the words "configuration menu" to ViewFinds' configuration menu.
  - Added a configuration menu explanation to the installation instructions.

*/

// Start of compatibility restrictions and mitigations ...

#ifndef INTERNAL_VERSION
  #define INTERNAL_VERSION 0
#endif

// End of compatibility restrictions and mitigations.

// Constants and semi-constants

integer ATTRIBUTES_LIST_ID                  = 0
integer ATTRS_ADDRESS                       = 0
string  MACRO_NAME           [MAXSTRINGLEN] = ''
integer MEMORY_BLOCKS_ID                    = 0
integer TMP_REF_ID                          = 0
#define TEXT_FRONT_LENGTH                     12
string  TRAILING_TEXT_SPACES [MAXSTRINGLEN] = ''

//  Global variables

integer cfg_trailing_spaces_color              = FALSE
integer cfg_cursor_bg_attr                     = -1

integer g_macro_ok                             = TRUE
integer g_old_hookstate                        = TRUE
string  g_synhi_mld_closers     [MAXSTRINGLEN] = ''
string  g_synhi_mld_openers     [MAXSTRINGLEN] = ''

integer g_synhi_num_mlds                       = 0

#if INTERNAL_VERSION >= 12445
  integer g_synhi_currline_mld_line            = 0
  integer g_synhi_currline_mld_type            = 0
  string  g_synhi_name          [MAXSTRINGLEN] = ''
#endif

string  searchStrGS             [MAXSTRINGLEN] = ''
integer searchLenGI                            = 0

string  g_trailing_spaces_attrs [MAXSTRINGLEN] = ''
integer g_cursor_bg_attr                       = 0
integer g_cursor_attr                          = 0
integer g_menu_select_attr                     = 0
integer g_menu_text_attr                       = 0
integer g_stop_main_menu                       = TRUE
integer g_text_attr                            = 0


proc to_beep_or_not_to_beep()
  if Query(Beep)
    Alarm()
  endif
end

proc profile_error(string section_name,
                   string item_name,
                   string item_value)
  to_beep_or_not_to_beep()
  MsgBox(MACRO_NAME,
         Format('ERROR:'                                      , Chr(13),
                '  Could not write item  "', item_name   , '"', Chr(13),
                '  with value            "', item_value  , '"', Chr(13),
                '  to section            "', section_name, '"', Chr(13),
                '  of configuration file "tse.ini".'))
end

integer proc write_profile_int(string  section_name,
                               string  item_name,
                               integer item_value)
  integer ok = WriteProfileInt(section_name, item_name, item_value)

  if not ok
    profile_error(section_name, item_name, Str(item_value))
  endif

  return(ok)
end

#if INTERNAL_VERSION > 12445
  integer proc CurrLine_MLD_Type()
    string  language_type [MAXSTRINGLEN] = GetSynLanguageType()
    integer text_address                 = 0
    integer text_length                  = 0
    integer to_line                      = CurrLine()

    if  NumLines()
    and to_line >= g_synhi_currline_mld_line
      PushLocation()
      if g_synhi_currline_mld_line == 0
        g_synhi_currline_mld_line = 1
      endif
      GotoLine(g_synhi_currline_mld_line)
      do to_line - g_synhi_currline_mld_line + 1 times
        text_address = CurrLinePtr()
        text_length  = CurrLineLen()

        GetSynHiAttrs(FALSE,
                      text_address,
                      text_length,
                      language_type,
                      ATTRS_ADDRESS,
                      g_synhi_currline_mld_type)
        Down()
        g_synhi_currline_mld_line = g_synhi_currline_mld_line + 1
      enddo
      g_synhi_currline_mld_line = g_synhi_currline_mld_line - 1
      PopLocation()
    endif
    return(g_synhi_currline_mld_type)
  end
#endif

integer proc create_memory_block(var integer blocks_id,
                                     integer block_size,
                                 var integer block_address)
  string s [MAXSTRINGLEN] = Format('': MAXSTRINGLEN: Chr(0))

  if block_size > MAXLINELEN
    MsgBox(SplitPath(CurrMacroFilename(), _NAME_),
           Format('create_memory_block abort: Block size > MAXLINELEN.'))
    return(FALSE)
  endif

  if blocks_id == 0
    PushLocation()
    blocks_id = CreateTempBuffer()
    ChangeCurrFilename(SplitPath(CurrMacroFilename(), _NAME_) +
                       ':MemoryBlocks',
                       _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
    PopLocation()
  endif

  PushLocation()
  GotoBufferId(blocks_id)
  EndFile()
  AddLine()
  BegLine()
  do block_size / MAXSTRINGLEN times
    InsertText(s)
  enddo
  if CurrLineLen() < block_size
    InsertText(s[1: block_size - CurrLineLen()])
  endif
  block_address = CurrLinePtr()
  PopLocation()
  return(TRUE)
end


#if INTERNAL_VERSION >= 12445

  integer proc get_syn_hi_attrs(integer line_address,
                                integer line_length)
    integer color_mode = 0
    integer result     = 0

    result = GetSynHiAttrs(FALSE,
                           line_address,
                           line_length,
                           g_synhi_name,
                           ATTRS_ADDRESS,
                           color_mode,
                           g_text_attr)

    return(result)
  end

  proc set_synhi_properties()
    string  mld_closer [MAXSTRINGLEN] = ''
    string  mld_opener [MAXSTRINGLEN] = ''
    integer n                         = 0

    g_synhi_name = GetSynLanguageType()
    g_synhi_mld_openers = ''
    g_synhi_mld_closers = ''

    for n = 1 to 3
      GetSynMultiLnDlmt(mld_opener, mld_closer, n)
      g_synhi_mld_openers = Trim(g_synhi_mld_openers + ' ' + mld_opener)
      g_synhi_mld_closers = Trim(g_synhi_mld_closers + ' ' + mld_closer)
    endfor

    g_synhi_num_mlds = NumTokens(g_synhi_mld_openers, ' ')
  end

  integer proc temporarily_load_ref_file(string file_fqn)
    integer result_id = 0

    if FileExists(file_fqn)
      if FindFirstFile(file_fqn, -1) or FindFirstFile(file_fqn, 0)
          if FFSizeHigh() > 0 or FFSize() > 10000000
              return (0)
          endif
      endif

      PushLocation()
      GotoBufferId(TMP_REF_ID)
      if LoadBuffer(file_fqn)
        if ChangeCurrFilename(SplitPath(CurrFilename(), _DRIVE_|_PATH_|_NAME_) +
                              SplitPath(file_fqn      , _EXT_                ) ,
                              _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
          BufferType(_NORMAL_)
          if InitSynhiCurrFile()
            result_id = TMP_REF_ID
          endif
          BufferType(_SYSTEM_)
        endif
      endif
      PopLocation()
    endif

    return(result_id)
  end

#endif


proc hd_draw_list_line(integer is_cursorline)
  integer initial_VWhereY                = VWhereY()
  string  line_attrs      [MAXSTRINGLEN] = ''
  integer line_number                    = CurrLine()
  string  line_text       [MAXSTRINGLEN] = ''
  integer list_x_offset                  = 1 + CurrXoffset()
  integer p                              = 0
  integer trail_size                     = 0

  #if INTERNAL_VERSION < 12445
    integer matchPosI                      = 0
    integer currentOffsetI                 = 1
    integer attrColonI                     = 0
    integer colonPosI                      = 0
    string  remainingTextS  [MAXSTRINGLEN] = ''
  #endif

  line_text = GetText(list_x_offset, Query(WindowCols))
  line_text = StrReplace(Chr(9), line_text, ' ')

  #if INTERNAL_VERSION < 12445
    // Lazy Evaluation: Instantly generate format strings without buffer switching
    colonPosI      = Pos(':', GetText(1, 12))
    remainingTextS = Lower(line_text)

    line_attrs = Format('': Length(line_text): Chr(g_text_attr))

    if GetText(1, 6) == 'File: '
        line_attrs = Format('': Length(line_text): Chr(Query(MenuTextLtrAttr)))
    else
        // Apply menu color to line numbers
        if colonPosI > 0
            attrColonI = colonPosI - list_x_offset + 1
            if attrColonI > Length(line_text)
                attrColonI = Length(line_text)
            endif
            if attrColonI > 0
                line_attrs = Format('': attrColonI: Chr(g_menu_text_attr)) + SubStr(line_attrs, attrColonI + 1, MAXSTRINGLEN)
            endif
        endif

        // Apply search-term highlight directly to the matching substring
        if searchLenGI > 0
            matchPosI = Pos(searchStrGS, remainingTextS)
            while matchPosI > 0
                line_attrs = SubStr(line_attrs, 1, currentOffsetI + matchPosI - 2) +
                             Format('': searchLenGI: Chr(Query(HiLiteAttr))) +
                             SubStr(line_attrs, currentOffsetI + matchPosI + searchLenGI - 1, MAXSTRINGLEN)
                
                currentOffsetI = currentOffsetI + matchPosI + searchLenGI - 1
                remainingTextS = SubStr(remainingTextS, matchPosI + searchLenGI, MAXSTRINGLEN)
                matchPosI = Pos(searchStrGS, remainingTextS)
            endwhile
        endif
    endif

  #else
    // Upfront Memory Block extraction for newer versions
    PushLocation()
    GotoBufferId(ATTRIBUTES_LIST_ID)
    GotoLine(line_number)
    line_attrs = GetText(list_x_offset, Query(WindowCols))
    PopLocation()
  #endif

  trail_size = Max(Query(WindowCols) - Length(line_text), 0)

  if trail_size
    line_text  = line_text  + TRAILING_TEXT_SPACES   [1: trail_size]
    line_attrs = line_attrs + g_trailing_spaces_attrs [1: trail_size]
  endif

  if is_cursorline
    for p = 1 to Length(line_attrs)
      case (Asc(line_attrs[p]) / 16)
        when (g_menu_text_attr / 16)
          line_attrs[p] = Chr((Asc(line_attrs[p]) mod 16) +
                              (g_menu_select_attr / 16) * 16)
        when (g_text_attr / 16)
          line_attrs[p] = Chr((Asc(line_attrs[p]) mod 16) + g_cursor_bg_attr)
      endcase
    endfor
  endif

  PutStrAttrXY(1, initial_VWhereY, line_text, line_attrs)
end

proc hd_startup_list_window()
end

proc hd_cleanup_list_window()
end

proc hd_hilite_found_text()
  HiLiteFoundText()
end

proc create_attributes_list()
  #if INTERNAL_VERSION < 12445
    // Completely bypass parsing loop for older versions to ensure instant loading.
    g_macro_ok = TRUE
    EmptyBuffer(ATTRIBUTES_LIST_ID)
  #else

    string  multi_line_attribute        [1] = ''
    integer n                               = 0
    integer ref_buffer_id                   = GetBufferId()
    string  ref_file_name    [MAXSTRINGLEN] = CurrFilename()
    integer ref_file_properties_unknown     = FALSE
    string  ref_line_front   [MAXSTRINGLEN] = ''
    integer ref_line_length                 = 0
    integer ref_line_MultiLineDelimiterType = 0
    integer ref_line_number                 = 0
    integer ref_line_offset                 = 0

    INTEGER charsLeftI                      = 0
    INTEGER chunkLenI                       = 0
    INTEGER xPosI                           = 0
    STRING  chunkS           [MAXSTRINGLEN] = ''

    integer ref_line_address              = 0
    integer attr_address                  = 0

    EmptyBuffer(ATTRIBUTES_LIST_ID)

    if NumLines()
      PushLocation()
      BegFile()
      repeat
        if GetText(1, 6) == 'File: '
          ref_file_name               = GetFileToken(GetText(7, MAXSTRINGLEN), 1)
          ref_buffer_id               = GetBufferId(ref_file_name)

          if not ref_buffer_id
            ref_buffer_id = temporarily_load_ref_file(ref_file_name)
          endif

          g_synhi_currline_mld_line = 0
          g_synhi_currline_mld_type = 0
          g_synhi_name              = ''

          ref_file_properties_unknown = TRUE
          AddLine(Format('': Length(GetText(1, MAXSTRINGLEN)):
                             Chr(Query(MenuTextLtrAttr))),
                  ATTRIBUTES_LIST_ID)
        else
          ref_line_front      = GetText(1, TEXT_FRONT_LENGTH)
          ref_line_number = Val(GetToken(ref_line_front, ':', 1))

          if ref_line_number
            ref_line_offset = Pos(':', ref_line_front) + 1
          else
            ref_line_offset = 0
          endif

          ref_line_length = Min(CurrLineLen() - ref_line_offset, MAXLINELEN)
          ref_line_address = AdjPtr(CurrLinePtr(), ref_line_offset)

          PushLocation()

          if  ref_buffer_id
          and ref_line_number
            GotoBufferId(ref_buffer_id)
            PushLocation()
            GotoLine(ref_line_number)
            if ref_file_properties_unknown
              set_synhi_properties()
              ref_file_properties_unknown = FALSE
            endif

            ref_line_MultiLineDelimiterType = CurrLine_MLD_Type()
            
            if not ref_line_MultiLineDelimiterType
              ref_line_front = Trim(GetText(1, MAXSTRINGLEN))
              if ref_line_front <> ''
                for n = 1 to g_synhi_num_mlds
                  if GetToken(g_synhi_mld_closers, ' ', n) == ref_line_front
                    ref_line_MultiLineDelimiterType = n
                    break
                  endif
                endfor
              endif
            endif
            PopLocation()
          else
            ref_line_MultiLineDelimiterType = 0
          endif

          GotoBufferId(ATTRIBUTES_LIST_ID)
          AddLine()
          BegLine()
          InsertText(Format('': ref_line_offset: Chr(g_menu_text_attr)))

          if ref_line_MultiLineDelimiterType
            case ref_line_MultiLineDelimiterType
              when 1
                multi_line_attribute = Chr(Query(MultiLnDlmt1Attr))
              when 2
                multi_line_attribute = Chr(Query(MultiLnDlmt2Attr))
              when 3
                multi_line_attribute = Chr(Query(MultiLnDlmt3Attr))
            endcase

            charsLeftI = ref_line_length
            WHILE charsLeftI > 0
              chunkLenI = Min(charsLeftI, MAXSTRINGLEN)
              InsertText(Format('': chunkLenI: multi_line_attribute))
              charsLeftI = charsLeftI - chunkLenI
            ENDWHILE

          else
              if not get_syn_hi_attrs(ref_line_address, ref_line_length)
                UpdateDisplay(_ALL_WINDOWS_REFRESH_)
                MsgBox(macro_name + ' aborted:',
                       Format('Abort reason: GetSynhiAttrs() returned an error.',
                              Chr(13),
                              'Parameters'; ref_line_address;
                                            ref_line_length;
                                            '"', g_synhi_name, '"';
                                            ATTRS_ADDRESS;
                                            g_text_attr))
                PurgeMacro(MACRO_NAME)
                PushKey(<Escape>)
                g_macro_ok = FALSE
                break
              endif
              
              charsLeftI = ref_line_length
              xPosI      = 1
              WHILE charsLeftI > 0
                chunkLenI = Min(charsLeftI, MAXSTRINGLEN)
                PushLocation()
                GotoBufferId(MEMORY_BLOCKS_ID)
                chunkS = GetText(xPosI, chunkLenI)
                PopLocation()
                
                InsertText(chunkS)
                
                charsLeftI = charsLeftI - chunkLenI
                xPosI      = xPosI + chunkLenI
              ENDWHILE
          endif

          PopLocation()
        endif
      until not g_macro_ok
         or not Down()
      PopLocation()
    endif
  #endif
end

proc del_line()
  integer current_line         = CurrLine()
  integer file_last_found_line = 0

  if GetText(1, 6) == 'File: '
    if MsgBox(GetFileToken(GetText(7, MAXSTRINGLEN), 1),
             'Unload this file?',
             _YES_NO_CANCEL_) == 1
      AbandonFile(GetBufferId(GetFileToken(GetText(7, MAXSTRINGLEN), 1)))
      EndLine()
      if lFind('^File: ', 'x+')
        file_last_found_line = CurrLine() - 1
      else
        file_last_found_line = NumLines()
      endif
      PushBlock()
      MarkLine(current_line, file_last_found_line)
      KillBlock()
      if CurrLine() > NumLines()
        Up()
      endif
      PushLocation()
      GotoBufferId(ATTRIBUTES_LIST_ID)
      MarkLine(current_line, file_last_found_line)
      KillBlock()
      PopLocation()
      PopBlock()
    endif
  else
    PushLocation()
    KillLine()
    if CurrLine() > NumLines()
      Up()
    endif
    GotoBufferId(ATTRIBUTES_LIST_ID)
    GotoLine(current_line)
    KillLine()
    PopLocation()
  endif
end

Keydef list_keys
  <Del>     del_line()
  <GreyDel> del_line()
  <Alt E>   UnhookDisplay() ChainCmd()
end

proc list_cleanup()
  UnHook(list_cleanup)
  UnhookDisplay()
  SetHookState(g_old_hookstate, _ON_CHANGING_FILES_)
  Disable(list_keys)
  EmptyBuffer(ATTRIBUTES_LIST_ID)
end


proc list_startup()
  string title_text  [MAXSTRINGLEN] = ''
  string title_attrs [MAXSTRINGLEN] = ''

  GetStrAttrXY(1, 0, title_text, title_attrs, MAXSTRINGLEN)

  if Pos('View Finds', title_text)
    g_old_hookstate = SetHookState(OFF, _ON_CHANGING_FILES_)
    ClrScr()
    PutStrAttrXY(Query(WindowCols) / 2 - 16,
                 Query(WindowRows) / 2,
                 'ViewFinds is getting syntax hiliting colors ...',
                 '', Asc(title_attrs[1]))
                 
    searchStrGS = Lower(GetHistoryStr(_FIND_HISTORY_, 1))
    searchLenGI = Length(searchStrGS)
                 
    create_attributes_list()
    if g_macro_ok
      HookDisplay(hd_draw_list_line,
                  hd_startup_list_window,
                  hd_cleanup_list_window,
                  hd_hilite_found_text)
      Enable(list_keys)
    endif
    Hook(_LIST_CLEANUP_, list_cleanup)
  endif
end


integer proc get_cursor_bg_attr()
  return(iif(cfg_cursor_bg_attr == -1,
             g_cursor_attr / 16 * 16,
             cfg_cursor_bg_attr))
end


proc after_command()
  g_cursor_attr      = Query(CursorAttr)
  g_cursor_bg_attr   = get_cursor_bg_attr()
  g_menu_select_attr = Query(MenuSelectAttr)
  g_menu_text_attr   = Query(MenuTextAttr)
  g_text_attr        = Query(TextAttr) 
end


proc toggle_trailing_spaces_color()
  cfg_trailing_spaces_color = not cfg_trailing_spaces_color
  write_profile_int(MACRO_NAME + ':Configuration',
                    'TrailingSpacesColor',
                    cfg_trailing_spaces_color)
  g_trailing_spaces_attrs = Format('': MAXSTRINGLEN:
                                      iif(cfg_trailing_spaces_color,
                                          Chr(g_text_attr),
                                          Chr(g_menu_text_attr)))
end


string proc show_cfg_cursor_bg_attr()
  string s[34] = ''

  if cfg_cursor_bg_attr == -1
    s = Format(cfg_cursor_bg_attr     : 2, ': Default: Same as edit window. ')
  else
    s = Format(cfg_cursor_bg_attr / 16: 2, ': Example text. Example comment.')
  endif
  return(s)
end


proc before_getkey_color_main_menu()
  PutAttrXY(33, 1, Query(TextAttr), 4)
  if cfg_cursor_bg_attr == -1
    PutAttrXY(37, 1, g_cursor_attr / 16 * 16 + g_text_attr       mod 16,  9)
    PutAttrXY(46, 1, g_cursor_attr / 16 * 16 + Query(ToEol1Attr) mod 16, 21)
  else
    PutAttrXY(37, 1, cfg_cursor_bg_attr + g_text_attr mod 16, 14)
    PutAttrXY(51, 1, cfg_cursor_bg_attr + Query(ToEol1Attr) mod 16, 16)
  endif
end


proc before_getkey_color_currline_bg_attr_menu()
  integer i = 0

  PutAttrXY( 5, 1, g_cursor_attr,  9)
  PutAttrXY(14, 1, g_cursor_attr / 16 * 16 + Query(ToEol1Attr) mod 16, 21)

  for i = 0 to 15
    PutAttrXY( 5, i + 2, i * 16 + Query(TextAttr  ) mod 16, 14)
    PutAttrXY(19, i + 2, i * 16 + Query(ToEol1Attr) mod 16, 16)
  endfor
end


proc select_cfg_cursor_bg_attr()
  integer i      = 0
  integer tmp_id = 0

  PushLocation()
  tmp_id = CreateTempBuffer()
  AddLine('-1: Default: Same as edit window.')
  for i = 0 to 15
    AddLine(Format(i:2, ': Text example. Comment example.'))
  endfor
  BegFile()
  if cfg_cursor_bg_attr <> -1
    GotoLine(cfg_cursor_bg_attr / 16 + 2)
  endif
  UnHook(before_getkey_color_main_menu)
  Hook(_BEFORE_GETKEY_, before_getkey_color_currline_bg_attr_menu)
  if List("Cursor line's background color", LongestLineInBuffer())
    cfg_cursor_bg_attr = Val(GetText(1, 2))
    if cfg_cursor_bg_attr <> -1
      cfg_cursor_bg_attr = cfg_cursor_bg_attr * 16
    endif
    write_profile_int(MACRO_NAME + ':Configuration',
                      'CursorLineColor',
                      cfg_cursor_bg_attr)
  endif
  UnHook(before_getkey_color_currline_bg_attr_menu)
  PopLocation()
  AbandonFile(tmp_id)
  g_stop_main_menu = FALSE
end


menu main_menu()
  history

  'Current line background color'
    [show_cfg_cursor_bg_attr(): 34],
    select_cfg_cursor_bg_attr(),
    _MF_ENABLED_|_MF_CLOSE_ALL_BEFORE_,
    "Select a background color for the List's cursor line."

  'Trailing spaces color'
    [iif(cfg_trailing_spaces_color, 'Text color', 'Menu color'): 10],
    toggle_trailing_spaces_color(),
    _MF_ENABLED_|_MF_DONT_CLOSE_,
    'Toggle the trailing spaces color'
end


proc do_main_menu()
  repeat
    g_stop_main_menu = TRUE
    Hook(_BEFORE_GETKEY_, before_getkey_color_main_menu)
    main_menu(MACRO_NAME + ' configuration menu')
    UnHook(before_getkey_color_main_menu)
  until g_stop_main_menu
end


proc WhenPurged()
  AbandonFile(ATTRIBUTES_LIST_ID)
  AbandonFile(MEMORY_BLOCKS_ID)
  AbandonFile(TMP_REF_ID)
end


proc WhenLoaded()
  MACRO_NAME           = SplitPath(CurrMacroFilename(), _NAME_)
  TRAILING_TEXT_SPACES = Format('': MAXSTRINGLEN, ' ')

  g_menu_select_attr   = Query(MenuSelectAttr)
  g_menu_text_attr     = Query(MenuTextAttr)
  g_text_attr          = Query(TextAttr)

  if not create_memory_block(MEMORY_BLOCKS_ID, MAXLINELEN, ATTRS_ADDRESS)
    g_macro_ok = FALSE
    PurgeMacro(MACRO_NAME)
  endif

  cfg_cursor_bg_attr        = GetProfileInt(MACRO_NAME + ':Configuration',
                                            'CursorLineColor',
                                            -1)
  g_cursor_attr             = Query(CursorAttr)
  g_cursor_bg_attr          = get_cursor_bg_attr()
  cfg_trailing_spaces_color = GetProfileInt(MACRO_NAME + ':Configuration',
                                            'TrailingSpacesColor',
                                            FALSE)
  g_trailing_spaces_attrs   = Format('': MAXSTRINGLEN:
                                         iif(cfg_trailing_spaces_color,
                                             Chr(g_text_attr),
                                             Chr(g_menu_text_attr)))

  PushLocation()
  ATTRIBUTES_LIST_ID = CreateTempBuffer()
  ChangeCurrFilename(MACRO_NAME + ':ListLinesAttrs',
                     _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
  TMP_REF_ID             = CreateTempBuffer()
  ChangeCurrFilename(MACRO_NAME + ':TemporarilyLoadedReferencedFile',
                     _DONT_PROMPT_|_DONT_EXPAND_|_OVERWRITE_)
  PopLocation()

  Hook(_AFTER_COMMAND_, after_command)
  Hook(_LIST_STARTUP_ , list_startup)
end


proc Main()
  if g_macro_ok
    do_main_menu()
    UpdateDisplay(_ALL_WINDOWS_REFRESH_)
  endif
end
