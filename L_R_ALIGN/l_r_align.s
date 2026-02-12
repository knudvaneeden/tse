// Author: Zhang Zhao
//
// Published: 10 August 2022
//
// Revision: 14964
//
// ===
//
// Documentation:
//
// ===
//
// Use case: left and right align of a block of lines
//
// ===
//
// Example:
//
// 1. -Mark these 4 lines
//
/*
--- cut here: begin --------------------------------------------------
f=0.0f;sscanf(s,"%f",&f);printf("%f\n",f);//1.234568
lf=0.0;sscanf(s,"%lf",&lf);printf("%.15lf\n",lf);//1.234567890123456
lf=0.0f;sscanf(s,"%f",&lf);printf("%.15lf\n",lf);//0.000000000000000
f=0.0;sscanf(s,"%lf",&f);printf("%f\n",f);//70.175720
 | | |        |     |            |    |   ||  |
 = . ;        ,     ,            %    ,   //  .
--- cut here: end ----------------------------------------------------
*/
//
// 2. -Optionally place the column spacing characters above
//
// 3. -Note the column spacing characters above and make a concatenated string of it
//
//      =.;,,)%,//.
//
// 4. -Please specify that each column is
//
//       'l' (=left aligned)
//       'r' (=right aligned)
//
//     by putting or an 'r' or an 'l' in front of each align character
//
//     From =.;,,)%,// this becomes:
//
//      r=l.l;l,l,r)l%l,r/l/r.l
//
//     Note that an 'l' has been added at the end here.
//
// 5. -Input this last string also
//
// 6. -Then execute the TSE macro l_r_align.s
//
// 7  -Note that each column is left or right aligned after it
//
/*
--- cut here: begin --------------------------------------------------
f =0.0f;sscanf(s,"%f" ,&f );printf("%f\n"    ,f); //1 .234568
lf=0.0 ;sscanf(s,"%lf",&lf);printf("%.15lf\n",lf);//1 .234567890123456
lf=0.0f;sscanf(s,"%f" ,&lf);printf("%.15lf\n",lf);//0 .000000000000000
f =0.0 ;sscanf(s,"%lf",&f );printf("%f\n"    ,f); //70.175720
--- cut here: end ----------------------------------------------------
*/
//
// ===
//
// Yes, very useful:
//
// I used it e.g. with this (simplified) example, to quickly align it more in table like format:
//
// Example:
//
// Before:
//
/*
--- cut here: begin --------------------------------------------------
Option 123: Do something1
Option 4578: Do something2
Option 3: Do something3
Option 1234: Do something4d
--- cut here: end ----------------------------------------------------
*/
//
// Then supply first which character to select:
//
// :
//
// Then supply if it is right or left aligned
//
// :l
//
// That gives as output
//
// After:
//
/*
--- cut here: begin --------------------------------------------------
Option 123 : Do something1
Option 4578: Do something2
Option 3   : Do something3
Option 1234: Do something4
--- cut here: end ----------------------------------------------------
*/
//
STRING input[255] = "" // global variable
STRING lr[255] = "" // global variable
STRING lri[255] = "" // global variable
//
INTEGER blocked = 0 // global variable
INTEGER spc = 0 // global variable
//
INTEGER PROC mIsEscKeyPressed()
 INTEGER PressedKey = 0
 IF KeyPressed()
  WHILE KeyPressed()
   PressedKey = GetKey()
  ENDWHILE
  IF PressedKey == <Escape>
   RETURN( TRUE )
  ENDIF
 ENDIF
 RETURN( FALSE )
