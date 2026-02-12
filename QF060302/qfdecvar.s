/*
Program....: qfDecVar
Version....: 3.5
Author.....: Randy Wallin & Ryan Katri
Date.......: 08/04/95  10:07 am  Last Modified: 09/06/95 @ 02:21 pm
Notice.....: Copyright 1993 COB System Designs, Inc., All Rights Reserved.
QFRestore..: ¯1,1®
Compiler...: TSE 2.5
Abstract...: Declares a variable as either Private or Local


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

#include ["QFLocal.inc"]
#include ["QFMsg.inc"]
//
// Create LOCAL/PRIVATE declaration
//
// Parameters:
//   cDeclareWords = Words which designate a var declaration (separated by '|')
//
// Example:
//   oFile.AddDeclaration("|LOCAL|LOCA|", "cName")
//   oFile.AddDeclaration("|PRIVATE|PRIVAT|PRIVA|PRIV|", "cName")
//

#define LOCAL_NEW    1
#define LOCAL_APPEND 2

#define FOUND_NONE   0
#define FOUND_LOCAL  1
#define FOUND_PROC   2


Proc QFDecVariable()


   string cWord[50], cVar[50], cToInsert[100] = "", cDeclareWord[20] = ""
   integer nFound, nAction

   if not (CurrExt() in ".prg", ".frg", ".spr", ".mpr", ".fmt")
      QFMessage(NO_FILEEXT_LOC, 3, FALSE)
      return()
   endif
   cDeclareWord = GetGlobalStr("gcDeclareWord")
   if not Length(cDeclareWord)>0
      return()
   endif // not Length(cDeclareWord)>0

   PushBlock()
   PushPosition()

   if IsWhite() or CurrChar() == -1
      left()
   endif

   cWord = GetWord()
   if not MarkWord()
      PopPosition()
      PopBlock()
      return()
   endif

   cVar = GetMarkedText()

   nFound = FOUND_NONE
   repeat
      if GetText(PosFirstNonWhite(), 1) in 'A'..'Z', 'a'..'z'

         BegLine()
         GotoPos(PosFirstNonWhite())
         cWord = upper(GetWord())
         if cWord in cDeclareWord
            nFound = FOUND_LOCAL
            break
         else
            if cWord in "FUNCTION", "PROCEDURE", "PARAMETERS", "LPARAMETERS",
                        "PARAMETER", "LPARAMETER", "PROC", "FUNC", "PARA",
                        "LPAR", "FUNCTIO", "FUNCTI", "PROCEDUR", "PROCEDU",
                        "PROCED", "PROCE", "PARAMETE", "PARAMET", "PARAME",
                        "PARAM", "LPARAMETE", "LPARAMET", "LPARAME", "LPARAM"
               nFound = FOUND_PROC
               break
            else
               if cWord in "PROTECTED", "PROTECTE", "PROTECT", "PROTEC", "PROTE", "PROT"
                  WordRight()
                  cWord = upper(GetWord())
                  if cWord in "FUNCTION", "PROCEDURE", "PROC", "FUNC", "FUNCTIO", "FUNCTI", "PROCEDUR", "PROCEDU", "PROCED", "PROCE"
                     nFound = FOUND_PROC
                     break
                  endif
               endif
            endif
         endif
      endif
   until not up()


   case nFound
      when FOUND_LOCAL

      	// -- Check to make sure it's not already defined
         if pos(upper(cVar + ","), upper(GetText(1, 255) + ",")) > 0
            PopPosition()
            PopBlock()
            Message(DECL_DUPL_LOC + " " + cDeclareWord + ":" + cVar)
            return()
         endif

      	// -- If there's a comment on this line, then create a new LOCAL
      	if pos("&", GetText(1, 255)) > 0
            AddLine()
      		nAction = LOCAL_NEW
         else
            nAction = LOCAL_APPEND
            cToInsert = ", " + cVar
            EndLine()
         endif


      when FOUND_PROC
      	// -- Determine what the indentation is
         cToInsert = GetText(1, PosFirstNonWhite() - 1)

      	// -- Create a LOCAL list starting on the next line
         AddLine()
         BegLine()
         nAction = LOCAL_NEW

      when FOUND_NONE
         cToInsert = ""
      	// -- Skip past comments at beginning of file
         repeat
            if GetText(PosFirstNonWhite(), 1) <> "*"
               break
            endif
         until not down()

         if GetText(PosFirstNonWhite(), 1) == "*"
            AddLine()
         else
            InsertLine()
         endif
         BegLine()
         nAction = LOCAL_NEW


   endcase

   if nAction == LOCAL_APPEND
   	cToInsert = ", " + cVar
   else
   	cToInsert = cToInsert + cDeclareWord + " " + cVar
   endif

   InsertText(cToInsert)
   PopPosition()
   Message(DECL_ADDED_LOC + " " + cDeclareWord + ":" + cVar)

   PopBlock()
end QFDecVariable

proc Main()
   QFDecVariable()
end Main

