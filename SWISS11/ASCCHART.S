/*=========================================================================*/
/*                                                                         */
/*  This macro is part of the "SwissArmyTool()" menu package, written      */
/*  and compiled by David Daniel Anderson.  This package collects, into    */
/*  a single TSE menu, many of the standard charts and utilities which     */
/*  programmers find useful.  Most of the features were written in SAL -   */
/*  the macro language for The SemWare Editor ("TSE").                     */
/*                                                                         */
/*  The entire "SwissArmyTool()" menu package should be available on       */
/*  SemWare's BBS (phone 1-404-641-8968), as SWISSnn.ZIP (where "nn" is    */
/*  the current version number).                                           */
/*                                                                         */
/***************************************************************************/
/***************************************************************************/
/* TSE Macro  : AscChart (alternate ASCII chart)                           */
/* Programmer : David Daniel Anderson                                      */
/*                                                                         */
/* Purpose    : AscChart() provides a simple pop-up chart of all 256 ASCII */
/*              characters, including their Decimal & Hexadecimal values.  */
/*                                                                         */
/*              This is similar to mAsciiChart() provided with TSE, but is */
/*              more colorful and, in my opinion, easier to read and use.  */
/*                                                                         */
/* Revision   : 1995/03/01 - first public version (v1.0)                   */
/*                                                                         */
/* Notice     : Public Domain.  Comments to author welcome on ILink,       */
/*              RIME, or Internet (david.daniel.anderson@panasia.com).     */
/*                                                                         */
/* Usage      : Can be bound to a key and burned into TSE, or run as an    */
/*              external macro.                                            */
/*              Additional navigation help is fairly intuitive, and is NOT */
/*              shown on-screen when active.                               */
/*                                                                         */
/* Note       : Display format for this macro was adapted from "asc.com",  */
/*              a TSR ASCII chart by PC Magazine.                          */
/***************************************************************************/

proc Chart(integer FirstNum)  // Called by "AscChart()"
integer count=0,x,y,i=FirstNum,
        DecAttr=15,
        HexAttr=10,
        ChrAttr=14

  Set(Attr,ChrAttr) VGotoXY(23,0) Write(chr(i))
  repeat
    x=iif((count < 16),2,16)
    y=(count mod 16)
    VGotoXY(x,2+y)
    if i < 256
      Set(Attr,DecAttr)
        Write(Format((i):3:chr(32)))
      VGotoXY(WhereX()+2,WhereY())
      Set(Attr,HexAttr)
        Write(Format((i):2:chr(32):16))
      VGotoXY(WhereX()+2,WhereY())
      Set(Attr,ChrAttr)
        Write(Chr(i))
    else
      Set(Attr,0)
        Write(Format('':10:chr(32)))
    endif
    count=count+1
    i=i+1
  until count==32
end

proc AscChart()
integer BoxAttr=iif(Query(TextAttr)==9,15,9),
        FirstNum=iif((CurrChar()<0),0,CurrChar()),
        WordAttr=12, InstAttr=11

  PopWinOpen(45,5,74,23,2,'',BoxAttr)
  Set(Attr,0)   ClrScr()
  Set(Attr,InstAttr) VGotoXY(4,0) Write(' <Enter> inserts: [ ] ')
  Set(Attr,InstAttr) VGotoXY(7,18) Write(' <Escape> exits ')

  Set(Attr,WordAttr)
  VGotoXY(2,1) Write('Dec Hex Char  Dec Hex Char')

  display:
    Chart(FirstNum)
    Case GetKey()
      when <CursorUp>,    <greyCursorUp>   FirstNum=FirstNum-1
      when <CursorDown>,  <greyCursorDown> FirstNum=FirstNum+1
      when <PgUp>,        <greyPgUp>       FirstNum=FirstNum-32
      when <PgDn>,        <greyPgDn>       FirstNum=FirstNum+32
      when <Home>,        <greyHome>       FirstNum=0
      when <End>,         <greyEnd>        FirstNum=224
      when <Enter>,       <greyEnter>  InsertText(Chr(FirstNum)) goto close
      when <Escape> goto close
    endcase
    FirstNum=iif((FirstNum>255),255,(iif((FirstNum<0),0,FirstNum)))
    goto display

  close:
  PopWinClose()
end

proc main()   // If burning into TSE, eliminate this part,
  AscChart()  //  and assign "AscChart()" to your preferred key.
end
