// Project Euler problem 296
// URL: https://projecteuler.net/problem=296
// Pure TSE SAL
//
#DEFINE LIMIT_N    100000
#DEFINE VERSION_I  1
//
INTEGER gPrimeCountGI = 0
INTEGER gPrime1GI = 0
INTEGER gPrime2GI = 0
INTEGER gPrime3GI = 0
INTEGER gPrime4GI = 0
INTEGER gPrime5GI = 0
INTEGER gPrime6GI = 0
//
PROC PROCResetPrimeFactors()
  gPrimeCountGI = 0
  gPrime1GI = 0
  gPrime2GI = 0
  gPrime3GI = 0
  gPrime4GI = 0
  gPrime5GI = 0
  gPrime6GI = 0
END
//
PROC PROCAddPrimeFactor( INTEGER primeI )
  gPrimeCountGI = gPrimeCountGI + 1
  IF gPrimeCountGI == 1
    gPrime1GI = primeI
  ELSEIF gPrimeCountGI == 2
    gPrime2GI = primeI
  ELSEIF gPrimeCountGI == 3
    gPrime3GI = primeI
  ELSEIF gPrimeCountGI == 4
    gPrime4GI = primeI
  ELSEIF gPrimeCountGI == 5
    gPrime5GI = primeI
  ELSE
    gPrime6GI = primeI
  ENDIF
END
//
PROC PROCSetDistinctPrimeFactors( INTEGER valueI )
  INTEGER remainingI = 0
  INTEGER testFactorI = 0
  //
  PROCResetPrimeFactors()
  remainingI = valueI
  IF ( remainingI mod 2 ) == 0
    PROCAddPrimeFactor( 2 )
    WHILE ( remainingI mod 2 ) == 0
      remainingI = remainingI / 2
    ENDWHILE
  ENDIF
  testFactorI = 3
  WHILE ( testFactorI * testFactorI ) <= remainingI
    IF ( remainingI mod testFactorI ) == 0
      PROCAddPrimeFactor( testFactorI )
      WHILE ( remainingI mod testFactorI ) == 0
        remainingI = remainingI / testFactorI
      ENDWHILE
    ENDIF
    testFactorI = testFactorI + 2
  ENDWHILE
  IF remainingI > 1
    PROCAddPrimeFactor( remainingI )
  ENDIF
END
//
INTEGER PROC FNTriangleTimesI( INTEGER countI, INTEGER multiplierI )
  INTEGER leftI = 0
  INTEGER rightI = 0
  //
  IF countI <= 1
    RETURN( 0 )
  ENDIF
  IF ( countI mod 2 ) == 0
    leftI = countI / 2
    rightI = countI - 1
  ELSE
    leftI = countI
    rightI = ( countI - 1 ) / 2
  ENDIF
  IF leftI < rightI
    leftI = leftI * multiplierI
  ELSE
    rightI = rightI * multiplierI
  ENDIF
  RETURN( leftI * rightI )
END
//
INTEGER PROC FNFloorSumI( INTEGER nI, INTEGER mI, INTEGER aI, INTEGER bI )
  INTEGER answerI = 0
  INTEGER doneI = FALSE
  INTEGER quotientI = 0
  INTEGER yMaxI = 0
  INTEGER swapI = 0
  //
  WHILE doneI == FALSE
    IF aI >= mI
      quotientI = aI / mI
      answerI = answerI + FNTriangleTimesI( nI, quotientI )
      aI = aI mod mI
    ENDIF
    IF bI >= mI
      quotientI = bI / mI
      answerI = answerI + ( nI * quotientI )
      bI = bI mod mI
    ENDIF
    yMaxI = ( aI * nI ) + bI
    IF yMaxI < mI
      doneI = TRUE
    ELSE
      nI = yMaxI / mI
      bI = yMaxI mod mI
      swapI = mI
      mI = aI
      aI = swapI
    ENDIF
  ENDWHILE
  RETURN( answerI )
END
//
INTEGER PROC FNPrefixCeilSumI( INTEGER upperI, INTEGER qI, INTEGER gI )
  IF upperI <= 0
    RETURN( 0 )
  ENDIF
  RETURN( upperI + FNFloorSumI( upperI, gI, qI, qI - 1 ) )
