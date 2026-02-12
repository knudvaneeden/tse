/****************************************************************************
                           Initial Caps Macro
 ****************************************************************************
                                  Version 2
                               **************

  Copyright: 1993 David Marcus

          Permission is granted to all persons for non-commercial
          distribution of this file and the macros and ideas contained
          herein provided (a) credit is given to the author and (b) all
          changes not made by the author are attributed.

          Permission is granted to SemWare for commercial distribution
          provided (a) and (b) above.

  Author:  David Marcus

  Assistance/Enhancement: Ray Asbury

  Date:    5-7-93

  Description:

          InitCaps() is a small macro that uppercases the first
          letter of each word within a marked block. Like similar
          TSE commands (Upper() and Lower()), the cursor must be
          inside the block.

          This file contains directions for making it part of the
          standard (non-WordPerfect, etc.) TSE interface.

  Installation:

  1. Place this file in the directory where your configuration
     (interface) files reside.  Add this line to your TSE.S (or other
     configuration) file:

          #include ['initcaps.inc']

     Place this line anywhere in the file as long as it comes before the
     procedure ChangeCase().

  2. Find the procedure ChangeCase() in your configuration file (TSE.S).
     It begins with this line:

          proc ChangeCase(integer type)

  3. In that procedure, find the section that looks like this:

          case casetype
              when UPPER_CASE
                  Upper()
              when LOWER_CASE
                  Lower()
              otherwise
                  Flip()
          endcase

  4. Add these two lines between "case casetype" and "when UPPER_CASE":

          when INIT_CAPS
               InitialCaps()

  5. Find this macro in TSE.S:

          proc mUpper()
               casetype = UPPER_CASE
               CaseMenu("Upper Case")
          end

   6. Add this macro before it:

          proc mInitCaps()
               casetype = INIT_CAPS
               CaseMenu("Initial Caps")
          end

   7. Find your Block menu in TSE.S. It begins with this line:

          menu BlockMenu()

   8. In that menu, find this line:

      "Fl&ip   "                 ,   mFlip()             , DontClose

      Add this line beneath it:

      "Ini&tCaps"                ,   mInitCaps()         , DontClose

   9. (optional) In your TSE.KEY file, add this line after the line
      containing "<Shift F4>              mUpper()".

      <Ctrl F4>               mInitCaps()


  10. (optional) Update your help file with any of the keys listed above.

  11. Re-bind the editor using the -b switch of sc.

**************************************************************************/
constant INIT_CAPS = 3

proc InitialCaps()
     integer lastLine = 0
     if IsBlockMarked()
        PushPosition()
        GotoBlockEnd()
        lastLine = CurrLine()
        GoToBlockBegin()
        Lower()
        BegLine()
        repeat
            if IsCursorInBlock()
                case CurrChar()
                    when _AT_EOL_, _BEYOND_EOL_
                    otherwise
                        InsertText(UpCase(GetText(CurrPos(), 1)),
                            _OVERWRITE_)
                endcase
            endif
        until ( NOT WordRight() )
           OR ( CurrLine() > lastLine )
        PopPosition()
     endif
end
