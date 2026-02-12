/****************************************************************************\

    TestDlg3.S

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

#include "testdlg3.si"
#include "msgbox.si"
#include "dialog.si"

/****************************************************************************\
    dialog resource
\****************************************************************************/

#include "testdlg3.dlg"

/****************************************************************************\
    list data
\****************************************************************************/

datadef cmb_data
    "Berlin"
    "London"
    "Montreal"
    "Paris"
    "Rome"
    "Tokyo"
    "Washington"
end

datadef lst_data
    "Canada"
    "France"
    "Germany"
    "Great Britain"
    "Italy"
    "Japan"
    "United States"
end

/****************************************************************************\
    global variables
\****************************************************************************/

integer en
integer cmb_buff
integer lst_buff

/****************************************************************************\
    preset and retrieve dialog data
\****************************************************************************/

public proc Test3DataInit()
    ExecMacro(Format("DlgSetData ",id_combo," ",cmb_buff))
    ExecMacro(Format("DlgSetData ",id_list ," ",lst_buff))
end

/****************************************************************************\
    answer double click in list box
\****************************************************************************/

public proc Test3DblCLick()
    Alarm()
end

/****************************************************************************\
    actions taken on pressed buttons
\****************************************************************************/

proc IdBtnTest()
    en = not en
    ExecMacro(Format("DlgSetEnable ",id_text1," ",en))
    ExecMacro(Format("DlgSetEnable ",id_combo," ",en))
    ExecMacro(Format("DlgSetEnable ",id_open1," ",en))
    ExecMacro(Format("DlgSetEnable ",id_text2," ",en))
    ExecMacro(Format("DlgSetEnable ",id_list," ",en))
    ExecMacro(Format("DlgSetEnable ",id_scroll," ",en))
    if en
        ExecMacro(Format("DlgSetTitle ",id_enable," &Disable"))
        ExecMacro(Format("DlgSetHint ",id_enable," Disable the lists"))
    else
        ExecMacro(Format("DlgSetTitle ",id_enable," &Enable"))
        ExecMacro(Format("DlgSetHint ",id_enable," Enable the lists"))
    endif
end

public proc Test3BtnDown()
    case CurrChar(POS_ID)
        when id_enable  IdBtnTest()
        otherwise       ExecMacro("DlgTerminate")
    endcase
end

/****************************************************************************\
    main program
\****************************************************************************/

proc Main()
    integer dlg
    string cmb_text[128]
    string lst_text[128]

    Set(break,ON)

    en = TRUE

    cmb_buff = CreateTempBuffer()
    InsertData(cmb_data)
    UnmarkBlock()
    BegFile()

    lst_buff = CreateTempBuffer()
    InsertData(lst_data)
    UnmarkBlock()
    BegFile()

    dlg = CreateTempBuffer()
    InsertData(testdlg3)
    ExecMacro("dialog test3")
    AbandonFile(dlg)

    GotoBufferId(cmb_buff)
    cmb_text = GetText(1,CurrLineLen())
    AbandonFile()

    GotoBufferId(lst_buff)
    lst_text = GetText(1,CurrLineLen())
    AbandonFile()

    ExecMacro(Format(
        "MsgBox ",
        Chr(MB_INFO),
        Chr(MB_OK),
        Chr(CNTRL_LTEXT),"return code = ",Query(MacroCmdLine),Chr(13),
        Chr(CNTRL_LTEXT),"combo box item = ",cmb_text,Chr(13),
        Chr(CNTRL_LTEXT),"list  box item = ",lst_text
    ))

    PurgeMacro(CurrMacroFilename())
end

