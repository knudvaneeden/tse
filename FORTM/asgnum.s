// Macro to search for a set variable in FTN and then allocate
//  sequential numbers to it. E.G. IBSERR(1) = 100, 102 3tc
proc main()
        string jock[20] ="IBSERR(1)"
        string strt [5] ="100"
        string incr [5] ="1"
        string sss[1] = ' '
        integer strtv
        integer incrv
        integer strl
        integer endl
        integer count = 0
// is there a line block?
        strl = 1
        endl = NumLines()
        if IsBlockInCurrFile() == _LINE_
           strl = Query(BlockBegLine)
           endl = Query(BlockEndLine)
        else
          ask("no line block-use whole file? Y/N",sss)
          if sss == 'Y' or sss == 'y'
          else
            return()
          endif
        endif
        pushposition()
        ask("string to search for is ",jock)
        ask ("Start is ",strt)
        ask ("Increment is ",incr)
        gotoline(strl)
        gotocolumn(0)
        strtv = val(strt)
        incrv = val(incr)
loop1:
        if lfind(jock,'ix+')
           if Currline() >= endl
              goto endit
           endif
           sss = gettext(1,1) //  check if a comment
           if sss == 'C' or sss == 'c' or sss == '*'
           else
              if lfind("=",'c')
                 deltoeol()
                 inserttext("= " + str(strtv))
                 strtv = strtv + incrv
                 count = count + 1
              endif
           endif
           goto loop1
        endif
endit:
        popposition()
        Message("Finished ",count," items processed")
end
