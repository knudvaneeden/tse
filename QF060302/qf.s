/*
Program....: Quiet Flight
Version....: 3.5
Author.....: Randy Wallin & Ryan Katri
Date.......: 02/01/93 11:12 pm  Last Modified: 06/28/2002 @ 11:14 am
Notice.....: Copyright 1992 COB System Designs, Inc., All Rights Reserved.
Compiler...: TSE Pro 2.5
Abstract...: Main Routine for all Quiet Flight Tools
QFRestore..: Ø1021,29Æ
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


// EditFile

#include ["QFLocal.inc"]
#include ["QFString.INC"]
    // Includes:
    // integer proc rat (string lookfor, string in_text )
    // string proc rtrim( string st )
    // string proc ltrim( string st )
    // string proc QFGetWordAtCursor()
    // string proc QFGetFirstWord()
    // string proc Proper(string cStr)
    // string proc GetWordAtCursor()
#include ["QFOption.inc"]
     // Includes:
     // string proc QFGetOption(string cSection, string cOption, var integer nError)
     // integer proc QFGetOnOff(string cSection, string cOption, var integer nError)
#include ["QFPath.inc"]
     // includes:
     // string proc QFGetEnv(string cEnvVar)
     // string proc QFGetPath(string cFileName)
#include ["QFMsg.inc"]
    // includes:
    // proc QFMessage(string cMessage, integer nTimeOut, integer nSound)
#include ["QFRegExp.inc"]
    // includes:
    // string proc QFRegExpr(string cExpr)
#include ["QFAllSav.inc"]
    // includes:
    // integer proc QFQuickSave(integer nSave)
// #include ["QFFFFunc.inc"]
    // includes:
    // string proc ffname(string ffblk)
    // integer proc ffAttr(string ffblk)
    // string proc ffTime(string ffblk)
    // string proc ffDate(string ffblk)
    // integer proc ffSize(string ffblk)
    // integer proc Find_First(string path, var string ffblk, integer attribs)
    // integer proc FindNext(var string ffblk)
    // integer proc CD(string dir)
#include ["QFMacros.inc"]
    // includes:
    // string proc QFDateStr()
    // string proc QFDOW()
    // string proc QFYear()
    // integer proc QFMacroReplace(integer lLocalBlock)
#include ["QFRestor.Inc"]
    // includes:
    // Integer proc QFRestore()

//********************************************************************
// 2 more includes are near Main() QF.KEY and QFMENU.INC
//********************************************************************

string
   cQFVer[] = "3.5"

 constant   SHAREWARE = FALSE       // Shareware Version

string
   cQFCfgExt[] = ".INI"

FORWARD Proc QFUnload()
FORWARD Proc QFNewHeader(integer lNewFile)
FORWARD Proc QFEditFile()


proc QFDeclare(string cDeclareWord)
     SetGlobalStr("gcDeclareWord", cDeclareWord)
     ExecMacro("QFDecVar")
     SetGlobalStr("gcDeclareWord", "")
end QFDeclare




// This function will jump to the next fill-in character (·) of
// an expansion.  By assigning this function to a key such as
// Alt-GreyCursorRight, it is easy to jump to the next place that needs
// to be filled in
// Pass TRUE if you want to find the previous beta, FALSE to go forward
proc QFNextBlank(integer lPrevious)
   integer nTopRow, nCurrLine, nError = 0
   string cOptions[3] = ""

   if NOT QFGetOnOff("GENERAL", "JumpNext", nError)
      return ()
   endif // NOT QFGetOnOff("GENERAL", "JumpNext", nError)

   // Keep track of our current row so we can minimize the amount of
   // scrolling the window does after a FIND command
   PushPosition()
   BegWindow()
   nTopRow = CurrLine()
   PopPosition()

   if lPrevious
      cOptions = "b"
   endif // lPrevious

   if lFind("~", cOptions)
      // remove the beta character
      delChar()

      // Scroll the window to the spot we were before the FIND command
      nCurrLine = CurrLine()
      BegWindow()
      GotoLine(nTopRow)
      while nCurrLine <> CurrLine()
         down()
      endwhile

   else
      message(NO_BLANKS_LOC)
   endif
end QFNextBlank

proc QFCleanLine()
     GotoPos(PosFirstNonWhite())
     DelToEol()
end QFCleanLine

integer proc QFShift(integer nDirection)
    integer nGoalLine  = CurrLine(),
            nSaveLine  = CurrLine(),
            nBlockType = isCursorInBlock()

    if nBlockType
       // BlockInfo(nStartLine, nStartCol, nGoalLine, nEndCol, nBuffId)
        nGoalLine=Query(BlockEndLine)
        GotoLine(Query(BlockBegLine))
    endif

    repeat until not ShiftText(nDirection) or
            not RollDown() or
            CurrLine() > nGoalLine
    GotoLine(nSaveLine)

    return (TRUE)
end

integer proc QFInsPhrase(string cPassPrompt, integer lShortHand, integer lClean)
   integer nSaveBuf, nColumn, nExpandBuf, nSaveCol
   integer lOkay = TRUE, nKey
   integer lInsWhere
   string cInitLine[100], cEndPrompt[1]
   integer nCurrLine, nTopRow

   // This little screen juggling tries to minimize the screen movement
   // after an expansion is done by saving the line number which is
   // on the top row of the window
   PushPosition()
   BegWindow()
   nTopRow = currLine()
   PopPosition()

   PushPosition()
   nSaveCol = CurrCol()

   PushBlock()
   UnMarkBlock()

   cInitLine=GetText(1,100)
   if lShortHand
      left()
      MarkWord()
      DelBlock()
   elseif lClean
      QFCleanLine()
   endif // lShortHand

   nColumn = CurrCol()


   if cPassPrompt == "{" or cPassPrompt == '[' or cPassPrompt == '('
      case cPassPrompt
         when '{'
            cEndPrompt = '}'
         when '('
            cEndPrompt = ')'
         when '['
            cEndPrompt = ']'
      endcase // cPassPrompt

      nSaveBuf = GetBufferId()
      nExpandBuf = GetGlobalInt("nExpandBuf")
      GotoBufferId(nExpandBuf)
      down()
      MarkLine()
      lFind("^\"+cEndPrompt, "x")
      up()

      GotoBufferId(nSaveBuf)
      lInsWhere = Set(InsertLineBlocksAbove, TRUE)
      CopyBlock()
      Set(InsertLineBlocksAbove, lInsWhere)

      QFShift(nColumn - 1)
   else

      SplitLine()
      MarkChar()

      InsertText(cPassPrompt, _OVERWRITE_)
      JoinLine()
      MarkChar()

   endif
   // perform macro replacements on marked block
   lOkay = QFMacroReplace(TRUE)

   if not lOkay

      DelBlock()
      BegLine()
      DelToEol()
      InsertText(cInitLine, _INSERT_)

      PopPosition()
      GotoColumn(nSavecol)
   else

      PopPosition()

      // position the cursor
      if lFind("~", "lg")
         delChar()
         nCurrLine = CurrLine()
         BegWindow()
         GotoLine(nTopRow)
         while nCurrLine <> CurrLine()
            down()
         endwhile
      else
         GotoBlockEnd()
      endif // lFind("~", "lg")
   endif // not lOkay
   // Hilite a keyword, and delete it if a non-movement (cursor) key pressed
   // Keywords that should be hilited are enclosed as follows:  ##keyword^^

   if lOkay and lFind(QFRegExpr(GetGlobalStr("gcAbbrevStart")) +
    "{.@}\^\^", "glx")
      nSaveCol = CurrCol()
      DelChar()
      DelChar()
      MarkWord()
      GotoBlockEnd()
      BackSpace()
      DelChar()

      UpdateDisplay()
      nKey = GetKey()
      Set(Cursor,OFF)
      if (nKey & 0xff) == 0 or nKey == <enter> or nKey == <greyenter>
         UnMarkBlock()
         PushKey(nKey)
      else
         GotoColumn(nSaveCol)
         DelBlock()
         PushKey(nKey)
      endif
      Set(Cursor,ON)
   endif // lOkay and lFind(QFRegExpr(GetGlobalStr("gcAbbrevStart")) + "{.@}\^\^", "glx")

   PopBlock()

   return(lOkay)
end QFInsPhrase



// Ryan's Expand.q 11/08/92
proc QFExpand(integer lShorthand)
   integer lExpanded = FALSE       // lExpanded returns TRUE only if successful
   integer nKillMax,                     // Save Restore Kill Buffer
           lOkay,
           nError = 0
   string cGotcha[10],
          cPhrase[200]

   if CurrChar() == -1 or lShortHand
      nKillMax = Set(KillMax,0)
      if lShorthand
         left()
         // cGotcha = QFGetWordAtCursor()
         cGotcha = GetWord()
         right()
         lOkay = TRUE
      else
         cGotcha = QFGetFirstWord()
         lOkay = (Length(cGotcha)+PosFirstNonWhite()==CurrCol())
      endif // lShorthand
      if length(cGotcha) > 1 and length(cGotcha) < 8 and lOkay
         cPhrase = QFGetOption("EXPANSION", cGotcha, nError)
         if nError
            cPhrase = QFGetOption("EXPANSION=Defaults", cGotcha, nError)
         endif
         if length(cPhrase)
            QFInsPhrase(cPhrase, lShortHand, TRUE)
            lExpanded = TRUE
         endif
      endif
      Set(KillMax, nKillMax)

   endif // CurrChar() == -1

   if not lExpanded and not lShortHand
      InsertText(" ")
   endif


end QFExpand


// Changed on 08/10/93 brought lBusiness to life - if Business Comments
// are used then we don't insert the  character.

integer proc QFCommentStr(var string cCommentStart, var string cCommentEnd, integer lbusiness)
   integer nError = 0

   cCommentStart = QFGetOption("GENERAL", "CommentStart", nError)

   if nError
      // set up comment characters depending on extension
      case CurrExt()
          when ".cpp", ".s", ".ch", ".inc", ".ui"         // !!! GDB: Added UI
              cCommentStart="//" + iif(lbusiness,"","")
          when ".c", ".h", ".cb"
              cCommentStart="/*"+ iif(lbusiness,"","")
              cCommentEnd="*/"
          when ".prg",".frg",".spr",".mpr",".fmt"
              cCommentStart="*"+ iif(lbusiness," ","*")
          when ".bat",".sys"
              cCommentStart="REM "
          when ".m",".ini"
              cCommentStart=";** "
          otherwise
              // Warn("File extension not supported")
              RETURN(FALSE)
      endcase
   else
      cCommentEnd = QFGetOption("GENERAL", "CommentEnd", nError)
   endif // nError

   return(TRUE)
