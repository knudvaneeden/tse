/****************************************************************************\

    TSEFileB.S

    Start file manager in batch mode

    Version         v3.10/28.04.95
    Copyright       (c) 1994,95 by DiK

    History

    v3.10/28.04.95  extended version (file compare)

\****************************************************************************/

proc main()
    integer id = GetBufferId()

    if CurrFilename() == "++unnamed++"
        ExecMacro("TSEFile")
        AbandonFile(id)
        if NumFiles() == 0
            Set(RestoreDirOnExit,OFF)
            AbandonEditor()
        endif
    else
        Alarm()
        Warn("TSEFileB can only be executed by TSEFile.BAT")
    endif
    PurgeMacro(CurrMacroFilename())
end
