/*
  Euler Project 160
  Factorial trailing digits
  Pure TSE SAL solution
  <version>1.0.0.0.1</version>

  This program computes:
  f(1000000000000) = last five digits before trailing zeroes of 1000000000000!

  Final result produced by this program:
  16576

  History:
  - Created by GPT-5.4 Thinking (ChatGPT)
*/

#DEFINE MODULUS_100000      100000
#DEFINE POWER_CYCLE_2500    2500

FORWARD STRING  PROC ProcTrimLeadingZeros( STRING numberS )
FORWARD INTEGER PROC ProcIsZeroDecimalString( STRING numberS )
FORWARD STRING  PROC ProcDivideDecimalStringBySmallInt( STRING numberS, INTEGER divisorI )
FORWARD INTEGER PROC ProcModuloDecimalStringBySmallInt( STRING numberS, INTEGER divisorI )
FORWARD INTEGER PROC ProcMultiplyMod100000( INTEGER leftI, INTEGER rightI )
FORWARD INTEGER PROC ProcPowMod100000( INTEGER baseI, INTEGER exponentI )
FORWARD INTEGER PROC ProcCountFactorsModuloCycle( STRING numberS, INTEGER factorI, INTEGER modulusI )
FORWARD INTEGER PROC ProcFactorialCoprime( STRING numberS )
FORWARD INTEGER PROC ProcOddFactorialish( STRING numberS )
FORWARD INTEGER PROC ProcEvenFactorialish( STRING numberS )
FORWARD INTEGER PROC ProcFactorialish( STRING numberS )

STRING PROC ProcTrimLeadingZeros( STRING numberS )
  INTEGER indexI = 1
  INTEGER lengthI = 0
  STRING workS[255] = ""
  STRING resultS[255] = ""
  //
  workS = numberS
  lengthI = Length( workS )
  WHILE indexI < lengthI AND SubStr( workS, indexI, 1 ) == "0"
    indexI = indexI + 1
  ENDWHILE
  resultS = SubStr( workS, indexI, lengthI - indexI + 1 )
  IF resultS == ""
    resultS = "0"
  ENDIF
  RETURN( resultS )
END

INTEGER PROC ProcIsZeroDecimalString( STRING numberS )
  STRING trimmedS[255] = ""
  //
  trimmedS = ProcTrimLeadingZeros( numberS )
  RETURN( trimmedS == "0" )
END

STRING PROC ProcDivideDecimalStringBySmallInt( STRING numberS, INTEGER divisorI )
  INTEGER indexI = 0
  INTEGER lengthI = 0
  INTEGER digitI = 0
  INTEGER workI = 0
  INTEGER quotientDigitI = 0
  INTEGER remainderI = 0
  INTEGER startedB = FALSE
  STRING resultS[255] = ""
  STRING inputS[255] = ""
  //
  inputS = ProcTrimLeadingZeros( numberS )
  lengthI = Length( inputS )
  FOR indexI = 1 TO lengthI
    digitI = Asc( SubStr( inputS, indexI, 1 ) ) - 48
    workI = remainderI * 10 + digitI
    quotientDigitI = workI / divisorI
    remainderI = workI mod divisorI
    IF startedB OR quotientDigitI > 0
      resultS = resultS + Chr( quotientDigitI + 48 )
      startedB = TRUE
    ENDIF
  ENDFOR
  IF NOT startedB
    resultS = "0"
  ENDIF
  RETURN( resultS )
END

INTEGER PROC ProcModuloDecimalStringBySmallInt( STRING numberS, INTEGER divisorI )
  INTEGER indexI = 0
  INTEGER lengthI = 0
  INTEGER digitI = 0
  INTEGER remainderI = 0
  STRING inputS[255] = ""
  //
  inputS = ProcTrimLeadingZeros( numberS )
  lengthI = Length( inputS )
  FOR indexI = 1 TO lengthI
    digitI = Asc( SubStr( inputS, indexI, 1 ) ) - 48
    remainderI = ( remainderI * 10 + digitI ) mod divisorI
  ENDFOR
  RETURN( remainderI )
END

INTEGER PROC ProcMultiplyMod100000( INTEGER leftI, INTEGER rightI )
  INTEGER leftHighI = 0
  INTEGER leftLowI = 0
  INTEGER rightHighI = 0
  INTEGER rightLowI = 0
  INTEGER part1I = 0
  INTEGER part2I = 0
  INTEGER part3I = 0
  INTEGER resultI = 0
  INTEGER leftWorkI = 0
  INTEGER rightWorkI = 0
  //
  leftWorkI = leftI mod MODULUS_100000
  rightWorkI = rightI mod MODULUS_100000
  leftHighI = leftWorkI / 100
  leftLowI = leftWorkI mod 100
  rightHighI = rightWorkI / 100
  rightLowI = rightWorkI mod 100
  part1I = ( ( leftHighI * rightHighI ) mod 10 ) * 10000
  part2I = ( ( leftHighI * rightLowI ) + ( rightHighI * leftLowI ) ) mod 1000
  part2I = part2I * 100
  part3I = leftLowI * rightLowI
  resultI = ( part1I + part2I + part3I ) mod MODULUS_100000
  RETURN( resultI )
