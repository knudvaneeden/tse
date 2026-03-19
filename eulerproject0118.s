// Project Euler - Problem 118: Pandigital Prime Sets
// Using all digits 1-9 each exactly once, form sets of primes
// by freely concatenating. Count distinct such sets.
//
// Algorithm:
//   Phase 1: For each non-empty subset of {1..9} (bitmask 1..511),
//     count how many permutations of its digits form a prime.
//     Store in gSubsetPrimeCountBufG (line mask+1).
//   Phase 2: Memoised exact cover:
//     countCovers(remaining) = sum over all subsets s of remaining
//     that contain the lowest set bit of remaining, of
//     primeCount[s] * countCovers(remaining XOR s).
//     Answer = countCovers(511).
//
// Confirmed correct answer: 44680.
// (1170 was a wrong assumption by the LLM -- 44680 is verified correct.)
//
// Notes:
//   Val("-1") correctly returns -1 in TSE SAL -- used as memo sentinel.
//   remaining & (-remaining) correctly isolates lowest set bit in SAL.
//   NOT is bitwise in SAL; use == 0 / == FALSE for logical tests.
//   PushLocation/PopLocation used only in countPrimePerms (pure
//   computation, no GotoBufferId calls). Not used in countCovers
//   since its recursion depth is at most 9, safely within the default
//   shallow limit.
//
// No file input required.
//
// Created by: Claude Sonnet 4.6 (Anthropic)
// <version>1.0.0.0.6</version>

// ---------------------------------------------------------------------------
// Globals
// ---------------------------------------------------------------------------
integer gSubsetPrimeCountBufG = 0  // 512 lines: line k+1 = primeCount[k]
integer gMemoBufG             = 0  // 512 lines: line k+1 = -1 or memoValue

// ---------------------------------------------------------------------------
// isPrime
// ---------------------------------------------------------------------------
integer proc isPrime(integer n)
    integer d
    if n < 2             return( FALSE )  endif
    if n == 2            return( TRUE )   endif
    if (n & 1) == 0      return( FALSE )  endif
    if n < 9             return( TRUE )   endif
    if (n mod 3) == 0    return( FALSE )  endif
    d = 5
    while d * d <= n
        if (n mod d) == 0        return( FALSE )  endif
        if (n mod (d + 2)) == 0  return( FALSE )  endif
        d = d + 6
    endwhile
    return( TRUE )
end

// ---------------------------------------------------------------------------
// countPrimePerms
//   Recursively enumerate all permutations of digits in subsetMask.
//   usedMask : bits set for digits already placed
//   nNum     : integer built so far (digits appended left-to-right)
//   Returns count of permutations that form a prime.
//   Pure computation -- no buffer ops.
//   Max recursion depth = 9; PushLocation/PopLocation used for safety.
// ---------------------------------------------------------------------------
integer proc countPrimePerms(integer subsetMask, integer usedMask, integer nNum)
    integer bit, nCount, newNum

    PushLocation()

    if usedMask == subsetMask
        PopLocation()
        if isPrime(nNum)
            return( 1 )
        endif
        return( 0 )
    endif

    nCount = 0
    for bit = 0 to 8
        if (subsetMask shr bit) & 1
            if ((usedMask shr bit) & 1) == 0
                newNum = nNum * 10 + (bit + 1)
                nCount = nCount + countPrimePerms(subsetMask,
                                                  usedMask | (1 shl bit),
                                                  newNum)
            endif
        endif
    endfor

    PopLocation()
    return( nCount )
end

// ---------------------------------------------------------------------------
// getSubsetPrimeCount
// ---------------------------------------------------------------------------
integer proc getSubsetPrimeCount(integer mask)
    integer savedBuf, nVal
    savedBuf = GetBufferId()
    GotoBufferId( gSubsetPrimeCountBufG )
    GotoLine( mask + 1 )
    nVal = Val( GetText( 1, CurrLineLen() ) )
    GotoBufferId( savedBuf )
    return( nVal )
