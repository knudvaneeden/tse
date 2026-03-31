// eulerproject0237ChatGPT.s
//
// Applied TSE SAL rules in this source:
// - pure TSE SAL only
// - one final Warn() only
// - two CopyToWinClip() calls around final Warn()
// - Return() always uses parentheses
// - no variable named val or pos
// - fixed-size strings only
// - numeric #define constants only
// - PROC Main() is last
// - linear version number at one place only
//
// <version>2</version>
//
// History:
// 1 - 2026-03-31 - ChatGPT - Initial pure TSE SAL solution for Euler Project problem 237.
// 2 - 2026-03-31 - ChatGPT - Renamed reserved keyword VERSION to APP_VERSION and rebuilt full source.
//
// Project Euler 237
//
// Recurrence used:
// T(n) = 2*T(n-1) + 2*T(n-2) - 2*T(n-3) + T(n-4)
//
// Initial values:
// T(1) = 1
// T(2) = 1
// T(3) = 4
// T(4) = 8
//
// Goal:
// T(10^12) mod 10^8
//
// Method:
// 4x4 matrix exponentiation modulo 100000000
// overflow-safe modular multiplication by repeated doubling
// exponent 999999999996 split into:
//   high = 931
//   low  = 346361852
// where exponent = high * 2^30 + low

#define APP_VERSION 2
#define MODULO 100000000
#define EXPBASE 1073741824

INTEGER gResult11I = 0
INTEGER gResult12I = 0
INTEGER gResult13I = 0
INTEGER gResult14I = 0
INTEGER gResult21I = 0
INTEGER gResult22I = 0
INTEGER gResult23I = 0
INTEGER gResult24I = 0
INTEGER gResult31I = 0
INTEGER gResult32I = 0
INTEGER gResult33I = 0
INTEGER gResult34I = 0
INTEGER gResult41I = 0
INTEGER gResult42I = 0
INTEGER gResult43I = 0
INTEGER gResult44I = 0

INTEGER gBase11I = 0
INTEGER gBase12I = 0
INTEGER gBase13I = 0
INTEGER gBase14I = 0
INTEGER gBase21I = 0
INTEGER gBase22I = 0
INTEGER gBase23I = 0
INTEGER gBase24I = 0
INTEGER gBase31I = 0
INTEGER gBase32I = 0
INTEGER gBase33I = 0
INTEGER gBase34I = 0
INTEGER gBase41I = 0
INTEGER gBase42I = 0
INTEGER gBase43I = 0
INTEGER gBase44I = 0

INTEGER gExponentHighI = 0
INTEGER gExponentLowI  = 0

INTEGER PROC FuncModAdd( INTEGER leftI, INTEGER rightI )
 INTEGER sumI = 0
 sumI = leftI + rightI
 IF sumI >= MODULO
  sumI = sumI - MODULO
 ENDIF
 RETURN( sumI )
END

INTEGER PROC FuncModMul( INTEGER leftI, INTEGER rightI )
 INTEGER aI = 0
 INTEGER bI = 0
 INTEGER resultI = 0
 aI = leftI
 bI = rightI
 resultI = 0
 WHILE bI > 0
  IF ( bI & 1 ) == 1
   resultI = FuncModAdd( resultI, aI )
  ENDIF
  bI = bI shr 1
  aI = FuncModAdd( aI, aI )
 ENDWHILE
 RETURN( resultI )
END

INTEGER PROC FuncDot4(
 INTEGER left1I, INTEGER right1I,
 INTEGER left2I, INTEGER right2I,
 INTEGER left3I, INTEGER right3I,
 INTEGER left4I, INTEGER right4I
)
 INTEGER totalI = 0
 totalI = 0
 totalI = FuncModAdd( totalI, FuncModMul( left1I, right1I ) )
 totalI = FuncModAdd( totalI, FuncModMul( left2I, right2I ) )
 totalI = FuncModAdd( totalI, FuncModMul( left3I, right3I ) )
 totalI = FuncModAdd( totalI, FuncModMul( left4I, right4I ) )
 RETURN( totalI )
END

PROC ProcSetResultIdentity()
 gResult11I = 1
 gResult12I = 0
 gResult13I = 0
 gResult14I = 0
 gResult21I = 0
 gResult22I = 1
 gResult23I = 0
 gResult24I = 0
 gResult31I = 0
 gResult32I = 0
 gResult33I = 1
 gResult34I = 0
 gResult41I = 0
 gResult42I = 0
 gResult43I = 0
 gResult44I = 1
END

