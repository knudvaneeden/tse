/*
Program....: qfcolor.s
Version....: 3.5
Author.....: Randy Wallin & Ryan Katri
Date.......: 06/02/93  02:58 pm  Last Modified: 08/30/95 @ 07:58 am
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

proc QFColor()
   integer nKey, nRow, nCol, nSaveAttr
   integer lBlink = FALSE
   string cColors[48] = "N  B  G  BG R  RB GR W  N+ B+ G+ BG+R+ RB+GR+W+ "
   string nFG[4], nBG[4]
   integer nKeyStat=Query(EquateEnhancedKbd)
   Set(EquateEnhancedKbd,ON)

   nSaveAttr = Set(Attr, Query(TextAttr))

   PopWinOpen(5, 5, 22, 17, 1, "", Query(OtherWinBorderAttr))
   ClrScr()

   nRow = 0
   while nRow < 8
      nCol = 0
      while nCol < 16
         Set(Attr, (nRow * 16) + nCol)
			VGotoXy(nCol+1, nRow+4)
			PutOemChar("")
         nCol = nCol + 1
      endwhile
      nRow = nRow + 1
   endwhile

   message("ENTER: Select color   ESC: Cancel   B: Blink on/off")

   nCol = 1
   nRow = 8
   repeat
      // create the color string
      nFG = substr(cColors, (nCol) * 3 - 2, 3) + " "
      nBG = substr(cColors, (nRow) * 3 - 2, 3) + " "
      nFG = substr(nFG, 1, pos(" ", nFG)-1) + iif(lBlink, "*", "")
      nBG = substr(nBG, 1, pos(" ", nBG)-1)

      // show the color string
      VGotoXy(1,2)
      Set(Attr, Color(White on Blue))
      Write(format("Color: " + nFG + "/" + nBG :-16 ))


      // set the color based upon our row/column coordinates
      // Turn blinking on for to display sample color only
      Set(Attr, ((nRow-1) * 16) + nCol - 1 + iif(lBlink, 128, 0))

      // show the sample color on the first row of our window
      VGotoXy(1,1)
      Write("  Quiet Flight  ")


      // reset color in case blinking was turned on
      Set(Attr, ((nRow-1) * 16) + nCol - 1)

      // Display the character we'll use as our "cursor"
      GotoXy(nCol, 3+nRow)
      PutOemChar("")

      // physical cursor was advanced, so move back
      GotoXy(nCol, 3+nRow)

      nKey = GetKey()
      case nKey
         when <B>           // blink on/off
            lBlink = not lBlink
         when <cursorup>
            if nRow > 1
               nRow = nRow - 1
            endif
         when <cursordown>
            if nRow < 8
               nRow = nRow + 1
            endif
         when <cursorleft>
            if nCol > 1
               nCol = nCol - 1
            endif
         when <cursorright>
            if nCol < 16
               nCol = nCol + 1
            endif
         when <home>
            nCol=1
         when <end>
            nCol=16
         when <PgUp>
            nRow = 1
         when <PgDn>
            nRow = 8
         when <enter>, <greyenter>
            InsertText(nFG + "/" + nBG, _INSERT_)
      endcase

      // redisplay the character our "cursor" overwrote
      PutOemChar("")

   until nKey == <escape> or nKey == <enter> or nkey == <greyenter>

   PopWinClose()

   Set(Attr, nSaveAttr)
   UpdateDisplay()
   SET(EquateEnhancedKbd,nKeyStat)

end QFColor

proc Main()
     QFCOLOR()
end Main

