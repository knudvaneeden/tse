proc BegPara()
     /*
          Goes to beginning of current or next paragraph:
               When on a non-blank line, goes to:
               (a) First line following the first blank line above
                   the current line, or
               (b) First line of file if no blank line above current line.
               When on a blank line, goes to:
               (a) Next non-blank line, or
               (b) Last line of file if no non-blank line found.
     */
     if PosLastNonWhite() == 0
          repeat until ( Down() AND PosLastNonWhite() <> 0 )
                    OR ( CurrLine() == NumLines() )
     else
          repeat until ( Up() AND PosLastNonWhite() == 0 )
                    OR ( CurrLine() == 1 )
          if currline() <> 1
               Down()
          endif
     endif
     GotoPos(PosFirstNonWhite())
end

proc EndPara()
     /*
          If current line is non-blank, goes to non-blank line
          immediately preceding the next blank line or end of file.

          If current line is blank,

     */
     Down()
     if PosLastNonWhite() == 0                   // get to first line
          Up()
          BegPara()
     endif
     repeat until ( Down() AND PosLastNonWhite() == 0 )
               OR ( CurrLine() == NumLines() )
     if CurrLine() <> NumLines()
          Up()
     endif
     EndLine()
end

proc prevpara()
     begpara()                // beginning of para
     repeat
          Up()
     until currline() == 1 or PosLastNonWhite() == 0  // inter para space
     repeat
          Up()
     until currline() == 1 or PosLastNonWhite() <> 0  // end of prev para
     begpara()                                    // beg of prev para
end

proc markpara()
     UnMarkBlock()
     PushPosition()
     begpara()
     MarkLine()
     endpara()
     MarkLine()
     PopPosition()
end

integer proc nextpara()
     endpara()
     repeat
          Down()
          if currline() == numlines()
               return(FALSE)
          endif
     until PosLastNonWhite() // beg of next para
     GotoPos(PosFirstNonWhite())
     return(TRUE)
end
/*
proc twiddle_para ( integer direction)
//   integer waseof = FALSE
     integer wasateof = FALSE
     integer start, endpoint

     pushblock()
     markpara()
     begpara()
     start = currline() - 2
     endpara()                        // end of present paragraph
     if down()                        // inter-paragraph line
          markline()
          if currline() == numlines()
               wasateof = TRUE
          endif
     else
          wasateof = TRUE               // is EOF
          addline()
          markline()
     endif

     if direction == -1
          up()                     // end of current para
          prevpara()               // beginning of prev para
     elseif direction == +1
          if wasateof
               gotoblockend()
               if PosLastNonWhite() == 0
                    delline()
               endif
               return()
          endif
          endpara()                // end of following para
          if NOT nextpara()
               addline()
               addline()
          endif
     endif
     moveblock()
     if direction == +1
          gotoblockend()
          endpoint = currline() + 2
          gotoline(start)
          repeat
               if PosLastNonWhite() == 0
                    down()
                    while PosLastNonWhite() == 0 and currline() <> numlines()
                         delline()
                    endwhile
               else
                    down()
               endif
          until currline() >= endpoint or not down()
          if PosLastNonWhite() == 0 and
                    currline() == numlines ()
               delline()
          endif
          gotoblockbegin()
     endif
     unmarkblock()
     popblock()
end
*/

/*
     asdsa
     asdsad
*/
/*
menu paramenu()
history
     "&Beg" , begpara()
     "&End" , endpara()
     "&Next", nextpara()
     "&Prev", prevpara()
end

<f10> paramenu()

*/