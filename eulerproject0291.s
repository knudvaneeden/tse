// Project Euler problem 291
// Panaitopol primes
// Pure TSE SAL
// <version>3</version>
// History:
// 1 - ChatGPT
// 2 - ChatGPT - rewrite to polynomial sieve over n, inspired by the uploaded 291.py brute-force structure
// 3 - ChatGPT - corrected exact all-divisor sieve over n segments

#DEFINE LIMIT_N                   49999999
#DEFINE LIMIT_Q                   70710678
#DEFINE BASE_PRIME_LIMIT          8408
#DEFINE PRIME_ODD_SEGMENT_SIZE    1000000
#DEFINE N_SEGMENT_SIZE            12500000
#DEFINE WORD_BITS                 30
#DEFINE WORDS_PER_LINE            7
#DEFINE LINE_BITS                 210
#DEFINE WORD_MASK                 1073741823
#DEFINE SPECIAL_LIMIT             6000

FORWARD INTEGER PROC FNIsqrtI( INTEGER numberI )
FORWARD INTEGER PROC FNIsPrimeSmallI( INTEGER numberI )
FORWARD INTEGER PROC FNNormModI( INTEGER valueI, INTEGER modI )
FORWARD INTEGER PROC FNMultiplyModI( INTEGER aI, INTEGER bI, INTEGER modI )
FORWARD INTEGER PROC FNPowModI( INTEGER baseI, INTEGER exponentI, INTEGER modI )
FORWARD INTEGER PROC FNPowerOfTwoI( INTEGER exponentI )
FORWARD INTEGER PROC FNLowBitsMaskI( INTEGER bitsI )
FORWARD INTEGER PROC FNPopCountI( INTEGER valueI )
FORWARD INTEGER PROC FNSqrtMinusOneModI( INTEGER primeI )
FORWARD INTEGER PROC FNIsSpecialRootI( INTEGER primeI, INTEGER residueI )
FORWARD INTEGER PROC FNFirstHitInSegmentI( INTEGER lowI, INTEGER highI, INTEGER residueI, INTEGER stepI )
FORWARD STRING  PROC FNEncodeWordLineS( INTEGER word1I, INTEGER word2I, INTEGER word3I, INTEGER word4I, INTEGER word5I, INTEGER word6I, INTEGER word7I )
FORWARD STRING  PROC FNZeroWordLineS()
FORWARD STRING  PROC FNEncodePrimeRootLineS( INTEGER primeI, INTEGER residue1I, INTEGER residue2I )
FORWARD PROC PROCBuildBasePrimeBuffer( INTEGER basePrimeBufferI )
FORWARD PROC PROCInitWordBuffer( INTEGER bufferI, INTEGER sizeI )
FORWARD PROC PROCMarkProgressionInWordBuffer( INTEGER bufferI, INTEGER firstPosI, INTEGER lastPosI, INTEGER stepPosI )
FORWARD INTEGER PROC FNCountMarkedInWordBufferI( INTEGER bufferI, INTEGER sizeI )
FORWARD PROC PROCAppendPrimeRootLine( INTEGER primeI, INTEGER primeRootBufferI )
FORWARD PROC PROCBuildPrimeRootBuffer( INTEGER basePrimeBufferI, INTEGER primeRootBufferI )
FORWARD INTEGER PROC FNCountSegmentSurvivorsI( INTEGER lowI, INTEGER highI, INTEGER primeRootBufferI, INTEGER primeRootLinesI )

INTEGER PROC FNIsqrtI( INTEGER numberI )
  INTEGER lowI = 0
  INTEGER highI = 46340
  INTEGER midI = 0
  INTEGER answerI = 0
  IF numberI <= 0
    RETURN( 0 )
  ENDIF
  IF numberI < 46340
    highI = numberI
  ENDIF
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

INTEGER PROC FNIsPrimeSmallI( INTEGER numberI )
  INTEGER divisorI = 0
  INTEGER limitI = 0
  IF numberI < 2
    RETURN( FALSE )
  ENDIF
  IF numberI == 2
    RETURN( TRUE )
  ENDIF
  IF ( numberI & 1 ) == 0
    RETURN( FALSE )
  ENDIF
  limitI = FNIsqrtI( numberI )
  FOR divisorI = 3 TO limitI BY 2
    IF ( numberI mod divisorI ) == 0
      RETURN( FALSE )
    ENDIF
  ENDFOR
  RETURN( TRUE )
