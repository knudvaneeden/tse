// rpm.s - Revision 007
// Replace() Protection Macro

string fnm[40]="rpm"
<ctrlshift r> execmacro(fnm)

/***

This macro protects text outside a column block from being
pulled into a marked column block when a replace() replace
text is shorter than the find text.

This is for the specific instances where large amounts of
search text, like spaces, are deleted using the Replace()
tool. Normally, when this is done in a column block, the
text to the right of the block is pulled into the block
as the deletions take place, and the pulled in text becomes
part of the Replace() process and the search text there is
deleted, too.

This usually happens when doing columns of data or similar
text.

This macro will prevent any of the text to the right of a
column block from being pulled into the column block.
Nothing outside the column block comes into the column
block.

The macro will only work when the replace string is shorter
than the find string. Use the normal Replace() tool for
other replace options.

The macro is set to use the special case Replace() options
"inl" only. An extra Ask() prompt may be added later if use
proves that it is necessary.

This protection macro is particularly beneficial when doing
columns of text or data, since a properly marked column
block will completely protect all columns to the right of
the block from movement or change.

When prompted, enter ordinary text, use ctrl-a to select
text from an ascii chart, or enter special text using the
chr() identification described below.

If you are not using a font that includes graphics
characters, and if you know the ASCII values for your
special characters, you can enter them another way if you
choose not to use the ASCII chart to enter them.

When you are prompted for your find/replace text, you may
enter it like this: chr(228). The macro recognizes the
chr() as being a special character, and the number enclosed
in parenthesis as the ascii value of that character. You may
put several of these characters together in the prompt as
well as mixing regular characters with the special
characters. For example:

chr(228)chr(226)

gives:

äâ

and:

Yellowchr(228)chr(226)Bluechr(227)Green

will produce:

YellowäâBlueãGreen

The non-standard ascii character set will depend on what
font and character set you have active in TSE. The normal
one I use is Terminal, which includes the line-drawing
characters. Be aware that some non-standard ascii characters
may not print properly on some printers, and that some (like
the Tab (chr(9)) will produce unexpected results in TSE on
some monitors, but that most of them do display nicely in
TSE.

Finally, spacing occurs between the last character of each
line in the column block and the first position of the text
to the right of the column block. In columns of data, this
is beneficial, but in ordinary prose text, this will leave a
separation in the text. This separation is made up of spaces
only, so you can easily remove them using the normal
Replace() tool while in the column block--a minor
inconvenience compared to manually doing the same thing to a
large block.

You can also now use the Adjust utility in Potpourri to
align your block left, right, or center.

***/



proc main()

string cr[2]=chr(13)+chr(13)
string fs[80]=""
string rs[80]=""
string pcs[1]=chr(228) // temp protect char

integer bm=0 // block marked?
integer i=0  // loops
integer j=0  // loops
integer n=0  // counting
integer s=0  // find/replace length difference
integer bl=0 // begin line
integer bc=0 // begin column
integer el=0 // end line
integer ec=0 // end column
integer count=0 // total changes

// is there a marked block in tse
bm=isblockincurrfile()
if bm==_column_


  if ask("Text To Find: (Ctrl-A for ASCII Chart)",
        fs,_find_history_) and length(fs)
    addhistorystr(fs,_find_history_)
    // look for maually entered special ascii
      if pos("chr(",fs) // do left
        for i=1 to length(fs)
          if fs[i:4]=="chr(" and val(fs[i+4:length(fs)])
            fs=fs[1:i-1]+chr(val(fs[i+4:length(fs)]))+
               fs[pos(")",fs)+1:length(fs)]
          endif
        endfor
      endif

    ask("Text To Replace: (Ctrl-A for ASCII Chart)",
       rs,_replace_history_)
    addhistorystr(rs,_replace_history_)
    // look for maually entered special ascii
      if pos("chr(",rs) // do right
        for i=1 to length(rs)
          if rs[i:4]=="chr(" and val(rs[i+4:length(rs)])
            rs=rs[1:i-1]+chr(val(rs[i+4:length(rs)]))+
               rs[pos(")",rs)+1:length(rs)]
          endif
        endfor
      endif

    // make sure find is longer than replace
    s=length(fs)-length(rs)

    // if it is, doit
    if s>=1

      gotoblockbegin()
      bl=currline()
      bc=currpos()
      gotoblockend()
      el=currline()
      ec=currpos()
      for i=bl to el
        n=0
        gotoline(i)
        if currlinelen()<>0
          gotopos(bc)
          for j=bc to ec
            gotopos(j)
            if lfind(fs,"inlc")
              n=n+1
              j=currpos()
            endif
          endfor
          if n
            gotopos(ec+1)
            inserttext(format(pcs:n*s:pcs),_insert_)
          endif
        endif
        count=count+n
      endfor
      // do the replacement
      gotoblockbegin()
      lreplace(fs,rs,"inl")
      gotoblockbegin()
      lreplace(pcs," ","inl")
      gotoblockbegin()
      lreplace(pcs,"","in")
      gotoblockbegin()
      scrolltocenter()
    else
      msgbox("Application Error","Replace Text Must Be "+cr+
         "Shorter Than Find Text."+cr+"Use TSE's regular"+
         " Replace() Tool.")
    endif // if rs>fs
  else
    warn("No Find Text")
  endif // if find text
else
  warn("There is no column block marked")
endif // if bm




message("rpm Rev 007 - Summary - Total Changes: "+str(count))

end





