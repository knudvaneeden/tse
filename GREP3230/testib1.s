/****************************************************************************\

    TestIB1.S

    Example input box

    Version         v2.00/24.10.96
    Copyright       (c) 1995-96 by DiK

    History

    v2.00/24.10.96  maintenance
    v1.20/25.03.96  maintenance
    v1.10/12.01.96  maintenance
    v1.00/11.10.95  first version

\****************************************************************************/

#include "dialog.si"

helpdef hello
    "Hello, World!"
end

public proc TestIB1Help()
    QuickHelp(Hello)
end

proc Main()
    string text[128]

    Set(break,ON)
    ExecMacro(Format(
        "InpBox ",
//          "0",Chr(13),
        _FIND_HISTORY_,Chr(13),
        "Input Box Title",Chr(13),
        "Input Box Prompt",Chr(13),
        "text to start with"
        ,Chr(13),"TestIB1Help"
    ))
    text = Query(MacroCmdLine)
    Warn("return code = ",Asc(text[1]),", text = ",text[2..Length(text)])
    PurgeMacro(CurrMacroFilename())
end

