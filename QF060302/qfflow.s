/*
Program....: qfflow.q
Version....: 3.5
Author.....: Ryan Katri / Randy Wallin
Date.......: 11/24/92  06:39 pm   Last Modified: 08/30/95 @ 07:58 am
Notice.....: Copyright COB System Designs, Inc., All Rights Reserved.
Compiler...: TSE 2.5
QFRestore..: ¯1,1®
Abstract...: Indents source code, checks for errors, etc, etc
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
#include ["QFOption.inc"]

constant
   TSE   = 1,
   DBASE = 2

constant
   INDENT_DR    = 1,   // Indent Right --> Display
   INDENT_LD    = 2,   // Indent Left  --> Display
   INDENT_LDR   = 3,   // Indent Left  --> Display --> Indent Right
   INDENT_NONE  = 4,   // No indent, no reformat
   INDENT_RDR   = 5,   // Indent Right --> Display --> Indent Right
   INDENT_LDL   = 6,   // Indent Left  --> Display --> Indent Left
   INDENT_STOP  = 7,
   INDENT_DISP  = 8,   // Display only with current indent
   INDENT_RESET = 9

// Globals
string cCommentStart[10]
string cFunction[30] = ""
integer nIndent, nMultiIndent
integer lFuncIndent, lCaseIndent, lErrorCheck, lComment, lHardTabs
integer nDebugID
integer nResetTo = 0

proc QFIndentSet(integer nSet)
   string s[1] = str(nIndent)

   if nSet > -1 or Read(s)
      nIndent = iif(nSet > -1, nSet, val(s))
   endif
end QFIndentSet

string proc QFSpaces(integer nSpaces)
   integer i = 0
   string cStr[9] = ""
   while i < nSpaces
      cStr = cStr + " "
      i = i + 1
   endwhile // i < nSpaces
   return (cStr)
end QFSpaces



proc QFToggleSet(var integer nToggle)
   nToggle = not nToggle
end QFToggleSet

string proc QFOnOffStr(integer i)
   return (iif(i, "On", "Off"))
end QFOnOffStr


menu FlowMenu()
   Title = "Quiet Flight FLOW!"
   X = 10
   Y = 5

   "&Procedure/Function"
   "&File"
   ""                          ,                   ,   Divide
   "&Indentation" [nIndent : 1], QFIndentSet(-1),   DontClose
   "Fu&nction Indent"  [QFOnOffStr(lFuncIndent) : 3], QFToggleSet(lFuncIndent),   DontClose
   "CA&SE Indent"  [QFOnOffStr(lCaseIndent) : 3], QFToggleSet(lCaseIndent), DontClose
   "&Error Check"  [QFOnOffStr(lErrorCheck) : 3], QFToggleSet(lErrorCheck), DontClose
   "&Add Comments" [QFOnOffStr(lComment) : 3], QFToggleSet(lComment), DontClose
   "&Use Hard Tabs" [QFOnOffStr(lHardTabs) : 3], QFToggleSet(lHardTabs), DontClose
   ""                          ,                   ,   Divide
   "&Cancel"
end FlowMenu



// Check for semicolon at end of line indicating continuation
integer proc QFSemiCheck()

   EndLine()
   left()
   // trim the current line
   while isWhite() and left()
   endwhile // isWhite() and left()

   return (chr(CurrChar()) == ";")

end QFSemiCheck


string proc QFGetWord(integer lUpper)
   string cWord[12] = ''

   // skip white space preceding word
   while isWhite()
      right()
   endwhile // isWhite()

   // ignore line if first character is not in our word set
   if not isWord()
      return ('')
   endif // not isWord()

   // Accumulate the word
   while isWord() and length(cWord) < sizeof(cWord)
      cWord = cWord + chr(CurrChar())
      if not Right()          // break on max line length
         break
      endif // not Right()
   endwhile // isWord() and length(cWord) < sizeof(cWord)
   right()

   if lUpper
      cWord = upper(cWord)
   endif

   return (cWord)             // and return the word
end QFGetWord


proc QFReIndent(integer nOffset)
   integer n = 0

   BegLine()

   // trim the current line
   while isWhite()
      delChar()
   endwhile // isWhite()


 	while n < nOffset
      InsertText(iif(lHardTabs, chr(09), QFSpaces(nIndent)), _INSERT_)
      n = n + 1
   endwhile // n < nOffset

end QFReIndent




// Remove indentation from comments above header
// This is a back-tracking procedure
proc QFUnHeader()
   integer lUp, nPause = FALSE
   string ch[1]

   lUp = up()
   BegLine()
   ch = GetText(PosFirstNonWhite(), 1)
   while (length(ch) == 0 or ch == "*" or ch == "&") and lUp
      nPause = GetText(PosLastNonWhite()-1, 2) == "*/"
      if not nPause
         QFReIndent(nResetTo)
      endif // not nPause
      if nPause and GetText(PosFirstNonWhite(), 2) == "/*"
         nPause = FALSE
      endif
      lUp = up()
      ch = GetText(PosFirstNonWhite(), 1)
   endwhile

