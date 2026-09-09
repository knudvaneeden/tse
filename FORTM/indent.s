// Macro to indent all if, else, elseif etc.in a  BLOCK
// Optionally indents DO s.
// Assume all Fortran code is in uppper case and Labels start in col 1.
proc main()
    string indentV[1] = '3'
    integer indent
    string DOY[1] = 'Y'
    string cc[1]
    integer doll
    integer LL
    integer Label
    integer Prime  // flag for prime text unpack
    integer Quote  // flag for quotation string mode
    string  Prime_Txt [16] // Prime text unpack - Compressed 1st.chrs
    string  Line_Txt [66]  // Left Justified Line Text
    string  Line_raw [66]  // 'Raw' Line text 7-72
    integer requote
    integer non_blank // non- space character found
    integer Bra      // ending bracket flag
    integer ID      // Indent position current line
    integer ID2      // Indent position next line
    integer then_flg
    string  then_txt[5]
    integer ID_Pres // Present indent position
    string  new_Txt[66]
    string  Init_col [2] // Initial column to start indentation
    integer in_col
    integer xx, ps,SS
    string  Lblstr[8]     // Do label text string
    integer trial
    integer lp0,lp1,lp2,lp3,lp4,lp5,lp6,lp7,lp8,lp9
    integer U_Line, Last_U_Line // Number & Last unable to adjust
    U_line = 0
    Last_U_line = 0
    lp0 = 0
    lp1 = 0
    lp2 = 0
    lp3 = 0
    lp4 = 0
    lp5 = 0
    lp6 = 0
    lp7 = 0
    lp8 = 0
    lp9 = 0
// Ask indent value
    ASK ("Number of columns to indent? ",indentV)
    indent = Val(indentV)
    ID = 0
    ID2 = 0
    then_flg = 0
    then_txt = ''
// Ask if DO loops need indentation
    Ask("DO loops to be indented? (Y/N)",DOY)
    if DOY == 'Y' or DOY == 'y'
        doll = 1
    else
        doll = 0
    endif
// Ask for initial column for indentation
Ask_again:
    Init_col = '7'
   ASK("Initial column to start indentation? ",INIT_COL)
   in_col = val(init_col)
   if in_col < 7 or in_col > 72
      goto Ask_again
   endif
   pushposition()
   gotoblockbegin()
   if IsBlockMarked() == 0
      message ('no marked block')
      goto ender
   endif
   LL = CurrLine()
Starter:
   cc = GetText(1,1)
//   Empty Line ?
   if cc == ''
        goto NextLine
   endif
//  is it a comment line?
   if cc == 'C' or cc == 'c' or cc == '*'
        goto NextLine
   endif
//  If DO loop's to be processed - unpack any label
    if doll == 1
        label = val(GetText(1,5))
     endif
    Line_Raw = GetText(7,72)
//  Check for continuation line
    cc = GetText(6,1)
    non_blank = 0
    Line_Txt = ''
    if cc == ' ' or cc == '0'
//     No continuation line
       Quote = 0
       Bra = 0
//      Did Previous line end with )THEN ?
       if then_flg == 1 and then_txt == 'THEN'
           ID = ID + 1
           ID2 = ID
       endif
       then_flg = 0
       then_txt = ''
       Prime = 1
       prime_txt = ''
    else
//     Continuation line
       if quote == 1
          non_blank = 1
       endif
    endif
    requote = Quote
    xx = 1
    ID_pres = 0
    while xx <= Length(Line_Raw)
        cc = Line_Raw[xx]
//        Create Left Justified Text
        if cc <> ' '
           non_blank = 1
        endif
        if non_blank == 1
           Line_Txt = Line_Txt + cc
        else
          ID_PRES = xx
        endif
        xx = xx + 1
//         First priority- check for quotes
        if cc == "'"
           if quote == 1
              quote = 0
           else
              quote = 1
           endif
        elseif prime == 1 and cc <> ' '
           prime_txt = prime_txt + cc
//            Stop prime function searching for following
           if cc == '(' or cc == '=' or cc == ',' or cc == '='
              if prime_txt == 'IF('
//                  Search for end bracket
                 Bra = 1
              elseif prime_txt == 'ELSEIF('
                 Bra = 1
                 ID  = ID - 1
                 ID2 = ID
              elseif Substr(prime_txt,1,2) == 'DO' and doll == 1
//               Possible DO loop check further
                 SS = 3
                 Lblstr = ''
                 while SS <= length(prime_txt)
                    cc = prime_txt[SS]
                    if cc >= '0' and cc <= '9'
                        Lblstr = Lblstr + cc
                    else
                      goto chk_label
                    endif
                    SS = SS + 1
                 endwhile
