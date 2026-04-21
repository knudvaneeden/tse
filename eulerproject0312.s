// Euler Project problem 312
// Cyclic Paths on Sierpinski Graphs
// Pure TSE SAL solution
// <version>1</version>
// History: ChatGPT created this pure TSE SAL program for Euler problem 312.

#DEFINE PROBLEM_NUMBER 312
#DEFINE START_INDEX    10000

INTEGER PROC FNPowerI( INTEGER baseI, INTEGER exponentI )
  INTEGER resultI = 1
  INTEGER remainingI = 0
  remainingI = exponentI
  WHILE remainingI > 0
    resultI = resultI * baseI
    remainingI = remainingI - 1
  ENDWHILE
  RETURN( resultI )
END

INTEGER PROC FNModAddI( INTEGER leftI, INTEGER rightI, INTEGER modulusI )
  INTEGER resultI = 0
  resultI = leftI + rightI
  IF resultI >= modulusI
    resultI = resultI - modulusI
  ENDIF
  RETURN( resultI )
END

INTEGER PROC FNModMulI( INTEGER leftI, INTEGER rightI, INTEGER modulusI )
  INTEGER resultI = 0
  INTEGER leftWorkI = 0
  INTEGER rightWorkI = 0
  resultI = 0
  leftWorkI = leftI MOD modulusI
  rightWorkI = rightI
  WHILE rightWorkI > 0
    IF ( rightWorkI & 1 ) == 1
      resultI = FNModAddI( resultI, leftWorkI, modulusI )
    ENDIF
    rightWorkI = rightWorkI shr 1
    IF rightWorkI > 0
      leftWorkI = FNModAddI( leftWorkI, leftWorkI, modulusI )
    ENDIF
  ENDWHILE
  RETURN( resultI )
END

INTEGER PROC FNModPowI( INTEGER baseI, INTEGER exponentI, INTEGER modulusI )
  INTEGER resultI = 1
  INTEGER baseWorkI = 0
  INTEGER exponentWorkI = 0
  resultI = 1 MOD modulusI
  baseWorkI = baseI MOD modulusI
  exponentWorkI = exponentI
  WHILE exponentWorkI > 0
    IF ( exponentWorkI & 1 ) == 1
      resultI = FNModMulI( resultI, baseWorkI, modulusI )
    ENDIF
    exponentWorkI = exponentWorkI shr 1
    IF exponentWorkI > 0
      baseWorkI = FNModMulI( baseWorkI, baseWorkI, modulusI )
    ENDIF
  ENDWHILE
  RETURN( resultI )
END

INTEGER PROC FNCombineWithSixI( INTEGER remainder13I, INTEGER powerI )
  INTEGER modulus13I = 0
  INTEGER adjustI = 0
  INTEGER resultI = 0
  modulus13I = FNPowerI( 13, powerI )
  adjustI = ( 6 - ( remainder13I MOD 6 ) ) MOD 6
  resultI = remainder13I + modulus13I * adjustI
  RETURN( resultI )
END

INTEGER PROC FNCyclicCountModPrimePowerI( INTEGER indexI, INTEGER powerI )
  INTEGER modulusI = 0
  INTEGER exponentModulusI = 0
  INTEGER power3ModulusI = 0
  INTEGER power3ValueI = 0
  INTEGER exponentI = 0
  INTEGER resultI = 0
  IF indexI <= 2
    RETURN( 1 )
  ENDIF
  modulusI = FNPowerI( 13, powerI )
  exponentModulusI = 2 * FNPowerI( 13, powerI - 1 )
  power3ModulusI = 2 * exponentModulusI
  power3ValueI = FNModPowI( 3, indexI - 2, power3ModulusI )
  exponentI = power3ValueI - 3
  IF exponentI < 0
    exponentI = exponentI + power3ModulusI
  ENDIF
  exponentI = exponentI / 2
  resultI = FNModMulI( 8, FNModPowI( 12, exponentI, modulusI ), modulusI )
  RETURN( resultI )
END

PROC Main()
  INTEGER firstRemainder13I = 0
  INTEGER firstReducedIndexI = 0
  INTEGER secondRemainder13I = 0
  INTEGER secondReducedIndexI = 0
  INTEGER answerI = 0
  STRING finalAnswerS[255] = ""
  firstRemainder13I = FNCyclicCountModPrimePowerI( START_INDEX, 4 )
  firstReducedIndexI = FNCombineWithSixI( firstRemainder13I, 4 )
  secondRemainder13I = FNCyclicCountModPrimePowerI( firstReducedIndexI, 6 )
  secondReducedIndexI = FNCombineWithSixI( secondRemainder13I, 6 )
  answerI = FNCyclicCountModPrimePowerI( secondReducedIndexI, 8 )
  finalAnswerS = Format( answerI )
  CopyToWinClip( finalAnswerS )
  Warn( finalAnswerS )
  CopyToWinClip( finalAnswerS )
END
