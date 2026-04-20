// Project Euler problem 299
// URL: https://projecteuler.net/problem=299
// History:
// ChatGPT created this pure TSE SAL program.
#DEFINE VERSION_NUMBER 1
#DEFINE LIMIT_N 100000000
INTEGER PROC FNGreatestCommonDivisorI( INTEGER firstValueI, INTEGER secondValueI )
  INTEGER leftValueI = firstValueI
  INTEGER rightValueI = secondValueI
  INTEGER remainderI = 0
  IF leftValueI < 0
    leftValueI = -leftValueI
  ENDIF
  IF rightValueI < 0
    rightValueI = -rightValueI
  ENDIF
  WHILE rightValueI > 0
    remainderI = leftValueI mod rightValueI
    leftValueI = rightValueI
    rightValueI = remainderI
  ENDWHILE
  RETURN( leftValueI )
END
INTEGER PROC FNCountIncenterFamilyI( INTEGER limitI )
  INTEGER totalCountI = 0
  INTEGER mValueI = 2
  INTEGER startNValueI = 0
  INTEGER nValueI = 0
  INTEGER perimeterI = 0
  INTEGER multipleCountI = 0
  WHILE ( mValueI * mValueI + 2 * mValueI - 1 ) < limitI
    IF ( mValueI mod 2 ) == 0
      startNValueI = 1
    ELSE
      startNValueI = 2
    ENDIF
    FOR nValueI = startNValueI TO mValueI - 1 BY 2
      IF FNGreatestCommonDivisorI( mValueI, nValueI ) == 1
        perimeterI = mValueI * mValueI + 2 * mValueI * nValueI - nValueI * nValueI
        IF perimeterI < limitI
          multipleCountI = ( limitI - 1 ) / perimeterI
          totalCountI = totalCountI + 2 * multipleCountI
        ENDIF
      ENDIF
    ENDFOR
    mValueI = mValueI + 1
  ENDWHILE
  RETURN( totalCountI )
END
INTEGER PROC FNCountParallelFamilyI( INTEGER limitI )
  INTEGER totalCountI = 0
  INTEGER uValueI = 1
  INTEGER vValueI = 0
  INTEGER baseValueI = 0
  INTEGER multipleCountI = 0
  WHILE ( 2 * ( uValueI * uValueI + 2 + 2 * uValueI ) ) < limitI
    vValueI = 1
    WHILE TRUE
      baseValueI = uValueI * uValueI + 2 * vValueI * vValueI + 2 * uValueI * vValueI
      IF ( 2 * baseValueI ) < limitI
        IF FNGreatestCommonDivisorI( uValueI, vValueI ) == 1
          multipleCountI = ( limitI - 1 ) / ( 2 * baseValueI )
          totalCountI = totalCountI + multipleCountI
        ENDIF
        vValueI = vValueI + 1
      ELSE
        BREAK
      ENDIF
    ENDWHILE
    uValueI = uValueI + 2
  ENDWHILE
  RETURN( totalCountI )
END
INTEGER PROC FNSolveI( INTEGER limitI )
  INTEGER answerI = 0
  answerI = FNCountIncenterFamilyI( limitI ) + FNCountParallelFamilyI( limitI )
  RETURN( answerI )
END
PROC Main()
  INTEGER answerI = 0
  STRING answerS[255] = ""
  answerI = FNSolveI( LIMIT_N )
  answerS = Format( answerI )
  CopyToWinClip( answerS )
  Warn( answerS )
  CopyToWinClip( answerS )
END
