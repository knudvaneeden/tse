/****************************************************************************\

    TFECompB.S

    Start file comparison in batch mode

    Version         v2.00/28.04.95
    Copyright       (c) 1994,95 by DiK

    History

    v2.00/28.04.95  interface to TSEFile

    Remark:

    The first filename in the editor command line ($ÿÿÿÿÿÿ$.$ÿ$)
    includes the ascii character #255. This is a dirty trick, to
    convince TSECompB.MAC that it has been executed by TSEComp.BAT.

\****************************************************************************/

/****************************************************************************\
    session global variables
\****************************************************************************/

string  target[] = "TSEF3-target"

/****************************************************************************\
    main function
\****************************************************************************/

proc main()
    if SplitPath(CurrFilename(),_NAME_|_EXT_) == "$ÿÿÿÿÿÿ$.$ÿ$"

        AbandonFile()                           // get rid of dummy
        LoadMacro("TSEComp")                    // load compare macro

        SetGlobalStr(target,CurrFilename())     // set right filename
        ExecMacro("TC_SetRightName")
        NextFile()                              // load left file
        SetGlobalStr(target,CurrFilename())     // set left filename
        ExecMacro("TC_SetLeftName")

        ExecMacro("TSEComp")                    // execute compare macro

        if NumFiles() == 0                      // quit after flush
            AbandonEditor()
        endif

    else

        Alarm()
        Warn("TSECompB can only be executed by TSEComp.BAT")

    endif
    PurgeMacro(CurrMacroFilename())
end

