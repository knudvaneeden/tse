/*
Program....: qfrowcol.s
Version....: 3.5
Author.....: Randy Wallin/Ryan Katri
Date.......: 12/09/92  08:12 pm   Last Modified: 08/30/95 @ 07:58 am
Notice.....: Copyright COB System Designs, Inc., All Rights Reserved.
Compiler...: TSE 2.5
Abstract...: QFROWCOL is a dBase Specific Row,Col update manager.
QFRestore..: Ø1,1Æ
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
#include ["qfmsg.inc"]

// RCW - simple block adjustment from non_Line / non_inclusive to Line
proc QFBlockSet(var integer nBlockBegLine, var integer nBlockEndLine)
   UnMarkBlock()
   GotoLine(nBlockBegLine)
   BegLine()
   MarkStream()
   GotoLine(nBlockEndLine)
   EndLine()
end QFBlockSet

menu YesNoOnly()  // no cancel
       "&Yes"
       "&No"
end YesNoOnly

proc qfrowcol()
     integer nAdjCol=0,                           // Adjust Column
             nAdjRow=0,                           //
             nTopLine=0,                          // Top Line of Block
             nBottomLine=0,                       // Bottom Line
             nChoice=0,
             nFirstNonWhite=0,                    // from whence we grab the Line
             nGetBufferID=GetBufferID(),          // storing our current ID
             nClipBoardID=Query(ClipBoardId),       //                     Clip
             nTempBoardID=CreateTempBuffer(),     // opening new Clip/Buffer
             nKillMax=Set(KillMax,0)              // turning off Delete History.
     integer nBlockType,
             nBlockBegLine,
             nBlockBegCol,
             nBlockEndLine,
             nBlockEndCol

     string cExt[5]="",                           // Extension check
            cLine[180]="",                        // Current Line
            cnAdjCol[3]="",                       // Text entry of Adj Col
            cnAdjRow[3]="",                       //                   Row
            cnRow[6]="",                          // Text Row Co-ordinates found on current line
            cnCol[180]="",                        //      Col
            cTLine[180]="",                       // Remaining part of Line after Column Co-ordinates
            cSearchExpr[40]="^{[ \t]@}\@#.@,.@{ SAY }|{ GET }"   // our lovely search expression
         // cSearchExpr[40]="^{[ \t]@}\@ #.@,.@{ SAY }|{ GET }"

     // return to current buffer after creating Temp Buffer Above
     GotoBufferID(nGetBufferID)
     cExt=lTrim(SplitPath(CurrFileName(),_EXT_))+" "
     nBlockType=isCursorinBlock()

     // Block has to be set and in a block - safety feature.
     if nBlockType AND pos(cExt,".prg .fmt .qpr .frg .spr ")
        // establish a new ClipBoard For our Undo at the end of the process
        Set(ClipBoardId,nTempBoardID)
        nTopLine=Query(BlockBegLine)
        nBottomline=Query(BlockEndLine)
        if ask("Increment Row: ", cnAdjRow)
           if Ask("Increment Column: ",cnAdjCol)
              nChoice=YesNoOnly("Increment Row: "+cnAdjRow+
                      " Adjust Column: " + cnAdjCol)
              if nChoice==1
                 if (nBlockType==1 AND CurrCol()<>1) OR (nBlockType<>1)
                    // we convert to block type inclusive.
                    nBlockBegLine=Query(BlockBegLine)
                    nBlockBegCol=Query(BlockBegCol)
                    nBlockEndLine=Query(BlockEndLine)
                    nBlockEndCol=Query(BlockEndCol)
                    QFBlockSet(nBlockBegLine,nBlockEndLine)
                 endif // nBlockType<>1
                 // ask only accepts Text Strings - convert to Numeric
                 nAdjRow=VAL(cnAdjRow)
                 nAdjCol=VAL(cnAdjCol)
                 // Hold position()
                 PushPosition()
                 PushBlock()
                 Copy()
                 PopBlock()
                 // start at the beginning of the block
                 GotoBlockBegin()
                 // by using lfind, we can move quickly through a block
                 // to find only what's needed.
                 while lFind(cSearchExpr,"ixl")
                       // message for end-users to confirm and confuse.
                       Message("Incrementing....."+Format(nBottomLine-CurrLine():-3))
                       BegLine()
                       // nFirstNonWhite tells us where the action begins.
                       nFirstNonWhite=PosFirstNonWhite()
                       // cLine = our line of code -
                       // grabbing the full length - hoping nobody in their
                       // clear mind has an @ SAY, GET longer than 180
                       cLine=GetText(nFirstNonWhite,180)
                       if nAdjRow
                          // cnRow is the Row value - ie @ 10,20 SAY - returns "10"
                          cnRow=ltrim(Substr(cLine,2,pos(",",cLine)-2))
                          if Pos(SUBSTR(cnRow,1,1),"1234567890") // no memory variables, please.
                             // the VAL of cnRow gets added to the nAdjRow, then formatted.
                             cnRow=ltrim(format(nAdjRow+VAL(cnRow):3))
                             cLine="@"+format(cnRow:3)+Substr(cLine,Pos(",",cLine),Length(cLine))
                          endif // SUBSTR(cnRow,1,1)
                       endif // nAdjRow
                       if nAdjCol
                          cnCol=ltrim(Substr(cLine,pos(",",cLine)+1,Length(cLine)))
                          if Pos(SUBSTR(cnCol,1,1),"1234567890")
                             cTLine=lTrim(Substr(cnCol,Pos(" ",cnCol),Length(cLine)))
                             cnCol=Substr(cnCol,1,Pos(" ",cnCol))
                             cnCol=ltrim(format(nAdjCol+VAL(cnCol):3))
                             cLine=Substr(cLine,1,pos(",",cLine))+cnCol+" "+cTLine
                          endif // Pos(SUBSTR(cnCol,1,1),"1234567890")
                       endif // nAdjCol
                       GotoColumn(nFirstNonWhite)
                       DelToEOL()
                       InsertText(cLine)
                 endwhile // lFind()
                 PopPosition()
                 PushPosition()
                 // GotoBlockBegin()
                 UpdateDisplay()
                 message("Finished Incrementing "+ ltrim(Format(nBottomLine-nTopLine:3))+ " Row(s). By Row: "+cnAdjRow+" Col: "+cnAdjCol)
                 nChoice=YesNoOnly("Accept Changes and Continue? ")
                 if nChoice==2
                    DelBlock()
                    Paste()
                    message("Row, Column changes reversed.")
                 endif // nChoice==2
                 UnMarkBlock()
                 PopPosition()
              endif // nChoice==1
           endif // Ask("Increment Column: ",nAdjCol)
        endif // ask("Increment Row:", nAdjRow)
     else
        if pos(cExt,".prg .fmt .qpr .frg .spr ")
           QFMessage("Please Mark Area To Be Adjusted First", 5, FALSE)
        else
           QFMessage("Extension not supported", 5, TRUE)
        endif //
     endif // isCursorinBlock()
     Set(ClipBoardId,nClipBoardID)
     AbandonFile(nTempBoardID)
     Set(KillMax,nKillMax)
end qfrowcol

proc main()
    qfrowcol()
end main