end QFUnHeader



integer proc QFEndCheck()
   integer lError = FALSE

   if lErrorCheck

      PushPosition()
      GotoBufferId(nDebugId)
      lError = CurrLineLen()

      PopPosition()
   endif

   return (lError)
end QFEndCheck



integer proc QFCheckToken(string cToken)
   integer lError = FALSE

   if lErrorCheck
      PushPosition()
      GotoBufferId(nDebugID)

      lError = not pos(cToken, GetText(1, 30))

      PopPosition()
   endif
   return (lError)
end QFCheckToken


integer proc QFAddToken(string cToken)
   integer nLine
   nLine = CurrLine()

   // Changed on 09/30/93 RMK to take advantage of new syntax
   AddLine(format(cToken:-30) + format(nLine:-6), nDebugId)

   return (FALSE)
end QFAddToken


proc QFAddComment(string cComment)
   if lComment
      PushPosition()
      GotoBufferId(nDebugID)
      GotoPos(40)
      InsertText(cComment, _INSERT_)
      PopPosition()
   endif
end QFAddComment

proc QFInsertComment(string cCommand)
   string cComment[80]
   integer nSemiPos

   if lComment
      PushPosition()
      GotoBufferId(nDebugID)
      cComment = cCommand + cCommentStart + GetText(40, 80)

      // check for semi-colon at end of comment string -- we don't want it!!
      // because that makes dBase think this is a multi-line!!
      nSemiPos = pos(";", cComment)
      if nSemiPos
         cComment = substr(cComment, 1, nSemiPos-1)
      endif // nSemiPos



      PopPosition()
      DelLine()
      InsertLine(cComment)
   endif
end QFInsertComment


integer proc QFDelToken(string cToken)
   integer lError = FALSE

   PushPosition()
   GotoBufferId(nDebugID)

   if pos(cToken, GetText(1, 30))
      DelLine()
      up()
   else
      lError = TRUE
   endif

   PopPosition()

   return (lError AND lErrorCheck)
end QFDelToken


