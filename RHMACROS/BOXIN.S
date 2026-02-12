/**********************************************************
This macro draws a Box around a marked COLUMN block.
 'Inserts' and does not overwrite any text.
If you want a particular linetype, simply set it before you 'Box'!
No fancy options like George de Bruin's "BoxIt".  <sorry!>
But it will 'get the job done' and do it without overwriting
any information, even in a solid matrix of characters.
For more 'white space' around text inside box, just include
more 'white space' in marked block. (Not possible in a solid
matrix unless manually inserted beforehand)
Created by Rob Howse, Saskatoon, SK. Dec 11, 1994   --Rbh
 ***********************************************************/
proc mLineDraw(INTEGER dir, INTEGER len)
    integer i = len
    while i
        LineDraw(dir)
        i = i - 1
    endwhile
end

proc main()
    if isBlockInCurrFile() <> _COLUMN_  //is there a marked COLUMN block
        message("No Column Block In File.")           //in current file?
        return()
    endif

    GoToBlockBegin()  InsertLine()            //insert line above block
    GoToBlockEnd()  AddLine() Right()         //addline below block
    repeat
    Up()  InsertText(" ",_INSERT_)  Left()    //insert space at right side
    until CurrLine() == Query(BlockBegLine)
    GoToBlockBegin()
    repeat
    InsertText(" ",_INSERT_)  Down()  Left()  //insert space at left side
    until CurrLine() == (Query(BlockEndLine) + 1)
    GoToBlockBegin() Up() Right()             //position cursor ready to draw
    mLineDraw(_RIGHT_, (Query(BlockEndCol)) - (Query(BlockBegCol)) + 1)
    mLineDraw(_DOWN_, (Query(BlockEndLine)) - (Query(BlockBegLine)) + 2)
    mLineDraw(_LEFT_, (Query(BlockEndCol)) - (Query(BlockBegCol)) + 2)
    mLineDraw(_UP_, (Query(BlockEndLine)) - (Query(BlockBegLine)) + 2)
    LineDraw(_RIGHT_)                         //finish top left corner
    GoToBlockEnd()  Down()  Down()  BegLine()
    UnMarkBlock()                             //all done
end
