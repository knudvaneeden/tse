// PgfRev1054.s - comprehinsive folding
string rev[50]="PgfRev1054"

<ctrlshift p><p> execmacro("pgfx25")

/***
Written/Compiled With TSEPRO GUI 4.4
Save/Compile Date-:> 2012 10 05 @ 11:11 am
{This Revision:}
1054- 20130108- special version for TSE 2.5 DOS
1054- 20121005- safe save: published
1053- 20121005- safe save
1052- 20121005- adding autosave toggle
              - added show all fold locations
              - added keys for find next code and show all locations
1051- 20121005- safe save
1050- 20121004- safe save
              - changed fold buffer barrier string
1049- 20121003- now test it... added left margin protect for fold code
1048- 20121003- changes made, see if it works
1047- 20121002- removing clean and exit and save routines
              - adding the pgo-style safety saves for folding and expading
              - changing pgf.buff filename to pgffold.dat, same directory
              -
1009- 20120628- now adding fold block paragraphs to one respective line
1008- 20120628- from jigpgrev1007 and jigfoldns.s and jigfolds.s
              - okay, fold to one line works
              - expand one line works
***/

helpdef pgfx25help
  title="Pretty Good Folding Help"

""
"Macro Name: PGF - Pretty Good Folding"
"Macro Version: PgfRev1054 for TSEPRO 4.4"
"Special Version: Pgfx25 for TSE 2.5"
""
"Assigned Keys:"
"=============="
"CtrlShift p p - Execute/Terminate PGF"
"CtrlShift p m - PGF Menu"
""
"CtrlShift p f - fold to one"
"CtrlShift p e - expand marked"
"CtrlShift p - - fold to many"
"CtrlShift p = - expand all"
"CtrlShift p g - find next fold code"
"CtrlShift p s - show fold code locations"
"CtrlShift p v - view the fold buffer"
""
"Simple Operation:"
"(See the PGFx25.doc)"
""

end


// local globals
string pgfbuff[255]="" // fold buffer filename
string curfil[255]=""  // source filename

integer pgfbuff_id=0         // fold buffer id
integer ob=0                 // fold source file
integer tb=0                 // fold work buffer

string mrkr[1]=chr(128)      // separate fold code from source filename in fold buffer
string mrkr2[1]=chr(129)     // folding work marker
string barrier[60]="/***(ÿÿÿÿÿ"+"ÿÿÿÿÿ)Fold End Code-Do Not Edit or Remove***/" // barrier line
string barrier2[10]="ÿÿÿÿÿ"+"ÿÿÿÿÿ" // barrier code
string uniq[3]=""            // the new uniq fold code
string hiuniq[3]=chr(131)+chr(131)+chr(130) // the current high unique fold code
string uniqform[39]="[\d131-\d250][\d131-\d250][\d131-\d250]" // the fold code form

integer bl=0          // line block begin line
integer el=0          // line block endline
integer oilba=0       // original insert line block above default
//integer lmc=4         // left margin control for folded codes
integer all=0         // do all paragraphs flag
integer numpgffolds=0 // keep track of numbr of folds
integer active=0      // macro is active
integer autosave=1    // autosave on fold/expand, 0=off,1=on

// make unique
proc mpgfmakeuniq()

string a[1]=chr(131)      // left most char
string b[1]=chr(131)      // second from left char
string c[1]=chr(130)      // third from left char
string e[3]=""//"+[!!!!]" // first use uniq code

// look for existing uniq code in pgfbuff
e=hiuniq
a=e[1:1]
b=e[2:1]
c=e[3:1]

// create the new uniq code
c=chr(asc(c)+1)
if c>=chr(251)
  c=chr(131)
  b=chr(asc(b)+1)
  if b>=chr(251)
    b=chr(131)
    a=chr(asc(a)+1)
    if a>=chr(251) // start over if necessary
      a=chr(131)
      b=chr(131)
      c=chr(131)
    endif
  endif
endif

uniq=a+b+c

// keep track of highest fold code used
hiuniq=uniq

end

// simplifying folding/expanding
proc mpgffold2one()