end

// ---------------------------------------------------------------------------
// getMemo  (returns -1 if not yet set)
// ---------------------------------------------------------------------------
integer proc getMemo(integer mask)
    integer savedBuf, nVal
    savedBuf = GetBufferId()
    GotoBufferId( gMemoBufG )
    GotoLine( mask + 1 )
    nVal = Val( GetText( 1, CurrLineLen() ) )
    GotoBufferId( savedBuf )
    return( nVal )
end

// ---------------------------------------------------------------------------
// setMemo
// ---------------------------------------------------------------------------
proc setMemo(integer mask, integer nVal)
    integer savedBuf
    savedBuf = GetBufferId()
    GotoBufferId( gMemoBufG )
    GotoLine( mask + 1 )
    BegLine()
    KillToEol()
    InsertText( Str(nVal), _INSERT_ )
    GotoBufferId( savedBuf )
end

// ---------------------------------------------------------------------------
// countCovers
//   remaining : bitmask of digits still to assign
//   Returns weighted count of all valid exact covers:
//     each partition piece must have primeCount > 0,
//     weight = product of primeCounts for each piece.
//   Canonical order: always include lowest set bit of remaining in the
//   first chosen piece -- prevents counting the same partition twice.
//   Recursion depth <= 9; no PushLocation needed.
// ---------------------------------------------------------------------------
integer proc countCovers(integer remaining)
    integer nResult, nPC, sub, subMask, lowestBit, done

    if remaining == 0
        return( 1 )
    endif

    nResult = getMemo( remaining )
    if nResult >= 0
        return( nResult )
    endif

    lowestBit = remaining & (-remaining)  // isolate lowest set bit

    subMask = remaining ^ lowestBit
    sub     = subMask
    nResult = 0
    done    = FALSE

    while done == FALSE
        nPC = getSubsetPrimeCount( sub | lowestBit )
        if nPC > 0
            nResult = nResult + nPC * countCovers( remaining ^ (sub | lowestBit) )
        endif
        if sub == 0
            done = TRUE
        else
            sub = (sub - 1) & subMask
        endif
    endwhile

    setMemo( remaining, nResult )
    return( nResult )
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer mask, nPC, nAnswer
    integer savedBuf
    string  sAnswer[20]

    // gSubsetPrimeCountBufG: 512 lines of "0"
    gSubsetPrimeCountBufG = CreateTempBuffer()
    GotoBufferId( gSubsetPrimeCountBufG )
    mask = 0
    while mask < 512
        AddLine( "0" )
        mask = mask + 1
    endwhile

    // gMemoBufG: 512 lines of "-1" (unset sentinel; Val("-1")=-1 in SAL)
    gMemoBufG = CreateTempBuffer()
    GotoBufferId( gMemoBufG )
    mask = 0
    while mask < 512
        AddLine( "-1" )
        mask = mask + 1
    endwhile

    // Phase 1: count prime-forming permutations for each non-empty subset
    savedBuf = GetBufferId()
    mask = 1
    while mask <= 511
        nPC = countPrimePerms( mask, 0, 0 )
        if nPC > 0
            GotoBufferId( gSubsetPrimeCountBufG )
            GotoLine( mask + 1 )
            BegLine()
            KillToEol()
            InsertText( Str(nPC), _INSERT_ )
        endif
        mask = mask + 1
    endwhile
    GotoBufferId( savedBuf )

    // Phase 2: memoised exact cover
    nAnswer = countCovers( 511 )   // 511 = all 9 digits

    // Output
    sAnswer = Str( nAnswer )
    CopyToWinClip( sAnswer )
    Warn( "Project Euler Problem 118"  + Chr(13) +
          "Pandigital Prime Sets"       + Chr(13) +
          Chr(13) +
          "Answer: " + sAnswer )

    AbandonFile( gSubsetPrimeCountBufG )
    AbandonFile( gMemoBufG )
end
