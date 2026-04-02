/*
  Euler Project 243 - pure TSE SAL
  Version history:
  2 - Corrected overflow-safe ChatGPT version for problem 243

  LLM creator recorded for statistics: ChatGPT

  Applied rule check for this source:
  - Pure TSE SAL only
  - No Python or external calculator
  - No own variables named val or pos
  - RETURN() always uses parentheses
  - Only one final Warn() box
  - Two CopyToWinClip() calls around the final Warn()
  - Final Warn() shows only the final numeric answer
  - Version number appears at one position only
*/

FORWARD INTEGER PROC ProcIsPrime( INTEGER numberI )
FORWARD INTEGER PROC ProcNextPrime( INTEGER currentPrimeI )
FORWARD INTEGER PROC ProcCompareFractions( INTEGER leftNumI, INTEGER leftDenI, INTEGER rightNumI, INTEGER rightDenI )

INTEGER PROC ProcIsPrime( INTEGER numberI )
  INTEGER divisorI = 0
  //
  IF ( numberI < 2 )
    RETURN( FALSE )
  ENDIF
  //
  IF ( numberI == 2 )
    RETURN( TRUE )
  ENDIF
  //
  IF ( ( numberI mod 2 ) == 0 )
    RETURN( FALSE )
  ENDIF
  //
  divisorI = 3
  WHILE ( divisorI <= ( numberI / divisorI ) )
    IF ( ( numberI mod divisorI ) == 0 )
      RETURN( FALSE )
    ENDIF
    divisorI = divisorI + 2
  ENDWHILE
  //
  RETURN( TRUE )

END

INTEGER PROC ProcNextPrime( INTEGER currentPrimeI )
  INTEGER candidateI = 0
  //
  IF ( currentPrimeI < 2 )
    RETURN( 2 )
  ENDIF
  //
  candidateI = currentPrimeI + 1
  WHILE ( TRUE )
    IF ProcIsPrime( candidateI )
      RETURN( candidateI )
    ENDIF
    candidateI = candidateI + 1
  ENDWHILE
  //
  RETURN( 2 )

END

INTEGER PROC ProcCompareFractions( INTEGER leftNumI, INTEGER leftDenI, INTEGER rightNumI, INTEGER rightDenI )
  INTEGER leftWholeI  = 0
  INTEGER rightWholeI = 0
  INTEGER leftRestI   = 0
  INTEGER rightRestI  = 0
  INTEGER compareI    = 0
  //
  leftWholeI  = leftNumI / leftDenI
  rightWholeI = rightNumI / rightDenI
  //
  IF ( leftWholeI < rightWholeI )
    RETURN( -1 )
  ENDIF
  //
  IF ( leftWholeI > rightWholeI )
    RETURN( 1 )
  ENDIF
  //
  leftRestI  = leftNumI mod leftDenI
  rightRestI = rightNumI mod rightDenI
  //
  IF ( leftRestI == 0 )
    IF ( rightRestI == 0 )
      RETURN( 0 )
    ELSE
      RETURN( -1 )
    ENDIF
  ENDIF
  //
  IF ( rightRestI == 0 )
    RETURN( 1 )
  ENDIF
  //
  compareI = ProcCompareFractions( leftDenI, leftRestI, rightDenI, rightRestI )
  RETURN( -compareI )

END

PROC Main()
  INTEGER MAX_INT_I       = 2147483647
  INTEGER targetNumI      = 15499
  INTEGER targetDenI      = 94744
  INTEGER productI        = 1
  INTEGER phiI            = 1
  INTEGER currentPrimeI   = 2
  INTEGER nextPrimeI      = 0
  INTEGER trialProductI   = 0
  INTEGER trialPhiI       = 0
  INTEGER multiplierI     = 0
  INTEGER candidateDenI   = 0
  INTEGER candidatePhiI   = 0
  INTEGER answerI         = 0
  STRING answerS[255]     = ""
  //
  WHILE ( TRUE )
    //
    // Overflow-safe stop:
    // if the next primorial step would overflow 32-bit SAL,
    // keep current productI/phiI and search multipliers below currentPrimeI.
    //
    IF ( productI > ( MAX_INT_I / currentPrimeI ) )
      nextPrimeI = currentPrimeI
      BREAK
    ENDIF
    //
    trialProductI = productI * currentPrimeI
    trialPhiI     = phiI * ( currentPrimeI - 1 )
    //
    productI = trialProductI
    phiI     = trialPhiI
    //
    currentPrimeI = ProcNextPrime( currentPrimeI )
  ENDWHILE
  //
  answerI = 0
  FOR multiplierI = 1 TO nextPrimeI - 1
    candidateDenI = productI * multiplierI
    candidatePhiI = phiI * multiplierI
    //
    IF ( ProcCompareFractions( candidatePhiI, candidateDenI - 1, targetNumI, targetDenI ) < 0 )
      answerI = candidateDenI
      BREAK
    ENDIF
  ENDFOR
  //
  answerS = Str( answerI )
  CopyToWinClip( answerS )
  Warn( answerS )
  CopyToWinClip( answerS )

END