END
//
INTEGER PROC FNCountForQGI( INTEGER qI, INTEGER gI, INTEGER lowerI )
  INTEGER upperI = 0
  INTEGER countI = 0
  INTEGER halfQI = 0
  INTEGER sumCeilI = 0
  //
  upperI = gI / 2
  IF lowerI > upperI
    RETURN( 0 )
  ENDIF
  countI = upperI - lowerI + 1
  halfQI = qI / 2
  sumCeilI = FNPrefixCeilSumI( upperI, qI, gI ) - FNPrefixCeilSumI( lowerI - 1, qI, gI )
  RETURN( ( countI * ( halfQI + 1 ) ) - sumCeilI )
END
//
INTEGER PROC FNSubsetDivisorI( INTEGER maskI )
  INTEGER divisorI = 1
  //
  IF ( gPrimeCountGI >= 1 ) AND ( ( maskI & 1 ) > 0 )
    divisorI = divisorI * gPrime1GI
  ENDIF
  IF ( gPrimeCountGI >= 2 ) AND ( ( maskI & 2 ) > 0 )
    divisorI = divisorI * gPrime2GI
  ENDIF
  IF ( gPrimeCountGI >= 3 ) AND ( ( maskI & 4 ) > 0 )
    divisorI = divisorI * gPrime3GI
  ENDIF
  IF ( gPrimeCountGI >= 4 ) AND ( ( maskI & 8 ) > 0 )
    divisorI = divisorI * gPrime4GI
  ENDIF
  IF ( gPrimeCountGI >= 5 ) AND ( ( maskI & 16 ) > 0 )
    divisorI = divisorI * gPrime5GI
  ENDIF
  IF ( gPrimeCountGI >= 6 ) AND ( ( maskI & 32 ) > 0 )
    divisorI = divisorI * gPrime6GI
  ENDIF
  RETURN( divisorI )
END
//
INTEGER PROC FNSubsetSignI( INTEGER maskI )
  INTEGER signI = 1
  //
  IF ( gPrimeCountGI >= 1 ) AND ( ( maskI & 1 ) > 0 )
    signI = -signI
  ENDIF
  IF ( gPrimeCountGI >= 2 ) AND ( ( maskI & 2 ) > 0 )
    signI = -signI
  ENDIF
  IF ( gPrimeCountGI >= 3 ) AND ( ( maskI & 4 ) > 0 )
    signI = -signI
  ENDIF
  IF ( gPrimeCountGI >= 4 ) AND ( ( maskI & 8 ) > 0 )
    signI = -signI
  ENDIF
  IF ( gPrimeCountGI >= 5 ) AND ( ( maskI & 16 ) > 0 )
    signI = -signI
  ENDIF
  IF ( gPrimeCountGI >= 6 ) AND ( ( maskI & 32 ) > 0 )
    signI = -signI
  ENDIF
  RETURN( signI )
END
//
PROC Main()
  INTEGER sumSideI = 0
  INTEGER maxGI = 0
  INTEGER gI = 0
  INTEGER lowerI = 0
  INTEGER upperI = 0
  INTEGER subsetLimitI = 0
  INTEGER maskI = 0
  INTEGER divisorI = 0
  INTEGER signI = 0
  INTEGER reducedSumI = 0
  INTEGER subtotalI = 0
  INTEGER answerI = 0
  STRING answerS[255] = ""
  //
  // <version>1</version>
  // <history>
  // 1 - ChatGPT GPT-5.4 Thinking - 2026-04-20 - Project Euler problem 296 pure TSE SAL program.
  // </history>
  //
  FOR sumSideI = 2 TO LIMIT_N / 2
    PROCSetDistinctPrimeFactors( sumSideI )
    subsetLimitI = 1 shl gPrimeCountGI
    maxGI = LIMIT_N / sumSideI
    FOR gI = 1 TO maxGI - 1
      IF ( 2 * gI ) <= maxGI
        lowerI = 1
      ELSE
        lowerI = ( 2 * gI ) - maxGI
      ENDIF
      upperI = gI / 2
      IF lowerI <= upperI
        subtotalI = 0
        FOR maskI = 0 TO subsetLimitI - 1
          divisorI = FNSubsetDivisorI( maskI )
          signI = FNSubsetSignI( maskI )
          reducedSumI = sumSideI / divisorI
          subtotalI = subtotalI + ( signI * FNCountForQGI( reducedSumI, gI, lowerI ) )
        ENDFOR
        answerI = answerI + subtotalI
      ENDIF
    ENDFOR
  ENDFOR
  answerS = Format( answerI )
  CopyToWinClip( answerS )
  Warn( answerS )
  CopyToWinClip( answerS )
END
