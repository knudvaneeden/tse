/*
  Euler Project 225 - Tribonacci Non-divisors
  Pure TSE SAL solution
  <version>1.0.0.0.1</version>
  <history>
    2026-03-28 ChatGPT GPT-5.4 Thinking created this TSE SAL program.
  </history>
*/
FORWARD INTEGER PROC ProcIsOddNonDivisor( INTEGER modulusI )
INTEGER PROC ProcIsOddNonDivisor( INTEGER modulusI )
  INTEGER tortoiseA_I = 0
  INTEGER tortoiseB_I = 0
  INTEGER tortoiseC_I = 0
  INTEGER hareA_I     = 0
  INTEGER hareB_I     = 0
  INTEGER hareC_I     = 0
  INTEGER nextTermI   = 0
  IF modulusI <= 1
    RETURN( FALSE )
  ENDIF
  tortoiseA_I = 1
  tortoiseB_I = 1
  tortoiseC_I = 1
  hareA_I     = 1
  hareB_I     = 1
  hareC_I     = 1
  WHILE TRUE
    nextTermI   = ( tortoiseA_I + tortoiseB_I + tortoiseC_I ) mod modulusI
    tortoiseA_I = tortoiseB_I
    tortoiseB_I = tortoiseC_I
    tortoiseC_I = nextTermI
    IF ( tortoiseA_I == 0 ) OR ( tortoiseB_I == 0 ) OR ( tortoiseC_I == 0 )
      RETURN( FALSE )
    ENDIF
    nextTermI = ( hareA_I + hareB_I + hareC_I ) mod modulusI
    hareA_I   = hareB_I
    hareB_I   = hareC_I
    hareC_I   = nextTermI
    IF ( hareA_I == 0 ) OR ( hareB_I == 0 ) OR ( hareC_I == 0 )
      RETURN( FALSE )
    ENDIF
    nextTermI = ( hareA_I + hareB_I + hareC_I ) mod modulusI
    hareA_I   = hareB_I
    hareB_I   = hareC_I
    hareC_I   = nextTermI
    IF ( hareA_I == 0 ) OR ( hareB_I == 0 ) OR ( hareC_I == 0 )
      RETURN( FALSE )
    ENDIF
    IF ( tortoiseA_I == hareA_I ) AND ( tortoiseB_I == hareB_I ) AND ( tortoiseC_I == hareC_I )
      RETURN( TRUE )
    ENDIF
  ENDWHILE
  RETURN( FALSE )
END
PROC Main()
  INTEGER targetCountI    = 124
  INTEGER foundCountI     = 0
  INTEGER candidateI      = 1
  INTEGER finalAnswerI    = 0
  STRING  finalAnswerS[255] = ""
  WHILE foundCountI < targetCountI
    IF ProcIsOddNonDivisor( candidateI )
      foundCountI = foundCountI + 1
      finalAnswerI = candidateI
    ENDIF
    candidateI = candidateI + 2
  ENDWHILE
  finalAnswerS = Format( finalAnswerI:0 )
  CopyToWinClip( finalAnswerS )
  Warn( finalAnswerS )
  CopyToWinClip( finalAnswerS )
END
