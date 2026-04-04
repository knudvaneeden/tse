/*
  Project Euler 251 - Cardano Triplets
  Pure TSE SAL
  <version>1</version>
  History:
  1 - ChatGPT - Initial pure TSE SAL version for Project Euler problem 251.
*/
#define LIMIT_251 110000000
#define LIMIT_251_PLUS_ONE 110000001
integer gBezoutUI = 0
integer gBezoutVI = 0
FORWARD string proc ProcBigTrim( string numberS )
FORWARD integer proc ProcBigCompare( string leftS, string rightS )
FORWARD string proc ProcBigMulStringInt( string numberS, integer factorI )
FORWARD string proc ProcBigMulIntInt( integer leftI, integer rightI )
FORWARD integer proc ProcCubeLeLimit( integer rI, integer qI, integer limitI )
FORWARD integer proc ProcRMax( integer qI, integer limitI )
FORWARD integer proc ProcGcd( integer leftI, integer rightI )
FORWARD proc ProcExtendedGcd( integer leftI, integer rightI )
FORWARD integer proc ProcIntSqrt( integer numberI )
string proc ProcBigTrim( string numberS )
 string answerS[255] = ""
 integer indexI = 1
 integer lengthI = 0
 lengthI = Length( numberS )
 WHILE ( indexI < lengthI ) AND ( SubStr( numberS, indexI, 1 ) == "0" )
  indexI = indexI + 1
 ENDWHILE
 answerS = SubStr( numberS, indexI, lengthI - indexI + 1 )
 RETURN( answerS )
END
integer proc ProcBigCompare( string leftS, string rightS )
 string leftTrimS[255] = ""
 string rightTrimS[255] = ""
 integer leftLengthI = 0
 integer rightLengthI = 0
 integer indexI = 0
 leftTrimS = ProcBigTrim( leftS )
 rightTrimS = ProcBigTrim( rightS )
 leftLengthI = Length( leftTrimS )
 rightLengthI = Length( rightTrimS )
 IF leftLengthI < rightLengthI
  RETURN( -1 )
 ENDIF
 IF leftLengthI > rightLengthI
  RETURN( 1 )
 ENDIF
 FOR indexI = 1 TO leftLengthI
  IF SubStr( leftTrimS, indexI, 1 ) < SubStr( rightTrimS, indexI, 1 )
   RETURN( -1 )
  ENDIF
  IF SubStr( leftTrimS, indexI, 1 ) > SubStr( rightTrimS, indexI, 1 )
   RETURN( 1 )
  ENDIF
 ENDFOR
 RETURN( 0 )
END
string proc ProcBigMulStringInt( string numberS, integer factorI )
 string workS[255] = ""
 string answerS[255] = ""
 integer indexI = 0
 integer digitI = 0
 integer productI = 0
 integer carryI = 0
 integer outDigitI = 0
 IF factorI == 0
  RETURN( "0" )
 ENDIF
 workS = ProcBigTrim( numberS )
 carryI = 0
 FOR indexI = Length( workS ) DOWNTO 1
  digitI = Asc( SubStr( workS, indexI, 1 ) ) - Asc( "0" )
  productI = digitI * factorI + carryI
  outDigitI = productI mod 10
  carryI = productI / 10
  answerS = Chr( Asc( "0" ) + outDigitI ) + answerS
 ENDFOR
 WHILE carryI > 0
  outDigitI = carryI mod 10
  carryI = carryI / 10
  answerS = Chr( Asc( "0" ) + outDigitI ) + answerS
 ENDWHILE
 answerS = ProcBigTrim( answerS )
 RETURN( answerS )
END
string proc ProcBigMulIntInt( integer leftI, integer rightI )
 string leftS[255] = ""
 leftS = Format( leftI )
 RETURN( ProcBigMulStringInt( leftS, rightI ) )
END
integer proc ProcCubeLeLimit( integer rI, integer qI, integer limitI )
 integer squareI = 0
 string cubeS[255] = ""
 string rightS[255] = ""
 squareI = rI * rI
 cubeS = ProcBigMulIntInt( squareI, rI )
 rightS = ProcBigMulIntInt( 8 * qI, limitI )
 IF ProcBigCompare( cubeS, rightS ) <= 0
  RETURN( TRUE )
 ENDIF
 RETURN( FALSE )
END
integer proc ProcRMax( integer qI, integer limitI )
 integer lowI = 1
 integer highI = 22000
 integer midI = 0
 integer answerI = 1
 WHILE lowI <= highI
  midI = ( lowI + highI ) / 2
  IF ProcCubeLeLimit( midI, qI, limitI )
   answerI = midI
   lowI = midI + 1
  ELSE
   highI = midI - 1
  ENDIF
 ENDWHILE
 IF ( answerI mod 2 ) == 0
  answerI = answerI - 1
 ENDIF
 IF answerI < 1
  answerI = 1
 ENDIF
 RETURN( answerI )