end QFCommentStr



// Comment/uncomment a marked block of text
// Changed on 08/10/93 brought lBusiness to life - if Business Comments
// are used then we don't insert the  character.
proc QFComment(integer lBusiness)
   string  cCommentStart[7]=""
   string  cCommentEnd[5] = ""
   string  cStartExpr[7] = ""
   string  cEndExpr[5] = ""
   integer nKillMax
   integer lUnComment
   integer nEndBlock

   IF Not QFCommentStr(cCommentStart,cCommentEnd, lBusiness)
      QFMessage(NO_FILEEXT_LOC,3,FALSE)
      Return()
   Endif // Not QFCommentStr
   cStartExpr = QFRegExpr(cCommentStart)
   cEndExpr = QFRegExpr(cCommentEnd)

   lUnComment = GetText(PosFirstNonWhite(), 10 + Length(cCommentStart)) == (cCommentStart + " " + SUBSTR(COMMENTED_LOC, 1, POS(' ', COMMENTED_LOC)-1))

   if isBlockInCurrFile() or lUnComment
      nKillMax = set(KillMax, 0)
      PushBlock()
      PushPosition()

      if lUnComment
         DelLine()
         MarkLine()
         while ((GetText(PosFirstNonWhite(), length(cCommentStart)) == cCommentStart) or
             (GetText(PosFirstNonWhite(), CurrLineLen()) == rtrim(cCommentStart))) and
              GetText(PosFirstNonWhite(), 10 + Length(cCommentStart)) <> (cCommentStart + " " + SUBSTR(COMMENTED_LOC, 1, POS(' ', COMMENTED_LOC)-1)) and down()
         endwhile
      endif
      if GetText(PosFirstNonWhite(), 10 + Length(cCommentStart)) == (cCommentStart + " " + SUBSTR(COMMENTED_LOC, 1, POS(' ', COMMENTED_LOC)-1))
         up()
      endif
      // ForceMarkEnd()
      Set(Marking,OFF)
      nEndBlock=Query(BlockEndLine)
      GotoBlockBegin()

      // This next block of code handles the case where the user
      // marks a partial line (doesn't use a line block).  We go back
      // and do a line block for them!
      PushBlock()
      UnMarkBlock()
      MarkLine()
      GotoLine(nEndBlock)
      MarkLine()
      Set(Marking, OFF)
      GotoBlockBegin()


      if lUncomment or GetText(PosFirstNonWhite(), length(cCommentStart)) == cCommentStart or
                       GetText(PosFirstNonWhite(), CurrLineLen()) == rtrim(cCommentStart)
         if GetText(PosFirstNonWhite(), 10 + Length(cCommentStart)) == (cCommentStart + " " + SUBSTR(COMMENTED_LOC, 1, POS(' ', COMMENTED_LOC)-1))
            DelLine()
         endif

         // uncomment
         lReplace('{^[ \t]@}{'+cStartExpr+'}|{'+rtrim(cStartExpr)+'}{.@}{'+cEndExpr+'}', '\1\4', 'glnx')
      else
         if NOT lBusiness
            InsertLine(cCommentStart + " " + COMMENTED_LOC + " " +
                     GetDateStr() + " " + AT_LOC + " " + GetTimeStr() +
                     " " + cCommentEnd)
            down()
            GotoPos(1)
         endif // NOT lBusiness


         // comment
         lReplace('^{.@}', cStartExpr+'\0'+cEndExpr, 'glnx')
      endif
      PopBlock()

      PopPosition()
      PopBlock()
      UnMarkBlock()
      set(KillMax, nKillMax)

   else
      QFMessage(NO_COMMENT_LOC,5,FALSE)
   endif

