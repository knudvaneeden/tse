/*
  Project Euler problem 306
  Paper-strip Game
  <version>1</version>

  History:
    Created by ChatGPT.
    Pure TSE SAL solver for Project Euler problem 306.

  Mathematical basis:
    The losing strip lengths begin as:
      1, 5, 9, 15, 21, 25, 29, 35, 39, 43, 55, 59, 63, 73
    and thereafter each new losing length is 34 more than the one 5 places earlier.

  Therefore:
    winningCount = LIMIT_N - losingCount
*/

#DEFINE LIMIT_N 1000000
#DEFINE STEP_K  34

INTEGER PROC FNCountLosingI( INTEGER limitI )
  INTEGER losingCountI = 0
  INTEGER continueB = TRUE
  INTEGER nextLosingI = 0
  INTEGER window1I = 43
  INTEGER window2I = 55
  INTEGER window3I = 59
  INTEGER window4I = 63
  INTEGER window5I = 73
  //
  IF limitI >= 1
    losingCountI = losingCountI + 1
  ENDIF
  IF limitI >= 5
    losingCountI = losingCountI + 1
  ENDIF
  IF limitI >= 9
    losingCountI = losingCountI + 1
  ENDIF
  IF limitI >= 15
    losingCountI = losingCountI + 1
  ENDIF
  IF limitI >= 21
    losingCountI = losingCountI + 1
  ENDIF
  IF limitI >= 25
    losingCountI = losingCountI + 1
  ENDIF
  IF limitI >= 29
    losingCountI = losingCountI + 1
  ENDIF
  IF limitI >= 35
    losingCountI = losingCountI + 1
  ENDIF
  IF limitI >= 39
    losingCountI = losingCountI + 1
  ENDIF
  IF limitI >= 43
    losingCountI = losingCountI + 1
  ENDIF
  IF limitI >= 55
    losingCountI = losingCountI + 1
  ENDIF
  IF limitI >= 59
    losingCountI = losingCountI + 1
  ENDIF
  IF limitI >= 63
    losingCountI = losingCountI + 1
  ENDIF
  IF limitI >= 73
    losingCountI = losingCountI + 1
  ENDIF
  //
  WHILE continueB
    nextLosingI = window1I + STEP_K
    IF nextLosingI <= limitI
      losingCountI = losingCountI + 1
      window1I = window2I
      window2I = window3I
      window3I = window4I
      window4I = window5I
      window5I = nextLosingI
    ELSE
      continueB = FALSE
    ENDIF
  ENDWHILE
  //
  RETURN( losingCountI )
END

INTEGER PROC FNCountWinningI( INTEGER limitI )
  //
  RETURN( limitI - FNCountLosingI( limitI ) )
END

PROC Main()
  INTEGER limitI = LIMIT_N
  INTEGER answerI = 0
  STRING answerS[255] = ""
  //
  answerI = FNCountWinningI( limitI )
  answerS = Format( answerI )
  CopyToWinClip( answerS )
  Warn( answerS )
  CopyToWinClip( answerS )
END
