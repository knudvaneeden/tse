/*******************************************************
This macro will delete ALL BLANK LINES in a marked block.
Created by: Rob Howse, Saskatoon, SK. Dec 12, 1994
Keys: None
 *******************************************************/
proc blankln0()
           if NOT isBlockInCurrFile()            //check for marked block
           message("No Block Marked!")
     endif
           GoToBlockBegin()
        repeat
           GoToPos(PosFirstNonWhite())
           if CurrChar() == _AT_EOL_  DelLine()  //if blank line, delete it
        elseif NOT Down() break                  //break out if end of file
     endif
        until NOT isCursorInBlock()              //quit at end of block
        UnMarkBlock()                            //all done
end

/***************************************************************
This macro will delete all DUPLICATE (ie consecutive) blank lines
in a marked block.  (ONE blank line will be left in place of any
group of consecutive blank lines.)
Created by: Rob Howse, Saskatoon, SK. Dec 12, 1994
Keys: None
 ***************************************************************/
proc blankln1()
           if NOT isBlockInCurrFile()          //check for marked block
           message("No Block Marked!")
        endif
           GoToBlockBegin()
        repeat
           GoToPos(PosFirstNonWhite())
           if NOT (CurrChar() == _AT_EOL_)     //if not blank line
             if NOT (Down() and Down()) break  //try to go down two lines
             endif                             //(break out if end of file)
        else DelLine()                         //if line IS blank, delete it
        endif
        until NOT isCursorINBlock()            //quit at end of block
        UnmarkBlock()                          //all done!
end

Menu blanklinMenu()
  Title = "Delete Blank Lines..."
  x = 46
  y = 3

  "Delete &ALL Blank Lines"           , blankln0()
  "Delete &DUPLICATE Blank Lines"     , blankln1()
end

proc Main()
  blanklinMenu()
end
