/*
                             !! Multi Print !!
                         A macro to add support for
                         Multiple Printer Settings
                                  to TSE

                            version 1, 03-09-94
                      Copyright (c) 1994 David Marcus
            The author can be reached on the SemWare BBS or via
                       CompuServe Email @ 76300,3204

    Permission is granted to all persons for non-commercial distribution
    of this file and the macros and ideas contained herein provided
                   (a) credit is given to the author and
           (b) all changes not made by the author are attributed.

        Permission is granted to SemWare for commercial distribution
                        provided (a) and (b) above.

To use:

    1. Compile MULTIPRT.S.

    2. Copy PRINTERS.TSE to your TSE directory.

    3. Edit PRINTERS.TSE as desired. (See PRINTERS.TSE for necessary format.)

    4. Save PRINTERS.TSE to disk.

    5. Execute MULTIPRT. You'll be presented with a picklist of printers.
           * Press <esc> for no change
           * Select a printer and press <enter> to load
             the settings you have associated for that printer.
           * Select 'Default' to restore the printer settings that were
             active when you first executed MULTIPRT in this TSE session.

Note:

    a. MULTIPRT automatically records your default settings
       (as of 1st MULTIPRT loading during current session).
    b. You can edit PRINTERS.TSE any time during a TSE sessions.
       If you save the changes to disk, the next time you invoke MULTIPRT
       the changes will be reflected. (You don't need to reload MULTIPRT.)

*/

FORWARD integer proc iSetting()
FORWARD STRING  proc sSetting()
FORWARD STRING  proc mSubstr(STRING s, STRING t, INTEGER op)
FORWARD         proc store_settings()
FORWARD         proc restore_settings()

STRING
    printer_def_file[78] = 'printers.tse',
    default_printer[80] =  'Default',
    DV[48], HD[4], FT[4], PI[60],
    printer_name[80]
INTEGER
    AF,BM,CP,FP,LI,LM,LN,LP,LS,PA,PS,RM,TM,UF

PROC whenloaded()
    printer_def_file = SearchPath( printer_def_file, Query(TSEPath))
                            // store current defaults the 1st
    store_settings()        // time macro is used.
end

PROC main()
    INTEGER
        plbid = 0, pdbid = 0, max_width = 24, bid = GetBufferID()

    if not Length( printer_def_file ) or not FileExists(printer_def_file)
        warn('cannot find printer definition file')
        return()
    endif

    plbid = CreateTempBuffer()
    pdbid = CreateTempBuffer()

    InsertFile( printer_def_file )
    while lfind( 'PrinterName' , 'i^')
        printer_name = GetText(1,255)
        printer_name = trim(mSubStr(printer_name, '=', +1))
        AddLine(printer_name, plbid)
        max_width = iif (max_width < length(printer_name), length(printer_name), max_width)
        EndLine()
    endwhile

    GotoBufferID(plbid)
    BegFile()
    InsertLine(format(default_printer:-max_width:' '))
    if list('Printer:', max_width)
        printer_name = Trim(GetText(1,255))
        restore_settings()                      // set to default
    else
        goto end_this
    endif

    if printer_name == default_printer  // settings are already restored
        goto end_this
    endif


    GotoBufferID(pdbid)
    BegFile()
    lFind(printer_name, 'i')
    EndLine()

    PushBlock()
    UnMarkBlock()
    MarkLine()
    if not lfind( 'PrinterName' , 'i^')
        EndFile()
    endif
    MarkLine()
    if lFind('PrintAddFF', '^gli')
         Set( PrintAddFF,        iSetting() )
    endif if lFind('PrintBotMargin', '^gli')
               Set( PrintBotMargin,    iSetting() )
    endif if lFind('PrintCopies', '^gli')
               Set( PrintCopies,       iSetting() )
    endif if lFind('PrintDevice', '^gli')
               Set( PrintDevice,       sSetting() )
    endif if lFind('PrintFirstPage', '^gli')
               Set( PrintFirstPage,    iSetting() )
    endif if lFind('PrintFooter', '^gli')
               Set( PrintFooter,       sSetting() )
    endif if lFind('PrintHeader', '^gli')
               Set( PrintHeader,       sSetting() )
    endif if lFind('PrintInit', '^gli')
               Set( PrintInit,         sSetting() )
    endif if lFind('PrintLastPage', '^gli')
               Set( PrintLastPage,     iSetting() )
    endif if lFind('PrintLeftMargin', '^gli')
               Set( PrintLeftMargin,   iSetting() )
    endif if lFind('PrintLineNumbers', '^gli')
               Set( PrintLineNumbers,  iSetting() )
    endif if lFind('PrintLineSpacing', '^gli')
               Set( PrintLineSpacing,  iSetting() )
    endif if lFind('PrintLinesPerPage', '^gli')
               Set( PrintLinesPerPage, iSetting() )
    endif if lFind('PrintPause', '^gli')
               Set( PrintPause,        iSetting() )
    endif if lFind('PrintRightMargin', '^gli')
               Set( PrintRightMargin,  iSetting() )
    endif if lFind('PrintTopMargin', '^gli')
               Set( PrintTopMargin,    iSetting() )
    endif if lFind('PrintUseFF', '^gli')
               Set( PrintUseFF,        iSetting() )
    endif
    PopBlock()
  end_this:
    GotoBufferID(bid)
    AbandonFile(plbid)
    AbandonFile(pdbid)