integer proc PRGindent(var integer lMultiLine, var integer nOffset,
   var integer nPause, integer nLineCnt, integer nFlowArea, var integer lError)
   integer nIndentType = INDENT_DISP
   string cWord1[14]
   string cWord2[14]
   string cComment1[80], cComment2[80], cRawWord[14]

   cRawWord = QFGetWord(FALSE)
   BegLine()
   cWord1 = "_" + QFGetWord(TRUE)+"_"
   cComment1 = GetText(CurrPos(), 80)
   cWord2 = "_" + QFGetWord(TRUE)+"_"

   cComment2 = GetText(CurrPos(), 80)


   nIndentType = iif(nPause > -1, INDENT_NONE, INDENT_DISP)


   if length(cWord1) == 2 and GetText(PosFirstNonWhite(), 2) == "/*"
      nPause = nOffset
      nIndentType = INDENT_NONE
   endif

   if nPause > - 1 and GetText(PosLastNonWhite()-1, 2) == "*/"
   	nOffset = nPause
      nPause = -1
      nIndentType = INDENT_NONE
   endif

   if not lMultiLine and nPause < 0
      if pos(cWord1, "_PROTECTED_PROTECTE_PROTECT_PROTEC_PROTE_PROT")
         cWord1 = cWord2
         cWord2 = "_" + QFGetWord(TRUE)+"_"
      endif

      if cWord1 == "_DO_" and pos(cWord2, "_WHILE_WHIL_")
         nIndentType = INDENT_DR
         lError = QFAddToken("_WHILE_END_")
         QFAddComment(cComment2)

      elseif cWord1 == "_DO_" and pos(cWord2, "_CASE_")
         nIndentType = iif(lCaseIndent, INDENT_RDR, INDENT_DR)
         lError = QFAddToken("_CASE_END_")

      elseif pos(cWord1, "_IF_FOR_SCAN_WITH_")
         nIndentType = INDENT_DR
         lError = QFAddToken(cWord1 + "END_")
         QFAddComment(cComment1)


      elseif pos(cWord1, "_ENDDE_ENDDEF_ENDDEFI_ENDDEFIN_ENDDEFINE_")
         if not QFCheckToken("_FUNC_")
            lError = QFDelToken("_FUNC_")
         endif

         if not QFCheckToken("_DEFINE_")
            lError = QFDelToken("_DEFINE_")
         endif
         nOffset = 0
         nResetTo = 0

         nIndentType = INDENT_LD

      elseif pos(cWord1, "_ENDFUNC_ENDFUN_ENDF_ENDPROC_ENDPRO_ENDPR_ENDP_")
         if lFuncIndent   // Indent within a procedure
            nIndentType = INDENT_LD
         else
            nIndentType = INDENT_DISP
         endif
         lError = QFDelToken("_FUNC_")

      elseif pos(cWord1, "_ENDDO_ENDD_")
         nIndentType = INDENT_LD
         QFInsertComment(cRawWord)
         lError = QFDelToken("_WHILE_")

      elseif pos(cWord1, "_ENDIF_ENDI_")
         nIndentType = INDENT_LD
         QFInsertComment(cRawWord)
         lError = QFDelToken("_IF_")

      elseif pos(cWord1, "_ENDWITH_ENDWI_ENDW_")
         nIndentType = INDENT_LD
         QFInsertComment(cRawWord)
         lError = QFDelToken("_WITH_")


      elseif pos(cWord1, "_ENDFOR_NEXT_ENDF_ENDFO_")
         nIndentType = INDENT_LD
         QFInsertComment(cRawWord)
         lError = QFDelToken("_FOR_")

      elseif pos(cWord1, "_ENDSCAN_ENDSCA_ENDSC_ENDS_")
         nIndentType = INDENT_LD
         QFInsertComment(cRawWord)
         lError = QFDelToken("_SCAN_")

      elseif pos(cWord1, "_ENDCASE_ENDCAS_ENDCA_ENDC_")
         nIndentType = iif(lCaseIndent, INDENT_LDL, INDENT_LD)
         lError = QFDelToken("_CASE_")

      elseif pos(cWord1, "_ELSE_")
         nIndentType = INDENT_LDR
         lError = QFCheckToken("_IF_")

      elseif pos(cWord1, "_CASE_OTHERWISE_OTHERWIS_OTHERWI_OTHERW_OTHER_OTHE_")
         nIndentType = INDENT_LDR
         lError = QFCheckToken("_CASE_")

      elseif (pos(cWord1, "_DEFINE_DEFIN_DEFI_") and pos(cWord2, "_CLASS_CLAS_"))
         nIndentType = INDENT_DR
         lError = QFAddToken("_DEFINE_END_")
         nResetTo = 1

      elseif (pos(cWord1, "_FUNCTION_PROCEDURE_PROC_FUNC_FUNCTIO_FUNCTI_FUNCT_PROCEDUR_PROCEDU_PROCED_PROCE_CONSTRUCTOR_"))
         or (pos(cWord1, "_METHOD_EXPORT_STATIC_STATI_STAT_CREATE_") and pos(cWord2, "_FUNCTION_PROCEDURE_PROC_FUNC_FUNCTIO_FUNCT_PROCEDUR_PROCEDU_PROCED_PROCE_CLASS_"))

         PushPosition()
         QFUnHeader()      // remove indentation from function header

         if not QFCheckToken("_FUNC_")
            lError = QFDelToken("_FUNC_")
            if lFuncIndent
               nIndentType = INDENT_LDR
            else
               nIndentType = INDENT_LDR
            endif
         else
            if lFuncIndent
               nIndentType = INDENT_LDR
            else
               nIndentType = INDENT_LD
            endif
         endif

         lError = QFAddToken("_FUNC_END_")

         // lError = QFEndCheck()
         if lError
            KillPosition()
         else
            PopPosition()
            cFunction = substr(cWord2, 2, length(cWord2)-2)

            nOffset = nResetTo
            if lFuncIndent   // Indent within a procedure
               nIndentType = INDENT_DR
            else
               nIndentType = INDENT_DISP
            endif

            if nFlowArea == 1 and nLineCnt > 1
               nIndentType = INDENT_STOP
            endif
         endif

      elseif pos(cWord1, "_TEXT_")
         nPause = nOffset
      endif

   endif // not lMultiLine

   if nPause > -1 and pos(cWord1, "_ENDTEXT_ENDTEX_ENDTE_ENDT_")
   	nOffset = nPause
      nPause = -1
      nIndentType = INDENT_DISP
   endif // nPause > -1 and pos(cWord1, "_ENDTEXT_ENDTEX_ENDTE_ENDT_")



   return (nIndentType)

