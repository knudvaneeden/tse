/*
Program....: qfdefine.s
Version....: 3.5
Author.....: Randy Wallin & Ryan Katri
Date.......: 04/23/94  08:54 am  Last Modified: 08/30/95 @ 07:58 am
Notice.....: Copyright 1994 COB System Designs, Inc., All Rights Reserved.
QFRestore..: ¯1,1®
Compiler...: TSE v2.50
Abstract...: Quick build routine for DEFINE
Changes....:
ÛßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßÛ
Û This program is a part of a series of macros written by COB System DesignsÛ
Û for TSE/*Base users...these are not public domain but are for sale at a   Û
Û reasonable price of $69.00. Please support the work involved in writing   Û
Û these programs.                                                           Û
Û For sales information and technical support, call SEMWARE Corporation:    Û
Û                                                                           Û
Û MAIL: SemWare Corporation               FAX: (770) 640-6213               Û
Û       730 Elk Cove Court                                                  Û
Û       Kennesaw, GA  30152-4047  USA                                       Û
Û                                         InterNet: sales@semware.com       Û
Û                                                   qf.support@semware.com  Û
Û PHONE (SALES ONLY): (800) 467-3692      OTHER VOICE CALLS: (770) 641-9002 Û
Û          Inside USA, 9am-5pm ET                              9am-5pm ET   Û
ÛÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÛ

*/

proc qfDefine()
     string cSuffix[20]=""
     string cPrefix[20]=""
     string cValue[100]=""
     string cLine[100]=""
     string cComment[100]=""
     string cColumnValue[3]="34"
     string cColumnComment[3]="44"
     string cInline[4]=""

     integer nContinue=1
     integer nColumnValue=34
     integer nColumnComment=44
     case CurrExt()
          when ".cpp", ".s", ".ch", ".inc", ".c", ".h", ".cb"
              cInLine="// "
          when ".prg",".frg",".spr",".mpr",".fmt"
              cInLine="&& "
          otherwise
              cInLine=" ** "
      endcase

     if ask("Enter Define Prefix: Example ECO_",cPrefix)
        if ask("Place Value Declared at Column? ",cColumnValue)
           nColumnValue=VAL(cColumnValue)
           if ask("Comment offset? Set to 0 for No Comments.",cColumnComment)
              nColumnComment=VAL(cColumnComment)

              while nContinue
                  if ask("Enter Define Suffix: "+cPrefix,cSuffix)
                     if ask("Enter Value for "+cPrefix+cSuffix+":",cValue)
                        cLine="#DEFINE "+cPrefix+cSuffix
                        AddLine()
                        Down()
                        BegLine()
                        InsertText(cLine, _INSERT_)
                        GotoColumn(nColumnValue)
                        InsertText(cValue)
                        if nColumnComment>0
                           if ask("Enter Comment for "+cPrefix+cSuffix+" = "+cValue,cComment)
                              GotoColumn(nColumnComment)
                              InsertText(cInline+cComment)
                           endif // ask("Enter Comment for "+cPrefix+cSuffix+" = "+cValue,cComment)
                        endif // nColumnComment>0
                        UpdateDisplay()
                        BegLine()
                     else
                        nContinue=0
                     endif // ask("Enter Value for "+cPrefix+"_"+cSuffix+":",cValue)

                  else
                     nContinue=0
                  endif // ask("Enter Define Suffix: "+cPrefix+"_",cSuffix)
              endwhile // nContinue
           endif // ask("Comment offset?",cColumnComment)
        endif // ask("Column for Declaration?",cColumnValue)
     endif // ask("Enter Define Prefix",cPrefix)
end qfDefine

proc Main()
   QFDefine()
end Main