if active and currfilename()<>pgfbuff

  // for one fold
  if all==0
    curfil=currfilename()
  endif
  ob=getbufferid()

  // close unfinished marking
  if query(marking)
    set(marking,off)
  endif

  // get or mark text to be folded
  if isblockincurrfile()==_line_
    lfind("[!-~]","glx")
    bl=currline()
    lfind("[!-~]","bglx")
    el=currline()
  else
    if currlinelen()
      if lfind("^$","bx")
        down()
      else
        begfile()
      endif
      bl=currline()
      if lfind("^$","+x")
        up()
      else
        endfile()
      endif
      el=currline()
    else
      if all==0
       sound(1600,1) delay(18) nosound() // sound(30)
      endif
      goto ending
    endif
  endif

  // if more than one line, mark it
  if el>bl
    markline(bl,el)
  else
    if all==0
     sound(1600,1) delay(18) nosound() // sound(30)
      message("Cannot fold one line paragraphs.")
    endif
    goto ending
  endif

  // skip already folded lines
  gotoblockbegin()
  if lfind(uniqform,"cg^x")
   sound(1600,1) delay(18) nosound() // sound(30)
    message("Cannot Fold Line Already Folded.")
    goto ending
  endif

  // create the uniq code for the new fold
  gotobufferid(pgfbuff_id)
  mpgfmakeuniq()     // make uniq code

  // add filename location to folded text in buffer
  lfind(barrier2,"bg")
  addline(uniq+" File Location"+mrkr+curfil)
  numpgffolds=numpgffolds+1

  // move folded text to pgfbuff
  set(insertlineblocksabove,off)
  moveblock()
  set(insertlineblocksabove,oilba)
  gotoblockbegin()
  unmarkblock()

  // clear stray blank top line from fold buffer
  pushposition()
  begfile()
  repeat
    if currlinelen()==0
      delline()
    endif
  until currlinelen()<>0 or (not down())
  popposition()

  // return top line of folded text to org file
  markline()
  markline()

  // add fold separator to end of buffer
  endfile()
  addline(barrier)

  // place header line back in original file
  gotobufferid(ob)
  set(insertlineblocksabove,on)
  copyblock()
  set(insertlineblocksabove,oilba)
  gotoblockbegin()
  unmarkblock()
  begline()
  inserttext(uniq,_insert_)

  if all==0
   sound(1600,1) delay(18) nosound() // sound(9000)
    if autosave
      pushposition()
      gotobufferid(pgfbuff_id)
      savefile()
      popposition()
      savefile()
    endif
  endif
  scrolltocenter()

else
 sound(1600,1) delay(18) nosound() // sound(30)
  message("Macro not Active or in PGF Fold Buffer. Nothing done.")
endif

goto ending
ending:

end

// fold paragraphs in a block to individual folds
proc mpgffold2many()

if active and currfilename()<>pgfbuff

  all=1
  curfil=currfilename()
  ob=getbufferid()

  // mark whole file
  if isblockincurrfile()<>_line_
    markline(1,numlines())
  endif

  // close unfinished blocks
  if query(marking)
    set(marking,off)
  endif

  pushposition()

  // mark text to be folded
  lreplace("^",mrkr2,"nglx")

  // clear marks from blank lines
  lreplace(mrkr2+"$","","nglx")
  gotoblockbegin()
  unmarkblock()

  // fold each paragraph in turn
  repeat
    pushposition()
    mpgffold2one()
    popposition()
    if keypressed() goto ending endif
  until lfind(mrkr2,"+^")==0// or not down()

  // remove remaining marks
  gotobufferid(pgfbuff_id)
  lreplace(mrkr2,"","ng")
  if autosave
    pushposition()
    gotobufferid(pgfbuff_id)
    savefile()
    popposition()
    savefile()
    popposition()
  endif
 sound(1600,1) delay(18) nosound() // sound(9000)
  all=0
  lreplace(mrkr2,"","ng")

else
 sound(1600,1) delay(18) nosound() // sound(30)
  message("Macro not Active or in PGF Fold Buffer. Nothing done.")
endif

goto ending
ending:

end

// expand
proc mpgfexpand()

if active and currfilename()<>pgfbuff

  // expand only one
  if all==0
    ob=getbufferid()
    curfil=currfilename()
  endif

  pushposition()

  // look for unique fold tag in current line [+][\d091][0-9][0-9][0-9][\d093]
  if lfind(uniqform,"cg^x")//"[+][\d091][0-9][0-9][0-9][\d093]","cg^x")
    uniq=gettext(1,3)

    // go to pgfbuff and find folded text and move folded text back to orig file
    gotobufferid(pgfbuff_id)

    // see if fold exists in buffer
    if lfind(uniq,"g^")
      delline()
      delline()
      markline()
      lfind(barrier2,"+")
      delline()
      up()
      markline()
      gotobufferid(ob)
      lfind(uniq,"g^")
      set(insertlineblocksabove,off)
      moveblock()
      set(insertlineblocksabove,oilba)
      gotoblockbegin()
      unmarkblock()
      up()
      lreplace(uniq,"","cng^")
      numpgffolds=numpgffolds-1

      // save the files if success
      if all==0
       sound(1600,1) delay(18) nosound() // sound(9000)
        if autosave
          pushposition()
          gotobufferid(pgfbuff_id)
          savefile()
          popposition()
          savefile()
        endif
      endif
    endif
  else
    if all==0
     sound(1600,1) delay(18) nosound() // sound(30)
      message("No Fold Code on Cursor Line. Nothing done.")
    endif
  endif
  popposition()
  scrolltocenter()

else
 sound(1600,1) delay(18) nosound() // sound(30)
  message("Macro not Active or in PGF Fold Buffer. Nothing done.")
endif

goto ending
ending:

end

// expand all
proc mpgfexpandall()

