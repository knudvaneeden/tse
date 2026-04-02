/*
  Euler Project 242
  Pure TSE SAL solution
  <version>1</version>

  History:
  - Created by ChatGPT GPT-5.4 Thinking
  - Solves Project Euler problem 242 in pure TSE SAL
  - Uses decimal-string arithmetic because TSE SAL integers are 32-bit
*/

integer gDecRemainderI = 0

string proc ProcTrimLeadingZeros( string numberS )
  string workS[255] = ""
  integer indexI = 0
  integer lengthI = 0
  integer startedB = FALSE
  string chS[2] = ""
  //
  workS = numberS
  lengthI = Length( workS )
  FOR indexI = 1 TO lengthI
    chS = SubStr( workS, indexI, 1 )
    IF startedB
      workS = SubStr( workS, indexI, 255 )
      RETURN( workS )
    ENDIF
    IF NOT ( chS == "0" )
      workS = SubStr( workS, indexI, 255 )
      RETURN( workS )
    ENDIF
  ENDFOR
  RETURN( "0" )
END

string proc ProcDecSubOne( string numberS )
  string workS[255] = ""
  string resultS[255] = ""
  string chS[2] = ""
  integer indexI = 0
  integer digitI = 0
  integer borrowI = 1
  integer newDigitI = 0
  //
  workS = numberS
  FOR indexI = Length( workS ) DOWNTO 1
    chS = SubStr( workS, indexI, 1 )
    digitI = Asc( chS ) - 48
    IF borrowI == 1
      IF digitI == 0
        newDigitI = 9
        borrowI = 1
      ELSE
        newDigitI = digitI - 1
        borrowI = 0
      ENDIF
    ELSE
      newDigitI = digitI
    ENDIF
    resultS = Chr( newDigitI + 48 ) + resultS
  ENDFOR
  resultS = ProcTrimLeadingZeros( resultS )
  RETURN( resultS )
END

string proc ProcDecDivSmall( string numberS, integer divisorI )
  string workS[255] = ""
  string quotientS[255] = ""
  string chS[2] = ""
  integer indexI = 0
  integer digitI = 0
  integer carryI = 0
  integer quotientDigitI = 0
  integer startedB = FALSE
  //
  workS = numberS
  quotientS = ""
  carryI = 0
  FOR indexI = 1 TO Length( workS )
    chS = SubStr( workS, indexI, 1 )
    digitI = Asc( chS ) - 48
    carryI = carryI * 10 + digitI
    quotientDigitI = carryI / divisorI
    carryI = carryI mod divisorI
    IF startedB
      quotientS = quotientS + Chr( quotientDigitI + 48 )
    ELSE
      IF NOT ( quotientDigitI == 0 )
        quotientS = quotientS + Chr( quotientDigitI + 48 )
        startedB = TRUE
      ENDIF
    ENDIF
  ENDFOR
  IF quotientS == ""
    quotientS = "0"
  ENDIF
  gDecRemainderI = carryI
  RETURN( quotientS )
END

string proc ProcBigAdd( string leftS, string rightS )
  string aS[255] = ""
  string bS[255] = ""
  string resultS[255] = ""
  string chS[2] = ""
  integer indexAI = 0
  integer indexBI = 0
  integer digitAI = 0
  integer digitBI = 0
  integer sumI = 0
  integer carryI = 0
  integer outDigitI = 0
  //
  aS = leftS
  bS = rightS
  resultS = ""
  indexAI = Length( aS )
  indexBI = Length( bS )
  carryI = 0
  WHILE ( indexAI >= 1 ) OR ( indexBI >= 1 ) OR ( carryI > 0 )
    digitAI = 0
    digitBI = 0
    IF indexAI >= 1
      chS = SubStr( aS, indexAI, 1 )
      digitAI = Asc( chS ) - 48
      indexAI = indexAI - 1
    ENDIF
    IF indexBI >= 1
      chS = SubStr( bS, indexBI, 1 )
      digitBI = Asc( chS ) - 48
      indexBI = indexBI - 1
    ENDIF
    sumI = digitAI + digitBI + carryI
    outDigitI = sumI mod 10
    carryI = sumI / 10
    resultS = Chr( outDigitI + 48 ) + resultS
  ENDWHILE
  resultS = ProcTrimLeadingZeros( resultS )
  RETURN( resultS )
