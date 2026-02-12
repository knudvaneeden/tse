// TSE Macro File (UPDOWN.S)
// Moves a selected line of code up or down (and displaces other lines
// around it).
// This version is 1.00 (written today...)
///////////////////////////////////////////////////
// Version 1.00 written by John Meadows on 09/18/95
// Phone:  (310) 302-4627
// CIS:    74513,2616
// NET:    johnm@felix.scvnet.com
//
// NOTES on Version 1.00
//
// I have a friend who uses a heavily customized version of another editor,
// and he had a macro that would select the line of text that the cursor
// was currently on, and move it either up or down, moving other lines of
// code up or down as necessary.
//
// I thought that was pretty darned useful, so I did it myself.  Voila!
// Enjoy -- and your comments are welcome!
//

Proc GrabCurrLine()
   BegLine()
   MarkToEOL()
End

Proc MoveItUp()
   DelLine()
   Up()
   UnDelete()
   GrabCurrLine()
End

Proc MoveItDown()
   DelLine()
   Down()
   UnDelete()
   GrabCurrLine()
End

Proc Main()
   integer exit_flag = FALSE
   repeat
      GrabCurrLine()
      UpdateDisplay()
      Case GetKey()
         when <CursorUp>
            MoveItUp()
         when <CursorDown>
            MoveItDown()
         when <Escape>
             exit_flag = TRUE
         when  <Enter>, <GreyEnter>
             exit_flag = TRUE
      EndCase
      UpdateDisplay()
   until exit_flag
   UnMarkBlock()
End


<Alt /> Main()

// End File UpDown.S

