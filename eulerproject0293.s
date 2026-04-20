/*
  TSE SAL solution for Project Euler problem 293
  Pseudo-Fortunate Numbers
  <version>1</version>

  History:
  1 - ChatGPT GPT-5.4 Thinking
*/

#define LIMIT_N          1000000000
#define PRIME_LIMIT      31623
#define MAX_PRIME_INDEX  8

INTEGER gPrimeBufferGI = 0
INTEGER gPseudoFortunateBufferGI = 0
INTEGER gAnswerGI = 0

INTEGER PROC FNPrimeByIndexI( INTEGER primeIndexI )
  CASE primeIndexI
    WHEN 0
      RETURN( 2 )
    WHEN 1
      RETURN( 3 )
    WHEN 2
      RETURN( 5 )
    WHEN 3
      RETURN( 7 )
    WHEN 4
      RETURN( 11 )
    WHEN 5
      RETURN( 13 )
    WHEN 6
      RETURN( 17 )
    WHEN 7
      RETURN( 19 )
    WHEN 8
      RETURN( 23 )
    OTHERWISE
      RETURN( 0 )
  ENDCASE
END

INTEGER PROC FNIsPrimeByPrimeBufferB( INTEGER numberI )
  INTEGER lineCountI = 0
  INTEGER lineI = 1
  INTEGER divisorI = 0
  STRING divisorS[255] = ""

  IF numberI == 2
    RETURN( TRUE )
  ENDIF
  IF numberI < 2
    RETURN( FALSE )
  ENDIF
  IF ( numberI mod 2 ) == 0
    RETURN( FALSE )
  ENDIF

  PushLocation()
  GotoBufferId( gPrimeBufferGI )
  lineCountI = NumLines()
  lineI = 1
  WHILE lineI <= lineCountI
    GotoLine( lineI )
    divisorS = GetText( 1, 255 )
    divisorI = Val( divisorS )
    IF divisorI >= 2
      IF divisorI * divisorI > numberI
        PopLocation()
        RETURN( TRUE )
      ENDIF
      IF ( numberI mod divisorI ) == 0
        PopLocation()
        RETURN( FALSE )
      ENDIF
    ENDIF
    lineI = lineI + 1
  ENDWHILE
  PopLocation()

  RETURN( TRUE )
END

PROC PROCBuildPrimeBuffer()
  INTEGER candidateI = 0

  gPrimeBufferGI = CreateTempBuffer()
  AddLine( "2", gPrimeBufferGI )

  FOR candidateI = 3 TO PRIME_LIMIT BY 2
    IF FNIsPrimeByPrimeBufferB( candidateI )
      AddLine( Format( candidateI ), gPrimeBufferGI )
    ENDIF
  ENDFOR
END

PROC PROCRememberPseudoFortunate( INTEGER pseudoFortunateI )
  INTEGER lineCountI = 0
  INTEGER lineI = 1
  INTEGER existingI = 0
  INTEGER foundB = FALSE
  STRING existingS[255] = ""

  PushLocation()
  GotoBufferId( gPseudoFortunateBufferGI )
  lineCountI = NumLines()
  lineI = 1
  WHILE lineI <= lineCountI
    GotoLine( lineI )
    existingS = GetText( 1, 255 )
    existingI = Val( existingS )
    IF existingI == pseudoFortunateI
      foundB = TRUE
    ENDIF
    lineI = lineI + 1
  ENDWHILE

  IF foundB == FALSE
    AddLine( Format( pseudoFortunateI ), gPseudoFortunateBufferGI )
    gAnswerGI = gAnswerGI + pseudoFortunateI
  ENDIF
  PopLocation()
END

PROC PROCProcessAdmissible( INTEGER admissibleI )
  INTEGER pseudoFortunateI = 3

  WHILE TRUE
    IF FNIsPrimeByPrimeBufferB( admissibleI + pseudoFortunateI )
      PROCRememberPseudoFortunate( pseudoFortunateI )
      RETURN()
    ENDIF
    pseudoFortunateI = pseudoFortunateI + 2
  ENDWHILE
END

PROC PROCGenerateAdmissibleNumbers( INTEGER primeIndexI, INTEGER lastPrimeIndexI, INTEGER currentProductI )
  INTEGER primeI = 0
  INTEGER nextProductI = 0

  primeI = FNPrimeByIndexI( primeIndexI )

  IF currentProductI > ( LIMIT_N / primeI )
    RETURN()
  ENDIF

  nextProductI = currentProductI * primeI

  WHILE nextProductI < LIMIT_N
    IF primeIndexI == lastPrimeIndexI
      PROCProcessAdmissible( nextProductI )
    ELSE
      PROCGenerateAdmissibleNumbers( primeIndexI + 1, lastPrimeIndexI, nextProductI )
    ENDIF

    IF nextProductI > ( LIMIT_N / primeI )
      RETURN()
    ENDIF

    nextProductI = nextProductI * primeI
  ENDWHILE
END

PROC Main()
  INTEGER lastPrimeIndexI = 0
  INTEGER doneB = FALSE
  INTEGER primorialI = 1
  INTEGER primeI = 0
  STRING answerS[255] = ""

  gAnswerGI = 0
  gPseudoFortunateBufferGI = CreateTempBuffer()

  PROCBuildPrimeBuffer()

  lastPrimeIndexI = 0
  doneB = FALSE
  primorialI = 1

  WHILE ( lastPrimeIndexI <= MAX_PRIME_INDEX ) AND ( doneB == FALSE )
    primeI = FNPrimeByIndexI( lastPrimeIndexI )

    IF primorialI > ( LIMIT_N / primeI )
      doneB = TRUE
    ELSE
      primorialI = primorialI * primeI
      IF primorialI < LIMIT_N
        PROCGenerateAdmissibleNumbers( 0, lastPrimeIndexI, 1 )
        lastPrimeIndexI = lastPrimeIndexI + 1
      ELSE
        doneB = TRUE
      ENDIF
    ENDIF
  ENDWHILE

  answerS = Format( gAnswerGI )

  CopyToWinClip( answerS )
  Warn( answerS )
  CopyToWinClip( answerS )
END
