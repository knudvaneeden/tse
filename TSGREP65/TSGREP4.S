/**************************************************************************
               TSGREP ... A regular expression line extractor ... 6.5

 File TSGREP4: Opens screen windows, paints them, and puts header in
               output file. 7025 bytes, compiled (10-24-95)
 **************************************************************************/

#INCLUDE ['tsgrep.inc']

/**************************************************************************
    DECLARATIONS - Constant, Integer, String
 **************************************************************************/

STRING
    padchar[1]='Ä'

/**************************************************************************
    DECLARATIONS - Forward Procedures and Menus
 **************************************************************************/
    // none //

/**************************************************************************
 **************************************************************************
    PROCEDURES
 **************************************************************************
 **************************************************************************/

proc                        main()
    string
        x_line_mode[18] = ''
    integer
        sc = Query(ScreenCols)/2,
        sr = Query(ScreenRows)/2

    get_globals()
    case getFlag(SEARCH_ACROSS_LINES)
        when FAST, AUTO_FAST    x_line_mode = ' [fast x-line]'
        when SLOW, AUTO_SLOW    x_line_mode = ' [slow x-line]'
    endcase

    Set(Cursor,Off)
    HideMouse()
    a = Set(Attr,0)
    ClrScr()
    if use_tsgrep_colors == TRUE
        Set(Attr, COLOR (RED ON WHITE))
    endif
    PopWinOpen( sc-35, sr-9,
                sc+35, sr+11,
                1, '', Query(TextAttr))
    ClrScr()
    PopWinOpen( sc-34, sr-8,
                sc+34, sr+10,
                6, '', Query(TextAttr))
    ClrScr()
    PopWinOpen( sc-32, sr-6,
                sc+32, sr+8,
                6, '', Query(TextAttr))
    ClrScr()
    Set(Attr,a)
/*
    Place header in outfile.
*/
    statusBar('Writing headers...',0,0,IN_WINDOW)
    GotoBufferId(oid)
    AddLine('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿')
    AddLine('³ TSGREP v' + v +
            ' ... David Marcus' +
              Format(GetDateStr() + " " + GetTimeStr():18) +" ³")
    AddLine('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ')
    AddLine("         Searchstring: [" + sstring + "]")
    AddLine("              Options: [" + options
                                      + iif(length(ts_options),'] [','')
                                      + ts_options
                                      + ']'
                                      + x_line_mode)
    if getFlag(TSGREP_MODE) == CMDLINE
        AddLine("      Input File Spec: " + GetEnvStr('INFILE'))
    else
        AddLine("      Input File Spec: LOADED FILES " + iif(length(trim(infile)), '+ ' + infile, 'ONLY') )
    endif
    AddLine("         File created: " + outfile)
    AddLine()
    AddLine("              # Files: [")
    AddLine("            # Matches: [")
    AddLine("         Elapsed Time: [")
    AddLine(Format('' : 29 : padchar, ' Files With Matches ', '' : 29 : padchar) )
    AddLine()

/*
    Screen display
*/
    Set(Attr, Query(TextAttr))
    VGotoXY(1,2)                       WriteLine('  ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿':-54)
                                  WriteLine('  ³ TSGREP v'+v+' ... David Marcus' +
                Format(GetDateStr() + ' ' + GetTimeStr() :18)  +' ³':-54)
                                  WriteLine('  ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ':-54)
                                  WriteLine("         Searchstring: [" + sstring + "]": -99)
                                  WriteLine("              Options: [" + options
                                                                + iif(length(ts_options),'] [','')
                                                                + ts_options
                                                                + ']'
                                                                + x_line_mode:-99)
    if getFlag(TSGREP_MODE) == CMDLINE
                                  WriteLine("      Input File Spec: " + GetEnvStr('INFILE'):-99)
    else
                                  WriteLine("      Input File Spec: LOADED FILES "+ iif(length(trim(infile)), '+ ' + infile, 'ONLY') :-99 )
    endif
                                  WriteLine("         File created: " + outfile:-54)
    VGoToXY(1, files_processed_line)   WriteLine("      Files Completed: [ ]":-54)
    VGoToXY(1, hits_line)              WriteLine("            # Matches: [ ]":-54)
    VGoToXY(1, time_line)              WriteLine("         Elapsed Time: [ ]":-54)
    VgotoXY(1, abort_line)             PutLine("  <escape> to abort",63)
end

proc                        whenloaded()
    /*
        Remainder of this proc present only to
        avoid compiler messages.
    */
    if 'foo' == 'oof'
        mjoinline()
        msplitline()
        ymd(padchar)
        set_flags_to_defaults()
        set_globals()
        a = getting_dirs_line +
        files_only + list_of_dirs + list_of_filespecs +
        loading_files_line + dirs_to_be_processed + pause +
        getting_files_line +
        processing_line +
        files_loaded_line +
        dirs_found_line +
        press_any_key_line +
        val(default_ext_2) +
        val(dir_list_ext)
    endif
end
