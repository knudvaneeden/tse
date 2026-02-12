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
/* TSE Macro  : NumberConversion                                           */
/* Programmer : David Daniel Anderson                                      */
/*                                                                         */
/* Purpose    : NumberConversion() provides a pop-up window of numbers in  */
/*              three bases:  Decimal, Hexadecimal and Binary.  Range for  */
/*              numbers is 0-65535 (decimal).                              */
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

string proc fbin(string bin)  // Format binary numbers to 16 digits
string tbin[16]=''
  tbin=format(bin:16:'0')
  return(substr(tbin,1,4)+chr(32)+
         substr(tbin,5,4)+chr(32)+
         substr(tbin,9,4)+chr(32)+
         substr(tbin,13,4))
end

proc NumDisplay(integer Value)  // Display numbers in three Dec/Hex/Bin
string dec[5]=Str(Value),
        hex[4]=Str(Value,16),
        bin[16]=Str(Value,2)
/*
  if (length(hex) mod 2)==1    // To display hex numbers with preceding
     hex='0'+hex               // zeros, remove comment delimiters from
  endif                        // above and below these three lines
*/
  VGotoXY(18,3) Write(format(dec:14))
  VGotoXY(18,5) Write(format(hex:14))
  VGotoXY(13,7) Write(fbin(bin))
end

proc NumberConversion()  // Convert numbers between Decimal/Hex/Binary
integer BoxAttr=iif(Query(TextAttr)==9,15,9), Value=0,
        InnerAttr=11, NumAttr=15, WordAttr=12

  PopWinOpen(41,5,74,15,2,'',BoxAttr)
  Set(Attr,0)   ClrScr()
  Set(Attr,BoxAttr)
  VGotoXY(1,2) Write(Format('':32:'Í'))
  VGotoXY(1,4) Write(Format('':32:'Í'))
  VGotoXY(1,6) Write(Format('':32:'Í'))
  VGotoXY(1,8) Write(Format('':32:'Í'))

  Set(Attr,WordAttr)
  VGotoXY(7,1) Write(' Number Conversions ')

  Set(Attr,InnerAttr)
  VGotoXY(2,3) Write('Decimal:')
  VGotoXY(2,5) Write('Hexadecimal:')
  VGotoXY(2,7) Write('Binary:')
  VGotoXY(2,9) Write('  PgUp PgDn ^PgUp ^PgDn Esc')

  Set(Attr,NumAttr)
  display:
    NumDisplay(Value)
    Case GetKey()
      when <CursorUp>,    <greyCursorUp>   Value=Value+1
      when <CursorDown>,  <greyCursorDown> Value=Value-1
      when <PgUp>,        <greyPgUp>       Value=Value+10
      when <PgDn>,        <greyPgDn>       Value=Value-10
      when <Ctrl PgUp>,   <Ctrl greyPgUp>  Value=Value+100
      when <Ctrl PgDn>,   <Ctrl greyPgDn>  Value=Value-100
      when <Escape> goto close
    endcase
    Value=iif((Value>65535),0,(iif((Value<0),65535,Value)))
    goto display

  close:
  PopWinClose()
end

proc main()           // If burning into TSE, eliminate this part, and
  NumberConversion()  //  assign "NumberConversion()" to your preferred key.
end
