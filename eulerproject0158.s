/*
  Euler Project 158 for The Semware Editor Professional SAL
  <version>1.0.0.0.0</version>

  RULE CHECK APPLIED:
  - Pure TSE SAL only
  - No external tools, no Python, no DLLs
  - Final answer is calculated, not hardcoded into the algorithm
  - Only one final Warn() box
  - Two CopyToWinClip() calls: before and after Warn()
  - Return() always uses parentheses
  - No own variables named val or pos
  - Forward declarations included
  - Variable declarations placed immediately after proc headers
  - String variables always have explicit sizes
  - Final result also shown in this source file

  Mathematical idea:
  p(n) = C(26,n) * A(n,1)
  where A(n,1) is the number of permutations of n distinct items
  with exactly one ascent.
  Recurrence used:
    A(1,1) = 0
    A(n,1) = 2 * A(n - 1, 1) + (n - 1)

  Expected computed result:
    Maximum p(n) = 409511334375
    Reached at n = 18

  History:
  1.0.0.0.0  2026-03-22
             Created by ChatGPT GPT-5.4 Thinking
*/

FORWARD STRING PROC ProcTrimLeadingZeros( STRING numberS )
FORWARD STRING PROC ProcIntegerToString( INTEGER numberI )
FORWARD STRING PROC ProcBigMultiplySmall( STRING numberS, INTEGER factorI )
FORWARD INTEGER PROC ProcBigCompare( STRING leftS, STRING rightS )

STRING PROC ProcTrimLeadingZeros( STRING numberS )
  STRING workS[255] = ""
  INTEGER indexI = 0
  INTEGER lengthI = 0
  STRING oneCharS[1] = ""

  workS = numberS
  lengthI = Length( workS )

  IF lengthI == 0
    Return( "0" )
  ENDIF

  indexI = 1
  WHILE indexI < lengthI
    oneCharS = SubStr( workS, indexI, 1 )
    IF oneCharS == "0"
      indexI = indexI + 1
    ELSE
      BREAK
    ENDIF
  ENDWHILE

  workS = SubStr( workS, indexI, Length( workS ) - indexI + 1 )

  IF Length( workS ) == 0
    workS = "0"
  ENDIF

  Return( workS )
END

STRING PROC ProcIntegerToString( INTEGER numberI )
  STRING resultS[255] = ""
  INTEGER workI = 0
  INTEGER digitI = 0

  workI = numberI

  IF workI == 0
    Return( "0" )
  ENDIF

  WHILE workI > 0
    digitI = workI mod 10
    resultS = Chr( 48 + digitI ) + resultS
    workI = workI / 10
  ENDWHILE

  Return( resultS )
END

STRING PROC ProcBigMultiplySmall( STRING numberS, INTEGER factorI )
  STRING cleanS[255] = ""
  STRING resultS[255] = ""
  STRING oneCharS[1] = ""
  INTEGER indexI = 0
  INTEGER digitI = 0
  INTEGER carryI = 0
  INTEGER productI = 0
  INTEGER remainderI = 0

  cleanS = ProcTrimLeadingZeros( numberS )

  IF factorI == 0
    Return( "0" )
  ENDIF

  IF cleanS == "0"
    Return( "0" )
  ENDIF

  FOR indexI = Length( cleanS ) DOWNTO 1
    oneCharS = SubStr( cleanS, indexI, 1 )
    digitI = Val( oneCharS )
    productI = digitI * factorI + carryI
    remainderI = productI mod 10
    carryI = productI / 10
    resultS = Chr( 48 + remainderI ) + resultS
  ENDFOR

  WHILE carryI > 0
    remainderI = carryI mod 10
    resultS = Chr( 48 + remainderI ) + resultS
    carryI = carryI / 10
  ENDWHILE

  Return( ProcTrimLeadingZeros( resultS ) )
END

INTEGER PROC ProcBigCompare( STRING leftS, STRING rightS )
  STRING cleanLeftS[255] = ""
  STRING cleanRightS[255] = ""
  INTEGER lengthLeftI = 0
  INTEGER lengthRightI = 0
  INTEGER indexI = 0
  STRING leftCharS[1] = ""
  STRING rightCharS[1] = ""

  cleanLeftS = ProcTrimLeadingZeros( leftS )
  cleanRightS = ProcTrimLeadingZeros( rightS )

  lengthLeftI = Length( cleanLeftS )
  lengthRightI = Length( cleanRightS )

  IF lengthLeftI > lengthRightI
    Return( 1 )
  ENDIF

  IF lengthLeftI < lengthRightI
    Return( -1 )
  ENDIF

  FOR indexI = 1 TO lengthLeftI
    leftCharS = SubStr( cleanLeftS, indexI, 1 )
    rightCharS = SubStr( cleanRightS, indexI, 1 )

    IF leftCharS > rightCharS
      Return( 1 )
    ENDIF

    IF leftCharS < rightCharS
      Return( -1 )
    ENDIF
  ENDFOR

  Return( 0 )
END

PROC Main()
  INTEGER nI = 0
  INTEGER chooseI = 1
  INTEGER ascentsOneI = 0
  STRING currentPS[255] = "0"
  STRING maxPS[255] = "0"
  INTEGER maxNI = 0
  STRING resultS[255] = ""

  FOR nI = 1 TO 26

    IF nI == 1
      chooseI = 26
      ascentsOneI = 0
    ELSE
      chooseI = ( chooseI * ( 26 - nI + 1 ) ) / nI
      ascentsOneI = 2 * ascentsOneI + ( nI - 1 )
    ENDIF

    currentPS = ProcBigMultiplySmall( ProcIntegerToString( chooseI ), ascentsOneI )

    IF ProcBigCompare( currentPS, maxPS ) > 0
      maxPS = currentPS
      maxNI = nI
    ENDIF

  ENDFOR

  resultS = maxPS
  CopyToWinClip( resultS )
  Warn( "Euler Project 158" + Chr( 13 ) +
        "maximum p(n) = " + resultS + Chr( 13 ) +
        "attained at n = " + ProcIntegerToString( maxNI ) )
  CopyToWinClip( resultS )
END
