/****************************************************************************\

    Hello.S

    Example dialog

    Version         v2.00/24.10.96
    Copyright       (c) 1995-96 by DiK

    History

    v2.00/24.10.96  maintenance
    v1.20/25.03.96  maintenance
    v1.10/12.01.96  maintenance
    v1.00/11.10.95  first version

\****************************************************************************/

#include "msgbox.si"
#include "dialog.si"

proc Main()
    Set(break,ON)
    ExecMacro(Format(
        "MsgBox ",
        Chr(MB_OK),
        Chr(MB_NOTITLE),
        Chr(CNTRL_CTEXT),"Hello, World!"
    ))
    PurgeMacro(CurrMacroFilename())
end

