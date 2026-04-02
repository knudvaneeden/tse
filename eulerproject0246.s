// Project Euler 246
// Tangents to an Ellipse
// Pure TSE SAL
// <version>2</version>
// History:
// 2026-04-02  Created by GPT-5.4 Thinking (ChatGPT)
// 2026-04-02  Version 2: removed invalid TRUE/FALSE #define lines

#define A2_I              56250000
#define B2_I              31250000
#define SUMAB2_I          87500000
#define ELLIPSE_RHS_I    281250000
#define MAX_Y_I              18949
#define MAX_X_I              20000
#define BASE_I                1000

integer gChunk0I = 0
integer gChunk1I = 0
integer gChunk2I = 0
integer gChunk3I = 0
integer gChunk4I = 0
integer gChunk5I = 0

FORWARD integer PROC ProcIntSqrt( integer numberI )
FORWARD integer PROC ProcCountXInterval( integer firstXI, integer lastXI )
FORWARD integer PROC ProcEllipseOutside( integer xI, integer ySquareI )
FORWARD PROC ProcBigMulIntInt( integer leftI, integer rightI )
FORWARD integer PROC ProcBigCompare6(
  integer left5I, integer left4I, integer left3I, integer left2I, integer left1I, integer left0I,
  integer right5I, integer right4I, integer right3I, integer right2I, integer right1I, integer right0I
)
FORWARD integer PROC ProcKNegative( integer uI, integer vI )
FORWARD integer PROC ProcOuterRowCount( integer ySquareI )
FORWARD integer PROC ProcAnnulusRowCount( integer ySquareI )
FORWARD string PROC ProcIntToString( integer numberI )

integer PROC ProcIntSqrt( integer numberI )
  integer lowI  = 0
  integer highI = 0
  integer midI  = 0
  integer testI = 0
  if ( numberI <= 0 )
    Return( 0 )
  endif
  highI = numberI
  if ( highI > MAX_X_I )
    highI = MAX_X_I
  endif
  while ( lowI < highI )
    midI = ( lowI + highI + 1 ) / 2
    testI = midI * midI
    if ( testI <= numberI )
      lowI = midI
    else
      highI = midI - 1
    endif
  endwhile
  Return( lowI )
END

integer PROC ProcCountXInterval( integer firstXI, integer lastXI )
  if ( lastXI < firstXI )
    Return( 0 )
  endif
  if ( firstXI == 0 )
    Return( 1 + ( 2 * lastXI ) )
  endif
  Return( 2 * ( lastXI - firstXI + 1 ) )
END

integer PROC ProcEllipseOutside( integer xI, integer ySquareI )
  integer leftI = 0
  if ( ySquareI > B2_I )
    Return( TRUE )
  endif
  leftI = ( 5 * xI * xI ) + ( 9 * ySquareI )
  if ( leftI > ELLIPSE_RHS_I )
    Return( TRUE )
  endif
  Return( FALSE )
END

PROC ProcBigMulIntInt( integer leftI, integer rightI )
  integer a0I = 0
  integer a1I = 0
  integer a2I = 0
  integer b0I = 0
  integer b1I = 0
  integer b2I = 0
  integer r0I = 0
  integer r1I = 0
  integer r2I = 0
  integer r3I = 0
  integer r4I = 0
  integer carryI = 0

  a0I = leftI mod BASE_I
  a1I = ( leftI / BASE_I ) mod BASE_I
  a2I = leftI / 1000000

  b0I = rightI mod BASE_I
  b1I = ( rightI / BASE_I ) mod BASE_I
  b2I = rightI / 1000000

  r0I = ( a0I * b0I )
  r1I = ( a0I * b1I ) + ( a1I * b0I )
  r2I = ( a0I * b2I ) + ( a1I * b1I ) + ( a2I * b0I )
  r3I = ( a1I * b2I ) + ( a2I * b1I )
  r4I = ( a2I * b2I )

  carryI = r0I / BASE_I
  r0I = r0I mod BASE_I
  r1I = r1I + carryI

  carryI = r1I / BASE_I
  r1I = r1I mod BASE_I
  r2I = r2I + carryI

  carryI = r2I / BASE_I
  r2I = r2I mod BASE_I
  r3I = r3I + carryI

  carryI = r3I / BASE_I
  r3I = r3I mod BASE_I
  r4I = r4I + carryI

  carryI = r4I / BASE_I
  r4I = r4I mod BASE_I

  gChunk0I = r0I
  gChunk1I = r1I
  gChunk2I = r2I
  gChunk3I = r3I
  gChunk4I = r4I
  gChunk5I = carryI
END

integer PROC ProcBigCompare6(
  integer left5I, integer left4I, integer left3I, integer left2I, integer left1I, integer left0I,
  integer right5I, integer right4I, integer right3I, integer right2I, integer right1I, integer right0I
)
  if ( left5I < right5I )
    Return( -1 )
  endif
  if ( left5I > right5I )
    Return( 1 )
  endif
  if ( left4I < right4I )
    Return( -1 )
  endif
  if ( left4I > right4I )
    Return( 1 )
  endif
  if ( left3I < right3I )
    Return( -1 )
  endif
  if ( left3I > right3I )
    Return( 1 )
  endif
  if ( left2I < right2I )
    Return( -1 )
  endif
  if ( left2I > right2I )
    Return( 1 )
  endif
  if ( left1I < right1I )
    Return( -1 )
  endif
  if ( left1I > right1I )
    Return( 1 )
  endif
  if ( left0I < right0I )
    Return( -1 )
  endif
  if ( left0I > right0I )
    Return( 1 )
  endif
  Return( 0 )