end QFComment

/* Screen Counter */
proc QFScrCounter()
   integer nKey
   integer rowpos, colpos
   string NumStr[3] = "0"
   integer nKeyStat=Query(EquateEnhancedKbd)

   Set(EquateEnhancedKbd,ON)
   if ask(INIT_ROW_LOC + " ", NumStr) and Length(NumStr)
        rowpos = Val(NumStr)
        NumStr = "0"
        if ask(INIT_COL_LOC + " ", NumStr) and Length(NumStr)
           colpos = Val(NumStr)


           repeat
              message(format(rowpos) + "," + format(colpos) +
              CURR_POS_LOC + " ")
              UpdateDisplay()
              nKey = GetKey()
              case nKey
                 when <cursorup>
                    if up()
                       rowpos=rowpos-1
                    endif // up()
                 when <cursordown>
                    if down()
                       rowpos=rowpos+1
                    endif // down()
                 when <cursorleft>
                    if left()
                       colpos=colpos-1
                    endif // left()
                 when <cursorright>
                    if right()
                       colpos=colpos+1
                    endif // right()
              endcase
           until nKey == <escape>
           Message(format(rowpos) + "," + format(colpos) +
              CURR_POS_LOC + ". " + EXIT_LOC + "." )
        endif
   endif
   SET(EquateEnhancedKbd,nKeyStat)
