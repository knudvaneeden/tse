// dem.s - do enclosures - Rev 011
// a macro to put quote marks around text
// macro filename
string fnm[40]="dem"
<ctrlshift p> execmacro(fnm)

helpdef demhelp // main menu help
"<ESC> to Exit, <Enter> to Return to Menu"
""
"Designer Enclosures"
""
"This macro will enclose text with enclusure characters of"
"your choice. The main menu will ask you to choose several"
"regular enclosure characters, such as double and single"
"quotation marks, and will also offer you the opportunity to"
"design a custom set of enclosures using the 'Other'"
"selection."
""
"What happens after the main menu?:"
""
"If you choose one of the standards enclosures listed, the"
"macro will detect whether you have a block marked, let you"
"choose to enclose either all or just the block, ask you if"
"you want blank lines enclosed, too, and then applies the"
"enclosures. If it is a column block, the enclosures will be"
"placed on the left and right boundaries of the column block."
""
"If you choose 'Other', the macro asks for the left enclosure"
"character(s), then asks for the right enclosure"
"character(s). You can use as many as 80 characters for each"
"side. A history list is provided for your convenience."
""
"Using Ctrl-A, you can enter graphics and other special"
"characters at the prompts for your enclosure designs."
""
"If you are not using a font that includes graphics"
"characters, and if you know the ASCII values for your"
"special characters, you can enter them another way if you"
"choose not to use the ASCII chart to enter them."
""
"When you are prompted for your enclosure characters, you may"
"enter them like this: chr(228). The macro recognizes the"
"chr() as being a special character, and the number enclosed"
"in parenthesis as the ascii value of that character. You may"
"put several of these characters together in the design as"
"well as mixing regular characters with the special"
"characters. For example:"
""
"chr(228)chr(226)"
""
"gives:"
""
"‰‚"
""
"and:"
""
"Yellowchr(228)chr(226)Bluechr(227)Green"
""
"will produce:"
""
"Yellow‰‚Blue„Green"
""
"The non-standard ascii character set will depend on what"
"font and character set you have active in TSE. The normal"
"one I use is Terminal, which includes the line-drawing"
"characters. Be aware that some non-standard ascii characters"
"may not print properly on some printers, and that some (like"
"the Tab (chr(9)) will produce unexpected results in TSE on"
"some monitors, but that most of them do display nicely in"
"TSE."
""
"As with choosing one of the regular enclosure sets, after"
"designing an enclosure set, the macro detects whether you"
"have a block marked in a loaded file. If you do, it gives"
"you the opportunity to either enclose all of the lines in"
"the current file, or just the lines in the marked block."
""
"If you choose to enclose the marked block only, the macro"
"detects whether it is a line-block or a column-block and"
"encloses the marked block appropriately."
""
"But before it does that, it finally asks if you want to"
"enclose blank lines, too."
""
"The macro then applies the enclosure markers as you"
"selected. If you are not satisfied with the result, you may"
"use the TSE UnDo to restore the original text."
""
"If there is no marked block, the macro returns you to your"
"previous position."
""
"If there is a marked block, the macro leaves the block"
"marked as it exits, makes the file where the enclosure took"
"place the current file, and leaves the cursor at the top of"
"the marked block. If it is a column block, it also extends"
"the marked block to cover the new enclosure marks. (NOTE: If"
"you UnDo after a column block enclosure, the extended block"
"marking will remain in place. If you wish to do the same"
"column block again, you will have to re-mark the column"
"block.)"
""
"Pressing ESC at any prompt will abort the macro."
""
"The source and latest version of this macro can be found at"
"my SemWare site:"
""
"http://groups.msn.com/asemwareusersgroup"
""
"Enjoy!"
""
"<ESC> to Exit, <Enter> to Return to Menu"
end

menu demMenu()
   title="Designer Enclosures - Revision: 011"
  "&"+chr(34)+"-Quotation Marks - "+chr(34)+chr(34)
  "&'-Single Quotes - `'"
  "&(-Parenthesis - ()"
  "&[-Brackets - []"
  "&{-Curly Braces - {}"
  "&<-Arrows - <>"
  "& -Single Spaces -   "
  "&*-Single Asterisks - **"
  "&--Single Dashes - --"
  "&.-Single Periods - .."
  "&O-Other"
  "&?-Help"
  "&Cancel"
end

proc main()

string cr[1]=chr(13)
string qs[1]=chr(34) // quote
string ls[80]="" // left enclosure
string rs[80]="" // right enclosure
string rev[119]="Designer Enclosures: Revision 011"

integer ak=0 // ok ask
integer i=0  // loops
integer bl=0 // begin line
integer bc=0 // begin column
integer el=0 // end line
integer ec=0 // end column
integer blank=0 // do blank lines
integer bm=0 // type of block marking
integer ok=0 // do all or block
integer sc=0 // select the kind of enclosure
integer qh=0 // return to macro from help
integer didit=0 // summary if done
integer dem_history=0 // dem history list

