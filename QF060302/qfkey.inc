/*
Program....: qfkey.inc
Version....: 3.5
Author.....: Randy Wallin & Ryan Katri
Date.......: 01/31/93  09:51 pm        Last Modified: 08/30/95 @ 08:10 am
Notice.....: Copyright 1993 COB System Designs, Inc., All Rights Reserved.
Compiler...: TSE 2.5
Abstract...: Key file for QF Macros
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

KeyDef TempQFKeys
     <Alt \>                       ExecMacro("qf")
end TempQFKeys

KeyDef QFKeys
   <Alt GreyCursorRight>         QFNextBlank(FALSE)
   <Alt GreyCursorLeft>          QFNextBlank(TRUE)
   <Alt 1>                       QFComment(FALSE)        // Comment UnComment
   <Alt 2>                       QFScrCounter()          // Screen Counter
   <Alt 3>                       ExecMacro("QFFlow")     // Don't KNow Flow
   <Alt 6>                       ExecMacro("QFX")        // Load Index Key
   <Alt 7>                       ExecMacro("qfDbf")      // Dbf Structure
   <Alt 8>                       ExecMacro("qfZip")      // Zip View Structure
   <Alt 9>                       ExecMacro("QFDir")      // DIR Program
   <Alt 0>                       ExecMacro("qfProj")      // Proj Structure
   <Alt F5>                      QFDeclare("LOCAL")
   <Alt F6>                      QFDeclare("PRIVATE")
   <Alt b>                       ExecMacro("QFBuff")     // Buffer List
   <Alt f>                       QFDispFile("")          // Display File Attributes
   <Alt />                       QFMenu()                // QF Menu
   <Alt \>                       QFUnload()              // QF Toggle Off/On
   <Alt F11>                     QFOpenCfg(TRUE)         // Edit QF.CFG
   <Alt F12>                     QFOpenCfg(FALSE)        // Reload QF.CFG
   <CenterCursor>                QFWhereAmI()            // Where Am I
   <Ctrl F1>                     ExecMacro("QFExpHlp")   // Expand Help
   // Changed on 08/10/93 added a business style commenter.
   <Ctrl 1>                      QFComment(TRUE)         // Comment UnComment
   <Ctrl 2>                      QFShowChanged()         // Show Changed
   <Ctrl 9>                      QFQuickDir()            // Quick DIR Program
   <Ctrl Enter>                  QFOurSave(FALSE)        // Save File
   <Ctrl GreyEnter>              QFOurSave(FALSE)        // Save File
   <Ctrl e>                      QFNewFile("")           // Load File
   <Ctrl k>                      QFKillRestore()         // Kill/Restore
   <Ctrl n>                      QFNewHeader(FALSE)      // New Header
   <Ctrl t>                      ExecMacro("QFNote")     // NotePad
   <Ctrl s>                      QFQuickSave(TRUE)       // Save All Modified FIles
   <Shift '>                     QFMatch('""')
   <Shift 9>                     QFMatch("()")
   <Shift [>                     QFMatch("{}")
   <[>                           QFMatch("[]")
   <Spacebar>                    QFExpand(FALSE)
   <Alt BackSpace>               QFExpand(TRUE)          // Abbreviation Expansion Shortcut
end QFkeys

KeyDef QFBriefKeys
   <Ctrl ->                      QuitFile()
   <Del>                         QFDelete()
   <Home>                        Qhome()
   <End>                         Qend()
end QFBriefKeys