END

INTEGER PROC FNNormModI( INTEGER valueI, INTEGER modI )
  INTEGER resultI = valueI
  WHILE resultI < 0
    resultI = resultI + modI
  ENDWHILE
  WHILE resultI >= modI
    resultI = resultI - modI
  ENDWHILE
  RETURN( resultI )
END

INTEGER PROC FNMultiplyModI( INTEGER aI, INTEGER bI, INTEGER modI )
  INTEGER resultI = 0
  INTEGER aWorkI = 0
  INTEGER bWorkI = 0
  aWorkI = FNNormModI( aI, modI )
  bWorkI = bI
  WHILE bWorkI > 0
    IF ( bWorkI & 1 ) == 1
      resultI = resultI + aWorkI
      IF resultI >= modI
        resultI = resultI - modI
      ENDIF
    ENDIF
    bWorkI = bWorkI shr 1
    aWorkI = aWorkI shl 1
    IF aWorkI >= modI
      aWorkI = aWorkI - modI
    ENDIF
  ENDWHILE
  RETURN( resultI )
END

INTEGER PROC FNPowModI( INTEGER baseI, INTEGER exponentI, INTEGER modI )
  INTEGER resultI = 1
  INTEGER baseWorkI = 0
  INTEGER exponentWorkI = exponentI
  baseWorkI = FNNormModI( baseI, modI )
  WHILE exponentWorkI > 0
    IF ( exponentWorkI & 1 ) == 1
      resultI = FNMultiplyModI( resultI, baseWorkI, modI )
    ENDIF
    exponentWorkI = exponentWorkI shr 1
    IF exponentWorkI > 0
      baseWorkI = FNMultiplyModI( baseWorkI, baseWorkI, modI )
    ENDIF
  ENDWHILE
  RETURN( resultI )
END

INTEGER PROC FNPowerOfTwoI( INTEGER exponentI )
  INTEGER resultI = 1
  INTEGER indexI = 0
  FOR indexI = 1 TO exponentI
    resultI = resultI shl 1
  ENDFOR
  RETURN( resultI )
END

INTEGER PROC FNLowBitsMaskI( INTEGER bitsI )
  IF bitsI <= 0
    RETURN( 0 )
  ENDIF
  IF bitsI >= WORD_BITS
    RETURN( WORD_MASK )
  ENDIF
  RETURN( FNPowerOfTwoI( bitsI ) - 1 )
END

INTEGER PROC FNPopCountI( INTEGER valueI )
  INTEGER countI = 0
  INTEGER workI = valueI
  WHILE workI > 0
    workI = workI & ( workI - 1 )
    countI = countI + 1
  ENDWHILE
  RETURN( countI )
END

INTEGER PROC FNSqrtMinusOneModI( INTEGER primeI )
  INTEGER oddPartI = 0
  INTEGER shiftCountI = 0
  INTEGER nonResidueI = 2
  INTEGER mI = 0
  INTEGER cI = 0
  INTEGER tI = 0
  INTEGER rI = 0
  INTEGER indexI = 0
  INTEGER tempI = 0
  INTEGER bI = 0
  oddPartI = primeI - 1
  WHILE ( oddPartI & 1 ) == 0
    oddPartI = oddPartI shr 1
    shiftCountI = shiftCountI + 1
  ENDWHILE
  WHILE NOT( FNPowModI( nonResidueI, ( primeI - 1 ) / 2, primeI ) == primeI - 1 )
    nonResidueI = nonResidueI + 1
  ENDWHILE
  mI = shiftCountI
  cI = FNPowModI( nonResidueI, oddPartI, primeI )
  tI = FNPowModI( primeI - 1, oddPartI, primeI )
  rI = FNPowModI( primeI - 1, ( oddPartI + 1 ) / 2, primeI )
  WHILE NOT( tI == 1 )
    indexI = 1
    tempI = FNMultiplyModI( tI, tI, primeI )
    WHILE NOT( tempI == 1 )
      tempI = FNMultiplyModI( tempI, tempI, primeI )
      indexI = indexI + 1
    ENDWHILE
    bI = FNPowModI( cI, FNPowerOfTwoI( mI - indexI - 1 ), primeI )
    mI = indexI
    cI = FNMultiplyModI( bI, bI, primeI )
    tI = FNMultiplyModI( tI, cI, primeI )
    rI = FNMultiplyModI( rI, bI, primeI )
  ENDWHILE
  RETURN( rI )
