// <version>1</version>
// History: Created by ChatGPT for Project Euler problem 294.
//
#DEFINE SUM_LIMIT          23
#DEFINE REM_COUNT          23
#DEFINE STATE_COUNT        552
#DEFINE MODULO_N           1000000000
#DEFINE SMALL_BASE         1000
#DEFINE CYCLE_LEN          22
#DEFINE EXTRA_LEN          11
//
FORWARD INTEGER PROC FNIndexI( INTEGER sumI, INTEGER remainderI )
FORWARD INTEGER PROC FNAddModI( INTEGER leftI, INTEGER rightI )
FORWARD INTEGER PROC FNSmallMulModI( INTEGER valueI, INTEGER factorI )
FORWARD INTEGER PROC FNMulModI( INTEGER leftI, INTEGER rightI )
FORWARD STRING  PROC FNTrimLeadingZerosS( STRING numberS )
FORWARD STRING  PROC FNMultiplyDecimalBySmallS( STRING numberS, INTEGER factorI )
FORWARD STRING  PROC FNSubtractSmallS( STRING numberS, INTEGER smallI )
FORWARD STRING  PROC FNDivideDecimalBySmallS( STRING numberS, INTEGER divisorI )
FORWARD INTEGER PROC FNIsZeroDecimalI( STRING numberS )
FORWARD INTEGER PROC FNIsOddDecimalI( STRING numberS )
FORWARD PROC    PROCInitBuffer( INTEGER bufferI, INTEGER countI )
FORWARD PROC    PROCZeroBuffer( INTEGER bufferI, INTEGER countI )
FORWARD INTEGER PROC FNGetBufferValueI( INTEGER bufferI, INTEGER lineI )
FORWARD PROC    PROCSetBufferValue( INTEGER bufferI, INTEGER lineI, INTEGER valueI )
FORWARD PROC    PROCAddBufferValueMod( INTEGER bufferI, INTEGER lineI, INTEGER addI )
FORWARD PROC    PROCCloneArrayBuffer( INTEGER sourceBufferI, INTEGER targetBufferI, INTEGER countI )
FORWARD PROC    PROCPrepareWeights( INTEGER weightsBufferI )
FORWARD PROC    PROCApplySingleWeight( INTEGER sourceBufferI, INTEGER targetBufferI, INTEGER weightI )
FORWARD PROC    PROCBuildCycleKernel( INTEGER weightsBufferI, INTEGER kernelZeroBufferI, INTEGER kernelNonZeroBufferI, INTEGER stateSourceBufferI, INTEGER stateTargetBufferI )
FORWARD PROC    PROCCombineKernels( INTEGER leftZeroBufferI, INTEGER leftNonZeroBufferI, INTEGER rightZeroBufferI, INTEGER rightNonZeroBufferI, INTEGER resultZeroBufferI, INTEGER resultNonZeroBufferI )
FORWARD PROC    PROCComputePoweredKernel( STRING exponentS, INTEGER baseZeroBufferI, INTEGER baseNonZeroBufferI, INTEGER resultZeroBufferI, INTEGER resultNonZeroBufferI, INTEGER tempZeroBufferI, INTEGER tempNonZeroBufferI )
FORWARD PROC    PROCBuildFullStateFromSymmetric( INTEGER symmetricZeroBufferI, INTEGER symmetricNonZeroBufferI, INTEGER stateBufferI )
//
INTEGER PROC FNIndexI( INTEGER sumI, INTEGER remainderI )
  RETURN( sumI * REM_COUNT + remainderI + 1 )
END
//
INTEGER PROC FNAddModI( INTEGER leftI, INTEGER rightI )
  INTEGER valueI = 0
  valueI = leftI + rightI
  IF valueI >= MODULO_N
    valueI = valueI - MODULO_N
  ENDIF
  RETURN( valueI )
END
//
INTEGER PROC FNSmallMulModI( INTEGER valueI, INTEGER factorI )
  INTEGER resultI = 0
  INTEGER countI  = 0
  FOR countI = 1 TO factorI
    resultI = FNAddModI( resultI, valueI )
  ENDFOR
  RETURN( resultI )
