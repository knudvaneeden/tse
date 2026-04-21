/*
  Project Euler problem 308
  An Amazing Prime-generating Automaton

  Pure TSE SAL solution.
  Computes the result, does not hardcode it.

  <version>1</version>

  History:
  1 - Initial pure TSE SAL solver for Project Euler problem 308.
      LLM: ChatGPT
*/

FORWARD PROC PROCResetTotal()
FORWARD PROC PROCNormalizeTotal()
FORWARD PROC PROCAddSmallToTotal( INTEGER valueI )
FORWARD PROC PROCAddProductToTotal( INTEGER leftI, INTEGER rightI )
FORWARD INTEGER PROC FNFirstPrimeFactorI( INTEGER numberI )
FORWARD PROC PROCAddCandidateContribution( INTEGER candidateI, INTEGER largestDivisorI )
FORWARD STRING PROC FNTotalToStringS()

#DEFINE TARGET_PRIME_INDEX 10001
#DEFINE BIG_BASE           10000

INTEGER total0GI = 0
INTEGER total1GI = 0
INTEGER total2GI = 0
INTEGER total3GI = 0
INTEGER total4GI = 0

PROC PROCResetTotal()
  total0GI = 0
  total1GI = 0
  total2GI = 0
  total3GI = 0
  total4GI = 0
END

PROC PROCNormalizeTotal()
  INTEGER carryI = 0
  carryI  = total0GI / BIG_BASE
  total0GI = total0GI mod BIG_BASE
  total1GI = total1GI + carryI
  carryI  = total1GI / BIG_BASE
  total1GI = total1GI mod BIG_BASE
  total2GI = total2GI + carryI
  carryI  = total2GI / BIG_BASE
  total2GI = total2GI mod BIG_BASE
  total3GI = total3GI + carryI
  carryI  = total3GI / BIG_BASE
  total3GI = total3GI mod BIG_BASE
  total4GI = total4GI + carryI
END

PROC PROCAddSmallToTotal( INTEGER valueI )
  INTEGER workingValueI = 0
  INTEGER chunk0I       = 0
  INTEGER chunk1I       = 0
  INTEGER chunk2I       = 0
  workingValueI = valueI
  chunk0I       = workingValueI mod BIG_BASE
  workingValueI = workingValueI / BIG_BASE
  chunk1I       = workingValueI mod BIG_BASE
  workingValueI = workingValueI / BIG_BASE
  chunk2I       = workingValueI
  total0GI      = total0GI + chunk0I
  total1GI      = total1GI + chunk1I
  total2GI      = total2GI + chunk2I
  PROCNormalizeTotal()
END

PROC PROCAddProductToTotal( INTEGER leftI, INTEGER rightI )
  INTEGER leftLowI      = 0
  INTEGER leftHighI     = 0
  INTEGER rightLowI     = 0
  INTEGER rightHighI    = 0
  INTEGER lowProductI   = 0
  INTEGER crossProductI = 0
  INTEGER highProductI  = 0
  leftLowI      = leftI mod BIG_BASE
  leftHighI     = leftI / BIG_BASE
  rightLowI     = rightI mod BIG_BASE
  rightHighI    = rightI / BIG_BASE
  lowProductI   = leftLowI * rightLowI
  crossProductI = leftHighI * rightLowI + leftLowI * rightHighI
  highProductI  = leftHighI * rightHighI
  total0GI      = total0GI + ( lowProductI mod BIG_BASE )
  total1GI      = total1GI + ( lowProductI / BIG_BASE )
  total1GI      = total1GI + ( crossProductI mod BIG_BASE )
  total2GI      = total2GI + ( crossProductI / BIG_BASE )
  total2GI      = total2GI + ( highProductI mod BIG_BASE )
  total3GI      = total3GI + ( highProductI / BIG_BASE )
  PROCNormalizeTotal()
END

INTEGER PROC FNFirstPrimeFactorI( INTEGER numberI )
  INTEGER divisorI = 0
  INTEGER stepI    = 0
  IF numberI == 2
    return( 2 )
  ENDIF
  IF numberI mod 2 == 0
    return( 2 )
  ENDIF
  IF numberI mod 3 == 0
    return( 3 )
  ENDIF
  divisorI = 5
  stepI    = 2
  WHILE divisorI * divisorI <= numberI
    IF numberI mod divisorI == 0
      return( divisorI )
    ENDIF
    divisorI = divisorI + stepI
    stepI    = 6 - stepI
  ENDWHILE
  return( numberI )
END

PROC PROCAddCandidateContribution( INTEGER candidateI, INTEGER largestDivisorI )
  INTEGER baseI                  = 0
  INTEGER firstUncheckedDivisorI = 0
  INTEGER lastUncheckedDivisorI  = 0
  INTEGER currentDivisorI        = 0
  INTEGER quotientI              = 0
  INTEGER nextDivisorI           = 0
  INTEGER countI                 = 0
  PROCAddSmallToTotal( candidateI - 1 )
  baseI                  = 2 + 6 * candidateI
  firstUncheckedDivisorI = largestDivisorI + 1
  lastUncheckedDivisorI  = candidateI - 1
  currentDivisorI        = firstUncheckedDivisorI
  WHILE currentDivisorI <= lastUncheckedDivisorI
    quotientI = candidateI / currentDivisorI
    nextDivisorI = candidateI / quotientI
    IF nextDivisorI > lastUncheckedDivisorI
      nextDivisorI = lastUncheckedDivisorI
    ENDIF
    countI = nextDivisorI - currentDivisorI + 1
    PROCAddProductToTotal( countI, baseI + 2 * quotientI )
    currentDivisorI = nextDivisorI + 1
  ENDWHILE
  PROCAddSmallToTotal( baseI + 2 * ( candidateI / largestDivisorI ) + largestDivisorI - 1 )
END

STRING PROC FNTotalToStringS()
  STRING answerS[255] = ""
  IF total4GI > 0
    answerS = Format(
      total4GI,
      total3GI : 4 : "0",
      total2GI : 4 : "0",
      total1GI : 4 : "0",
      total0GI : 4 : "0"
    )
  ELSE
    IF total3GI > 0
      answerS = Format(
        total3GI,
        total2GI : 4 : "0",
        total1GI : 4 : "0",
        total0GI : 4 : "0"
      )
    ELSE
      IF total2GI > 0
        answerS = Format(
          total2GI,
          total1GI : 4 : "0",
          total0GI : 4 : "0"
        )
      ELSE
        IF total1GI > 0
          answerS = Format(
            total1GI,
            total0GI : 4 : "0"
          )
        ELSE
          answerS = Format( total0GI )
        ENDIF
      ENDIF
    ENDIF
  ENDIF
  return( answerS )
END

PROC Main()
  INTEGER remainingPrimesI  = TARGET_PRIME_INDEX
  INTEGER candidateI        = 2
  INTEGER firstPrimeFactorI = 0
  INTEGER largestDivisorI   = 0
  STRING answerS[255]       = ""
  PROCResetTotal()
  WHILE remainingPrimesI > 0
    firstPrimeFactorI = FNFirstPrimeFactorI( candidateI )
    largestDivisorI   = candidateI / firstPrimeFactorI
    PROCAddCandidateContribution( candidateI, largestDivisorI )
    IF firstPrimeFactorI == candidateI
      remainingPrimesI = remainingPrimesI - 1
    ENDIF
    candidateI = candidateI + 1
  ENDWHILE
  answerS = FNTotalToStringS()
  CopyToWinClip( answerS )
  Warn( answerS )
  CopyToWinClip( answerS )
END