end PRGindent


integer proc TSEindent(var integer lMultiLine, var integer nOffset,
   var integer nPause, integer nLineCnt, integer nFlowArea, var integer lError)

   integer nIndentType
   string cWord1[14]
   string cWord2[14]


   // Set these two variables so we don't get warnings when we compile
   lMultiLine = FALSE
   nPause = -1

   cWord1 = "_" + QFGetWord(TRUE)+"_"
   cWord2 = "_" + QFGetWord(TRUE)+"_"

   nIndentType = iif(nPause > -1, INDENT_NONE, INDENT_DISP)

   PushBlock()
   MarkLine()
   if lFind("\c/\*", "glx")
      nPause = nOffset
      nIndentType = INDENT_NONE
   endif // lFind("/*", "glx")


   if nPause < 0
      if cWord1 == "_CASE_"
         nIndentType = INDENT_RDR
      elseif pos(cWord1, "_IF_REPEAT_WHILE_CONFIG_LOOP_KEYDEF_")
         nIndentType = INDENT_DR
      elseif pos(cWord1, "_ENDWHILE_ENDIF_UNTIL_END_ENDCONFIG_ENDLOOP_")
         nIndentType = INDENT_LD
      elseif pos(cWord1, "_WHEN_ELSE_OTHERWISE_ELSEIF_")
         nIndentType = INDENT_LDR
      elseif cWord1 == "_ENDCASE_"
         nIndentType = INDENT_LDL
      elseif pos(cWord1, "_PROC_MACRO_MENU_MENUBAR_HELP_PUBLIC_KEYDEF_DATADEF_") or pos(cWord2, "_PROC_MACRO_FUNCTION_")
         PushPosition()
         QFUnHeader()      // remove indentation from function header

         lError = QFEndCheck()
         if lError
            KillPosition()
         else
            PopPosition()
            cFunction = substr(cWord2, 2, length(cWord2)-2)

            nOffset = 0
            if lFuncIndent   // Indent within a procedure
               nIndentType = INDENT_DR
            endif

            if nFlowArea == 1 and nLineCnt > 1
               nIndentType = INDENT_STOP
            endif
         endif
      endif
   endif // nPause < 0

   if nPause > -1 and lFind("\c\*/", "glx")
      nOffset = nPause
      nPause = -1
      nIndentType = INDENT_NONE
   endif

   PopBlock()


   return (nIndentType)

end TSEindent


