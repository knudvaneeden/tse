/****************************************************************************\

    TestDlg1.S

    Example dialog

    Version         v2.00/24.10.96
    Copyright       (c) 1995-96 by DiK

    History

    v2.00/24.10.96  maintenance
    v1.20/25.03.96  maintenance
    v1.10/12.01.96  maintenance
    v1.00/11.10.95  first version

\****************************************************************************/

/****************************************************************************\
    global constants
\****************************************************************************/

#include "testdlg1.si"
#include "dialog.si"

/****************************************************************************\
    dialog resource
\****************************************************************************/

#include "testdlg1.dlg"

/****************************************************************************\
    global variables
\****************************************************************************/

integer en
integer count
string t1[64]
string t2[64]
string text[64]

/****************************************************************************\
    preset and retrieve dialog data
\****************************************************************************/

public proc Test1DataInit()
    ExecMacro(Format("DlgSetData ",id_edit1," ",_EDIT_HISTORY_))
    ExecMacro(Format("DlgSetData ",id_check03," 1"))
    ExecMacro(Format("DlgSetData ",id_radio51," 1"))
    ExecMacro(Format("DlgSetData ",id_check60," 1"))
    ExecMacro(Format("DlgSetData ",id_check62," 1"))
end

public proc Test1DataDone()
    ExecMacro(Format("DlgGetTitle ",id_edit1))
    text = Query(MacroCmdLine)
end

/****************************************************************************\
    actions taken on pressed buttons
\****************************************************************************/

proc IdBtnTest()

    // toggle check box title

    ExecMacro(Format("DlgGetTitle ",id_text03))
    t1 = Query(MacroCmdLine)
    ExecMacro(Format("DlgSetTitle ",id_text03," ",t2))
    t2 = t1

    // toggle enable state of some controls

    ExecMacro(Format("DlgSetEnable ",id_btn_exec," ",en))
    ExecMacro(Format("DlgSetEnable ",id_text1," ",en))
    ExecMacro(Format("DlgSetEnable ",id_edit1," ",en))
    ExecMacro(Format("DlgSetEnable ",id_hist1," ",en))
//      ExecMacro(Format("DlgSetEnable ",id_radio50," ",en))
    ExecMacro(Format("DlgSetEnable ",id_radio51," ",en))
//      ExecMacro(Format("DlgSetEnable ",id_radio52," ",en))
    ExecMacro(Format("DlgSetEnable ",id_check60," ",en))
    en = not en
    ExecMacro(Format("DlgSetEnable ",id_text03," ",en))
    ExecMacro(Format("DlgSetEnable ",id_check03," ",en))
end

public proc Test1BtnDown()
    case CurrChar(POS_ID)
        when id_btn_test    IdBtnTest()
        when id_btn_exec    ExecMacro("testdlg2")
    endcase
end

public proc Test1Idle()
    count = count + 1
    Message(count)
end

/****************************************************************************\
    main program
\****************************************************************************/

proc Main()
    integer dlg

    Set(break,ON)

    en = FALSE
    t1 = ""
    t2 = "Check &Mark Title"

    dlg = CreateTempBuffer()
    InsertData(testdlg1)
    ExecMacro("dialog test1")
    AbandonFile(dlg)

    Warn("return code = ",Query(MacroCmdLine),"  text = ",text[1:30])
    PurgeMacro(CurrMacroFilename())
end