END
integer proc ProcGcd( integer leftI, integer rightI )
 integer tempI = 0
 IF leftI < 0
  leftI = 0 - leftI
 ENDIF
 IF rightI < 0
  rightI = 0 - rightI
 ENDIF
 WHILE NOT ( rightI == 0 )
  tempI = leftI mod rightI
  leftI = rightI
  rightI = tempI
 ENDWHILE
 RETURN( leftI )
END
proc ProcExtendedGcd( integer leftI, integer rightI )
 integer oldRemainderI = 0
 integer remainderI = 0
 integer quotientI = 0
 integer tempI = 0
 integer oldSI = 0
 integer currentSI = 0
 integer oldTI = 0
 integer currentTI = 0
 oldRemainderI = leftI
 remainderI = rightI
 oldSI = 1
 currentSI = 0
 oldTI = 0
 currentTI = 1
 WHILE NOT ( remainderI == 0 )
  quotientI = oldRemainderI / remainderI
  tempI = oldRemainderI - quotientI * remainderI
  oldRemainderI = remainderI
  remainderI = tempI
  tempI = oldSI - quotientI * currentSI
  oldSI = currentSI
  currentSI = tempI
  tempI = oldTI - quotientI * currentTI
  oldTI = currentTI
  currentTI = tempI
 ENDWHILE
 gBezoutUI = oldSI
 gBezoutVI = oldTI
END
integer proc ProcIntSqrt( integer numberI )
 integer lowI = 0
 integer highI = 50000
 integer midI = 0
 integer answerI = 0
 integer squareI = 0
 WHILE lowI <= highI
  midI = ( lowI + highI ) / 2
  IF midI == 0
   squareI = 0
  ELSE
   IF midI <= ( numberI / midI )
    squareI = midI * midI
   ELSE
    squareI = numberI + 1
   ENDIF
  ENDIF
  IF squareI <= numberI
   answerI = midI
   lowI = midI + 1
  ELSE
   highI = midI - 1
  ENDIF
 ENDWHILE
 RETURN( answerI )
END
PROC Main()
 integer qMaxI = 0
 integer qI = 0
 integer q2I = 0
 integer numeratorI = 0
 integer tempI = 0
 integer denominatorI = 0
 integer pMaxI = 0
 integer totalI = 0
 integer rMaxI = 0
 integer rI = 0
 integer r2I = 0
 integer factor8qI = 0
 integer threeUI = 0
 integer p0I = 0
 integer stepShiftI = 0
 integer s0I = 0
 integer factorI = 0
 integer term1I = 0
 integer term2I = 0
 integer remI = 0
 integer rem2I = 0
 integer step1I = 0
 integer step2I = 0
 integer stepI = 0
 integer validTripletB = FALSE
 string finalAnswerS[255] = ""
 qMaxI = ProcIntSqrt( LIMIT_251 )
 totalI = 0
 FOR qI = 1 TO qMaxI
  q2I = qI * qI
  factor8qI = 8 * qI
  numeratorI = LIMIT_251_PLUS_ONE + 3 * q2I
  tempI = numeratorI - 3 * qI - 1
  pMaxI = 0
  IF tempI >= 0
   IF q2I <= ( tempI / factor8qI )
    denominatorI = factor8qI * q2I + 3 * qI + 1
    pMaxI = numeratorI / denominatorI
   ENDIF
  ENDIF
  totalI = totalI + pMaxI
  rMaxI = ProcRMax( qI, LIMIT_251_PLUS_ONE )
  FOR rI = 3 TO rMaxI BY 2
   IF ProcGcd( qI, rI ) == 1
    r2I = rI * rI
    ProcExtendedGcd( factor8qI, r2I )
    threeUI = 3 * gBezoutUI
    p0I = threeUI mod r2I
    WHILE p0I <= 0
     p0I = p0I + r2I
    ENDWHILE
    stepShiftI = ( p0I - threeUI ) / r2I
    s0I = 0 - ( 3 * gBezoutVI ) + factor8qI * stepShiftI
    validTripletB = TRUE
    IF s0I <= 0
     validTripletB = FALSE
    ENDIF
    factorI = 3 * qI + rI
    IF validTripletB
     IF p0I > ( LIMIT_251_PLUS_ONE / factorI )
      validTripletB = FALSE
     ELSE
      term1I = p0I * factorI
      remI = LIMIT_251_PLUS_ONE - term1I
      IF s0I > ( remI / q2I )
       validTripletB = FALSE
      ELSE
       term2I = s0I * q2I
       remI = remI - term2I
      ENDIF
     ENDIF
    ENDIF
    IF validTripletB
     totalI = totalI + 1
     IF r2I <= ( remI / factorI )
      step1I = r2I * factorI
      rem2I = remI - step1I
      IF q2I <= ( rem2I / factor8qI )
       step2I = q2I * factor8qI
       stepI = step1I + step2I
       totalI = totalI + ( remI / stepI )
      ENDIF
     ENDIF
    ENDIF
   ENDIF
  ENDFOR
 ENDFOR
 finalAnswerS = Format( totalI )
 CopyToWinClip( finalAnswerS )
 Warn( finalAnswerS )
 CopyToWinClip( finalAnswerS )
END