END
//
INTEGER PROC FNMulModI( INTEGER leftI, INTEGER rightI )
  INTEGER a0I    = 0
  INTEGER a1I    = 0
  INTEGER a2I    = 0
  INTEGER b0I    = 0
  INTEGER b1I    = 0
  INTEGER b2I    = 0
  INTEGER p0I    = 0
  INTEGER p1I    = 0
  INTEGER p2I    = 0
  INTEGER carryI = 0
  INTEGER d0I    = 0
  INTEGER d1I    = 0
  INTEGER d2I    = 0
  INTEGER resultI = 0
  a0I = leftI mod SMALL_BASE
  a1I = ( leftI / SMALL_BASE ) mod SMALL_BASE
  a2I = leftI / 1000000
  b0I = rightI mod SMALL_BASE
  b1I = ( rightI / SMALL_BASE ) mod SMALL_BASE
  b2I = rightI / 1000000
  p0I = a0I * b0I
  p1I = a0I * b1I + a1I * b0I
  p2I = a0I * b2I + a1I * b1I + a2I * b0I
  d0I = p0I mod SMALL_BASE
  carryI = p0I / SMALL_BASE
  p1I = p1I + carryI
  d1I = p1I mod SMALL_BASE
  carryI = p1I / SMALL_BASE
  p2I = p2I + carryI
  d2I = p2I mod SMALL_BASE
  resultI = d0I + d1I * SMALL_BASE + d2I * 1000000
  RETURN( resultI )
END
//
STRING PROC FNTrimLeadingZerosS( STRING numberS )
  INTEGER indexI    = 1
  INTEGER lengthI   = 0
  STRING  workS[255] = ''
  workS = numberS
  lengthI = Length( workS )
  WHILE indexI < lengthI AND SubStr( workS, indexI, 1 ) == '0'
    indexI = indexI + 1
  ENDWHILE
  RETURN( SubStr( workS, indexI, lengthI - indexI + 1 ) )
END
//
STRING PROC FNMultiplyDecimalBySmallS( STRING numberS, INTEGER factorI )
  INTEGER indexI    = 0
  INTEGER digitI    = 0
  INTEGER carryI    = 0
  INTEGER valueI    = 0
  STRING  resultS[255] = ''
  STRING  workS[255]   = ''
  workS = numberS
  FOR indexI = Length( workS ) DOWNTO 1
    digitI = Asc( SubStr( workS, indexI, 1 ) ) - 48
    valueI = digitI * factorI + carryI
    resultS = Chr( 48 + ( valueI mod 10 ) ) + resultS
    carryI = valueI / 10
  ENDFOR
  WHILE carryI > 0
    resultS = Chr( 48 + ( carryI mod 10 ) ) + resultS
    carryI = carryI / 10
  ENDWHILE
  RETURN( FNTrimLeadingZerosS( resultS ) )
END
//
STRING PROC FNSubtractSmallS( STRING numberS, INTEGER smallI )
  INTEGER numberIndexI = 0
  INTEGER smallIndexI  = 0
  INTEGER digitLeftI   = 0
  INTEGER digitRightI  = 0
  INTEGER borrowI      = 0
  INTEGER valueI       = 0
  STRING  resultS[255] = ''
  STRING  workS[255]   = ''
  STRING  smallS[255]  = ''
  workS = numberS
  smallS = Format( smallI )
  numberIndexI = Length( workS )
  smallIndexI = Length( smallS )
  WHILE numberIndexI > 0
    digitLeftI = Asc( SubStr( workS, numberIndexI, 1 ) ) - 48
    IF smallIndexI > 0
      digitRightI = Asc( SubStr( smallS, smallIndexI, 1 ) ) - 48
    ELSE
      digitRightI = 0
    ENDIF
    valueI = digitLeftI - digitRightI - borrowI
    IF valueI < 0
      valueI = valueI + 10
      borrowI = 1
    ELSE
      borrowI = 0
    ENDIF
    resultS = Chr( 48 + valueI ) + resultS
    numberIndexI = numberIndexI - 1
    smallIndexI = smallIndexI - 1
  ENDWHILE
  RETURN( FNTrimLeadingZerosS( resultS ) )
