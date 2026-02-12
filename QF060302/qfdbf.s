/*
Program....: Quiet Flight DBF Viewer
Version....: 3.5
Author.....: Ryan Katri / Randy Wallin
Date.......: 11/20/92  11:19 am   Last Modified: 08/30/95 @ 07:58 am
Notice.....: Copyright COB System Designs, Inc., All Rights Reserved.
Compiler...: TSE 2.5
QFRestore..: ¯1,1®
Abstract...: Database structure lister
Changes....: RCW - QFDBF no longer requires external DOS programs.

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

#include ["QFLocal.INC"]
#include ["QFByte.INC"]
#include ["QFString.INC"]
#include ["QFPath.INC"]
#include ["QFMsg.INC"]

constant
   DIR_POS = 4

constant
   SCREEN_OUT  = 1,
   PRINTER_OUT = 2,
   FIELD_LIST  = 3,
   SQL_TABLE   = 4

constant
   TAG_FILE    = 3,
   UNTAG_FILE  = 4,
   TAG_ALL     = 1,
   UNTAG_ALL   = 2,
   TAG_TOGGLE  = 5,
   REVERSE_TAG = 6

constant
   NOPREFIX     = 1,
   M_DOT        = 2,
   M_ARROW      = 3,
   ALIAS        = 4,
   USER_DEFINED = 5

string
   DBF_FILE[] = "$qfdbf$.tmp"


Menu DBFMenu()
   "&Screen Output"
   "&Printer Output"
   "Build &Field List"
   "Build SQL &Table"
   "",, Divide
   "&Cancel"
end

Menu FieldMenu()
   "&None"
   "&M.  Prefix"
   "M-> &Prefix"
   "&Alias"
   "&User Defined"
   "",, Divide
   "&Cancel"
end

// Build Database structure listing.

integer proc QFDBFRead(string fn, string cOutput)

integer nBufferID,
        nHandle,
        nTempBytes,
        nFieldCount,
        nFieldLen,
        nTotalBytes,
        nCount,
        nAdjAmount,
        nAddLine,
        nStrLen

string  cWhats[253]="",
        cTempText[10]="",
        cDataBase[20]="",
        cFieldName[13]="",
        cFieldType[15]="",
        cFieldDec[2]="",
        cLastUpdate[8]=""

nHandle = EditFile(cOutPut)

if nHandle
   EmptyBuffer(nHandle)
else
   return(FALSE)
endif // nHandle

nBufferID = fOpen(fn, _OPEN_READONLY_ )

if nBufferID == -1
   AbandonFile(nHandle)
   QFMessage(fn + " " + NO_ACCESS_LOC,5,TRUE)
   return (FALSE)
endif

if fread(nBufferID, cWhats, 32)
   cTempText = GetHexDec(substr(cWhats,1,1),0)

   cTempText = format(cTempText:2:"0")

   nAdjAmount = 1

   case cTempText
        when "30"
                cDataBase = "Visual FoxPro"
                nAdjAmount = 10
        when "F5"
                cDataBase = "FoxPro"
        when "83", "03"
                cDataBase = "dBase/FoxBase"
        when "84","04"
                cDataBase = "dBase IV"
        otherwise
                AbandonFile(nHandle)
                AbandonFile(nBufferID)
                QFMessage(fn + " " + BAD_FORMAT_LOC,5,TRUE)
                return (FALSE)
   endcase

   Addline(format("Structure for Database:  ",  fn :-30 , cDatabase), nHandle)

   nTempBytes = ReadByte(substr(cWhats,5,4))
   cTempText = str(nTempBytes)
   AddLine( "Number of data records:  " + cTempText , nHandle)

   nTotalBytes = ReadByte(substr(cWhats,9,2))
   nFieldCount = ((nTotalBytes / 32) -nAdjAmount)

   if nFieldCount < 1
      // adjust for single field databases
      nFieldCount = 1
   else
      if cDataBase == "Visual FoxPro"
         // round up Visual FoxPro
         nFieldCount = nFieldCount + 1
      endif //

   endif // nFieldCount < 1

   cLastUpdate = format( ReadByte(substr(cWhats,3,1)):2 :"0", "/" ,  ReadByte(substr(cWhats,4,1)):2:"0" , "/" , ReadByte(substr(cWhats,2,1)):2:"0" )
   Addline("Date of last update:     " + cLastUpdate ,nHandle )

   Addline("Field  Field Name   Type      Width    Dec")
   nCount = 1
   while ncount <= nFieldCount
         // read in the field information
         if fread(nBufferID, cWhats, 32)

            cFieldName = substr(cWhats,1,10)
            // GetNull evalutes string and returns the 1st null position in
            // the string
            nStrLen = GetNull(cFieldName,1)
            cFieldName = substr(cWhats,1,nStrLen)
            cFieldType = substr(cWhats,12,1)

            nFieldLen  = ReadByte(substr(cWhats,17,1))
            cFieldDec  = iif( cFieldType == "N" or cFieldType == "F",
                         str(Readbyte(substr(cWhats,18,1))),"")
            nAddLine = 1
            case cFieldType
                when "C"
                   cFieldType = "Character"
                when "L"
                   cFieldType = "Logical"
                when "N"
                   cFieldType = "Numeric"
                when "F"
                   cFieldType = "Float"
                when "I"
                   cFieldType = "Integer"
                when "Y"
                   cFieldType = "Currency"
                when "D"
                   cFieldType = "Date"
                when "T"
                   cFieldType = "DateTime"
                when "M"
                   cFieldType = "Memo"
                otherwise
                   cFieldType = "Unknown"
                   nAddLine = 0
            endcase
            if nAddline
               AddLine(format(nCount:4,
                       "   ",
                       cFieldName:-13 ,
                       cFieldType:-10 ,
                       nFieldLen:5 ,
                       cFieldDec:7
                       ), nHandle)
            endif // nAddline
            nCount = nCount + 1
         else
            break
         endif // fread
   endwhile
   Addline("** Total **    " + format(nTotalBytes:13), nHandle)
endif

fClose(nBufferID)

return(TRUE)
end

proc Status(string cMsg, integer nRow)
   integer nSaveAttr

   nRow = iif(nRow == 0, Query(ScreenRows), nRow)
   // Display status on bottom line
   nSaveAttr = Set(Attr, Color(black on white))
   vGotoXy(1, nRow)
   ClrEol()
   Write(cMsg)
   Set(Attr, nSaveAttr)
end Status


integer proc PickUpdate( string cTitle, string cFooter, var integer nRow,
  integer nLeft, integer nTop, integer nRight, integer nWinSize,
  integer nWinColor, integer nBarColor, integer nUpdateType, integer nTextAttr,
  string cStatus)

   integer n, nKey,
           lDownOkay = 1,
           nLine,
           nLen,
           nSaveAttr
   string cInfo[80]

   // Close window
   if nUpdateType == 4
      // restore screen to the way it was before we entered our window
      PopWinClose()
      return (0)
   endif

   if nUpdateType == 3
      PopWinClose()
   endif

   // Make sure nRow & currline don't get out of sync
   if nRow > CurrLine()
       nRow = CurrLine()
   endif


   nSaveAttr = Set(Attr, nWinColor )

   if nUpdateType == 1 or nUpdateType == 3

      if length(cStatus)
         Status("       ® Quiet Flight ¯  Copyright (c) 1992 COB System Designs, Inc.", 0)
         Status(cStatus, Query(ScreenRows)-1)
      endif // length(cStatus)

      PopWinOpen(nLeft, nTop, nRight, nTop+nWinSize+1, 1, cTitle, nWinColor)

      // center the footer message
      vGotoXY((nRight-nLeft)/2 - (Length(cFooter)/2), nWinSize+1)
      Write(cFooter)

   endif

   if nUpdateType > 0
      ClrScr()
   endif

   nLen = nRight - nLeft -1

   Set(Cursor,OFF)
   vHomeCursor()

   // Make sure nRow and the current line are valid
   if not CurrLineLen()
      up()
      nRow = iif(nRow > 1, nRow - 1, nRow)
   endif
   if nRow > NumLines()
        nRow = NumLines()
   endif

   // move up to the line we want to display on the first row
   nLine = CurrLine()
   while CurrLine() <> (nLine - nRow + 1) and up()
   endwhile // CurrLine() <> (nLine - nRow + 1) and up()

   Set(Attr, nTextAttr)

   // display all the lines which fit in the window
   n = 0
   if nWinSize > 1
      repeat
         cInfo = format(GetText(1, nLen):-nLen)
         WriteLine(cInfo)
         n = n + 1
         lDownOkay = down()
      until (n == (nWinSize - 1)) or (not lDownOkay)
   endif // nWinsize > 1

   // display the last line in window, but without going to next line
   if lDownOkay
      cInfo = format(GetText(1, nLen):-nLen)
      Write(cInfo)
   endif // lDownOkay



   // move back to our original line in the buffer
   GotoLine(nLine)

   // hilite the current selection
   vGotoXY(1, nRow)
   PutAttr(nBarColor, nLen)

   // Display arrow if more entries ABOVE the window
   vGotoXY((nRight - nLeft)-1, 0)
   if nRow < nLine
      PutOemChar("")
   else
      PutOemChar("Ä")
   endif

   // Display arrow if more entries BELOW the window
   vGotoXY((nRight - nLeft)-1, nWinSize + 1)
   if NumLines() > nLine + (nWinSize - nRow)
      // Display arrow if more entries above the window
      PutOemChar("")
   else
      PutOemChar("Ä")
   endif

   // get a keystroke and process defaults
   nKey = GetKey()
   case nKey
     when <CursorDown>
        if down() and (nRow <> nWinSize)
           nRow = nRow + 1
        endif // down() and (nRow <> nWinSize)
     when <CursorUp>
        if up() and (nRow > 1)
           nRow = nRow - 1
        endif // up() and (nRow > 1)
     when <PgUp>
        gotoLine(CurrLine()-(nWinSize-1))
        ClrScr()
     when <PgDn>
        gotoLine(CurrLine()+(nWinSize - 1))
        ClrScr()
     when <Home>
        BegFile()
        nRow = 1
     when <End>
        EndFile()
        nRow = iif(CurrLine() > (nWinSize), nWinSize, CurrLine())
   endcase // nKey

   if CurrLine() <= (nWinSize -1) and nRow >= CurrLine()
      nRow = CurrLine()
   endif // CurrLine() <= (nWinSize -1) and nRow >= CurrLine()

   Set(Attr, nSaveAttr)


   Set(Cursor,ON)

   return (nKey)
end PickUpdate


// Build a comma-delimited field list
proc BuildList( integer nBufferID, integer nListType, string cFileName )
   integer nSaveCol,
           nInitialRun=1,
           lBreak = FALSE,
           nFieldPreFix=0

   string cFieldStr[80] = "",
          cDecimals[2]="",
          cFieldType[1]="",
          cCreateSQL[10]="",
          cFieldPrefix[10]=SUBSTR(cFileName,RAT("\",cFileName)+1,20),
          cFieldFull[10]=""
   cFieldPrefix=SUBSTR(cFieldPrefix,1,RAT(".",cFieldPrefix))
   // get a CREATE TABLE name, or abort if ESC entered
   if nListType == SQL_TABLE and not Ask("Table Name: ",cCreateSQL)
      return()
   endif // nListType == SQL_TABLE and not Ask("Table Name: ",cCreateSQL)
   // Changed on 12/06/93 RCW - added if construct below to allow for
   // different types of field prefixes.

   if nListType == FIELD_LIST
      nFieldPrefix=FieldMenu()
      if nFieldPrefix==0 or nFieldPrefix==7
         return()
      endif // nFieldPrefix=0 OR nFieldPrefix=7

      case nFieldPrefix
         when M_DOT
              cFieldPrefix="m."
         when M_ARROW
              cFieldPrefix="m->"
         when USER_DEFINED
              IF NOT ASK("Field Prefix Name: ",cFieldPrefix)
                 cFieldPrefix=""
              ENDIF // ASK("Field Prefix Name: ",cFieldPrefix)
         when NOPREFIX
              cFieldPrefix=""
      endcase // nFieldPrefix

   endif // nListType == FIELD_LIST

   if nListType == SQL_TABLE
      cFieldPrefix=""
   endif // nListType == SQL_TABLE

   PushPosition()
   GotoBufferId(nBufferId)
   nSaveCol = CurrCol()

   // Don't create line breaks if we are already very close to or
   // past the right margin setting
   lBreak = (CurrCol() < Query(RightMargin)-10)

   PopPosition()

   BegFile()
   repeat
      GotoPos(2)
      if Chr(CurrChar()) == "û"
         GotoPos(8)
         case nListType
            when FIELD_LIST
               if Length(cFieldStr)
                  cFieldStr = ", "+cFieldPrefix
               else
                  cFieldStr = cFieldPrefix+""
               endif
               cFieldStr = cFieldStr + GetWord()

            when SQL_TABLE
               cFieldStr = Proper(Format(GetWord():-10))

               GotoPos(21)
               cFieldFull = TRIM(GetText(CurrCol(),10))
               cFieldType = SubStr(cFieldFull,1,1)

               case cFieldType
                  when "C"
                     case cFieldFull
                          when "Character"
                               cFieldStr = cFieldStr + " C(" + ltrim(format(GetText(33, 3))) + ")"
                          when "Currency"
                               cFieldStr = cFieldStr + " Y"
                     endcase

                  when "N", "F"
                     cDecimals=GetText(41, 2)
                     cFieldStr = cFieldStr + format(cFieldType:2) + "(" + ltrim(format(GetText(33, 3))) +
                                iif(cDecimals=="  ","", "," + ltrim(format(cDecimals))) + ")"

                  when "D"
                     case cFieldFull
                          when "DateTime"
                               cFieldStr = cFieldStr + " T"
                          when "Date"
                               cFieldStr = cFieldStr + " D"
                     endcase
                  otherwise
                     cFieldStr = cFieldStr + " " + cFieldType
               endcase

               cFieldStr = cFieldStr + ", ;"

         endcase


         // Write field into original buffer area
         PushPosition()
         GotoBufferID(nBufferID)


         if nListType == FIELD_LIST
            if (lBreak) and (CurrCol() + length(cFieldStr) > Query(RightMargin))
               InsertText(", ;", _INSERT_)
               AddLine()
               GotoColumn(nSaveCol)
               cFieldStr = substr(cFieldStr, 2, length(cFieldStr)-1)
            endif
            InsertText(cFieldStr, _INSERT_)
         else
            if nInitialRun
               GotoColumn(nSaveCol)
               AddLine()
               GotoColumn(nSaveCol)
               InsertText("CREATE TABLE "+ cCreateSQL + " ;", _INSERT_)
               nSaveCol = nSaveCol + 3
               AddLine()
               GotoColumn(nSaveCol)
               InsertText( "(" + cFieldStr , _INSERT_ )
               nInitialRun = FALSE
            else
               InsertText(" " + cFieldStr, _INSERT_ )
            endif //  nInitialRun
            AddLine()
            GotoColumn(nSaveCol)
         endif // nListType == FIELD_LIST

         PopPosition()

      endif
   until not down()


   if nListType == SQL_TABLE
      PushPosition()
      GotoBufferId(nBufferId)
      Up()
      EndLine()
      BackSpace()
      BackSpace()
      BackSpace()
      InsertText(")", _INSERT_)
      PopPosition()
   endif // nListType == SQL_TABLE

end BuildList





// Tag a field name
proc Tag( integer TagType )
   string cLine[12]
   PushPosition()

   cLine = GetText(DIR_POS, 12)
   case TagType
      when TAG_TOGGLE      // toggle tag on current file
         GotoPos(2)
         if substr(cLine, 1, 1) <> "<" and length(cLine)
            InsertText( iif(isWhite(), "û", " "), _OVERWRITE_)
         endif
         PushKey(<CursorDown>)
      when TAG_ALL,UNTAG_ALL    // tag/untag all (1 = tag, 2 = untag)
         BegFile()
         repeat
            cLine = GetText(DIR_POS, 12)
            GotoPos(2)
            if substr(cLine, 1, 1) <> "<" and length(cLine)
               InsertText( iif( TagType == TAG_ALL, "û", " "), _OVERWRITE_)
            endif
         until not down()
      when TAG_FILE      // tag current file
         GotoPos(2)
         InsertText("û", _OVERWRITE_)
         PushKey(<CursorDown>)
      when UNTAG_FILE    // untag current file
         GotoPos(2)
         InsertText(" ", _OVERWRITE_)
         PushKey(<CursorDown>)
      when REVERSE_TAG   // toggle tag on all files (reverse tag)
         BegFile()
         repeat
            cLine = GetText(DIR_POS, 40)
            GotoPos(2)
            if substr(cLine, 1, 1) <> "<" and length(cLine)
               InsertText( iif( GetText(2, 1) == " ", "û", " "), _OVERWRITE_)
            endif
         until not down()

   endcase

   PopPosition()

end Tag


// Display a browse list of the database fields
integer proc MakeDBF(string cFileSpec, string cOutput, integer lraw)
   message(LOAD_LOC)

   IF QFDBFRead(cFileSpec, cOutPut)
      EditFile(cOutput)
      // EraseDiskFile(cOutput)
      // lRaw determines if we want to delete the header / footer info
      if NOT lRaw
         // Massage the dbf output
         BegFile()
         MarkLine()
         lFind("^Field  Field Name", "x")
         DelBlock()

         lFind("^\*\* Total \*\*", "x")
         DelLine()
         DelLine()
         DelLine()
         BackSpace()

         BegFile()
      endif // NOT lRaw
      message("")

      return (GetBufferId())
 endif
      return (FALSE)

end MakeDBF



integer proc DBFList(string cFileSpec, integer nUserID, integer nListType)
   string cSpeedKey[12] = ""
   integer nCurrId,
           nTempId,
           nRow,
           nKey,
           nWinSize,
           nUpdateType = 1


   nRow = 1
   nCurrId = GetBufferId()              // save current buffer id

   // set the window size based upon # of items to display and rows available
   nWinSize = Query(ScreenRows)-5

   nTempId = MakeDBF(cFileSpec, DBF_FILE, FALSE)
   if NOT nTempid

   else

      nRow = 1
      repeat

         message(iif(length(cSpeedKey), "SpeedKey: " + cSpeedKey, ""))
         nKey = PickUpdate("",
          " " + cFileSpec+ " ", nRow, 1, 2, 45, nWinSize,
          color(bright white on magenta), color(black on white), nUpdateType,
          color(bright white on magenta),
          "   ENTER: Insert List  SPACE: Tag Toggle  CTRL-T: Tag All  CTRL-U: Untag All")
         nUpdateType = 0


         case nKey
            when <ctrl t>       // tag all
               tag(TAG_ALL)
            when <t>           // tag file
               tag(TAG_FILE)
            when <ctrl u>       // untag all
               tag(UNTAG_ALL)
            when <u>           // untag file
               tag(UNTAG_FILE)
            when <spacebar>     // tag
               tag(TAG_TOGGLE)
            when <ctrl r>       // reverse tags
               tag(REVERSE_TAG)
            when <enter>,<GreyEnter>   // build list
               // Changed on 12/06/93 - RCW - added cFileSpec to BuildList
               BuildList(nUserId, nListType, cFileSpec)
         endcase

      until nKey == <escape> or nKey == <enter> or nKey == <greyenter>

      // close the popup picklist
      PickUpdate("", "", nRow, 1, 2, 45, nWinSize, 0, 0, 4, 0, "")

      AbandonFile()

      // move to original buffer
      GotoBufferId( nCurrId )

      return (nKey == <escape>)
   endif // NOT nTempid
   return (true)

end DBFList


proc DIRList(string cSpec)
   integer nListType, nCurrId
   integer lQuit = FALSE
   integer nWarnStmt=0
   string cFile[80]

   nCurrId = GetBufferId()              // save current buffer id

   while not lQuit
      lQuit = TRUE
      if Pos("*",cSpec) OR POS("?",cSpec)
         cFile = PickFile(cSpec)
      else
         cFile = cSpec
      endif // Pos("*",cSpec) OR POS("?",cSpec)

      if length(cFile)

         nListType = DBFMenu(cFile)
         case nListType
            when FIELD_LIST, SQL_TABLE
               if DBFList(cFile, nCurrId, nListType)
                  lQuit = FALSE
               endif
            when SCREEN_OUT
               nWarnStmt=MakeDbf(cFile, SplitPath(cFile, _DRIVE_ | _PATH_ | _NAME_)+".LST",TRUE)
               IF nWarnStmt
                  // At this point we can SaveFile() or do this forceChange(FALSE)
                  // What do you think?
                  FileChanged(FALSE)
                  if isZoomed()
                     ZoomWindow()
                  endif // isZoomed()
                  nWarnStmt=WindowID()
                  HWindow()  // maybe make this VWINDOW() ???
                  PrevFile()
                  GotoWindow(nWarnStmt)
               Endif // Makedbf()
            when PRINTER_OUT
               if MakeDbf(cFile, SplitPath(cFile, _NAME_)+".LST",TRUE)
                  PrintFile()
                  AbandonFile()
               endif // MakeDbf()
         endcase
      endif
   endwhile
end DirList


proc main()
   string cDrive[2]
   string cPath[60]
   string cSpec[60]
   integer nCurrId
   integer nMsgLevel
   integer nKillMax
   integer nHistory

   // turn off undelete for now
   nKillMax = set(KillMax, 0)
   nMsgLevel = SET(MsgLevel, _NONE_)

   nCurrId = GetBufferId()              // save current buffer id

   PushBlock()

   nHistory = GetGlobalInt("QFDBF_HISTORY")
   if not nHistory
      nHistory = GetFreeHistory("QFDBF_HISTORY")
      SetGlobalInt("QFDBF_HISTORY", nHistory)
   endif // not nHistory

   cDrive = SplitPath(CurrFilename(), _DRIVE_)
   cPath = SplitPath(CurrFilename(), _PATH_)
   cSpec = cDrive+cPath+"*.dbf"

   if AskFileName(LOAD_DBF_LOC, cspec, _FULL_PATH_ | _MUST_EXIST_, nHistory)

      AddHistoryStr(cSpec, nHistory)

      DIRList(cSpec)
   endif // AskFileName()



   PopBlock()


   // move to original buffer
   GotoBufferId( nCurrId )


   // re-enable undelete
   set(KillMax, nKillMax)
   Set(MsgLevel, nMsgLevel)

   UpdateDisplay(_ALL_WINDOWS_REFRESH_)

end main