END

integer PROC ProcKNegative( integer uI, integer vI )
  integer wI = 0

  integer left0I = 0
  integer left1I = 0
  integer left2I = 0
  integer left3I = 0
  integer left4I = 0
  integer left5I = 0

  integer right0I = 0
  integer right1I = 0
  integer right2I = 0
  integer right3I = 0
  integer right4I = 0
  integer right5I = 0

  integer carryI = 0
  integer compareI = 0

  wI = uI + vI

  ProcBigMulIntInt( wI, wI )
  left0I = gChunk0I
  left1I = gChunk1I
  left2I = gChunk2I
  left3I = gChunk3I
  left4I = gChunk4I
  left5I = gChunk5I

  carryI = 0
  left0I = left0I + 0
  carryI = left0I / BASE_I
  left0I = left0I mod BASE_I

  left1I = left1I + 0 + carryI
  carryI = left1I / BASE_I
  left1I = left1I mod BASE_I

  left2I = left2I + 0 + carryI
  carryI = left2I / BASE_I
  left2I = left2I mod BASE_I

  left3I = left3I + 500 + carryI
  carryI = left3I / BASE_I
  left3I = left3I mod BASE_I

  left4I = left4I + 687 + carryI
  carryI = left4I / BASE_I
  left4I = left4I mod BASE_I

  left5I = left5I + 14 + carryI

  ProcBigMulIntInt( 300000000, uI )
  right0I = gChunk0I
  right1I = gChunk1I
  right2I = gChunk2I
  right3I = gChunk3I
  right4I = gChunk4I
  right5I = gChunk5I

  ProcBigMulIntInt( 400000000, vI )

  carryI = 0
  right0I = right0I + gChunk0I
  carryI = right0I / BASE_I
  right0I = right0I mod BASE_I

  right1I = right1I + gChunk1I + carryI
  carryI = right1I / BASE_I
  right1I = right1I mod BASE_I

  right2I = right2I + gChunk2I + carryI
  carryI = right2I / BASE_I
  right2I = right2I mod BASE_I

  right3I = right3I + gChunk3I + carryI
  carryI = right3I / BASE_I
  right3I = right3I mod BASE_I

  right4I = right4I + gChunk4I + carryI
  carryI = right4I / BASE_I
  right4I = right4I mod BASE_I

  right5I = right5I + gChunk5I + carryI

  compareI = ProcBigCompare6(
    left5I, left4I, left3I, left2I, left1I, left0I,
    right5I, right4I, right3I, right2I, right1I, right0I
  )
  if ( compareI < 0 )
    Return( TRUE )
  endif
  Return( FALSE )
END

integer PROC ProcAnnulusRowCount( integer ySquareI )
  integer xMaxI = 0
  integer lowI  = 0
  integer highI = 0
  integer midI  = 0
  integer xMinI = 0

  if ( ySquareI > SUMAB2_I )
    Return( 0 )
  endif

  xMaxI = ProcIntSqrt( SUMAB2_I - ySquareI )

  if ( ProcEllipseOutside( 0, ySquareI ) )
    Return( ProcCountXInterval( 0, xMaxI ) )
  endif

  lowI  = 0
  highI = xMaxI
  while ( lowI < highI )
    midI = ( lowI + highI ) / 2
    if ( ProcEllipseOutside( midI, ySquareI ) )
      highI = midI
    else
      lowI = midI + 1
    endif
  endwhile
  xMinI = lowI

  Return( ProcCountXInterval( xMinI, xMaxI ) )
END

integer PROC ProcOuterRowCount( integer ySquareI )
  integer startXI = 0
  integer lowI    = 0
  integer highI   = 0
  integer midI    = 0
  integer endXI   = 0
  integer uI      = 0

  if ( ySquareI < SUMAB2_I )
    startXI = ProcIntSqrt( SUMAB2_I - ySquareI ) + 1
  else
    startXI = 0
  endif

  if ( startXI > MAX_X_I )
    Return( 0 )
  endif

  uI = startXI * startXI
  if ( NOT ( ProcKNegative( uI, ySquareI ) ) )
    Return( 0 )
  endif

  lowI  = startXI
  highI = MAX_X_I
  while ( lowI < highI )
    midI = ( lowI + highI + 1 ) / 2
    uI = midI * midI
    if ( ProcKNegative( uI, ySquareI ) )
      lowI = midI
    else
      highI = midI - 1
    endif
  endwhile
  endXI = lowI

  Return( ProcCountXInterval( startXI, endXI ) )
END

string PROC ProcIntToString( integer numberI )
  string numberS[ 255 ] = ""
  numberS = Format( numberI:0 )
  Return( numberS )
END

PROC Main()
  integer yI             = 0
  integer ySquareI       = 0
  integer rowCountI      = 0
  integer totalCountI    = 0
  string answerS[ 255 ]  = ""
  string llmNameS[ 255 ] = "GPT-5.4 Thinking (ChatGPT)"
  string versionS[ 255 ] = "2"

  for yI = 0 to MAX_Y_I
    ySquareI = yI * yI
    rowCountI = ProcAnnulusRowCount( ySquareI ) + ProcOuterRowCount( ySquareI )
    if ( yI == 0 )
      totalCountI = totalCountI + rowCountI
    else
      totalCountI = totalCountI + rowCountI + rowCountI
    endif
  endfor

  answerS = ProcIntToString( totalCountI )

  CopyToWinClip( answerS )
  Warn( answerS )
  CopyToWinClip( answerS )
END