END
//
STRING PROC FNDivideDecimalBySmallS( STRING numberS, INTEGER divisorI )
  INTEGER indexI      = 0
  INTEGER digitI      = 0
  INTEGER valueI      = 0
  INTEGER remainderI  = 0
  INTEGER quotientI   = 0
  STRING  resultS[255] = ''
  STRING  workS[255]   = ''
  workS = numberS
  FOR indexI = 1 TO Length( workS )
    digitI = Asc( SubStr( workS, indexI, 1 ) ) - 48
    valueI = remainderI * 10 + digitI
    quotientI = valueI / divisorI
    remainderI = valueI mod divisorI
    IF Length( resultS ) > 0 OR quotientI > 0
      resultS = resultS + Chr( 48 + quotientI )
    ENDIF
  ENDFOR
  IF resultS == ''
    resultS = '0'
  ENDIF
  RETURN( FNTrimLeadingZerosS( resultS ) )
END
//
INTEGER PROC FNIsZeroDecimalI( STRING numberS )
  STRING workS[255] = ''
  workS = FNTrimLeadingZerosS( numberS )
  RETURN( workS == '0' )
END
//
INTEGER PROC FNIsOddDecimalI( STRING numberS )
  INTEGER digitI = 0
  STRING  workS[255] = ''
  workS = FNTrimLeadingZerosS( numberS )
  digitI = Asc( SubStr( workS, Length( workS ), 1 ) ) - 48
  RETURN( digitI mod 2 )
END
//
PROC PROCInitBuffer( INTEGER bufferI, INTEGER countI )
  INTEGER indexI = 0
  PushLocation()
  GotoBufferId( bufferI )
  FOR indexI = 1 TO countI
    AddLine( '0', bufferI )
  ENDFOR
  PopLocation()
END
//
PROC PROCZeroBuffer( INTEGER bufferI, INTEGER countI )
  INTEGER indexI = 0
  PushLocation()
  GotoBufferId( bufferI )
  FOR indexI = 1 TO countI
    GotoLine( indexI )
    BegLine()
    KillToEol()
    InsertText( '0' )
  ENDFOR
  PopLocation()
END
//
INTEGER PROC FNGetBufferValueI( INTEGER bufferI, INTEGER lineI )
  STRING valueS[255] = ''
  PushLocation()
  GotoBufferId( bufferI )
  GotoLine( lineI )
  valueS = GetText( 1, CurrLineLen() )
  PopLocation()
  RETURN( Val( valueS ) )
END
//
PROC PROCSetBufferValue( INTEGER bufferI, INTEGER lineI, INTEGER valueI )
  PushLocation()
  GotoBufferId( bufferI )
  GotoLine( lineI )
  BegLine()
  KillToEol()
  InsertText( Format( valueI ) )
  PopLocation()
END
//
PROC PROCAddBufferValueMod( INTEGER bufferI, INTEGER lineI, INTEGER addI )
  INTEGER currentI = 0
  STRING  valueS[255] = ''
  PushLocation()
  GotoBufferId( bufferI )
  GotoLine( lineI )
  valueS = GetText( 1, CurrLineLen() )
  currentI = Val( valueS )
  currentI = FNAddModI( currentI, addI )
  BegLine()
  KillToEol()
  InsertText( Format( currentI ) )
  PopLocation()
END
//
PROC PROCCloneArrayBuffer( INTEGER sourceBufferI, INTEGER targetBufferI, INTEGER countI )
  INTEGER indexI = 0
  INTEGER valueI = 0
  FOR indexI = 1 TO countI
    valueI = FNGetBufferValueI( sourceBufferI, indexI )
    PROCSetBufferValue( targetBufferI, indexI, valueI )
  ENDFOR
END
//
PROC PROCPrepareWeights( INTEGER weightsBufferI )
  INTEGER indexI  = 0
  INTEGER valueI  = 1
  PROCZeroBuffer( weightsBufferI, CYCLE_LEN )
  FOR indexI = 1 TO CYCLE_LEN
    PROCSetBufferValue( weightsBufferI, indexI, valueI )
    valueI = ( valueI * 10 ) mod 23
  ENDFOR
