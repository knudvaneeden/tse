// umm.s - Revision 030
// do user macro catalog
// written with TSE-PRO GUI 4.0
string fnm[20] = "umm"
<ctrlshift d> execmacro(fnm)
helpdef ummhelp
"<ESC> to Exit, <Enter> to Return to Menu"
""
"This macro will custom format any of the raw SemWare"
"TSE-PRO and TSEJr User Macro html Catalogs available"
"at the SemWare site into column form."
""
"Once a catalog is in column form, you can convert it"
"into paragraph form for readability. The column form"
"can be sorted on any column using the TSE sort, and"
"that sort order will be maintained in the paragraph"
"form. The column format also offers the advantage of"
"having searches that are not limited by line breaks."
""
"If you are just starting, you MUST copy the SemWare"
"User Macro Catalog from the SemWare site. This requires"
"that you mark and copy the catalog page into your"
"clipboard, then paste it into TSE."
""
"When you do, the listing looks like this:"
""
"Keywords: TSE SEMWARE EDITOR LOG LOGGING"
"Description: This is a self-extracting archive of an..."
"tsepro44.zip 1380721  2005-07-09 (July 01, 2005) - T..."
"tsesh42a.zip 23917  2004-07-26 (Jul 25, 2004) - TSES..."
"Requires TSE 2.6 or higher, and Windows NT or higher..."
""
"DO NOT MAKE CHANGES TO THE CATALOG YOU PASTE INTO TSE"
"BEFORE YOU RUN THIS MACRO ON IT, or the macro may fail."
"The macro looks for things to be in certain places and"
"the only way to insure that is to leave the file in its"
"virgin form."
""
"To convert your TSE-PRO or TSEJr catalog into a readable"
"column format, select C in the opening Menu. Tha macro"
"knows which catalog is being converted and will make the"
"proper changes."
""
"The first form of both catalogs this macro creates is the"
"column form, and it looks like this:"
""
"tsefil31.zip     93716   1995-05-04   Description:..."
"tselog.zip        1048   1994-12-01   Description:..."
"tsepro44.zip   1380721   2005-07-09   Description:..."
"tsesh42a.zip     23917   2004-07-26   Description:..."
"tseshs99.zip     11618   1996-04-17   Description:..."
""
"The paragraph form for both catalogs looks like this:"
""
"FileName: tsepro44.zip"
"FileSize: 1380721"
"FileDate: 2005-07-09"
"Description: (July 01, 2005) - The SemWare Editor"
"Professional v4.4 for Windows (Win95/98/Me/NT/2000/XP or"
"greater) - Test Drive version. GUI interface; Wheel Mouse;"
"Font selection; Single-instance mode option; Transparent"
"mode option; Keep Window on Top option; Multilevel"
"...(rest of the listing)..."
""
"Once the TSE-PRO or the TSEJr catalogs are formatted,"
"the formats are identical and you can use the options"
"A and B to move back and forth between column and"
"paragraph forms on either of the catalogs."
""
"(After using this macro, you can also combine both"
"catalogs into one file and this macro will still work"
"properly. Just be sure you combine columns to columns"
"and paragraphs to paragraphs in the same file.)"
""
"The idea is to be able to sort any of the columns in"
"the column form and produce a paragraph form in that"
"sorted order."
""
"Once you have your formatted catalog forms, you can add"
"new listings to them by selecting the new user macro"
"files from the SemWare site, converting the raw listings"
"to the column form, and simply adding them to your"
"previously created forms. Or, you can just copy a whole"
"fresh listing and start over."
""
"(If you wish, you may also add comments within or to the"
"end of the Description section--there is no size limit"
"for Description except TSE's line-length limit. As set"
"up, this macro limits the line to 3000 characters, but"
"this could be extended to whatever length you prefer--"
"just change the variable lww. You can also change the"
"paragraph wordwrap from 60 by changing the variable sww.)"
""
"The menu selections are:"
""
"A - Converts either the TSE-PRO or the TSEJr paragraph"
"form into the column form. Both column form formatting is"
"the same."
""
"B - Converts either the TSE-PRO or the TSEJr column form"
"into the paragraph form. Both paragraph form formatting is"
"the same."
""
"C - Converts either a raw TSE-PRO or a raw TSEJr html"
"User Macro Catalog page from the SemWare site into the"
"properly formatted column form."
""
"0 - Cancel Macro"
""
"? - View this help/description screen."
""
"Any prompt box that does not have a proper answer will"
"abort the macro."
""
"Remember that you can use the TSE UnDo to reverse any"
"of these procedure during an editing session. And, you"
"can save your formatted catalog to your TSEPRO User"
"Macro directory."
""
"If you cannot resist making changes after you have the"
"new forms, please remember to keep your changes within"
"the obvious field widths. The only field in which you can"
"write an unlimited amount is the Description field. The"
"best place to do that is in the paragraph form."
""
"Remember, too, that after the Column Formatting is done,"
"the TSE Right Margin is set to 3000 (lww), and after the"
"Paragraph Formatting is done, the TSE Right Margin is"
"set to 60 (sww)."
""
"The latest version of this macro, the latest Catalog"
"produced by this macro, and all of the SemWare TSE-PRO"
"and TSEJr User Macro files are available at:"
""
"http://groups.msn.com/asemwareusersgroup"
""
"Enjoy!"
""
"<ESC> to Exit, <Enter> to Return to Menu"
end
menu UmmMenu()
   title="UserMac Formatting Selections Menu - Rev 030"
  "&A-Format TSEPRO/TSEJr Paragraph Form Into Columns"
  "&B-Format TSEPRO/TSEJr Column Form Into Paragraphs"
  "",,divide
  "&C-Format Raw TSE-PRO or TSEJr Macro Catalog Into Columns"
  "",,divide
  "&0-Cancel"
  "&?-Description Of This Macro"
