/*
 <version>1.0.0.0.1</version>
 Euler Project 195
 60-degree Triangle Inscribed Circles
 Pure TSE SAL solution
 Created by: ChatGPT GPT-5.4 Thinking

 History:
 1.0.0.0.1
 - Initial pure TSE SAL version.
 - Uses the standard Eisenstein-triple parameterization.
 - Counts both primitive families and all integer multiples.
 - Uses exact integer correction for floor( 2*n/sqrt(3) ) and floor( 6*n/sqrt(3) )
   without floating point.
 - Final answer is shown in one Warn() box only.
 - Final answer is copied to clipboard both before and after Warn().
*/

/*
 Mathematical summary

 For coprime integers p > q > 0, all integer-sided 60-degree triangles arise
 from the Eisenstein parameterization.

 One primitive family contributes inradius:
   r = k * p * q * sqrt(3) / 2
 when ( p - q ) mod 3 <> 0.

 The other primitive family contributes inradius:
   r = k * p * q * sqrt(3) / 6
 when p mod 3 == q mod 3.

 Therefore:
   T( n ) =
     sum floor( floor( 2*n/sqrt(3) ) / ( p*q ) )   over gcd( p, q ) = 1, p > q, ( p - q ) mod 3 <> 0
   +
     sum floor( floor( 6*n/sqrt(3) ) / ( p*q ) )   over gcd( p, q ) = 1, p > q, p mod 3 == q mod 3

 Check values from the problem statement:
   T(100)   = 1234
   T(1000)  = 22767
   T(10000) = 359912
*/

#define TARGET_RADIUS 1053779

FORWARD INTEGER PROC ProcGcd( INTEGER aI, INTEGER bI )
FORWARD INTEGER PROC ProcCompareScaledSquares( INTEGER leftValueI, INTEGER leftScaleI, INTEGER rightValueI, INTEGER rightScaleI )
FORWARD INTEGER PROC ProcFloorTwoOverSqrtThree( INTEGER nI )
FORWARD INTEGER PROC ProcFloorSixOverSqrtThree( INTEGER nI )
FORWARD INTEGER PROC ProcSolve( INTEGER radiusLimitI )

INTEGER PROC ProcGcd( INTEGER aI, INTEGER bI )
 INTEGER tempI = 0
 WHILE NOT( bI == 0 )
  tempI = aI mod bI
  aI = bI
  bI = tempI
 ENDWHILE
 RETURN( aI )
END

INTEGER PROC ProcCompareScaledSquares( INTEGER leftValueI, INTEGER leftScaleI, INTEGER rightValueI, INTEGER rightScaleI )
 INTEGER leftHighI = leftValueI / 1000
 INTEGER leftLowI = leftValueI mod 1000
 INTEGER rightHighI = rightValueI / 1000
 INTEGER rightLowI = rightValueI mod 1000
 INTEGER leftPart2I = 0
 INTEGER leftPart1I = 0
 INTEGER leftPart0I = 0
 INTEGER rightPart2I = 0
 INTEGER rightPart1I = 0
 INTEGER rightPart0I = 0
 INTEGER tempI = 0
 INTEGER carryI = 0

 tempI = leftScaleI * leftLowI * leftLowI
 leftPart0I = tempI mod 1000
 carryI = tempI / 1000
 tempI = ( leftScaleI * 2 * leftHighI * leftLowI ) + carryI
 leftPart1I = tempI mod 1000
 carryI = tempI / 1000
 leftPart2I = ( leftScaleI * leftHighI * leftHighI ) + carryI

 tempI = rightScaleI * rightLowI * rightLowI
 rightPart0I = tempI mod 1000
 carryI = tempI / 1000
 tempI = ( rightScaleI * 2 * rightHighI * rightLowI ) + carryI
 rightPart1I = tempI mod 1000
 carryI = tempI / 1000
 rightPart2I = ( rightScaleI * rightHighI * rightHighI ) + carryI

 IF leftPart2I < rightPart2I
  RETURN( -1 )
 ENDIF
 IF leftPart2I > rightPart2I
  RETURN( 1 )
 ENDIF

 IF leftPart1I < rightPart1I
  RETURN( -1 )
 ENDIF
 IF leftPart1I > rightPart1I
  RETURN( 1 )
 ENDIF

 IF leftPart0I < rightPart0I
  RETURN( -1 )
 ENDIF
 IF leftPart0I > rightPart0I
  RETURN( 1 )
 ENDIF

 RETURN( 0 )