PROC ProcSetBaseMatrix()
 gBase11I = 2
 gBase12I = 2
 gBase13I = 99999998
 gBase14I = 1
 gBase21I = 1
 gBase22I = 0
 gBase23I = 0
 gBase24I = 0
 gBase31I = 0
 gBase32I = 1
 gBase33I = 0
 gBase34I = 0
 gBase41I = 0
 gBase42I = 0
 gBase43I = 1
 gBase44I = 0
END

PROC ProcMultiplyResultByBase()
 INTEGER temp11I = 0
 INTEGER temp12I = 0
 INTEGER temp13I = 0
 INTEGER temp14I = 0
 INTEGER temp21I = 0
 INTEGER temp22I = 0
 INTEGER temp23I = 0
 INTEGER temp24I = 0
 INTEGER temp31I = 0
 INTEGER temp32I = 0
 INTEGER temp33I = 0
 INTEGER temp34I = 0
 INTEGER temp41I = 0
 INTEGER temp42I = 0
 INTEGER temp43I = 0
 INTEGER temp44I = 0

 temp11I = FuncDot4( gResult11I, gBase11I, gResult12I, gBase21I, gResult13I, gBase31I, gResult14I, gBase41I )
 temp12I = FuncDot4( gResult11I, gBase12I, gResult12I, gBase22I, gResult13I, gBase32I, gResult14I, gBase42I )
 temp13I = FuncDot4( gResult11I, gBase13I, gResult12I, gBase23I, gResult13I, gBase33I, gResult14I, gBase43I )
 temp14I = FuncDot4( gResult11I, gBase14I, gResult12I, gBase24I, gResult13I, gBase34I, gResult14I, gBase44I )

 temp21I = FuncDot4( gResult21I, gBase11I, gResult22I, gBase21I, gResult23I, gBase31I, gResult24I, gBase41I )
 temp22I = FuncDot4( gResult21I, gBase12I, gResult22I, gBase22I, gResult23I, gBase32I, gResult24I, gBase42I )
 temp23I = FuncDot4( gResult21I, gBase13I, gResult22I, gBase23I, gResult23I, gBase33I, gResult24I, gBase43I )
 temp24I = FuncDot4( gResult21I, gBase14I, gResult22I, gBase24I, gResult23I, gBase34I, gResult24I, gBase44I )

 temp31I = FuncDot4( gResult31I, gBase11I, gResult32I, gBase21I, gResult33I, gBase31I, gResult34I, gBase41I )
 temp32I = FuncDot4( gResult31I, gBase12I, gResult32I, gBase22I, gResult33I, gBase32I, gResult34I, gBase42I )
 temp33I = FuncDot4( gResult31I, gBase13I, gResult32I, gBase23I, gResult33I, gBase33I, gResult34I, gBase43I )
 temp34I = FuncDot4( gResult31I, gBase14I, gResult32I, gBase24I, gResult33I, gBase34I, gResult34I, gBase44I )

 temp41I = FuncDot4( gResult41I, gBase11I, gResult42I, gBase21I, gResult43I, gBase31I, gResult44I, gBase41I )
 temp42I = FuncDot4( gResult41I, gBase12I, gResult42I, gBase22I, gResult43I, gBase32I, gResult44I, gBase42I )
 temp43I = FuncDot4( gResult41I, gBase13I, gResult42I, gBase23I, gResult43I, gBase33I, gResult44I, gBase43I )
 temp44I = FuncDot4( gResult41I, gBase14I, gResult42I, gBase24I, gResult43I, gBase34I, gResult44I, gBase44I )

 gResult11I = temp11I
 gResult12I = temp12I
 gResult13I = temp13I
 gResult14I = temp14I
 gResult21I = temp21I
 gResult22I = temp22I
 gResult23I = temp23I
 gResult24I = temp24I
 gResult31I = temp31I
 gResult32I = temp32I
 gResult33I = temp33I
 gResult34I = temp34I
 gResult41I = temp41I
 gResult42I = temp42I
 gResult43I = temp43I
 gResult44I = temp44I
END

