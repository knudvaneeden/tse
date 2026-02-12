/************************************************************************
  Author:  Hans de Wit
           The Netherlands

  Description:
  This is probably a very old idea.
  Sometimes you want to "multiply" a block with 1 or 2 numbers rising.
  The numbers you indicate by a # are starting values.

  Examples:

1 Your block could look like this (1 line):
  bla var#1 bla

  If you generate this block 10 times with a step of 1 it will look like this:
  bla var1 bla
  bla var2 bla
  bla var3 bla
  bla var4 bla
  bla var5 bla

2 It doesn't matter what kind of block it is. For Spss users:
  recode (#1=#2)

  will be like this:
  recode (1=2)(2=3)(3=4)(4=5)(5=6)

  You have to take care that you don't block behind the EndOfLine.
  In that case you will have:
  recode (1=2)
         (2=3)
         (3=4)
         (4=5)
         (5=6)

3 You could als have something like:
   var#001

  It will be:
  var001 var002 var003 var004 var005 var006 var007 var008 var009 var010

  So generate uses this extra zero's
 ************************************************************************/
integer gen_repeat_hist,gen_step_hist

proc main()
/* why have 10 subprocs. 1 big main does the job */
string dumbo[6]=''
string strfigure1[10]=''
string strfigure2[10]=''
string prefix[10]=''
integer repeteer,gen_step,ok,bufid,index1,index2,extra
integer newbufid,oldbufid,oldclpbrd,newclpbrd
integer cijfpos,figure1,figure2,lengonefigure,lprefix,lprefixmin
integer typeblock,saveilba

/* Setup Historybuffers for repeat and gen_step
   If this is the first time generate is called we have to setup these buffers */
if gen_repeat_hist==0
   gen_repeat_hist=getfreehistory()
   gen_step_hist=  getfreehistory()
   AddHistoryStr(str(1),gen_step_hist)
endif

/* Ask 2 things: # repeat and step */
ok=ask("Repeat #: ",dumbo,gen_repeat_hist)
repeteer=val(dumbo)
if ok and length(dumbo)>0
  dumbo=''
  ok=ask("Step: ",dumbo,gen_step_hist)
  gen_step=val(dumbo)
  if ok and length(dumbo)>0

/* Setup the right buffers. I work via a temporary clipboard (newclpbrd)
   I don't want to change the active clipboard.
   Also a temporary buffer is created to gather the results. */

    message('Working')
    oldbufid=getbufferid()
    newbufid=createtempbuffer()
    oldclpbrd=getclipboardid()
    newclpbrd=createtempbuffer()
    setclipboardid(newclpbrd)

/*  the text is copied into the new clipboard
    If no block is active the active line is used.
    otherwise message and return                    */

    gotobufferid(oldbufid)
    typeblock=isblockmarked()
    if (typeblock==0)
    if (query(UseCurrLineIfNoBlock)==On)
       typeblock=_LINE_
    else
       message("No block is active")
       return()
    endif
    endif

    cut()

/*  Every time the contents of the temporary clipboard is pasted into the
    temporary buffer. Then the macro searches the # numbers.
    When the macro pastes it has to be under the text in the temporary buffer
    that's why we do: */

    saveilba=set(insertlineblocksabove,FALSE)
    gotobufferid(newbufid)
    begfile()
    index1=0
    repeat
      extra=index1*gen_step
      paste()
/* Now 1 paste. # are replaced by the correct number */
      while lfind('#','I')>0
        delchar()
        pushposition()
        markchar()
        wordright()
        strfigure1=getmarkedtext()
/* When you get a text, there can be a prefix, 000 .
   That prefix has to be used. You have to determine the length of the
   prefix. When the number itself is 1 figure extra the prefix has to be 1
   figure shorter. */

        unmarkblock()
        figure1=val(strfigure1)
        strfigure2=str(figure1)
        cijfpos=pos(strfigure2,strfigure1)
        prefix=''
        if cijfpos>1
           prefix=substr(strfigure1,1,cijfpos-1)
        endif

/* get rid of the old number, the # was gone already */
        popposition()
        index2=1
        lengonefigure=length(prefix+strfigure2)
        while index2<=lengonefigure
         delchar()
         index2=index2+1
        endwhile

/* Now it starts to be difficult, so i stop commenting. (Good habbit, succes!) */
        figure2=figure1+extra
        lprefixmin=length(str(figure2))-length(str(figure1))
        lprefix=length(prefix)
        if lprefixmin>lprefix
          prefix=''
        else
          prefix=substr(prefix,1,lprefix-lprefixmin)
        endif
        inserttext(prefix+str(figure2),_INSERT_)
      endwhile
      endfile()
      index1=index1+1
    until index1>repeteer-1
    begfile()
    if typeblock==_LINE_
       markline()
    else
       markchar()
    endif
    endfile()
    copy()
    gotobufferid(oldbufid)
    set(insertlineblocksabove,saveilba)
    paste()
    setclipboardid(oldclpbrd)
    abandonfile(newclpbrd)
    abandonfile(newbufid)
    gotobufferid(oldbufid)
    updatedisplay(_STATUSLINE_REFRESH_)
  endif
endif
end