if active and currfilename()<>pgfbuff

  curfil=currfilename()
  ob=getbufferid()

  // identify or make block
  if isblockincurrfile()<>_line_
    markline(1,numlines())
  endif
  if query(marking)
    set(marking,off)
  endif
  bl=query(blockbegline)
  el=query(blockendline)
  gotoblockbegin()

  // if block, expand folds
  if el>bl and lfind(uniqform,"gl^x")
    tb=createtempbuffer()
    moveblock()
    unmarkblock()
    gotobufferid(tb)
    begfile()

    // one by one expand
    repeat
      if lfind(uniqform,"cg^x")
        uniq=gettext(1,3)
        gotobufferid(pgfbuff_id)
        if lfind(uniq,"g^")
          delline()
          delline()
          markline()
          lfind(barrier2,"+")
          delline()
          up()
          markline()
          gotobufferid(tb)
          set(insertlineblocksabove,off)
          moveblock()
          set(insertlineblocksabove,oilba)
          gotoblockbegin()
          up()
          lreplace(uniq,"","cng^")
          unmarkblock()
        endif
        if keypressed() goto ending endif
      endif
      if keypressed() goto ending endif
    until not down()
    gotobufferid(tb)
    unmarkblock()
    markline(1,numlines())
    gotobufferid(ob)
    set(insertlineblocksabove,on)
    moveblock()
    set(insertlineblocksabove,oilba)
    gotoblockbegin()
    scrolltocenter()
    unmarkblock()
    abandonfile(tb)
   sound(1600,1) delay(18) nosound() // sound(9000)
    if autosave
      pushposition()
      gotobufferid(pgfbuff_id)
      savefile()
      popposition()
      savefile()
    endif
  endif

 sound(1600,1) delay(18) nosound() // sound(9000)

else
 sound(1600,1) delay(18) nosound() // sound(30)
endif

goto ending
ending:

end

// find next fold code
proc mpgffindcode()

if find(uniqform,"+^x")
else
  message("No folded text found.")
endif

end

// toggle autosave on/off
proc mpgftoggleautosave()

autosave=not not autosave

end

// view the fold buffer
proc mpgfview()

if currfilename()<>pgfbuff
  placemark('p')
  editfile(pgfbuff)
  updatedisplay()
 sound(1600,1) delay(18) nosound() // sound(9000)
  message("Use CtrlShift p v to return to your original file.")
else
  gotomark('p')
endif

end

// show all fold locations
proc mpgfshowallfoldlocations()

if lfind(uniqform,"ga^vx")
else
 sound(1600,1) delay(18) nosound() // sound(40)
  message("No folded Text Found.")
endif

end

// menu
menu mpgfmenu()
  title="PgfRev1054 Menu"
  history

"Fold Paragraph or Block To One Fold Line"       , mpgffold2one()
"Fold Paragraphs To Multiple Fold Lines"         , mpgffold2many()
"" , , divide
"Expand Folded Text At CursorLine"               , mpgfexpand() // expand marked
"Expand All Folded Text"                         , mpgfexpandall() // expand all
"" , , divide
"Find Next Folded Text"                          , mpgffindcode()
"Show All Fold Locations"                        , mpgfshowallfoldlocations()
"View The PGF Fold Buffer"                       , mpgfview()
"" , , divide
"Toggle AutoSave On/Off"[getglobalstr("pgftoggle"+str(autosave)):3] , mpgftoggleautosave()
"Simple Help"                                                       , quickhelp(pgfx25help)
"" , , divide
"Terminate Macro"                                , execmacro(rev)

end

proc main()

mpgfmenu()

oilba=query(insertlineblocksabove)

pgfbuff=loaddir()+"pgffold.dat"

// hook start or end continuous hiliting the
if active==0
  active=1
  pushposition()
 sound(1600,1) delay(18) nosound() // sound(9000)
  updatedisplay(_window_refresh_)

  setglobalstr("pgftoggle0","OFF")
  setglobalstr("pgftoggle1","ON")
  editfile(pgfbuff)
  buffertype(_hidden_)
  pgfbuff_id=getbufferid()
  message(rev+" is now ACTIVE. Use <Ctrlshift p><p> to Terminate, <ctrlshift p><m> for menu.")

  // get the highest uniq code in fold buffer if one
  begfile()
  repeat
    if lfind(uniqform,"cg^x")
      numpgffolds=numpgffolds+1
      if gettext(1,3)>hiuniq
        hiuniq=gettext(1,3)
      endif
    endif
  until not down()
  popposition()

// terminate
else
 sound(1600,1) delay(18) nosound() // sound(40)
  updatedisplay(_window_refresh_)
  message(rev+" is now TERMINATED. Use <CtrlShift p><p> to execute again.")
  active=0
  numpgffolds=0
  //purgemacro(rev) // remove macro completely after termination
  goto ending
endif

goto ending
ending:

end

<ctrlaltshift p><m> mpgfmenu()                 // menu
<ctrlaltshift p><f> mpgffold2one()             // fold to one
<ctrlaltshift p><e> mpgfexpand()               // expand marked
<ctrlaltshift p><-> mpgffold2many()            // fold to many
<ctrlaltshift p><=> mpgfexpandall()            // expand all
<ctrlaltshift p><g> mpgffindcode()             // find next fold code
<ctrlaltshift p><s> mpgfshowallfoldlocations() // show fold code locations
<ctrlaltshift p><v> mpgfview()                 // view the fold buffer

