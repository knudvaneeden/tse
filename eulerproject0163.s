/*
  Euler Project 163 - Cross-hatched Triangles
  Pure TSE SAL program
  Exact closed-form quasipolynomial evaluation

  Version history:
  2026-03-22  1.0.0.0.1
  Created by GPT-5.4 Thinking

  Problem reference:
  T(1) = 16
  T(2) = 104
  Find T(36)

  Exact formula used:
  a(n) =
  (1678*n^3 + 3117*n^2 + 88*n
   - 345*(n mod 2)
   - 320*(n mod 3)
   - 90*(n mod 4)
   - 288*((n^3 - n^2 + n) mod 5)) / 240

  For n = 36 this evaluates to 343047
*/

#DEFINE TARGET_N163 36

FORWARD STRING PROC ProcIntegerToString( INTEGER numberI )
FORWARD INTEGER PROC ProcPower3( INTEGER numberI )
FORWARD INTEGER PROC ProcEuler163( INTEGER nI )

STRING PROC ProcIntegerToString( INTEGER numberI )
  STRING resultS[255] = ""
  INTEGER workI = 0
  INTEGER digitI = 0
  STRING digitsS[10] = "0123456789"
  IF numberI == 0
    Return( "0" )
  ENDIF
  workI = numberI
  IF workI < 0
    workI = -workI
  ENDIF
  WHILE workI > 0
    digitI = workI mod 10
    resultS = SubStr( digitsS, digitI + 1, 1 ) + resultS
    workI = workI / 10
  ENDWHILE
  IF numberI < 0
    resultS = "-" + resultS
  ENDIF
  Return( resultS )
END

INTEGER PROC ProcPower3( INTEGER numberI )
  INTEGER resultI = 0
  resultI = numberI * numberI * numberI
  Return( resultI )
END

INTEGER PROC ProcEuler163( INTEGER nI )
  INTEGER n2I = 0
  INTEGER n3I = 0
  INTEGER mod2I = 0
  INTEGER mod3I = 0
  INTEGER mod4I = 0
  INTEGER mod5ExprI = 0
  INTEGER numeratorI = 0
  INTEGER resultI = 0
  n2I = nI * nI
  n3I = ProcPower3( nI )
  mod2I = nI mod 2
  mod3I = nI mod 3
  mod4I = nI mod 4
  mod5ExprI = ( n3I - n2I + nI ) mod 5
  numeratorI =
    1678 * n3I +
    3117 * n2I +
    88   * nI -
    345  * mod2I -
    320  * mod3I -
    90   * mod4I -
    288  * mod5ExprI
  resultI = numeratorI / 240
  Return( resultI )
END

PROC Main()
  INTEGER nI = TARGET_N163
  INTEGER answerI = 0
  STRING answerS[255] = ""
  STRING messageS[255] = ""
  STRING versionS[255] = "1.0.0.0.1"
  answerI = ProcEuler163( nI )
  answerS = ProcIntegerToString( answerI )
  CopyToWinClip( answerS )
  messageS =
    "Euler Project 163" + Chr( 13 ) +
    "version = " + versionS + Chr( 13 ) +
    "n = " + ProcIntegerToString( nI ) + Chr( 13 ) +
    "T(n) = " + answerS
  Warn( messageS )
  CopyToWinClip( answerS )
END