PROC ProcSquareBase()
 INTEGER temp11I = 0
 INTEGER temp12I = 0
 INTEGER temp13I = 0
 INTEGER temp14I = 0
 INTEGER temp21I = 0
 INTEGER temp22I = 0
 INTEGER temp23I = 0
 INTEGER temp24I = 0
 INTEGER temp31I = 0
 INTEGER temp32I = 0
 INTEGER temp33I = 0
 INTEGER temp34I = 0
 INTEGER temp41I = 0
 INTEGER temp42I = 0
 INTEGER temp43I = 0
 INTEGER temp44I = 0

 temp11I = FuncDot4( gBase11I, gBase11I, gBase12I, gBase21I, gBase13I, gBase31I, gBase14I, gBase41I )
 temp12I = FuncDot4( gBase11I, gBase12I, gBase12I, gBase22I, gBase13I, gBase32I, gBase14I, gBase42I )
 temp13I = FuncDot4( gBase11I, gBase13I, gBase12I, gBase23I, gBase13I, gBase33I, gBase14I, gBase43I )
 temp14I = FuncDot4( gBase11I, gBase14I, gBase12I, gBase24I, gBase13I, gBase34I, gBase14I, gBase44I )

 temp21I = FuncDot4( gBase21I, gBase11I, gBase22I, gBase21I, gBase23I, gBase31I, gBase24I, gBase41I )
 temp22I = FuncDot4( gBase21I, gBase12I, gBase22I, gBase22I, gBase23I, gBase32I, gBase24I, gBase42I )
 temp23I = FuncDot4( gBase21I, gBase13I, gBase22I, gBase23I, gBase23I, gBase33I, gBase24I, gBase43I )
 temp24I = FuncDot4( gBase21I, gBase14I, gBase22I, gBase24I, gBase23I, gBase34I, gBase24I, gBase44I )

 temp31I = FuncDot4( gBase31I, gBase11I, gBase32I, gBase21I, gBase33I, gBase31I, gBase34I, gBase41I )
 temp32I = FuncDot4( gBase31I, gBase12I, gBase32I, gBase22I, gBase33I, gBase32I, gBase34I, gBase42I )
 temp33I = FuncDot4( gBase31I, gBase13I, gBase32I, gBase23I, gBase33I, gBase33I, gBase34I, gBase43I )
 temp34I = FuncDot4( gBase31I, gBase14I, gBase32I, gBase24I, gBase33I, gBase34I, gBase34I, gBase44I )

 temp41I = FuncDot4( gBase41I, gBase11I, gBase42I, gBase21I, gBase43I, gBase31I, gBase44I, gBase41I )
 temp42I = FuncDot4( gBase41I, gBase12I, gBase42I, gBase22I, gBase43I, gBase32I, gBase44I, gBase42I )
 temp43I = FuncDot4( gBase41I, gBase13I, gBase42I, gBase23I, gBase43I, gBase33I, gBase44I, gBase43I )
 temp44I = FuncDot4( gBase41I, gBase14I, gBase42I, gBase24I, gBase43I, gBase34I, gBase44I, gBase44I )

 gBase11I = temp11I
 gBase12I = temp12I
 gBase13I = temp13I
 gBase14I = temp14I
 gBase21I = temp21I
 gBase22I = temp22I
 gBase23I = temp23I
 gBase24I = temp24I
 gBase31I = temp31I
 gBase32I = temp32I
 gBase33I = temp33I
 gBase34I = temp34I
 gBase41I = temp41I
 gBase42I = temp42I
 gBase43I = temp43I
 gBase44I = temp44I
END

PROC ProcShiftExponentRightOne()
 IF ( gExponentHighI & 1 ) == 1
  gExponentLowI = gExponentLowI + EXPBASE
 ENDIF
 gExponentLowI = gExponentLowI shr 1
 gExponentHighI = gExponentHighI shr 1
END

INTEGER PROC FuncApplyResultToInitialVector()
 INTEGER answerI = 0
 answerI = 0
 answerI = FuncModAdd( answerI, FuncModMul( gResult11I, 8 ) )
 answerI = FuncModAdd( answerI, FuncModMul( gResult12I, 4 ) )
 answerI = FuncModAdd( answerI, FuncModMul( gResult13I, 1 ) )
 answerI = FuncModAdd( answerI, FuncModMul( gResult14I, 1 ) )
 RETURN( answerI )
END

PROC Main()
 INTEGER answerI = 0
 STRING answerS[255] = ""

 ProcSetResultIdentity()
 ProcSetBaseMatrix()

 gExponentHighI = 931
 gExponentLowI  = 346361852

 WHILE NOT ( gExponentHighI == 0 AND gExponentLowI == 0 )
  IF ( gExponentLowI & 1 ) == 1
   ProcMultiplyResultByBase()
  ENDIF
  ProcSquareBase()
  ProcShiftExponentRightOne()
 ENDWHILE

 answerI = FuncApplyResultToInitialVector()
 answerS = Format( answerI )

 CopyToWinClip( answerS )
 Warn( answerS )
 CopyToWinClip( answerS )
END
