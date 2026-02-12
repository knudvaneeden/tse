// ****************************************************************************/
//
// 02-12-93: Submitted by Don Dougherty (Msg 6266 Cnf 15)
// 03-09-93: KAC - Rewritten, commented, and tested.
// 7 Apr 93: ggc - addition for environmental variable.
//
// Macro to Execute Share Spell on the current file
//
// ASSUMPTIONS: ShareSpell is installed and located in the current directory
//              or along the users path.  The name of the Share Spell
//              executable is "SS.EXE"
//
// PARAMETERS:  none
//
// RETURNS:     nothing
//
// GLOBAL VARS: none
//
// LOCAL VARS:  cfilename   - string that is loaded with the current filename
//              cline       - current line in file
//              cpos        - current pos in file
//              cxofs       - current XOffset in window
//              crow        - current row in window
//
proc Main()
    integer cline, cpos, cxofs, crow
    string  cfilename[128] = CurrFileName(),
            env[30] = GetEnvStr("SS")    // environment path to SS.exe
                                         // ggc 7 Apr 93
    if isChanged() and not SaveFile()
        //
        // If file has been changed and we could not save it, then we should
        // immediately return without attempting to call ShareSpell.
        //
        return()
    endif

    if not Length(env)      // if there is no EV then use current dir
       env = LoadDir()      // ggc 7 apr 93
    endif

    cline = CurrLine()      // this saves our position in the file
    cpos = CurrPos()
    cxofs = CurrXOffset()
    crow = CurrRow()
    PushBlock()             // just in case a block is currently marked
    Dos(env+"\SS "+cfilename, _DONTPROMPT_)    // call ShareSpell
    AbandonFile()           // get rid of the file so we can reload it
    EditFile(cfilename)     // reloads the file from disk
    GotoLine(cline)         // restore our position in the file
    GotoPos(cpos)
    GotoXOffset(cxofs)
    ScrollToRow(crow)
    PopBlock()              // restore block, if one was marked
end
//
// End of ShareSpell()
