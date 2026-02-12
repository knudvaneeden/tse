/* UNWRAP.S
    Unwrap a paragraph to a single long line, to create generic files
    usable by word processors.
    Works on all lines from current line to next blank line.
    Use either from the Potpourri or from the key you assign
                                            (recompile, of course)
    This version works on one paragraph at a time; a whole file conversion would
    not know if you had something you wanted kept as-is.
    For additional functionality, see my DOCMODE package on Semware's BBS and
    FTP site.
*/

proc mGeneric()
    integer clin
    Set(Break, ON)

     while PosFirstNonWhite() == 0 // started on a blank line
           if not Down()
               return()
           endif
     endwhile
     clin = CurrLine()            // set start point
     while PosFirstNonWhite()     // find end of paragraph
           if not Down()
              goto generizar
           endif
     endwhile
     Up()

     generizar:
     loop
         if not Up()
            Alarm()
            GoToPos(1)
            return()
         endif
         GotoPos(PosLastNonWhite())
         Right()
         Right()
         if not Joinline()
            alarm()
            Message("Line Length Limit exceeded!")
            if Down() BegLine() endif
            return()
         endif
         while isWhite()
            DelChar()
         endwhile
         if CurrLine() <= clin
            break
        endif
     endloop
     if not Down()
        return()
     endif
     GoToPos(1)
end

proc main()
    mGeneric()
end

// <Key_of_your_choice>    mGeneric()
<CtrlAlt B>                mGeneric()