end QFScrCounter



Proc QFShowChanged()
    string CommentStart[7]="",
           CommentEnd[5]=""
    integer nComeBack
    IF Not QFCommentStr(CommentStart,CommentEnd,1)
       QFMessage(NO_FILEEXT_LOC, 5, TRUE)
    Endif
    if CommentStart==""
       return()
    endif // CommentStart=""
    GotoPos(PosFirstNonWhite())     // At first non white
    InsertLine()
    InsertText(CommentStart + " " + CHANGED_LOC + " " + GetDateStr() + " ")
    if CommentEnd<>""
       nComeBack=CurrCol()-1
       InsertText(" "+CommentEnd)
       GotoColumn(nComeBack)
    endif
end QFShowChanged



proc QFWhereAmI()
     string cfuncname[80]="",
            cLook4[60]=""
     PushPosition()
     case CurrExt()
         when ".c",".cpp",".cb"
             cLook4 = "^[a-zA-Z_].*\(.*[~;]$"
         when ".s", ".inc"
             cLook4 = "^{{integer #}|{string #}}@proc +[a-zA-Z_]"
         when ".m"
             cLook4 = "^(macro +[a-zA-Z_]"
         when ".pas"
             cLook4 = "{procedure}|{function} +[a-zA-Z_]"
         when ".prg",".frg",".spr",".mpr",".fmt"
             cLook4 = "^{procedure}|{function} +[a-zA-Z_]"
         when ".ini"
             cLook4 = "^\[.@\]"
         otherwise
             QFMessage(NO_FILEEXT_LOC,5,TRUE)
             return ()
     endcase
     if lfind(cLook4,"xibq")
        GotoPos(1)
        cfuncname=GetText(1,CurrLineLen())
        message(cfuncname)
     else
        message(NO_PROC_LOC)
     endif
     PopPosition()
end QFWhereAmI


proc QFDispFile(string cMessage)
    string cFsize[12]="",
           cFtime[10]="",
           cFdate[12]=""

    if not FindThisFile(CurrFilename(), _READONLY_ | _HIDDEN_ | _SYSTEM_)
        message(NEW_FILE_LOC + "..." + CurrFilename())
        return ()
    endif

    cFsize = Str(FFSize())
    cFDate = FFDateStr()
    cFtime = FFTimeStr()

    message(CurrFileName()+iif(FileChanged(),"*"," ")+" Size: " +cFsize + "  " +
                cFdate + " @ " + cFTime + "  "+cMessage)
end QFDispFile


