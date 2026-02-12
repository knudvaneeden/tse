/**********************************************************************
procedure==>  vmRingFind  <==by Volker Multhopp  04/19/93
    Searches all ring files for any given string.

    returns:
    notes: Requires user interaction.  Beeps when find is made in a new
    file.  Uses Find_history.  Has its own find options history.

**********************************************************************/
integer  RingFindOptionsHistory     //global

proc vmRingFind()
    integer orgbuf, found=false, newfile=true
    string findstr[40]='', options[11]='', do_now[1]='c'

    if RingFindOptionsHistory == 0
        RingFindOptionsHistory = getfreehistory()
    endif

    found=ask("Search all files for what string?",findstr,_Find_History_)
    if not found or length(findstr)==0 return() endif

    ask("Options [IXW] Ignore-case reg-Xpres Words-only:",options,RingFindOptionsHistory)
    addHistorystr(findstr,_Find_History_)
    found=false
    pushposition()
    orgbuf=getbufferid()

    repeat  // for each file
        repeat  //  for each find
            if newfile
                found=lfind(findstr,options+'g')  // start at bof;
                //  lfind has to be re-inited because lfind hooked to changing files.
            else
                found=lrepeatfind()
            endif
            if found
                scrolltorow(query(windowrows) / 2)
                if newfile and do_now <> 'n' and getbufferid() <> orgbuf
                    // Alert user we've changed files.
                    sound(1100) delay(1) nosound() delay(1)
                    sound(1100) delay(1) nosound()
                endif
                updatedisplay(_default_)  // otherwise no see.
                what_now:
                if not ask(
                'found!  options: Continue, Quit-here, Next-file, or Return-home [CQNR]',do_now)
                    do_now = 'q'
                endif
                lower(do_now)
                case do_now
                    when 'q'
                        killposition()
                        goto out
                    when 'r', 'h'
                        goto home
                    when 'n'
                        break // exit repeatfind
                    when 'c'  // continue looping
                    otherwise
                        warn ('Unsupported key. ')
                        goto what_now
                endcase
            endif
            newfile=false
        until found==false
        newfile=true
        nextfile()
    until getbufferid()==orgbuf

    home:
    popposition()
    out:  // here only if killedposition
    return()

end  // of vmRingFind

//  test <grey*> vmRingfind()