END

INTEGER PROC ProcPowMod100000( INTEGER baseI, INTEGER exponentI )
  INTEGER resultI = 1
  INTEGER currentBaseI = 0
  INTEGER currentExponentI = 0
  //
  currentBaseI = baseI mod MODULUS_100000
  currentExponentI = exponentI
  WHILE currentExponentI > 0
    IF currentExponentI mod 2 == 1
      resultI = ProcMultiplyMod100000( resultI, currentBaseI )
    ENDIF
    currentExponentI = currentExponentI / 2
    IF currentExponentI > 0
      currentBaseI = ProcMultiplyMod100000( currentBaseI, currentBaseI )
    ENDIF
  ENDWHILE
  RETURN( resultI )
END

INTEGER PROC ProcCountFactorsModuloCycle( STRING numberS, INTEGER factorI, INTEGER modulusI )
  INTEGER sumI = 0
  INTEGER quotientModI = 0
  STRING currentS[255] = ""
  //
  currentS = ProcTrimLeadingZeros( numberS )
  WHILE TRUE
    currentS = ProcDivideDecimalStringBySmallInt( currentS, factorI )
    IF ProcIsZeroDecimalString( currentS )
      BREAK
    ENDIF
    quotientModI = ProcModuloDecimalStringBySmallInt( currentS, modulusI )
    sumI = ( sumI + quotientModI ) mod modulusI
  ENDWHILE
  RETURN( sumI )
END

INTEGER PROC ProcFactorialCoprime( STRING numberS )
  INTEGER limitI = 0
  INTEGER factorI = 1
  INTEGER productI = 1
  //
  limitI = ProcModuloDecimalStringBySmallInt( numberS, MODULUS_100000 )
  factorI = 1
  WHILE factorI <= limitI
    IF NOT( factorI mod 5 == 0 )
      productI = ProcMultiplyMod100000( productI, factorI )
    ENDIF
    factorI = factorI + 2
  ENDWHILE
  RETURN( productI )
END

INTEGER PROC ProcOddFactorialish( STRING numberS )
  STRING quotientS[255] = ""
  INTEGER recursivePartI = 0
  INTEGER currentPartI = 0
  //
  IF ProcIsZeroDecimalString( numberS )
    RETURN( 1 )
  ENDIF
  quotientS = ProcDivideDecimalStringBySmallInt( numberS, 5 )
  recursivePartI = ProcOddFactorialish( quotientS )
  currentPartI = ProcFactorialCoprime( numberS )
  RETURN( ProcMultiplyMod100000( recursivePartI, currentPartI ) )
END

INTEGER PROC ProcEvenFactorialish( STRING numberS )
  STRING quotientS[255] = ""
  //
  IF ProcIsZeroDecimalString( numberS )
    RETURN( 1 )
  ENDIF
  quotientS = ProcDivideDecimalStringBySmallInt( numberS, 2 )
  RETURN( ProcFactorialish( quotientS ) )
END

INTEGER PROC ProcFactorialish( STRING numberS )
  INTEGER evenPartI = 0
  INTEGER oddPartI = 0
  //
  IF ProcIsZeroDecimalString( numberS )
    RETURN( 1 )
  ENDIF
  evenPartI = ProcEvenFactorialish( numberS )
  oddPartI = ProcOddFactorialish( numberS )
  RETURN( ProcMultiplyMod100000( evenPartI, oddPartI ) )
END

PROC Main()
  STRING numberS[255] = "1000000000000"
  STRING resultS[255] = ""
  INTEGER count2ModI = 0
  INTEGER count5ModI = 0
  INTEGER twosDifferenceModI = 0
  INTEGER adjustedTwosExponentI = 0
  INTEGER factorialishI = 0
  INTEGER powerOfTwoI = 0
  INTEGER finalResultI = 0
  //
  count2ModI = ProcCountFactorsModuloCycle( numberS, 2, POWER_CYCLE_2500 )
  count5ModI = ProcCountFactorsModuloCycle( numberS, 5, POWER_CYCLE_2500 )

  twosDifferenceModI = count2ModI - count5ModI
  WHILE twosDifferenceModI < 0
    twosDifferenceModI = twosDifferenceModI + POWER_CYCLE_2500
  ENDWHILE
  twosDifferenceModI = twosDifferenceModI mod POWER_CYCLE_2500

  adjustedTwosExponentI = ( ( twosDifferenceModI + POWER_CYCLE_2500 - 5 ) mod POWER_CYCLE_2500 ) + 5

  factorialishI = ProcFactorialish( numberS )
  powerOfTwoI = ProcPowMod100000( 2, adjustedTwosExponentI )
  finalResultI = ProcMultiplyMod100000( factorialishI, powerOfTwoI )

  resultS = Format( finalResultI:5:"0" )

  CopyToWinClip( resultS )
  Warn( "Euler Project 160" + Chr( 13 ) +
        "f(1000000000000) = " + resultS )
  CopyToWinClip( resultS )
END
