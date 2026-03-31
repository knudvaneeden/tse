/*
  euler0231.s
  <version>1</version>

  RULE CHECK APPLIED TO THIS SOURCE:
  - Pure TSE SAL only.
  - No Python or external calculation helper.
  - No hard coded final answer.
  - Final answer is calculated from loops and functions only.
  - No own variable names val / pos.
  - Return() always uses parentheses.
  - Only one final Warn() box.
  - CopyToWinClip() placed both before and after final Warn().
  - Final Warn() shows only the final answer.
  - String sizes kept <= 255.
  - PROC Main() is last.
  - LLM creator recorded in history/comment for statistics: ChatGPT GPT-5.4 Thinking.

  ALGORITHM:
  - Problem: sum of the terms in the prime factorisation of C(20000000,15000000).
  - Use Legendre:
      exponent_p( n! ) = floor( n/p ) + floor( n/p^2 ) + ...
  - Therefore contribution of a prime p is:
      p * ( exponent_p( 20000000! )
          - exponent_p( 15000000! )
          - exponent_p(  5000000! ) )
  - Enumerate primes up to 20000000 with a segmented odd-only sieve.
  - Accumulate the overall result as a decimal string.
*/

integer gBasePrimeBufferIdI = 0
string  gFullFlagsS[251]    = ""

/*
*/
proc ProcBuildFullFlags()
 string workS[251] = ""
 integer indexI = 0
 //
 workS = ""
 for indexI = 1 to 250
  workS = workS + "1"
 endfor
 gFullFlagsS = workS
end

/*
*/
integer proc FuncBufferNumLines( integer bufferIdI )
 integer numberOfLinesI = 0
 //
 PushLocation()
 PushBlock()
 GotoBufferId( bufferIdI )
 numberOfLinesI = NumLines()
 PopBlock()
 PopLocation()
 Return( numberOfLinesI )
end

/*
*/
string proc FuncBufferGetLine( integer bufferIdI, integer lineNumberI )
 string lineS[255] = ""
 //
 PushLocation()
 PushBlock()
 GotoBufferId( bufferIdI )
 GotoLine( lineNumberI )
 lineS = GetText( 1, 255 )
 PopBlock()
 PopLocation()
 Return( lineS )
end

/*
*/
proc ProcBufferPutLine( integer bufferIdI, integer lineNumberI, string newLineS )
 string workS[255] = ""
 //
 workS = newLineS
 PushLocation()
 PushBlock()
 GotoBufferId( bufferIdI )
 GotoLine( lineNumberI )
 BegLine()
 KillToEol()
 InsertText( workS )
 PopBlock()
 PopLocation()
end

/*
*/
string proc FuncReplaceCharAt( string textS, integer oneBasedIndexI, string charS )
 string leftS[255]  = ""
 string rightS[255] = ""
 string workS[255]  = ""
 //
 workS = textS
 if oneBasedIndexI <= 1
  leftS = ""
 else
  leftS = SubStr( workS, 1, oneBasedIndexI - 1 )
 endif
 if oneBasedIndexI >= Length( workS )
  rightS = ""
 else
  rightS = SubStr( workS, oneBasedIndexI + 1, Length( workS ) - oneBasedIndexI )
 endif
 Return( leftS + charS + rightS )
end

/*
*/
integer proc FuncCreateBlockBuffer( integer oddCountI )
 integer bufferIdI       = 0
 integer fullLineCountI  = 0
 integer remainderI      = 0
 integer lineIndexI      = 0
 string  partialLineS[255] = ""
 //
 bufferIdI = CreateTempBuffer()
 fullLineCountI = oddCountI / 250
 remainderI = oddCountI mod 250
 for lineIndexI = 1 to fullLineCountI
  AddLine( gFullFlagsS, bufferIdI )
 endfor
 if remainderI > 0
  partialLineS = SubStr( gFullFlagsS, 1, remainderI )
  AddLine( partialLineS, bufferIdI )
 endif
 Return( bufferIdI )
end