END mIsEscKeyPressed
//
INTEGER PROC getmaxcol( STRING inp )
 INTEGER i = 0
 INTEGER j = 0
 INTEGER col = 0
 INTEGER maxcol = 0
 INTEGER yb = 0
 INTEGER ye = 0
 INTEGER L = 0
 INTEGER uw = 0
 STRING c[ 1 ] = ""
 maxcol = 0
 yb = Query( BlockBegLine )
 ye = Query( BlockEndLine )
 uw = Length( Str( ye ) )
 L = Length( inp )
 FOR j = yb TO ye
  IF ( ( j - yb + 1 ) MOD 100 ) == 0
   Message( j-yb+1:uw, " / ", ye - yb + 1, "  Press Esc abort" )
   IF mIsEscKeyPressed()
    RETURN( 0 )
   ENDIF
  ENDIF
  GotoLine( j )
  BegLine()
  i = 1
  c = SubStr( inp, Min( i, L ), 1 )
  IF IIF( c=='?', LFind( "[~\x0a0-9'\x22\x40-\x5a\x5f-\x7a\x7f-\xff]",'c+x' ), LFind( c,'c+' ) )
   i = i + 1
   WHILE ( 1 )
    c = SubStr( inp, Min( i,L ), 1 )
    IF NOT IIF( c=='?', LFind( "[~\x0a0-9'\x22\x40-\x5a\x5f-\x7a\x7f-\xff]",'c+x' ), LFind( c,'c+' ) )
     BREAK
    ENDIF
    i = i + 1
   ENDWHILE
   col = i
   IF ( col > maxcol )
    maxcol = col
   ENDIF
  ENDIF
 ENDFOR
 RETURN( maxcol )
END getmaxcol
//
INTEGER PROC getcolpos( STRING inp, INTEGER col )
 INTEGER i = 0
 INTEGER j = 0
 INTEGER colpos = 0
 INTEGER maxcolpos = 0
 INTEGER yb = 0
 INTEGER ye = 0
 INTEGER L = 0
 STRING c[ 1 ] = ""
 maxcolpos = 0
 yb = Query( BlockBegLine )
 ye = Query( BlockEndLine )
 L = Length( inp )
 FOR j = yb TO ye
  GotoLine( j )
  BegLine()
  FOR i = 1 TO col
   c = SubStr( inp, Min( i, L ),1 )
   IF IIF( c=='?', LFind( "[~\x0a0-9'\x22\x40-\x5a\x5f-\x7a\x7f-\xff]",'c+x' ), LFind( c,'c+' ) )
    IF ( i >= col )
     colpos = CurrCol()
     IF ( colpos > maxcolpos )
      maxcolpos = colpos
     ENDIF
     BREAK
    ENDIF
    ELSE
    BREAK
   ENDIF
  ENDFOR
 ENDFOR
 RETURN( maxcolpos )
END getcolpos
//
INTEGER PROC aligncol( INTEGER colpos, INTEGER col, STRING inp, INTEGER maxcol ) // According TO the requirements of InP, insert an appropriate space at the left OR right of the col column TO make the current column END AND display the progress WHEN reaching colpos. Press ESC TO interrupt
 INTEGER i = 0
 INTEGER j = 0
 INTEGER uline = 0
 INTEGER cc = 0
 INTEGER cc1 = 0
 INTEGER uw = 0
 INTEGER nc = 0
 INTEGER L = 0
 INTEGER yb = 0
 INTEGER ye = 0
 INTEGER lrL = 0
 INTEGER n = 0
 STRING c[ 1 ] = ""
 yb = Query( BlockBegLine )
 ye = Query( BlockEndLine )
 L = Length( inp )
 uline = ye - yb + 1
 uw = Length( Str( uline ) )
 nc = Length( Str( maxcol ) )
 lrL = Length( lr )
 IF Lower( SubStr( lr,Min( col,lrL ),1 ) ) == 'r'
  FOR j = yb TO ye
   IF ( j MOD 100 ) == 0
    Message( j:uw,"*",col:nc," / ",uline,"*",maxcol,"  Press Esc abort" )
    IF ( mIsEscKeyPressed() )
     RETURN( 1 )
    ENDIF
   ENDIF
   GotoLine( j )
   BegLine()
   cc = 1
   cc1 = 0
   FOR i = 1 TO col
    c = SubStr( inp, Min( i, L ), 1 )
    IF IIF( c=='?', LFind( "[~\x0a0-9'\x22\x40-\x5a\x5f-\x7a\x7f-\xff]",'c+x' ), LFind( c, 'c+' ) )
     IF ( i >= col )
      cc = CurrCol()
      IF ( cc < colpos )
       GotoColumn( cc1 + 1 )
       n = colpos - cc
       WHILE ( 1 )
        IF ( n <= 255 )
         InsertText( Format( "":n:CHR( 10 ) ), _INSERT_ )
         BREAK
         ELSE
         InsertText( Format( "":255:CHR( 10 ) ), _INSERT_ )
         n = n - 255
        ENDIF
       ENDWHILE
       GotoColumn( cc )
      ENDIF
      BREAK
      ELSE
      cc1 = CurrCol()
     ENDIF
     ELSE
     BREAK
    ENDIF
   ENDFOR
  ENDFOR
  ELSE
  FOR j = yb TO ye
   IF ( j MOD 100 ) == 0
    Message( j:uw,"*",col:nc," / ",uline,"*",maxcol,"  Press Esc abort" )
    IF ( mIsEscKeyPressed() )
     RETURN( 1 )
    ENDIF
   ENDIF
   GotoLine( j )
   BegLine()
   cc = 1
   FOR i = 1 TO col
    c = SubStr( inp, Min( i, L ), 1 )
    IF IIF( c=='?', LFind( "[~\x0a0-9'\x22\x40-\x5a\x5f-\x7a\x7f-\xff]",'c+x' ), LFind( c, 'c+' ) )
     IF ( i >= col )
      cc = CurrCol()
      IF ( cc < colpos )
       n = colpos - cc
       WHILE ( 1 )
        IF ( n <= 255 )
         InsertText( Format( "":n:CHR( 10 ) ),_INSERT_ )
         BREAK
         ELSE
         InsertText( Format( "":255:CHR( 10 ) ),_INSERT_ )
         n = n - 255
        ENDIF
       ENDWHILE
      ENDIF
      BREAK
     ENDIF
     ELSE
     BREAK
    ENDIF
   ENDFOR
  ENDFOR
 ENDIF
 RETURN( 0 )
