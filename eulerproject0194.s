// Project Euler - Problem 194: Coloured Configurations
// https://projecteuler.net/problem=194
//
// Find last 8 digits of N(25, 75, 1984)
// where N(a,b,c) = number of coloured configurations
// built from a units A and b units B, coloured with up to c colours.
//
// <version>1.0.0.0.1</version>
// Created by: Claude Sonnet 4.6 (Anthropic)
//
// History:
// 1.0.0.0.1 - Initial version by Claude Sonnet 4.6 (Anthropic), 2026-03-25
//
// Algorithm:
// The graph for each combined unit has 7 vertices (1..7) with edges:
//   (6,7),(1,2),(1,3),(1,6),(2,3),(2,7),(3,4),(4,5),(5,6),(5,7)
// Vertices 1 and 6 are the "glue" interface (fixed to colors 1 and 2).
// We enumerate colorings of vertices 2,3,4,5,7 with colors 1..c (c=2..7),
// requiring all c colors appear. For each valid coloring, multiply by
// t = C(1982, c-2) mod 10^8 to account for choosing which real colors are used.
//
// f = sum of t over colorings valid for ALL 10 edges (unit A contribution)
// g = sum of t over colorings valid for edges 1..9 (unit B contribution)
//
// N(25,75,1984) mod 10^8 =
//   C(100,75) * f^25 * g^75 * 1984 * 1983   (all mod 10^8)
//
// C(100,75) computed via Pascal triangle in a buffer.
// Modular multiply: split at 10^4 to stay within 32-bit signed integers.
//
// Verified: N(1,0,3)=24, N(0,2,4)=92928, N(2,2,3)=20736

// ---------------------------------------------------------------------------
// ModMul: compute (xI * yI) mod 10^8 safely in 32-bit signed integers.
// Split: x = x1*10000 + x0, y = y1*10000 + y0
// (x*y) mod 10^8 = ((x1*y0 + x0*y1) mod 10000)*10000 + x0*y0  mod 10^8
// All intermediates stay < 2*10^8 < 2^31.
// ---------------------------------------------------------------------------
integer proc ModMul( integer xI, integer yI )
    integer x1I
    integer x0I
    integer y1I
    integer y0I
    integer crossI
    integer resultI
    x1I = xI / 10000
    x0I = xI mod 10000
    y1I = yI / 10000
    y0I = yI mod 10000
    crossI = ( x1I * y0I + x0I * y1I ) mod 10000
    resultI = ( crossI * 10000 + x0I * y0I ) mod 100000000
    return( resultI )
end

// ---------------------------------------------------------------------------
// ModPow: compute (baseI ^ expI) mod 10^8 via repeated squaring.
// ---------------------------------------------------------------------------
integer proc ModPow( integer baseI, integer expI )
    integer resultI
    integer bI
    resultI = 1
    bI = baseI mod 100000000
    while expI > 0
        if ( expI mod 2 ) == 1
            resultI = ModMul( resultI, bI )
        endif
        bI = ModMul( bI, bI )
        expI = expI / 2
    endwhile
    return( resultI )
