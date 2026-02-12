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
/* TSE Macro  : BoxChars                                                   */
/* Programmer : David Daniel Anderson                                      */
/*                                                                         */
/* Purpose    : BoxChars() provides a pop-up window showing the Decimal    */
/*              equivalents of the line and box drawing ASCII characters.  */
/*                                                                         */
/* Revision   : 1995/03/01 - first public version (v1.0)                   */
/*                                                                         */
/* Notice     : Public Domain.  Comments to author welcome on ILink,       */
/*              RIME, or Internet (david.daniel.anderson@panasia.com).     */
/*                                                                         */
/* Usage      : Can be bound to a key and burned into TSE, or run as an    */
/*              external macro.                                            */
/*              Additional usage help is shown on-screen when active.      */
/*                                                                         */
/* Note       : Display format for this macro was adapted from PC-Pilot    */
/*              (a very handy public domain pop-up program).               */
/***************************************************************************/

proc Cycle(integer BoxStyle)  // Cycle through box-drawing char displays
integer NumChar=11, LineChar=15
 case BoxStyle
  when 1
    Set(Attr,NumChar)
      VGotoXY(4,3) Write('196       179')
      VGotoXY(9,5) Write('194')
      VGotoXY(2,6) Write('218           191')
      VGotoXY(2,8) Write('195           180')
      VGotoXY(9,9) Write('197')
      VGotoXY(2,10) Write('192           217')
      VGotoXY(9,11) Write('193')

    Set(Attr,LineChar)
      VGotoXY(4,4) Write('ÄÄÄ        ³')
      VGotoXY(5,6)  Write('ÚÄ  ÄÂÄ  Ä¿')
      VGotoXY(5,8)  Write('ÃÄ  ÄÅÄ  Ä´')
      VGotoXY(5,10) Write('ÀÄ  ÄÁÄ  ÄÙ')

  when 2
    Set(Attr,NumChar)
      VGotoXY(4,3) Write('205       186')
      VGotoXY(9,5) Write('203')
      VGotoXY(2,6) Write('201           187')
      VGotoXY(2,8) Write('204           185')
      VGotoXY(9,9) Write('206')
      VGotoXY(2,10) Write('200           188')
      VGotoXY(9,11) Write('202')

    Set(Attr,LineChar)
      VGotoXY(4,4) Write('ÍÍÍ        º')
      VGotoXY(5,6)  Write('ÉÍ  ÍËÍ  Í»')
      VGotoXY(5,8)  Write('ÌÍ  ÍÎÍ  Í¹')
      VGotoXY(5,10) Write('ÈÍ  ÍÊÍ  Í¼')

  when 3
    Set(Attr,NumChar)
      VGotoXY(4,3) Write('205       179')
      VGotoXY(9,5) Write('209')
      VGotoXY(2,6) Write('213           184')
      VGotoXY(2,8) Write('198           181')
      VGotoXY(9,9) Write('216')
      VGotoXY(2,10) Write('212           190')
      VGotoXY(9,11) Write('207')

    Set(Attr,LineChar)
      VGotoXY(4,4) Write('ÍÍÍ        ³')
      VGotoXY(5,6)  Write('ÕÍ  ÍÑÍ  Í¸')
      VGotoXY(5,8)  Write('ÆÍ  ÍØÍ  Íµ')
      VGotoXY(5,10) Write('ÔÍ  ÍÏÍ  Í¾')

  when 4
    Set(Attr,NumChar)
      VGotoXY(4,3) Write('196       186')
      VGotoXY(9,5) Write('210')
      VGotoXY(2,6) Write('214           183')
      VGotoXY(2,8) Write('199           182')
      VGotoXY(9,9) Write('215')
      VGotoXY(2,10) Write('211           189')
      VGotoXY(9,11) Write('208')

    Set(Attr,LineChar)
      VGotoXY(4,4) Write('ÄÄÄ        º')
      VGotoXY(5,6)  Write('ÖÄ  ÄÒÄ  Ä·')
      VGotoXY(5,8)  Write('ÇÄ  Ä×Ä  Ä¶')
      VGotoXY(5,10) Write('ÓÄ  ÄÐÄ  Ä½')
 endcase
end

proc BoxChars()
integer cursor=Set(Cursor,OFF),
        BoxAttr=iif(Query(TextAttr)==9,15,9), BoxStyle=1,
        InnerAttr=11, WordAttr=12

  PopWinOpen(54,5,74,19,2,'',BoxAttr)
  Set(Attr,0)   ClrScr()
  Set(Attr,BoxAttr)
  VGotoXY(1,2) Write(Format('':32:'Í'))
  VGotoXY(1,12) Write(Format('':32:'Í'))

  Set(Attr,WordAttr)
  VGotoXY(6,1) Write('Box Chars')

  Set(Attr,InnerAttr)
  VGotoXY(2,13) Write('Any key  Esc-Quit')

  display:
    Cycle(BoxStyle)
    Case GetKey()
      when <Escape> goto close
      otherwise
         BoxStyle=iif(BoxStyle==4,1,BoxStyle+1)
    endcase
    goto display

  close:
  Set(Cursor,cursor)
  PopWinClose()

end

proc main()   // If burning into TSE, eliminate this part,
  BoxChars()  //  and assign "BoxChars()" to your preferred key.
end
