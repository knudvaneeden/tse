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
/* TSE Macro  : DosColor (TSE DOS Color chart)                             */
/* Programmer : David Daniel Anderson                                      */
/*                                                                         */
/* Purpose    : Displays a pop-up chart of the 256 DOS colors, with each   */
/*              color highlighting its corresponding decimal or hex value. */
/*                                                                         */
/* Revision   : 1995/01/26 - first public version (v1.0)                   */
/*              1995/02/01 - minor aesthetic alterations (v1.001)          */
/*              1995/02/18 - expanded columns (v1.01)                      */
/*              1995/03/01 - inclusion in SwissArmyTool()                  */
/*                                                                         */
/* Notice     : Public Domain.  Comments to author welcome on ILink,       */
/*              RIME, or Internet (david.daniel.anderson@panasia.com).     */
/*                                                                         */
/* Usage      : Can be bound to a key and burned into TSE, or run as an    */
/*              external macro.                                            */
/*              Additional usage help is shown on-screen when active.      */
/***************************************************************************/

proc DisplayColors(integer hex_on, integer blink_on) // Supports DosColor()
integer ColourNumber=iif(blink_on,128,0)
  repeat
    VGotoXY(3+(4*((ColourNumber) mod 16)), 2+((ColourNumber mod 128)/16))
    Set(Attr,ColourNumber)
    if hex_on
      Write(Chr(32)+Chr(32)+Format(ColourNumber:2:'0':16))
    else
      Write(Format(ColourNumber:4))
    endif
    ColourNumber=ColourNumber+1
  until ColourNumber mod 128==0
end DisplayColors

proc DosColor()  // This proc may be bound to a key, or called from
                 //  a "main" proc if used as an external macro.
integer blink=FALSE, hex=FALSE,  // make hex=TRUE for hex default
        BoxAttr=iif(Query(TextAttr)==9,15,9), WordAttr=15
  PopWinOpen(8,4,77,15,2,'',BoxAttr)
  Set(Attr,0)   ClrScr()
  Set(Attr,WordAttr)
  VGotoXY(11,0) Write(' Left=Dec ') VGotoXY(23,0) Write(' Right=Hex ')
  VGotoXY(36,0) Write(' Up=Norm ')  VGotoXY(47,0) Write(' Down=Blink ')
  VGotoXY(8,11) Write(' ...any other key exits ')
  VGotoXY(34,11) Write(' [TSE DOS Color chart v1.0] ')

  display:
    DisplayColors(hex, blink)
    Case GetKey()
      when <CursorLeft>,  <greyCursorLeft>   hex=FALSE   goto display
      when <CursorRight>, <greyCursorRight>  hex=TRUE    goto display
      when <CursorUp>,    <greyCursorUp>     blink=FALSE goto display
      when <CursorDown>,  <greyCursorDown>   blink=TRUE  goto display
    endcase

  PopWinClose()
end DosColor

proc main()   // If burning into TSE, eliminate this part,
  DosColor()  //  and assign "DosColor()" to your preferred key.
end
