/****************************************************************************\

    TestMB1.S

    Example message box

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
//          Chr(MB_OK),
//          Chr(MB_CANCEL),
//          Chr(MB_OKCANCEL),
//          Chr(MB_YESNO),
        Chr(MB_YESNOCANCEL),
        Chr(MB_TITLE),"some user defined title",Chr(13),
        Chr(CNTRL_LTEXT),"some text flush left",Chr(13),
        Chr(CNTRL_CTEXT),"some text centered in the middle",Chr(13),
        Chr(CNTRL_RTEXT),"some text flush right"
    ))
    Warn("return code = ",Query(MacroCmdLine))
    PurgeMacro(CurrMacroFilename())
end

