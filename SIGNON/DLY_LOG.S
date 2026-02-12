proc mRet()
    while NumFiles()
        if FileChanged()
            UpdateDisplay()

            case YesNo("Save changes")
             when 1 SaveFile()
             when 2 AbandonFile()
             when 3 goto finish
            endcase
        else
            AbandonFile()
        endif
    endwhile
    finish:
end

keydef ret_key
    <F3>         mRet()
end

proc main()
    integer mon
           ,day
           ,year
           ,dow
           ,wrap   = Query(WordWrap)
           ,margin = Query(RightMargin)
           ,mode   = Query(CurrVideoMode)
    string srch_dte[15] = ""

    GetDate(mon, day, year, dow)    // get current date

    case dow
     when 1
        srch_dte = Format("Sun  ",mon:2:"0","-",day:2:"0","-",year:4)
     when 2
        srch_dte = Format("Mon  ",mon:2:"0","-",day:2:"0","-",year:4)
     when 3
        srch_dte = Format("Tue  ",mon:2:"0","-",day:2:"0","-",year:4)
     when 4
        srch_dte = Format("Wed  ",mon:2:"0","-",day:2:"0","-",year:4)
     when 5
        srch_dte = Format("Thu  ",mon:2:"0","-",day:2:"0","-",year:4)
     when 6
        srch_dte = Format("Fri  ",mon:2:"0","-",day:2:"0","-",year:4)
     when 7
        srch_dte = Format("Sat  ",mon:2:"0","-",day:2:"0","-",year:4)
    endcase

    Editfile("c:\daily.log")
    Set(WordWrap,On)
    Set(RightMargin,79)
    Set(CurrVideoMode,_25_lines_)


    if lFind(srch_dte,"GB")
        Down()

        repeat
            Down()
            EndLine()
        until CurrPos() == 1

        Up()
        EndLine()
    else
        BegFile()
        InsertLine()
        InsertLine()
        InsertLine(srch_dte)
        Down()
        BegLine()
    endif

    Message("Press F3 to return")
    Enable(ret_key)
    Process()
    Disable(ret_key)

    Set(WordWrap,wrap)
    Set(RightMargin,margin)
    Set(CurrVideoMode,mode)

    if GetHistoryStr(_EDIT_HISTORY_, 1) == "-edly_log"
        DelHistoryStr(_EDIT_HISTORY_, 1)
    endif
end
