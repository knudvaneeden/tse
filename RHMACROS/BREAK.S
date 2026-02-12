/********************************************************************
One area that TSE doesn't handle is keyboard macro termination on
a negative return code from a command.  This feature is most
desirable is when one wishes to process each line of a file
'til reaching the end, or to process each line on which a string
is found.

If you are a Tessie user that misses that function, here are a
couple of macros that will give you this functionality.

  **Repeat find and repeat down for Keyboard Macro use.**

     <Ctrl R> <Ctrl B>       BlankDownBreakOut() //"Repeat ('til) Blank/Down"
     <Ctrl R> <Ctrl D>       DownBreakOut()      //"Repeat Down"
     <Ctrl R> <Ctrl F>       FindBreakOut()      //"Repeat Find"

    These macros 'break' when Find or RollDown fails.  The RollDown
    also fails on a blank line (with "BlankDownBreakOut" only).
    Provides much of functionality of the TSE Jr. capability to process
    each line of a database file with a keyboard macro.

    Usage. 1)   Bind these three macros and RepeatCmd() to keys.
           2)   Start a keyboard macro.
           3)   Do the steps desired on the current line.
           4)   As the last step, enter the key bound to
                BlankDownBreakOut(), DownBreakOut() or FindBreakout()
                as required.
           5)   Terminate recording of the Keyboard macro.
           6)   If you want to use the keyboard macro again, save
                it (It purges itself on completion.)
           7)   Execute the macro once.
           8)   Touch the key bound to RepeatCmd() and give it a
                number of execution times greater than the number
                of lines in the file.
           9)   Press <Enter>.  The macro will repeat until it
                can no longer meet the DownNOut() or FindOut(),
                as applicable, conditions.
 *************************************************************************/
Proc DownBreakOut()
    BegLine()
    If NOT RollDown()                    //Stops @ EndFile
        PurgeKeyMacro()
    EndIf
End

Proc BlankDownBreakOut()
    BegLine()
    If NOT RollDown() OR CurrChar() < 0  //Stops @ EndFile Or Blank Line
        PurgeKeyMacro()
    EndIf
End

Proc  FindBreakOut()
    If RepeatFind()
        Right()
    Else
        PurgeKeyMacro()
    EndIf
End

<Ctrl R> <Ctrl B>       BlankDownBreakOut() //"Repeat ('til) Blank/Down"
<Ctrl R> <Ctrl D>       DownBreakOut()      //"Repeat Down"
<Ctrl R> <Ctrl F>       FindBreakOut()      //"Repeat Find"