dem_history=getfreehistory("dem:enclosures")

sc=demmenu()


case sc

  when 1  // quotations
    ls=qs
    rs=qs

  when 2 // single quotes
    ls="`"
    rs="'"

  when 3 // parenthesis
    ls="("
    rs=")"


  when 4 // brackets
    ls="["
    rs="]"


  when 5 // curly braces
    ls="{"
    rs="}"


  when 6 // arrows
    ls="<"
    rs=">"


  when 7 // arrows
    ls=" "
    rs=" "


  when 8 // arrows
    ls="*"
    rs="*"


  when 9 // arrows
    ls="-"
    rs="-"


  when 10// arrows
    ls="."
    rs="."


  when 11 // user design
    ak=ask("Left Enclosure Char(s) (Ctrl-A For ASCII Chart)",
        ls,dem_history) and length(ls)
    addhistorystr(ls,dem_history)
    if ak
      ak=ask("Right Enclosure Char(s) (Ctrl-A For ASCII Chart)",
          rs,dem_history) and length(rs)
      addhistorystr(rs,dem_history)
    endif
    // look for maually entered special ascii
    if length(ls) and length(rs) and ak
      if pos("chr(",ls) // do left
        for i=1 to length(ls)
          if ls[i:4]=="chr(" and val(ls[i+4:length(ls)])
            ls=ls[1:i-1]+chr(val(ls[i+4:length(ls)]))+
               ls[pos(")",ls)+1:length(ls)]
          endif
        endfor
      endif
      if pos("chr(",rs) // do right
        for i=1 to length(rs)
          if rs[i:4]=="chr(" and val(rs[i+4:length(rs)])
            rs=rs[1:i-1]+chr(val(rs[i+4:length(rs)]))+
               rs[pos(")",rs)+1:length(rs)]
          endif
        endfor
      endif
    endif
    if ak==0
      sc=0
    endif


  when 12 // help screen
    qh=quickhelp(demhelp)
    goto finish


  when 13 // cancel
    sc=0

endcase

if sc // if menu selection

  // is there a marked block in tse
  bm=isblockmarked()
  if bm
    ok=msgboxex("Do Enclosing Text-All Or Block",
             "A-Enclose All Lines?"+cr+
             "B-Enclose Marked Lines?"+cr+cr,
             "[&All];[&Block];[&Cancel]")
  else
    ok=msgbox("Do Enclosing Text-Confirm",
      "Enclose All Lines?",_yes_no_cancel_)
    if ok==2
      ok=0
    endif
  endif // if isblock

  if ok // check about blank lines
    blank=msgbox("Do Enclosing Text-Blanks",
      "Do you want to enclose blank lines?",
      _yes_no_cancel_)

    if blank // yes or no
      didit=1
      if ok==1 // do all lines
        pushposition()
        begfile()
        // do all lines
        for i=1 to numlines()
          if currlinelen()<>0
            begline()
            inserttext(ls,_insert_)
            endline()
            inserttext(rs)
          endif // if currline
          if currlinelen()==0 and blank==1
            begline()
            inserttext(ls+rs)
          endif // if currine 0
          down()
        endfor
        popposition()
      endif // if ok 1

      if ok==2 // do blocks
        bm=isblockmarked() // what kind of block

        // do line block
        if bm==_line_      // line block
          gotoblockbegin()
          bl=currline()
          gotoblockend()
          el=currline()
          for i=bl to el
            gotoline(i)
            if currlinelen()<>0
              begline()
              inserttext(ls,_insert_)
              endline()
              inserttext(rs)
            endif
            if currlinelen()==0 and blank==1
              begline()
              inserttext(ls+rs)
            endif
          endfor
        endif // if bm line

        // do column block
        if bm==_column_    // column block
          gotoblockbegin()
          bl=currline()
          bc=currpos()
          gotoblockend()
          el=currline()
          ec=currpos()
          for i=bl to el
              gotoline(i)
            if currlinelen()>=bc
              gotopos(bc)
              inserttext(ls,_insert_)
              gotopos(ec+1+length(ls))
              inserttext(rs,_insert_)
            endif
            if (currlinelen()==0
                or currlinelen()<bc)
                and blank==1
              gotopos(bc)
              inserttext(ls,_insert_)
              gotopos(ec+1+length(ls))
              inserttext(rs,_insert_)
            endif
          endfor
          gotoblockend()
          right(length(ls+rs))
          markcolumn()
        endif // if bm column
      endif // if ok 1
    endif // if blank
  endif // if ok

endif // if sc

finish:
if qh
  qh=0
  execmacro(fnm)
elseif didit
  message("Finished - "+Rev)
else
  message("Cancelled - "+Rev)
endif


end