END
//
PROC PROCApplySingleWeight( INTEGER sourceBufferI, INTEGER targetBufferI, INTEGER weightI )
  INTEGER sumI          = 0
  INTEGER remainderI    = 0
  INTEGER digitI        = 0
  INTEGER maxDigitI     = 0
  INTEGER sourceValueI  = 0
  INTEGER targetSumI    = 0
  INTEGER targetRemI    = 0
  INTEGER targetLineI   = 0
  PROCZeroBuffer( targetBufferI, STATE_COUNT )
  FOR sumI = 0 TO SUM_LIMIT
    maxDigitI = SUM_LIMIT - sumI
    IF maxDigitI > 9
      maxDigitI = 9
    ENDIF
    FOR remainderI = 0 TO 22
      sourceValueI = FNGetBufferValueI( sourceBufferI, FNIndexI( sumI, remainderI ) )
      IF sourceValueI > 0
        FOR digitI = 0 TO maxDigitI
          targetSumI = sumI + digitI
          targetRemI = ( remainderI + digitI * weightI ) mod 23
          targetLineI = FNIndexI( targetSumI, targetRemI )
          PROCAddBufferValueMod( targetBufferI, targetLineI, sourceValueI )
        ENDFOR
      ENDIF
    ENDFOR
  ENDFOR
END
//
PROC PROCBuildCycleKernel( INTEGER weightsBufferI, INTEGER kernelZeroBufferI, INTEGER kernelNonZeroBufferI, INTEGER stateSourceBufferI, INTEGER stateTargetBufferI )
  INTEGER indexI    = 0
  INTEGER weightI   = 0
  INTEGER sumI      = 0
  INTEGER tempI     = 0
  PROCZeroBuffer( stateSourceBufferI, STATE_COUNT )
  PROCSetBufferValue( stateSourceBufferI, FNIndexI( 0, 0 ), 1 )
  FOR indexI = 1 TO CYCLE_LEN
    weightI = FNGetBufferValueI( weightsBufferI, indexI )
    PROCApplySingleWeight( stateSourceBufferI, stateTargetBufferI, weightI )
    tempI = stateSourceBufferI
    stateSourceBufferI = stateTargetBufferI
    stateTargetBufferI = tempI
  ENDFOR
  FOR sumI = 0 TO SUM_LIMIT
    PROCSetBufferValue( kernelZeroBufferI, sumI + 1, FNGetBufferValueI( stateSourceBufferI, FNIndexI( sumI, 0 ) ) )
    PROCSetBufferValue( kernelNonZeroBufferI, sumI + 1, FNGetBufferValueI( stateSourceBufferI, FNIndexI( sumI, 1 ) ) )
  ENDFOR
