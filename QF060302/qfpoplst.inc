/*
Program....: qfpoplst.inc
Version....: 3.5
Author.....: Randy Wallin & Ryan Katri
Date.......: 07/20/93  10:25 am  Last Modified: 08/30/95 @ 08:10 am
Notice.....: Copyright 1993 COB System Designs, Inc., All Rights Reserved.
QFRestore..: ¯1,1®
Compiler...: TSE 2.5
Abstract...:
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

constant
   POP_NOTHING = 0,
   POP_OPEN = 1,
   POP_REFRESH = 3,
   POP_CLOSE = 4

integer proc QFPopList(string cTitle, string cFooter, var integer nRow,
  integer nLeft, integer nTop, integer nRight, integer nWinSize,
  integer nWinColor, integer nBarColor, integer nUpdateType, integer nTextAttr)

   integer n, nKey,
           lDownOkay = 1,
           nLine,
           nLen,
           nSaveAttr,
           nMouseRow, nMouseCol
   string cInfo[80]

   // Close window
   if nUpdateType == POP_CLOSE
      // restore screen to the way it was before we entered our window
      PopWinClose()
      return (0)
   endif

   if nUpdateType == POP_REFRESH
      PopWinClose()
   endif

   // Make sure nRow & currline don't get out of sync
   if nRow > CurrLine()
       nRow = CurrLine()
   endif


   nSaveAttr = Set(Attr, nWinColor )

   if nUpdateType == POP_OPEN or nUpdateType == POP_REFRESH
      PopWinOpen(nLeft, nTop, nRight, nTop+nWinSize+1, 1, cTitle, nWinColor)
      // center the footer message
      vGotoXY((nRight-nLeft)/2 - (Length(cFooter)/2), nWinSize+1)
      Write(cFooter)
   endif

//    or nUpdateType == POP_REFRESH

   if nUpdateType > POP_NOTHING
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
   Set(Attr, nWinColor)
   vGotoXY(nLen, 0)

   if nRow < nLine
      PutOemChar("")
   else
      PutOemChar("Ä")
   endif

   // Display arrow if more entries BELOW the window
   vGotoXY(nLen, nWinSize + 1)
   if NumLines() > nLine + (nWinSize - nRow)
      // Display arrow if more entries above the window
      PutOemChar("")
   else
      PutOemChar("Ä")
   endif

   if not MouseKeyHeld()
      // get a keystroke and process defaults
      nKey = GetKey()

      if nKey == <LeftBtn>
         MouseStatus()
         if Query(MouseX) == nRight-1 and Query(MouseY) == nTop
            nKey = <CursorUp>
         endif
         if Query(MouseX) == nRight-1 and Query(MouseY) == (nTop+nWinSize+1)
            nKey = <CursorDown>
         endif
      endif
   endif

   case nKey
     when <LeftBtn>
        MouseStatus()
        nMouseRow = Query(MouseY) - nTop
        nMouseCol = Query(MouseX) - nLeft

        // Is mouse within our window coordinates ???
        if nMouseRow > 0 and nMouseRow <= nWinSize and
           nMouseCol > 0 and nMouseCol <= nLen

           // Jump to the line represented by mouse row coordinates
           GotoLine(CurrLine() + (nMouseRow - nRow))
           nRow = nMouseRow
        endif

     when <CursorDown>, <GreyCursorDown>
        if down() and (nRow <> nWinSize)
           nRow = nRow + 1
        endif // down() and (nRow <> nWinSize)
     when <CursorUp>, <GreyCursorUp>
        if up() and (nRow > 1)
           nRow = nRow - 1
        endif // up() and (nRow > 1)
     when <PgUp>, <GreyPgUp>
        gotoLine(CurrLine()-(nWinSize-1))
        ClrScr()
     when <PgDn>, <GreyPgDn>
        gotoLine(CurrLine()+(nWinSize - 1))
        ClrScr()
     when <Home>, <GreyHome>
        BegFile()
        nRow = 1
     when <End>, <GreyEnd>
        EndFile()
        nRow = iif(CurrLine() > (nWinSize), nWinSize, CurrLine())
   endcase // nKey

   if CurrLine() <= (nWinSize -1) and nRow >= CurrLine()
      nRow = CurrLine()
   endif // CurrLine() <= (nWinSize -1) and nRow >= CurrLine()

   Set(Attr, nSaveAttr)
   Set(Cursor,ON)

   return (nKey)
end QFPopList