END

INTEGER PROC FNIsSpecialRootI( INTEGER primeI, INTEGER residueI )
  INTEGER candidateI = 0
  IF residueI < 0
    RETURN( FALSE )
  ENDIF
  IF residueI > SPECIAL_LIMIT
    RETURN( FALSE )
  ENDIF
  candidateI = 2 * residueI * residueI + 2 * residueI + 1
  RETURN( candidateI == primeI )
END

INTEGER PROC FNFirstHitInSegmentI( INTEGER lowI, INTEGER highI, INTEGER residueI, INTEGER stepI )
  INTEGER firstI = residueI
  INTEGER deltaI = 0
  INTEGER jumpsI = 0
  IF firstI < lowI
    deltaI = lowI - firstI
    jumpsI = ( deltaI + stepI - 1 ) / stepI
    firstI = firstI + jumpsI * stepI
  ENDIF
  IF firstI > highI
    RETURN( 0 )
  ENDIF
  RETURN( firstI )
END

STRING PROC FNEncodeWordLineS( INTEGER word1I, INTEGER word2I, INTEGER word3I, INTEGER word4I, INTEGER word5I, INTEGER word6I, INTEGER word7I )
  STRING lineS[255] = ""
  lineS = Format( word1I : 10 : "0" ) + Format( word2I : 10 : "0" ) + Format( word3I : 10 : "0" ) + Format( word4I : 10 : "0" ) + Format( word5I : 10 : "0" ) + Format( word6I : 10 : "0" ) + Format( word7I : 10 : "0" )
  RETURN( lineS )
END

STRING PROC FNZeroWordLineS()
  RETURN( FNEncodeWordLineS( 0, 0, 0, 0, 0, 0, 0 ) )
END

STRING PROC FNEncodePrimeRootLineS( INTEGER primeI, INTEGER residue1I, INTEGER residue2I )
  STRING lineS[255] = ""
  lineS = Format( primeI : 8 : "0" ) + Format( residue1I : 8 : "0" ) + Format( residue2I : 8 : "0" )
  RETURN( lineS )
END

PROC PROCBuildBasePrimeBuffer( INTEGER basePrimeBufferI )
  INTEGER candidateI = 0
  AddLine( "3", basePrimeBufferI )
  FOR candidateI = 5 TO BASE_PRIME_LIMIT BY 2
    IF FNIsPrimeSmallI( candidateI )
      AddLine( Format( candidateI ), basePrimeBufferI )
    ENDIF
  ENDFOR
END

PROC PROCInitWordBuffer( INTEGER bufferI, INTEGER sizeI )
  INTEGER lineCountI = 0
  INTEGER lineIndexI = 0
  STRING zeroLineS[255] = ""
  zeroLineS = FNZeroWordLineS()
  lineCountI = ( sizeI + LINE_BITS - 1 ) / LINE_BITS
  FOR lineIndexI = 1 TO lineCountI
    AddLine( zeroLineS, bufferI )
  ENDFOR
END

