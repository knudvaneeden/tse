/*
Program....: qfregexp.inc
Version....: 3.5
Author.....: Randy Wallin & Ryan Katri
Date.......: 07/17/93  09:26 am  Last Modified: 08/30/95 @ 08:10 am
Notice.....: Copyright 1993 COB System Designs, Inc., All Rights Reserved.
QFRestore..: Ø1,1Æ
Compiler...: TSE 2.5
Abstract...:
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
// Convert a find string to be compatible with regular expressions
string proc QFRegExpr(string cExpr)
   string cRegExpr[40]
   PushPosition()
   CreateTempBuffer()
   InsertText(cExpr)
   lReplace("\", "\\", "gn")
   lReplace("*", "\*", "gn")
   lReplace("?", "\?", "gn")
   lReplace("@", "\@", "gn")
   lReplace("&", "\&", "gn")
   lReplace("-", "\-", "gn")
   lReplace("~", "\~", "gn")
   lReplace(".", "\.", "gn")
   lReplace("|", "\|", "gn")
   lReplace("+", "\+", "gn")
   lReplace("#", "\#", "gn")
   lReplace("[", "\[", "gn")
   lReplace("]", "\]", "gn")
   lReplace("{", "\{", "gn")
   lReplace("}", "\}", "gn")
   lReplace("$", "\$", "gn")
   cRegExpr = GetText(1, 40)
   AbandonFile()
   PopPosition()
   return (cRegExpr)
end QFRegExpr