chk_label:
//                  check for valid label
                 trial = val(Lblstr)
                 if trial <> 0
//                    Search for label in block
                    SS = LFind('^' + str(trial),'xlw')
                    GotoLine(LL)
                    if SS == 1
//                         Max. 0f 10 imbedded loops
                       if lp0 == 0
                          lp0 = trial
                       elseif lp1 == 0
                              lp1 = trial
                       elseif lp2 == 0
                              lp2 = trial
                       elseif lp3 == 0
                              lp3 = trial
                       elseif lp4 == 0
                              lp4 = trial
                       elseif lp5 == 0
                              lp5 = trial
                       elseif lp6 == 0
                              lp6 = trial
                       elseif lp7 == 0
                              lp7 = trial
                       elseif lp8 == 0
                              lp8 = trial
                       elseif lp9 == 0
                              lp9 = trial
                       else
                          goto no_indent
                       endif
                       ID2 = ID + 1
no_indent:
                    endif
                 endif
              endif
              prime = 0
           endif
        elseif bra <> 0
//              Counting brakets to look for )THEN
           if cc == '('
                bra = bra + 1
           endif
           if cc == ')'
                bra = bra - 1
                if bra == 0
                   then_txt = ''
                   then_flg = 1
                endif
            endif
        elseif then_flg <> 0
            if cc <> ' '
                then_txt = then_txt + cc
            endif
        endif
    endwhile
//    Check for any pending ELSE or ENDIF
    if prime == 1
        if prime_txt == 'ELSE'
           ID2 = ID
           ID = ID - 1
        elseif prime_txt == 'ENDIF'
           ID = ID - 1
           ID2 = ID
        endif
     endif
//      DO loop processing on check on label match
     if Doll == 1 and label <> 0
         if label == lp0
            lp0 = 0
            ID =  ID - 1
            ID2 = ID
         endif
         if label == lp1
            lp1 = 0
            ID = ID - 1
            ID2 = ID
         endif
         if label == lp2
            lp2 = 0
            ID = ID - 1
            ID2 = ID
         endif
         if label == lp3
            lp3 = 0
            ID = ID - 1
            ID2 = ID
         endif
         if label == lp4
            lp4 = 0
            ID = ID - 1
            ID2 = ID
         endif
         if label == lp5
            lp5 = 0
            ID = ID - 1
            ID2 = ID
         endif
         if label == lp6
            lp6 = 0
            ID = ID - 1
            ID2 = ID
         endif
         if label == lp7
            lp7 = 0
            ID = ID - 1
            ID2 = ID
         endif
         if label == lp8
            lp8 = 0
            ID = ID - 1
            ID2 = ID
         endif
         if label == lp9
            lp9 = 0
            ID = ID - 1
            ID2 = ID
         endif
     endif
//  Is text already in correct position?
     if ID < 0
        ID = 0
     endif
     ps = ID * indent + In_col - 7
     if ps == ID_pres
        goto no_output
     endif
//    Check if line finished with non-terminated quote or was a
//    continuation line starting with non-terminated quote.
     if quote == 1 or requote == 1 or ps >= SizeOf(Line_txt)
        Message('Unable to adjust line '+ str(LL))
        U_Line = U_line + 1
        Last_U_line = LL
        goto no_output
     endif
//      Space fill LJ Text
    cc = ' '
    while Length(Line_txt) <> SizeOf(Line_txt)
        Line_txt = Line_txt + cc
    endwhile
//    Check for enough spaces at back of string
    xx = Length(Line_txt)
    while xx > Length(Line_txt) - ps
        cc = Line_txt[xx]
        xx = xx - 1
        if cc <> ' '
           Message('Not able to adjust line ' + str(LL))
           U_Line = U_line + 1
           Last_U_line = LL
           goto no_output
        endif
    endwhile
//     Create & output new string
    cc = ' '
    New_txt = ''
    xx = 1
    while xx <= ps
        New_txt = New_txt + cc
        xx = xx + 1
    endwhile
    New_txt = New_txt + Line_txt
    GoToColumn(7)
    InsertText(New_txt, _OVERWRITE_)
no_output:
     ID = ID2
//    Next line if any
Nextline:
     LL = LL + 1
     if LL > Query(BlockEndLine)
        if U_Line <> 0
           Message('Finished- Line errors ',U_Line,' last error line '
           ,Last_U_Line)
         else
            Message("Finished- no errors")
         endif
        goto ender
     else
        GoToLine(LL)
     endif
     goto Starter
ender:
    popposition()
end