PROC PROCMarkProgressionInWordBuffer( INTEGER bufferI, INTEGER firstPosI, INTEGER lastPosI, INTEGER stepPosI )
  INTEGER hitPosI = 0
  INTEGER zeroBasedI = 0
  INTEGER lineNoI = 0
  INTEGER withinLineI = 0
  INTEGER slotI = 0
  INTEGER bitI = 0
  INTEGER maskI = 0
  INTEGER currentLineI = 0
  INTEGER word1I = 0
  INTEGER word2I = 0
  INTEGER word3I = 0
  INTEGER word4I = 0
  INTEGER word5I = 0
  INTEGER word6I = 0
  INTEGER word7I = 0
  STRING lineS[255] = ""
  IF firstPosI <= 0
    RETURN()
  ENDIF
  IF firstPosI > lastPosI
    RETURN()
  ENDIF
  PushLocation()
  GotoBufferId( bufferI )
  FOR hitPosI = firstPosI TO lastPosI BY stepPosI
    zeroBasedI = hitPosI - 1
    lineNoI = zeroBasedI / LINE_BITS + 1
    withinLineI = zeroBasedI mod LINE_BITS
    slotI = withinLineI / WORD_BITS
    bitI = withinLineI mod WORD_BITS
    maskI = 1 shl bitI
    IF NOT( lineNoI == currentLineI )
      IF currentLineI > 0
        GotoLine( currentLineI )
        BegLine()
        KillToEol()
        InsertText( FNEncodeWordLineS( word1I, word2I, word3I, word4I, word5I, word6I, word7I ) )
      ENDIF
      currentLineI = lineNoI
      GotoLine( currentLineI )
      lineS = GetText( 1, 70 )
      word1I = Val( SubStr( lineS, 1, 10 ) )
      word2I = Val( SubStr( lineS, 11, 10 ) )
      word3I = Val( SubStr( lineS, 21, 10 ) )
      word4I = Val( SubStr( lineS, 31, 10 ) )
      word5I = Val( SubStr( lineS, 41, 10 ) )
      word6I = Val( SubStr( lineS, 51, 10 ) )
      word7I = Val( SubStr( lineS, 61, 10 ) )
    ENDIF
    CASE slotI
      WHEN 0
        word1I = word1I | maskI
      WHEN 1
        word2I = word2I | maskI
      WHEN 2
        word3I = word3I | maskI
      WHEN 3
        word4I = word4I | maskI
      WHEN 4
        word5I = word5I | maskI
      WHEN 5
        word6I = word6I | maskI
      OTHERWISE
        word7I = word7I | maskI
    ENDCASE
  ENDFOR
  IF currentLineI > 0
    GotoLine( currentLineI )
    BegLine()
    KillToEol()
    InsertText( FNEncodeWordLineS( word1I, word2I, word3I, word4I, word5I, word6I, word7I ) )
  ENDIF
  PopLocation()
END

