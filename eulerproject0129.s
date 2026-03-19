// Project Euler - Problem 129: Repunit Divisibility
// Find the least value of n for which A(n) first exceeds one-million.
//
// A repunit R(k) has k ones: R(1)=1, R(2)=11, R(3)=111, ...
// A(n) = least k such that n divides R(k), where gcd(n,10) = 1.
// R(k) mod n can be computed iteratively:
//   r = 1
//   if r mod n == 0 then k=1 else r = r*10+1, k=2, ...
// Since A(n) <= n, to get A(n) > 1000000 we need n > 1000000.
// We search n starting just above 1000000, skipping multiples of 2 and 5.
//
// Created by: Claude (Anthropic) - claude-sonnet-4-6
// <version>1.0.0.0.1</version>

// ===================================================================
// FNGcdI( aI, bI )
// Returns gcd(a,b) using Euclidean algorithm.
// ===================================================================
integer proc FNGcdI( integer aI, integer bI )
    integer tmpI = 0
    //
    while bI <> 0
        tmpI = aI mod bI
        aI   = bI
        bI   = tmpI
    endwhile
    return( aI )
end

// ===================================================================
// FNRepunitPeriodI( nI )
// Returns A(n) = least k >= 1 such that n | R(k).
// Uses: R(k) mod n computed as r = (r*10 + 1) mod n iteratively.
// Returns 0 if gcd(n,10) != 1 (should not happen in our search).
// ===================================================================
integer proc FNRepunitPeriodI( integer nI )
    integer kI = 0
    integer rI = 0
    //
    if FNGcdI( nI, 10 ) <> 1
        return( 0 )
    endif
    //
    kI = 1
    rI = 1 mod nI
    while rI <> 0
        rI = ( rI * 10 + 1 ) mod nI
        kI = kI + 1
    endwhile
    return( kI )
end

// ===================================================================
// Main
// ===================================================================
proc Main()
    integer nI       = 0
    integer aN       = 0
    integer foundI   = 0
    integer limitI   = 0
    string  resultS[255] = ""
    //
    limitI  = 1000000
    foundI  = 0
    //
    // A(n) <= n, so A(n) > 1000000 requires n > 1000000.
    // Start at first candidate above 1000000 with gcd(n,10)=1.
    // n must be odd and not divisible by 5.
    // 1000001 is odd; check if div by 5: 1000001 mod 5 = 1, so ok.
    nI = limitI + 1
    //
    while foundI == 0
        // Only test n with gcd(n,10) == 1
        if ( nI mod 2 <> 0 ) and ( nI mod 5 <> 0 )
            aN = FNRepunitPeriodI( nI )
            if aN > limitI
                foundI = nI
            endif
        endif
        if foundI == 0
            nI = nI + 1
        endif
    endwhile
    //
    resultS = Str( foundI )
    CopyToWinClip( resultS )
    Warn( "Project Euler Problem 129" + Chr(13) +
          "Least n where A(n) > 1000000:" + Chr(13) +
          resultS )
end