END
//
PROC PROCCombineKernels( INTEGER leftZeroBufferI, INTEGER leftNonZeroBufferI, INTEGER rightZeroBufferI, INTEGER rightNonZeroBufferI, INTEGER resultZeroBufferI, INTEGER resultNonZeroBufferI )
  INTEGER leftSumI        = 0
  INTEGER rightSumI       = 0
  INTEGER totalSumI       = 0
  INTEGER aI              = 0
  INTEGER bI              = 0
  INTEGER cI              = 0
  INTEGER dI              = 0
  INTEGER acI             = 0
  INTEGER bdI             = 0
  INTEGER adI             = 0
  INTEGER bcI             = 0
  INTEGER addZeroI        = 0
  INTEGER addNonZeroI     = 0
  INTEGER currentZeroI    = 0
  INTEGER currentNonZeroI = 0
  PROCZeroBuffer( resultZeroBufferI, SUM_LIMIT + 1 )
  PROCZeroBuffer( resultNonZeroBufferI, SUM_LIMIT + 1 )
  FOR leftSumI = 0 TO SUM_LIMIT
    aI = FNGetBufferValueI( leftZeroBufferI, leftSumI + 1 )
    bI = FNGetBufferValueI( leftNonZeroBufferI, leftSumI + 1 )
    IF aI > 0 OR bI > 0
      FOR rightSumI = 0 TO ( SUM_LIMIT - leftSumI )
        cI = FNGetBufferValueI( rightZeroBufferI, rightSumI + 1 )
        dI = FNGetBufferValueI( rightNonZeroBufferI, rightSumI + 1 )
        IF cI > 0 OR dI > 0
          totalSumI = leftSumI + rightSumI
          currentZeroI = FNGetBufferValueI( resultZeroBufferI, totalSumI + 1 )
          currentNonZeroI = FNGetBufferValueI( resultNonZeroBufferI, totalSumI + 1 )
          acI = FNMulModI( aI, cI )
          bdI = FNMulModI( bI, dI )
          adI = FNMulModI( aI, dI )
          bcI = FNMulModI( bI, cI )
          addZeroI = acI
          addZeroI = FNAddModI( addZeroI, FNSmallMulModI( bdI, 22 ) )
          addNonZeroI = adI
          addNonZeroI = FNAddModI( addNonZeroI, bcI )
          addNonZeroI = FNAddModI( addNonZeroI, FNSmallMulModI( bdI, 21 ) )
          currentZeroI = FNAddModI( currentZeroI, addZeroI )
          currentNonZeroI = FNAddModI( currentNonZeroI, addNonZeroI )
          PROCSetBufferValue( resultZeroBufferI, totalSumI + 1, currentZeroI )
          PROCSetBufferValue( resultNonZeroBufferI, totalSumI + 1, currentNonZeroI )
        ENDIF
      ENDFOR
    ENDIF
  ENDFOR
END
//
PROC PROCComputePoweredKernel( STRING exponentS, INTEGER baseZeroBufferI, INTEGER baseNonZeroBufferI, INTEGER resultZeroBufferI, INTEGER resultNonZeroBufferI, INTEGER tempZeroBufferI, INTEGER tempNonZeroBufferI )
  STRING workExponentS[255] = ''
  workExponentS = exponentS
  PROCZeroBuffer( resultZeroBufferI, SUM_LIMIT + 1 )
  PROCZeroBuffer( resultNonZeroBufferI, SUM_LIMIT + 1 )
  PROCSetBufferValue( resultZeroBufferI, 1, 1 )
  WHILE FNIsZeroDecimalI( workExponentS ) == FALSE
    IF FNIsOddDecimalI( workExponentS )
      PROCCombineKernels( resultZeroBufferI, resultNonZeroBufferI, baseZeroBufferI, baseNonZeroBufferI, tempZeroBufferI, tempNonZeroBufferI )
      PROCCloneArrayBuffer( tempZeroBufferI, resultZeroBufferI, SUM_LIMIT + 1 )
      PROCCloneArrayBuffer( tempNonZeroBufferI, resultNonZeroBufferI, SUM_LIMIT + 1 )
    ENDIF
    workExponentS = FNDivideDecimalBySmallS( workExponentS, 2 )
    IF FNIsZeroDecimalI( workExponentS ) == FALSE
      PROCCombineKernels( baseZeroBufferI, baseNonZeroBufferI, baseZeroBufferI, baseNonZeroBufferI, tempZeroBufferI, tempNonZeroBufferI )
      PROCCloneArrayBuffer( tempZeroBufferI, baseZeroBufferI, SUM_LIMIT + 1 )
      PROCCloneArrayBuffer( tempNonZeroBufferI, baseNonZeroBufferI, SUM_LIMIT + 1 )
    ENDIF
  ENDWHILE