END

string proc ProcBigMulSmall( string numberS, integer factorI )
  string workS[255] = ""
  string resultS[255] = ""
  string chS[2] = ""
  integer indexI = 0
  integer digitI = 0
  integer productI = 0
  integer carryI = 0
  integer outDigitI = 0
  //
  IF numberS == "0"
    RETURN( "0" )
  ENDIF
  workS = numberS
  resultS = ""
  carryI = 0
  FOR indexI = Length( workS ) DOWNTO 1
    chS = SubStr( workS, indexI, 1 )
    digitI = Asc( chS ) - 48
    productI = digitI * factorI + carryI
    outDigitI = productI mod 10
    carryI = productI / 10
    resultS = Chr( outDigitI + 48 ) + resultS
  ENDFOR
  WHILE carryI > 0
    outDigitI = carryI mod 10
    carryI = carryI / 10
    resultS = Chr( outDigitI + 48 ) + resultS
  ENDWHILE
  resultS = ProcTrimLeadingZeros( resultS )
  RETURN( resultS )
END

string proc ProcPow3( integer exponentI )
  string resultS[255] = ""
  integer indexI = 0
  //
  resultS = "1"
  FOR indexI = 1 TO exponentI
    resultS = ProcBigMulSmall( resultS, 3 )
  ENDFOR
  RETURN( resultS )
END

string proc ProcPow2( integer exponentI )
  string resultS[255] = ""
  integer indexI = 0
  //
  resultS = "1"
  FOR indexI = 1 TO exponentI
    resultS = ProcBigMulSmall( resultS, 2 )
  ENDFOR
  RETURN( resultS )
END

string proc ProcBuildBitsFromDecimal( string numberS )
  string workS[255] = ""
  string bitsS[255] = ""
  //
  workS = ProcTrimLeadingZeros( numberS )
  bitsS = ""
  IF workS == "0"
    RETURN( "0" )
  ENDIF
  WHILE NOT ( workS == "0" )
    workS = ProcDecDivSmall( workS, 2 )
    bitsS = Chr( gDecRemainderI + 48 ) + bitsS
  ENDWHILE
  RETURN( bitsS )
END

string proc ProcSolveEuler242()
  string limitS[255] = ""
  string minusOneS[255] = ""
  string quarterS[255] = ""
  string bitsS[255] = ""
  string answerS[255] = ""
  string termS[255] = ""
  integer bitIndexI = 0
  integer stringIndexI = 0
  integer onesCountI = 0
  integer repeatI = 0
  string chS[2] = ""
  //
  limitS = "1000000000000"
  minusOneS = ProcDecSubOne( limitS )
  quarterS = ProcDecDivSmall( minusOneS, 4 )
  bitsS = ProcBuildBitsFromDecimal( quarterS )
  answerS = "0"
  onesCountI = 0
  FOR stringIndexI = 1 TO Length( bitsS )
    chS = SubStr( bitsS, stringIndexI, 1 )
    bitIndexI = Length( bitsS ) - stringIndexI
    IF chS == "1"
      termS = ProcPow3( bitIndexI )
      FOR repeatI = 1 TO onesCountI
        termS = ProcBigMulSmall( termS, 2 )
      ENDFOR
      answerS = ProcBigAdd( answerS, termS )
      onesCountI = onesCountI + 1
    ENDIF
  ENDFOR
  answerS = ProcBigAdd( answerS, ProcPow2( onesCountI ) )
  RETURN( answerS )
END

PROC Main()
  string answerS[255] = ""
  //
  answerS = ProcSolveEuler242()
  CopyToWinClip( answerS )
  Warn( answerS )
  CopyToWinClip( answerS )
END