INTEGER PROC FNCountMarkedInWordBufferI( INTEGER bufferI, INTEGER sizeI )
  INTEGER totalI = 0
  INTEGER lineCountI = 0
  INTEGER lineIndexI = 0
  INTEGER remainingBitsI = 0
  INTEGER usedBitsI = 0
  INTEGER bits1I = 0
  INTEGER bits2I = 0
  INTEGER bits3I = 0
  INTEGER bits4I = 0
  INTEGER bits5I = 0
  INTEGER bits6I = 0
  INTEGER bits7I = 0
  INTEGER word1I = 0
  INTEGER word2I = 0
  INTEGER word3I = 0
  INTEGER word4I = 0
  INTEGER word5I = 0
  INTEGER word6I = 0
  INTEGER word7I = 0
  STRING lineS[255] = ""
  lineCountI = ( sizeI + LINE_BITS - 1 ) / LINE_BITS
  remainingBitsI = sizeI
  PushLocation()
  GotoBufferId( bufferI )
  FOR lineIndexI = 1 TO lineCountI
    GotoLine( lineIndexI )
    lineS = GetText( 1, 70 )
    word1I = Val( SubStr( lineS, 1, 10 ) )
    word2I = Val( SubStr( lineS, 11, 10 ) )
    word3I = Val( SubStr( lineS, 21, 10 ) )
    word4I = Val( SubStr( lineS, 31, 10 ) )
    word5I = Val( SubStr( lineS, 41, 10 ) )
    word6I = Val( SubStr( lineS, 51, 10 ) )
    word7I = Val( SubStr( lineS, 61, 10 ) )
    IF remainingBitsI >= LINE_BITS
      usedBitsI = LINE_BITS
    ELSE
      usedBitsI = remainingBitsI
    ENDIF
    bits1I = usedBitsI
    IF bits1I > WORD_BITS
      bits1I = WORD_BITS
    ENDIF
    bits2I = usedBitsI - WORD_BITS
    IF bits2I < 0
      bits2I = 0
    ENDIF
    IF bits2I > WORD_BITS
      bits2I = WORD_BITS
    ENDIF
    bits3I = usedBitsI - 2 * WORD_BITS
    IF bits3I < 0
      bits3I = 0
    ENDIF
    IF bits3I > WORD_BITS
      bits3I = WORD_BITS
    ENDIF
    bits4I = usedBitsI - 3 * WORD_BITS
    IF bits4I < 0
      bits4I = 0
    ENDIF
    IF bits4I > WORD_BITS
      bits4I = WORD_BITS
    ENDIF
    bits5I = usedBitsI - 4 * WORD_BITS
    IF bits5I < 0
      bits5I = 0
    ENDIF
    IF bits5I > WORD_BITS
      bits5I = WORD_BITS
    ENDIF
    bits6I = usedBitsI - 5 * WORD_BITS
    IF bits6I < 0
      bits6I = 0
    ENDIF
    IF bits6I > WORD_BITS
      bits6I = WORD_BITS
    ENDIF
    bits7I = usedBitsI - 6 * WORD_BITS
    IF bits7I < 0
      bits7I = 0
    ENDIF
    IF bits7I > WORD_BITS
      bits7I = WORD_BITS
    ENDIF
    totalI = totalI + FNPopCountI( word1I & FNLowBitsMaskI( bits1I ) )
    totalI = totalI + FNPopCountI( word2I & FNLowBitsMaskI( bits2I ) )
    totalI = totalI + FNPopCountI( word3I & FNLowBitsMaskI( bits3I ) )
    totalI = totalI + FNPopCountI( word4I & FNLowBitsMaskI( bits4I ) )
    totalI = totalI + FNPopCountI( word5I & FNLowBitsMaskI( bits5I ) )
    totalI = totalI + FNPopCountI( word6I & FNLowBitsMaskI( bits6I ) )
    totalI = totalI + FNPopCountI( word7I & FNLowBitsMaskI( bits7I ) )
    remainingBitsI = remainingBitsI - usedBitsI
  ENDFOR
  PopLocation()
  RETURN( totalI )
END

PROC PROCAppendPrimeRootLine( INTEGER primeI, INTEGER primeRootBufferI )
  INTEGER rootI = 0
  INTEGER inv2I = 0
  INTEGER residue1I = 0
  INTEGER residue2I = 0
  INTEGER swapI = 0
  STRING lineS[255] = ""
  rootI = FNSqrtMinusOneModI( primeI )
  inv2I = ( primeI + 1 ) / 2
  residue1I = FNMultiplyModI( FNNormModI( rootI - 1, primeI ), inv2I, primeI )
  residue2I = FNMultiplyModI( FNNormModI( primeI - rootI - 1, primeI ), inv2I, primeI )
  IF residue2I < residue1I
    swapI = residue1I
    residue1I = residue2I
    residue2I = swapI
  ENDIF
  lineS = FNEncodePrimeRootLineS( primeI, residue1I, residue2I )
  AddLine( lineS, primeRootBufferI )
END