END
//
PROC main()
 INTEGER j = 0
 INTEGER yb = 0
 INTEGER ye = 0
 INTEGER colpos = 0
 INTEGER i = 0
 INTEGER maxcol = 0
 INTEGER save_marking = 0
 STRING inp[255] = ""
 STRING c[ 1 ] = ""
 PushPosition()
 blocked = 0
 IF ( isBlockInCurrFile() > 0 )
  save_marking = Set( Marking, OFF )
  blocked = 1
  PushBlock()
  ELSE
  UnMarkBlock()
  MarkLine( 1, NumLines() )
 ENDIF
 Set( X1, 10 )
 Set( Y1, 10 )
 IF ( NOT ( Ask( "Please enter a column spacing character OR STRING", input, 11 ) ) )
  GOTO ExitP
 ENDIF
 IF input == ""
  GOTO ExitP
 ENDIF
 IF ( ( Length( input ) >= 2 ) AND ( Pos( ' ', input ) == 0 ) AND ( Pos( 'l', input ) == 0 ) AND ( Pos( 'r', input ) == 0 ) )
  lri = "l"
  FOR j = 1 TO Length( input )
   lri = lri + input[ j ] + "l"
  ENDFOR
 ENDIF
 Set( Insert, OFF )
 Set( X1, 10 )
 Set( Y1, 10 )
 IF ( NOT ( Ask( "Please specify that each column is l ( left aligned ) AND r ( right aligned )", lri, 12 ) ) )
  Set( Insert, ON )
  GOTO ExitP
 ENDIF
 Set( Insert, ON )
 //
 IF ( ( Length( input ) >= 2 ) AND ( Pos( ' ', input ) == 0 ) AND ( Pos( 'l', input ) == 0 ) AND ( Pos( 'r', input ) == 0 ) )
  lr = ""
  FOR j = 1 TO Length( lri )
   IF ( ( lri[ j ] == 'l' ) OR ( lri[ j ] == 'r' ) )
    lr = lr + lri[ j ]
   ENDIF
  ENDFOR
  ELSE
  lr = lri
 ENDIF
 //
 IF ( Pos( '\x09',input ) == 0 )
  yb = Query( BlockBegLine )
  ye = Query( BlockEndLine )
  FOR j = yb TO ye
   GotoLine( j )
   ExpandTabsToSpaces()
  ENDFOR
 ENDIF
 spc = 0
 GotoBlockBegin()
 IF ( CurrCol() == 1 )
  LFind( "[~ ]", 'cx' )
  spc = CurrCol() - 1
 ENDIF
 GotoBlockBegin()
 CASE input
  WHEN " "
  WHILE ( 1 )
   IF ( NOT ( LReplace( "  ", " ", 'lgn' ) ) ) BREAK ENDIF
  ENDWHILE
  LReplace( "^ ","",'lgnx' )
  LReplace( ",","\x0d",'lgnx' )
  LReplace( " ",",",'lgn' )
  LReplace( "$",",",'lgnx' )
  LReplace( ",,$",",",'lgnx' )
  inp = ","
  WHEN "  "
  TWOSPACE:
  WHILE ( 1 )
   IF ( NOT ( LReplace( "   ","  ",'lgn' ) ) ) BREAK ENDIF
  ENDWHILE
  LReplace( "^ ","",'lgnx' )
  LReplace( "^ ","",'lgnx' )
  LReplace( ",","\x0d",'lgnx' )
  LReplace( "  ",",",'lgn' )
  LReplace( "$",",",'lgnx' )
  LReplace( ",,$",",",'lgnx' )
  inp = ","
  WHEN "?"
  WHILE ( 1 )
   IF ( NOT ( LReplace( "  "," ",'lgn' ) ) ) BREAK ENDIF
  ENDWHILE
  LReplace( "^ ","",'lgnx' )
  LReplace( "$","?",'lgnx' )
  LReplace( "\?\?$","?",'lgnx' )
  inp = input
  OTHERWISE
  input = RTrim( input )
  IF ( input == "" )
   input = "  "
   GOTO TWOSPACE
  ENDIF
  spc = 0
  c = RightStr( input, 1 )
  LReplace( "$", c, 'lgnx' )
  IF Pos( c, ".^$|?[*+@#{\" )
   LReplace( "\"+c+"\"+c+"$", c, 'lgnx' )
   ELSE
   LReplace( c + c + "$", c, 'lgnx' )
  ENDIF
  IF Pos( " ", input )
   WHILE ( 1 )
    IF NOT LReplace( "  ", " ", 'lgn' ) BREAK ENDIF
   ENDWHILE
   LReplace( "^ ", "", 'lgnx' )
  ENDIF
  inp = input
 ENDCASE
 maxcol = getmaxcol( inp )
 IF ( maxcol > 0 )
  i = 1
  WHILE ( 1 )
   IF ( i > maxcol ) BREAK ENDIF
   colpos = getcolpos( inp, i )
   IF ( colpos > 0 )
    IF aligncol( colpos, i, inp, maxcol )
     BREAK
    ENDIF
   ENDIF
   i = i + 1
  ENDWHILE
 ENDIF
 GotoBlockBegin()
 LReplace( '\x0a',' ','lgnx' )
 CASE input
  WHEN " "
  LReplace( ',',' ','lgn' )
  LReplace( "\x0d",",",'lgnx' )
  WHEN "  "
  LReplace( ',','  ','lgn' )
  LReplace( "\x0d",",",'lgnx' )
  WHEN "?"
  LReplace( "\?$","",'lgnx' )
  OTHERWISE
  IF Pos( c,".^$|?[*+@#{\" )
   LReplace( "\"+c+"$","",'lgnx' )
   ELSE
   LReplace( c+"$","",'lgnx' )
  ENDIF
 ENDCASE
 IF ( spc > 0 )
  IF ( spc > 255 ) spc = 255 ENDIF
  yb = Query( BlockBegLine )
  ye = Query( BlockEndLine )
  FOR j = yb TO ye
   GotoLine( j )
   GotoColumn( 1 )
   InsertText( Format( "":spc:' ' ),_INSERT_ )
  ENDFOR
 ENDIF
 ExitP:
 IF ( blocked == 1 )
  PopBlock()
  Set( Marking, save_marking )
  ELSE
  UnMarkBlock()
 ENDIF
 PopPosition()
 UpdateDisplay( _STATUSLINE_REFRESH_ )
 PurgeMacro( CurrMacroFilename() )
END
