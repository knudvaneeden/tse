/*
Program....: qfrestor.inc
Version....: 3.5
Author.....: Randy Wallin & Ryan Katri
Date.......: 08/04/93  04:28 pm  Last Modified: 08/30/95 @ 08:10 am
Notice.....: Copyright 1993 COB System Designs, Inc., All Rights Reserved.
QFRestore..: Ø1,1Æ
Compiler...: TSE 2.5
Abstract...: Our Restore Position Macro, called by QFEditFile in QF.S and
             QFPROJ.S.
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

Integer proc QFRestore()
    string cQFRestore[20]=""
    integer nGotoLine,
            nGotoCol,
            nError = 0

    if (QFGetOnOff("GENERAL", "Restore", nError) or not GetGlobalInt("nExpandBuf")) and lFind("QFR.@Ø\c[0-9].@Æ","ixg")
       cQFRestore=GetText(CurrCol(),20)
       nGotoLine=Val(SubStr(cQFRestore,1,pos(",",cQFRestore)-1))
       nGotoCol=Val(SubStr(cQFRestore,pos(",",cQFRestore)+1,10))
       if nGotoLine
          GotoLine(nGotoLine)
          GotoColumn(nGotoCol)
          ScrollToRow(Query(WindowRows) / 2)
          Return(TRUE)
       endif // nGotoLine
    endif // lFind()
    RETURN(FALSE)
end QFRestore