PROC PROCBuildPrimeRootBuffer( INTEGER basePrimeBufferI, INTEGER primeRootBufferI )
  INTEGER segmentLowOddI = 0
  INTEGER segmentHighOddI = 0
  INTEGER oddCountI = 0
  INTEGER markBufferI = 0
  INTEGER baseLinesI = 0
  INTEGER baseLineI = 0
  INTEGER basePrimeI = 0
  INTEGER firstCompositeI = 0
  INTEGER firstPosI = 0
  INTEGER lastPosI = 0
  INTEGER stepPosI = 0
  INTEGER lineCountI = 0
  INTEGER lineIndexI = 0
  INTEGER usedBitsI = 0
  INTEGER bitIndexI = 0
  INTEGER candidateI = 0
  INTEGER word1I = 0
  INTEGER word2I = 0
  INTEGER word3I = 0
  INTEGER word4I = 0
  INTEGER word5I = 0
  INTEGER word6I = 0
  INTEGER word7I = 0
  INTEGER slotI = 0
  INTEGER maskI = 0
  INTEGER markedB = FALSE
  STRING lineS[255] = ""
  PushLocation()
  GotoBufferId( basePrimeBufferI )
  baseLinesI = NumLines()
  PopLocation()
  segmentLowOddI = 3
  WHILE segmentLowOddI <= LIMIT_Q
    segmentHighOddI = segmentLowOddI + 2 * ( PRIME_ODD_SEGMENT_SIZE - 1 )
    IF segmentHighOddI > LIMIT_Q
      segmentHighOddI = LIMIT_Q
    ENDIF
    IF ( segmentHighOddI & 1 ) == 0
      segmentHighOddI = segmentHighOddI - 1
    ENDIF
    oddCountI = ( segmentHighOddI - segmentLowOddI ) / 2 + 1
    markBufferI = CreateTempBuffer()
    PROCInitWordBuffer( markBufferI, oddCountI )
    PushLocation()
    GotoBufferId( basePrimeBufferI )
    FOR baseLineI = 1 TO baseLinesI
      GotoLine( baseLineI )
      basePrimeI = Val( GetText( 1, 255 ) )
      IF basePrimeI * basePrimeI > segmentHighOddI
        baseLineI = baseLinesI
      ELSE
        firstCompositeI = ( ( segmentLowOddI + basePrimeI - 1 ) / basePrimeI ) * basePrimeI
        IF firstCompositeI < basePrimeI * basePrimeI
          firstCompositeI = basePrimeI * basePrimeI
        ENDIF
        IF ( firstCompositeI & 1 ) == 0
          firstCompositeI = firstCompositeI + basePrimeI
        ENDIF
        firstPosI = ( firstCompositeI - segmentLowOddI ) / 2 + 1
        lastPosI = oddCountI
        stepPosI = basePrimeI
        PROCMarkProgressionInWordBuffer( markBufferI, firstPosI, lastPosI, stepPosI )
      ENDIF
    ENDFOR
    PopLocation()
    lineCountI = ( oddCountI + LINE_BITS - 1 ) / LINE_BITS
    PushLocation()
    GotoBufferId( markBufferI )
    FOR lineIndexI = 1 TO lineCountI
      GotoLine( lineIndexI )
      lineS = GetText( 1, 70 )
      word1I = Val( SubStr( lineS, 1, 10 ) )
      word2I = Val( SubStr( lineS, 11, 10 ) )
      word3I = Val( SubStr( lineS, 21, 10 ) )
      word4I = Val( SubStr( lineS, 31, 10 ) )
      word5I = Val( SubStr( lineS, 41, 10 ) )
      word6I = Val( SubStr( lineS, 51, 10 ) )
      word7I = Val( SubStr( lineS, 61, 10 ) )
      usedBitsI = oddCountI - ( lineIndexI - 1 ) * LINE_BITS
      IF usedBitsI > LINE_BITS
        usedBitsI = LINE_BITS
      ENDIF
      FOR bitIndexI = 0 TO usedBitsI - 1
        slotI = bitIndexI / WORD_BITS
        maskI = 1 shl ( bitIndexI mod WORD_BITS )
        markedB = FALSE
        CASE slotI
          WHEN 0
            markedB = ( word1I & maskI ) == maskI
          WHEN 1
            markedB = ( word2I & maskI ) == maskI
          WHEN 2
            markedB = ( word3I & maskI ) == maskI
          WHEN 3
            markedB = ( word4I & maskI ) == maskI
          WHEN 4
            markedB = ( word5I & maskI ) == maskI
          WHEN 5
            markedB = ( word6I & maskI ) == maskI
          OTHERWISE
            markedB = ( word7I & maskI ) == maskI
        ENDCASE
        IF NOT( markedB )
          candidateI = segmentLowOddI + 2 * ( ( lineIndexI - 1 ) * LINE_BITS + bitIndexI )
          IF candidateI <= LIMIT_Q
            IF ( candidateI mod 4 ) == 1
              PROCAppendPrimeRootLine( candidateI, primeRootBufferI )
            ENDIF
          ENDIF
        ENDIF
      ENDFOR
    ENDFOR
    PopLocation()
    PushLocation()
    GotoBufferId( markBufferI )
    AbandonFile()
    PopLocation()
    segmentLowOddI = segmentHighOddI + 2
  ENDWHILE