proc Flow()
   integer nIndentType,
           nOffset,
           nPause,
           nLineCnt,
           lMultiLine,
           nFileType
   integer nSaveId, nKillMax
   integer nFlowArea
   integer lError = FALSE
   string cErrLine[5],
          cWord1[14], cWord2[14]


   case CurrExt()
      when ".s", ".inc"
         nFileType = TSE
      when ".prg",".spr",".mpr",".fmt"
         nFileType = DBASE
      otherwise
         QFMessage(NO_FILEEXT_LOC, 5, TRUE)
         return()
   endcase


   nFlowArea = FlowMenu()

   PushPosition()

   case nFlowArea
      when 0,11
         PopPosition()
         return()
      when 1
         BegLine()
         case nFileType
            when TSE
               while not pos("_"+QFGetWord(TRUE)+"_", "_PROC_STRING_INTEGER_") and up()
                  BegLine()
               endwhile

            when DBASE

               repeat
                  BegLine()
                  cWord1 = "_" + QFGetWord(TRUE) + "_"
                  cWord2 = "_" + QFGetWord(TRUE) + "_"

                  if pos(cWord1, "_PROTECTED_PROTECTE_PROTECT_PROTEC_PROTE_PROT")
                     cWord1 = cWord2
                     cWord2 = "_" + QFGetWord(TRUE)+"_"
                  endif
               until pos(cWord1, "_FUNCTION_PROCEDURE_PROC_FUNC_FUNCTIO_FUNCTI_FUNCT_PROCEDUR_PROCEDU_PROCED_PROCE_") or
                     (pos(cWord1, "_DEFINE_DEFIN_DEFI_") and pos(cWord2, "_CLASS_CLAS")) or not up()
         endcase
      when 2
         BegFile()
   endcase // nFlowArea

   nSaveId = GetBufferId()
   nDebugId = CreateTempBuffer()
   GotoBufferId(nSaveId)


   lMultiLine = FALSE
   nOffset = 0
   nPause = -1
   nLineCnt = 1
   nIndentType = INDENT_DISP

   // turn undelete buffer off
   nKillMax = Set(KillMax,0)

   repeat

      if not (CurrLine() mod 100)
         message(PROCESS_LINE_LOC + " " + format(CurrLine():-6))
      endif // not (nLineCnt mod 100)

      BegLine()

      case nFileType
         when TSE
            nIndentType = TSEindent(lMultiLine, nOffset, nPause, nLineCnt, nFlowArea, lError)
         when DBASE
            nIndentType = PRGindent(lMultiLine, nOffset, nPause, nLineCnt, nFlowArea, lError)
      endcase
      if not lError
         case nIndentType

            when INDENT_DR  // 1
               // display -> indent
               QFReIndent(nOffset)
               nOffset = nOffset + 1
            when INDENT_LD  // 2
               // outdent -> display
               nOffset = nOffset - 1
               QFReIndent(nOffset)
            when INDENT_LDR  // 3
               // outdent -> display -> indent
               nOffset = nOffset - 1
               QFReIndent(nOffset)
               nOffset = nOffset + 1
            when INDENT_NONE  // 4
               // no reformat
            when INDENT_RDR  // 5
               // indent -> display -> indent
               QFReIndent(nOffset)
               nOffset = nOffset + 2
            when INDENT_LDL  // 6
               // outdent -> display -> outdent
               nOffset = nOffset - 2
               QFReIndent(nOffset)
            when INDENT_STOP  // 7
               break
            otherwise
               // display
               QFReIndent(nOffset)
         endcase // nIndentType


         // Pause mode should only be set in a TEXT...ENDTEXT
         // Later on we might want to set it in comments like /* .. */
         nIndentType = iif(nPause > -1, INDENT_NONE, INDENT_DISP)

         if lMultiLine
            BegLine()
            InsertText(QFSpaces(nMultiIndent), _INSERT_)
         endif


         // check to see if this is a continuation line
         lMultiLine = (nFileType == DBASE) AND QFSemiCheck()

         nLineCnt = nLineCnt+1
      endif // not lError

   until lError or not down()

   if not QFCheckToken("_FUNC_")
      lError = QFDelToken("_FUNC_")
   endif


   // if there were no errors generated, see if there are any left-over
   // tokens, which indicate a mis-match!
   if not lError
      lError = QFEndCheck()
   endif // not lError


   GotoBufferId(nDebugId)
   cErrLine = GetText(31, 6)  // if there is an error, find originating line
   AbandonFile()
   GotoBufferId(nSaveId)

   if lError
      if not length(cErrLine)
         cErrLine = str(CurrLine())
      endif
      KillPosition()      // return to error line, not original line
      GotoLine(val(cErrLine))

      UpdateDisplay()
      QFmessage("Mismatch from Line " + cErrLine + " in " + cFunction, 0, TRUE)

   else
      message(FINISHED_LOC)
      PopPosition()
   endif

   // turn undelete buffer back on
   Set(KillMax, nKillMax)

end Flow


proc WhenLoaded()
   integer nError = 0

   nIndent = val(QFGetOption("FLOW", "Indent", nError))
   if nError  // set defaults if can't find QF config file
      nIndent = Query(TabWidth)
      nMultiIndent = nIndent - 1
      lFuncIndent = FALSE
      lCaseIndent = TRUE
      lErrorCheck = FALSE
      lComment    = TRUE
      lHardTabs   = FALSE
      cCommentStart = " &&* "
   else
      nMultiIndent = val(QFGetOption("FLOW", "MultiIndent", nError))
      if nError
         nMultiIndent = nIndent - 1
      endif
      lFuncIndent = upper(QFGetOption("FLOW", "FuncIndent", nError)) == "ON"
      lCaseIndent = upper(QFGetOption("FLOW", "CaseIndent", nError)) == "ON"
      lErrorCheck = upper(QFGetOption("FLOW", "ErrorCheck", nError)) == "ON"
      lComment    = upper(QFGetOption("FLOW", "Comment", nError)) == "ON"
      lHardTabs   = upper(QFGetOption("FLOW", "HardTabs", nError)) == "ON"
      if nError
         lHardTabs = (Query(TabType) == 0)
      endif
      cCommentStart = " " + QFGetOption("FLOW", "CommentStr", nError) + " "
      if nError
         cCommentStart = " &&* "
      endif
   endif
end WhenLoaded


proc main()
   Flow()
end main