/*
*/
proc ProcSetBlockFlag( integer blockBufferIdI, integer zeroBasedIndexI, integer valueI )
 integer lineNumberI   = 0
 integer columnNumberI = 0
 string  lineS[255]    = ""
 string  charS[2]      = ""
 //
 lineNumberI = ( zeroBasedIndexI / 250 ) + 1
 columnNumberI = ( zeroBasedIndexI mod 250 ) + 1
 if valueI == 0
  charS = "0"
 else
  charS = "1"
 endif
 lineS = FuncBufferGetLine( blockBufferIdI, lineNumberI )
 lineS = FuncReplaceCharAt( lineS, columnNumberI, charS )
 ProcBufferPutLine( blockBufferIdI, lineNumberI, lineS )
end

/*
*/
integer proc FuncGetBlockFlag( integer blockBufferIdI, integer zeroBasedIndexI )
 integer lineNumberI   = 0
 integer columnNumberI = 0
 string  lineS[255]    = ""
 string  charS[2]      = ""
 //
 lineNumberI = ( zeroBasedIndexI / 250 ) + 1
 columnNumberI = ( zeroBasedIndexI mod 250 ) + 1
 lineS = FuncBufferGetLine( blockBufferIdI, lineNumberI )
 charS = SubStr( lineS, columnNumberI, 1 )
 if charS == "1"
  Return( 1 )
 endif
 Return( 0 )
end

/*
*/
integer proc FuncPrimeExponentInFactorial( integer limitI, integer primeI )
 integer totalI = 0
 integer workI  = 0
 //
 totalI = 0
 workI = limitI
 while workI > 0
  workI = workI / primeI
  totalI = totalI + workI
 endwhile
 Return( totalI )
end

/*
*/
integer proc FuncPrimeContribution( integer upperI, integer firstLowerI, integer secondLowerI, integer primeI )
 integer exponentUpperI = 0
 integer exponentFirstLowerI = 0
 integer exponentSecondLowerI = 0
 integer exponentNetI = 0
 //
 exponentUpperI       = FuncPrimeExponentInFactorial( upperI, primeI )
 exponentFirstLowerI  = FuncPrimeExponentInFactorial( firstLowerI, primeI )
 exponentSecondLowerI = FuncPrimeExponentInFactorial( secondLowerI, primeI )
 exponentNetI = exponentUpperI - exponentFirstLowerI - exponentSecondLowerI
 Return( primeI * exponentNetI )
end

/*
*/
string proc FuncAddSmallToBig( string totalS, integer addI )
 string workS[255]   = ""
 string addS[32]     = ""
 string resultS[255] = ""
 integer indexTotalI = 0
 integer indexAddI   = 0
 integer digitTotalI = 0
 integer digitAddI   = 0
 integer carryI      = 0
 integer digitSumI   = 0
 //
 workS = totalS
 if workS == ""
  workS = "0"
 endif
 addS = Str( addI )
 resultS = ""
 indexTotalI = Length( workS )
 indexAddI = Length( addS )
 carryI = 0
 while ( indexTotalI > 0 ) or ( indexAddI > 0 ) or ( carryI > 0 )
  digitTotalI = 0
  digitAddI = 0
  if indexTotalI > 0
   digitTotalI = Asc( SubStr( workS, indexTotalI, 1 ) ) - Asc( "0" )
   indexTotalI = indexTotalI - 1
  endif
  if indexAddI > 0
   digitAddI = Asc( SubStr( addS, indexAddI, 1 ) ) - Asc( "0" )
   indexAddI = indexAddI - 1
  endif
  digitSumI = digitTotalI + digitAddI + carryI
  carryI = digitSumI / 10
  resultS = Chr( Asc( "0" ) + ( digitSumI mod 10 ) ) + resultS
 endwhile
 while ( Length( resultS ) > 1 ) and ( SubStr( resultS, 1, 1 ) == "0" )
  resultS = SubStr( resultS, 2, Length( resultS ) - 1 )
 endwhile
 Return( resultS )
end

/*
*/
proc ProcGenerateBasePrimes( integer limitI )
 integer candidateI    = 0
 integer isPrimeB      = TRUE
 integer lineCountI    = 0
 integer lineIndexI    = 0
 integer primeI        = 0
 string  lineS[32]     = ""
 //
 gBasePrimeBufferIdI = CreateTempBuffer()
 AddLine( "2", gBasePrimeBufferIdI )
 for candidateI = 3 to limitI BY 2
  isPrimeB = TRUE
  lineCountI = FuncBufferNumLines( gBasePrimeBufferIdI )
  for lineIndexI = 1 to lineCountI
   lineS = FuncBufferGetLine( gBasePrimeBufferIdI, lineIndexI )
   primeI = Val( lineS )
   if primeI * primeI > candidateI
    break
   endif
   if ( candidateI mod primeI ) == 0
    isPrimeB = FALSE
    break
   endif
  endfor
  if isPrimeB
   AddLine( Str( candidateI ), gBasePrimeBufferIdI )
  endif
 endfor