END

INTEGER PROC ProcFloorTwoOverSqrtThree( INTEGER nI )
 INTEGER estimateI = 0

 /*
  Initial rational estimate:
   2 / sqrt(3) ~= 1142 / 989
  Then corrected exactly by integer square comparison:
   x <= 2*n/sqrt(3)  <=>  3*x*x <= 4*n*n
 */

 estimateI = ( ( nI / 989 ) * 1142 ) + ( ( ( nI mod 989 ) * 1142 ) / 989 )

 WHILE ProcCompareScaledSquares( estimateI + 1, 3, nI, 4 ) <= 0
  estimateI = estimateI + 1
 ENDWHILE

 WHILE ProcCompareScaledSquares( estimateI, 3, nI, 4 ) > 0
  estimateI = estimateI - 1
 ENDWHILE

 RETURN( estimateI )
END

INTEGER PROC ProcFloorSixOverSqrtThree( INTEGER nI )
 INTEGER estimateI = 0

 /*
  Initial rational estimate:
   6 / sqrt(3) ~= 3426 / 989
  Then corrected exactly by integer square comparison:
   x <= 6*n/sqrt(3)  <=>  x*x <= 12*n*n
 */

 estimateI = ( ( nI / 989 ) * 3426 ) + ( ( ( nI mod 989 ) * 3426 ) / 989 )

 WHILE ProcCompareScaledSquares( estimateI + 1, 1, nI, 12 ) <= 0
  estimateI = estimateI + 1
 ENDWHILE

 WHILE ProcCompareScaledSquares( estimateI, 1, nI, 12 ) > 0
  estimateI = estimateI - 1
 ENDWHILE

 RETURN( estimateI )
END

INTEGER PROC ProcSolve( INTEGER radiusLimitI )
 INTEGER maxr1I = 0
 INTEGER maxr2I = 0
 INTEGER totalI = 0
 INTEGER qI = 0
 INTEGER pI = 0
 INTEGER productI = 0

 maxr1I = ProcFloorTwoOverSqrtThree( radiusLimitI )
 maxr2I = ProcFloorSixOverSqrtThree( radiusLimitI )

 /*
  Family 1:
   primitive inradius = p*q*sqrt(3)/2
   conditions: gcd( p, q ) = 1, p > q, ( p - q ) mod 3 <> 0
 */

 qI = 1
 WHILE qI * qI <= maxr1I
  pI = qI + 1
  WHILE pI * qI <= maxr1I
   productI = pI * qI
   IF NOT( ( ( pI - qI ) mod 3 ) == 0 )
    IF ProcGcd( pI, qI ) == 1
     totalI = totalI + ( maxr1I / productI )
    ENDIF
   ENDIF
   pI = pI + 1
  ENDWHILE
  qI = qI + 1
 ENDWHILE

 /*
  Family 2:
   primitive inradius = p*q*sqrt(3)/6
   conditions: gcd( p, q ) = 1, p > q, p mod 3 == q mod 3
   We enforce p = q + 3, q + 6, ...
 */

 qI = 1
 WHILE qI * qI <= maxr2I
  pI = qI + 3
  WHILE pI * qI <= maxr2I
   productI = pI * qI
   IF ProcGcd( pI, qI ) == 1
    totalI = totalI + ( maxr2I / productI )
   ENDIF
   pI = pI + 3
  ENDWHILE
  qI = qI + 1
 ENDWHILE

 RETURN( totalI )
END

PROC Main()
 INTEGER answerI = 0
 STRING answerS[255] = ""

 answerI = ProcSolve( TARGET_RADIUS )
 answerS = Format( answerI )

 CopyToWinClip( answerS )
 Warn( answerS )
 CopyToWinClip( answerS )
END
