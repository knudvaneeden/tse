// ============================================================
// Project Euler - Problem 206: Concealed Square
// Find unique positive integer whose square has form:
// 1_2_3_4_5_6_7_8_9_0  (19 digits)
// ============================================================
// Strategy:
//   n ends in 0 -> n = 10*k
//   k^2 = 1_2_3_4_5_6_7_8_9 (17 digits, last digit = 9)
//   k ends in 3 or 7 (so k^2 ends in 9)
//   k in range [101010103 .. 138902663]
//   Split k = A*10000 + B to avoid 32-bit overflow:
//     k^2 = A^2*10^8 + 2*A*B*10^4 + B^2
//   Compute three sub-products (each fits in 32-bit signed):
//     p0 = B^2            max ~9.998*10^7  fits
//     p1 = 2*A*B          max ~2.78*10^8   fits
//     p2 = A^2            max ~1.93*10^8   fits
//   Propagate carries between groups of 4 digits:
//     low4     = p0 mod 10000
//     carry1   = p0 / 10000
//     midSum   = p1 + carry1
//     low4mid  = midSum mod 10000
//     carry2   = midSum / 10000
//     highSum  = p2 + carry2
//   Extract and check fixed digit positions:
//     D=2  in low4    : (low4    /     100) mod 10 == 8
//     D=4  in low4mid : low4mid           mod 10 == 7
//     D=6  in low4mid : (low4mid /     100) mod 10 == 6
//     D=8  in highSum : highSum           mod 10 == 5
//     D=10 in highSum : (highSum /     100) mod 10 == 4
//     D=12 in highSum : (highSum /   10000) mod 10 == 3
//     D=14 in highSum : (highSum / 1000000) mod 10 == 2
//     D=16 in highSum : (highSum /100000000) mod 10 == 1
//   n = k * 10
// ============================================================
// <version>1.0.0.0.1</version>
// History:
//   1.0.0.0.1  2025-03-25  Created by Claude (Anthropic)
// ============================================================

proc Main()
    string  ansS[20]    = ""
    integer kI          = 0
    integer modI        = 0
    integer aI          = 0
    integer bI          = 0
    integer p0I         = 0
    integer p1I         = 0
    integer p2I         = 0
    integer carry1I     = 0
    integer carry2I     = 0
    integer midSumI     = 0
    integer low4I       = 0
    integer low4midI    = 0
    integer highSumI    = 0
    integer foundB      = FALSE
    //
    // k must end in 3 or 7; step by 2, check mod 10
    // range: 101010103 .. 138902663
    //
    kI = 101010103
    while kI <= 138902663 and foundB == FALSE
        modI = kI mod 10
        if modI == 3 or modI == 7
            aI = kI / 10000
            bI = kI mod 10000
            p0I     = bI * bI
            p1I     = 2 * aI * bI
            p2I     = aI * aI
            carry1I  = p0I / 10000
            low4I    = p0I mod 10000
            midSumI  = p1I + carry1I
            carry2I  = midSumI / 10000
            low4midI = midSumI mod 10000
            highSumI = p2I + carry2I
            if (low4I / 100) mod 10 == 8
                if low4midI mod 10 == 7
                    if (low4midI / 100) mod 10 == 6
                        if highSumI mod 10 == 5
                            if (highSumI / 100) mod 10 == 4
                                if (highSumI / 10000) mod 10 == 3
                                    if (highSumI / 1000000) mod 10 == 2
                                        if (highSumI / 100000000) mod 10 == 1
                                            foundB = TRUE
                                            ansS = Str(kI) + "0"
                                        endif
                                    endif
                                endif
                            endif
                        endif
                    endif
                endif
            endif
        endif
        kI = kI + 2
    endwhile
    CopyToWinClip(ansS)
    Warn("P206 Concealed Square answer: " + Chr(13) + ansS)
    CopyToWinClip(ansS)
end
