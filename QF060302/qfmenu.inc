/*
Program....: qfmenu.inc
Version....: 3.5
Author.....: Randy Wallin
Date.......: 01/31/93  09:50 pm        Last Modified: 08/30/95 @ 08:10 am
Notice.....: Copyright 1993 COB System Designs, Inc., All Rights Reserved.
Compiler...: TSE 2.5
Abstract...: Quiet Flight's Menu
QFRestore..: Ø1,1Æ
Changes....:
€ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ€
€ This program is a part of a series of macros written by COB System Designs€
€ for TSE/*Base users...these are not public domain but are for sale at a   €
€ reasonable price of $69.00. Please support the work involved in writing   €
€ these programs.                                                           €
€ For sales information and technical support, call SEMWARE Corporation:    €
€                                                                           €
€ MAIL: SemWare Corporation               FAX: (770) 640-6213               €
€       730 Elk Cove Court                                                  €
€       Kennesaw, GA  30152-4047  USA                                       €
€                                         InterNet: sales@semware.com       €
€                                                   qf.support@semware.com  €
€ PHONE (SALES ONLY): (800) 467-3692      OTHER VOICE CALLS: (770) 641-9002 €
€          Inside USA, 9am-5pm ET                              9am-5pm ET   €
€‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹€
*/

menu QFCfgMenu()
    Title="Configuration Menu"
   "&Edit QF.CFG          <Alt F11>",QFOpenCfg(TRUE)     ,   CloseAllBefore
   "&Reload QF.CFG        <Alt F12>",QFOpenCfg(FALSE)    ,   CloseAllBefore
   "&About Quiet Flight            ",QFAbout()           ,   CloseAllBefore
end QFCfgMenu
menu QFDbMoreMenu()
    Title="Additional xBase Utilities"
   "Add &PRIVATE Declaration <Alt F6>",QFDeclare("PRIVATE") ,   CloseAllBefore
   "Add &LOCAL Declaration   <Alt F5>",QFDeclare("LOCAL")   ,   CloseAllBefore
   "Color &Table                   ",ExecMacro("QFCOLOR") ,   CloseAllBefore
   "&Update Row/Col                ",ExecMacro("QFROWCOL"), CloseAllBefore

end  QFDbMoreMenu

menu QFGenMoreMenu()
    Title="Additional Generic Utilities"
   "Show C&hanged           <Ctrl 2>",QFShowChanged()       ,   CloseAllBefore
   "&Screen Counter         <Alt 2>",QFScrCounter()        ,   CloseAllBefore
   "&Window Size                   ",ExecMacro("QFBLOCK")  ,   CloseAllBefore
   // "&Generate Screen               ",ExecMacro("QFGENSCR") ,   CloseAllBefore
end QFGenMoreMenu

menu QFMenu()
   Title = "Quiet Flight Menu"
   X = 10
   Y = 3
   "&Comment Block          <Alt 1>",QFComment(FALSE)      ,   CloseAllBefore
   "&New File Header        <Ctrl n>",QFNewHeader(FALSE)      ,   CloseAllBefore
   "Expansion &Help         <Ctrl F1>",ExecMacro("QFEXPHLP")  ,   CloseAllBefore
   "More &1......                  ",QFGenMoreMenu()   ,   DontClose
   "xBase Utilities",,Divide
   "&DBF Structure          <Alt 7>",ExecMacro("QFDBF") ,   CloseAllBefore
   "&Index Key Lister       <Alt 6>",ExecMacro("QFX")   ,   CloseAllBefore
   "&Flow                   <Alt 3>",ExecMacro("QFFLow"),   CloseAllBefore
   "More &2......                  ",QFDbMoreMenu()      ,DontClose
   "File Management",,Divide
   "&Buffer List            <Alt b>",ExecMacro("QFBuff")  ,   CloseAllBefore
   "Project Management     <Alt 0>",ExecMacro("QFProj")  ,   CloseAllBefore
   "Directory Management   <Alt 9>",ExecMacro("QFDIR")   ,   CloseAllBefore
   "&Zip View               <Alt 8>",ExecMacro("QFZip")   ,   CloseAllBefore
   "Display &File Info      <Alt f>",QFDispFile("")       ,   CloseAllBefore
   "&Kill Restore File      <Ctrl k>",QFKillRestore()      ,   CloseAllBefore
   "Save All &Modified      <Ctrl s>",QFQuickSave(TRUE)    ,   CloseAllBefore
   "Note &Pad               <Ctrl t>",ExecMacro("QFNote")  ,   CloseAllBefore
   "&Where am I?            <Num 5>",QFWhereAmI()         ,   CloseAllBefore
   "&Edit Configuration           ",QFCfgMenu()          ,DontClose
   "&Unload QF              <Alt \>",QFUnload()           ,   CloseAllBefore
end QFMenu
