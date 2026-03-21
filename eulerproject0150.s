/*
 * TSE SAL solution for Project Euler Problem 150
 * Searching a triangular array for a sub-triangle having minimum-sum
 *
 * Algorithm  : O(N^3) with row prefix sums in a temp buffer.
 * LCG        : 615949 = 601*1024 + 525, safe 32-bit decomposition.
 * 64-bit sums: hi/lo split with splitI = 1,000,000,000.
 * Buffer     : line 1 is unused (empty). rowsum[rI][j] is at
 *              line rI*(rI+1)/2 + j + 1  (1-based, rI = 1..1000).
 *
 * Answer: -271248680
 *
 * <version>1.0.0.0.1</version>
 */

PROC Main()
 //
 integer tI          = 0        // LCG state (starts at 0)
 integer sI          = 0        // current triangle element
 integer rI          = 0        // outer loop: apex row (1..rowsI)
 integer cI          = 0        // middle loop: apex col (1..rI)
 integer kI          = 0        // inner loop: expanding row
 integer dI          = 0        // depth = kI - rI
 integer rowSliceI   = 0        // row kI slice sum for current apex
 integer leftValI    = 0        // prefix sum at left boundary
 integer rightValI   = 0        // prefix sum at right boundary
 integer lineLeftI   = 0        // buffer line for left prefix sum
 integer lineRightI  = 0        // buffer line for right prefix sum
 integer rowBaseI    = 0        // kI*(kI+1)/2 + 1, base line for row kI
 integer curHiI      = 0        // current sub-triangle sum hi part
 integer curLoI      = 0        // current sub-triangle sum lo part
 integer bestHiI     = 0        // best (minimum) sum hi part
 integer bestLoI     = 0        // best (minimum) sum lo part
 integer jI          = 0        // col index when building prefix sums
 integer colSumI     = 0        // running sum while building a prefix row
 integer pSumBufI    = 0        // buffer id for prefix sums
 string  valS[20]    = ""       // scratch string for Val()
 string  resultS[30] = ""       // final result string
 //
 integer rowsI        = 1000
 integer lcgModI         = 1048576  // 2^20
 integer lcgHalfI        = 524288   // 2^19
 integer splitI       = 1000000000
 //
 // ---------------------------------------------------------------
 // Phase 1: build prefix sum buffer
 // ---------------------------------------------------------------
 // After CreateTempBuffer() the buffer has 1 empty line (line 1).
 // All AddLine() calls append after the current last line.
 // So rowsum[rI][j] ends up at line rI*(rI+1)/2 + j + 1.
 //
 pSumBufI = CreateTempBuffer()
 //
 rI = 1
 while rI <= rowsI
  //
  // rowsum[rI][0] = 0
  AddLine( "0" )
  //
  colSumI = 0
  jI = 1
  while jI <= rI
   //
   // Next LCG step: 615949 = 601*1024 + 525
   tI = ((601 * tI) & 1023) * 1024 + 525 * tI + 797807
   tI = tI mod lcgModI
   sI = tI - lcgHalfI
   //
   colSumI = colSumI + sI
   AddLine( Str( colSumI ) )
   //
   jI = jI + 1
  endwhile
  //
  rI = rI + 1
 endwhile
 //
 // ---------------------------------------------------------------
 // Phase 2: triple loop - find minimum sub-triangle sum
 // ---------------------------------------------------------------
 // Initialise best to 0 (neutral; any negative sub-triangle beats it)
 //
 bestHiI = 0
 bestLoI = 0
 //
 rI = 1
 while rI <= rowsI
  //
  cI = 1
  while cI <= rI
   //
   curHiI = 0
   curLoI = 0
   //
   kI = rI
   while kI <= rowsI
    //
    dI = kI - rI
    //
    // rowsum[kI][cI-1]   -> line kI*(kI+1)/2 + (cI-1) + 1
    // rowsum[kI][cI+dI]  -> line kI*(kI+1)/2 + (cI+dI) + 1
    //
    rowBaseI   = kI * (kI + 1) / 2 + 1
    lineLeftI  = rowBaseI + cI - 1
    lineRightI = rowBaseI + cI + dI
    //
    GotoBufferId( pSumBufI )
    //
    GotoLine( lineRightI )
    valS      = GetText( 1, CurrLineLen() )
    rightValI = Val( valS )
    //
    GotoLine( lineLeftI )
    valS     = GetText( 1, CurrLineLen() )
    leftValI = Val( valS )
    //
    rowSliceI = rightValI - leftValI
    //
    // Add rowSliceI to (curHiI, curLoI)
    curLoI = curLoI + rowSliceI
    if curLoI >= splitI
     curHiI = curHiI + 1
     curLoI = curLoI - splitI
    endif
    if curLoI <= -splitI
     curHiI = curHiI - 1
     curLoI = curLoI + splitI
    endif
    // Enforce same-sign invariant so hi/lo comparison works
    if curHiI > 0 AND curLoI < 0
     curHiI = curHiI - 1
     curLoI = curLoI + splitI
    endif
    if curHiI < 0 AND curLoI > 0
     curHiI = curHiI + 1
     curLoI = curLoI - splitI
    endif
    //
    // Update best if current is smaller
    if curHiI < bestHiI
     bestHiI = curHiI
     bestLoI = curLoI
    elseif curHiI == bestHiI AND curLoI < bestLoI
     bestHiI = curHiI
     bestLoI = curLoI
    endif
    //
    kI = kI + 1
   endwhile
   //
   cI = cI + 1
  endwhile
  //
  rI = rI + 1
 endwhile
 //
 // ---------------------------------------------------------------
 // Phase 3: report result
 // ---------------------------------------------------------------
 // The answer (-271248680) fits in 32 bits, so bestHiI should be 0.
 //
 if bestHiI == 0
  resultS = Str( bestLoI )
 else
  resultS = Str( bestHiI ) + "*1e9+" + Str( bestLoI )
 endif
 //
 Warn( "The smallest possible sub-triangle sum is" + Chr(13) + resultS )
 CopyToWinClip( resultS )
 //
END
