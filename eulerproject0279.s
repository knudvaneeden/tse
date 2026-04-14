// Project Euler problem 279
// Triangles with Integral Sides and an Integral Angle
// Version: 1
// History: 1 = ChatGPT
// Rule check applied:
// - Pure TSE SAL only
// - No own variables named val or pos
// - All RETURN() use parentheses
// - Exactly one final Warn() box
// - CopyToWinClip() before and after final Warn()
// - Only final result shown in Warn()
// - Version number included once
//
#define LIMIT_279 100000000
INTEGER gFactorCountGI = 0
INTEGER gFactor1GI = 0
INTEGER gFactor2GI = 0
INTEGER gFactor3GI = 0
INTEGER gFactor4GI = 0
INTEGER gFactor5GI = 0
PROC ProcClearFactors()
  gFactorCountGI = 0
  gFactor1GI = 0
  gFactor2GI = 0
  gFactor3GI = 0
  gFactor4GI = 0
  gFactor5GI = 0
END
PROC ProcAppendFactor( INTEGER factorI )
  gFactorCountGI = gFactorCountGI + 1
  CASE gFactorCountGI
    WHEN 1
      gFactor1GI = factorI
    WHEN 2
      gFactor2GI = factorI
    WHEN 3
      gFactor3GI = factorI
    WHEN 4
      gFactor4GI = factorI
    WHEN 5
      gFactor5GI = factorI
  ENDCASE
END
PROC ProcFactorDistinct( INTEGER numberI )
  INTEGER remainderI = numberI
  INTEGER divisorI = 0
  ProcClearFactors()
  IF remainderI mod 2 == 0
    ProcAppendFactor( 2 )
    WHILE remainderI mod 2 == 0
      remainderI = remainderI / 2
    ENDWHILE
  ENDIF
  divisorI = 3
  WHILE divisorI <= remainderI / divisorI
    IF remainderI mod divisorI == 0
      ProcAppendFactor( divisorI )
      WHILE remainderI mod divisorI == 0
        remainderI = remainderI / divisorI
      ENDWHILE
    ENDIF
    divisorI = divisorI + 2
  ENDWHILE
  IF remainderI > 1
    ProcAppendFactor( remainderI )
  ENDIF
END
INTEGER PROC ProcIsCoprimeWithCurrentFactors( INTEGER numberI )
  IF gFactorCountGI >= 1
    IF numberI mod gFactor1GI == 0
      RETURN( FALSE )
    ENDIF
  ENDIF
  IF gFactorCountGI >= 2
    IF numberI mod gFactor2GI == 0
      RETURN( FALSE )
    ENDIF
  ENDIF
  IF gFactorCountGI >= 3
    IF numberI mod gFactor3GI == 0
      RETURN( FALSE )
    ENDIF
  ENDIF
  IF gFactorCountGI >= 4
    IF numberI mod gFactor4GI == 0
      RETURN( FALSE )
    ENDIF
  ENDIF
  IF gFactorCountGI >= 5
    IF numberI mod gFactor5GI == 0
      RETURN( FALSE )
    ENDIF
  ENDIF
  RETURN( TRUE )
END
INTEGER PROC ProcIntegerSqrt( INTEGER numberI )
  INTEGER lowI = 0
  INTEGER highI = 46340
  INTEGER midI = 0
  INTEGER answerI = 0
  WHILE lowI <= highI
    midI = ( lowI + highI ) / 2
    IF midI == 0
      answerI = 0
      lowI = 1
    ELSE
      IF midI <= numberI / midI
        answerI = midI
        lowI = midI + 1
      ELSE
        highI = midI - 1
      ENDIF
    ENDIF
  ENDWHILE
  RETURN( answerI )
END
INTEGER PROC ProcCount90( INTEGER limitI )
  INTEGER limitHalfI = limitI / 2
  INTEGER lastI = ProcIntegerSqrt( limitHalfI ) + 2
  INTEGER resultI = 0
  INTEGER mI = 0
  INTEGER nI = 0
  INTEGER startN_I = 0
  INTEGER mmI = 0
  INTEGER mnI = 0
  INTEGER perimeterI = 0
  FOR mI = 2 TO lastI
    ProcFactorDistinct( mI )
    mmI = mI * mI
    startN_I = ( mI mod 2 ) + 1
    FOR nI = startN_I TO mI - 1 BY 2
      mnI = mI * nI
      perimeterI = 2 * ( mmI + mnI )
      IF perimeterI > limitI
        BREAK
      ENDIF
      IF ProcIsCoprimeWithCurrentFactors( nI )
        resultI = resultI + ( limitI / perimeterI )
      ENDIF
    ENDFOR
  ENDFOR
  RETURN( resultI )
END
INTEGER PROC ProcCount60And120( INTEGER limitI )
  INTEGER limitTimes3I = limitI * 3
  INTEGER lastI = ProcIntegerSqrt( ( limitI * 3 ) / 2 ) + 2
  INTEGER resultI = 0
  INTEGER mI = 0
  INTEGER nI = 0
  INTEGER halfI = 0
  INTEGER mmI = 0
  INTEGER twoMmI = 0
  INTEGER mnI = 0
  INTEGER nnI = 0
  INTEGER raw60I = 0
  INTEGER primitive60I = 0
  INTEGER raw120I = 0
  INTEGER primitive120I = 0
  INTEGER sideB120I = 0
  INTEGER sideC120I = 0
  INTEGER active120I = FALSE
  FOR mI = 2 TO lastI
    ProcFactorDistinct( mI )
    mmI = mI * mI
    twoMmI = 2 * mmI
    halfI = mI / 2
    active120I = TRUE
    FOR nI = 1 TO halfI
      mnI = mI * nI
      nnI = nI * nI
      raw60I = twoMmI + mnI - nnI
      IF raw60I > limitTimes3I
        BREAK
      ENDIF
      IF active120I
        sideB120I = ( 2 * mnI ) + nnI
        sideC120I = mmI - nnI
        IF sideB120I > sideC120I
          active120I = FALSE
        ELSE
          raw120I = twoMmI + ( 3 * mnI ) + nnI
          IF raw120I > limitTimes3I
            active120I = FALSE
          ENDIF
        ENDIF
      ENDIF
      IF ProcIsCoprimeWithCurrentFactors( nI )
        IF ( ( mI + nI ) mod 3 ) == 0
          primitive60I = raw60I / 3
        ELSE
          primitive60I = raw60I
        ENDIF
        IF primitive60I <= limitI
          resultI = resultI + ( limitI / primitive60I )
        ENDIF
        IF active120I
          IF ( ( mI - nI ) mod 3 ) == 0
            primitive120I = raw120I / 3
          ELSE
            primitive120I = raw120I
          ENDIF
          resultI = resultI + ( limitI / primitive120I )
        ENDIF
      ENDIF
    ENDFOR
  ENDFOR
  RETURN( resultI )
END
PROC Main()
  INTEGER limitI = LIMIT_279
  INTEGER count90I = 0
  INTEGER count60And120I = 0
  INTEGER totalI = 0
  STRING answerS[255] = ''
  count90I = ProcCount90( limitI )
  count60And120I = ProcCount60And120( limitI )
  totalI = count90I + count60And120I
  answerS = Format( totalI )
  CopyToWinClip( answerS )
  Warn( answerS )
  CopyToWinClip( answerS )
END
