/*
Program....: qfblock.s
Version....: 3.5
Author.....: Randy Wallin & Ryan Katri
Date.......: 08/04/93  10:07 am  Last Modified: 08/30/95 @ 07:58 am
Notice.....: Copyright 1993 COB System Designs, Inc., All Rights Reserved.
QFRestore..: Ø1,1Æ
Compiler...: TSE 2.5
Abstract...: Determines Block size.  You mark an area via Column block, then
             call this macro.  You will get the block size back and can
             insert it into your current program.
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

Proc QFBlocksize()
   integer nBlockType,
           nBeginLine,
           nBeginCol,
           nEndline,
           nEndCol,
           nwStartRow,
           nwStartCol,
           nwEndRow,
           nwEndCol,
           lQuit=TRUE,
           nKey=0,
           lCenter=FALSE,
           nRows,
           nCols
   string cExt[4]=SplitPath(CurrFileName(),_EXT_),
          cWinSize[40]=""
   nBlockType=isBlockInCurrFile()
   if nBlockType
      nBeginLine=Query(BlockBegLine)
      nBeginCol=Query(BlockBegCol)
      nEndline=Query(BlockEndLine)
      nEndCol=Query(BlockEndCol)
      nRows=nEndLine - nBeginLine +1
      nCols=nEndCol - nBeginCol +1

      repeat
          PushPosition()
          GotoBlockBegin()
          if lCenter
             nwStartRow=(25-(nRows))/2
             nwStartCol=(80-(nCols))/2
             nwEndRow=nwStartRow+nRows
             nwEndCol=nwStartCol+nCols
          else
             nwStartRow=CurrRow()
             nwStartCol=CurrCol()
             nwEndRow=(CurrRow())+(nEndLine - nBeginLine)
             nwEndCol=CurrCol()+(nEndCol - nBeginCol)
          endif // lCenter


          if cExt==".s"
             cWinSize=    ltrim(format(nwStartCol: 3)) +
                          ", " + ltrim(format(nwStartRow+1: 3)) + ", " +
                          ltrim(format(nwEndCol: 3))+ ", " +
                          ltrim(format(nwEndRow+1: 3))

          else
             cWinSize=" FROM " + format(nwStartRow: 3) +
                          "," + format(nwStartCol-1: -3) + " TO " +
                          format(nwEndRow: 3) + "," +
                          format(nwEndCol-1: -3)
          endif // cExt==".s"
          PopPosition()


          if nBlockType==8

             message("Current Block: Rows,Cols " + format(nRows:3 ) +
                      "," + ltrim(format(nCols: -3)) +
                       " *OR* " + cWinSize + iif(lCenter," Centered.",""))
             lQuit=FALSE
          else
             message("Length of Block: " + format(nEndCol-nBeginCol +1 :-4 )+
             "Center at: " +format((80-(nEndCol-nBeginCol +1))/2 :-4 ))
             lQuit=TRUE
          endif
          if NOT lQuit
             lQuit=TRUE
             nKey=GetKey()
             case nKey
                when <Ins>
                     PushPosition()
                     GotoBufferID(Query(ClipBoardId))
                     EmptyBuffer()
                     PushPosition()
                     InsertText(cWinSize,_OVERWRITE_)
                     PopPosition()
                     EndLine()
                     DelChar()
                     PopPosition()
                     Message("Window Co-Ordinates "+cWinSize +" inserted into ClipBoard.")
                when <C>,<c>
                     lCenter=NOT lCenter
                     lQuit=FALSE
                otherwise
                     PushKey(nKey)
             endcase // nKey
          endif // NOT lQuit

      until lquit

   else
        message(" QF Window Size: Please mark block first.")
   endif // isBlock
end QFBlockSize

proc Main()
   QFBlockSize()
end Main

