// ===========================================================================
// p139.s - Project Euler Problem 139: Pythagorean Tiles
// ===========================================================================
// Problem:
//   Find how many Pythagorean triangles (a,b,c), a^2+b^2=c^2,
//   with perimeter < 100,000,000 allow a c*c square (formed by 4 such
//   triangles) to be tiled by the hole squares (hole side = |b-a|).
//   Tiling is possible iff c mod |b-a| == 0.
//
// Method:
//   Generate all primitive Pythagorean triples via Euclid's formula:
//     a = m^2 - n^2,  b = 2*m*n,  c = m^2 + n^2
//   with m > n > 0, gcd(m,n) = 1, (m-n) odd.
//   Primitive perimeter P0 = 2*m*(m+n).
//   For each valid primitive triple, count multiples k where k*P0 < LIMIT.
//   Tiling condition: c mod |b-a| == 0  (only need to check on primitive).
//
// Answer: 10057761
//
// Created by: Claude Sonnet 4.6 (Anthropic)
// <version>1.0.0.0.1</version>
// ===========================================================================

constant LIMIT = 100000000   // 10^8

// ---------------------------------------------------------------------------
// GCD via Euclidean algorithm
// ---------------------------------------------------------------------------
integer proc GCD( integer aI, integer bI )
    integer tmpI = 0
    //
    while bI <> 0
        tmpI = bI
        bI   = aI mod bI
        aI   = tmpI
    endwhile
    return( aI )
end

// ---------------------------------------------------------------------------
// Absolute value
// ---------------------------------------------------------------------------
integer proc AbsVal( integer xI )
    //
    if xI < 0
        return( -xI )
    endif
    return( xI )
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer mI       = 0   // Euclid parameter m
    integer nI       = 0   // Euclid parameter n
    integer aI       = 0   // triple leg a
    integer bI       = 0   // triple leg b
    integer cI       = 0   // triple hypotenuse c
    integer perimI   = 0   // primitive perimeter
    integer diffI    = 0   // |b - a|
    integer countI   = 0   // total count of valid triangles
    integer multipI  = 0   // number of valid multiples
    string  resultS[32] = ""
    //
    // Euclid: m from 2 upward; inner n from 1 to m-1
    // Primitive perimeter = 2*m*(m+n); stop when 2*m*(m+1) >= LIMIT
    //
    mI = 2
    while ( 2 * mI * ( mI + 1 ) ) < LIMIT
        nI = 1
        while nI < mI
            // m-n must be odd (one even, one odd)
            if ( ( mI - nI ) mod 2 ) == 1
                // gcd(m,n) must be 1
                if GCD( mI, nI ) == 1
                    aI     = mI * mI - nI * nI
                    bI     = 2 * mI * nI
                    cI     = mI * mI + nI * nI
                    perimI = aI + bI + cI        // = 2*m*(m+n)
                    diffI  = AbsVal( bI - aI )
                    // Tiling condition: diffI divides cI
                    if diffI > 0
                        if cI mod diffI == 0
                            // Count multiples k*perimI < LIMIT
                            multipI = ( LIMIT - 1 ) / perimI
                            countI  = countI + multipI
                        endif
                    endif
                endif
            endif
            nI = nI + 1
        endwhile
        mI = mI + 1
    endwhile
    //
    resultS = Str( countI )
    CopyToWinClip( resultS )
    Warn( "Project Euler #139 - Pythagorean Tiles", Chr(13),
          "Pythagorean triangles (perimeter < 10^8)", Chr(13),
          "allowing c*c tiling: ", resultS )
end