end

/*
*/
string proc FuncSolveEuler231()
 integer upperI            = 20000000
 integer firstLowerI       = 15000000
 integer secondLowerI      = 5000000
 integer blockSpanI        = 50000
 integer blockStartI       = 3
 integer blockEndI         = 0
 integer blockOddCountI    = 0
 integer blockBufferIdI    = 0
 integer blockIndexI       = 0
 integer candidatePrimeI   = 0
 integer lineCountI        = 0
 integer lineIndexI        = 0
 integer basePrimeI        = 0
 integer startMultipleI    = 0
 integer markValueI        = 0
 integer contributionI     = 0
 string  resultS[255]      = ""
 string  lineS[32]         = ""
 //
 resultS = "0"
 contributionI = FuncPrimeContribution( upperI, firstLowerI, secondLowerI, 2 )
 resultS = FuncAddSmallToBig( resultS, contributionI )
 ProcGenerateBasePrimes( 4472 )
 blockStartI = 3
 while blockStartI <= upperI
  blockEndI = blockStartI + blockSpanI - 1
  if blockEndI > upperI
   blockEndI = upperI
  endif
  if ( blockStartI mod 2 ) == 0
   blockStartI = blockStartI + 1
  endif
  if ( blockEndI mod 2 ) == 0
   blockEndI = blockEndI - 1
  endif
  if blockStartI > blockEndI
   blockStartI = blockStartI + blockSpanI
  else
   blockOddCountI = ( ( blockEndI - blockStartI ) / 2 ) + 1
   blockBufferIdI = FuncCreateBlockBuffer( blockOddCountI )
   lineCountI = FuncBufferNumLines( gBasePrimeBufferIdI )
   for lineIndexI = 2 to lineCountI
    lineS = FuncBufferGetLine( gBasePrimeBufferIdI, lineIndexI )
    basePrimeI = Val( lineS )
    if basePrimeI * basePrimeI > blockEndI
     break
    endif
    startMultipleI = basePrimeI * basePrimeI
    if startMultipleI < blockStartI
     startMultipleI = ( ( blockStartI + basePrimeI - 1 ) / basePrimeI ) * basePrimeI
    endif
    if ( startMultipleI mod 2 ) == 0
     startMultipleI = startMultipleI + basePrimeI
    endif
    markValueI = startMultipleI
    while markValueI <= blockEndI
     blockIndexI = ( markValueI - blockStartI ) / 2
     if ( blockIndexI >= 0 ) and ( blockIndexI < blockOddCountI )
      ProcSetBlockFlag( blockBufferIdI, blockIndexI, 0 )
     endif
     markValueI = markValueI + ( 2 * basePrimeI )
    endwhile
   endfor
   for blockIndexI = 0 to blockOddCountI - 1
    if FuncGetBlockFlag( blockBufferIdI, blockIndexI )
     candidatePrimeI = blockStartI + ( 2 * blockIndexI )
     contributionI = FuncPrimeContribution( upperI, firstLowerI, secondLowerI, candidatePrimeI )
     if contributionI > 0
      resultS = FuncAddSmallToBig( resultS, contributionI )
     endif
    endif
   endfor
   PushLocation()
   PushBlock()
   GotoBufferId( blockBufferIdI )
   AbandonFile()
   PopBlock()
   PopLocation()
   blockStartI = blockEndI + 2
  endif
 endwhile
 PushLocation()
 PushBlock()
 GotoBufferId( gBasePrimeBufferIdI )
 AbandonFile()
 PopBlock()
 PopLocation()
 Return( resultS )
end

/*
*/
proc Main()
 string resultS[255] = ""
 string historyS[255] = ""
 //
 ProcBuildFullFlags()
 historyS = "Euler 231 pure TSE SAL, version 1, creator ChatGPT GPT-5.4 Thinking"
 resultS = FuncSolveEuler231()
 CopyToWinClip( resultS )
 Warn( resultS )
 CopyToWinClip( resultS )
END
