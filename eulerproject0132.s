// TSE/32
//
// eulerproject132.s
//
// Project Euler problem 132
// Large repunit factors
//
// Created by: ChatGPT GPT-5.4 Thinking
// <version>1.0.0.0.2</version>

FORWARD INTEGER PROC MulMod( INTEGER leftI, INTEGER rightI, INTEGER modulusI )
FORWARD INTEGER PROC PowMod( INTEGER baseI, INTEGER exponentI, INTEGER modulusI )
FORWARD INTEGER PROC IsPrime( INTEGER numberI )
FORWARD INTEGER PROC IsRepunitFactor( INTEGER primeI )
FORWARD STRING PROC SolveProblem132()

INTEGER PROC MulMod( INTEGER leftI, INTEGER rightI, INTEGER modulusI )
 INTEGER resultI = 0
 INTEGER aI = 0
 INTEGER bI = 0
 //
 aI = leftI mod modulusI
 bI = rightI
 WHILE bI > 0
  IF ( bI mod 2 ) == 1
   resultI = resultI + aI
   IF resultI >= modulusI
    resultI = resultI mod modulusI
   ENDIF
  ENDIF
  aI = aI + aI
  IF aI >= modulusI
   aI = aI mod modulusI
  ENDIF
  bI = bI / 2
 ENDWHILE
 Return( resultI )
END

INTEGER PROC PowMod( INTEGER baseI, INTEGER exponentI, INTEGER modulusI )
 INTEGER resultI = 1
 INTEGER currentBaseI = 0
 INTEGER currentExponentI = 0
 //
 currentBaseI = baseI mod modulusI
 currentExponentI = exponentI
 WHILE currentExponentI > 0
  IF ( currentExponentI mod 2 ) == 1
   resultI = MulMod( resultI, currentBaseI, modulusI )
  ENDIF
  currentBaseI = MulMod( currentBaseI, currentBaseI, modulusI )
  currentExponentI = currentExponentI / 2
 ENDWHILE
 Return( resultI )
END

INTEGER PROC IsPrime( INTEGER numberI )
 INTEGER divisorI = 0
 //
 IF numberI < 2
  Return( FALSE )
 ENDIF
 IF numberI == 2
  Return( TRUE )
 ENDIF
 IF ( numberI mod 2 ) == 0
  Return( FALSE )
 ENDIF
 divisorI = 3
 WHILE ( divisorI * divisorI ) <= numberI
  IF ( numberI mod divisorI ) == 0
   Return( FALSE )
  ENDIF
  divisorI = divisorI + 2
 ENDWHILE
 Return( TRUE )
END

INTEGER PROC IsRepunitFactor( INTEGER primeI )
 INTEGER modulusI = 0
 //
 IF primeI == 2
  Return( FALSE )
 ENDIF
 IF primeI == 3
  Return( FALSE )
 ENDIF
 IF primeI == 5
  Return( FALSE )
 ENDIF
 modulusI = 9 * primeI
 IF PowMod( 10, 1000000000, modulusI ) == 1
  Return( TRUE )
 ENDIF
 Return( FALSE )
END

STRING PROC SolveProblem132()
 INTEGER foundCountI = 0
 INTEGER candidateI = 0
 INTEGER sumI = 0
 STRING resultS[255] = ""
 //
 foundCountI = 0
 candidateI = 2
 sumI = 0
 WHILE foundCountI < 40
  IF IsPrime( candidateI )
   IF IsRepunitFactor( candidateI )
    sumI = sumI + candidateI
    foundCountI = foundCountI + 1
   ENDIF
  ENDIF
  IF candidateI == 2
   candidateI = 3
  ELSE
   candidateI = candidateI + 2
  ENDIF
 ENDWHILE
 resultS = Str( sumI )
 Return( resultS )
END

PROC Main()
 STRING answerS[255] = ""
 STRING historyS[255] = ""
 //
 historyS = "LLM: ChatGPT GPT-5.4 Thinking"
 answerS = SolveProblem132()
 AddHistoryStr( historyS, _EDIT_HISTORY_ )
 CopyToWinClip( answerS )
 Warn( "Project Euler 132 answer: " + answerS )
END