integer proc QFHeaderSize()
    // procedure to establish Header Size from QF.CFG
    // this will enable us to limit the search for different
    // header modifications in large files - TSE is fast, but
    // no use to penalize anyone with a slow machine.
    integer  nBeginLine=0,
             nEndLine=0,
             nExpandBuf=0,
             nSaveBuf=0,
             nQfHeadSize=0,
             nError=0

      if nError==0
         PushPosition()
         nSaveBuf = GetBufferId()
         nExpandBuf = GetGlobalInt("nExpandBuf")
         GotoBufferId(nExpandBuf)
         down()
         MarkLine()
         lFind("^\}", "x")
         up()
         nBeginLine=Query(BlockBegLine)
         nEndline=Query(BlockEndLine)
         nQfHeadSize=nEndLine - nBeginLine +1
         unMarkBlock()
         GotoBufferId(nSaveBuf)
         PopPosition()
      endif // nError==0
   Return(nQfHeadSize)
end qfheadersize

proc QFUpdateModTime()
    // function to update last modified date in header - on save.
    // called at same time QFInsRESTORE is so that we make one pass on
    // the Header.
    string cModifiedText[20]="Last Modified:\c"
    integer nQfHeadSize=0,
            nMsgLevel=0
    PushPosition()

    nQfHeadSize=QfHeaderSize()

    PushBlock()
    UnmarkBlock()
    BegFile()
    // Localize Search - in case of Big Files.
    MarkLine()
    if NumLines()>nQfHeadSize
        // mark block - minimize search area for updating header information.
       GotoLine(nQfHeadSize)
    else
       GotoLine(NumLines())
    endif // NumLines()>nQfHeadSize+10
    MarkLine()
    GotoBlockBegin()
    nMsgLevel=SET(MsgLevel,_NONE_)
    if lfind(cModifiedText,"xil")
        unMarkBlock()
        if CurrLine()<=nQfHeadSize
            MarkChar()
            EndLine()
            Left()
            MarkChar()
            GotoBlockBegin()
            PushPosition()
            lFind("{ a\cm}|{ p\cm}","ilx")
            if isBlockInCurrFile()
               UnMarkBlock()
               MarkChar()
               PopPosition()
               // blank existing Last Modification Information
               lReplace("[a-z0-9/:]"," ","xiln")
            else
               PopPosition()
            endif // isBlockInCurrFile()
            InsertText(" "+GetDateStr()+ " @ "+ GetTimeStr()+ " ",_OVERWRITE_)
        endif // CurrLine()<=nQfHeadSize
   else
        UnMarkBlock()
   endif // lfind(cModifiedText,"xil")
   PopBlock()
   Set(MsgLevel, nMsgLevel)
   PopPosition()

end QFUpdateModTime
// ***

proc QFInsRestore(string cSearchFor)
     integer nCurrCol=CurrCol(),
             nCurrLine=CurrLine(),
             nError = 0,
             nKillMax = Set(KillMax,0)

     string cCommentStart[10]="",
             cCommentEnd[10]=""

     if NOT QFGetOnOff("GENERAL", "Restore", nError)
        Set(KillMax, nKillMax) //Added
        return()
     endif
     PushPosition()

     QFUpdateModTime()

     PushBlock()
     UnmarkBlock()
     BegFile()

     if lFind(cSearchFor+".@Ø.@Æ\c","ixg")
        MarkChar()
        lFind("\cØ","xib")
        DelBlock()
        InsertText("Ø" + Ltrim(format(nCurrLine:8))+","+Ltrim(format(nCurrCol:8))+"Æ")
     else
        IF QFCommentStr(cCommentStart,cCommentEnd, FALSE)
           InsertLine(cCommentStart+ " QFRestore Ø" + Ltrim(format(nCurrLine+1:8))+","+Ltrim(format(nCurrCol:8))+"Æ"+cCommentEnd)
        Endif // QFCommentStr(cCommentStart,cCommentEnd, FALSE)
     endif // lFind("QFR.@Æ","ixg")
     PopPosition()
     // warn("PopPosition")
     PopBlock()
     // warn("PopBlock")
     Set(KillMax, nKillMax)
end QFInsRestore