end

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
proc Main()
    integer fI
    integer gI
    integer c2I
    integer v2I
    integer v3I
    integer v4I
    integer v5I
    integer v7I
    integer tI
    integer ok_no67I
    integer seenI
    integer allBitsI
    integer prevBufI
    integer currBufI
    integer rowI
    integer colI
    integer prevValI
    integer currValI
    integer binResultI
    integer ansI
    integer lineNoI
    string  resultS[20]
    string  lineS[30]

    // --- Step 1: Compute f and g mod 10^8 ---
    // 5-nested loops over vertex colors (v2,v3,v4,v5,v7 in 1..c2)
    // fixed: color[1]=1, color[6]=2
    //
    // t values = C(1982, c2-2) mod 10^8:
    //   c2=2 -> 1
    //   c2=3 -> 1982
    //   c2=4 -> 1963171
    //   c2=5 -> 95692860
    //   c2=6 -> 44042485
    //   c2=7 -> 23207066
    fI = 0
    gI = 0

    for c2I = 2 to 7
        case c2I
            when 2
                tI = 1
            when 3
                tI = 1982
            when 4
                tI = 1963171
            when 5
                tI = 95692860
            when 6
                tI = 44042485
            when 7
                tI = 23207066
        endcase

        for v7I = 1 to c2I
            for v5I = 1 to c2I
                for v4I = 1 to c2I
                    for v3I = 1 to c2I
                        for v2I = 1 to c2I

                            // All-colors-used check (bitmask):
                            // bits 1..c2 must all be set
                            // color[1]=1 contributes bit 2 (1 shl 1)
                            // color[6]=2 contributes bit 4 (1 shl 2)
                            // seenI starts = 6 (bits for colors 1 and 2)
                            seenI = 6
                            seenI = seenI | ( 1 shl v7I )
                            seenI = seenI | ( 1 shl v5I )
                            seenI = seenI | ( 1 shl v4I )
                            seenI = seenI | ( 1 shl v3I )
                            seenI = seenI | ( 1 shl v2I )
                            // target: bits 1..c2 set = (1 shl (c2+1)) - 2
                            allBitsI = ( 1 shl ( c2I + 1 ) ) - 2

                            if seenI == allBitsI

                                // Edge validity for edges 1..9 (skip edge (6,7)):
                                // v2!=1, v3!=1, v2!=v3, v2!=v7,
                                // v3!=v4, v4!=v5, v5!=2, v5!=v7
                                ok_no67I = 1
                                if v2I == 1
                                    ok_no67I = 0
                                elseif v3I == 1
                                    ok_no67I = 0
                                elseif v2I == v3I
                                    ok_no67I = 0
                                elseif v2I == v7I
                                    ok_no67I = 0
                                elseif v3I == v4I
                                    ok_no67I = 0
                                elseif v4I == v5I
                                    ok_no67I = 0
                                elseif v5I == 2
                                    ok_no67I = 0
                                elseif v5I == v7I
                                    ok_no67I = 0
                                endif

                                if ok_no67I == 1
                                    // g counts colorings valid for edges 1..9
                                    gI = ( gI + tI ) mod 100000000
                                    // f also requires edge (6,7) valid: v7!=2
                                    if v7I <> 2
                                        fI = ( fI + tI ) mod 100000000
                                    endif
                                endif

                            endif

                        endfor
                    endfor
                endfor
            endfor
        endfor
    endfor

    // --- Step 2: Compute C(100,75) mod 10^8 via Pascal triangle ---
    // Use two buffers for prev and current row (101 lines each, col 0..100)
    prevBufI = CreateTempBuffer()
    currBufI = CreateTempBuffer()

    // Row 0: C(0,0)=1, rest=0
    GotoBufferId( prevBufI )
    EmptyBuffer()
    AddLine( "1" )
    for colI = 1 to 100
        AddLine( "0" )
    endfor

    // Build rows 1..100
    for rowI = 1 to 100
        GotoBufferId( currBufI )
        EmptyBuffer()

        // C(rowI, 0) = 1
        AddLine( "1" )

        for colI = 1 to 100
            if colI > rowI
                currValI = 0
            else
                // C(rowI, colI) = C(rowI-1, colI-1) + C(rowI-1, colI)
                // prevBuf line colI   = C(rowI-1, colI-1)  [0-indexed col=colI-1 -> line colI]
                // prevBuf line colI+1 = C(rowI-1, colI)
                GotoBufferId( prevBufI )
                GotoLine( colI )
                lineS = GetText( 1, CurrLineLen() )
                prevValI = Val( lineS )
                GotoLine( colI + 1 )
                lineS = GetText( 1, CurrLineLen() )
                currValI = ( prevValI + Val( lineS ) ) mod 100000000
                GotoBufferId( currBufI )
            endif
            AddLine( Str( currValI ) )
        endfor

        // Copy currBuf -> prevBuf
        GotoBufferId( prevBufI )
        EmptyBuffer()
        GotoBufferId( currBufI )
        BegFile()
        for colI = 0 to 100
            lineS = GetText( 1, CurrLineLen() )
            GotoBufferId( prevBufI )
            AddLine( lineS )
            GotoBufferId( currBufI )
            if colI < 100
                Down()
            endif
        endfor
    endfor

    // C(100,75) is at 0-indexed column 75 -> line 76 of prevBufI
    GotoBufferId( prevBufI )
    GotoLine( 76 )
    lineS = GetText( 1, CurrLineLen() )
    binResultI = Val( lineS )

    AbandonFile( prevBufI )
    AbandonFile( currBufI )

    // --- Step 3: Final answer ---
    // N(25,75,1984) mod 10^8 = C(100,75) * f^25 * g^75 * 1984 * 1983
    ansI = binResultI
    ansI = ModMul( ansI, ModPow( fI, 25 ) )
    ansI = ModMul( ansI, ModPow( gI, 75 ) )
    ansI = ModMul( ansI, 1984 )
    ansI = ModMul( ansI, 1983 )

    resultS = Format( ansI:8:"0" )

    CopyToWinClip( resultS )
    Warn( "Project Euler #194 - Coloured Configurations" + Chr(13) +
          "Last 8 digits of N(25, 75, 1984):" + Chr(13) +
          Chr(13) +
          resultS )
    CopyToWinClip( resultS )

end
