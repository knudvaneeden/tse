// euler188.s
// <version>1.0.0.0.0</version>
// Project Euler 188
// GPT-5.4 Thinking
//
// History:
// 1.0.0.0.0  2026-03-24  GPT-5.4 Thinking
//  Initial pure TSE SAL solution for Project Euler problem 188.
//
// The program calculates the last 8 digits of 1777^^1855.
// It uses recursive Euler-phi reduction and overflow-safe modular multiplication.

#define BASE_VALUE     1777
#define HEIGHT_VALUE   1855
#define MODULO_VALUE   100000000

FORWARD INTEGER PROC ProcPhi( INTEGER numberI )
FORWARD INTEGER PROC ProcModMultiply( INTEGER leftI, INTEGER rightI, INTEGER modulusI )
FORWARD INTEGER PROC ProcPowMod( INTEGER baseI, INTEGER exponentI, INTEGER modulusI )
FORWARD INTEGER PROC ProcTetrationMod( INTEGER baseI, INTEGER heightI, INTEGER modulusI )

INTEGER PROC ProcPhi( INTEGER numberI )
 INTEGER resultI = numberI
 INTEGER workI   = numberI
 INTEGER factorI = 2
 //
 IF numberI <= 1
  RETURN( numberI )
 ENDIF
 //
 WHILE factorI * factorI <= workI
  IF workI mod factorI == 0
   resultI = resultI - ( resultI / factorI )
   WHILE workI mod factorI == 0
    workI = workI / factorI
   ENDWHILE
  ENDIF
  IF factorI == 2
   factorI = 3
  ELSE
   factorI = factorI + 2
  ENDIF
 ENDWHILE
 //
 IF workI > 1
  resultI = resultI - ( resultI / workI )
 ENDIF
 //
 RETURN( resultI )
END

INTEGER PROC ProcModMultiply( INTEGER leftI, INTEGER rightI, INTEGER modulusI )
 INTEGER resultI    = 0
 INTEGER leftWorkI  = leftI mod modulusI
 INTEGER rightWorkI = rightI
 //
 IF modulusI == 1
  RETURN( 0 )
 ENDIF
 //
 WHILE rightWorkI > 0
  IF ( rightWorkI & 1 ) == 1
   resultI = resultI + leftWorkI
   IF resultI >= modulusI
    resultI = resultI mod modulusI
   ENDIF
  ENDIF
  rightWorkI = rightWorkI shr 1
  IF rightWorkI > 0
   leftWorkI = leftWorkI + leftWorkI
   IF leftWorkI >= modulusI
    leftWorkI = leftWorkI mod modulusI
   ENDIF
  ENDIF
 ENDWHILE
 //
 RETURN( resultI mod modulusI )
END

INTEGER PROC ProcPowMod( INTEGER baseI, INTEGER exponentI, INTEGER modulusI )
 INTEGER resultI   = 1 mod modulusI
 INTEGER baseWorkI = baseI mod modulusI
 INTEGER expWorkI  = exponentI
 //
 IF modulusI == 1
  RETURN( 0 )
 ENDIF
 //
 WHILE expWorkI > 0
  IF ( expWorkI & 1 ) == 1
   resultI = ProcModMultiply( resultI, baseWorkI, modulusI )
  ENDIF
  expWorkI = expWorkI shr 1
  IF expWorkI > 0
   baseWorkI = ProcModMultiply( baseWorkI, baseWorkI, modulusI )
  ENDIF
 ENDWHILE
 //
 RETURN( resultI mod modulusI )
END

INTEGER PROC ProcTetrationMod( INTEGER baseI, INTEGER heightI, INTEGER modulusI )
 INTEGER phiI      = 0
 INTEGER exponentI = 0
 //
 IF modulusI == 1
  RETURN( 0 )
 ENDIF
 //
 IF heightI == 1
  RETURN( baseI mod modulusI )
 ENDIF
 //
 phiI      = ProcPhi( modulusI )
 exponentI = ProcTetrationMod( baseI, heightI - 1, phiI )
 //
 RETURN( ProcPowMod( baseI, exponentI, modulusI ) )
END

PROC Main()
 INTEGER answerI    = 0
 STRING  answerS[255] = ""
 //
 answerI = ProcTetrationMod( BASE_VALUE, HEIGHT_VALUE, MODULO_VALUE )
 answerS = Format( answerI )
 //
 CopyToWinClip( answerS )
 Warn( answerS )
 CopyToWinClip( answerS )
END