END
//
PROC PROCBuildFullStateFromSymmetric( INTEGER symmetricZeroBufferI, INTEGER symmetricNonZeroBufferI, INTEGER stateBufferI )
  INTEGER sumI       = 0
  INTEGER remainderI = 0
  INTEGER zeroI      = 0
  INTEGER nonZeroI   = 0
  PROCZeroBuffer( stateBufferI, STATE_COUNT )
  FOR sumI = 0 TO SUM_LIMIT
    zeroI = FNGetBufferValueI( symmetricZeroBufferI, sumI + 1 )
    nonZeroI = FNGetBufferValueI( symmetricNonZeroBufferI, sumI + 1 )
    PROCSetBufferValue( stateBufferI, FNIndexI( sumI, 0 ), zeroI )
    FOR remainderI = 1 TO 22
      PROCSetBufferValue( stateBufferI, FNIndexI( sumI, remainderI ), nonZeroI )
    ENDFOR
  ENDFOR
END
//
PROC Main()
  INTEGER weightsBufferI         = 0
  INTEGER kernelZeroBufferI      = 0
  INTEGER kernelNonZeroBufferI   = 0
  INTEGER powerZeroBufferI       = 0
  INTEGER powerNonZeroBufferI    = 0
  INTEGER tempZeroBufferI        = 0
  INTEGER tempNonZeroBufferI     = 0
  INTEGER stateSourceBufferI     = 0
  INTEGER stateTargetBufferI     = 0
  INTEGER indexI                 = 0
  INTEGER weightI                = 0
  INTEGER tempI                  = 0
  INTEGER answerI                = 0
  STRING  numberS[255]           = ''
  STRING  exponentS[255]         = ''
  STRING  answerS[255]           = ''
  weightsBufferI       = CreateTempBuffer()
  kernelZeroBufferI    = CreateTempBuffer()
  kernelNonZeroBufferI = CreateTempBuffer()
  powerZeroBufferI     = CreateTempBuffer()
  powerNonZeroBufferI  = CreateTempBuffer()
  tempZeroBufferI      = CreateTempBuffer()
  tempNonZeroBufferI   = CreateTempBuffer()
  stateSourceBufferI   = CreateTempBuffer()
  stateTargetBufferI   = CreateTempBuffer()
  PROCInitBuffer( weightsBufferI, CYCLE_LEN )
  PROCInitBuffer( kernelZeroBufferI, SUM_LIMIT + 1 )
  PROCInitBuffer( kernelNonZeroBufferI, SUM_LIMIT + 1 )
  PROCInitBuffer( powerZeroBufferI, SUM_LIMIT + 1 )
  PROCInitBuffer( powerNonZeroBufferI, SUM_LIMIT + 1 )
  PROCInitBuffer( tempZeroBufferI, SUM_LIMIT + 1 )
  PROCInitBuffer( tempNonZeroBufferI, SUM_LIMIT + 1 )
  PROCInitBuffer( stateSourceBufferI, STATE_COUNT )
  PROCInitBuffer( stateTargetBufferI, STATE_COUNT )
  PROCPrepareWeights( weightsBufferI )
  PROCBuildCycleKernel( weightsBufferI, kernelZeroBufferI, kernelNonZeroBufferI, stateSourceBufferI, stateTargetBufferI )
  numberS = '1'
  DO 12 TIMES
    numberS = FNMultiplyDecimalBySmallS( numberS, 11 )
  ENDDO
  numberS = FNSubtractSmallS( numberS, 11 )
  exponentS = FNDivideDecimalBySmallS( numberS, 22 )
  PROCComputePoweredKernel( exponentS, kernelZeroBufferI, kernelNonZeroBufferI, powerZeroBufferI, powerNonZeroBufferI, tempZeroBufferI, tempNonZeroBufferI )
  PROCBuildFullStateFromSymmetric( powerZeroBufferI, powerNonZeroBufferI, stateSourceBufferI )
  FOR indexI = 1 TO EXTRA_LEN
    weightI = FNGetBufferValueI( weightsBufferI, indexI )
    PROCApplySingleWeight( stateSourceBufferI, stateTargetBufferI, weightI )
    tempI = stateSourceBufferI
    stateSourceBufferI = stateTargetBufferI
    stateTargetBufferI = tempI
  ENDFOR
  answerI = FNGetBufferValueI( stateSourceBufferI, FNIndexI( 23, 0 ) )
  answerS = Format( answerI )
  CopyToWinClip( answerS )
  Warn( answerS )
  CopyToWinClip( answerS )
END