proc QFNewFile(string cFile2Load)
   string  cLoadFile[80]="",
   cFullName[80]="",
   cPath[80]="",
   cDrive[3]="",
   cExt[10]=""
   // nLen returns value of Ask
   // nWild this is a wild card
   integer nLen,
   nWild=FALSE,
   nError=0

   if NOT Length(cFile2Load)
       /* grab current data */
      cFullName=CurrFilename()
      cExt=SplitPath(cFullName,_EXT_)
      cDrive=SplitPath(cFullName,_DRIVE_)
      cPath=SplitPath(cFullName,_DRIVE_ | _PATH_)
      nLen = ask(OPEN_FILE_LOC + " ["+cExt+"]:",cLoadFile,_EDIT_HISTORY_)
   else
      nLen=1
      cLoadFile=cFile2Load
   endif // NOT Length()
   // nLen => 0 when Esc wasn't pressed.
   if nLen > 0
      if length(cLoadFile)>0
         if Length(SPLITPATH(cLoadFile,_NAME_))
            // check for ext
            if not pos(".",cLoadFile)
               cLoadFile = cLoadFile+cExt
            endif // pos(".",cLoadFile)

            // check for drive/Path
            if not pos("\",cLoadFile) and not pos(":",cLoadFile)
               cLoadFile = cPath+cLoadFile
            endif // not pos("\",cLoadFile)

            // check for drive
            if not pos(":",cLoadFile)
               cLoadFile = cDrive+cLoadFile
            endif // not pos(":",cLoadFile)

            if pos("*",cLoadFile) or pos("?",cLoadFile)
               nWild=TRUE
            endif // pos("*",cLoadFile) or pos("?",cLoadFile)
         else
            // no file name given
            nWild = TRUE
            cLoadFile=cLoadFile+"*.*"
         endif // Length(SPLITPATH(cLoadFile,_NAME_)
      else
         // no file name given.
         cLoadFile = cPath+"*.*"
         nWild=TRUE
      endif // length(cLoadFile)>0
      // nWild is true only when we have either: 1) wildcards in file spec
      //                                         2) no file name given
      if NOT nWild
         //
         if not Editfile(cLoadFile)
            nWild=TRUE
         endif // not Editfile(cLoadFile)
      endif // nWild
      if nWild
         if QfGetOnOff("GENERAL","QFDIR",nError)
            SetGlobalStr("gcQfDir", cLoadFile)
            ExecMacro("QFDir")
         else
            PickFile(cLoadFile)
         endif // QfGetOnOff("GENERAL","QFDIR",nError)
      endif // nWild

   endif // nLen > 0
end QFNewFile



proc QFOurSave(integer lInList)
    if Not lInList
       if isCursorInBlock()
              if SaveBlock()
                 halt
              endif /* SaveBlock() */
        endif  /* isCursorInBlock() */
    endif // Not lInList
      if FileChanged()
         QFInsRestore("QFRest")
         if SaveFile()
            QFDispFile(SAVED_LOC)
         endif // SaveFile()
      else
         message(NO_SAVE_LOC)
         halt
      endif // FileChanged()
end QFOurSave


proc QFKillRestore()
   string fname[50]=CurrFilename()
   integer nCurrentCol,
           nCurrentLine,
           nCurrentRow
   if FileExists(FName)
      if YesNoOnly("Kill/Restore? "+ fname)==1
         nCurrentRow=CurrRow()
         nCurrentCol=CurrCol()
         nCurrentLine=CurrLine()
         AbandonFile()
         EditFile(fname)
         GotoRow(nCurrentRow)
         GotoLine(nCurrentLine)
         GotoColumn(nCurrentCol)
      endif // YesNo
   else
      QFMessage(Fname + " " + NOT_SAVED_LOC,3,TRUE)
   endif // FileExists
end QFKillRestore



proc QFmatch(string cInbound)
    InsertText(cInbound)
    left()
end QFmatch

proc QFNewHeader(integer lNewFile)
   string  cExt[4] = "",
   cPhrase[200] = "",
   cFileName[80]=""
   integer lExpanded = FALSE,
   nKillMax,
   nError = 0

   nKillMax=Set(KillMax,0)
   PushPosition()
   BegFile()
   cExt = CurrExt()

   cPhrase = QFGetOption("EXPANSION", "HEADER", nError)
   case nError
      when 0
         lExpanded = QFInsPhrase(cPhrase, FALSE, FALSE)
      when 1
         QFMessage("QF Configuration not Loaded.",0,TRUE)
      when 2
         QFMessage("Header for File Extension "+ cExt +" not found.",5,TRUE)
      when 3
         QFMessage("File Extension " + cExt + " not found in QF Config File.",5,TRUE)
   endcase // nError

   if lExpanded
      KillPosition()
   else
      PopPosition()
   endif // lExpanded

   if nError==0 AND lNewFile
      if NumLines()==1 AND CurrLineLen()==0
         unHook(QFEditFile)
         cFileName=CurrFileName()
         AbandonFile()
         EditFile(cFileName)
         Hook(_ON_FIRST_EDIT_, QFEditFile)
      endif // NumLines()==1 AND CurrLineLen()==0
   endif // nError==0 AND lNewFile AND NumLines()==0

   Set(KillMax, nKillMax)
end QFNewHeader



proc QFDelete()
    // Emulates Brief to delete a block if cursor is in a block or
    // a character if not in block
    if isBlockinCurrfile()
        DelBlock()
    else
       if CurrChar() > 0
           DelChar()
       else
           JoinLine()
       endif // CurrChar()>0
    endif  // isBlockinCurrFile()
end QfDelete


/**********************************************************
  These macros emulate the Brief _home and _end commands.
  They should be included in your qconfig.q file and assigned
  to the <home> and <end> keys, respectively.
 ***********************************************************/
proc qhome()
    integer key
    BegLine()
    UpdateDisplay()
    key = GetKey()
    if key == <home>
        BegWindow()
        UpdateDisplay()
        key = GetKey()
        if key == <home>
            BegFile()
            return ()
        endif
    endif
    PushKey(key)
end qhome

proc qend()
    integer key
    EndLine()
    UpdateDisplay()
    key = GetKey()
    if key == <end>
        EndWindow()
        UpdateDisplay()
        key = GetKey()
        if key == <end>
            EndFile()
            return ()
        endif
    endif
    PushKey(key)
end qend



proc QFOpenCfg(integer lEditCfg)
   string cCfgPath[80]=""
   string cCfgFile[12]
   integer nExpandBuf, nSetMessage

   // Use "QFCFG" variable to specify modifying initials on QF.CFG file
   // For instance, if QFCFG=RMK, then look for the file QFRMK.CFG
   cCfgFile = "QF" + SUBSTR(GetEnvStr("QFCFG"),1,5) + cQFCfgExt

   cCfgPath = QFGetPath(cCfgFile)
   if FileExists(cCfgPath + cCfgFile)
      if lEditCfg
         editfile(cCfgPath+cCfgFile)
         message(CFG_ENABLE_LOC)
      else
         nSetMessage = Set(MsgLevel, _WARNINGS_ONLY_)     // get and save setting
         PushPosition()
         PushBlock()

         if GetGlobalInt("nExpandBuf")

            // Added the following block (the IF ... ELSE)
            // to make sure we display the Active message at
            // reload time.
            if not GetGlobalInt("lQFActive")
               message("Quiet Flight "+cQFVer+" active.       COB System Designs, Inc.       Alt-/ for Menu")
               // message("Quiet Flight "+cQFVer+" active                               COB System Designs, Inc.")
               SetGlobalInt("lQFActive", TRUE)
            else
               Message(cCfgPath + cCfgFile + " reinitialized.")
            endif // not GetGlobalInt("lQFActive")
            GotoBufferID(GetGlobalInt("nExpandBuf"))
            AbandonFile()
         endif // GetGlobalInt("nExpandBuf")

         nExpandBuf = CreateTempBuffer()
         if nExpandBuf
            InsertFile(cCfgPath + cCfgFile)
            SetGlobalInt("nExpandBuf", nExpandBuf)
            SetGlobalStr("QfCfg", cCfgPath + cCfgFile)
            SetGlobalStr("gcQFdir","")
         endif
         PopBlock()
         PopPosition()
         Set(MsgLevel, nSetMessage)
      endif // lEditCfg

   else
      QFMessage(cCfgFile + " " + CFG_NOTFOUND_LOC,10,TRUE)
   endif // FileExists(cCfgPath + cCfgFile)

end QFOpenCfg

proc QFQuickDir()
     string cLoadFile[80]=SPLITPATH(CurrFileName(),_DRIVE_ | _PATH_)+"*.*"
     SetGlobalStr("gcQfDir", cLoadFile)
     ExecMacro("QFDir")
end QFQuickDir

proc QFAbout()
   integer nColorSave = 0
   // in xBase language, this would translate to:
   // @ 7,20 to 22,60
   // and ,1 is the type of window border we want.
   PopWinOpen(20, 6, 60, 23 ,1, "Quiet Flight About",color (bright yellow on cyan))
   nColorSave = Set(Attr, Color(black on white))
   Set(Cursor,OFF)
   clrscr()
   writeline("Quiet Flight Macros Version 3.5")
   writeline("-------------------------------------")
   writeline("Copyright COB System Designs, Inc.")
   writeline("All Rights Reserved.")
   writeline("206 South Hampton Drive")
   writeline("Jupiter, Florida 33458-8111")
   writeline("")
   writeline("Sales & Support:")
   writeline("   SemWare Corporation")
   writeline("   Phone: (770) 641-9002")
   writeline("   InterNet:  qf.support@semware.com")
   writeline("")
   writeline("      Thanks for your support!")

   if SHAREWARE
      QFMessage("Quiet Flight...just $69.00! Register Soon...",0,TRUE)
      if YesNoOnly("Read Registration Information Now? ")==1
         ExecMacro("QFSHARE")
      endif // YesNoOnly
   else
      QFMessage("Press Any Key To Continue..",0,0)
   endif // SHAREWARE

   PopWinClose()
   Set(Cursor,ON)
   Set(Attr, nColorSave)
end QFAbout

// Added this hook, which is set up in Main().
// This handles inserting new headers when creating new files
// and the QF Restore option.
proc QFEditFile()
   integer nError=0,
           nQfRestore=0
   string  cMessage[20]=""

   nQfRestore=QFRestore()

   if not GetGlobalInt("lQFActive")
      // message("Quiet Flight "+cQFVer+" active   Alt / for Menu              COB System Designs, Inc.")
      message("Quiet Flight "+cQFVer+" active.       COB System Designs, Inc.       Alt-/ for Menu")
      SetGlobalInt("lQFActive", TRUE)

   else
      if nQfRestore
         cMessage = POS_RESTORED_LOC
      endif // nQfRestore
      QFDispFile(cMessage)

   endif // not GetGlobalInt("lQFActive")

   // Project file specified to load?
   if pos(".prj", CurrFileName())
      LoadMacro("QFProj")
      ExecMacro("QFProj")
   endif // pos(".prj", CurrFileName())



   // Is this a new file?
   if NumLines() == 0
      if QFGetOnOff("GENERAL", "NewHeader", nError)
         QFNewHeader(TRUE)
      endif // QFGetOnOff("GENERAL", "NewHeader", nError)
   endif // NumLines() == 0
end QFEditFile


proc QFPreRestore()
     if FileChanged()
        QFInsRestore("QFRest")
     else
        Message(NO_SAVE_LOC)
     endif // FileChanged()

end QFPreRestore

#include "qfmenu.inc"   // menu
#include "qfkey.inc"   // key-assignments

proc QFUnload()
     alarm()
     Disable(QFkeys)
     enable(TempQFkeys)
     message("Quiet Flight unloaded.     COB System Designs, Inc.      Press Alt-\ to reload.")
     UnHook(QFPreRestore)
     UnHook(QFEditFile)
     SetGlobalInt("lQFActive", FALSE)
end QFUnload



proc WhenLoaded()
   string ffn[120]="" ,
          cPath[40]=""
   string cAbbrevStart[5] = "$"
   string cAbbrevEnd[5] = "."
   string cEnvStart[5] = "%"
   string cEnvEnd[5] = "%"
   string cTemp[5]
   integer nError=0

   QfOpenCfg(FALSE)
   // message("Quiet Flight "+cQFVer+" active                               COB System Designs, Inc.")

   enable(QFkeys)
   if QfGetOnOff("GENERAL","BriefKeys",nError)
      enable(QFBRIEFkeys)
   endif // QfGetOption("GENERAL", "BriefKeys", nError)

   // Read in the delimiters for the Abbreviation & environment
   // macro expansion from the configuration file
   //
   cTemp = QfGetOption("GENERAL","AbbrevStart", nError)
   if length(cTemp)
      cAbbrevStart = cTemp
   endif
   SetGlobalStr("gcAbbrevStart", cAbbrevStart)

   cTemp = QfGetOption("GENERAL","AbbrevEnd", nError)
   if length(cTemp)
      cAbbrevEnd = cTemp
   endif
   SetGlobalStr("gcAbbrevEnd", cAbbrevEnd)

   cTemp = QfGetOption("GENERAL","EnvStart", nError)
   if length(cTemp)
      cEnvStart = cTemp
   endif
   SetGlobalStr("gcEnvStart", cEnvStart)

   cTemp = QfGetOption("GENERAL","EnvEnd", nError)
   if length(cTemp)
      cEnvEnd = cTemp
   endif
   SetGlobalStr("gcEnvEnd", cEnvEnd)



   Hook(_ON_FIRST_EDIT_, QFEditFile)
   Hook(_ON_FILE_SAVE_, QFPreRestore)

   SetGlobalInt("gnInitShare",1)

   if SHAREWARE
      cPath=QFGetEnv("QFPATH")
      ffn=SearchPath("QFSHARE.MAC", cPath, ".")
      if NOT FileExists(ffn)
         QFMessage("Quiet Flight is Shareware. Please Register Soon.",10,TRUE)
      else
         ExecMacro(ffn)              // GDB: Modified to use fully qualified path
         PurgeMacro("QFShare")
      endif // NOT FileExist(ffn)
   endif // SHAREWARE
   SetGlobalInt("gnInitShare",0)
end WhenLoaded

<Alt \>                       ExecMacro("qf")



