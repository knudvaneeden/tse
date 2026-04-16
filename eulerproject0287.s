// Project Euler problem 287
// Quadtree Encoding (a Simple Compression Algorithm)
// Pure TSE SAL solution
// <version>1</version>
// History: ChatGPT created this TSE SAL program.
//
#DEFINE PROBLEM_N              24
#DEFINE RADIUS_I               8388608
#DEFINE LIMB_SHIFT             12
#DEFINE LIMB_MASK              4095
#DEFINE THRESHOLD_TOP_LIMB     1024
//
INTEGER PROC FNCompareToRadiusSquaredI( INTEGER xI, INTEGER yI )
  INTEGER xHiI = xI shr LIMB_SHIFT
  INTEGER xLoI = xI & LIMB_MASK
  INTEGER yHiI = yI shr LIMB_SHIFT
  INTEGER yLoI = yI & LIMB_MASK
  INTEGER part0I = 0
  INTEGER part1I = 0
  INTEGER part2I = 0
  INTEGER digit0I = 0
  INTEGER digit1I = 0
  INTEGER digit2I = 0
  INTEGER digit3I = 0
  INTEGER carryI = 0
  part0I  = xLoI * xLoI + yLoI * yLoI
  digit0I = part0I & LIMB_MASK
  carryI  = part0I shr LIMB_SHIFT
  part1I  = 2 * xHiI * xLoI + 2 * yHiI * yLoI + carryI
  digit1I = part1I & LIMB_MASK
  carryI  = part1I shr LIMB_SHIFT
  part2I  = xHiI * xHiI + yHiI * yHiI + carryI
  digit2I = part2I & LIMB_MASK
  digit3I = part2I shr LIMB_SHIFT
  IF digit3I < THRESHOLD_TOP_LIMB
    RETURN( -1 )
  ENDIF
  IF digit3I > THRESHOLD_TOP_LIMB
    RETURN( 1 )
  ENDIF
  IF ( digit2I > 0 ) OR ( digit1I > 0 ) OR ( digit0I > 0 )
    RETURN( 1 )
  ENDIF
  RETURN( 0 )
END
//
INTEGER PROC FNCountMixedForTypeAndSizeI( INTEGER offsetXI, INTEGER offsetYI, INTEGER sizeI )
  INTEGER columnsI = RADIUS_I / sizeI
  INTEGER countI = 0
  INTEGER jHasI = columnsI - 1
  INTEGER jBlackI = columnsI - 1
  INTEGER iI = 0
  INTEGER xNearI = 0
  INTEGER xFarI = 0
  INTEGER yNearI = 0
  INTEGER yFarI = 0
  INTEGER mixedI = 0
  FOR iI = 0 TO columnsI - 1
    xNearI = offsetXI + iI * sizeI
    WHILE ( jHasI >= 0 ) AND ( FNCompareToRadiusSquaredI( xNearI, offsetYI + jHasI * sizeI ) > 0 )
      jHasI = jHasI - 1
    ENDWHILE
    xFarI = xNearI + sizeI - 1
    WHILE ( jBlackI >= 0 ) AND ( FNCompareToRadiusSquaredI( xFarI, offsetYI + jBlackI * sizeI + sizeI - 1 ) > 0 )
      jBlackI = jBlackI - 1
    ENDWHILE
    mixedI = jHasI - jBlackI
    IF mixedI > 0
      countI = countI + mixedI
    ENDIF
  ENDFOR
  RETURN( countI )
END
//
INTEGER PROC FNComputeAnswerI()
  INTEGER internalCountI = 1
  INTEGER sizeI = RADIUS_I
  sizeI = RADIUS_I
  WHILE sizeI >= 2
    internalCountI = internalCountI + FNCountMixedForTypeAndSizeI( 0, 0, sizeI )
    internalCountI = internalCountI + FNCountMixedForTypeAndSizeI( 0, 1, sizeI )
    internalCountI = internalCountI + FNCountMixedForTypeAndSizeI( 1, 0, sizeI )
    internalCountI = internalCountI + FNCountMixedForTypeAndSizeI( 1, 1, sizeI )
    sizeI = sizeI shr 1
  ENDWHILE
  RETURN( 7 * internalCountI + 2 )
END
//
PROC Main()
  INTEGER answerI = 0
  STRING answerS[255] = ""
  answerI = FNComputeAnswerI()
  answerS = Format( answerI )
  CopyToWinClip( answerS )
  Warn( answerS )
  CopyToWinClip( answerS )
END