end

INTEGER PROC iSetting()
    /*
        Returns integer setting from current line.
        Recognizes on, off, false, true, yes, no
    */
    STRING s[64] = mSubStr(GetText(1,SizeOf(s)), '=', +1)
    s = trim(s)
    if Pos(Lower(s), 'on true yes')
        return(TRUE)
    elseif Pos(Lower(s), 'off false no')
        return(FALSE)
    else
        return(val(s))
    endif
end

STRING PROC sSetting()
    INTEGER l
    STRING s[100] = mSubStr(GetText(1,SizeOf(s)), '=', +1)
    s = trim(s)
    l = Length(s)
    if s[1] == '"' or s[1] == "'"
        s = SubStr(s,2,l-1)
    endif
    l = Length(s)
    if s[l] == '"' or s[l] == "'"
        s = SubStr(s,1,l-1)
    endif
    return(s)
end

STRING PROC mSubstr(STRING s, STRING t, INTEGER op)
     integer p = Pos(t,s), lt = Length(t)
     if     op == -1 return(iif(p, substr(s,1,p-1), s ))
     else            return(iif(p, substr(s,p+lt,Length(s)-(p+lt)+1), ''))
     endif
     return('!!MsubSTRoooops!!')
end

PROC store_settings()
    AF = Query( PrintAddFF )            BM = Query( PrintBotMargin )
    CP = Query( PrintCopies )           DV = Query( PrintDevice )
    FP = Query( PrintFirstPage )        FT = Query( PrintFooter )
    HD = Query( PrintHeader )           LI = Query( PrintLinesPerPage )
    LM = Query( PrintLeftMargin )       LN = Query( PrintLineNumbers )
    LP = Query( PrintLastPage )         LS = Query( PrintLineSpacing )
    PI = Query( PrintInit )             PS = Query( PrintPause )
    RM = Query( PrintRightMargin )      TM = Query( PrintTopMargin )
    UF = Query( PrintUseFF )
end

PROC restore_settings()
  Set( PrintAddFF,        AF )  Set( PrintBotMargin,    BM )
  Set( PrintCopies,       CP )  Set( PrintDevice,       DV )
  Set( PrintFirstPage,    FP )  Set( PrintFooter,       FT )
  Set( PrintHeader,       HD )  Set( PrintInit,         PI )
  Set( PrintLastPage,     LP )  Set( PrintLeftMargin,   LM )
  Set( PrintLineNumbers,  LN )  Set( PrintLineSpacing,  LS )
  Set( PrintLinesPerPage, LI )  Set( PrintPause,        PA )
  Set( PrintRightMargin,  RM )  Set( PrintTopMargin,    TM )
  Set( PrintUseFF,        UF )
end