end
proc main()
string cr[2]=chr(13)+chr(13)
string tse[10]="" // catalog id
string u[50]=""
string x[80]=""
integer goodcat=0 // prevent wrong file formatting
integer i=0
integer j=0
integer cf=0     // holds # of files
integer lww=3000 // long wordwrap
integer ok=0
integer p=0
integer p1=0
integer q=0
integer sww=60   // short wordwrap
integer v=0
ok=ummmenu()
if ok // ok start
  case ok
    when 1 // A format tsepro/tsejr paragraphs to columns
      u="A - From Column To Paragraph"
      begfile()
      if gettext(1,20)=="Paragraph Formatting"
        goodcat=1
        begfile() // which cat
          gotoline(2)
          tse="TSE-PRO"
          if pos("TSEJr",gettext(1,80))
            tse="TSEJr"
          endif
          begfile() // remove header/footer
          markline()
          down(5)
          markline()
          delblock()
          endfile()
          if currlinelen()==0
            delline()
          endif
          begfile()
          set(rightmargin,lww)
          for i=1 to numlines() // pull up to one line
            if gettext(1,10)=="FileName: "
              cf=cf+1
              delrightword() // filename
              delchar()
              delchar()
              gotopos(16)
              joinline()
              delrightword() // filesize
              delchar()
              delchar()
              gotopos(26)
              joinline()
              delrightword() // filedate
              delchar()
              delchar()
              gotopos(39)
              joinline()
              delrightword() // description
              delchar()
              delchar()
              execmacro("wrappara") // do long lines
            endif
            down()
          endfor
          begfile()
          for i=1 to numlines() // remove blanks
            if currlinelen()==0
              delline()
            endif
            if currlinelen()<>0
              down()
            endif
          endfor
      endif
    when 2 // B format tsepro/tsejr columns to paragraphs
        u="B - From Paragraph To Column"
        begfile()
        cf=0
      if gettext(1,17)=="Column Formatting"
        goodcat=1
        begfile() // which cat
        gotoline(2)
        tse="TSE-PRO"
        if pos("TSEJr",gettext(1,80))
          tse="TSEJr"
        endif
        begfile() // remove header/footer
        markline()
        down(5)
        markline()
        delblock()
        endfile()
        if currlinelen()==0
          delline()
        endif
        begfile()
        set(rightmargin,sww)
        for i=1 to numlines() // blank line above filenames
          if currlinelen()<>0
            up()
            addline()
            down()
          endif
            down()
        endfor
        begfile() // format the paragraphs
        for i=1 to numlines()
          begline()
          if currlinelen()<>0
            cf=cf+1
            begline()
            inserttext("FileName: ",_insert_)
            gotopos(26)
            splitline()
            down()
            begline()
            inserttext("FileSize: ",_insert_)
            gotopos(21)
            splitline()
            down()
            begline()
            inserttext("FileDate: ",_insert_)
            gotopos(24)
            splitline()
            down()
            begline()
            inserttext("Description: ",_insert_)
            execmacro("wrappara")
          else
            down()
          endif
        endfor
        gotoline(7)
        for i=1 to numlines()
          if currlinelen()==0
            down()
          endif
          if currlinelen()<>0
            down()
          else
            delline()
          endif
        endfor
      endif
    when 4 // C format raw tsepro/tsejr catalogs to columns
      u="C - Convert Raw Catalog"
      begfile()
      for i=1 to 10
        if
        pos("(YYYY-MM-DD)",gettext(1,50)) or
        pos("Recent TSE-Pro Macro",gettext(1,50)) or
        pos("All TSE-Pro Macro Files Sorted",gettext(1,50))
          goodcat=1 tse="TSE-PRO"
        elseif
        pos("TSE-Jr Macro Files",gettext(1,30)) or
        pos("TSE-Jr Files sorted",gettext(1,30))
          goodcat=2 tse="TSEJr"
        else
          down()
        endif
      endfor
      if  goodcat
        begfile()
        if pos("Formatting",gettext(1,40))==0
          markline() // remove the top header
          if goodcat==1 // for tsepro
            down(8)
          else
            down(7) // for tsejr
          endif
          markline()
          delblock()
          endfile() // remove the bottom footer
          markline()
          if goodcat==1
            up(10) // for tsepro
          else
            up(4) // for tsejr
          endif
          markline()
          delblock()
          begfile()
          for i=1 to numlines() //del blanks/nonfiles  in list
            if currlinelen()==0
              delline()
            endif
            if pos("www.semware",gettext(1,20)) // for tse
              delline()
              delline()
            elseif currlinelen()<>0
              down()
            endif
          endfor
          begfile()
          v=0
          for i=1 to numlines()
            p=pos(".",gettext(1,12))
            p1=pos(" ",gettext(1,13))
            v=val(gettext(p1,5))
            if p and v and p1
              cf=cf+1
              insertline()
              down()
            endif
            down()
          endfor
          endfile()    // do long wrapping
          set(rightmargin,lww)
          markline()
          begfile()
          markline()
          execmacro("wrappara")
          unmarkblock()
          begfile()
          v=0
          for i=1 to numlines() // format the fields
            p=pos(" ",gettext(1,13))
            if p
              gotopos(p)
              for j=p to p+4 // do the size
                if gettext(p,1)==" "
                  delchar()
                endif
              endfor
              v=val(gettext(p,7))
              gotopos(p)
              inserttext(format(" ":23-p-length(str(v))),_insert_)
              if goodcat==1
                gotopos(23)            // for tsepro
                inserttext(" ",_insert_)
                gotopos(36)
                inserttext("  ",_insert_)
              else // for tsejr
                gotopos(25)             // for tsejr
                inserttext(" ",_insert_)
                  x=gettext(32,2)
                  if val(x)<80
                    x="20"+x+"-"
                  else
                    x="19"+x+"-"
                  endif
                gotopos(26)
                inserttext(x,_insert_)
                gotopos(33)
                delchar()
                delchar()
                delchar()
                gotopos(37)
                inserttext("  ",_insert_)
              endif
            endif
            down()
          endfor
          if goodcat==2
            begfile()
            for i=1 to numlines()
              if currlinelen()==0
                delline()
              endif
              if currlinelen()<>0
                down()
              endif
            endfor
          endif
        endif
      endif
    when 6 // 0 cancel
    when 7 // ? show help screen and restart/quit
      q=quickhelp(ummhelp)
  endcase
  // put in new header/footer
  if pos("Formatting",gettext(1,40))==0 and goodcat
    if ok==1 or ok==2 or ok==4
      set(rightmargin,lww)
      begfile()
      begline()
      for i=1 to 6
        insertline()
      endfor
      begfile()
      if ok==2 // line 1
        inserttext("Paragraph")
      else
        inserttext("Column")
      endif
      inserttext(" Formatting <--- Do NOT change "+
                 "these two words.",_insert_)
      down()
      begline() // line 2
      inserttext("The "+str(cf)+" "+tse+" User Macro "+
                 "Files from the html page.",_insert_)
      down()
      begline() // line 3
      if ok==1 or ok==4
        set(rightmargin,lww)
        set(wordwrap,OFF)
        x=str(lww)
      else
        set(rightmargin,sww)
        set(wordwrap,ON)
        x=str(sww)
      endif
      inserttext("========== "+
                 "Please Note: Right Margin Set To "+
                 x+" ===========",_insert_)
      down()
      begline() // line 4
      if ok==2
        inserttext("The paragraphs are presented in the sort",_insert_)
        down()
        begline() // line 5
        inserttext("order of your last column format.",_insert_)
      else
        inserttext("FileName      FileSize   FileDate     "+
                 "Description",_insert_)
        down()
        begline()
        inserttext("============  ========   ==========   "+
                   "=============================",_insert_)
      endif
      gotoline(7)
      if ok==1 or ok==4
        for i=7 to numlines()-1
          gotoline(i)
          if currlinelen()==0
            delline()
          endif
        endfor
      endif
      endfile()
      addline()
      begfile()
    endif
  endif
  begfile()
endif // ok finish


if goodcat
  msgbox("Summary for SemWare UserMac Catalog Formatter",
  "Your Selection was "+chr(64+ok)+cr+cr+
  str(cf)+" Catalog Files Processed")
elseif q
  execmacro(fnm)
elseif ok==7 and q==0 or ok==6
  warn("Cancelled")
else
  msgbox("Incorrect Application Of This Macro",
         "Either"+cr+"Not A TSE Catalog File"+cr+
         "Or"+cr+"Not A Correct File Format For Your"+cr+
         "Selection "+u+".")
endif
end