END

INTEGER PROC FNCountSegmentSurvivorsI( INTEGER lowI, INTEGER highI, INTEGER primeRootBufferI, INTEGER primeRootLinesI )
  INTEGER segmentSizeI = 0
  INTEGER markBufferI = 0
  INTEGER lineIndexI = 0
  INTEGER primeI = 0
  INTEGER residue1I = 0
  INTEGER residue2I = 0
  INTEGER firstHitI = 0
  INTEGER firstPosI = 0
  INTEGER markedCountI = 0
  STRING lineS[255] = ""
  segmentSizeI = highI - lowI + 1
  markBufferI = CreateTempBuffer()
  PROCInitWordBuffer( markBufferI, segmentSizeI )
  PushLocation()
  GotoBufferId( primeRootBufferI )
  FOR lineIndexI = 1 TO primeRootLinesI
    GotoLine( lineIndexI )
    lineS = GetText( 1, 24 )
    primeI = Val( SubStr( lineS, 1, 8 ) )
    residue1I = Val( SubStr( lineS, 9, 8 ) )
    residue2I = Val( SubStr( lineS, 17, 8 ) )
    firstHitI = FNFirstHitInSegmentI( lowI, highI, residue1I, primeI )
    IF firstHitI > 0
      IF FNIsSpecialRootI( primeI, firstHitI )
        firstHitI = firstHitI + primeI
      ENDIF
      IF firstHitI <= highI
        firstPosI = firstHitI - lowI + 1
        PROCMarkProgressionInWordBuffer( markBufferI, firstPosI, segmentSizeI, primeI )
      ENDIF
    ENDIF
    IF NOT( residue2I == residue1I )
      firstHitI = FNFirstHitInSegmentI( lowI, highI, residue2I, primeI )
      IF firstHitI > 0
        IF FNIsSpecialRootI( primeI, firstHitI )
          firstHitI = firstHitI + primeI
        ENDIF
        IF firstHitI <= highI
          firstPosI = firstHitI - lowI + 1
          PROCMarkProgressionInWordBuffer( markBufferI, firstPosI, segmentSizeI, primeI )
        ENDIF
      ENDIF
    ENDIF
  ENDFOR
  PopLocation()
  markedCountI = FNCountMarkedInWordBufferI( markBufferI, segmentSizeI )
  PushLocation()
  GotoBufferId( markBufferI )
  AbandonFile()
  PopLocation()
  RETURN( segmentSizeI - markedCountI )
END

PROC Main()
  INTEGER basePrimeBufferI = 0
  INTEGER primeRootBufferI = 0
  INTEGER primeRootLinesI = 0
  INTEGER lowI = 0
  INTEGER highI = 0
  INTEGER answerI = 0
  STRING resultS[255] = ""
  basePrimeBufferI = CreateTempBuffer()
  primeRootBufferI = CreateTempBuffer()
  PROCBuildBasePrimeBuffer( basePrimeBufferI )
  PROCBuildPrimeRootBuffer( basePrimeBufferI, primeRootBufferI )
  PushLocation()
  GotoBufferId( primeRootBufferI )
  primeRootLinesI = NumLines()
  PopLocation()
  lowI = 1
  WHILE lowI <= LIMIT_N
    highI = lowI + N_SEGMENT_SIZE - 1
    IF highI > LIMIT_N
      highI = LIMIT_N
    ENDIF
    answerI = answerI + FNCountSegmentSurvivorsI( lowI, highI, primeRootBufferI, primeRootLinesI )
    lowI = highI + 1
  ENDWHILE
  resultS = Format( answerI )
  CopyToWinClip( resultS )
  Warn( resultS )
  CopyToWinClip( resultS )
END
