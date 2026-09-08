/****************************************************************************\

    Find pipe macro for TSE filter

    Usage:          find  [-x] expr

    Version         v1.00/19.10.95
    Copyright       (c) 1995 by DiK

    History

    v1.00/19.10.95  first version

\****************************************************************************/

proc main()
    string opt[1] = ""
    string cmd[128] = Query(MacroCmdLine)
    //
    IF NOT YesNo( Format( "This will run a capture via filt100\find.s. Abandon all files first as it might affect your working files." ) )
     Halt
    ENDIF
    //
    if Lower(GetToken(cmd," ",1)) == "-x"
        opt = "x"
    endif
    if Length(opt)
        cmd = DelStr(cmd,1,3)
    endif

    loop
        if lFind(cmd,"cg"+opt)
            if not Down()
                break
            endif
        else
            MarkLine()
            if lFind(cmd,opt)
                Up()
                KillBlock()
            else
                EndFile()
                KillBlock()
                break
            endif
        endif
    endloop
end

